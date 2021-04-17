"
Model used for radio buttons in example of basic controls (see ""UITheme exampleBasicControls"").
"
Class {
	#name : #RadioButtonModelExample,
	#superclass : #Model,
	#instVars : [
		'option'
	],
	#category : #'Morphic-Examples-Widgets'
}

{ #category : #accessing }
RadioButtonModelExample >> beCenter [
	"Set the option to #center."

	self option: #center
]

{ #category : #accessing }
RadioButtonModelExample >> beLeft [
	"Set the option to #left."

	self option: #left
]

{ #category : #accessing }
RadioButtonModelExample >> beRight [
	"Set the option to #right."

	self option: #right
]

{ #category : #initialization }
RadioButtonModelExample >> initialize [
	"Initialize the receiver."

	super initialize.
	self
		option: #left
]

{ #category : #accessing }
RadioButtonModelExample >> isCenter [
	"Answer whether the option if #center."

	^self option == #center
]

{ #category : #accessing }
RadioButtonModelExample >> isLeft [
	"Answer whether the option if #left."

	^self option == #left
]

{ #category : #accessing }
RadioButtonModelExample >> isRight [
	"Answer whether the option if #right."

	^self option == #right
]

{ #category : #accessing }
RadioButtonModelExample >> option [
	"Answer the value of option"

	^ option
]

{ #category : #accessing }
RadioButtonModelExample >> option: aSymbol [
	"Set the value of option"

	option := aSymbol.
	self
		changed: #isLeft;
		changed: #isCenter;
		changed: #isRight
]
