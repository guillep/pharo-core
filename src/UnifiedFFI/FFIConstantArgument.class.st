"
I am a function argument representing a literal value (in contrast to a variable).
The parser creates me when it finds other than symbols as arguments.

I am resolved by resolving my type.
The type knows how to resolve itself in a context.
"
Class {
	#name : #FFIConstantArgument,
	#superclass : #FFIFunctionArgument,
	#instVars : [
		'value'
	],
	#category : #'UnifiedFFI-Arguments'
}

{ #category : #'instance creation' }
FFIConstantArgument class >> value: aValue typeName: aTypeName arity: anInteger [
	
	^ self new
		value: aValue;
		type: (FFITypeDeclaration typeName: aTypeName arity: anInteger);
		yourself
]

{ #category : #converting }
FFIConstantArgument >> asOldArraySpec [

	^ {
		nil .
		nil .
		value isNumber
			ifTrue: [ value ]
			ifFalse: [ value asString ] .
		0 }
]

{ #category : #'emitting code' }
FFIConstantArgument >> emitArgument: aBuilder context: aContext objectClass: objectClass instVarName: aName [
	
	self shouldNotImplement
]

{ #category : #'private emitting code' }
FFIConstantArgument >> emitArgumentVariableAccesingPart: aBuilder context: aContext objectClass: objectClass instVarName: aName [

	self shouldNotImplement
]

{ #category : #resolving }
FFIConstantArgument >> initialize [

	super initialize.
	type := FFIUndefinedTypeDeclaration new.
]

{ #category : #resolving }
FFIConstantArgument >> resolveUsing: aResolver [

	value = false ifTrue: [ 
		loader := FFILiteralArgument value: 0 type: (aResolver resolveType: #bool).
		resolvedType := type resolveUsing: aResolver forArgument: self.
		resolvedType loader: loader.
		^ self ].
	value = true ifTrue: [ 
		loader := FFILiteralArgument value: 1 type: (aResolver resolveType: #bool).
		resolvedType := type resolveUsing: aResolver forArgument: self.
		resolvedType loader: loader.
		^ self ].
	(value isNil or: [ value = 'NULL' ]) ifTrue: [ 
		loader := FFILiteralArgument value: ExternalAddress null type: (aResolver resolveType: #'void *').
		resolvedType := type resolveUsing: aResolver forArgument: self.
		resolvedType loader: loader.
		^ self ].
	value == #self ifTrue: [
		loader := resolvedType := type resolveUsing: aResolver forArgument: self.
		loader loader: FFISelfArgument new.
		^ self ].
	loader := FFILiteralArgument value: value.
	resolvedType := type resolveUsing: aResolver forArgument: self.
	resolvedType loader: loader.
]

{ #category : #accessing }
FFIConstantArgument >> value [ 

	^ value
]

{ #category : #accessing }
FFIConstantArgument >> value: anObject [
	value := anObject
]
