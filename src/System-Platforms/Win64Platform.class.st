"
I am a an object representing a Windows platform (64bits). 
Use myself to access platform specific features.

Please keep me polymorphic to the the other platform objects.

To get the current platform, you can evaluate:

OSPlatform current.
"
Class {
	#name : #Win64Platform,
	#superclass : #WinPlatform,
	#category : #'System-Platforms-Windows'
}

{ #category : #testing }
Win64Platform class >> isActivePlatform [

	"Answer whether the receiver is the active platform"

	^ self currentPlatformName = 'Win32' and: [ 
		  Smalltalk vm wordSize = 8 ]
]

{ #category : #visiting }
Win64Platform >> accept: aVisitor [

	^ aVisitor visitWindows64: self
]

{ #category : #testing }
Win64Platform >> isWin64 [
	^ true
]
