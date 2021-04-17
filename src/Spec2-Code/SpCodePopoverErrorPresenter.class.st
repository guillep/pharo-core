"
I show a compiler error as a popover (instead inserting an error string, which pollutes the text)
"
Class {
	#name : #SpCodePopoverErrorPresenter,
	#superclass : #SpPopoverContentPresenter,
	#instVars : [
		'object',
		'code',
		'text',
		'message'
	],
	#category : #'Spec2-Code'
}

{ #category : #'instance creation' }
SpCodePopoverErrorPresenter class >> newCode: aPresenter message: aString [

	^ (self on: aString)
		code: aPresenter;
		yourself
]

{ #category : #accessing }
SpCodePopoverErrorPresenter >> code [

	^ code
]

{ #category : #accessing }
SpCodePopoverErrorPresenter >> code: aPresenter [

	code := aPresenter
]

{ #category : #'api-focus' }
SpCodePopoverErrorPresenter >> defaultKeyboardFocus [

	^ text
]

{ #category : #api }
SpCodePopoverErrorPresenter >> dismiss [

	super dismiss.
	self code takeKeyboardFocus
]

{ #category : #initialization }
SpCodePopoverErrorPresenter >> initializePresenters [

	self initializeText.

	layout := SpBoxLayout newTopToBottom
		add: text expand: false;
		yourself.

	self flag: #TODO. "This is uber bad. Keybindings needs to come from application configuration"
	text
		bindKeyCombination: 
			Character escape asKeyCombination 
			| Character backspace asKeyCombination 
			| Character cr asKeyCombination
			toAction: [ self dismiss ]
]

{ #category : #initialization }
SpCodePopoverErrorPresenter >> initializeText [

	text := self newText
		beNotWrapWord;
		propagateNaturalWidth: true;
		propagateNaturalHeight: false;
		editable: false;
		text: self message;
		"addStyle: 'codePopover';"
		addStyle: 'codePopoverError';
		yourself
]

{ #category : #accessing }
SpCodePopoverErrorPresenter >> message [

	^ message
]

{ #category : #accessing }
SpCodePopoverErrorPresenter >> message: aString [

	message := aString
]

{ #category : #'accessing model' }
SpCodePopoverErrorPresenter >> setModelBeforeInitialization: aString [

	message := aString
]
