;; Ajoute un calque transparent à la photo
;;
;; image : current Image
;; width : largeur du calque
;; height : hauteur du calque
(define (script-fu-add-transparent-layer image width height layerName)

	(let* 
		(
			(newLayer 0)
		)

		;; Création d'un nouveau calque représentant la région à l'intérieur du calque pour ensuite ajouter une ombre
		(set! newLayer (car (gimp-layer-new image width height RGB-IMAGE layerName 100 LAYER-MODE-NORMAL-LEGACY)))
		(gimp-layer-add-alpha newLayer)
		(gimp-drawable-fill newLayer TRANSPARENT-FILL)		
		(gimp-image-add-layer image newLayer 0)

		;; retourne le nouveau layer
		newLayer
	)
)

(script-fu-register
	"script-fu-add-transparent-layer"                   				;func name
    	"Add Transparent Layer"	                                  			;menu label
	"Ajoute un calque transparent"							;description
    	"Julien Girard" 	                            				;author
    	""				        					;copyright notice
	"August 25, 2015"                          					;date created
	"RGB*, GRAY*"                     						;image type that the script works on
	SF-IMAGE "image" 0								;param 0
	SF-VALUE "Largeur (px)" ""							;param 1
	SF-VALUE "Hauteur (px)" ""							;param 2
	SF-VALUE "Nom du calque" ""							;param 3
)
 
 (script-fu-menu-register "script-fu-add-transparent-layer" "<Image>/Filters/Script Perso/Utils")
