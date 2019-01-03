;; Resize a layer to match dimension passing in parameter 
;; according to the image resolution
;; Also add a frame with a shadow to that layer
;;
;; Default behavior use a postal card format 
;;
;; Layer are not cropped if it does not fit parameters values
;;
;; @param : 
;; - height : height of the layer in inch, default 3.71 inch
;; - width : width of the layer in inch, default 5.94 inch
;; - frameBorderInInch : border thickness
;;
;; TODO : Add parameters for targeted resolutions
;; TODO : Run that script in mass
;; TODO : Reduce size image
(define (script-fu-cadre image drawable heigth width frameBorderInInch)
	
	;; Indicate beginning of actions. Used for UNDO actions 
	(gimp-image-undo-group-start image)

	(let* 
		(
			(frameHeightInInch heigth)
			(frameWidthInInch width)
			;;(frameBorderInInch 0.2)

			;; Get image sizing values
			(widthImageInPixel (car (gimp-image-width image)))
			(heigthImageInPixel (car (gimp-image-height image)))

			;; Create a frame layer and a shadow layer using image size
			(frameLayer (script-fu-add-transparent-layer image widthImageInPixel heigthImageInPixel "Frame"))
			(layerShadow (script-fu-add-transparent-layer image widthImageInPixel heigthImageInPixel "Shadow"))

			;; Get image resolution
			(resolution (car (gimp-image-get-resolution image)))

			;; Compute Frame sizes
			(widthFrameInPixel (round (* resolution frameWidthInInch)))
			(heigthFrameInPixel (round (* resolution frameHeightInInch)))
			(frameBorderInPixel (round (* resolution frameBorderInInch)))

			;; Compute frame coordinates 
			(x (- (/ widthImageInPixel 2) (/ widthFrameInPixel 2)))
			(y (- (/ heigthImageInPixel 2) (/ heigthFrameInPixel 2)))

			;; rapport des bordures du cadre interieur height / width
			(rapportCadre (/ (- heigthFrameInPixel (* frameBorderInPixel 2)) (- widthFrameInPixel (* frameBorderInPixel 2))))

			;; Define shadow color
			(black (list 0 0 0))

			(layerOffsets 0)

			;; Get layer sizing values
			(heightLayer (car (gimp-drawable-height drawable)))
			(widthLayer (car (gimp-drawable-width drawable)))

			;; Determine if image is in vertical or horizontal mode
			(rapportLayer (/ heightLayer widthLayer))

			(heightFrameWithoutBorder (- heigthFrameInPixel (* frameBorderInPixel 2)))
			(widthFrameWithoutBorder (- widthFrameInPixel (* frameBorderInPixel 2)))
		)

		(gimp-layer-add-alpha drawable)
		
		;; Affiche le nom du calque sélectionné
		;;(gimp-message (car (gimp-item-get-name drawable)))

		;; Build frame margin
		(script-fu-build-margin image frameLayer x y widthFrameInPixel frameBorderInPixel);;Top
		(script-fu-build-margin image frameLayer x (- (+ y heigthFrameInPixel) frameBorderInPixel) widthFrameInPixel frameBorderInPixel);;Bottom
		(script-fu-build-margin image frameLayer x y frameBorderInPixel heigthFrameInPixel);;Left
		(script-fu-build-margin image frameLayer (- (+ x widthFrameInPixel) frameBorderInPixel) y frameBorderInPixel heigthFrameInPixel);;Right


		;;Select a rectangle inside frame
		(gimp-image-select-rectangle image CHANNEL-OP-REPLACE x y widthFrameInPixel heigthFrameInPixel)  
		(gimp-edit-fill layerShadow FOREGROUND-FILL)

		;; Add shadow
		(script-fu-drop-shadow image layerShadow 0 0 60 black 75 0)
		(gimp-image-remove-layer image layerShadow)

		;; Fusionne les calques 
		(gimp-image-merge-down image (car (gimp-image-get-layer-by-name image "Drop Shadow")) 1)

		;; Resize Layer into the frame
		(script-fu-resize-layer drawable (- widthFrameInPixel (* 2 frameBorderInPixel)) (- heigthFrameInPixel (* 2 frameBorderInPixel))) 

		(if (> rapportCadre rapportLayer)
			(begin 
				(script-fu-resize-layer drawable (/ heightFrameWithoutBorder rapportLayer) heightFrameWithoutBorder)
			)
			(begin 
				(script-fu-resize-layer drawable widthFrameWithoutBorder (* widthFrameWithoutBorder rapportLayer)) 
			)
		)
		
		;; Move layer
		(set! layerOffsets (gimp-drawable-offsets drawable))
		(gimp-layer-translate drawable (+ frameBorderInPixel (- x (car layerOffsets))) (+ frameBorderInPixel (- y (cadr layerOffsets))))

		(gimp-selection-none image)
		(gimp-displays-flush)
	
	)

	;; Termine la fonction "undo"
	(gimp-image-undo-group-end image)
)

(script-fu-register
	"script-fu-cadre"                   						;func name
    "Cadre"	                                  				;menu label
	"Inclue le calque dans un cadre"					;description
    "Julien Girard" 	                            				;author
    ""				        					;copyright notice
	"August 25, 2015"                          					;date created
	"RGB*, GRAY*"                     						;image type that the script works on
	SF-IMAGE "image" 0								;param 0
	SF-DRAWABLE "drawable" 0							;param 1
	SF-VALUE "hauteur (inch)" "3.71"							;param 1
	SF-VALUE "largeur (inch)" "5.94"							;param 2
	SF-VALUE "Largeur Bordure (inch)" "0.2"
)
 
 (script-fu-menu-register "script-fu-cadre" "<Image>/Filters/Script Perso")
