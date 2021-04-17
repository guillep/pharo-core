"
I show the result of a printing as part of a popover 
"
Class {
	#name : #SpCodePopoverPrintPresenter,
	#superclass : #SpPopoverContentPresenter,
	#instVars : [
		'object',
		'code',
		'text'
	],
	#category : #'Spec2-Code'
}

{ #category : #accessing }
SpCodePopoverPrintPresenter class >> linesToShow [

	^ 15
]

{ #category : #accessing }
SpCodePopoverPrintPresenter class >> maxLengthShownInPopover [

	^ 80
]

{ #category : #'instance creation' }
SpCodePopoverPrintPresenter class >> newCode: aCodePresenter object: anObject [ 

	^ (self on: anObject)
		code: aCodePresenter;
		yourself 
]

{ #category : #private }
SpCodePopoverPrintPresenter >> basicObjectAsString [
	
	^ [ object printString ]
		on: Error
		do: [ '<error in printString: try ''Inspect it'' to debug>' ]
]

{ #category : #accessing }
SpCodePopoverPrintPresenter >> code [

	^ code
]

{ #category : #accessing }
SpCodePopoverPrintPresenter >> code: aCodePresenter [

	code := aCodePresenter
]

{ #category : #'api-focus' }
SpCodePopoverPrintPresenter >> defaultKeyboardFocus [

	^ text
]

{ #category : #api }
SpCodePopoverPrintPresenter >> dismiss [

	super dismiss.
	self code takeKeyboardFocus
]

{ #category : #actions }
SpCodePopoverPrintPresenter >> dismissAndInspect [

	self dismiss.
	object inspect.
	"(SpCodeInspectItCommand forContext: context) execute"
]

{ #category : #actions }
SpCodePopoverPrintPresenter >> dismissAndPrint [

	self dismiss.
	self code insertAndSelectAfterCurrentSelection: self objectAsPrintString
]

{ #category : #initialization }
SpCodePopoverPrintPresenter >> initializePresenters [

	self initializeText.

	self layout: (SpBoxLayout newTopToBottom
		add: text expand: false;
		yourself).

	self flag: #TODO. "This is uber bad. Keybindings needs to come from application configuration"
	text
		bindKeyCombination: Character cr asKeyCombination | $p meta 
			toAction: [ self dismissAndPrint ];
		bindKeyCombination: $i meta 
			toAction: [ self dismissAndInspect ];
		bindKeyCombination: Character escape asKeyCombination | Character backspace asKeyCombination | $l meta
			toAction: [ self dismiss ]
]

{ #category : #initialization }
SpCodePopoverPrintPresenter >> initializeText [
	| string numLines |

	string := self objectAsString.
	numLines := string lines size.	
	text := self 
		newTextMultiLine: string 
		withScrollBars: numLines >= self class linesToShow.
		
	text 
		"addStyle: 'code';"
		addStyle: 'codePopover'
]

{ #category : #initialization }
SpCodePopoverPrintPresenter >> newTextMultiLine: aString withScrollBars: withScrollBars [
	| newText |		

	newText := self newText
		beNotWrapWord;
		propagateNaturalWidth: true;
		propagateNaturalHeight: withScrollBars not;
		editable: false;
		text: aString;
		yourself.

	"this is needed just for the gtk backend"
	withScrollBars ifTrue: [ 
		newText addScrollBarStyle: 'scrollbarPopoverLarge' ].
	
	^ newText
]

{ #category : #accessing }
SpCodePopoverPrintPresenter >> objectAsPrintString [
	
	^ String streamContents: [ :stream |
		stream 
			<< ' "'
			<< self basicObjectAsString
			<< '"' ]
]

{ #category : #accessing }
SpCodePopoverPrintPresenter >> objectAsString [
	| string |
	
	string := self basicObjectAsString.
	string size <= self class maxLengthShownInPopover 
		ifTrue: [ ^ string ].
	
	(string includesAny: Character separators) 
		ifTrue: [ ^ string withNoLineLongerThan: self class maxLengthShownInPopover ].
	
	^ String streamContents: [ :stream | 
			(string groupsOf: self class maxLengthShownInPopover)
				do: [ :each | stream << each ]
				separatedBy: [ stream cr ] ]
]

{ #category : #'accessing model' }
SpCodePopoverPrintPresenter >> setModelBeforeInitialization: anObject [

	object := anObject
]
