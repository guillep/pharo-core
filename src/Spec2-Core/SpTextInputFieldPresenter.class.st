"
A presenter to handle a single line of text.

"
Class {
	#name : #SpTextInputFieldPresenter,
	#superclass : #SpAbstractTextPresenter,
	#instVars : [
		'#entryCompletion => SpObservableSlot',
		'#isPassword => SpObservableSlot',
		'#editable => SpObservableSlot',
		'#maxLength => SpObservableSlot'
	],
	#category : #'Spec2-Core-Widgets'
}

{ #category : #specs }
SpTextInputFieldPresenter class >> adapterName [

	^ #TextInputFieldAdapter
]

{ #category : #api }
SpTextInputFieldPresenter >> beEditable [
	"Allow edition (deny readonly)."

	self editable: true
]

{ #category : #api }
SpTextInputFieldPresenter >> beNotEditable [
	"Set content text as not editable (readonly)"

	self editable: false
]

{ #category : #api }
SpTextInputFieldPresenter >> bePassword [
	"Set this input text as a password editor."
	
	self bePassword: true
]

{ #category : #private }
SpTextInputFieldPresenter >> bePassword: aBoolean [
	
	isPassword := aBoolean
]

{ #category : #api }
SpTextInputFieldPresenter >> beText [
	"Set this input text as a text editor."

	self bePassword: false
]

{ #category : #private }
SpTextInputFieldPresenter >> editable: aBoolean [

	editable := aBoolean
]

{ #category : #api }
SpTextInputFieldPresenter >> entryCompletion [
	"Return an entry completion used to suggest text while typing"

	^ entryCompletion
]

{ #category : #api }
SpTextInputFieldPresenter >> entryCompletion: anEntryCompletion [
	"Set an entry completion used to suggest text while typing"

	entryCompletion := anEntryCompletion
]

{ #category : #TOREMOVE }
SpTextInputFieldPresenter >> eventKeyStrokesForNextFocus [
	"String describing the keystroke to perform to jump to the next widget"	
		
	^ { Character tab asKeyCombination }
]

{ #category : #TOREMOVE }
SpTextInputFieldPresenter >> eventKeyStrokesForPreviousFocus [
	"String describing the keystroke to perform to jump to the previous widget"
	
	^ { Character tab shift asKeyCombination }
]

{ #category : #initialization }
SpTextInputFieldPresenter >> initialize [
	super initialize.

	maxLength := 0.
	isPassword := false.
	self beEditable.

]

{ #category : #testing }
SpTextInputFieldPresenter >> isEditable [
	"Answer true if edition is allowed (component is NOT readonly)"

	^ editable
]

{ #category : #testing }
SpTextInputFieldPresenter >> isPassword [
	"Answer true if input field will be shown as a password (hiding characters)."
	
	^ isPassword
]

{ #category : #api }
SpTextInputFieldPresenter >> maxLength [
	"Answer maximum allowed length (if set)"

	^ maxLength
]

{ #category : #api }
SpTextInputFieldPresenter >> maxLength: anInteger [ 
	"Set maximum allowed length."
	
	maxLength := anInteger.
	self updateText.
]

{ #category : #api }
SpTextInputFieldPresenter >> removeEntryCompletion [
	"Remove the entry completion"
	
	self entryCompletion: nil
]

{ #category : #api }
SpTextInputFieldPresenter >> text: aString [
	"Set input text contents."
	| truncatedText |

	truncatedText := self maxLength = 0
		ifTrue: [ aString ]
		ifFalse: [ aString first: (self maxLength min: aString size) ].
	super text: truncatedText
]

{ #category : #api }
SpTextInputFieldPresenter >> updateText [
	"Update text but applying lenght constraints"
	
	self text: self text.
]

{ #category : #'api-events' }
SpTextInputFieldPresenter >> whenEditableChangedDo: aBlock [
	"Inform when editable property has changed. 
	 `aBlock` has three optional arguments: 
	 - new value
	 - old value
	 - the announcement triggering this action"

	self property: #editable whenChangedDo: aBlock
]

{ #category : #'api-events' }
SpTextInputFieldPresenter >> whenEntryCompletionChangedDo: aBlock [
	"Inform when entryCompletion property has changed. 
	 `aBlock` has three optional arguments: 
	 - new value
	 - old value
	 - the announcement triggering this action"

	self property: #entryCompletion whenChangedDo: aBlock
]

{ #category : #'api-events' }
SpTextInputFieldPresenter >> whenMaxLengthChangedDo: aBlockClosure [ 
	"Inform when maxLength property has changed. 
	 `aBlock` has three optional arguments: 
	 - new value
	 - old value
	 - the announcement triggering this action"
	
	self property: #maxLength whenChangedDo: aBlockClosure
]

{ #category : #'api-events' }
SpTextInputFieldPresenter >> whenPasswordChangedDo: aBlockClosure [ 
	"Inform when password property has changed. 
	 `aBlock` has three optional arguments: 
	 - new value
	 - old value
	 - the announcement triggering this action"
	
	self property: #isPassword whenChangedDo: aBlockClosure
]

{ #category : #'api-events' }
SpTextInputFieldPresenter >> whenSubmitDo: aBlock [
	"This method will add a 'submit' event to the widget. It will react when user 
	 presses <meta+s> key (this is for historical reasons), and with enter (cr)."

	self 
		bindKeyCombination: Character cr asKeyCombination | $s meta 
		toAction: aBlock
]
