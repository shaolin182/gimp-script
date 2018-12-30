;; Transforme le calque sélectionné pour être inclus dans un format de carte postale
;; Le calque respecte la résolution de l'image et est redimensionné au besoin pour correspondre au format carte postale
(define (script-fu-cadre image drawable heigth width frameBorderInInch)
	
	;; début du script. Permet de ne faire qu'une seule fois "Undo" pour toutes les manips
	(gimp-image-undo-group-start image)

	(let* 
		(
			(frameHeightInInch heigth)
			(frameWidthInInch width)
			;;(frameBorderInInch 0.2)

			(widthImageInPixel (car (gimp-image-width image)))
			(heigthImageInPixel (car (gimp-image-height image)))

			;; Crée un calque pour le contour du cadre et l'ombre
			(frameLayer (script-fu-add-transparent-layer image widthImageInPixel heigthImageInPixel "Frame"))
			(layerShadow (script-fu-add-transparent-layer image widthImageInPixel heigthImageInPixel "Shadow"))

			;; Récupération de la résolution de l'image, on part du principe que la résolution est la meme pour x et y
			(resolution (car (gimp-image-get-resolution image)))

			;; Calcul les dimensions du cadre
			(widthFrameInPixel (round (* resolution frameWidthInInch)))
			(heigthFrameInPixel (round (* resolution frameHeightInInch)))
			(frameBorderInPixel (round (* resolution frameBorderInInch)))

			;; Position du cadre
			(x (- (/ widthImageInPixel 2) (/ widthFrameInPixel 2)))
			(y (- (/ heigthImageInPixel 2) (/ heigthFrameInPixel 2)))

			;; rapport des bordures du cadre interieur height / width
			(rapportCadre (/ (- heigthFrameInPixel (* frameBorderInPixel 2)) (- widthFrameInPixel (* frameBorderInPixel 2))))

			;; Define shadow color
			(black (list 0 0 0))

			(layerOffsets 0)

			(heightLayer (car (gimp-drawable-height drawable)))
			(widthLayer (car (gimp-drawable-width drawable)))

			(rapportLayer (/ heightLayer widthLayer))

			(heightFrameWithoutBorder (- heigthFrameInPixel (* frameBorderInPixel 2)))
			(widthFrameWithoutBorder (- widthFrameInPixel (* frameBorderInPixel 2)))
		)

		(gimp-layer-add-alpha drawable)
		
		;; Affiche le nom du calque sélectionné
		;;(gimp-message (car (gimp-item-get-name drawable)))

		;; Crée les marges du cadre
		(script-fu-build-margin image frameLayer x y widthFrameInPixel frameBorderInPixel);;Top
		(script-fu-build-margin image frameLayer x (- (+ y heigthFrameInPixel) frameBorderInPixel) widthFrameInPixel frameBorderInPixel);;Bottom
		(script-fu-build-margin image frameLayer x y frameBorderInPixel heigthFrameInPixel);;Left
		(script-fu-build-margin image frameLayer (- (+ x widthFrameInPixel) frameBorderInPixel) y frameBorderInPixel heigthFrameInPixel);;Right


		;;Select a rectangle inside frame
		(gimp-image-select-rectangle image CHANNEL-OP-REPLACE x y widthFrameInPixel heigthFrameInPixel)  
		(gimp-edit-fill layerShadow FOREGROUND-FILL)

		;; Get drawable
		(script-fu-drop-shadow image layerShadow 0 0 60 black 75 0)
		(gimp-image-remove-layer image layerShadow)

		;; Fusionne les calques 
		(gimp-image-merge-down image (car (gimp-image-get-layer-by-name image "Drop Shadow")) 1)

		;; redimensionne le calque pour rentrer dans le cadre
		;; Récupération de la largeur et hauteur de la photo en pixel en fonction du rapport attendu
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
