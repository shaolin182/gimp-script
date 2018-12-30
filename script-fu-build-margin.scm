;; Construit une marge
;;
;; x : Position horizontale où démarre la marge
;; y : Position verticale où démarre la marge
;; width : largeur de la marge en pixel
;; heigth : hauteur de la marge en pixel
(define (script-fu-build-margin image layer x y width heigth)
	
	(gimp-context-set-foreground '(242 242 242))
	(gimp-image-select-rectangle image CHANNEL-OP-REPLACE x y width heigth)  
	(gimp-edit-fill layer FOREGROUND-FILL)
)

(script-fu-register
	"script-fu-build-margin"        	           				;func name
    	"Dessine une marge"	     	                             			;menu label
	"Dessine une marge blanche en fct des paramètres"				;description
    	"Julien Girard" 	                            				;author
    	""				        					;copyright notice
	"August 25, 2015"                          					;date created
	"RGB*, GRAY*"                     						;image type that the script works on
	SF-IMAGE "image" 0								;param 0	
	SF-DRAWABLE "drawable" 0							;param 1
	SF-VALUE "Poistion sur axe horizontale" ""					;param 2
	SF-VALUE "Poistion sur axe verticale" ""					;param 2
	SF-VALUE "Largeur en pixel" ""							;param 2
	SF-VALUE "Hauteur en pixel" ""							;param 2
)
 
 (script-fu-menu-register "script-fu-build-margin" "<Image>/Filters/Script Perso/Utils")
