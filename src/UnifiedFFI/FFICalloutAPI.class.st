"
I'm a façade to perform ffi nb calls.
"
Class {
	#name : #FFICalloutAPI,
	#superclass : #Object,
	#instVars : [
		'options',
		'callingConvention',
		'senderContext',
		'uFFIEntryPointContext'
	],
	#classVars : [
		'CalloutAPIClass'
	],
	#category : #'UnifiedFFI-Callouts'
}

{ #category : #accessing }
FFICalloutAPI class >> calloutAPIClass [
	^ CalloutAPIClass ifNil: [ self defaultCalloutAPIClass ]
	
]

{ #category : #accessing }
FFICalloutAPI class >> calloutAPIClass: aClass [
	CalloutAPIClass := aClass
]

{ #category : #accessing }
FFICalloutAPI class >> defaultCalloutAPIClass [
	
	^ FFIBackend current calloutAPIClass 
]

{ #category : #'instance creation' }
FFICalloutAPI class >> inContext: aContext [
	"Should not be used. For backwards compatibility only"
	^ self basicNew 
		initializeContext: aContext;
		yourself
]

{ #category : #'instance creation' }
FFICalloutAPI class >> inUFFIContext: aContext [
	^ self basicNew 
		initializeUFFIContext: aContext;
		yourself
]

{ #category : #'instance creation' }
FFICalloutAPI class >> new [ 
	self error: 'use #inFFIContext:'
]

{ #category : #private }
FFICalloutAPI class >> newCallbackBackendFor: aCallback [

	^ FFIAlienCallback fromFrontendCallback: aCallback
]

{ #category : #private }
FFICalloutAPI >> callingConvention [
	^ callingConvention
]

{ #category : #'call conventions' }
FFICalloutAPI >> cdecl [
	callingConvention := #cdecl
]

{ #category : #accessing }
FFICalloutAPI >> context [
	^ senderContext
]

{ #category : #accessing }
FFICalloutAPI >> convention: aCallingConvention [
	"It can be #cdecl or #stdcall"
	callingConvention := aCallingConvention
]

{ #category : #configuration }
FFICalloutAPI >> findUffiEnterContext [
	"Finds the initial context where entering the uffi framework.
	That is, the context that was marked with the #ffiCalloutTranslator pragma, whose caller was not.
	The found context determines how uffi was called. Its sender context is the client context.
	If no context is found, return nil"
	
	| pragmaName uffiEnterContext |
	pragmaName := #ffiCalloutTranslator.
	
	uffiEnterContext := (uFFIEntryPointContext ifNil: [ thisContext ]) findContextSuchThat: [ :ctx |
		(ctx compiledCode method hasPragmaNamed: pragmaName)
			and: [ (ctx sender compiledCode method hasPragmaNamed: pragmaName) not] ].
	^ uffiEnterContext
]

{ #category : #action }
FFICalloutAPI >> function: functionSignature library: moduleNameOrLibrary [
	| sender ffiMethod ffiMethodSelector |
	sender := self senderContext.
	ffiMethodSelector := self uFFIEnterMethodSelector.	"Build new method"
	ffiMethod := self newBuilder
		build: [ :builder | 
			builder
				signature: functionSignature;
				sender: sender;
				library: moduleNameOrLibrary ].
	ffiMethod
		selector: sender selector;
		methodClass: sender methodClass.	"Replace with generated ffi method, but save old one for future use"
	ffiMethod
		propertyAt: #ffiNonCompiledMethod
		put: (sender methodClass methodDict at: sender selector).	"For senders search, one need to keep the selector in the properties"
	ffiMethod propertyAt: #ffiMethodSelector put: ffiMethodSelector.
	sender methodClass methodDict at: sender selector put: ffiMethod.	"Register current method as compiled for ffi"
	FFIMethodRegistry uniqueInstance registerMethod: ffiMethod.	"Resend"
	sender
		return: (sender receiver withArgs: sender arguments executeMethod: ffiMethod).
	^ self
]

{ #category : #'backward compatibility' }
FFICalloutAPI >> function: aCollection module: aClass [ 
	
	^ self function: aCollection library: aClass
]

{ #category : #initialization }
FFICalloutAPI >> initialize [
	callingConvention := #cdecl.
	options := #().
	super initialize
]

{ #category : #initialization }
FFICalloutAPI >> initializeContext: aContext [
	senderContext := aContext.
	self initialize
]

{ #category : #initialization }
FFICalloutAPI >> initializeUFFIContext: aUFFIEntryPointContext [
	uFFIEntryPointContext := aUFFIEntryPointContext.
	self initialize
]

{ #category : #action }
FFICalloutAPI >> newBuilder [
	^ FFICalloutMethodBuilder calloutAPI: self
]

{ #category : #action }
FFICalloutAPI >> newCallbackWithSignature: signature block: aBlock library: aLibrary [

	^ (FFICallback signature: signature block: aBlock)
		calloutAPIClass: self class;
		ffiLibrary: aLibrary;
		yourself
]

{ #category : #accessing }
FFICalloutAPI >> options [
	^ options
]

{ #category : #accessing }
FFICalloutAPI >> options: anObject [
	options := anObject
]

{ #category : #accessing }
FFICalloutAPI >> senderContext [
	
	senderContext ifNotNil: [ ^ senderContext ].
	^ self findUffiEnterContext sender
]

{ #category : #'call conventions' }
FFICalloutAPI >> stdcall [
	callingConvention := #stdcall
]

{ #category : #accessing }
FFICalloutAPI >> uFFIEnterMethodSelector [
	
	"Return the selector of the uffiEnterContext.
	That is, the selector that was called by client code to invoke uffi.
	If we got here from a context not controlled by uffi, return nil, as we have found no method"
	
	^ self findUffiEnterContext ifNotNil: [ :ctx | ctx compiledCode method selector ]
]
