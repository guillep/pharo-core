Extension { #name : #Metaclass }

{ #category : #'*TraitsV2' }
Metaclass >> baseLocalMethods [
	^ self instanceSide methodDict
]

{ #category : #'*TraitsV2' }
Metaclass >> initializeBasicMethods [ 
	
	"Nothing to do in the metaclass"
]

{ #category : #'*TraitsV2' }
Metaclass >> setTraitComposition: aTraitCompositionOrArray [
	
	^ self trait: aTraitCompositionOrArray slots: self slots.
]

{ #category : #'*TraitsV2' }
Metaclass >> trait: aTraitCompositionOrArray [
	
	^ self trait: aTraitCompositionOrArray slots: #().
]

{ #category : #'*TraitsV2' }
Metaclass >> trait: aTraitCompositionOrArray instanceVariableNames: instVarString [ 
	
	^ self trait: aTraitCompositionOrArray slots: instVarString asSlotCollection
]

{ #category : #'*TraitsV2' }
Metaclass >> trait: aTraitCompositionOrArray slots: slotArray [
	| theClass |
	theClass := self instanceSide.
	
	theClass := theClass classInstaller
		update: theClass
		to: [ :builder | 
			builder
				fillFor: theClass;
				classTraitComposition: aTraitCompositionOrArray asTraitComposition;				
				classSlots: slotArray ].
	^ theClass classSide
]

{ #category : #'*TraitsV2' }
Metaclass >> uses: aTraitCompositionOrArray [
	"This method will be deprecated better use trait."
	
	self trait: aTraitCompositionOrArray slots: #().
]

{ #category : #'*TraitsV2' }
Metaclass >> uses: aTraitCompositionOrArray instanceVariableNames: instVarString [ 
	"This method will be deprecated better use trait:slots: or trait:instanceVariableNames:"
	^ self uses: aTraitCompositionOrArray slots: instVarString asSlotCollection
]

{ #category : #'*TraitsV2' }
Metaclass >> uses: aTraitCompositionOrArray slots: slotArray [
	| theClass |
	theClass := self instanceSide.
	
	theClass := theClass classInstaller
		update: theClass
		to: [ :builder | 
			builder
				fillFor: theClass;
				classTraitComposition: aTraitCompositionOrArray asTraitComposition;				
				classSlots: slotArray ].
	^ theClass classSide
]
