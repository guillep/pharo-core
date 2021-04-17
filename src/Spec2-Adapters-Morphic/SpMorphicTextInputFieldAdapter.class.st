"
I am the adapter used to bridge a TextInputFieldPresenter and a PluggableTextFieldMorph
"
Class {
	#name : #SpMorphicTextInputFieldAdapter,
	#superclass : #SpMorphicBaseTextAdapter,
	#category : #'Spec2-Adapters-Morphic-Base'
}

{ #category : #'widget API' }
SpMorphicTextInputFieldAdapter >> accept: aText notifying: aNotifyier [
	"We use #asString because rubric send Text instead of strings."

	super
		accept: aText asString 
		notifying: aNotifyier
]

{ #category : #factory }
SpMorphicTextInputFieldAdapter >> buildWidget [
	| newWidget |

	newWidget := (SpRubTextFieldMorph on: self)
		getTextSelector: #getText;
		setTextSelector: #accept:notifying:;
		getSelectionSelector: #readSelection;
		menuProvider: self selector: #codePaneMenu:shifted:;
		setSelectionSelector: #setSelection:;
		entryCompletion: self entryCompletion;
		ghostText: self getPlaceholderText;
		encrypted: self encrypted;
		enabled: self enabled;
		askBeforeDiscardingEdits: self askBeforeDiscardingEdits;
		autoAccept: true;
		vResizing: #spaceFill;
		hResizing: #spaceFill;
		setBalloonText: self help;
		dragEnabled: self dragEnabled;
		dropEnabled: self dropEnabled;
		maxLength: self presenter maxLength;
		yourself.

	self presenter whenTextChangedDo: [ :text | newWidget setText: text ].
	self presenter whenSelectionChangedDo: [ :selectionInterval | 
		self selectionInterval: selectionInterval ].
	self presenter whenPlaceholderChangedDo: [ :text | 
		newWidget ghostText: (text ifNotNil: [ :aString | 
			aString localizedForPresenter: self presenter ]) ].
	self presenter whenPasswordChangedDo: [ :isPassword | 
		newWidget encrypted: isPassword ].
	self presenter whenMaxLengthChangedDo: [ :length | 
		newWidget maxLength: length ].
	self presenter whenEditableChangedDo: [ :value | 
		self setEditable: value to: newWidget ].

	^ newWidget
]

{ #category : #'widget API' }
SpMorphicTextInputFieldAdapter >> cursorPositionIndex: index [ 

	self widgetDo: [ :w | ^ w textArea editor selectAt: index ]
]

{ #category : #'widget API' }
SpMorphicTextInputFieldAdapter >> encrypted [
	^ self model isPassword
]

{ #category : #'spec protocol' }
SpMorphicTextInputFieldAdapter >> encrypted: aBoolean [

	self widgetDo: [ :w | 
		w encrypted: aBoolean.
		w changed ]
]

{ #category : #'widget API' }
SpMorphicTextInputFieldAdapter >> entryCompletion [

	^ self model entryCompletion
]

{ #category : #private }
SpMorphicTextInputFieldAdapter >> eventHandlerReceiver: aWidget [

	^ aWidget textArea
]

{ #category : #private }
SpMorphicTextInputFieldAdapter >> getPlaceholderText [

	^ self presenter placeholder ifNotNil: [ :aString | 
		aString localizedForPresenter: self presenter ]
]

{ #category : #testing }
SpMorphicTextInputFieldAdapter >> isPassword [
	
	^ self widget font isKindOf: FixedFaceFont
]

{ #category : #private }
SpMorphicTextInputFieldAdapter >> setEditable: aBoolean to: aWidget [

	aWidget textArea readOnly: aBoolean not
]

{ #category : #accessing }
SpMorphicTextInputFieldAdapter >> text: aString [

	widget
		setText: aString;
		acceptTextInModel
]

{ #category : #emulating }
SpMorphicTextInputFieldAdapter >> widgetEventReceiver [
	
	^ widget
]
