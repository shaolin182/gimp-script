;; Transforme le calque sélectionné pour être inclus dans un format de carte postale
;; Le calque respecte la résolution de l'image et est redimensionné au besoin pour correspondre au format carte postale
(define (script-fu-carte-postale image drawable bordure)
	
	;; début du script. Permet de ne faire qu'une seule fois "Undo" pour toutes les manips
	(gimp-image-undo-group-start image)

	(script-fu-cadre image drawable 3.71 5.94 bordure)

	;; Termine la fonction "undo"
	(gimp-image-undo-group-end image)
)

(script-fu-register
	"script-fu-carte-postale"                   						;func name
    	"Carte Postale"	                                  				;menu label
	"Inclue le calque dans un format de carte psotale"					;description
    	"Julien Girard" 	                            				;author
    	""				        					;copyright notice
	"August 25, 2015"                          					;date created
	"RGB*, GRAY*"                     						;image type that the script works on
	SF-IMAGE "image" 0								;param 0
	SF-DRAWABLE "drawable" 0
	SF-VALUE "bordure (inch)" "0.1"							;param 1

)
 
 (script-fu-menu-register "script-fu-carte-postale" "<Image>/Filters/Script Perso")
