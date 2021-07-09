Class {
	#name : #SliderTest,
	#superclass : #TestCase,
	#instVars : [
		'aSlider',
		'window'
	],
	#category : #'Morphic-Tests-Widgets'
}

{ #category : #helpers }
SliderTest >> assertSameValueAfter: aBlock [
	"I get the value on the slider, execute a block and then assert the value of the slider remains the same"

	| oldValue |
	oldValue := aSlider value.
	aBlock value.
	self assert: aSlider value equals: oldValue
]

{ #category : #helpers }
SliderTest >> createSlider [

	^ SliderMorph new
		extent: 240 @ 16;
		yourself
]

{ #category : #running }
SliderTest >> setUp [

	super setUp.
	aSlider := self createSlider.
	window := aSlider openInWindow.
]

{ #category : #running }
SliderTest >> tearDown [

	window close.
	super tearDown.
]

{ #category : #tests }
SliderTest >> testDraggingModifiesValue [

	aSlider simulateSliderMouseDown.
	aSlider
		simulateScrollAbsolute: aSlider bounds origin
		to: aSlider bounds corner.

	self assert: aSlider value equals: 1
]

{ #category : #tests }
SliderTest >> testDraggingSeveralTimesModifiesValueSeveralTimes [

	aSlider simulateSliderMouseDown.
	aSlider
		simulateScrollAbsolute: aSlider bounds origin
		to: aSlider bounds corner.
	aSlider
		simulateScrollAbsolute: aSlider bounds corner
		to: aSlider bounds origin.

	self assert: aSlider value equals: 0
]

{ #category : #tests }
SliderTest >> testMouseMoveWithoutDraggingDoesNotModifyValue [

	self assertSameValueAfter: [
		aSlider
			simulateScrollAbsolute: aSlider bounds origin
			to: aSlider bounds corner ]
]

{ #category : #tests }
SliderTest >> testMouseMoveWithoutDraggingDoesNotStartDrag [

	aSlider
		simulateScrollAbsolute: aSlider bounds origin
		to: aSlider bounds corner.

	"Verify that is not dragging"
	self deny: aSlider dragging
]

{ #category : #tests }
SliderTest >> testNewSliderIsNotDragging [

	self deny: aSlider dragging
]

{ #category : #tests }
SliderTest >> testNewSliderValueIsZero [

	self assert: aSlider value equals: 0
]

{ #category : #tests }
SliderTest >> testSliderMouseDownDoesNotModifyValue [

	self assertSameValueAfter: [ aSlider simulateSliderMouseDown ]
]

{ #category : #tests }
SliderTest >> testSliderMouseDownMakesItDrag [

	aSlider simulateSliderMouseDown.
	self assert: aSlider dragging
]

{ #category : #tests }
SliderTest >> testSliderMouseUpReleaseDrag [

	self assertSameValueAfter: [ 
		aSlider simulateSliderMouseDown.
		aSlider simulateSliderMouseUp.
	]
]
