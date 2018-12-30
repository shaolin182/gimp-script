;; Le besoin : 
;; On prend n images en entrée pour les positionnées sur un cadre blanc.
;; Les dimensions du cadre blanc sont fournis en paramètre d'entrée ainsi que les espaces entre les photos
;; Enfin, les dimensions de la plus petite image sont utilisées pour gérer la résolution de l'ensemble.
(define (script-fu-three-img image hauteur largeur margeHeigth margeWidth)

	;; Calcule la résolution de l'image
	;;
	;; nbPhoto : Nombre de photos présents dans l'image
	;; largeurImage : largeur de l'image en cm
	;; largeurMarge : largeur de la marge en cm
	;; doublePage : est ce que l'image représente 2 pages ?
	;; dimPhoto : dimension en pixel de la photo avec le nombre de pixels le moins grand
	(define (getResolution nbPhoto largeurImage largeurMarge doublePage dimPhoto)

		(let* 
			(
				(resolution 0)
				(pouce 2.54)
				(nbPixelsWidth 0)
			)

			;; Cas des double pages, on retire une marge supplémentaire
			(if (> doublePage 0)
				(begin 
					(set! largeurImage (- largeurImage margeWidth))
				)
			) 
	
			;; Pour obtenir la résolution, on estime le nombre de pixels de large de la photo (sans les marges)
			(set! nbPixelsWidth (* (* nbPhoto (cadr dimPhoto)) pouce))

			;; on divise maintenant le nombre de pixels par le nombre de cm voulus en largeur
			(set! resolution (round (/ nbPixelsWidth (- largeurImage (* largeurMarge (+ nbPhoto 1)))))) 
		)
	)

	;; En fonction des dimensions de l'image finale, de la taille des marges et du nb de photo de l'image finale,
	;; on détermine le rapport que doit avoir chacune des photos
	;; Si on est dans le cas de double page et que le nombre d'images est pair, on rajouter une marge
	;;
	;; hauteurImage : hauteur de l'image en cm
	;; largeurImage : largeur de l'image en cm
	;; largeurMarge : largeur de la marge en cm
	;; hauteurMarge : hauteur de la marge en cm
	;; nbPhoto : Nombre de photos présents dans l'image
	;; doublePage : est ce que l'image représente 2 pages ?
	;;
	;; TODO gérer le cas où les photos sont alignées verticalement
	(define (getRapportTarget hauteurImage largeurImage largeurMarge hauteurMarge nbPhoto doublePage) 
		(let* 
			(
				(largeurPhoto (- largeurImage (* largeurMarge (+ nbPhoto 1))))
				(hauteurPhoto (- hauteurImage (* hauteurMarge 2)))

				(rapportTarget 0)
			)

			;; Cas des double pages
			(if (> doublePage 0)
				(begin 
					(set! largeurPhoto (- largeurPhoto margeWidth))
				)
			) 

			(set! largeurPhoto (/ largeurPhoto nbPhoto))
			(set! rapportTarget (/ hauteurPhoto largeurPhoto))
		)
	)

	;; En fonction du rapport de la photo attendu, on calcule la hauteur et la largeur en pixel du calque
	;; pour que les dimensions soient conformes à ce rapport
	;; On retourne ensuite la hauteur et la largeur en pixel du calque dans une liste
	;; Dans tous les cas, on respecte le rapport du calque
	;;
	;; layer : calque pour lequel on veut les dimensions
	;; rapportTarget : rapport entre la largeur et la hauteur de la photo que l'on souhaite avoir pour le calque
	(define (getDimensionLayer layer rapportTarget)
		(let* 
			(
				;; Récupère la hauteur et la largeur du calque en pixel
				(height-img-origine (car (gimp-drawable-height layer)))
				(width-img-origine (car (gimp-drawable-width layer)))

				;; Rapport du calque actuelle
				(rapportCalque (/ height-img-origine width-img-origine))

				;; Result
				(heigthLayer 0)
				(widthLayer 0)
			)

			(gimp-message (number->string rapportTarget))
			(gimp-message (number->string rapportCalque))


			
			(if (< rapportCalque rapportTarget)
				(begin 
					(set! widthLayer (round (/ height-img-origine rapportTarget)))
					(set! heigthLayer height-img-origine)
				)
				(begin 
					(set! heigthLayer (round (* width-img-origine rapportTarget)))
					(set! widthLayer width-img-origine)
				)
			)

			(list heigthLayer widthLayer)
		)
	)

	;; On retourne le produit de la hauteur par la largeur du calque pour estimer le 'poids' d'une image
	;;
	;; dimPhoto : liste qui contient 2 élements : la hauteur et la largeur du calque
	(define (getImageWeigth dimPhoto)
		(let* 
			(
				(result 0)
			)
			
			(set! result (* (car dimPhoto) (cadr dimPhoto)))
		)
	)

	;; Retourne le calque avec la plus petite dimension
	;;
	;; layers : liste de tous les calques de l'image
	;; rapportTarget : rapport entre la largeur et la hauteur de la photo que l'on souhaite avoir pour le calque
	(define (getSmallLayer layers rapportTarget)

		(let* 
			(
				;; On récupère le nombre de calques de l'image
				(nbLayers (car layers))

				;; index pour boucle
				(i 0)

				;; index du calque courant
				(layerIndex 0)

				;; Index du calque le plus petit
				(smallLayer 0)

				;; Dimension récupérée de la fonction
				(dim 0)

				;; Dimension du plus petit layer
				(smallDim 10000000000000)

			)
			
			;; on boucle sur tous les calques et on affiche leur noms
			(while (< i nbLayers)
				(set! layerIndex (vector-ref (cadr layers) i))
				
				(set! dim (getImageWeigth (getDimensionLayer layerIndex rapportTarget)))

				(gimp-message (number->string dim))
				
				(if (> smallDim dim)
					(begin
						(set! smallDim dim)
						(set! smallLayer layerIndex)
					)
				)
				(gimp-layer-add-alpha layerIndex)

				(set! i (+ i 1))
			)

			;; Retourne l'index du plus petit calque
			smallLayer
		)
	)

	;; Ajoute une ombre autour de chaque cadre
	;;
	;; image : image de base
	;; widthImage : largeur de l'image en pixel
	;; heigthImage : hauteur de l'image en pixel
	;; margeWidthInPixel : largeur des marges verticales en pixel
	;; margeHeigthInPixel : hauteur des marges horizontales en pixel
	;; widthPhoto : largeur d'une photo en pixel qui permet de construire la sélection des ombres
	;; heigthPhoto : hauteur d'une photo en pixel qui permet de construire la sélection des ombres
	;; nbPhoto : Nombre de photos composants l'image finale
	(define (addShadows image widthImage heigthImage margeWidthInPixel margeHeigthInPixel widthPhoto heigthPhoto nbPhoto)

		(let* 
			(
				(newLayer 0)
				(i 0)

				;; Define shadow color
				(black (list 0 0 0))
			)

			;; On crée les marges intérieures
			(while (< i nbPhoto)

				;; Création d'un nouveau calque représentant la région à l'intérieur du calque pour ensuite ajouter une ombre
				(set! newLayer (script-fu-add-transparent-layer image widthImage heigthImage "Shadow"))

				;;Select a rectangle inside frame
				(gimp-image-select-rectangle image CHANNEL-OP-REPLACE (+ (* margeWidthInPixel (+ i 1)) (* widthPhoto i)) margeHeigthInPixel widthPhoto heigthPhoto)  
				(gimp-edit-fill newLayer FOREGROUND-FILL)

				;; Get drawable
				(script-fu-drop-shadow image newLayer 20 20 45 black 60 0)

				(set! i (+ 1 i))

				(gimp-image-remove-layer image newLayer)

				;; Fusionne les calques 
				(gimp-image-merge-down image (car (gimp-image-get-layer-by-name image "Drop Shadow")) 1)
			)		
		)
	)

	;; Construit le cadre blanc autour des photos en respectant les paramètres d'entrée
	;;
	;; image : image de base
	;; widthImage : largeur de l'image en pixel
	;; heigthImage : hauteur de l'image en pixel
	;; nbPhoto : Nombre de photos composants l'image finale
	;; doublePage : Est ce que l'image représente une double page
	;; widthMargeInPixel : largeur des marges verticales en pixel
	;; heigthMargeInPixel : hauteur des marges horizontales en pixel
	;; widthPhoto : largeur d'une photo en pixel qui permet d'espacer les marges intermédiaires
	(define (buildFrame image widthImage heigthImage nbPhoto doublePage margeWidthInPixel margeHeigthInPixel widthPhoto)

		(let*
			(
				(newLayer 0)
				(i 1)
			)
			
			(gimp-image-resize image widthImage heigthImage 0 0)
			
			;; On crée un nouveau calque transparent qui tient compte compte des marges
			(set! newLayer (script-fu-add-transparent-layer image widthImage heigthImage "Frame"))

			;; On crée les marges extérieures
			(script-fu-build-margin image newLayer 0 0 widthImage margeHeigthInPixel) ;; Top
			(script-fu-build-margin image newLayer 0 (- heigthImage margeHeigthInPixel) widthImage margeHeigthInPixel) ;; Bottom
			(script-fu-build-margin image newLayer 0 0 margeWidthInPixel heigthImage) ;; Left
			(script-fu-build-margin image newLayer (- widthImage margeWidthInPixel) 0 margeWidthInPixel heigthImage) ;; Rigth

			;; On crée les marges intérieures
			(while (< i (+ nbPhoto 1))
				
				(script-fu-build-margin image newLayer (+ (* i margeWidthInPixel) (* i widthPhoto)) 0 margeWidthInPixel heigthImage)

				(set! i (+ 1 i))
			)

		)
	)

	;; Calcule les dimensions de l'image en pixel
	;;
	;; widthPhoto : largeur d'une photo en pixel
	;; heigthPhoto : Hauteur d'une photo en pixel
	;; nbPhoto : Nombre de photos composants l'image finale
	;; doublePage : Est ce que l'image représente une double page
	;; widthMargeInPixel : largeur des marges verticales en pixel
	;; heigthMargeInPixel : hauteur des marges horizontales en pixel
	(define (computeDimImage widthPhoto heigthPhoto nbPhoto doublePage widthMargeInPixel heigthMargeInPixel)
		(let* 
			(
				(widthImage (+ (* widthPhoto nbPhoto) (* (+ nbPhoto 1) widthMargeInPixel)))
				(heigthImage (+ heigthPhoto (* 2 heigthMargeInPixel)))
			)
			(list widthImage heigthImage)
		)
	)

	;; Déplace chaque calque à l'endroit prévu et redimensionne le calque au besoin
	;;
	;; allLayers : liste de tous les calques de l'image
	(define (resizeAndMoveLayers image allLayers rapportTarget dimSmallLayer margeHeigthInPixel margeWidthInPixel widthPhoto)
		(let* 
			(
				(i 0)
				(nbLayers (car allLayers))
				(layerIndex 0)
				(dimPhoto 0)
				
				(layerOffsets 0)

				(height-img-origine 0)
				(width-img-origine 0)
			)
				
			(while (< i nbLayers)
				(set! layerIndex (vector-ref (cadr allLayers) i))

				;; Récupère la hauteur et la largeur du calque en pixel
				(set! height-img-origine (car (gimp-drawable-height layerIndex)))
				(set! width-img-origine (car (gimp-drawable-width layerIndex)))
				
				;; on le resize
				(if (> rapportTarget (/ height-img-origine width-img-origine))
					(begin 
						(gimp-message "cas 1")
						(script-fu-resize-layer layerIndex (/ (car dimSmallLayer) (/ height-img-origine width-img-origine)) (car dimSmallLayer)) 
					)
					(begin 
						(gimp-message "cas 2")
						(script-fu-resize-layer layerIndex (cadr dimSmallLayer) (* (cadr dimSmallLayer) (/ height-img-origine width-img-origine))) 
					)
				)

				;; on la déplace
				(set! layerOffsets (gimp-drawable-offsets layerIndex))
				(gimp-layer-translate layerIndex (- (+ (* (- nbLayers i)  margeWidthInPixel) (* (- (- nbLayers 1) i) widthPhoto)) (car layerOffsets)) (- margeHeigthInPixel (cadr layerOffsets)))

				(set! i (+ i 1))
			)
		)
	)

	;; début du script. Permet de ne faire qu'une seule fois "Undo" pour toutes les manips
	(gimp-image-undo-group-start image)

	(let* 
		
		(
			;; Initialisation de variables
			;; Récupération de l'ensemble des calques
			(all_layers (gimp-image-get-layers image))
			(nbPhoto (car all_layers))
			(rapportTarget 0)
			(smallLayer 0)
			(resolution 0)
			(dimPhoto 0)
			(dimImage 0)
			(margeHeigthInPixel 0)
			(margeWidthInPixel 0)

		)

		;; On calcule le rapport que les photos devront avoir
		;; TODO passer en paramètre du script la notion de double page
		(set! rapportTarget (getRapportTarget hauteur largeur margeWidth margeHeigth nbPhoto 0))
		(gimp-message (number->string rapportTarget))

		;; On récupère le calque le plus petit qui va nous servir pour définir la résolution de l'image
		(set! smallLayer (getSmallLayer all_layers rapportTarget))
		(gimp-message (car (gimp-layer-get-name smallLayer)))

		;; On récupère les dimensions de la partie visible de chaque photo en se basant sur le calque le plus petit
		;; et le rapport souhaité
		(set! dimPhoto (getDimensionLayer smallLayer rapportTarget))

		;; On resize la photo
		;;(if (> rapportTarget (/ (cadr dimPhoto) (car dimPhoto)))
		;;	(begin 
		;;		(gimp-layer-scale smallLayer (cadr dimPhoto) (car dimPhoto) FALSE)
		;;	)
		;;)

		;; Calcul de la résolution de l'image globale
		(set! resolution (getResolution nbPhoto largeur margeWidth 0 dimPhoto))

		;; Calcul des marges en pixel
		(set! margeHeigthInPixel (script-fu-compute-margin-in-pixel resolution margeHeigth))
		(set! margeWidthInPixel (script-fu-compute-margin-in-pixel resolution margeWidth))

		;; Calcul des dimensions de l'ensemble de l'image
		(set! dimImage (computeDimImage (cadr dimPhoto) (car dimPhoto) nbPhoto 0 margeWidthInPixel margeHeigthInPixel))
		
		;; On construit le calque
		(buildFrame image (car dimImage) (cadr dimImage) nbPhoto 0 margeWidthInPixel margeHeigthInPixel (cadr dimPhoto))

		;; On ajoute les ombres
		(addShadows image (car dimImage) (cadr dimImage) margeWidthInPixel margeHeigthInPixel (cadr dimPhoto) (car dimPhoto) nbPhoto)		

		;; On déplace et on resize les calques
		(resizeAndMoveLayers image all_layers rapportTarget dimPhoto margeHeigthInPixel margeWidthInPixel (cadr dimPhoto))

		;; Modification de la résolution
		(gimp-image-set-resolution image resolution resolution)
		
		(gimp-selection-none image)
		(gimp-displays-flush)
	
	)

	;; Termine la fonction "undo"
	(gimp-image-undo-group-end image)
)

(script-fu-register
	"script-fu-three-img"                   					;func name
    	"Aligne les images horizontalement"                            			;menu label
	"Positionne n images en portrait en respectant les dimensions fournies "	;description
    	"Julien Girard" 	                            				;author
    	""				        					;copyright notice
	"Août 01, 2015"                          					;date created
	"RGB*, GRAY*"                     						;image type that the script works on
	SF-IMAGE "image" 0								;param 0
	SF-VALUE "hauteur (cm)" "20.5"							;param 1
	SF-VALUE "largeur (cm)" "54"							;param 2
	SF-VALUE "Marge Hauteur (cm)" "1.5"						;param 3
	SF-VALUE "Marge Largeur (cm)" "1.5"						;param 4
)
 
 (script-fu-menu-register "script-fu-three-img" "<Image>/Filters/Script Perso")
