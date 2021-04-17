Class {
	#name : #SpFTTableMorph,
	#superclass : #FTTableMorph,
	#instVars : [
		'movementDispatcher'
	],
	#category : #'Spec2-Adapters-Morphic-Support'
}

{ #category : #'drag and drop' }
SpFTTableMorph >> acceptDroppingMorph: aTransferMorph event: anEvent [

	^ self dataSource model adapter
		acceptDroppingMorph: aTransferMorph 
		event: anEvent
]

{ #category : #drawing }
SpFTTableMorph >> drawKeyboardFocusOn: aCanvas [

	self color = Color transparent ifTrue: [ ^ self ].
	^ super drawKeyboardFocusOn: aCanvas
]

{ #category : #'events-processing' }
SpFTTableMorph >> handleKeyDown: anEvent [
	"System level event handling."

	anEvent wasHandled ifTrue:[ ^ self ].
	
	self shortcutsHandler ifNotNil: [ :handler | 
		handler handleKeystroke: anEvent inMorph: self.
		anEvent wasHandled ifTrue: [ ^ self ] ].
	
	movementDispatcher dispatch: { anEvent }.
	anEvent wasHandled ifTrue: [ ^ self ].
	
	(self handlesKeyDown: anEvent) ifFalse:[ ^ self ].
	anEvent wasHandled: true.
	self keyDown: anEvent.
	
	^ self eventHandler ifNotNil: [ :handler | 
		handler 
			keyDown: anEvent 
			fromMorph: self ]
]

{ #category : #initialization }
SpFTTableMorph >> initializeKeyBindings [
	"add keybindings used by table"

	movementDispatcher := KMDispatcher target: self.
	movementDispatcher 
		bindKeyCombination: Character arrowUp shift | Character arrowUp asKeyCombination
		toAction: [ :target :morph :event | self keyStrokeArrowUp: event ].
	movementDispatcher
		bindKeyCombination: Character arrowDown shift | Character arrowDown asKeyCombination
		toAction: [ :target :morph :event | self keyStrokeArrowDown: event ].
	movementDispatcher
		bindKeyCombination: Character arrowLeft shift | Character arrowLeft asKeyCombination
		toAction: [ :target :morph :event | self keyStrokeArrowLeft: event ].
	movementDispatcher
		bindKeyCombination: Character arrowRight shift | Character arrowRight asKeyCombination
		toAction: [ :target :morph :event | self keyStrokeArrowRight: event ].
	movementDispatcher
		bindKeyCombination: Character home asKeyCombination
		toAction: [ self selectFirst ].
	movementDispatcher
		bindKeyCombination: Character end asKeyCombination
		toAction: [ self selectLast ].
	movementDispatcher
		bindKeyCombination: self shortcutProvider selectAllShortcut
		toAction: [ self selectAll ]
]

{ #category : #'drag and drop' }
SpFTTableMorph >> wantsDroppedMorph: aTransferMorph event: anEvent [

	aTransferMorph isTransferable ifFalse: [ ^ false ].
	^ self dataSource model adapter 
		wantsDroppedMorph: aTransferMorph 
		event: anEvent
]
