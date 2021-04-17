Class {
	#name : #SpMorphicCodeAdapter,
	#superclass : #SpMorphicTextAdapter,
	#category : #'Spec2-Code-Morphic'
}

{ #category : #initialization }
SpMorphicCodeAdapter >> addKeyBindingsTo: aMorph [

	super addKeyBindingsTo: aMorph.
	self presenter contextKeyBindings ifNotNil: [ :kmCategory |
	 	kmCategory allEntries keymaps do: [ :each |
			self
				bindKeyCombination: each shortcut 
				toAction: each action ] ]
]

{ #category : #'widget API' }
SpMorphicCodeAdapter >> behavior [

	^ self presenter behavior
]

{ #category : #'private-shout' }
SpMorphicCodeAdapter >> bindingOf: aString [

	^ self presenter bindingOf: aString
]

{ #category : #factory }
SpMorphicCodeAdapter >> buildWidget [
	| newWidget |
	
	newWidget := super buildWidget.
	
	self presenter hasLineNumbers ifTrue: [ 
		newWidget withLineNumbers ].
	self presenter interactionModel ifNotNil: [ :im | 
		self setInteractionModel: im to: newWidget ].
 
	self presenter whenLineNumbersChangedDo: [ :hasLineNumbers | 
		self changeLineNumbers: hasLineNumbers to: newWidget ].
	self presenter whenSyntaxHighlightChangedDo: [ :hasSyntaxHighlight | 
		self setEditingModeFor: newWidget ].
	
	^ newWidget
]

{ #category : #private }
SpMorphicCodeAdapter >> changeLineNumbers: hasLineNumbers to: aMorph [ 

	hasLineNumbers 
		ifTrue: [ aMorph withLineNumbers ]
		ifFalse: [ aMorph withoutLineNumbers ]
]

{ #category : #'private-shout' }
SpMorphicCodeAdapter >> classOrMetaClass: aClass [

	self 
		setEditingModeFor: self widget textArea 
		withBehavior: aClass
		forScripting: self isForScripting
]

{ #category : #private }
SpMorphicCodeAdapter >> computeOriginFor: aMorph [
	| desiredTop desiredLeft |

	aMorph textArea scrollSelectionIntoView: nil.
	desiredTop := (self originMorphFor: aMorph) positionInWorld y - 6.
						"unclear why 6 is the magic number"
	desiredLeft := (self originMorphFor: aMorph) right + aMorph positionInWorld x + 6.
	
	^ desiredLeft @ desiredTop
]

{ #category : #'widget API' }
SpMorphicCodeAdapter >> doItContext [

	^ self presenter doItContext
]

{ #category : #'widget API' }
SpMorphicCodeAdapter >> doItReceiver [

	^ self presenter doItReceiver
]

{ #category : #NOCompletion }
SpMorphicCodeAdapter >> guessTypeForName: aString [

	^nil
]

{ #category : #'private-shout' }
SpMorphicCodeAdapter >> hasBindingOf: aString [

	^ self presenter hasBindingOf: aString
]

{ #category : #private }
SpMorphicCodeAdapter >> hasSyntaxHighlight [

	^ self presenter hasSyntaxHighlight
]

{ #category : #private }
SpMorphicCodeAdapter >> hasSyntaxHighlightEnabled [
	"this is used just for testing"
	
	^ self presenter hasSyntaxHighlight
]

{ #category : #'widget API' }
SpMorphicCodeAdapter >> insertPopoverAfterCurrentSelection: aPresenter style: styleName [
	| popover pos |

	self widgetDo: [ :w |

		popover := self presenter newPopover
			bePositionRight;
			presenter: aPresenter;
			yourself.
			
		styleName ifNotNil: [ 
			popover addStyle: styleName ].
		popover buildWithSpec.
		"popover style needs to be applied when poping up. 
		 Do not apply it here! (I am letting it here as documentation)"
		"popover adapter applyStyle."
	
		pos := self computeOriginFor: w.
		"(20@0) is a magic number to position correctly the popover"
		popover popupPointingTo: (pos corner: (pos + (20@0))).
		popover takeKeyboardFocus ]
]

{ #category : #'widget API' }
SpMorphicCodeAdapter >> interactionModel: anInteractionModel [

	self classOrMetaClass: anInteractionModel behavior.
	self widgetDo: [ :w |
		self setInteractionModel: anInteractionModel to: w ]
]

{ #category : #'widget API' }
SpMorphicCodeAdapter >> isForScripting [

	^ self presenter isForScripting
]

{ #category : #private }
SpMorphicCodeAdapter >> newCompletionEngine: anInteractionModel [

	^ SpMorphicCodeCompletionEngine new 
		scripting: anInteractionModel isForScripting;
		doItRequestor: anInteractionModel;
		doItContext: anInteractionModel doItContext;
		completionClass: anInteractionModel selectedClassOrMetaClass;
		yourself
]

{ #category : #private }
SpMorphicCodeAdapter >> originMorphFor: aMorph [

	(aMorph textArea hasSelection not and: [ 
		aMorph textArea hasHighlightSegment ]) ifTrue: [ 
			^ aMorph textArea getHighlightSegment ].
	^ aMorph textArea cursor
]

{ #category : #NOCompletion }
SpMorphicCodeAdapter >> receiverClass [

	^ self behavior
]

{ #category : #'widget API' }
SpMorphicCodeAdapter >> selectedBehavior [

	^ self presenter selectedBehavior
]

{ #category : #NOCompletion }
SpMorphicCodeAdapter >> selectedClassOrMetaClass [

	^ self behavior
]

{ #category : #private }
SpMorphicCodeAdapter >> setEditingModeFor: textArea [

	self hasSyntaxHighlight
		ifTrue: [ 
			self 
				setEditingModeFor: textArea 
				withBehavior: self behavior 
				forScripting: self isForScripting ]
		ifFalse: [ 
			super setEditingModeFor: textArea ]
]

{ #category : #private }
SpMorphicCodeAdapter >> setEditingModeFor: textArea withBehavior: aBehavior forScripting: aBoolean [

	textArea model: self.
	(aBoolean or: [ aBehavior isNil ]) 
		ifTrue: [ 
			textArea beForSmalltalkScripting.
			textArea editingMode classOrMetaClass: aBehavior ]
		ifFalse: [
			textArea beForSmalltalkCodeInClass: aBehavior ].
	"Following code should bring correct requestor (a code presenter) with a proper code interaction model into styler to enable a visibility of external variables (like workspace variables)"
	textArea shoutStyler styler 
		isForWorkspace: aBoolean;
		workspace: self presenter.
	textArea shoutStyler refreshStyling
]

{ #category : #'widget API' }
SpMorphicCodeAdapter >> setInteractionModel: anInteractionModel to: w [

	w textArea editor isSmalltalkEditor ifFalse: [ ^ self ].
	w completionEngine: (self newCompletionEngine: anInteractionModel)
]

{ #category : #private }
SpMorphicCodeAdapter >> textWithStyle [
	"This method is to be used for testing. 
	 DO NOT USE IT!"
	
	^ self widget getText
]

{ #category : #'widget API' }
SpMorphicCodeAdapter >> userActionDuring: aBlock [

	aBlock value
]
