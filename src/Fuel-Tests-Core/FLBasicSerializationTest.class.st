"
SUnit tests for basic fuel serialization
"
Class {
	#name : #FLBasicSerializationTest,
	#superclass : #FLSerializationTest,
	#instVars : [
		'currentTimeZone'
	],
	#category : #'Fuel-Tests-Core-Base'
}

{ #category : #testing }
FLBasicSerializationTest class >> shouldInheritSelectors [ 
	^true
]

{ #category : #failures }
FLBasicSerializationTest >> expectedFailures [
	^ #(testConsiderCustomWideSymbolGlobal testWideStringGlobal testWideStringClassName)
]

{ #category : #running }
FLBasicSerializationTest >> setUp [
	super setUp.
	currentTimeZone := DateAndTime localTimeZone.
]

{ #category : #running }
FLBasicSerializationTest >> tearDown [
	DateAndTime localTimeZone: currentTimeZone.
	super tearDown
]

{ #category : #'tests-numbers' }
FLBasicSerializationTest >> testAllRangeOfIntegers [

	1 to: 100 do: [:shift |
		self assertSerializationEqualityOrIdentityOf: 1 << shift.
		self assertSerializationEqualityOrIdentityOf: 0 - (1 << shift) ]

]

{ #category : #'tests-collections' }
FLBasicSerializationTest >> testArray [
	self assertSerializationEqualityOf: #(1).
	self assertSerializationEqualityOf: #(10 20).
	self assertSerializationEqualityOf: #(1 2 3 #('Hello' 2 3)).
	


]

{ #category : #tests }
FLBasicSerializationTest >> testAssociation [

	self assertSerializationEqualityOf: 1-> 'marino'.
	self assertSerializationEqualityOf: nil-> 'marino'.
	self assertSerializationEqualityOf: nil-> nil.
	self assertSerializationEqualityOf: nil-> #(1 3 4).
	self assertSerializationEqualityOf: nil-> true.
]

{ #category : #'tests-collections' }
FLBasicSerializationTest >> testBag [
	| bag materialized |
	bag := Bag new.
	bag add: 10.
	bag add: 20.
	bag add: 30.
	bag add: 30.

	materialized := self resultOfSerializeAndMaterialize: bag.
	self assert: bag ~~ materialized.
	self assert: bag equals: materialized.
	self assert: materialized size equals: 4
]

{ #category : #'tests-collections' }
FLBasicSerializationTest >> testBitmap [
	| bitmap materialized |
	self assertSerializationEqualityOf: (Bitmap with: 0 with: 16rFFFFFFFF).
	self assertSerializationEqualityOf: (Bitmap with: 4278190080).
	self assertSerializationEqualityOf: (Bitmap new: 4096).
	self assertSerializationEqualityOf: (Bitmap with: 0 with: 4294967295).
	self assertSerializationEqualityOf: (Bitmap new: 256).
	self assertSerializationEqualityOf: (Bitmap with: 0).
	bitmap := Bitmap new: 3.
	bitmap at: 1 put: 4324.
	bitmap at: 2 put: 5674.
	bitmap at: 3 put: 8978.
	materialized := self resultOfSerializeAndMaterialize: bitmap.
	self assert: (materialized at: 1) equals: 4324.
	self assert: (materialized at: 2) equals: 5674.
	self assert: (materialized at: 3) equals: 8978
]

{ #category : #'tests-collections' }
FLBasicSerializationTest >> testByteArrays [

	self assertSerializationEqualityOf: { #[1 2 3 4 5 6]. #[1 2 3 4 5 6]. #[7 8 9 10 11 12]. #[7 8 9 10 11 12] }.
	self assertSerializationEqualityOf:  (ByteArray with: 10 with: 20 with: 30).
	self assertSerializationEqualityOf: ByteArray new.
	self assertSerializationEqualityOf: (ByteArray new: 100).
	self assertSerializationEqualityOf: (0 to: 255) asByteArray.
]

{ #category : #tests }
FLBasicSerializationTest >> testCharacter [
	"Test character serialization. If the code is less than 255 the same instance is used. But if it is bigger, new ones are created. For more info read Character class comment and Character class >> value:"

	self assertSerializationIdentityOf: $a.
	
	FLPlatform current isSpur 
		ifTrue: [
			self assertSerializationIdentityOf: (Character value: 12345). "Japanese Hiragana 'A' " ]
		ifFalse: [
			self assertSerializationEqualityOf: (Character value: 12345). "Japanese Hiragana 'A' " ].
		
	self assertSerializationEqualityOf: Character allCharacters.
	self assertSerializationEqualityOf: (Array with: $a with: (Character value: 12345)).
]

{ #category : #'tests-globals' }
FLBasicSerializationTest >> testClassSideCompiledMethod [
	"They should be considered as globals by default."
	
	self assertSerializationIdentityOf: FLGlobalSendMock class >> #newInstanceToSerialize

]

{ #category : #'tests-collections-Pharo1.3' }
FLBasicSerializationTest >> testCollectionElement [
	(Smalltalk classNamed: #CollectionElement) ifNil: [ self skip ].
	
	self assertSerializationEqualityOf: ((Smalltalk classNamed: #CollectionElement) with: 3)
]

{ #category : #tests }
FLBasicSerializationTest >> testColor [

	self assertSerializationEqualityOf: Color blue.
	self assertSerializationEqualityOf: Color black.
	
]

{ #category : #'tests-collections' }
FLBasicSerializationTest >> testColorArray [

	self assertSerializationEqualityOf: (ColorArray with: (Color r: 0.0 g: 0.031 b: 0.008) with: (Color r: 0.0 g: 0.07 b: 0.023))
]

{ #category : #'tests-globals' }
FLBasicSerializationTest >> testCompiledMethod [
	"They should be considered as globals by default."
	
	self assertSerializationIdentityOf: FLPair >> #left

]

{ #category : #'tests-globals' }
FLBasicSerializationTest >> testConsiderCustomGlobal [
	"A custom global variable is treated as global by Fuel, when we explicitly specify this."
	
	| aPerson globalKey |
	
	globalKey := #FLGlobalVariableForTesting.
	self analyzer considerGlobal: globalKey.

	aPerson := FLPerson new.
	[ 
		testingEnvironment at: globalKey put: aPerson.
		self assertSerializationIdentityOf: aPerson.
	] ensure: [ testingEnvironment removeKey: globalKey ]

]

{ #category : #'tests-globals' }
FLBasicSerializationTest >> testConsiderCustomWideSymbolGlobal [
	"The same than #testConsiderCustomGlobal but with a WideSymbol."
	
	| aWideSymbol aPerson |
	aWideSymbol := (WideString streamContents: [ :stream |
		256 to: 280 do: [ :code | stream nextPut: code asCharacter ] ]) asSymbol.

	self analyzer considerGlobal: aWideSymbol.

	aPerson := FLPerson new.	
	[ 
		testingEnvironment at: aWideSymbol put: aPerson.
		self
			shouldnt: [ self resultOfSerializeAndMaterialize: aPerson ]
			raise: Error
	] ensure: [ 
		testingEnvironment removeKey: aWideSymbol ].

]

{ #category : #'tests-cycles' }
FLBasicSerializationTest >> testCyclicIdentitySet [

	| aSet materializedSet |
	aSet := IdentitySet new.
	aSet add: aSet.
	
	materializedSet := self resultOfSerializeAndMaterialize: aSet.
	self assert: aSet ~~ materializedSet .
	self assert: (materializedSet includes: materializedSet) description: 'The materialized set has to include himself. Note aSet = materializedSet is false, bacause equality implementation checks that materializedSet *identity-includes* each element of aSet, which is false.'
]

{ #category : #'tests-cycles' }
FLBasicSerializationTest >> testCyclicLink [
	| a materializedA |
	a := Link new.
	a nextLink: a.

	materializedA := self resultOfSerializeAndMaterialize: a.

	"We can't check using the equality of the links because hangs ad infinitum. So we only check that the structure is right."
	self assert: materializedA nextLink identicalTo: materializedA
]

{ #category : #'tests-cycles' }
FLBasicSerializationTest >> testCyclicLinks [
	| a b c materializedA |
	a := Link new.
	b := Link new.
	c := Link new.

	a nextLink: b.
	b nextLink: c.
	c nextLink: a.

	materializedA := self resultOfSerializeAndMaterialize: a.

	"We can't check using the equality of the links because hangs ad infinitum. So we only check that the structure is right."
	self assert: materializedA nextLink nextLink nextLink identicalTo: materializedA.
	self deny: materializedA nextLink identicalTo: materializedA.
	self deny: materializedA nextLink nextLink identicalTo: materializedA
]

{ #category : #'tests-cycles' }
FLBasicSerializationTest >> testCyclicLinksInArray [
	| a b c materializedA materialized |
	a := Link new.
	b := Link new.
	c := Link new.

	a nextLink: b.
	b nextLink: c.
	c nextLink: a.

	materialized := self resultOfSerializeAndMaterialize: (Array with: a with: b with: c).
	materializedA := materialized first.

	"We can't check using the equality of the links because hangs ad infinitum. So we only check that the structure is right."
	self assert: materialized size equals: 3.
	self assert: materializedA nextLink nextLink nextLink identicalTo: materializedA.
	self deny: materializedA nextLink identicalTo: materializedA.
	self deny: materializedA nextLink nextLink identicalTo: materializedA
]

{ #category : #tests }
FLBasicSerializationTest >> testDate [

	self assertSerializationEqualityOf: (Date fromDays: 37023).
	self assertSerializationEqualityOf: (Date today).
	self assertSerializationEqualityOf: (Date year: 3050 month: 12 day: 31).
	self assertSerializationEqualityOf: (Date year: 1600 month: 12 day: 31).
	 
	
	
	
	
]

{ #category : #tests }
FLBasicSerializationTest >> testDateAndTime [

	| initialTime initialDate |
	initialTime := Time fromSeconds: 76020.
	initialDate := Date fromSeconds: 3492288000.
	self assertSerializationEqualityOf:
		(DateAndTime date: initialDate time: initialTime).

	initialTime := Time hour: 0 minute: 0 second: 0.
	initialDate := Date year: 3050 month: 12 day: 31.
	self assertSerializationEqualityOf:
		(DateAndTime date: initialDate time: initialTime).

	initialTime := Time hour: 0 minute: 0 second: 0.
	initialDate := Date year: 1600 month: 12 day: 31.
	self assertSerializationEqualityOf:
		(DateAndTime date: initialDate time: initialTime)
]

{ #category : #tests }
FLBasicSerializationTest >> testDateAndTimeOffsetNegative [
	| edt now |
	edt := TimeZone timeZones last.
	
	DateAndTime localTimeZone: edt.
	now := DateAndTime now.
	self assert: now offset equals: -4 hours.
	self serialize: now.

	self assert: self materialized offset equals: -4 hours
]

{ #category : #tests }
FLBasicSerializationTest >> testDateOffsets [
	| bst sast materialized object |
	bst := TimeZone timeZones third.
	sast := TimeZone timeZones fourth.
	
	DateAndTime localTimeZone: bst.
	self assert: DateAndTime now offset equals: 1 hour.
	object := Date fromDays: 37023.
	self assert: object start offset equals: 0 hours.
	materialized := self resultOfSerializeAndMaterialize: object.
	self assert: materialized start offset equals: 0 hours.
	
	DateAndTime localTimeZone: sast.
	self assert: DateAndTime now offset equals: 2 hours.
	object := Date fromDays: 37023.
	self assert: object start offset equals: 0 hours.
	materialized := self resultOfSerializeAndMaterialize: object.
	self assert: materialized start offset equals: 0 hours
	
]

{ #category : #tests }
FLBasicSerializationTest >> testDateOffsetsChanging [
	| bst sast object |
	bst := TimeZone timeZones third.
	sast := TimeZone timeZones fourth.
	
	DateAndTime localTimeZone: bst.
	self assert: DateAndTime now offset equals: 1 hour.
	object := Date fromDays: 37023.
	self assert: object start offset equals: 0 hours.
	self serialize: object.
	
	DateAndTime localTimeZone: sast.
	self assert: DateAndTime now offset equals: 2 hours.
	object := Date fromDays: 37023.
	self assert: object start offset equals: 0 hours.
	self assert: self materialized start offset equals: 0 hours
	
]

{ #category : #'tests-collections' }
FLBasicSerializationTest >> testDictionary [

	self assertSerializationEqualityOf: (Dictionary with: 1->2).
]

{ #category : #'tests-globals' }
FLBasicSerializationTest >> testDontConsiderCustomGlobal [
	"A custom global variable is not treated as global by Fuel, unless we explicitly specify this."

	| aPerson globalName |
	aPerson := FLPerson new.
	globalName := #FLGlobalVariableForTesting.

	[ testingEnvironment at: globalName put: aPerson.
	self deny: (self resultOfSerializeAndMaterialize: aPerson) identicalTo: aPerson ]
		ensure: [ testingEnvironment removeKey: globalName ]
]

{ #category : #tests }
FLBasicSerializationTest >> testDuration [
	
	self assertSerializationEqualityOf: 123 seconds.
	self assertSerializationEqualityOf: -123 seconds.
	self assertSerializationEqualityOf: (
		Duration 
			seconds: 3 
			nanoSeconds: 35).
	

]

{ #category : #'tests-collections' }
FLBasicSerializationTest >> testEmptyArray [
	self assertSerializationEqualityOf: #()
]

{ #category : #'tests-collections' }
FLBasicSerializationTest >> testEmptyDictionary [

	self assertSerializationEqualityOf: Dictionary new
]

{ #category : #'tests-collections' }
FLBasicSerializationTest >> testEmptyOrderedCollection [

	self assertSerializationEqualityOf: OrderedCollection new
]

{ #category : #'tests-collections' }
FLBasicSerializationTest >> testEmptySet [

	self assertSerializationEqualityOf: Set new
]

{ #category : #tests }
FLBasicSerializationTest >> testExceptions [
	| ex |
	ex := (Error new messageText: 'sample error').
	self assert: (self resultOfSerializeAndMaterialize: ex) messageText equals: ex messageText.
	
	ex := (Warning new messageText: 'sample warning').
	self assert: (self resultOfSerializeAndMaterialize: ex) messageText equals: ex messageText.
	
	ex := (Notification new messageText: 'sample notification').
	self assert: (self resultOfSerializeAndMaterialize: ex) messageText equals: ex messageText.
	

]

{ #category : #'tests-fuelAfterMaterialization' }
FLBasicSerializationTest >> testExecuteAfterMaterialization [
	| anObject result aClass |
	aClass := self newClass
		addInstVarNamed: 'a';
		duringTestCompileSilently: 'fuelAfterMaterialization a := #A';
		yourself.
	anObject := aClass new.

	result := self resultOfSerializeAndMaterialize: anObject.

	self assert: #A equals: (result instVarNamed: 'a')
]

{ #category : #tests }
FLBasicSerializationTest >> testFalse [

	self assertSerializationIdentityOf: false
]

{ #category : #'tests-numbers' }
FLBasicSerializationTest >> testFloat [
	{180.0.
	0.0.
	-0.0.
	11.22321.
	-11.22321.
	-132311.22321.
	1234567890.123456789.
	-1234567890.123456789.
	Float e.
	Float infinity.
	Float halfPi.
	Float negativeZero.
	Float halfPi.
	Float pi} 
		do: [ :aFloat | self assertSerializationEqualityOrIdentityOf: aFloat ]
]

{ #category : #tests }
FLBasicSerializationTest >> testFraction [

	self assertSerializationEqualityOf: (3 / 4).
	self assertSerializationEqualityOf: (4 / 3).
	self assertSerializationEqualityOf: (-4 / 3).
	self assertSerializationEqualityOf: (-4 / -3).
	self assertSerializationEqualityOf: (4 / -3).	
	self assertSerializationIdentityOf: (0-0 / -3).	
	self assertSerializationEqualityOf: 0-(1001/1000).	



]

{ #category : #'tests-graph-modification' }
FLBasicSerializationTest >> testFuelReplacement [
	| object |
	self 
		assert: (self resultOfSerializeAndMaterialize: FLReplacementClassMock)
		equals: nil.
		
	self
		assert: (self resultOfSerializeAndMaterialize: {FLReplacementClassMock})
		equals: { nil }.

	object := FLReplacementMock new
		ignoreMe;
		yourself.
	self 
		assert: (self resultOfSerializeAndMaterialize: {object})
		equals: { nil }.
		
	object dontIgnoreMe.
	self 
		assert: (self resultOfSerializeAndMaterialize: {object})
		equals: { object }
]

{ #category : #'tests-globals' }
FLBasicSerializationTest >> testGlobalClass [
	"A class should be global by default."
	
	self assertSerializationIdentityOf: Integer.

]

{ #category : #'tests-globals' }
FLBasicSerializationTest >> testGlobalMetaclass [
	"A metaclass should be global by default."
	
	self assertSerializationIdentityOf: Integer class.

]

{ #category : #'tests-not-so-basic' }
FLBasicSerializationTest >> testGradientFillStyle [

	self assertSerializationEqualityOf: GradientFillStyle sample
]

{ #category : #'tests-collections' }
FLBasicSerializationTest >> testInterval [

	self assertSerializationEqualityOf: (-10 to: 10 by: 5).
	self assertSerializationEqualityOf: (-0 to: 0 by: 1).
	self assertSerializationEqualityOf: (1 to: 10 by: 2).
	self assertSerializationEqualityOf: (33333333333333331 to: 1444444444444444440 by: 2).
	self assertSerializationEqualityOf: (0 to: 1 by: 2).
	
]

{ #category : #'tests-numbers' }
FLBasicSerializationTest >> testLargeNegativeInteger [

	self assertSerializationEqualityOf: -354314316134313999999999.
	self assertSerializationEqualityOf: 0-100 factorial.
]

{ #category : #'tests-numbers' }
FLBasicSerializationTest >> testLargePositiveInteger [

	self assertSerializationEqualityOf: 354314316134313999999999.
	self assertSerializationEqualityOf: 100 factorial.
	
]

{ #category : #tests }
FLBasicSerializationTest >> testLotsOfCharacters [

	| all |
	all := OrderedCollection new.
	(1 << 16) timesRepeat: [
	all add: (1 to: 255 ) atRandom asCharacter ].
	self assertSerializationEqualityOf: all.
]

{ #category : #tests }
FLBasicSerializationTest >> testLotsOfNils [

	self assertSerializationEqualityOf: (Array new: 1 << 16).
]

{ #category : #'tests-collections' }
FLBasicSerializationTest >> testMethodDictionary [
	self resultOfSerializeAndMaterializeMethodDictionary: FLPair methodDict.
	
]

{ #category : #'tests-collections' }
FLBasicSerializationTest >> testNestedDictionary [

	| childDic dic |
	childDic := Dictionary new.
	childDic at: #child1 put: 'abcde'.
	dic := Dictionary new.
	dic at: #parent1 put: 'sample string.'.
	dic at: #parent2 put: 100.
	dic at: #parent3 put: #(10 20 30 ).
	dic at: #parent4 put: childDic.
	
	self assertSerializationEqualityOf: childDic.
	self assertSerializationEqualityOf: dic.
]

{ #category : #tests }
FLBasicSerializationTest >> testNil [

	self assertSerializationIdentityOf: nil
]

{ #category : #'tests-not-so-basic' }
FLBasicSerializationTest >> testNotSerializableObject [

	self 
		should: [ self serialize: FLNotSerializableMock new ] 
		raise: FLNotSerializable
		whoseDescriptionIncludes: FLNotSerializableMock new printString
		description: 'User can prevent some objects from serialization.'
]

{ #category : #'tests-collections' }
FLBasicSerializationTest >> testOrderedCollection [

	self assertSerializationEqualityOf: (OrderedCollection with: 10 with: 20)
]

{ #category : #tests }
FLBasicSerializationTest >> testPair [

	self assertSerializationEqualityOf:
			(FLPair new
				left: 10;
				right: 20;
				yourself)
]

{ #category : #tests }
FLBasicSerializationTest >> testPoint [

	self assertSerializationEqualityOf: 10@20.
	self assertSerializationEqualityOf: -10@20.
	self assertSerializationEqualityOf: -10@ -20.
	self assertSerializationEqualityOf: 1.1@2.2.
	self assertSerializationEqualityOf: 1.1@ -2.2.
	
]

{ #category : #'tests-streams' }
FLBasicSerializationTest >> testReadStream [
	| aReadStream materialized |
	aReadStream := ReadStream on: 'A'.

	materialized := self resultOfSerializeAndMaterialize: aReadStream.

	self assert: $A equals: aReadStream next.

	self deny: materialized atEnd.
	self assert: $A equals: materialized next.
	self assert: materialized atEnd
]

{ #category : #tests }
FLBasicSerializationTest >> testRectangle [
	
	self assertSerializationEqualityOf: (10@20 corner: 30@40).
	self assertSerializationEqualityOf: (1.1@2.2 corner: 3.3@4.4).
	self assertSerializationEqualityOf: (1.1@ -2.2 corner: -3.3@4.4).
]

{ #category : #'tests-cycles' }
FLBasicSerializationTest >> testRecursiveArray [
	| arr materialized |
	arr := Array new: 3.
	arr at: 1 put: 10.
	arr at: 2 put: 20.
	arr at: 3 put: arr.

	materialized := self resultOfSerializeAndMaterialize: arr.

	"We can't check using the equality of the links because hangs ad infinitum. So we only check that the structure is right."
	self assert: materialized first equals: 10.
	self assert: materialized second equals: 20.
	self assert: materialized third identicalTo: materialized
]

{ #category : #'tests-strings' }
FLBasicSerializationTest >> testRemoteString [
	"Tests that the materialized RemoteString has *the same* location on file."

	| aRemoteString materializedRemoteString |
	aRemoteString := SourceFiles remoteStringAt: thisContext method sourcePointer.

	materializedRemoteString := self resultOfSerializeAndMaterialize: aRemoteString.

	self assert: aRemoteString string equals: materializedRemoteString string.
	self assert: aRemoteString sourcePointer identicalTo: materializedRemoteString sourcePointer
]

{ #category : #'tests-collections' }
FLBasicSerializationTest >> testRunArray [

	self assertSerializationEqualityOf: (RunArray runs: #(1 2 1) values: #(1 2 3))

]

{ #category : #'tests-numbers' }
FLBasicSerializationTest >> testScaledDecimal [

	self assertSerializationEqualityOf: (13/11s6).
	self assertSerializationEqualityOf: (-13/11s6).
	self assertSerializationEqualityOf: (7621476292473147/9007199254740992s8).
	self assertSerializationEqualityOf: (-7621476292473147/9007199254740992s8).
	self assertSerializationEqualityOf: (-0/9007199254740992s8).
	self assertSerializationEqualityOf: ((13 / 11) asScaledDecimal: 6).
	self assertSerializationEqualityOf: ((11 / 13) asFloat asScaledDecimal).

]

{ #category : #'tests-collections' }
FLBasicSerializationTest >> testSet [
	| set materialized |
	set := Set new.
	set add: 10.
	set add: 20.
	set add: 30.
	set add: 30.

	materialized := self resultOfSerializeAndMaterialize: set.
	self assert: set equals: materialized.
	self assert: materialized size equals: 3.
	self assert: (materialized includes: 10).
	self assert: (materialized includes: 20).
	self assert: (materialized includes: 30)
]

{ #category : #'tests-collections-Pharo1.3' }
FLBasicSerializationTest >> testSetWithCollectionElement [
	(Smalltalk classNamed: #CollectionElement) ifNil: [ self skip ].
	
	self assertSerializationEqualityOf: (Set with: ((Smalltalk classNamed: #CollectionElement) with: 3))
]

{ #category : #'tests-collections-Pharo1.3' }
FLBasicSerializationTest >> testSetWithNil [

	self assertSerializationEqualityOf: (Set with: nil)
]

{ #category : #tests }
FLBasicSerializationTest >> testSharedReferences [
	| sharedObject point1 point2 materialized array |
	sharedObject := SmallInteger maxVal + 1.
	point1 := Point x: sharedObject y: SmallInteger maxVal + 2.
	point2 := Point x: SmallInteger maxVal + 2 y: sharedObject.
	array := Array with: point1 with: point2.

	materialized := self resultOfSerializeAndMaterialize: array.
	self assert: array equals: materialized.
	self
		assert: materialized first x == materialized second y
		description: 'An object that is referenced twice by the graph must not be duplicated when materialized'.
	self deny: materialized first y == materialized second x description: 'Two (non-literal) objects must maintain different identity even if they are equal'
]

{ #category : #'tests-numbers' }
FLBasicSerializationTest >> testSmallInteger [

	self assertSerializationIdentityOf: -1212.
	self assertSerializationIdentityOf: 7.
	self assertSerializationIdentityOf: 0.
	self assertSerializationIdentityOf: 1111.
	self assertSerializationIdentityOf: SmallInteger one.


]

{ #category : #'tests-numbers' }
FLBasicSerializationTest >> testSmallIntegerMaxValue [

	self assertSerializationIdentityOf: SmallInteger maxVal .
	
]

{ #category : #'tests-numbers' }
FLBasicSerializationTest >> testSmallIntegerMinValue [

	self assertSerializationIdentityOf: SmallInteger minVal 
]

{ #category : #'tests-numbers' }
FLBasicSerializationTest >> testSmallIntegerNegative [

	self assertSerializationIdentityOf: -42.
]

{ #category : #'tests-numbers' }
FLBasicSerializationTest >> testSmallIntegerSerializationForAllBits [
	1
		to: 64
		do: [ :exp |
			| integer |
			integer := 2 raisedTo: exp.
			integer isLarge ifFalse: [
				self assertSerializationIdentityOf: integer ].
			integer := 0 - integer.
			integer isLarge ifFalse: [
				self assertSerializationIdentityOf: integer ] ]


]

{ #category : #'tests-globals' }
FLBasicSerializationTest >> testSmalltalkGlobals [
	"Smalltalk globals should be global by default."

	self assertSerializationIdentityOf: Smalltalk globals
]

{ #category : #'tests-strings' }
FLBasicSerializationTest >> testString [

	self assertSerializationEqualityOf: 'testString'.
	self assertSerializationEqualityOf:  'Hi, I''m String-object'.
	self assertSerializationEqualityOf:  String new.
	self assertSerializationEqualityOf:  (0 to: 255) asByteArray asString.
	

]

{ #category : #'tests-strings' }
FLBasicSerializationTest >> testSymbol [

	self assertSerializationIdentityOf: #testSymbol.
	self assertSerializationIdentityOf: #with:with:with:with:.
	self assertSerializationIdentityOf: #'hello there'.
]

{ #category : #'tests-globals' }
FLBasicSerializationTest >> testSystemDictionary [
	"We want to treat the <Smalltalk globals> instance of SystemDictionary
	specially but want to serialize all others"

	self assertSerializationEqualityOf: SystemDictionary new
]

{ #category : #tests }
FLBasicSerializationTest >> testTime [

	self assertSerializationEqualityOf: (Time fromSeconds: 84072).
	self assertSerializationEqualityOf:
		(Time hour: 0 minute: 0 second: 0).
	self assertSerializationEqualityOf:
		(Time hour: 23 minute: 59 second: 59).
	self assertSerializationEqualityOf:
		(Time hour: 0 minute: 0 second: 0).
	self assertSerializationEqualityOf: (Time seconds: 0 nanoSeconds: 5).
	self assertSerializationEqualityOf:
		(Time allInstances sort: [ :a :b | a asSeconds > b asSeconds ])
			first.
	self assertSerializationEqualityOf:
		(Time allInstances sort: [ :a :b | a nanoSecond > b nanoSecond ])
			first
]

{ #category : #tests }
FLBasicSerializationTest >> testTrue [

	self assertSerializationIdentityOf: true
]

{ #category : #tests }
FLBasicSerializationTest >> testUUID [

	self assertSerializationEqualityOf: (UUID fromString: 'a3b64357-377a-5b41-b575-1c653084a121').
	self assertSerializationEqualityOf: UUID nilUUID.
	self assertSerializationEqualityOf: UUID new.
	
]

{ #category : #tests }
FLBasicSerializationTest >> testWideAndByteCharacters [
	"Since wide and byte characters are represented in the same class, this case is prone to fail."

	| materialized aByteCharacter aWideCharacter |
	aWideCharacter := Character value: 12345.
	aByteCharacter := $a.
	materialized := self resultOfSerializeAndMaterialize: (Array with: aWideCharacter with: aByteCharacter).
	self assert: materialized first equals: aWideCharacter.
	self assert: materialized second identicalTo: aByteCharacter
]

{ #category : #'tests-strings' }
FLBasicSerializationTest >> testWideString [
	self 
		shouldnt: [
			self assertSerializationEqualityOf: 'aString' asWideString.
			self assertSerializationEqualityOf: (WideString
				streamContents: [ :stream |
					2000 timesRepeat: [
						stream nextPut: (256 to: 1000) atRandom asCharacter ] ]) ]
		raise: Error
]

{ #category : #'tests-strings' }
FLBasicSerializationTest >> testWideStringClassName [
	| class className |
	className := 'Foox' asWideString
		at: 4 put: (Character value: 265);
		yourself.
	class := Class new setName: className; yourself.
	[
		testingEnvironment at: class name put: class.
		self
			shouldnt: [ self resultOfSerializeAndMaterialize: class ]
			raise: Error
	] ensure:[ testingEnvironment removeKey: class name ]
]

{ #category : #'tests-strings' }
FLBasicSerializationTest >> testWideStringGlobal [
	| global globalValue |
	global := 'Foox' asWideString
		at: 4 put: (Character value: 265);
		yourself.
	globalValue := global , 'value'.
	[ testingEnvironment at: global put: globalValue.
	self analyzer considerGlobal: global.

	self shouldnt: [ self serialize: 'bar' -> globalValue ] raise: Error.
	self assert: self materialized class equals: Association.
	self assert: self materialized value identicalTo: global ]
		ensure: [ testingEnvironment removeKey: global ]
]

{ #category : #'tests-collections' }
FLBasicSerializationTest >> testWordArray [

	self assertSerializationEqualityOf: (WordArray with: 10 with: 20)
]

{ #category : #'tests-streams' }
FLBasicSerializationTest >> testWriteStream [
	| aWriteStream materialized |
	aWriteStream := WriteStream on: (ByteArray new: 1).

	materialized := self resultOfSerializeAndMaterialize: aWriteStream.

	aWriteStream nextPut: 1.
	self assert: 1 equals: aWriteStream size.

	self assert: 0 equals: materialized size.
	materialized nextPut: 2.
	self assert: (Array with: 2) equals: materialized contents asArray
]
