"
This is the unit test for the class Set. Unit tests are a good way to exercise the functionality of your system in a repeatable and automatic manner. They are therefore recommended if you plan to release anything. For more information, see: 
	- http://www.c2.com/cgi/wiki?UnitTest
	- there is a chapter in the PharoByExample book (http://pharobyexample.org/)
	- the sunit class category
"
Class {
	#name : #SetTest,
	#superclass : #CollectionRootTest,
	#traits : 'TAddForUniquenessTest + TIncludesWithIdentityCheckTest + TCloneTest + TCopyTest + TRemoveTest + TGrowableTest + TStructuralEqualityTest + TPrintTest + TAsStringCommaAndDelimiterTest + TConvertTest + TConvertAsSortedTest + TConcatenationEqualElementsRemovedTest + TOccurrencesTest + (TCreationWithTest - {#testOfSize. #collectionClass}) + (TSetArithmetic - {#collectionClass})',
	#classTraits : 'TAddForUniquenessTest classTrait + TIncludesWithIdentityCheckTest classTrait + TCloneTest classTrait + TCopyTest classTrait + TRemoveTest classTrait + TGrowableTest classTrait + TStructuralEqualityTest classTrait + TPrintTest classTrait + TAsStringCommaAndDelimiterTest classTrait + TConvertTest classTrait + TConvertAsSortedTest classTrait + TConcatenationEqualElementsRemovedTest classTrait + TOccurrencesTest classTrait + TCreationWithTest classTrait + TSetArithmetic classTrait',
	#instVars : [
		'full',
		'empty',
		'collectResult',
		'emptyButAllocatedWith20',
		'elementNotIn',
		'collectionOfFloat',
		'collectionIncluded',
		'nonEmpty1element',
		'withoutEqualElements',
		'collection5Elements',
		'collectionWith3Elements',
		'collectionOfNonIdentical'
	],
	#category : #'Collections-Unordered-Tests-Sets'
}

