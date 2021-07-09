"
Dialog window displaying a message with a single OK button. Escape/return will close. Icon is a themed information icon.
"
Class {
	#name : #MessageDialogWindow,
	#superclass : #DialogWindowMorph,
	#instVars : [
		'textMorph',
		'textFont',
		'iconMorph'
	],
	#category : #'Polymorph-Widgets-Windows'
}

{ #category : #icons }
MessageDialogWindow class >> taskbarIconName [
	"Answer the icon for the receiver in a task bar."

	^#smallInfoIcon
]

{ #category : #initialization }
MessageDialogWindow >> defaultTextFont [
	^self theme textFont
]

{ #category : #'visual properties' }
MessageDialogWindow >> icon [
	"Answer an icon for the receiver."

	^ self iconNamed: #infoIcon
]

{ #category : #accessing }
MessageDialogWindow >> iconMorph [

	^ iconMorph ifNil: [ iconMorph := self newIconMorph ]
]

{ #category : #accessing }
MessageDialogWindow >> iconMorph: anObject [
	"Set the value of iconMorph"

	iconMorph := anObject
]

{ #category : #'open/close' }
MessageDialogWindow >> initialExtent [
	"Answer the initial extent for the receiver.
	Adjust the text if the text	would be wider than 1/4 the display width."
	
	|ext|
	ext := super initialExtent.
	self textMorph width > (Display width - 50) ifTrue: [
		self textMorph
			wrapFlag: true;
			hResizing: #rigid;
			extent: (Display width - 50) @ 0.
		ext := super initialExtent].
	^ext
]

{ #category : #initialization }
MessageDialogWindow >> initialize [
	super initialize.
	textFont:= self defaultTextFont
]

{ #category : #private }
MessageDialogWindow >> lineLengths [

	^ self textLines collect: [ :line | self textFont widthOfString: line ].
]

{ #category : #accessing }
MessageDialogWindow >> minimumWidth [
	
	^ (self lineLengths max + 100) min: Display width.
]

{ #category : #actions }
MessageDialogWindow >> newButtons [
	"Answer new buttons as appropriate."

	^{self newOKButton isDefault: true}
]

{ #category : #actions }
MessageDialogWindow >> newContentMorph [
	"Answer a new content morph."

	self iconMorph: self newIconMorph.
	self textMorph: self newTextMorph.
	^self newGroupboxFor: (self newRow: {self iconMorph. self textMorph})
]

{ #category : #private }
MessageDialogWindow >> newIconMorph [
	"Answer an icon for the receiver."
	
	^ImageMorph new form: self icon
]

{ #category : #private }
MessageDialogWindow >> newTextMorph [
	"Answer a text morph."
	^self newText: ' '
]

{ #category : #theme }
MessageDialogWindow >> playOpenSound [
	"Play the themed sound for opening.
	Do nothing at present, done by the UIManager."
]

{ #category : #accessing }
MessageDialogWindow >> text: aStringOrText [
	"Set the text."
	
	|t|
	t := aStringOrText isString
		ifTrue: [aStringOrText asText addAttribute: (TextFontReference toFont: self textFont); yourself]
		ifFalse: [aStringOrText].
	t
		addAttribute: TextAlignment centered;
		addAttribute: (TextColor color: self textMorph textColor).
	self textMorph newContents: t

]

{ #category : #accessing }
MessageDialogWindow >> textFont [
	"Answer the text font."
	
	^textFont
]

{ #category : #accessing }
MessageDialogWindow >> textFont: aFont [
	"Set the text font."
	
	textFont :=  aFont.
	self textMorph ifNotNil: [:m | m font: aFont]
]

{ #category : #private }
MessageDialogWindow >> textLines [

	^ self textMorph text asString lines.
]

{ #category : #accessing }
MessageDialogWindow >> textMorph [
	"Answer the value of textMorph"

	^ textMorph
]

{ #category : #accessing }
MessageDialogWindow >> textMorph: anObject [
	"Set the value of textMorph"

	textMorph := anObject
]

{ #category : #theme }
MessageDialogWindow >> themeChanged [
	"Update the icon."

	super themeChanged.
	self iconMorph image: self icon

]
