"
A MethodNameEditor is an editor to set the name of a method.


	MethodNameEditor openOn: (RBMethodName selector: #foo: arguments: #('x')) 
"
Class {
	#name : #RBMethodNameEditor,
	#superclass : #DialogWindowMorph,
	#instVars : [
		'argumentIndex',
		'labelMorph',
		'methodName',
		'selectorField',
		'labelGroup'
	],
	#category : #'Refactoring2-Transformations-Utilities'
}

{ #category : #'instance creation' }
RBMethodNameEditor class >> on: aMethodName [
	^ self basicNew initializeOn: aMethodName
]

{ #category : #'instance creation' }
RBMethodNameEditor class >> openOn: aMethodName [
	^ (self on: aMethodName) openModal
]

{ #category : #actions }
RBMethodNameEditor >> add [

	| newArguments |
	newArguments := self argumentList.
	newArguments add: ('arg', (newArguments size + 1) asString).
	
	self methodName arguments: newArguments.
	self update
]

{ #category : #grips }
RBMethodNameEditor >> addEdgeGrips [
	"Should add these to the front!"
	
	| l r lh |
	lh := self labelHeight.
	l  := WindowEdgeGripMorph new target: self; position: self position; edgeName: #left.
	l layoutFrame topOffset: lh negated + 22.
	r  := WindowEdgeGripMorph new target: self; position: self position; edgeName: #right.
	r layoutFrame topOffset: lh negated + 22.
	self
		addMorph: l;
		addMorph: r

]

{ #category : #grips }
RBMethodNameEditor >> addGrips [

	self addEdgeGrips
]

{ #category : #accessing }
RBMethodNameEditor >> argumentIndex [
	^ argumentIndex
]

{ #category : #accessing }
RBMethodNameEditor >> argumentIndex: anInteger [
	argumentIndex := anInteger.
	self update
]

{ #category : #accessing }
RBMethodNameEditor >> argumentList [

	^ self methodName
		ifNil: [ OrderedCollection new ]
		ifNotNil: [ :method | method arguments copy ]
]

{ #category : #actions }
RBMethodNameEditor >> cancel [
	methodName := nil.
	^ super cancel
]

{ #category : #'focus handling' }
RBMethodNameEditor >> defaultFocusMorph [
	"Answer the morph that should have the keyboard
	focus by default when the dialog is opened."
	
	^ selectorField
		ifNil: [ super defaultFocusMorph ]
]

{ #category : #actions }
RBMethodNameEditor >> down [
	self isDownEnabled ifFalse: [ ^ self ].
	self argumentList swap: self argumentIndex with: self argumentIndex + 1.
	self argumentIndex: self argumentIndex + 1
]

{ #category : #initialization }
RBMethodNameEditor >> initialize [

	super initialize.

	self beResizeable
]

{ #category : #initialization }
RBMethodNameEditor >> initializeOn: aMethodName [
	methodName := aMethodName.
	argumentIndex := 0.
	self initialize.
	self title: 'Method Name'
]

{ #category : #testing }
RBMethodNameEditor >> isDownEnabled [
	^ self argumentIndex ~= 0 and: [ self argumentIndex + 1 between: 1 and: self argumentList size ]
]

{ #category : #testing }
RBMethodNameEditor >> isOkEnabled [

	^ self methodName isNotNil
		and: [ self methodName isValid ]
]

{ #category : #testing }
RBMethodNameEditor >> isUpEnabled [
	^ self argumentIndex ~= 0 and: [ self argumentIndex - 1 between: 1 and: self argumentList size ]
]

{ #category : #accessing }
RBMethodNameEditor >> methodName [
	^ methodName
]

{ #category : #morphic }
RBMethodNameEditor >> newContentMorph [

	^ labelGroup := (self newRow: {
		self newLabelGroup: {
			'Selector:' -> (selectorField := 
			(self newTextEntryFor: self getText: #selector setText: #selector: help: nil)
				autoAccept: true;
				on: #keyStroke send: #value:value:
				to: [:key :morph | key keyCharacter = Character cr ifTrue: [ self ok. true]. false];
				hResizing: #spaceFill;
				yourself).
				
			'Arguments:' -> (self newRow: {
				(self newColumn: {
					self newButtonFor: self action: #add label: '+'  help: nil.
					self newButtonFor: self action: #remove label: '-'  help: nil })
					hResizing: #shrinkWrap.
				(self newListFor: self list: #argumentList
					selected: #argumentIndex
					changeSelected: #argumentIndex: help: nil)
					hResizing: #spaceFill;
					yourself. }).
					
			'Preview:' -> (labelMorph := self newLabel: self methodName printString) } } )
 		minWidth: 400;
		hResizing: #spaceFill;
		yourself
]

{ #category : #morphic }
RBMethodNameEditor >> newOKButton [
	^ self newOKButtonFor: self getEnabled: #isOkEnabled
]

{ #category : #actions }
RBMethodNameEditor >> remove [

	| newArguments |
	newArguments := self argumentList.
	newArguments removeAt: self argumentIndex.
	
	self methodName arguments: newArguments.
	self update
]

{ #category : #accessing }
RBMethodNameEditor >> selector [

	^ self methodName ifNotNil: [ :method | method selector ]
]

{ #category : #accessing }
RBMethodNameEditor >> selector: aString [

	super selector: aString.
	(labelGroup extent x > self extent x) ifTrue: [
		self extent: ((labelGroup extent x+20) @ labelGroup extent y) ]
	
	
]

{ #category : #actions }
RBMethodNameEditor >> up [
	self isUpEnabled ifFalse: [ ^ self ].
	self argumentList swap: self argumentIndex with: self argumentIndex - 1.
	self argumentIndex: self argumentIndex - 1
]

{ #category : #morphic }
RBMethodNameEditor >> update [
	self changed: #argumentList; changed: #argumentIndex.
	self changed: #isUpEnabled; changed: #isDownEnabled; changed: #isOkEnabled.
	labelMorph contents: self methodName printString
]
