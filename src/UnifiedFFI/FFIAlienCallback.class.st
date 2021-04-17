"
A callback via Alien machinery
"
Class {
	#name : #FFIAlienCallback,
	#superclass : #Object,
	#instVars : [
		'frontendCallback',
		'thunk',
		'callback'
	],
	#category : #'UnifiedFFI-Callbacks'
}

{ #category : #'instance creation' }
FFIAlienCallback class >> fromFrontendCallback: aFFICallback [

	^ self new
		frontendCallback: aFFICallback;
		yourself
]

{ #category : #private }
FFIAlienCallback >> argumentsFor: stackPointer context: callbackContext [

	| callbackArgumentReader | 
	
	callbackArgumentReader := FFIArchitecture forCurrentArchitecture newCallbackArgumentReaderForCallback: frontendCallback inContext: callbackContext.

	callbackArgumentReader extractArguments.
	
	self assert: frontendCallback functionSpec arguments size = callbackArgumentReader arguments size.

	^ callbackArgumentReader arguments.
]

{ #category : #accessing }
FFIAlienCallback >> beNull [

	thunk := ExternalAddress null
]

{ #category : #accessing }
FFIAlienCallback >> frontendCallback [
	^ frontendCallback
]

{ #category : #accessing }
FFIAlienCallback >> frontendCallback: anObject [
	frontendCallback := anObject.
	
	self register
]

{ #category : #invoking }
FFIAlienCallback >> invokeAsFunctionWithArguments: aCollection [ 

	^ (ExternalLibraryFunction 
			name: nil
			module: nil
			callType: (OSPlatform current ffiCallingConvention = #stdcall ifTrue: [ 1 ] ifFalse: [ 0 ])
			returnType: self frontendCallback functionSpec returnType externalTypeWithArity
			argumentTypes: (self frontendCallback functionSpec arguments collect: [:each | each externalTypeWithArity]))
				setHandle: (ExternalAddress fromAddress: (self frontendCallback thunk address)) ;	
					invokeWithArguments: aCollection

]

{ #category : #registering }
FFIAlienCallback >> register [
	"declare the real callback"
	callback := Callback forCallbackEvaluator: self.
	"keeping the thunk here to easy the FFI method compilation"
	thunk := callback thunk.
]

{ #category : #accessing }
FFIAlienCallback >> thunk [
	^ thunk
]

{ #category : #evaluation }
FFIAlienCallback >> valueWithContext: callbackContext sp: stackPointer [ 
	| argumentValues |
	
	self flag: #todo. "This can be optimised in a shadow method"
	argumentValues := self argumentsFor: stackPointer context: callbackContext.
	^ frontendCallback functionSpec returnType resolvedType
		callbackReturnOn: callbackContext 
		for: (frontendCallback valueWithArguments: argumentValues)
]
