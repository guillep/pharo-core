"
STONReaderTests test materialization.

"
Class {
	#name : #STONReaderTest,
	#superclass : #TestCase,
	#category : #'STON-Tests-Reader'
}

{ #category : #private }
STONReaderTest >> materialize: string [
	^ STON reader 
		on: string readStream;
		next
]

{ #category : #tests }
STONReaderTest >> testAssociation [
	self assert: (self materialize: '''foo'':1') equals: 'foo' -> 1.
	self assert: (self materialize: '#bar:2') equals: #bar -> 2.
	self assert: (self materialize: '''foo bar'':#ok') equals: 'foo bar' -> #ok.
	self assert: (self materialize: '123:456') equals: 123 -> 456.

	self assert: (self materialize: '''foo'' : 1') equals: 'foo' -> 1.
	self assert: (self materialize: '#bar : 2') equals: #bar -> 2.
	self assert: (self materialize: '''foo bar'' : #ok') equals: 'foo bar' -> #ok.
	self assert: (self materialize: '123 : -456') equals: 123 -> -456.

	self assert: (self materialize: '#foo : 1 : 2') equals: #foo -> (1 -> 2)
]

{ #category : #tests }
STONReaderTest >> testBag [
	self 
		assert: (self materialize: 'Bag{#a:2,#b:3}') 
		equals: (Bag withAll: #(a a b b b)).
	self 
		assert: (self materialize: 'Bag{}') 
		equals: Bag new.

]

{ #category : #tests }
STONReaderTest >> testBoolean [
	self assert: (self materialize: 'true') equals: true.
	self assert: (self materialize: 'false') equals: false
]

{ #category : #tests }
STONReaderTest >> testByteArray [
	self assert: (self materialize: 'ByteArray[''010203'']') equals: #(1 2 3) asByteArray
]

{ #category : #tests }
STONReaderTest >> testCharacter [
	self assert: (self materialize: 'Character[''A'']') identicalTo: $A
]

{ #category : #tests }
STONReaderTest >> testClass [
	self assert: (self materialize: 'Class[#Point]') equals: Point
]

{ #category : #tests }
STONReaderTest >> testClassWithUnderscore [

	| cls data reader |

	cls := Object newAnonymousSubclass.
	cls setName: #A_B_C123AnonClass.

	data := STON toString: cls new.
	reader := STONReader on: data readStream.

	(reader instVarNamed: #classes) 
		at: cls name 
		put: cls.

	self assert: reader next class equals: cls
]

{ #category : #tests }
STONReaderTest >> testColor [
	self 
		assert: (self materialize: 'Color[#red]')
		equals: Color red.
	self 
		assert: (self materialize: 'Color{#red:1.0,#green:0.0,#blue:0.0,#alpha:0.4}')
		equals: (Color red copy setAlpha: 0.4).
	self 
		assert: (self materialize: 'Color{#red:1.0,#green:0.061,#blue:0.061,#alpha:1.0}')
		equals: Color red lighter lighter.
]

{ #category : #tests }
STONReaderTest >> testColorBackwardsCompatibility [
	"ensure the older Color representation still works"
	self 
		assert: (self materialize: 'Color{#rgb:1072693248}')
		equals: Color red.
	self 
		assert: (self materialize: 'Color{#rgb:1072693248}')
		equals: (self materialize: 'Color[#red]').
]

{ #category : #tests }
STONReaderTest >> testConvertingNewLines [
	| input result output |
	input := '''line ending with CR', String cr, 
		'line ending with LF', String lf, 
		'line ending with CRLF', String crlf, ''''.
	output := 'line ending with CR', String crlf, 
		'line ending with LF', String crlf, 
		'line ending with CRLF', String crlf.
	result := (STON reader on: input readStream) newLine: String crlf; convertNewLines: true; next.
	self assert: result equals: output.
	output := 'line ending with CR', String cr, 
		'line ending with LF', String cr, 
		'line ending with CRLF', String cr.
	result := (STON reader on: input readStream) newLine: String cr; convertNewLines: true; next.
	self assert: result equals: output
]

{ #category : #tests }
STONReaderTest >> testDate [
	| date |
	date := (Date year: 2012 month: 1 day: 1) translateToUTC.
	self assert: (self materialize: 'Date[''2012-01-01Z'']') equals: date.
	self assert: (self materialize: 'Date[''2012-01-01+00:00'']') equals: date.
	date := (Date year: 2012 month: 1 day: 1) translateTo: 1 hour.
	self assert: (self materialize: 'Date[''2012-01-01+01:00'']') equals: date.
	"a missing timezone offset results in the local timezone offset being used,
	this is never written by STON, but matches the first implementation for backwards compatibility"
	date := Date year: 2012 month: 1 day: 1.
	self assert: (self materialize: 'Date[''2012-01-01'']') equals: date.
]

{ #category : #tests }
STONReaderTest >> testDateAndTime [
	| dateAndTime |
	dateAndTime := DateAndTime
		year: 2012
		month: 1
		day: 1
		hour: 6
		minute: 30
		second: 15
		offset: 1 hour.
	self assert: (self materialize: 'DateAndTime[''2012-01-01T06:30:15+01:00'']') equals: dateAndTime
]

{ #category : #tests }
STONReaderTest >> testDeepStructure [
	| holder deepest structure writer ston reader result |
	"Create a deep nested structure so that the deepest element is a reference back to a top level holder."
	holder := Array with: 42.
	deepest := Array with: holder.
	structure := deepest.
	1 * 1024 timesRepeat: [ structure := Array with: structure ].
	structure := Array with: holder with: structure.
	writer := STON writer optimizeForLargeStructures.
	ston := String streamContents: [ :out | (writer on: out) nextPut: structure ].
	"After reading, the second pass will have to go down the structure to resolve the reference."
	reader := STON reader optimizeForLargeStructures.
	result := (reader on: ston readStream) next.
	self assert: result equals: structure
]

{ #category : #tests }
STONReaderTest >> testDictionary [
	| collection |
	collection := STON mapClass new
		at: 1 put: 1;
		at: 2 put: 2;
		yourself.
	self assert: (self materialize: '{1:1,2:2}') equals: collection.
	self assert: (self materialize: '{}') equals: STON mapClass new
]

{ #category : #tests }
STONReaderTest >> testDictionaryWithComplexKeys [
	| collection reader |
	collection := STON mapClass new
		at: true put: 1;
		at: #(foo) put: 2;
		yourself.
	"allowing complex map keys used to be optional, now it is always the default"
	reader := STONReader on: '{true:1,[#foo]:2}' readStream.
	self assert: reader next equals: collection
]

{ #category : #tests }
STONReaderTest >> testDictionaryWithIndirectReferenceKeys [
	| keysCollection dictionary ston object |
	keysCollection := OrderedCollection streamContents: [ :out |
		10 timesRepeat: [ out nextPut: UUID new ] ].
	dictionary := Dictionary new.
	keysCollection doWithIndex: [ :each :index | 
		dictionary at: (Array with: each) put: index ].
	object := Array with: keysCollection with: dictionary.
	ston := STON toStringPretty: object.
	object := (STON reader on: ston readStream) next.
	object first doWithIndex: [ :each :index |
		self assert: (object second at: (Array with: each)) equals: index ].
	self assert: object second isHealthy 
]

{ #category : #tests }
STONReaderTest >> testDictionaryWithReferenceKeys [
	| keysCollection dictionary ston object |
	keysCollection := OrderedCollection streamContents: [ :out |
		10 timesRepeat: [ out nextPut: UUID new ] ].
	dictionary := Dictionary new.
	keysCollection doWithIndex: [ :each :index | 
		dictionary at: each put: index ].
	object := Array with: keysCollection with: dictionary.
	ston := STON toStringPretty: object.
	object := (STON reader on: ston readStream) next.
	object first doWithIndex: [ :each :index |
		self assert: (object second at: each) equals: index ].
	self assert: object second isHealthy 
]

{ #category : #tests }
STONReaderTest >> testDiskFile [
	self assert: (self materialize: 'FILE[''foo.txt'']') equals: 'foo.txt' asFileReference.
	self assert: (self materialize: 'FILE[''/tmp/foo.txt'']') equals: '/tmp/foo.txt' asFileReference.
	self assert: (self materialize: 'FILE[''tmp/foo.txt'']') equals: 'tmp/foo.txt' asFileReference.
	self assert: (self materialize: 'FILE[''/tmp'']') equals: '/tmp' asFileReference.
]

{ #category : #tests }
STONReaderTest >> testError [
	#( 'foo' '{foo:}' '{foo,}' '[1,]' '+1' ']' '#' '' '  ' '	' 'nul' 'tru' 'fals' ) do: [ :each |
		self 
			should: [ self materialize: each ] 
			raise: STONReaderError ]

]

{ #category : #tests }
STONReaderTest >> testFileReferenceBackwardsCompatibility [
	"we now have FILE, make sure that we support the old generic format"
	| fs |
	fs := STON toString: FileSystem disk.
	self 
		assert: (self materialize: 'FileReference{#path:RelativePath[],#filesystem:', fs, '}')
		equals: FileLocator workingDirectory.
	self 
		assert: (self materialize: 'FileReference{#path:RelativePath[],#filesystem:', fs, '}')
		equals: (self materialize: 'FILE[''.'']').
	self 
		assert: (self materialize: 'FileReference{#path:AbsolutePath[''tmp'',''foo.txt''],#filesystem:', fs, '}')
		equals: '/tmp/foo.txt' asFileReference.
	self 
		assert: (self materialize: 'FileReference{#path:AbsolutePath[''tmp'',''foo.txt''],#filesystem:', fs, '}')
		equals: (self materialize: 'FILE[''/tmp/foo.txt'']').
]

{ #category : #tests }
STONReaderTest >> testFloat [
	self assert: ((self materialize: '1.5') closeTo: 1.5).
	self assert: ((self materialize: '-1.5') closeTo: -1.5).
	self assert: (self materialize: '0.0') isZero.
	self assert: (Float pi closeTo: (self materialize: '3.14149')).
	self assert: (1/3 closeTo: (self materialize: '0.333333')).
	self assert: ((self materialize: '1.0e100') closeTo: (10 raisedTo: 100)).
	self assert: ((self materialize: '1.0e-100') closeTo: (10 raisedTo: -100)).
	self assert: ((self materialize: '-1.0e-100') closeTo: (10 raisedTo: -100) negated)
]

{ #category : #tests }
STONReaderTest >> testFraction [
	self assert: (self materialize: '1/3') equals: 1/3.
	self assert: (self materialize: '-1/3') equals: -1/3.
	self assert: (self materialize: '100/11') equals: 100/11.

]

{ #category : #tests }
STONReaderTest >> testIdentityDictionary [
	| collection |
	collection := IdentityDictionary new
		at: 1 put: 1;
		at: 2 put: 2;
		yourself.
	self assert: (self materialize: 'IdentityDictionary{1:1,2:2}') equals: collection.
	self assert: (self materialize: 'IdentityDictionary{}') equals: IdentityDictionary new
]

{ #category : #tests }
STONReaderTest >> testIllegalCharacterEscapes [
	self should: [ STON fromString: '''\a''' ] raise: STONReaderError.
	self should: [ STON fromString: '''\u''' ] raise: STONReaderError.
	self should: [ STON fromString: '''\u00''' ] raise: STONReaderError.
	self should: [ STON fromString: '''\u000''' ] raise: STONReaderError.
	self should: [ STON fromString: '''\*''' ] raise: STONReaderError
]

{ #category : #tests }
STONReaderTest >> testInteger [
	self assert: (self materialize: '1') equals: 1.
	self assert: (self materialize: '-1') equals: -1.
	self assert: (self materialize: '0') equals: 0.
	self assert: (self materialize: '1234567890') equals: 1234567890.
	self assert: (self materialize: '-1234567890') equals: -1234567890
]

{ #category : #tests }
STONReaderTest >> testJsonString [
	"Allow double quotes for backwards JSON compatibility"

	| string |
	self assert: (self materialize: '"foo"') equals: 'foo'.
	self assert: (self materialize: '"FOO"') equals: 'FOO'.
	self assert: (self materialize: '"\u00E9l\u00E8ve en Fran\u00E7ais"') equals: 'élève en Français'.
	string := String withAll: {$" . $' . $\ . Character tab . Character cr . Character lf . Character newPage . Character backspace}.
	self assert: (self materialize: '"\"\''\\\t\r\n\f\b"') equals: string
]

{ #category : #tests }
STONReaderTest >> testList [
	self assert: STON listClass equals: Array.
	self assert: (self materialize: '[1,2,3]') equals: (STON listClass with: 1 with: 2 with: 3).
	self assert: (self materialize: '[]') equals: STON listClass new
]

{ #category : #tests }
STONReaderTest >> testMap [
	self
		assert: (self materialize: '{#foo:1}')
		equals:
			(STON mapClass new
				at: #foo put: 1;
				yourself).
	self assert: (self materialize: '{}') equals: STON mapClass new
]

{ #category : #tests }
STONReaderTest >> testMetaclass [
	self assert: (self materialize: 'Metaclass[#Point]') equals: Point class
]

{ #category : #tests }
STONReaderTest >> testMimeType [
	self 
		assert: (self materialize: 'MimeType[''application/json'']') 
		equals: ZnMimeType applicationJson.
	self 
		assert: (self materialize: 'MimeType[''text/plain;charset=utf-8'']') 
		equals: ZnMimeType textPlain.
]

{ #category : #tests }
STONReaderTest >> testMultiple [
	| reader |
	reader := STON reader 
		on: '123 -123 nil #foo true [ 0 ] false { #one : 1 }' readStream.
	self deny: reader atEnd.
	self assert: reader next equals: 123. 
	self assert: reader next equals: -123. 
	self assert: reader next equals: nil. 
	self assert: reader next equals: #foo. 
	self assert: reader next equals: true. 
	self assert: reader next equals: { 0 }. 
	self assert: reader next equals: false. 
	self assert: reader next equals: (Dictionary with: #one -> 1). 
	self assert: reader atEnd.

]

{ #category : #tests }
STONReaderTest >> testNewSymbol [
	| n notASymbol shouldBeSymbol |
	
	"Find a name that has not yet been interned"
	n := 0.
	[ Symbol hasInterned: (notASymbol := 'notASymbol', n printString) ifTrue: [ :symbol | symbol ] ] 
		whileTrue: [ n := n + 1 ].
	"Parsing the new, not yet interned name should create a new Symbol"
	shouldBeSymbol := self materialize: '#', notASymbol.
	self assert: (shouldBeSymbol isSymbol and: [ notASymbol = shouldBeSymbol asString ])

]

{ #category : #tests }
STONReaderTest >> testNil [
	self assert: (self materialize: 'nil') isNil
]

{ #category : #tests }
STONReaderTest >> testNonBMPCharacterDecoding [
	"Characters not in the Basic Multilingual Plane are encoded as a UTF-16 surrogate pair"

	| string object |
	string := String with: 16r1D11E asCharacter. "MUSICAL SYMBOL G CLEF"
	object := (STON fromString: '''\uD834\uDD1E''').
	self assert: object equals: string
]

{ #category : #tests }
STONReaderTest >> testNull [
	self assert: (self materialize: 'null') isNil
]

{ #category : #tests }
STONReaderTest >> testObject [
	self assert: (self materialize: 'Point[1,2]') equals: 1 @ 2.
	self assert: (self materialize: 'Point[1.5,-0.5]') equals: 1.5 @ -0.5
]

{ #category : #tests }
STONReaderTest >> testOrderedCollection [
	| collection |
	collection := OrderedCollection with: 1 with: 2 with: 3.
	self assert: (self materialize: 'OrderedCollection[1,2,3]') equals: collection.
	self assert: (self materialize: 'OrderedCollection[]') equals: OrderedCollection new
]

{ #category : #tests }
STONReaderTest >> testPoint [
	self assert: (self materialize: 'Point[1,2]') equals: 1 @ 2
]

{ #category : #tests }
STONReaderTest >> testReferenceCycle [
	| array |
	array := self materialize: '[1,@1]'.
	self assert: array class equals: STON listClass.
	self assert: array size equals: 2.
	self assert: array first equals: 1.
	self assert: array second identicalTo: array
]

{ #category : #tests }
STONReaderTest >> testReferenceSharing [
	| one array |
	one := {#one}.
	array := self materialize: '[[#one],@2,@2]'.
	self assert: array equals: (STON listClass with: one with: one with: one).
	self assert: array first identicalTo: array second.
	self assert: array first identicalTo: array third
]

{ #category : #tests }
STONReaderTest >> testScaledDecimal [
	self assert: (self materialize: '1/3s2') equals: 1/3s2.
	self assert: (self materialize: '-1/3s2') equals: -1/3s2.
	self assert: (self materialize: '1/3s10') equals: 1/3s10.
	self assert: (self materialize: '-1/3s10') equals: -1/3s10.

]

{ #category : #tests }
STONReaderTest >> testSetWithIndirectReferenceElements [
	| elementsCollection set ston object |
	elementsCollection := OrderedCollection streamContents: [ :out |
		10 timesRepeat: [ out nextPut: UUID new ] ].
	set := Set withAll: (elementsCollection collect: [ :each | Array with: each ]).
	object := Array with: elementsCollection with: set.
	ston := STON toStringPretty: object.
	object := STON fromString: ston readStream.
	object first do: [ :each |
		self assert: (object second includes: (Array with: each)) ].
	self assert: object second isHealthy 
]

{ #category : #tests }
STONReaderTest >> testSetWithReferenceElements [
	| elementsCollection set ston object |
	elementsCollection := OrderedCollection streamContents: [ :out |
		10 timesRepeat: [ out nextPut: UUID new ] ].
	set := Set withAll: elementsCollection.
	object := Array with: elementsCollection with: set.
	ston := STON toStringPretty: object.
	object := STON fromString: ston readStream.
	object first do: [ :each |
		self assert: (object second includes: each) ].
	self assert: object second isHealthy 
]

{ #category : #tests }
STONReaderTest >> testStreaming [
	| reader |
	reader := STON reader 
		on: '1 2 3 4 5 6 7 8 9 10' readStream.
	self 
		assert: (Array streamContents: [ :stream |
			[ reader atEnd] whileFalse: [ 
				stream nextPut: reader next ] ]) sum
		equals: #(1 2 3 4 5 6 7 8 9 10) sum
]

{ #category : #tests }
STONReaderTest >> testString [
	| string |
	self assert: (self materialize: '''foo''') equals: 'foo'.
	self assert: (self materialize: '''FOO''') equals: 'FOO'.
	self assert: (self materialize: '''\u00E9l\u00E8ve en Fran\u00E7ais''') equals: 'élève en Français'.
	string := String withAll: {$" . $' . $\ . $/ . Character tab . Character cr . Character lf . Character newPage . Character backspace}.
	self assert: (self materialize: '''\"\''\\\/\t\r\n\f\b''') equals: string
]

{ #category : #tests }
STONReaderTest >> testSymbol [
	self assert: (self materialize: '#''foo''') identicalTo: #foo.
	self assert: (self materialize: '#foo') identicalTo: #foo
]

{ #category : #tests }
STONReaderTest >> testTime [
	| time |
	time := Time hour: 6 minute: 30 second: 15.
	self assert: (self materialize: 'Time[''06:30:15'']') equals: time.
	time := Time hour: 6 minute: 30 second: 15 nanoSecond: 123.
	self assert: (self materialize: 'Time[''06:30:15.000000123'']') equals: time.

]

{ #category : #tests }
STONReaderTest >> testURL [
	self 
		assert: (self materialize: 'URL[''https://pharo.org/files/pharo.png'']') 
		equals: 'https://pharo.org/files/pharo.png' asUrl.
	self 
		assert: (self materialize: 'URL[''mailto:sven@stfx.eu'']') 
		equals: 'mailto:sven@stfx.eu' asUrl.
	self 
		assert: (self materialize: 'URL[''file:///var/log/system.log'']') 
		equals: 'file:///var/log/system.log' asUrl.
	self 
		assert: (self materialize: 'URL[''scheme://user:password@host:123/var/log/system.log?foo=1&bar#frag'']') 
		equals: 'scheme://user:password@host:123/var/log/system.log?foo=1&bar#frag' asUrl.
]

{ #category : #tests }
STONReaderTest >> testUnknownClasses [
	| input object |
	input := 'FooBar { #foo : 1, #bar : true }'.
	self should: [ self materialize: input ] raise: STONReaderError.
	object := STON reader 
		acceptUnknownClasses: true; 
		on: input readStream; 
		next.
	self assert: object class equals: STON mapClass.
	self assert: (object at: #foo) equals: 1.
	self assert: (object at: #bar).
	self assert: (object at: STON classNameKey) equals: #FooBar
]

{ #category : #tests }
STONReaderTest >> testUser [
	| user |
	(user := STONTestUser new)
		username: 'john@foo.com';
		password: 'secret1'.
	self assert: (self materialize: 'STONTestUser{#username:''john@foo.com'',#password:''secret1'',#enabled:true}') equals: user
]

{ #category : #tests }
STONReaderTest >> testUser2 [
	| user |
	(user := STONTestUser2 new)
		username: 'john@foo.com';
		password: 'secret1'.
	self assert: (self materialize: 'STONTestUser2{#username:''john@foo.com'',#password:''secret1'',#enabled:true}') equals: user
]

{ #category : #tests }
STONReaderTest >> testWhitespace [
	| whitespace |
	whitespace := {Character space . Character tab . Character cr . Character lf}.
	self assert: (self materialize: whitespace , '123') equals: 123
]

{ #category : #tests }
STONReaderTest >> testWideSymbol [
	self assert: (self materialize: '#''яблоко''') identicalTo: #яблоко.
	self assert: (self materialize: '#яблоко') identicalTo: #яблоко
]

{ #category : #tests }
STONReaderTest >> testZnUrlBackwardsCompatibility [
	"We now have URL, make sure we still support the old format"
	self 
		assert: (self materialize: 'ZnUrl{#scheme:#https,#host:''pharo.org'',#segments:OrderedCollection[''files'', ''pharo.png'']}') 
		equals: 'https://pharo.org/files/pharo.png' asUrl.
	self 
		assert: (self materialize: 'ZnUrl{#scheme:#file,#segments:OrderedCollection[''tmp'', ''foo.txt'']}') 
		equals: 'file:///tmp/foo.txt' asUrl.
]
