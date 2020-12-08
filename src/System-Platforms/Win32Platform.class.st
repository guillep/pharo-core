"
I am a an object representing a Windows platform (32bits). 
Use myself to access platform specific features.

Please keep me polymorphic to the the other platform objects.

To get the current platform, you can evaluate:

OSPlatform current.
"
Class {
	#name : #Win32Platform,
	#superclass : #WinPlatform,
	#category : #'System-Platforms-Windows'
}

{ #category : #testing }
Win32Platform class >> isActivePlatform [

	"Answer whether the receiver is the active platform"

	^ self currentPlatformName = 'Win32' and: [ 
		  Smalltalk vm wordSize = 4 ]
]

{ #category : #visiting }
Win32Platform >> accept: aVisitor [

	^ aVisitor visitWindows32: self
]

{ #category : #testing }
Win32Platform >> isWin32 [
	^ true
]
