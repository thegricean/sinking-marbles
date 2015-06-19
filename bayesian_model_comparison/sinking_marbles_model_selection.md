---
layout: model
title: Sinking marbles model selection
---

# Wonky vs regular RSA

~~~


(define model-comparison
	(lambda (experiment-data)
		(enumeration-query
			(define is-model-wonky? (flip 0.5))
			
			; generate predictions for all items (RRSA)
			(define model-regular
				(map
					(lambda (item-prior ...) 
						(regular-rsa item-prior ...))
						all-items
					)
				)

			; generate predictions for all items (WRSA)
			(define model-wonky
				(map
					(lambda (item-prior ...) 
						(wonky-rsa item-prior wonky-prior ...))
						all-items
					)
				)
				
			(define best-model (if is-model-wonky?
				model-wonky
				model-regular))
					
			is-model-wonky?
			
			...
			)
		)
	)


~~~