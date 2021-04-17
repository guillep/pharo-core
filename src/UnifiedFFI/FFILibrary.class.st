"
I'm an util to answer module libraries that can have different names in different platforms. 
I just implement a double dispatch with platform.
"
Class {
	#name : #FFILibrary,
	#superclass : #Object,
	#classInstVars : [
		'uniqueInstance'
	],
	#category : #'UnifiedFFI-Libraries'
}

{ #category : #converting }
FFILibrary class >> asFFILibrary [
	^ self uniqueInstance
]

{ #category : #converting }
FFILibrary class >> calloutAPIClass [

	^ self uniqueInstance calloutAPIClass 
]

{ #category : #'instance creation' }
FFILibrary class >> new [
	self error: 'Use #uniqueInstance'
]

{ #category : #options }
FFILibrary class >> options [
	
	^ #()
]

{ #category : #'instance creation' }
FFILibrary class >> uniqueInstance [ 
	self = FFILibrary 
		ifTrue: [ self error: 'I''m an abstract class, use one of my children.' ].
	^ uniqueInstance ifNil: [ uniqueInstance := super new ]
]

{ #category : #converting }
FFILibrary >> asFFILibrary [ 
	^ self
]

{ #category : #converting }
FFILibrary >> calloutAPIClass [

	^ FFICalloutAPI calloutAPIClass 
]

{ #category : #accessing }
FFILibrary >> ffiLibrary [

	"This method returns the FFILibrary to use when executing a FFI call.
	As we are already in a FFILibrary, the ffi call can use myself!"

	^ self
]

{ #category : #'library path' }
FFILibrary >> ffiLibraryName [
	^ self libraryName
]

{ #category : #accessing }
FFILibrary >> libraryName [ 
	^ Smalltalk platform ffiLibraryName: self
]

{ #category : #'accessing platform' }
FFILibrary >> macLibraryName [
	"Calling by default #macModuleName for backwards compatibility.
	The system complains that this method is not implemented as it will only exist
	in subclasses that use the old API.
	Please redefine #macLibraryName"
	^ self macModuleName
]

{ #category : #'accessing platform' }
FFILibrary >> options [
	
	^ self class options
]

{ #category : #'extension - hooks' }
FFILibrary >> postMethodBuildContext: sender builder: builder spec: functionSpec [
]

{ #category : #'extension - hooks' }
FFILibrary >> preMethodBuildContext: sender builder: builder spec: functionSpec [
]

{ #category : #accessing }
FFILibrary >> uniqueInstance [
	
	^ self
]

{ #category : #'accessing platform' }
FFILibrary >> unix32LibraryName [
	"Use to #unixLibraryName to keep backward compatibility." 
	^ self unixLibraryName
]

{ #category : #'accessing platform' }
FFILibrary >> unix64LibraryName [
	"Point to #unixLibraryName to keep backward compatibility." 
	^ self unixLibraryName
]

{ #category : #'accessing platform' }
FFILibrary >> unixLibraryName [
	"Kept for backward compatibility. 
	The system complains that this method is not implemented as it will only exist
	in subclasses that use the old API.
	 Users should use unix32* or unix64*"
	^ self unixModuleName
]

{ #category : #'accessing platform' }
FFILibrary >> win32LibraryName [
	"Calling by default #win32ModuleName for backwards compatibility.
	The system complains that this method is not implemented as it will only exist
	in subclasses that use the old API.
	Please redefine #win32LibraryName"
	^ self win32ModuleName
]
