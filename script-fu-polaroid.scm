;; Transforme le calque sélectionné pour être inclus dans un format polaroid
;; Le calque respecte la résolution de l'image et est redimensionné au besoin pour correspondre au format polaroid
(define (script-fu-polaroid image drawable)
	
	;; début du script. Permet de ne faire qu'une seule fois "Undo" pour toutes les manips
	(gimp-image-undo-group-start image)

	(let* 
		(
			(polaroidHeightInInch 4.4)
			(polaroidWidthInInch 3.6)
			(polaroidBorderInInch 0.2)
			(polaroidBottomBorderInInch 0.87)

			(widthImageInPixel (car (gimp-image-width image)))
			(heigthImageInPixel (car (gimp-image-height image)))

			;; Crée un calque pour le contour du polaroid et l'ombre
			(polaroidLayer (script-fu-add-transparent-layer image widthImageInPixel heigthImageInPixel "Frame"))
			(layerShadow (script-fu-add-transparent-layer image widthImageInPixel heigthImageInPixel "Shadow"))

			;; Récupération de la résolution de l'image, on part du principe que la résolution est la meme pour x et y
			(resolution (car (gimp-image-get-resolution image)))

			;; Calcul les dimensions du polaroid
			(widthPolaroidInPixel (round (* resolution polaroidWidthInInch)))
			(heigthPolaroidInPixel (round (* resolution polaroidHeightInInch)))
			(polaroidBorderInPixel (round (* resolution polaroidBorderInInch)))
			(polaroidBottomBorderInPixel (round (* resolution polaroidBottomBorderInInch)))

			;; Position du polaroid
			(x (- (/ widthImageInPixel 2) (/ widthPolaroidInPixel 2)))
			(y (- (/ heigthImageInPixel 2) (/ heigthPolaroidInPixel 2)))

			;; Define shadow color
			(black (list 0 0 0))

			(layerOffsets 0)
		)

		(gimp-layer-add-alpha drawable)
		
		;; Affiche le nom du calque sélectionné
		(gimp-message (car (gimp-item-get-name drawable)))

		;; Crée les marges du polaroid
		(script-fu-build-margin image polaroidLayer x y widthPolaroidInPixel polaroidBorderInPixel);;Top
		(script-fu-build-margin image polaroidLayer x (- (+ y heigthPolaroidInPixel) polaroidBottomBorderInPixel) widthPolaroidInPixel polaroidBottomBorderInPixel);;Bottom
		(script-fu-build-margin image polaroidLayer x y polaroidBorderInPixel heigthPolaroidInPixel);;Left
		(script-fu-build-margin image polaroidLayer (- (+ x widthPolaroidInPixel) polaroidBorderInPixel) y polaroidBorderInPixel heigthPolaroidInPixel);;Right


		;;Select a rectangle inside frame
		(gimp-image-select-rectangle image CHANNEL-OP-REPLACE x y widthPolaroidInPixel heigthPolaroidInPixel)  
		(gimp-edit-fill layerShadow FOREGROUND-FILL)

		;; Get drawable
		(script-fu-drop-shadow image layerShadow 0 0 60 black 75 0)
		(gimp-image-remove-layer image layerShadow)

		;; Fusionne les calques 
		;;(gimp-image-merge-down image (car (gimp-image-get-layer-by-name image "Drop Shadow")) 1)

		;; redimensionne le calque pour rentrer dans le polaroid
		;; Récupération de la largeur et hauteur de la photo en pixel en fonction du rapport attendu
		(script-fu-resize-layer drawable (- widthPolaroidInPixel (* 2 polaroidBorderInPixel)) (- heigthPolaroidInPixel (+ polaroidBottomBorderInPixel polaroidBorderInPixel))) 
		
		;; Move layer
		(set! layerOffsets (gimp-drawable-offsets drawable))
		(gimp-layer-translate drawable (+ polaroidBorderInPixel (- x (car layerOffsets))) (+ polaroidBorderInPixel (- y (cadr layerOffsets))))

		(gimp-selection-none image)
		(gimp-displays-flush)
	
	)

	;; Termine la fonction "undo"
	(gimp-image-undo-group-end image)
)

(script-fu-register
	"script-fu-polaroid"                   						;func name
    	"Polaroid"	                                  				;menu label
	"Inclue le calque dans un format polaroid"					;description
    	"Julien Girard" 	                            				;author
    	""				        					;copyright notice
	"August 25, 2015"                          					;date created
	"RGB*, GRAY*"                     						;image type that the script works on
	SF-IMAGE "image" 0								;param 0
	SF-DRAWABLE "drawable" 0							;param 1
)
 
 (script-fu-menu-register "script-fu-polaroid" "<Image>/Filters/Script Perso")
