"
I am the FFI backend implemented by using TFFI
"
Class {
	#name : #TFFIBackend,
	#superclass : #FFIBackend,
	#type : #bytes,
	#category : #'ThreadedFFI-Base'
}

{ #category : #detecting }
TFFIBackend class >> isAvailable [
	
	^ self new isAvailable 
]

{ #category : #accessing }
TFFIBackend class >> priority [

	^ 10
]

{ #category : #'instance creation' }
TFFIBackend >> allocate: byteSize [

	"Primitive. Allocate an object on the external heap."

	<primitive: 'primitiveFFIAllocate'>
	^ self primitiveFailed
]

{ #category : #'instance creation' }
TFFIBackend >> calloutAPIClass [
	
	^ TFCalloutAPI 
]

{ #category : #'instance creation' }
TFFIBackend >> free: anExternalAddress [

	<primitive:'primitiveFFIFree'>
	^self primitiveFailed
]

{ #category : #accessing }
TFFIBackend >> integerOfObject: anObject at: byteOffset put: value size: nBytes signed: aBoolean [
	"Primitive. Store the given value as integer of nBytes size
	in the receiver. Fail if the value is out of range.
	Note: This primitive will access memory in the outer space if
	invoked from ExternalAddress."
	<primitive: 'primitiveFFIIntegerAtPut'>
	^self primitiveFailed
]

{ #category : #accessing }
TFFIBackend >> integerOfObject: anObject at: byteOffset size: nBytes signed: aBoolean [
	"Primitive. Return an integer of nBytes size from the receiver.
	Note: This primitive will access memory in the outer space if
	invoked from ExternalAddress."
	<primitive: 'primitiveFFIIntegerAt'>
	^self primitiveFailed
]

{ #category : #testing }
TFFIBackend >> isAvailable [

	^ [ self loadSymbol: #primitiveLoadSymbolFromModule module: nil. true ] onErrorDo: [ false ]
]

{ #category : #'instance creation' }
TFFIBackend >> loadSymbol: moduleSymbol module: module [ 
	
	| encodedString |
	encodedString := module ifNotNil: [ module utf8Encoded asString ].
	
	"The primitive is expected the module to be a utf8Encoded String."
	^ self primLoadSymbol: moduleSymbol module: encodedString
]

{ #category : #accessing }
TFFIBackend >> on: anObject float32At: offset [

	^ self primitiveFailed
]

{ #category : #accessing }
TFFIBackend >> on: anObject float32At: offset put: value [

	value isFloat ifFalse: [ 
		^ anObject float32AtOffset: offset - 1 put: value asFloat ].

	self isReadOnlyObject ifTrue: [ 
		^ self
			  modificationForbiddenFor: #on:float32At:put:
			  index: offset
			  value: value ].

	^ self primitiveFailed
]

{ #category : #accessing }
TFFIBackend >> on: anObject float64At: offset [

	^ self primitiveFailed
]

{ #category : #accessing }
TFFIBackend >> on: anObject float64At: offset put: value [

	value isFloat ifFalse: [ 
		^ anObject float64AtOffset: offset - 1 put: value asFloat ].

	self isReadOnlyObject ifTrue: [ 
		^ self
			  modificationForbiddenFor: #on:float64At:put:
			  index: offset
			  value: value ].
		
	^ self primitiveFailed
]

{ #category : #'instance creation' }
TFFIBackend >> primLoadSymbol: moduleSymbol module: module [ 

	<primitive: 'primitiveLoadSymbolFromModule'>

	^ self primitiveFailed
]
