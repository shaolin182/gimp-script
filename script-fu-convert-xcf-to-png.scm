(define (convert-xcf-to-png inFile outFile) 
	(gimp-message "Entering the Script")
	(gimp-message inFile)
	(gimp-message outFile)
	
	(let* 
		(
			(image (car (gimp-file-load RUN-NONINTERACTIVE inFile inFile)))
			(drawable (car (gimp-image-merge-visible-layers image CLIP-TO-IMAGE)))
		)
	
		(file-png-save-defaults RUN-NONINTERACTIVE image drawable outFile outFile)
		
	)
	
	(gimp-quit 0)
)
