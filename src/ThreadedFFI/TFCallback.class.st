"
I am the Backend implementation of callbacks for UFFI. I use TFFI as a backend
"
Class {
	#name : #TFCallback,
	#superclass : #FFIExternalReference,
	#instVars : [
		'callbackData',
		'parameterHandlers',
		'returnTypeHandler',
		'runner',
		'parameterTypes',
		'returnType',
		'frontendCallback',
		'runStrategy',
		'success'
	],
	#category : #'ThreadedFFI-Callbacks'
}

{ #category : #finalization }
TFCallback class >> finalizeResourceData: aCallbackDataHandler [

	aCallbackDataHandler isNull ifTrue: [ ^ self ].
	
	self primUnregister: aCallbackDataHandler.
	aCallbackDataHandler beNull
]

{ #category : #'instance creation' }
TFCallback class >> forCallback: aCallback parameters: parameterTypes returnType: returnType runner: aRunner [

	^ self new
		frontendCallback: aCallback;
		parameterTypes: parameterTypes;
		returnType: returnType;
		runner: aRunner;
		autoRelease;
		register;
		yourself
]

{ #category : #'private primitives' }
TFCallback class >> primUnregister: callbackHandle [
	<primitive: 'primitiveUnregisterCallback'>

	^ self primitiveFailed
]

{ #category : #accessing }
TFCallback >> beFailed [

	success := false
]

{ #category : #accessing }
TFCallback >> beNull [

	self setHandle: ExternalAddress null

]

{ #category : #accessing }
TFCallback >> beSuccess [

	success := true
]

{ #category : #accessing }
TFCallback >> callbackData [
	^ callbackData
]

{ #category : #accessing }
TFCallback >> callbackData: anObject [
	callbackData := anObject
]

{ #category : #accessing }
TFCallback >> frontendCallback [

	^ frontendCallback
]

{ #category : #accessing }
TFCallback >> frontendCallback: anObject [
	frontendCallback := anObject
]

{ #category : #initialization }
TFCallback >> initialize [

	super initialize.
	success := true.
	callbackData := ExternalAddress new.
	parameterHandlers := #()
]

{ #category : #invoking }
TFCallback >> invokeAsFunctionWithArguments: aCollection [ 
	
	| definition function preparedArguments |

	definition := TFFunctionDefinition
		parameterTypes: self parameterTypes
		returnType: self returnType.

	function := TFExternalFunction 
		fromAddress: self getHandle 
		definition: definition.

	preparedArguments := aCollection 
		with: self parameterTypes 
		collect: [ :anArgument :aType | aType marshallToPrimitive: anArgument ].

	^ self returnType marshallFromPrimitive: (self runner invokeFunction: function withArguments: preparedArguments)
]

{ #category : #testing }
TFCallback >> isSuccess [

	^ success == true
]

{ #category : #accessing }
TFCallback >> parameterTypes [
	^ parameterTypes
]

{ #category : #accessing }
TFCallback >> parameterTypes: anObject [
	parameterTypes := anObject
]

{ #category : #registering }
TFCallback >> register [
	
	handle isNull ifFalse: [ ^ self error: 'Callback already registered' ].
	
	self validateTypes.
	self runner ensureInitialized.
	self registerCallback: frontendCallback tfPrintString.
	TFCallbackQueue uniqueInstance registerCallback: self.
]

{ #category : #registering }
TFCallback >> registerCallback [
	"TODO: This is still here to allow updating. We need to remove it soon!"
	<primitive: 'primitiveRegisterCallback'>
	^ self primitiveFailed 
]

{ #category : #registering }
TFCallback >> registerCallback: debugString [

	<primitive: 'primitiveRegisterCallback'>
	^ self primitiveFailed 
]

{ #category : #accessing }
TFCallback >> resourceData [

	^ self callbackData.

]

{ #category : #accessing }
TFCallback >> returnType [
	^ returnType
]

{ #category : #accessing }
TFCallback >> returnType: anObject [
	returnType := anObject
]

{ #category : #accessing }
TFCallback >> runStrategy [
	^ runStrategy ifNil: [ TFCallbackForkRunStrategy new ]
]

{ #category : #accessing }
TFCallback >> runStrategy: anObject [
	runStrategy := anObject
]

{ #category : #accessing }
TFCallback >> runner [
	^ runner
]

{ #category : #accessing }
TFCallback >> runner: anObject [
	runner := anObject
]

{ #category : #accessing }
TFCallback >> thunk [
	^ self getHandle 
]

{ #category : #'private operations' }
TFCallback >> validateTypes [

	parameterTypes do: [ :each | each validate ].
	returnType validate.

	parameterHandlers := parameterTypes collect: [ :e | e basicType ] as: Array.
	returnTypeHandler := returnType basicType.
]
