Extension { #name : #CompiledMethod }

{ #category : #'*DrTests' }
CompiledMethod >> asResultForDrTest [

	^ DTTestLeafNode content: self
]

{ #category : #'*DrTests' }
CompiledMethod >> drTestsBrowse [

	Smalltalk tools browser openOnClass: self methodClass selector: self selector
]
