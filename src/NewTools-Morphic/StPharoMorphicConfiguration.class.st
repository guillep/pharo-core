Class {
	#name : #StPharoMorphicConfiguration,
	#superclass : #SpApplicationConfiguration,
	#category : #'NewTools-Morphic'
}

{ #category : #defaults }
StPharoMorphicConfiguration class >> defaultStyleSheet [

	^ SpStyle defaultStyleSheet
]

{ #category : #configuring }
StPharoMorphicConfiguration >> configure: anApplication [

	super configure: anApplication
]

{ #category : #configuring }
StPharoMorphicConfiguration >> configureOSX: anApplication [
	
	anApplication styleSheet: (self styleSheet, self styleSheetOSX)
	
]

{ #category : #configuring }
StPharoMorphicConfiguration >> configureUnix: anApplication [
	
	anApplication styleSheet: self styleSheet
]

{ #category : #configuring }
StPharoMorphicConfiguration >> configureWindows: anApplication [
	
	anApplication styleSheet: self styleSheet
]

{ #category : #private }
StPharoMorphicConfiguration >> styleSheet [

	^ StPharoStyleContributor availableContributors 
		inject: SpStyle defaultStyleSheet 
		into: [ :accum :each | accum, (each styleSheetContribution) ]
]

{ #category : #private }
StPharoMorphicConfiguration >> styleSheetOSX [
	"Just an example on how to build styles programatically ;)"

	^ SpStyle newApplication 
		addClass: 'label' with: [ :label |
			label addClass: 'shortcut' with: [ :shortcut |
				shortcut addPropertyFontWith: [ :font |
					font name: 'Lucida Grande'; size: 10 ] ] ];
		yourself
]
