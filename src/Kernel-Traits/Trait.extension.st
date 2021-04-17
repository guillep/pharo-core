Extension { #name : #Trait }

{ #category : #'*Kernel-Traits' }
Trait >> hasEmptyComposition [
	
	^ self traitComposition isEmpty or: [ self traitComposition = TEmpty asTraitComposition ]
]
