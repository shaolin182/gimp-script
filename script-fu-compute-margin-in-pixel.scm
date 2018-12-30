;; Calcule le nombre de pixel d'une marge
;;
;; res : Resolution de l'image
;; marge : taille de la marge en cm
(define (script-fu-compute-margin-in-pixel res marge)
	(let*
		( 
			(pouce 2.54)
			(margeInPixel (* (/ res pouce) marge))
		)
		(round margeInPixel)
	)
)

(script-fu-register
	"script-fu-compute-margin-in-pixel"                   				;func name
    	"Calcul des marges"	                                  			;menu label
	"Calcule la taille des marges en pixel"						;description
    	"Julien Girard" 	                            				;author
    	""				        					;copyright notice
	"August 25, 2015"                          					;date created
	"RGB*, GRAY*"                     						;image type that the script works on
	SF-VALUE "Resolution" ""							;param 1
	SF-VALUE "Marge (cm)" ""							;param 2
)
 
 (script-fu-menu-register "script-fu-compute-margin-in-pixel" "<Image>/Filters/Script Perso/Utils")
