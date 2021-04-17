Class {
	#name : #FFIStringCalloutTest,
	#superclass : #TestCase,
	#category : #'UnifiedFFI-Tests-Tests'
}

{ #category : #tests }
FFIStringCalloutTest >> newFFIMethodWithSignature: signature doing: aBlock [
	
	^ self newFFIMethodWithSignature: signature doing: aBlock options: #()
]

{ #category : #tests }
FFIStringCalloutTest >> newFFIMethodWithSignature: signature doing: aBlock options: options [
	
	| calloutAPI methodBuilder |
	calloutAPI := FFICalloutAPI inUFFIContext: nil.
	methodBuilder := FFIMockCalloutMethodBuilder calloutAPI: calloutAPI.
	methodBuilder doing: aBlock.
	methodBuilder requestor: (FFICallout new
		methodArgs: aBlock argumentNames;
		requestor: methodBuilder;
		options: options;
		yourself).
	
	^ methodBuilder build: [ :builder | 
			builder
				signature: signature;
				sender: methodBuilder ]
]

{ #category : #tests }
FFIStringCalloutTest >> testCalloutShouldHaveLegacyStringEncodingStrategyByDefault [
	|generator|
	generator := FFICallout new.
	
	self assert: generator stringEncodingStrategy isLegacy
]

{ #category : #tests }
FFIStringCalloutTest >> testConflictingEncodingOptionShouldRaiseError [
	|generator|
	generator := FFICallout new.
	generator options: #( optStringEncodingUtf8 optStringEncodingUtf16 ).

	[generator stringEncodingStrategy.
	self fail]
		on: Error
		do: [ :error | self assert: error messageText equals: 'Conflicting string encoding options' ]
]

{ #category : #tests }
FFIStringCalloutTest >> testEncodingOptionSetsStringEncodingStrategy [
	|generator|
	generator := FFICallout new.
	generator options: #( optStringEncodingUtf8 ).
	self assert: generator stringEncodingStrategy encoding equals: 'Utf8'
]

{ #category : #tests }
FFIStringCalloutTest >> testLegacyCalloutShouldReturnStringArgument [
	| method return |
	
	method := self
		newFFIMethodWithSignature: #( char* f ( void ) )
		doing: [ 'string' ].	
	
	return := method valueWithReceiver: nil arguments: #( ).
	
	self assert: return equals: 'string'
]

{ #category : #tests }
FFIStringCalloutTest >> testLegacyCalloutShouldSendStringArgument [
	| ffiInvocationArgument method |
	
	method := self
		newFFIMethodWithSignature: #( void f (char* aString) )
		doing: [ :aString | ffiInvocationArgument := aString ].	
	method valueWithReceiver: nil arguments: #( 'string' ).
	
	self assert: ffiInvocationArgument equals: 'string'
]

{ #category : #tests }
FFIStringCalloutTest >> testMandatoryEncodingWithSpecifiedEncodingShouldNotFail [
	| ffiInvocationArgument method |
	
	method := self
		newFFIMethodWithSignature: #( void f (char* aString) )
		doing: [ :aString | ffiInvocationArgument := aString ]
		options: #( optStringEncodingUtf8 optStringEncodingMandatory ).
	method valueWithReceiver: nil arguments: #( 'string' ).
	
	self assert: ffiInvocationArgument equals: ('string' nullTerminatedEncodeWith: #utf8)
]

{ #category : #tests }
FFIStringCalloutTest >> testMandatoryEncodingWithoutExplicitEncodingShouldRaiseError [
	[self
		newFFIMethodWithSignature: #( void f (char* 'string') )
		doing: [ :aString | "nothing" ]
		options: #( optStringEncodingMandatory ).
	self fail]
		on: Error
		do: [ :error | self assert: error messageText equals: 'String encoding option not specified' ]
]

{ #category : #tests }
FFIStringCalloutTest >> testStringEncodingWithMandatoryEncodingWithSpecifiedEncodingShouldNotFail [
	| result method |
	
	method := self
		newFFIMethodWithSignature: #( char* f ( ) )
		doing: [ 'test' ]
		options: #( optStringEncodingUtf8 optStringEncodingMandatory ).
	result := method valueWithReceiver: nil arguments: #( ).

	self assert: result equals: 'test'
]

{ #category : #tests }
FFIStringCalloutTest >> testStringReturnWithMandatoryEncodingWithoutExplicitEncodingShouldRaiseError [
	[self
		newFFIMethodWithSignature: #( char* f (void) )
		doing: [ 'asd' utf8Encoded ]
		options: #( optStringEncodingMandatory ).
	self fail]
		on: Error
		do: [ :error | self assert: error messageText equals: 'String encoding option not specified' ]
]

{ #category : #tests }
FFIStringCalloutTest >> testUtf8CalloutShouldReturnDecodeUtf8EncodedString [
	| return method |
	"The FFI backend returns a byte string instead of a byte array. We should gracefully transform it to byte array and decode it"
	method := self
		newFFIMethodWithSignature: #( char* f ( ) )
		doing: [ 	ByteString withAll: 'les élèves français' utf8Encoded ]
		options: #( optStringEncodingUtf8 ).
	return := method valueWithReceiver: nil arguments: #( ).
	
	self assert: return equals: 'les élèves français'
]

{ #category : #tests }
FFIStringCalloutTest >> testUtf8CalloutShouldSendUtf8EncodedLiteralStringArgument [
	| ffiInvocationArgument method |
	
	method := self
		newFFIMethodWithSignature: #( void f (char* 'string') )
		doing: [ :aString | ffiInvocationArgument := aString ]
		options: #( optStringEncodingUtf8 ).
	method valueWithReceiver: nil arguments: #( nil ).
	
	self assert: ffiInvocationArgument equals: ('string' nullTerminatedEncodeWith: #utf8)
]

{ #category : #tests }
FFIStringCalloutTest >> testUtf8CalloutShouldSendUtf8EncodedStringArgument [
	| ffiInvocationArgument method |
	
	method := self
		newFFIMethodWithSignature: #( void f (char* aString) )
		doing: [ :aString | ffiInvocationArgument := aString ]
		options: #( optStringEncodingUtf8 ).
	method valueWithReceiver: nil arguments: #( 'string' ).
	
	self assert: ffiInvocationArgument equals: ('string' nullTerminatedEncodeWith: #utf8)
]

{ #category : #tests }
FFIStringCalloutTest >> testUtf8EncodedStringShouldHaveNullTerminator [
	| ffiInvocationArgument method |
	
	method := self
		newFFIMethodWithSignature: #( void f (char* 'string') )
		doing: [ :aString | ffiInvocationArgument := aString ]
		options: #( optStringEncodingUtf8 ).
	method valueWithReceiver: nil arguments: #( nil ).
	
	self assert: ffiInvocationArgument utf8Decoded equals: 'string', Character null asString
]