{ #category : #'tests - includes' }
SetTest >> anotherElementNotIn [
	^ 42
]

{ #category : #requirements }
SetTest >> anotherElementOrAssociationIn [
	" return an element (or an association for Dictionary ) present  in 'collection' "
	^ self collection  anyOne
]

{ #category : #requirements }
SetTest >> anotherElementOrAssociationNotIn [
	" return an element (or an association for Dictionary )not present  in 'collection' "
	^ elementNotIn 
]

{ #category : #coverage }
SetTest >> classToBeTested [

	^ Set
]

{ #category : #requirements }
SetTest >> collection [

	^ collectionWith3Elements
]

{ #category : #coverage }
SetTest >> collectionClass [
	"Return the class to be used to create instances of the class tested"
	
	^ self classToBeTested
]

{ #category : #requirements }
SetTest >> collectionInForIncluding [
	^ collectionIncluded 
]

{ #category : #requirements }
SetTest >> collectionMoreThan5Elements [
" return a collection including at least 5 elements"
	
	^ collection5Elements 
]

{ #category : #requirements }
SetTest >> collectionNotIncluded [
	^ self classToBeTested  with: elementNotIn. 
]

{ #category : #requirements }
SetTest >> collectionWithCopyNonIdentical [
	" return a collection that include elements for which 'copy' return a different object (this is not the case of SmallInteger)"
	^ collectionOfNonIdentical
]

{ #category : #requirements }
SetTest >> collectionWithElement [
	^ full
]

{ #category : #requirements }
SetTest >> collectionWithElementsToRemove [
	^ collectionIncluded 
]

{ #category : #requirements }
SetTest >> collectionWithSortableElements [
" return a collection elements that can be sorte ( understanding message ' < '  or ' > ')"
	^collectionOfFloat 
]

{ #category : #requirements }
SetTest >> collectionWithoutElement [
	" return a collection that does not include 'element' "
	^ collectionWith3Elements  
]

{ #category : #requirements }
SetTest >> collectionWithoutEqualElements [
" return a collection without equal elements"
	^ withoutEqualElements 
]

{ #category : #requirements }
SetTest >> collectionWithoutNilElements [
" return a collection that doesn't includes a nil element  and that doesn't includes equal elements'"
	^ collectionWith3Elements  
]

{ #category : #requirements }
SetTest >> element [
	^ 4
]

{ #category : #requirements }
SetTest >> elementInForIncludesTest [
" return an element included in nonEmpty "
	^ self nonEmpty anyOne
]

{ #category : #ambiguous }
SetTest >> elementNotIn [
	^elementNotIn 
]

{ #category : #'tests - includes' }
SetTest >> elementNotInForOccurrences [
	^ 666
]

{ #category : #'tests - copying' }
SetTest >> elementToAdd [
	^ 42
]

{ #category : #'tests - empty' }
SetTest >> empty [
	
	^ empty
]

{ #category : #'tests - size capacity' }
SetTest >> emptyButAllocatedWith20 [

	^ emptyButAllocatedWith20
]

{ #category : #'tests - iterate' }
SetTest >> expectedSizeAfterReject [
	^1
]

{ #category : #requirements }
SetTest >> firstCollection [
" return a collection that will be the first part of the concatenation"
	^ nonEmpty1element 
]

{ #category : #requirements }
SetTest >> integerCollectionWithoutEqualElements [
" return a collection of integer without equal elements"
	^ withoutEqualElements 
]

{ #category : #'tests - empty' }
SetTest >> nonEmpty [
	
	^ full
]

{ #category : #requirements }
SetTest >> nonEmpty1Element [
" return a collection of size 1 including one element"
	^ nonEmpty1element 
]

{ #category : #requirements }
SetTest >> nonEmptyWithoutEqualElements [
" return a collection without equal elements "
	^ withoutEqualElements 
]

{ #category : #requirements }
SetTest >> result [

	 ^ collectResult
]

{ #category : #requirements }
SetTest >> secondCollection [
" return a collection that will be the second part of the concatenation"
	^ collectionWith3Elements  
]

{ #category : #'tests - iterate' }
SetTest >> selectedNumber [

	^ 2
	
]

{ #category : #running }
SetTest >> setUp [
	super setUp.
	empty := self classToBeTested  new.
	full := self classToBeTested  with: 1 with: 2 with: 3 with: 4.
	collectionIncluded := self classToBeTested  with: 2 with: 3 .
	collectionWith3Elements := self classToBeTested  new.
	collectionWith3Elements add: 1; add: -2; add: 3. 
	collectResult := self classToBeTested  new add: SmallInteger ; yourself.
	emptyButAllocatedWith20 := self classToBeTested  new: 20.
	elementNotIn := 99.
	collectionOfFloat := self classToBeTested  with: 2.5 with: 4.6 with: 4.2.
	collectionOfNonIdentical := self classToBeTested  with: 'a' with: 'b' with: 'c'.
	nonEmpty1element := self classToBeTested  with: 32.
	withoutEqualElements := self classToBeTested  with: 4 with: 5 with: 2.
	collection5Elements := self classToBeTested with: 1 with: 2 with: 3 with: 4 with: 5.
]

{ #category : #'tests - size capacity' }
SetTest >> sizeCollection [

	^ full
]

{ #category : #'tests - iterate' }
SetTest >> speciesClass [
	
	^ Set
]

{ #category : #'tests - fixture' }
SetTest >> test0FixtureAddForUniquenessTest [
	self element.
	self collectionWithElement.
	self assert: (self collectionWithElement includes: self element).
	self collectionWithoutElement.
	self assert: (self collectionWithElement includes: self element)
]

{ #category : #'tests - sunit original tests' }
SetTest >> testAdd [ 
	empty add: 5.
	self assert: (empty includes: 5).
]

{ #category : #'tests - growable' }
SetTest >> testAddNonEmptyGrowsWhenNewElement [
	
	| oldSize |
	oldSize := self nonEmpty size.
	self deny: (self nonEmpty includes: self elementNotInForOccurrences).
	self nonEmpty add: self elementNotInForOccurrences.
	self assert: self nonEmpty size > oldSize
]

{ #category : #'tests - some' }
SetTest >> testAddWithOccurrences [
	empty add: 2 withOccurrences: 3.
	self assert: (empty includes: 2).
	self assert: (empty occurrencesOf: 2) equals: 1
]

{ #category : #'tests - with nil' }
SetTest >> testAllowInclusionOfNils [
	| set |
	set := self classToBeTested new.
	set add: nil.
	self assert: (set includes: nil).
	set remove: nil.
	self deny: (set includes: nil)
]

{ #category : #'tests - some' }
SetTest >> testAsSet [
	"could be moved in Array or Collection"

	| newFull |
	newFull := #(1 2 3) asSet.
	newFull add: 4.
	self assert: newFull equals: full
]

{ #category : #'tests - iterating' }
SetTest >> testCollect [
	| res element collection |
	collection := self collectionWithoutNilElements.
	element := self element.
	res := collection collect: [ :each | element ].

	self assert: res class identicalTo: self classToBeTested.
	self assert: res size equals: 1.

	res do: [ :each | self assert: each equals: element ]
]

{ #category : #'tests - some' }
SetTest >> testCollect2 [
	| newFull result |
	newFull := Set withAll: (1 to: 10).
	result := newFull collect: [ :each | each >= 1 ifTrue: [ each ] ifFalse: [ 'no' ] ].
	self assert: result equals: newFull.
	result := newFull collect: [ :each | each >= 5 ifTrue: [ each ] ifFalse: [ 'no' ] ].
	self
		assert: result
		equals:
			((Set withAll: (5 to: 10))
				add: 'no';
				yourself)
]

{ #category : #'tests - some' }
SetTest >> testCopy [
	| newFull |
	full add: 3.
	full add: 2.
	newFull := full copy.
	self assert: full size equals: newFull size.
	self assertEmpty: (full select: [ :each | (newFull includes: each) not ]).
	self assertEmpty: (newFull select: [ :each | (full includes: each) not ])
]

{ #category : #'tests - copy' }
SetTest >> testCopyNonEmptyWithoutAllNotIncluded [
	
]

{ #category : #'tests - some' }
SetTest >> testCopyWithout [
	| newFull |
	full add: 3.
	full add: 2.
	newFull := full copyWithout: 3.
	self assert: newFull size equals: full size - 1.
	self deny: (newFull includes: 3).
	self assertEmpty: (newFull select: [ :each | (full includes: each) not ]).
	self assert: (full select: [ :each | (newFull includes: each) not ]) equals: (Set with: 3)
]

{ #category : #'tests - some' }
SetTest >> testDo2 [
	| newFull result |
	newFull := Set withAll: (1 to: 5).
	result := 0.
	newFull do: [ :each | result := result + each ].
	self assert: result equals: 15
]

{ #category : #'tests - iterate' }
SetTest >> testDoWithoutNoDuplicates [
	| res |
	res := self speciesClass new.
	self collection do: [ :each | res add: each ] without: -2.
	self assert: res size equals: self doWithoutNumber
]

{ #category : #'tests - enumerating' }
SetTest >> testFlatCollect [
	self assert: (#(1 2) asSet flatCollect: [ :x | 1 to: 2 * x ]) equals: #(1 2 3 4) asSet.
	self assertEmpty: (#() asSet flatCollect: [ :x | 1 to: 4 ])
]

{ #category : #'tests - enumerating' }
SetTest >> testFlatCollectAsSet [
	self assert: (#(1 2) asSet flatCollect: [ :x | 1 to: 2 * x ]) equals: #(1 2 3 4) asSet
]

{ #category : #'tests - sunit original tests' }
SetTest >> testGrow [
	empty addAll: (1 to: 100).
	self assert: empty size equals: 100
]

{ #category : #'tests - includes' }
SetTest >> testIdentityIncludes [
	" test the comportement in presence of elements 'includes' but not 'identityIncludes' "

	" can not be used by collections that can't include elements for wich copy doesn't return another instance "

	| collection element |
	self collectionWithCopyNonIdentical.
	collection := self collectionWithCopyNonIdentical.
	element := collection anyOne copy.	"self assert: (collection includes: element)."
	self deny: (collection identityIncludes: element)
]

{ #category : #'tests - sunit original tests' }
SetTest >> testIllegal [
	self should: [empty at: 5] raise: self defaultTestError.
	self should: [empty at: 5 put: #abc] raise: self defaultTestError.
			
]

{ #category : #'tests - sunit original tests' }
SetTest >> testIncludes [
	self assert: (full includes: 4).
	self assert: (full includes: 3).
	self deny: (full includes: 6).
			
]

{ #category : #'tests - includes' }
SetTest >> testIncludesElementIsNotThere [
	
	self deny: (self nonEmpty includes: self elementNotInForOccurrences).
	self assert: (self nonEmpty includes: self nonEmpty anyOne).
	self deny: (self empty includes: self elementNotInForOccurrences)
]

{ #category : #'tests - some' }
SetTest >> testIntersection [
	| newFull col |
	full
		add: 3;
		add: 2.
	col := full intersection: full.
	self assert: full equals: col.

	newFull := Set with: 8 with: 9 with: #z.
	col := newFull intersection: full.
	self assertEmpty: col.

	newFull
		add: 5;
		add: #abc;
		add: 7.
	col := newFull intersection: full.
	self assert: (full select: [ :each | newFull includes: each ]) equals: col
]

{ #category : #'tests - integrity' }
SetTest >> testIsHealthy [

	"we use associations as keys on purpose, because they changing
	hash depending on the key"

	| a1 a2 set |
	"There is a probability that nil will hash to 0 in some builds,
	so the nil key will still be in the correct position after
	it is changed to 0. The larger the set's capacity, the lower the
	probability of this failure. Also, the default size of a set
	happens to have the same correct position for 3 and 0."
	set := Set new: 50000.
	[ 
	a1 := 3 -> nil.
	a2 := nil -> 3.
	set
		add: a1;
		add: a2.
	self assert: set isHealthy.
	a1 key: 0.
	a2 key: 0.
	self assert: set isHealthy not ] ensure: [ set removeAll ]
]

{ #category : #'tests - some' }
SetTest >> testLike [
	self assert: (full like: 3) equals: 3.
	self assert: (full like: 8) isNil
]

{ #category : #'tests - comparing' }
SetTest >> testMax [
	| set |
	set := self empty.
	set add: 1; add: 2.
	self assert: (set max: [ :each | each + 1 ]) equals: 3
]

{ #category : #'tests - comparing' }
SetTest >> testMaxIfNil [
	| emptySet |
	emptySet := self empty.
	self assert: (emptySet max: [ :each | each + 1 ]) equals: nil
]

{ #category : #'tests - sunit original tests' }
SetTest >> testOccurrences [
	self assert: (empty occurrencesOf: 0) equals: 0.
	self assert: (full occurrencesOf: 4) equals: 1.
	full add: 4.
	self assert: (full occurrencesOf: 4) equals: 1
]

{ #category : #'tests - sunit original tests' }
SetTest >> testRemove [
	full remove: 4.
	self assert: (full includes: 3).
	self deny: (full includes: 4).
]

{ #category : #tests }
SetTest >> testRemoveAll [
	"Allows one to remove all elements of a collection"

	| c1 c2 s2 |
	c1 := full.
	c2 := c1 copy.
	s2 := c2 size.

	c1 removeAll.

	self assert: c1 size equals: 0.
	self assert: c2 size = s2 description: 'the copy has not been modified'
]

{ #category : #'tests - some' }
SetTest >> testRemoveIfAbsent [
		
	self assert: (full remove: 8 ifAbsent: [true]).
	self assert: (full remove: 4 ifAbsent: [false]) isNumber.
	
	
	
]

{ #category : #'tests - integrity' }
SetTest >> testSetWithNilItemsIsHealthy [
	self classToBeTested = Set
		ifFalse: [ ^ self	"only works on Dictionary" ].
	self assert: {nil} asSet isHealthy
]

{ #category : #'tests - some' }
SetTest >> testSize2 [
	self assert: empty size equals: 0.
	self assert: full size equals: 4.
	empty add: 2.
	empty add: 1.
	full add: 2.
	self assert: empty size equals: 2.
	self assert: full size equals: 4.
	empty remove: 2.
	self assert: empty size equals: 1
]

{ #category : #'tests - some' }
SetTest >> testUnion [
	| newFull col newCol |
	full add: 3.
	full add: 2.
	col := full union: full.
	self assert: full equals: col.

	newFull := Set with: 8 with: 9 with: #z.
	col := newFull union: full.
	self assert: col size equals: full size + newFull size.
	self assert: (col select: [ :each | (full includes: each) not ]) equals: newFull.
	self assert: (col select: [ :each | (newFull includes: each) not ]) equals: full.

	full add: 9.
	col := newFull union: full.
	newCol := newFull copy.
	newCol remove: 9.
	self assert: col size equals: full size + newFull size - 1.
	self assert: (col select: [ :each | (full includes: each) not ]) equals: newCol.
	newCol := full copy.
	newCol remove: 9.
	self assert: (col select: [ :each | (newFull includes: each) not ]) equals: newCol
]
