Class {
	#name : #GLMHighlighterTextStylerDecorator,
	#superclass : #RubParagraphDecorator,
	#instVars : [
		'text',
		'styler'
	],
	#category : #'Glamour-Rubric-Presentations'
}

{ #category : #querying }
GLMHighlighterTextStylerDecorator class >> key [

	^ nil
]

{ #category : #accessing }
GLMHighlighterTextStylerDecorator >> defaultStyler [
	"There is no default styler"
	^ nil
]

{ #category : #accessing }
GLMHighlighterTextStylerDecorator >> okToStyle [
	^ true
]

{ #category : #editing }
GLMHighlighterTextStylerDecorator >> replaceFrom: start to: stop with: aText [
	self okToStyle
		ifFalse: [ ^ next replaceFrom: start to: stop with: aText ].
	self
		disableDrawingWhile: [
			aText addAttribute: self defaultFontChange.
			text ifNil: [ text := self text ].
			text replaceFrom: start to: stop with: (self styler format: aText).
			self style: text.
			next text: text.
			self recomposeFrom: start to: start + aText size - 1 delta: aText size - (stop - start + 1).
			self textArea paragraphWasComposedFrom: start to: start + aText size - 1.
			self textArea paragraphReplacedTextFrom: start to: stop with: aText ]
]

{ #category : #editing }
GLMHighlighterTextStylerDecorator >> style: aText [
	self styler ifNotNil: [ :aStyler | aStyler styleInBackgroundProcess: aText ]
]

{ #category : #accessing }
GLMHighlighterTextStylerDecorator >> styler [
	"The styler responsible for highlighting text in the receiver"
	^ styler ifNil: [ styler := self defaultStyler ]
]

{ #category : #accessing }
GLMHighlighterTextStylerDecorator >> styler: aStylerObject [
	
	styler := aStylerObject.
	styler view: self
]

{ #category : #editing }
GLMHighlighterTextStylerDecorator >> stylerStyled: styledCopyOfText [
	next ifNil: [ ^self ].
	text runs: styledCopyOfText runs.
	(self textArea scrollPane ifNil: [ self textArea ]) changed
]

{ #category : #editing }
GLMHighlighterTextStylerDecorator >> stylerStyledInBackground: styledCopyOfText [
	next ifNil: [ ^self ].
	text string = styledCopyOfText string
		ifTrue: [ self stylerStyled: styledCopyOfText ].

]

{ #category : #accessing }
GLMHighlighterTextStylerDecorator >> text [
	^ next text
]
