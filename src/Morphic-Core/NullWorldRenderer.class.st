"
I am a null renderer.
I am used when we are in command line or during the initialization
"
Class {
	#name : #NullWorldRenderer,
	#superclass : #AbstractWorldRenderer,
	#category : #'Morphic-Core-Worlds'
}

{ #category : #accessing }
NullWorldRenderer class >> isApplicableFor: aWorld [

	"This worldRenderer is always applicable"
	^ true
]

{ #category : #accessing }
NullWorldRenderer class >> priority [ 

	^ 0
]

{ #category : #operations }
NullWorldRenderer >> activateCursor: aCursor withMask: maskForm [

	"We don't activate nothing"
]

{ #category : #accessing }
NullWorldRenderer >> actualScreenSize [

	^ 240@120
]

{ #category : #generated }
NullWorldRenderer >> canvas: x [

	self deprecated: 'Use #invalidate instead'
]

{ #category : #'display box access' }
NullWorldRenderer >> checkForNewScreenSize [

]

{ #category : #activation }
NullWorldRenderer >> deactivate [
]

{ #category : #activation }
NullWorldRenderer >> doActivate [
]

{ #category : #operations }
NullWorldRenderer >> drawDuring: aBlock [

	| canvas |
	canvas := (Form extent: self actualScreenSize depth: 32) getCanvas.
	aBlock value: canvas
]

{ #category : #operations }
NullWorldRenderer >> forceDamageToScreen: allDamage [

	"Do Nothing"
	
]

{ #category : #operations }
NullWorldRenderer >> forceDisplayUpdate [

	" Do Nothing "
]

{ #category : #accessing }
NullWorldRenderer >> icon: aForm [ 

	"Do nothing, a null world rendered has no window, so no icon either"
]

{ #category : #rendering }
NullWorldRenderer >> updateDamage: rectangles [

	"Do nothing"
]
