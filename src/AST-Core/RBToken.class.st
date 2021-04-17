"
RBToken is the abstract superclass of all of the RB tokens. These tokens (unlike the standard parser's) remember where they came from in the original source code.

Subclasses must implement the following messages:
	accessing
		length

Instance Variables:
	sourcePointer	<Integer>	The position in the original source code where this token began.

"
Class {
	#name : #RBToken,
	#superclass : #Object,
	#instVars : [
		'sourcePointer',
		'comments'
	],
	#category : #'AST-Core-Tokens'
}

{ #category : #testing }
RBToken class >> isAbstract [

	^ self == RBToken
]

{ #category : #'instance creation' }
RBToken class >> start: anInterval [ 
	^self new start: anInterval
]

{ #category : #accessing }
RBToken >> comments [
	^comments
]

{ #category : #accessing }
RBToken >> comments: anObject [
	comments := anObject
]

{ #category : #testing }
RBToken >> isAssignment [
	^false
]

{ #category : #testing }
RBToken >> isBinary [
	^false
]

{ #category : #testing }
RBToken >> isComment [
	^false
]

{ #category : #testing }
RBToken >> isEOF [
	^false
]

{ #category : #testing }
RBToken >> isError [
	^false
]

{ #category : #testing }
RBToken >> isIdentifier [
	^false
]

{ #category : #testing }
RBToken >> isKeyword [
	^false
]

{ #category : #testing }
RBToken >> isKeywordPattern [
	^ false
]

{ #category : #testing }
RBToken >> isLiteralArrayToken [
	^false
]

{ #category : #testing }
RBToken >> isLiteralToken [
	^false
]

{ #category : #testing }
RBToken >> isNumberLiteralToken [
	^false
]

{ #category : #testing }
RBToken >> isPatternBlock [
	^false
]

{ #category : #testing }
RBToken >> isPatternVariable [
	^false
]

{ #category : #testing }
RBToken >> isPrimitiveKeyword [
	^ false
]

{ #category : #testing }
RBToken >> isSpecial [
	^false
]

{ #category : #accessing }
RBToken >> length [
	^self subclassResponsibility
]

{ #category : #printing }
RBToken >> printOn: aStream [ 
	aStream
		nextPut: $ ;
		nextPutAll: self class name
]

{ #category : #accessing }
RBToken >> removePositions [
	sourcePointer := nil
]

{ #category : #accessing }
RBToken >> start [
	^ sourcePointer ifNil: [ 0 ]
]

{ #category : #initialization }
RBToken >> start: anInteger [ 
	sourcePointer := anInteger
]

{ #category : #accessing }
RBToken >> stop [
	^ sourcePointer 
		ifNil: [ -1 ]
		ifNotNil: [ self start + self length - 1 ]
]
