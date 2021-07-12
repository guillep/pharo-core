"
STONJSONTests contains unit tests for the JSON functionality available in STON.
"
Class {
	#name : #STONJSONTest,
	#superclass : #TestCase,
	#category : #'STON-Tests-Facade'
}

{ #category : #accessing }
STONJSONTest >> environment [
	^ Smalltalk globals
]

{ #category : #tests }
STONJSONTest >> testBooleans [
	self assert: (STONJSON toString: true) equals: 'true'.
	self assert: (STONJSON toString: false) equals: 'false'.
	self assert: (STONJSON fromString: 'true') equals: true.
	self assert: (STONJSON fromString: 'false') equals: false.
]

{ #category : #tests }
STONJSONTest >> testCircular [
	"Circular datastructures cannot be encoded using JSON"
	self
		should: [ | foo |
			foo := { 'foo'->'dummy' } asDictionary.
			foo at: 'bar' put: foo.
			STONJSON toString: foo ]
		raise: STONWriterError
]

{ #category : #tests }
STONJSONTest >> testFloats [
	self assert: (STONJSON toString: 1.0) equals: '1.0'.
	self assert: (STONJSON toString: 0.0) equals: '0.0'.
	self assert: (STONJSON toString: -1.0) equals: '-1.0'.
	self assert: (STONJSON toString: -1.23456e-6) equals: '-1.23456e-6'.
	self assert: ((STONJSON fromString: '1.0') closeTo: 1.0).
	self assert: ((STONJSON fromString: '0.0') closeTo: 0.0).
	self assert: ((STONJSON fromString: '-1.0') closeTo: -1.0).
	self assert: ((STONJSON fromString: '-1.23456e-6') closeTo: -1.23456e-6).
]

{ #category : #tests }
STONJSONTest >> testIntegers [
	self assert: (STONJSON toString: 1) equals: '1'.
	self assert: (STONJSON toString: 0) equals: '0'.
	self assert: (STONJSON toString: -1) equals: '-1'.
	self assert: (STONJSON toString: 1234567890) equals: '1234567890'.
	self assert: (STONJSON fromString: '1') equals: 1.
	self assert: (STONJSON fromString: '0') equals: 0.
	self assert: (STONJSON fromString: '-1') equals: -1.
	self assert: (STONJSON fromString: '1234567890') equals: 1234567890.
]

{ #category : #tests }
STONJSONTest >> testLists [
	self assert: (STONJSON toString: #(1 2 3)) equals: '[1,2,3]'.
	self assert: (STONJSON toString: #(1 -2 true 3 nil)) equals: '[1,-2,true,3,null]'.
	self assert: (STONJSON toString: #(1 (2) 3)) equals: '[1,[2],3]'.
	self assert: (STONJSON toString: #()) equals: '[]'.
	self assert: (STONJSON fromString: '[]') equals: #().
	self assert: (STONJSON fromString: '[1,2,3]') equals: #(1 2 3).
	self assert: (STONJSON fromString: '[1,-2,true,3,null]') equals: #(1 -2 true 3 nil).
	self assert: (STONJSON fromString: '[1,[2],3]') equals: #(1 (2) 3).
]

{ #category : #tests }
STONJSONTest >> testMaps [
	self assert: (STONJSON toString: { 'temperature'->37 } asDictionary) equals: '{"temperature":37}'.
	self assert: (STONJSON toString: Dictionary new) equals: '{}'.
	self assert: (STONJSON fromString: '{"temperature":37}') equals: { 'temperature'->37 } asDictionary.
	self assert: (STONJSON fromString: '{}') equals: Dictionary new.
]

{ #category : #tests }
STONJSONTest >> testNull [
	self assert: (STONJSON toString: nil) equals: 'null'.
	self assert: (STONJSON fromString: 'null') equals: nil.
]

{ #category : #tests }
STONJSONTest >> testOrderedDictionary [
	| odictClass odict json dict |
	odictClass := self environment at: #OrderedDictionary ifAbsent: [ ^ self skip ].

	odict := odictClass newFrom: {('a' -> 42) . ('b' -> 1) . ('aa' -> 4) . ('c' -> 23)}.

	"assert that the order is not equal in the dictionary hash table"
	self
		assertCollection: odict asArray hasSameElements: odict dictionary asArray;
		deny: odict asArray equals: odict dictionary asArray.

	"ordered presevered when encoding:"
	json := STONJSON toString: odict.
	self assert: json equals: '{"a":42,"b":1,"aa":4,"c":23}'.

	"lost when decoding"
	dict := STONJSON fromString: json.

	self
		assertCollection: dict asArray hasSameElements: odict asArray;
		assert: dict equals: odict dictionary;
		deny: dict asArray equals: odict asArray
]

{ #category : #tests }
STONJSONTest >> testShared [
	"Structure sharing cannot be encoded using JSON"
	self
		should: [ | foo |
			foo := { 'foo'->'dummy' } asDictionary.
			STONJSON toString: { foo. foo } ]
		raise: STONWriterError
]

{ #category : #tests }
STONJSONTest >> testStrings [
	self assert: (STONJSON toString: 'string') equals: '"string"'.
	self assert: (STONJSON toString: '') equals: '""'.
	self assert: (STONJSON toString: 'élèves français') equals: '"élèves français"'.
	self assert: (STONJSON toString: String crlf) equals: '"\r\n"'.
	self assert: (STONJSON fromString: '"string"') equals: 'string'.
	self assert: (STONJSON fromString: '""') equals: ''.
	self assert: (STONJSON fromString: '"élèves français"') equals: 'élèves français'.
	self 
		assert: (STONJSON fromString: '"\u212B \"Angstrom Symbol\""') 
		equals: 8491 asCharacter asString, ' "Angstrom Symbol"'.
]

{ #category : #tests }
STONJSONTest >> testUnknown [
	"Only Array for lists and Dictionary for maps are allowed for JSON encoding,
	any other Smalltalk object cannot be encoded (following the specs).
	Even considering all collections to be lists won't work because the type 
	is then lost when decoding"
	
	self should: [ STONJSON toString: 1@2 ] raise: STONWriterError.
	self should: [ STONJSON toString: #(1 2 3) asOrderedCollection ] raise: STONWriterError.
]
