"
I'm a side button to be used with a text field to open an entry completion list 
"
Class {
	#name : #RubDropListButtonRuler,
	#superclass : #RubScrolledTextSideRuler,
	#instVars : [
		'downArrowBtn'
	],
	#category : #'Rubric-Editing-Widgets'
}

{ #category : #querying }
RubDropListButtonRuler class >> key [
	^ #dropListButton
]

{ #category : #geometry }
RubDropListButtonRuler >> computedWidthFrom: aRectangle [
	^ downArrowBtn width
]

{ #category : #initialization }
RubDropListButtonRuler >> initialize [ 
	super initialize.
	side := #right

]

{ #category : #accessing }
RubDropListButtonRuler >> level [
	^ 1
]

{ #category : #'submorphs-accessing' }
RubDropListButtonRuler >> noteNewOwner: aMorph [
	| downArrow |
	super noteNewOwner: aMorph.
	downArrow := (self theme 
		basicCreateArrowOfDirection: #bottom 
		size: (self textArea textStyle defaultFont height)
		color: Color veryLightGray).
	downArrowBtn := IconicButtonMorph new labelGraphic: downArrow.
	downArrowBtn height: self paragraphProvider innerBounds height.
	downArrowBtn borderWidth: 0.
	downArrowBtn color: Color transparent.
	downArrowBtn actionSelector:  #openChooserWithAllOrCloseFrom:.
	downArrowBtn target: self paragraphProvider entryCompletion.
	downArrowBtn arguments: (Array with: self paragraphProvider).
	self addMorph: downArrowBtn
]
