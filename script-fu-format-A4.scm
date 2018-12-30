;; Modifie les dimensions de l'image pour respecter les dimensions données en entrée
;; tout en tenant compte des dimensions de la photo d'origine pour garder la meilleure définition
(define (script-fu-redim-img image hauteur largeur margeHeigth margeWidth)
	
	;; début du script. Permet de ne faire qu'une seule fois "Undo" pour toutes les manips
	(gimp-image-undo-group-start image)

	(let* 
		(
			;; Taille d'un pouce en cm
			(pouce 2.54)
			(width 10)
			(height 10)

			;; Récupère la hauteur et la largeur de l'image en pixel
			(height-img-origine (car (gimp-image-height image)))
			(width-img-origine (car (gimp-image-width image)))

			;; On détermine le rapport du format attendu et le rapport de la photo
			;;(rapport_photo (/ height_img_origine width_img_origine))
			(rapport-attendu (/ (- hauteur (* margeHeigth 2)) (- largeur (* margeWidth 2))))

			;; Largeur idéale en fonction du rapport attendu et de la hauteur de la photo
			(width-expected (round (/ height-img-origine rapport-attendu)))

			;; Calcul de la résolution pour avoir des dimensions en cm qui respecte les paramètres d'entrée
			;; On détermine combien de pixels on souhaite par centimetre
			(res (round (/ (* height-img-origine pouce) (- hauteur (* margeHeigth 2)))))
			
			;; init variable theLayer
			(theLayer 0)
			(selection 0)

			;; Détermination de la taille des marges en pixel
			(margeHeigthInPixel (script-fu-compute-margin-in-pixel res margeHeigth))
			(margeWidthInPixel (script-fu-compute-margin-in-pixel res margeWidth))

			;; Define shadow color
			(black (list 0 0 0))

		)

		(if (< width-expected width-img-origine) 
			;; si la largeur idéale est < à la largeur de la photo, alors largeur définitive = largeur idéale
			(begin
				(set! width width-expected)
				(set! height height-img-origine)
		
			)
			;; si la largeur idéale est > à la largeur de la photo, alors on modifie la hauteur de la photo
			(begin
				(set! height (* width-img-origine rapport-attendu))
				(set! width width-img-origine)
			)
		)

		;; On redimensionne une 1ere fois l'image ==> l'image a les proportions correctes sans les marges
		(gimp-image-resize image width height 0 0)

		;; On redimensionne une 2nde fois l'image pour ajouter la marge (et on décale l'existant)
		(gimp-image-resize image (+ width (* 2 margeWidthInPixel)) (+ height (* 2 margeHeigthInPixel)) margeWidthInPixel margeHeigthInPixel)

		;; On crée un nouveau calque transparent qui tient compte compte des marges
		(set! theLayer (script-fu-add-transparent-layer image (+ width (* 2 margeWidthInPixel)) (+ height (* 2 margeHeigthInPixel)) "Frame"))
    			
  		;; Create marge
		(script-fu-build-margin image theLayer 0 0 (+ width (* 2 margeWidthInPixel)) margeHeigthInPixel) ;; Top
		(script-fu-build-margin image theLayer 0 (+ height margeHeigthInPixel) (+ width (* 2 margeWidthInPixel)) margeHeigthInPixel) ;; Bottom
		(script-fu-build-margin image theLayer 0 0 margeWidthInPixel (+ height margeHeigthInPixel)) ;; Left
		(script-fu-build-margin image theLayer (+ width margeWidthInPixel) 0 margeWidthInPixel (+ height margeHeigthInPixel)) ;; Right

		;; Création d'un nouveau calque représentant la région à l'intérieur du calque pour ensuite ajouter une ombre
		(set! theLayer (script-fu-add-transparent-layer image (+ width (* 2 margeWidthInPixel)) (+ height (* 2 margeHeigthInPixel)) "Shadow"))

		;;Select a rectangle inside frame
		(gimp-image-select-rectangle image CHANNEL-OP-REPLACE margeWidthInPixel margeHeigthInPixel width height)  
		(gimp-edit-fill theLayer FOREGROUND-FILL)

		;; Get drawable
		(script-fu-drop-shadow image theLayer 20 20 45 black 60 0)

		(gimp-image-remove-layer image theLayer)

		;; Fusionne les calques 
		(gimp-image-merge-down image (car (gimp-image-get-layer-by-name image "Drop Shadow")) 1)
		
		;; Modification de la résolution
		(gimp-image-set-resolution image res res)

		(gimp-selection-none image)
		(gimp-displays-flush)
	
	)

	;; Termine la fonction "undo"
	(gimp-image-undo-group-end image)
)

(script-fu-register
	"script-fu-redim-img"                   					;func name
    	"Cadre (Obsolète)"	                                  					;menu label
	"Modifie la taille de l'image pour obtenir le format saisi en paramètre"	;description
    	"Julien Girard" 	                            				;author
    	""				        					;copyright notice
	"April 30, 2011"                          					;date created
	"RGB*, GRAY*"                     						;image type that the script works on
	SF-IMAGE "image" 0								;param 0
	SF-VALUE "hauteur (cm)" "20.5"							;param 1
	SF-VALUE "largeur (cm)" "27"							;param 2
	SF-VALUE "Marge Hauteur (cm)" "1"						;param 3
	SF-VALUE "Marge Largeur (cm)" "1"						;param 4
)
 
 (script-fu-menu-register "script-fu-redim-img" "<Image>/Filters/Script Perso")
