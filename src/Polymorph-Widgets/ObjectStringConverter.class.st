"
Generic object<->string converter for use with PluggableTextFieldMorph.
Optional regex matching for validation.
Optional transform blocks for each conversion direction.
"
Class {
	#name : #ObjectStringConverter,
	#superclass : #Object,
	#instVars : [
		'objectClass',
		'regex',
		'stringTransformBlock',
		'objectTransformBlock'
	],
	#category : #'Polymorph-Widgets-Utilities'
}

{ #category : #'instance creation' }
ObjectStringConverter class >> forClass: aClass [
	"Answer a new instance of the receiver that converts to and from
	the given class of object and a string."

	^self new objectClass: aClass
]

{ #category : #conversion }
ObjectStringConverter >> configureForIntegers [
	"Configure the receiver to match/convert positive or negative integers only."

	self
		objectClass: Integer;
		regexString: '[-]?[0-9]+';
		stringTransformBlock: [:s |
			(s beginsWith: '-')
				ifTrue: ['-', (s select: [:c | c isDigit])]
				ifFalse: [s select: [:c | c isDigit]]]
]

{ #category : #conversion }
ObjectStringConverter >> configureForPositiveIntegers [
	"Configure the receiver to match/convert positive integers only."

	self
		objectClass: Integer;
		regexString: '[0-9]+';
		stringTransformBlock: [:s |
			s select: [:c | c isDigit]]
]

{ #category : #initialization }
ObjectStringConverter >> initialize [
	"Initialize the receiver."

	super initialize.
	self
		objectTransformBlock: [:obj | obj];
		stringTransformBlock: [:string | string]
]

{ #category : #conversion }
ObjectStringConverter >> isStringValid: aString [
	"Answer whether the given string is valid for conversion."

	^(self regex isNil or: [self regex matches: aString]) and: [
		[self stringAsObject: aString. true] on: Error do: [false]]
]

{ #category : #conversion }
ObjectStringConverter >> needsConversion [
	"Answer whether conversion is required for the receiver's object class."

	^self objectClass notNil and: [(self objectClass includesBehavior: String) not]
]

{ #category : #conversion }
ObjectStringConverter >> objectAsString: anObject [
	"Answer the given object in string form."

	^(self objectTransformBlock value: anObject)
		ifNotNil: [:o | o asString]
]

{ #category : #accessing }
ObjectStringConverter >> objectClass [
	"Answer the class of object we are dealing with."

	^objectClass
]

{ #category : #accessing }
ObjectStringConverter >> objectClass: aClass [
	"Set the class of object we are dealing with."

	objectClass := aClass
]

{ #category : #accessing }
ObjectStringConverter >> objectTransformBlock [

	^ objectTransformBlock
]

{ #category : #accessing }
ObjectStringConverter >> objectTransformBlock: anObject [

	objectTransformBlock := anObject
]

{ #category : #accessing }
ObjectStringConverter >> regex [

	^ regex
]

{ #category : #accessing }
ObjectStringConverter >> regex: anObject [

	regex := anObject
]

{ #category : #accessing }
ObjectStringConverter >> regexString: aString [
	"Setup the regex based on the given string."

	self regex: aString asRegex
]

{ #category : #conversion }
ObjectStringConverter >> stringAsObject: aString [
	"Answer the given string in object form."

	|transformed|
	transformed := self stringTransformBlock value: aString asString.
	^(transformed notNil and: [self needsConversion])
		ifTrue: [self objectClass readFromString: transformed]
		ifFalse: [transformed]
]

{ #category : #accessing }
ObjectStringConverter >> stringTransformBlock [

	^ stringTransformBlock
]

{ #category : #accessing }
ObjectStringConverter >> stringTransformBlock: anObject [

	stringTransformBlock := anObject
]
