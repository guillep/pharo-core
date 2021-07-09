"
A SpecDialogWindow is a window made for embedding Spec models into dialog windows

"
Class {
	#name : #SpecDialogWindow,
	#superclass : #DialogWindowMorph,
	#instVars : [
		'specWidget',
		'toolbar'
	],
	#category : #'Spec-MorphicAdapters-Support'
}

{ #category : #protocol }
SpecDialogWindow >> cancelAction: aBlock [

	self toolbar cancelAction: aBlock 
]

{ #category : #protocol }
SpecDialogWindow >> cancelled [

	^ self toolbar cancelled
]

{ #category : #actions }
SpecDialogWindow >> close [

	super close.
	self toolbar cancel
]

{ #category : #actions }
SpecDialogWindow >> escapePressed [

	self toolbar triggerCancelAction
]

{ #category : #focus }
SpecDialogWindow >> giveFocusToNextFrom: aModel [ 

	^ self model giveFocusToNextFrom: aModel 
]

{ #category : #focus }
SpecDialogWindow >> giveFocusToPreviousFrom: aModel [ 

	^ self model giveFocusToPreviousFrom: aModel
]

{ #category : #'open/close' }
SpecDialogWindow >> initialExtent [ 

	^ self model
		ifNil: [ super initialExtent ]
		ifNotNil: [:m | m initialExtent
						ifNil: [ super initialExtent ]]
]

{ #category : #initialize }
SpecDialogWindow >> initialize [

	super initialize.

	self beResizeable
]

{ #category : #accessing }
SpecDialogWindow >> model: aModel [

	super model: aModel.

	aModel model focusOrder
		addLast: toolbar.
	toolbar focusOrder addLast: model
]

{ #category : #accessing }
SpecDialogWindow >> newButtonRow [
	^ self toolbar ifNotNil: [ :t | t buildWithSpec ]
]

{ #category : #accessing }
SpecDialogWindow >> newContentMorph [
	"Answer a new content morph."

	^ self specWidget
		ifNotNil: [ :w | 
			w
				hResizing: #spaceFill;
				vResizing: #spaceFill ]
]

{ #category : #actions }
SpecDialogWindow >> newMainPanel [
	"Answer a new main panel."
	| panel |
	panel := self newDialogPanel.
	self newContentMorph ifNotNil: [:m | panel 	addMorphBack: m ].
	self newButtonRow ifNotNil: [:m | panel 	addMorphBack: m ].
	^ panel
]

{ #category : #protocol }
SpecDialogWindow >> okAction: aBlock [

	self toolbar okAction: aBlock 
]

{ #category : #protocol }
SpecDialogWindow >> setToolbarFrom: aBlock [
	| newToolbar |
	
	newToolbar := aBlock value.
	
	toolbar := newToolbar.
	newToolbar owner: self
]

{ #category : #accessing }
SpecDialogWindow >> specWidget [

	^ specWidget
]

{ #category : #accessing }
SpecDialogWindow >> specWidget: anObject [

	specWidget := anObject.
]

{ #category : #accessing }
SpecDialogWindow >> toolbar [
	"Lazy initialization because this method is called efore the initialize method"
	
	^ toolbar
]

{ #category : #accessing }
SpecDialogWindow >> toolbar: anObject [

	toolbar := anObject.
	anObject owner: self.
	
	self removeMorph: self submorphs last.
	self addMainPanel
]
