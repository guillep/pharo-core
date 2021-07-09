"
Support for GeneralScrollPane.
"
Class {
	#name : #GeneralScrollBarMorph,
	#superclass : #ScrollBarMorph,
	#instVars : [
		'showState'
	],
	#category : #'Morphic-Widgets-Scrolling'
}

{ #category : #initialization }
GeneralScrollBarMorph >> initialize [
	"Initialize the receiver."

	super initialize.
	self showWhenNeeded
]

{ #category : #'model access' }
GeneralScrollBarMorph >> setValue: newValue [
	"Bypass screwed up scrollbar!"
	
	^self perform: #setValue: withArguments: {newValue} inSuperclass: SliderMorph
]

{ #category : #accessing }
GeneralScrollBarMorph >> showAlways [
	"Set the scrollbar to be always shown."

	self showState: #always
]

{ #category : #accessing }
GeneralScrollBarMorph >> showNever [
	"Set the scrollbar to be never shown."

	self showState: #never
]

{ #category : #accessing }
GeneralScrollBarMorph >> showState [

	^ showState
]

{ #category : #accessing }
GeneralScrollBarMorph >> showState: anObject [

	showState := anObject
]

{ #category : #accessing }
GeneralScrollBarMorph >> showWhenNeeded [
	"Set the scrollbar to be shown if needed."

	self showState: #whenNeeded
]

{ #category : #accessing }
GeneralScrollBarMorph >> showsAlways [
	"Answer whether the scrollbar should always be shown."

	^self showState == #always
]

{ #category : #accessing }
GeneralScrollBarMorph >> showsNever [
	"Answer whether the scrollbar should never be shown."

	^self showState == #never
]

{ #category : #accessing }
GeneralScrollBarMorph >> showsWhenNeeded [
	"Answer whether the scrollbar should be shown if needed."

	^self showState == #whenNeeded
]
