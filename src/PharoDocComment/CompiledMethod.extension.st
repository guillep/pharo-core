Extension { #name : #CompiledMethod }

{ #category : #'*PharoDocComment' }
CompiledMethod >> hasDocComment [
	^ self pharoDocCommentNodes notEmpty
]

{ #category : #'*PharoDocComment' }
CompiledMethod >> pharoDocCommentNodes [
	"we try to avoid to have to create the AST if we are sure that we do not need it"
	^ (self sourceCode includesSubstring: '>>>')
		  ifTrue: [ self ast pharoDocCommentNodes ]
		  ifFalse: [ ^ #(  ) ]
]
