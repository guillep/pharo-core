"
A button in a morphic based tree
"
Class {
	#name : #TreeColumnButtonMorph,
	#superclass : #SimpleButtonMorph,
	#instVars : [
		'model',
		'icon'
	],
	#category : #'Morphic-Widgets-Tree'
}

{ #category : #accessing }
TreeColumnButtonMorph >> acceptDroppingMorph: aMorph event: evt [
	self model container swapColumn: self model withColumn: aMorph passenger.
	evt hand releaseMouseFocus: self.
	self noMorePotentialDropTarget.
	self model container changed.
	Cursor normal show.

]

{ #category : #accessing }
TreeColumnButtonMorph >> asPotentialDropTarget [ 
	self model asPotentialDropTarget
]

{ #category : #'dropping/grabbing' }
TreeColumnButtonMorph >> handlesMouseOverDragging: evt [
	^ true
]

{ #category : #accessing }
TreeColumnButtonMorph >> icon [

	^ icon
]

{ #category : #accessing }
TreeColumnButtonMorph >> icon: anIcon [
	
	icon ifNotNil: [ self removeMorph: icon ].
	
	anIcon ifNotNil: [
		icon := anIcon.
		self addMorphFront: anIcon ]
]

{ #category : #initialization }
TreeColumnButtonMorph >> initialize [
	super initialize.
	self enableDragNDrop: true.
	self fillStyle: (self theme morphTreeColumnFillStyleFor: self).
	self borderStyle: (self theme morphTreeColumnBorderStyleFor: self)

]

{ #category : #testing }
TreeColumnButtonMorph >> isDefault [
	^true
]

{ #category : #initialization }
TreeColumnButtonMorph >> model [
	^ model
]

{ #category : #initialization }
TreeColumnButtonMorph >> model: anObject [
	model := anObject
]

{ #category : #'event handling' }
TreeColumnButtonMorph >> mouseDown: anEvent [
	| selectors |
	selectors := Array 
		with: #click:
		with: nil
		with: nil
		with: (self dragEnabled ifTrue:[#startDrag:] ifFalse:[nil]).
	anEvent hand waitForClicksOrDrag: self event: anEvent selectors: selectors threshold: 10.
	super mouseDown: anEvent
]

{ #category : #'dropping/grabbing' }
TreeColumnButtonMorph >> mouseEnterDragging: evt [
	(evt hand hasSubmorphs and:[self dropEnabled]) ifFalse: ["no d&d"
		^ super mouseEnterDragging: evt].
	(self wantsDroppedMorph: evt hand firstSubmorph event: evt )
		ifTrue:[
			self asPotentialDropTarget.
		].
]

{ #category : #'dropping/grabbing' }
TreeColumnButtonMorph >> mouseLeaveDragging: evt [
	self noMorePotentialDropTarget 
]

{ #category : #'dropping/grabbing' }
TreeColumnButtonMorph >> mouseUp: evt [
	self noMorePotentialDropTarget.
	super mouseUp: evt
]

{ #category : #accessing }
TreeColumnButtonMorph >> noMorePotentialDropTarget [
	self model noMorePotentialDropTarget
]

{ #category : #accessing }
TreeColumnButtonMorph >> removeIcon [
	
	icon ifNotNil: [ self removeMorph: icon ].
]

{ #category : #'event handling' }
TreeColumnButtonMorph >> startDrag: anEvent [
	| aTransferMorph |
	self dragEnabled ifFalse: [^ self].
	(anEvent hand hasSubmorphs)
		ifTrue: [^ self].
	oldColor 
		ifNotNil: [
			self fillStyle: oldColor.
			oldColor := nil].
	aTransferMorph := self model transferFor: self model from: self.
	aTransferMorph align: aTransferMorph draggedMorph center with: anEvent position.
	anEvent hand grabMorph: aTransferMorph.
	anEvent hand releaseMouseFocus: self
]

{ #category : #theme }
TreeColumnButtonMorph >> themedFillStyle [
	^ self theme morphTreeColumnFillStyleFor: self
]

{ #category : #accessing }
TreeColumnButtonMorph >> wantsDroppedMorph: aMorph event: anEvent [ 
	^ model container columnDropUnabled and: [(aMorph isTransferable) and: [(aMorph passenger isKindOf: MorphTreeColumn) and: [aMorph passenger ~= self model]]]
]
