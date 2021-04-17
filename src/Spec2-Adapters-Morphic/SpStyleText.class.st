"
Text property controls how the ""input text"" fields (*SpTextInputFieldPresenter* hierarchy for now)
"
Class {
	#name : #SpStyleText,
	#superclass : #SpStyleProperty,
	#instVars : [
		'drawKeyboardFocus'
	],
	#category : #'Spec2-Adapters-Morphic-StyleSheet'
}

{ #category : #operations }
SpStyleText >> applyTo: aMorph [


	self drawKeyboardFocusVariable
		ifNotNil: [ :aVariable | aMorph drawKeyboardFocus: aVariable value ]
]

{ #category : #accessing }
SpStyleText >> drawKeyboardFocus [

	^ self drawKeyboardFocusVariable value
]

{ #category : #accessing }
SpStyleText >> drawKeyboardFocus: aBoolean [

	drawKeyboardFocus := aBoolean asStyleVariable
]

{ #category : #'accessing variables' }
SpStyleText >> drawKeyboardFocusVariable [

	^ self toVariable: drawKeyboardFocus
]
