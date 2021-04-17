"
A GLMHorizontalScrollPaneBrick is a very simple scrollpane with support of light scrollbar.
Acceleration mechanism is used for scrolling, as longer user scrolls faster it becomes.

"
Class {
	#name : #GLMHorizontalScrollPaneBrick,
	#superclass : #GLMScrollPaneBrick,
	#category : #'Glamour-Morphic-Brick-Widgets-Scrollpane'
}

{ #category : #private }
GLMHorizontalScrollPaneBrick >> calculateMaxVelocity [

	"max velocity must depend from the height of the band"
	^ (self band width / 15) max: self class defaultMaxVelocity
]

{ #category : #'instance creation' }
GLMHorizontalScrollPaneBrick >> newBand [
	^ GLMHorizontalBandBrick new
]

{ #category : #scrolling }
GLMHorizontalScrollPaneBrick >> scrollDown: anInteger [
	
	band brickBounds corner x <= self width ifTrue: [ ^ self ].
	band brickBounds: (band brickBounds translateBy: (anInteger@ 0) negated).
	band brickBounds corner x < self width ifTrue: [ band brickBounds: (band brickBounds translateBy: ((self width - band brickBounds corner x)@0)) ]
]

{ #category : #scrolling }
GLMHorizontalScrollPaneBrick >> scrollTo: aBrick [

	self shouldBeImplemented
]

{ #category : #scrolling }
GLMHorizontalScrollPaneBrick >> scrollUp: anInteger [

	"preventing from scrolling if already at the top"
	band brickBounds origin x >= 0 ifTrue: [ ^ self ].
	"actuall scrolling"
	band brickBounds: (band brickBounds translateBy: (anInteger@ 0)).
	"returning scrollpane back if went away"
	band brickBounds origin x > 0 ifTrue: [ band brickBounds: (band brickBounds translateBy: (band brickBounds origin x@ 0 ) negated) ]
]
