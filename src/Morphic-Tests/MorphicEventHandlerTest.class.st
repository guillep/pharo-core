Class {
	#name : #MorphicEventHandlerTest,
	#superclass : #TestCase,
	#instVars : [
		'morph'
	],
	#category : #'Morphic-Tests-Event'
}

{ #category : #running }
MorphicEventHandlerTest >> setUp [
	super setUp.
	morph := Morph new.
	morph eventHandler: MorphicEventHandler new
]

{ #category : #running }
MorphicEventHandlerTest >> tearDown [

	morph delete.

	morph := nil.
	super tearDown
]

{ #category : #tests }
MorphicEventHandlerTest >> testClickFromMorph [
	morph eventHandler on: #click send: #value to: true.

	self assert: (morph click: nil) identicalTo: true
]

{ #category : #tests }
MorphicEventHandlerTest >> testDoubleClickFromMorph [
	morph eventHandler on: #doubleClick send: #value to: true.

	self assert: (morph doubleClick: nil) identicalTo: true
]

{ #category : #tests }
MorphicEventHandlerTest >> testDoubleClickTimeoutFromMorph [
	morph eventHandler on: #doubleClickTimeout send: #value to: true.

	self assert: (morph doubleClickTimeout: nil) identicalTo: true
]

{ #category : #'tests - events' }
MorphicEventHandlerTest >> testKeyDownFromMorph [
	| keyboardEvent |

	keyboardEvent := KeyboardEvent new
		setType: #keyDown
		buttons: 2
		position: nil
		keyValue: nil
		charCode: 65
		hand: nil
		stamp: nil.

	morph eventHandler on: #keyDown send: #value to: true.

	self assert: (keyboardEvent sentTo: morph) identicalTo: true
]

{ #category : #tests }
MorphicEventHandlerTest >> testKeyStrokeFromMorph [
	| keyboardEvent |
	keyboardEvent := KeyboardEvent new
		setType: #keystroke
		buttons: 2
		position: nil
		keyValue: nil
		charCode: 65
		hand: nil
		stamp: nil.

	morph eventHandler on: #keyStroke send: #value to: true.

	self assert: (morph handleKeystroke: keyboardEvent) identicalTo: true
]

{ #category : #'tests - events' }
MorphicEventHandlerTest >> testKeyUpFromMorph [
	| keyboardEvent |

	keyboardEvent := KeyboardEvent new
		setType: #keyUp
		buttons: 2
		position: nil
		keyValue: nil
		charCode: 65
		hand: nil
		stamp: nil.

	morph eventHandler on: #keyUp send: #value to: true.

	self assert: (keyboardEvent sentTo: morph) identicalTo: true
]

{ #category : #'tests - events' }
MorphicEventHandlerTest >> testMiddleButtonOpenHalos [
	| event |

	morph openInWorld.

	event := (MouseButtonEvent new 
		setType: #mouseDown
		position: 0@0
		which: MouseButtonEvent blueButton
		buttons: 0
		hand: morph world activeHand
		stamp: Time millisecondClockValue).
	
	event sentTo: morph.
			
	self assert: (morph halo) isNotNil
]

{ #category : #'tests - events' }
MorphicEventHandlerTest >> testMouseDownFromMorph [
	| event |

	event := (MouseButtonEvent new 
		setType: #mouseDown
		position: 0@0
		which: 0
		buttons: 0
		hand: (HandMorph new
			mouseFocus: morph;
			yourself)
		stamp: Time millisecondClockValue).

	morph eventHandler on: #mouseDown send: #value to: true.
	
	self assert: (event sentTo: morph) identicalTo: true
]

{ #category : #'tests - events' }
MorphicEventHandlerTest >> testMouseEnterDraggingFromMorph [
	| event |
	event := MouseEvent basicNew
		setType: #mouseOver
		position: nil
		buttons: 2
		hand: Morph new.
	morph eventHandler on: #mouseEnterDragging send: #value to: true.

	self assert: (morph handleMouseEnter: event) identicalTo: true
]

{ #category : #tests }
MorphicEventHandlerTest >> testMouseEnterEventIsNotDuplicated [
	| mockObject window evt |
	mockObject := ForEventTestMock new.

	[ window := mockObject stringMorph openInWindow.
	evt := MouseButtonEvent new
		setType: nil
		position: mockObject stringMorph center
		which: MouseButtonEvent redButton
		buttons: MouseButtonEvent redButton
		hand: nil
		stamp: nil.

	self assert: mockObject counter equals: 0.

	mockObject stringMorph handleMouseEnter: evt.
	self assert: mockObject counter equals: 1 ]
		ensure: [ window ifNotNil: #close ]
]

{ #category : #'tests - events' }
MorphicEventHandlerTest >> testMouseEnterFromMorph [
	| event |
	morph eventHandler on: #mouseEnter send: #value to: true.

	event := (MouseButtonEvent new 
		setType: #mouseMove
		position: 0@0
		which: 0
		buttons: 0
		hand: (HandMorph new
			mouseFocus: morph;
			yourself)
		stamp: Time millisecondClockValue).

	self assert: (morph handleMouseEnter: event) identicalTo: true
]

{ #category : #'tests - events' }
MorphicEventHandlerTest >> testMouseLeaveFromMorph [
	| event |
	morph eventHandler on: #mouseLeave send: #value to: true.

	event := (MouseButtonEvent new 
		setType: #mouseMove
		position: 0@0
		which: 0
		buttons: 0
		hand: (HandMorph new
			mouseFocus: morph;
			yourself)
		stamp: Time millisecondClockValue).

	self assert: (morph handleMouseLeave: event) identicalTo: true
]

{ #category : #'tests - events' }
MorphicEventHandlerTest >> testMouseUpFromMorph [
	| event |

	event := (MouseButtonEvent new 
		setType: #mouseUp
		position: 0@0
		which: 0
		buttons: 0
		hand: (HandMorph new
			mouseFocus: morph;
			yourself)
		stamp: Time millisecondClockValue).

	morph eventHandler on: #mouseUp send: #value to: true.
	
	self assert: (event sentTo: morph) identicalTo: true
]

{ #category : #tests }
MorphicEventHandlerTest >> testTwoEventHandlersAreAttached [

	| keyboardEvent first second |
	keyboardEvent := KeyboardEvent new 
							setType: #keystroke
							buttons: 2
							position: nil
							keyValue: 65
							charCode: 65
							hand: nil
							stamp: nil.

	first := false.
	second := false.
	morph eventHandler on: #keyStroke send: #value to: [ first := true ].
	morph eventHandler on: #keyStroke send: #value to: [ second := true ].
	morph handleKeystroke: keyboardEvent.
	
	self assert: first.
	self assert: second.
]
