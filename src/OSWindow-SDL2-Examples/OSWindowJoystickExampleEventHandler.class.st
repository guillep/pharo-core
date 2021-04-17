"
I am the event handler linked to OSWindowJoystickExample.
"
Class {
	#name : #OSWindowJoystickExampleEventHandler,
	#superclass : #OSWindowGenericRendererExampleEventHandler,
	#category : #'OSWindow-SDL2-Examples-Joystick'
}

{ #category : #settings }
OSWindowJoystickExampleEventHandler class >> axisDeadZoneThreshold [
	^ 0.20
]

{ #category : #settings }
OSWindowJoystickExampleEventHandler class >> axisMaxValue [
	^ 32767
]

{ #category : #accessing }
OSWindowJoystickExampleEventHandler >> axisDeadZoneThreshold [
	^ self class axisDeadZoneThreshold
]

{ #category : #settings }
OSWindowJoystickExampleEventHandler >> axisMaxValue [
	^ self class axisMaxValue
]

{ #category : #visiting }
OSWindowJoystickExampleEventHandler >> normalizeAxisValue: value [
	| result deadZone |
	result := value asFloat / self axisMaxValue.
	deadZone := self axisDeadZoneThreshold.
	(result between: deadZone negated and: deadZone) ifTrue: [ 
		result := 0.0
	] ifFalse: [
		result < 0 ifTrue: [ 
			result := result + deadZone.
		] ifFalse: [ 
			result := result - deadZone.
		].
		result := result / (1.0 - deadZone).
	].

	^ result min: 1.0 max: -1.0
]

{ #category : #visiting }
OSWindowJoystickExampleEventHandler >> visitJoyAxisEvent: axisEvent [
	| axisValue velocity |
	axisEvent isPreferredEvent ifFalse: [ ^ self ].
	
	axisValue := self normalizeAxisValue: axisEvent value.
	velocity := example characterVelocity.
	axisEvent isLeftX ifTrue: [ 
		velocity := (axisValue * 300) @ velocity y
	].

	axisEvent isLeftY ifTrue: [ 
		"Left Y"
		velocity := velocity x @ (axisValue * 300)

	].

	example characterVelocity: velocity
]

{ #category : #visiting }
OSWindowJoystickExampleEventHandler >> visitJoyButtonDownEvent: buttonEvent [
	buttonEvent isPreferredEvent ifFalse: [ ^ self ].
	
	buttonEvent isButtonX ifTrue: [ 
		example shoot.
	].

	buttonEvent isButtonStart ifTrue: [ 
		example reset.
	].

]

{ #category : #visiting }
OSWindowJoystickExampleEventHandler >> visitJoyButtonUpEvent: buttonUpEvent [
	buttonUpEvent isPreferredEvent ifFalse: [ ^ self ].
	"TODO: Handle button up event."
]
