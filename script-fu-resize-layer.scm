;; Redimensionne un calque en fonction de dimension passée en paramètre
;;
;; layer : calque à redimensionner
;; minimumWidth : largeur minimum de la photo
;; minimumHeigth : hauteur minimum de la photo
(define (script-fu-resize-layer layer minimumWidth minimumHeigth) 

	(let* 
		(
			(rapportCurrentPhoto 0)
			(width (car (gimp-drawable-width layer)))
			(heigth (car (gimp-drawable-height layer)))
		)

		;; Récupération de la largeur et hauteur de la photo en pixel en fonction du rapport attendu
		(set! rapportCurrentPhoto (/ width heigth))

		(if (< rapportCurrentPhoto 1)
			(begin 
				;; largeur < hauteur
				(set! width minimumWidth)
				(set! heigth (/ width rapportCurrentPhoto))
			)
			(begin 
				;; hauteur < largeur
				(set! heigth minimumHeigth)
				(set! width (* heigth rapportCurrentPhoto))	
			)
		)

		;; On resize la photo
		(gimp-layer-scale layer width heigth FALSE)
	)
)

(script-fu-register
	"script-fu-resize-layer" 	                  				;func name
    	"Redimensionne un calque"                                  			;menu label
	"Redimensionne un calque en fonction d'une taille minimum et en respectant le rapport de la photo"							;description
    	"Julien Girard" 	                            				;author
    	""				        					;copyright notice
	"August 25, 2015"                          					;date created
	"RGB*, GRAY*"                     						;image type that the script works on
	SF-DRAWABLE "calque" 0								;param 0
	SF-VALUE "Largeur minimum (px)" ""						;param 1
	SF-VALUE "Hauteur minimum(px)" ""						;param 2
)
 
 (script-fu-menu-register "script-fu-resize-layer" "<Image>/Filters/Script Perso/Utils")
