"
A trait for test purposes
"
Trait {
	#name : #TAsStringCommaAndDelimiterTest,
	#category : #'Collections-Abstract-Tests-Traits'
}

{ #category : #requirements }
TAsStringCommaAndDelimiterTest >> empty [

	^ self explicitRequirement 
]

{ #category : #requirements }
TAsStringCommaAndDelimiterTest >> nonEmpty [

	^ self explicitRequirement 
]

{ #category : #requirements }
TAsStringCommaAndDelimiterTest >> nonEmpty1Element [
" return a collection of size 1 including one element"
	^ self explicitRequirement 
]

{ #category : #'tests - fixture' }
TAsStringCommaAndDelimiterTest >> test0FixtureAsStringCommaAndDelimiterTest [
	self nonEmpty.
	self denyEmpty: self nonEmpty.
	self empty.
	self assertEmpty: self empty.
	self nonEmpty1Element.
	self assert: self nonEmpty1Element size = 1
]

{ #category : #'tests - as string comma delimiter sequenceable' }
TAsStringCommaAndDelimiterTest >> testAsCommaStringEmpty [

	self assert: self empty asCommaString = ''.
	self assert: self empty asCommaStringAnd = ''.
	

]

{ #category : #'tests - as string comma delimiter sequenceable' }
TAsStringCommaAndDelimiterTest >> testAsCommaStringMore [

	| result resultAnd allElementsAsString tmp |
	result:= self nonEmpty asCommaString .
	resultAnd:= self nonEmpty asCommaStringAnd .
	tmp :=OrderedCollection new. 
	self nonEmpty do: [ :each | tmp add: each asString].

	"verifying result  :"
	allElementsAsString := (result findBetweenSubstrings: ', ' ).
	allElementsAsString do:
		[:each |
		self assert: (tmp occurrencesOf: each)=(allElementsAsString occurrencesOf: each).
		].
	
	"verifying esultAnd :"
	allElementsAsString:=(resultAnd findBetweenSubstrings: ', ' ).
	1 to: allElementsAsString size do:
		[:i | 
		i<(allElementsAsString size-1 ) | (i= allElementsAsString size)
			ifTrue: [self assert: (tmp occurrencesOf:(allElementsAsString at:i))=(allElementsAsString  occurrencesOf:(allElementsAsString at:i))].
		i=(allElementsAsString size-1)
			ifTrue:[ self assert: (allElementsAsString at:i)=('and')].
			].
]

{ #category : #'tests - as string comma delimiter sequenceable' }
TAsStringCommaAndDelimiterTest >> testAsCommaStringOne [
	
	self nonEmpty1Element do: 
		[:each | 
		self assert: each asString =self nonEmpty1Element  asCommaString.
		self assert: each asString=self nonEmpty1Element  asCommaStringAnd.].

	
]

{ #category : #'tests - as string comma delimiter sequenceable' }
TAsStringCommaAndDelimiterTest >> testAsStringOnDelimiterEmpty [
	self assert: (String streamContents: [ :emptyStream | self empty asStringOn: emptyStream delimiter: ', ' ]) equals: ''

]

{ #category : #'tests - as string comma delimiter sequenceable' }
TAsStringCommaAndDelimiterTest >> testAsStringOnDelimiterLastEmpty [
	self assert: (String streamContents: [ :emptyStream | self empty asStringOn: emptyStream delimiter: ', ' last: 'and' ]) equals: ''
]

{ #category : #'tests - as string comma delimiter sequenceable' }
TAsStringCommaAndDelimiterTest >> testAsStringOnDelimiterLastMore [

	| delim multiItemStream result last allElementsAsString |
	
	delim := ', '.
	last := ' and '.
	result:=''.
	multiItemStream := ReadWriteStream on:result.
	self nonEmpty asStringOn: multiItemStream delimiter: delim last: last.
	result := multiItemStream contents.
	allElementsAsString:=(result findBetweenSubstrings: delim ).
	self nonEmpty do:[:each |
		self assert: (self nonEmpty occurrencesOf: each) = (allElementsAsString occurrencesOf: each asString)].
	self assert: ((allElementsAsString at: (allElementsAsString size - 1))=('and'))
]

{ #category : #'tests - as string comma delimiter sequenceable' }
TAsStringCommaAndDelimiterTest >> testAsStringOnDelimiterLastOne [

	| delim oneItemStream result |
	
	delim := ', '.
	result:=''.
	oneItemStream := ReadWriteStream on: result.
	self nonEmpty1Element  asStringOn: oneItemStream delimiter: delim last: 'and'.
	oneItemStream  do:
		[:each1 |
		self nonEmpty1Element do: [:each2 |self assert: each1 = (each2 asString) ]
		 ].
	


]

{ #category : #'tests - as string comma delimiter sequenceable' }
TAsStringCommaAndDelimiterTest >> testAsStringOnDelimiterMore [

	| delim multiItemStream result allElementsAsString |
		
	delim := ', '.
	result:= ''.
	multiItemStream := ReadWriteStream on:result.
	self nonEmpty asStringOn: multiItemStream delimiter: delim.
	result := multiItemStream contents.
	allElementsAsString := (result findBetweenSubstrings: delim ).
	self nonEmpty do:
		[:each |
		self assert: (self nonEmpty occurrencesOf: each)=(allElementsAsString occurrencesOf: each asString).
		].
]

{ #category : #'tests - as string comma delimiter sequenceable' }
TAsStringCommaAndDelimiterTest >> testAsStringOnDelimiterOne [

	| delim oneItemStream result |

	delim := ', '.
	result:=''.
	oneItemStream := ReadWriteStream on: result.
	self nonEmpty1Element  asStringOn: oneItemStream delimiter: delim.
	oneItemStream  do:
		[:each1 |
		self nonEmpty1Element do: [:each2 |self assert: each1 = (each2 asString) ]
		 ].
	

]
