;; Add a new transparent layer to the image
;;
;; image : current Image
;; width : layer width
;; height : layer height
(define (script-fu-add-transparent-layer image width height layerName)

	(let* 
		(
			(newLayer 0)
		)

		;; Create new layer
		(set! newLayer (car (gimp-layer-new image width height RGB-IMAGE layerName 100 LAYER-MODE-NORMAL-LEGACY)))
		(gimp-layer-add-alpha newLayer)
		(gimp-drawable-fill newLayer TRANSPARENT-FILL)		
		(gimp-image-add-layer image newLayer 0)

		;; return new layer
		newLayer
	)
)

(script-fu-register
	"script-fu-add-transparent-layer"	;func name
    "Add Transparent Layer"	            ;menu label
	"Ajoute un calque transparent"		;description
    "Julien Girard" 	                ;author
    ""				        			;copyright notice
	"August 25, 2015"                   ;Creation date
	"RGB*, GRAY*"                     	;image type that the script works on
	SF-IMAGE "image" 0					;param - Current Image
	SF-VALUE "Largeur (px)" ""			;param - Width
	SF-VALUE "Hauteur (px)" ""			;param - Height
	SF-VALUE "Nom du calque" ""			;param - Layer name, ex : "layer_name" (Quotes are mandatory)
)
 
 (script-fu-menu-register "script-fu-add-transparent-layer" "<Image>/Filters/Script Perso/Utils")
