"
I am the state of a tab enabled but not yet selected
"
Class {
	#name : #TabEnabledState,
	#superclass : #TabState,
	#category : #'Morphic-Widgets-Tabs-States'
}

{ #category : #protocol }
TabEnabledState >> backgroundColor [
	^ Smalltalk ui theme darkBaseColor 
]

{ #category : #protocol }
TabEnabledState >> enabled [

	^ true
]

{ #category : #protocol }
TabEnabledState >> isEnabledMatchingTheState: aBoolean [

	^ aBoolean
]

{ #category : #protocol }
TabEnabledState >> isSelectedMatchingTheState: aBoolean [

	^ aBoolean not
]

{ #category : #protocol }
TabEnabledState >> newStateForEnabled: aBoolean [
	"aBoolean here must be false"
	self deny: aBoolean.
	
	^ TabDisabledState tab: self tab
]

{ #category : #protocol }
TabEnabledState >> newStateForSelected: aBoolean [
	self assert: aBoolean.
	
	^ TabSelectedState tab: self tab
]
