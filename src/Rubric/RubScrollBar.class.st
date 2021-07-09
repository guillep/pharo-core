"
I am a scroll bar
"
Class {
	#name : #RubScrollBar,
	#superclass : #GeneralScrollBarMorph,
	#category : #'Rubric-Editing-Widgets'
}

{ #category : #style }
RubScrollBar >> mouseOverThumbButtonFillStyle [
	"Return the mouse over thumb fillStyle for the receiver."
	
	^(self theme scrollbarMouseOverThumbButtonFillStyleFor: self) asColor darker
]

{ #category : #style }
RubScrollBar >> normalThumbFillStyle [
	"Return the normal thumb fillStyle for the receiver."
	
	^(self theme scrollbarNormalThumbFillStyleFor: self) asColor darker
]

{ #category : #style }
RubScrollBar >> pressedThumbFillStyle [
	"Return the pressed thumb fillStyle for the receiver."
	
	^(self theme scrollbarPressedThumbFillStyleFor: self) asColor darker
]
