"
Similar to class `FluidClassBuilder` but for traits
"
Class {
	#name : #FluidTraitBuilder,
	#superclass : #Object,
	#instVars : [
		'packageName',
		'slots',
		'name',
		'uses',
		'tagToBuild',
		'shiftClassBuilder'
	],
	#category : #'FluidClassBuilder-Base'
}

{ #category : #building }
FluidTraitBuilder >> build [

	^ shiftClassBuilder build 


]

{ #category : #accessing }
FluidTraitBuilder >> fillShiftClassBuilder [

	shiftClassBuilder := ShiftClassBuilder new.
	shiftClassBuilder buildEnvironment: ShSmalltalkGlobalsEnvironment new. 
	shiftClassBuilder 
		name: name;
		beTrait;
		sharedVariables: '';
		sharedPools: ''.
		
	slots ifNotNil: [ shiftClassBuilder slots: slots ].	
	uses ifNotNil: [ 
		shiftClassBuilder traitComposition: uses asTraitComposition.
		shiftClassBuilder classTraitComposition: uses asTraitComposition classComposition ].
	shiftClassBuilder classSlots: #().
	(tagToBuild isNil or: [ tagToBuild isEmpty ])
		ifTrue: [ shiftClassBuilder category: packageName ]
		ifFalse: [ tagToBuild isEmpty 
						ifFalse: [ shiftClassBuilder category: packageName, '-', tagToBuild asString ]
						ifTrue: [ shiftClassBuilder category: packageName ]
		].
]

{ #category : #building }
FluidTraitBuilder >> install [

	"Install the trait in the system environment"

	^ ShiftClassInstaller new makeWithBuilder: shiftClassBuilder
]

{ #category : #accessing }
FluidTraitBuilder >> instanceVariables: anArray [
	"Pay attention this is not part of the fluid interface -- this method should not probably removed."
	
	slots := anArray
]

{ #category : #API }
FluidTraitBuilder >> name: aString [

	name := aString
]

{ #category : #API }
FluidTraitBuilder >> package: aString [

	packageName := aString.
	self fillShiftClassBuilder
]

{ #category : #building }
FluidTraitBuilder >> shiftClassBuilder [ 

	^ shiftClassBuilder 
]

{ #category : #API }
FluidTraitBuilder >> slots: anArray [

	slots := anArray
]

{ #category : #accessing }
FluidTraitBuilder >> tag [

	^ tagToBuild
]

{ #category : #API }
FluidTraitBuilder >> tag: anObject [

	tagToBuild := anObject
]

{ #category : #API }
FluidTraitBuilder >> trait: anArray [
	"To replace the uses: which will be deprecated"
	uses := anArray
]

{ #category : #deprecated }
FluidTraitBuilder >> uses: anArray [

	uses := anArray
]
