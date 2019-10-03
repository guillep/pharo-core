Class {
	#name : #Comparisons,
	#superclass : #Object,
	#category : #'Equals-Examples'
}

{ #category : #displaying }
Comparisons class >> display: aBoolean [
	| displayColor displayLabel |
	displayLabel := aBoolean ifTrue: [ 'Equal' ] ifFalse: [ 'Different' ].
	displayColor := aBoolean ifTrue: [ Color green ] ifFalse: [ Color yellow ].
	GrowlMorph 
		openWithLabel: displayLabel
		contents: ''
		backgroundColor: displayColor
		labelColor: Color black
]
