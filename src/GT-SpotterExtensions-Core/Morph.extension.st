Extension { #name : #Morph }

{ #category : #'*GT-SpotterExtensions-Core' }
Morph >> spotterPreviewMorphIn: aComposite [
	<spotterPreview: 20>
	aComposite custom: 
		(self imageForm asAlphaImageMorph asBrick margin: 20)
]
