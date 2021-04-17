Class {
	#name : #StIteratorsTest,
	#superclass : #TestCase,
	#category : #'NewTools-Spotter-Processors-Tests'
}

{ #category : #tests }
StIteratorsTest >> testBeginsWithFilterDoesNotFetchTwiceIfTheFilterIsARefinementOfPreviousText [

	| it |
	it := (SptGeneratorBlockIterator on: [ :x | x value: 'bbb'; value:'bbb1'; error ]) beginsWithFilter: 'b'.
	it next.
	it beginsWithFilter: 'bb'.
	
	self assert: it next equals: 'bbb'
]

{ #category : #tests }
StIteratorsTest >> testBeginsWithFilterReturnsValidResults [

	| it |
	it := (SptCollectionIterator on: { 'aaa'. 'bbb'. 'ccc' }) beginsWithFilter: 'b'.
	self assert: it next equals: 'bbb'
]

{ #category : #tests }
StIteratorsTest >> testBeginsWithFilterReturnsValidResultsWithTheSameFilter [

	| it |
	it := (SptCollectionIterator on: { 'aaa'. 'bbb'. 'ccc' }) beginsWithFilter: 'b'.
	it beginsWithFilter: 'b'.
	
	self assert: it next equals: 'bbb'
]

{ #category : #tests }
StIteratorsTest >> testIteratorOnACollectedCollectionIsFiltered [

	| it |
	it := ((SptCollectionIterator on: #(1 2 3)) 
		collect: [ :e | e * 2 ])
		select: [:e | e even].
	self assertCollection: (it next: 3) hasSameElements: #(2 4 6).

]

{ #category : #tests }
StIteratorsTest >> testIteratorOnACollectionIsFiltered [

	| it |

	it := (SptCollectionIterator on: #(1 2 3)) select: [:e | e even].

	self assertCollection: (it next: 3) hasSameElements: #(2).

]

{ #category : #tests }
StIteratorsTest >> testIteratorOnACollectionReturnsTheCollection [

	| it |
	it := SptCollectionIterator on: #(1 2 3).
	self assertCollection: (it next:3) hasSameElements: #(1 2 3)
]

{ #category : #tests }
StIteratorsTest >> testIteratorOnACollectionReturnsTheFirstValue [

	| it |

	it := SptCollectionIterator on: #(1 2 3).
	self assert: (it next) equals: 1
]

{ #category : #tests }
StIteratorsTest >> testIteratorOnACollectionReturnsTheFirstValueAndSecondValue [

	| it |

	it := SptCollectionIterator on: #(1 2 3).
	self assert: (it next) equals: 1.
	self assert: (it next) equals: 2	
]

{ #category : #tests }
StIteratorsTest >> testIteratorOnACollectionWithCollectReturnsCorrectFirstValue [

	| it |
	it := (SptCollectionIterator on: #(1 2 3)) collect: [:e | e * 3].
	self assert: (it next) equals: 3.

]

{ #category : #tests }
StIteratorsTest >> testIteratorOnACollectionWithCollectReturnsCorrectValues [

	| it |
	it := (SptCollectionIterator on: #(1 2 3)) collect: [:e | e * 3].
	self assertCollection: (it next: 3) hasSameElements: #(3 6 9).

]

{ #category : #tests }
StIteratorsTest >> testIteratorOnACollectionWithTwoCollectReturnsCorrectFirstValue [

	| it |
	it := ((SptCollectionIterator on: #(1 2 3)) collect: [:e | e * 3]) collect: [:e | e * 2].
	self assert: it next equals: 6.

]

{ #category : #tests }
StIteratorsTest >> testIteratorOnACollectionWithTwoCollectReturnsCorrectValues [
	| it |
	
	it := ((StCollectionIterator on: #(1 2 3)) collect: [:e | e * 3]) collect: [:e | e * 2].
	self assertCollection: (it next: 3) hasSameElements: #(6 12 18).

]

{ #category : #tests }
StIteratorsTest >> testNonDuplicatesRemoveDuplicates [

	| it |
	
	it := (StCollectionIterator on: #(1 1)) asWithoutDuplicates.
	self assert: (it next:1) equals: #(1) asOrderedCollection
]

{ #category : #tests }
StIteratorsTest >> testNonDuplicatesRemoveDuplicatesResetReturnsWithoutDuplicates [

	| it |
	
	it := (StCollectionIterator on: #(1 1 2 2 3 3)) asWithoutDuplicates.
	self assert: (it next:3) equals: #(1 2 3) asOrderedCollection.
	
	it reset. 
	
	self assert: (it next:3) equals: #(1 2 3) asOrderedCollection 
]

{ #category : #tests }
StIteratorsTest >> testNonDuplicatesRemoveDuplicatesWithThree [
	| it |
	
	it := (StCollectionIterator on: #(1 1 2 2 3 3)) asWithoutDuplicates.
	self assert: (it next:3) equals: #(1 2 3) asOrderedCollection 
]

{ #category : #tests }
StIteratorsTest >> testSequenceDetectsAtEnd [

	| it |
	it := (StCollectionIterator on: #(1 2 3)) , (StCollectionIterator on: #(4 5 6)).
	it next: 3.
	self deny: it atEnd.
	it next: 3.
	self assert: it atEnd.
		

	
]

{ #category : #tests }
StIteratorsTest >> testSequenceReturnsTheSequenceOfAllResults [
	| it |
	
	it := (StCollectionIterator on: #(1 2 3)) , (StCollectionIterator on: #(4 5 6)).
	self assertCollection: (it next: 6) hasSameElements: #(1 2 3 4 5 6)
]

{ #category : #tests }
StIteratorsTest >> testSequenceReturnsTheSequenceOfAllResultsInParts [
	| it |
	
	it := (StCollectionIterator on: #(1 2 3)) , (StCollectionIterator on: #(4 5 6)).
	
	self assertCollection: (it next: 3) hasSameElements: #(1 2 3).
	self assertCollection: (it next: 3) hasSameElements: #(4 5 6)	
]

{ #category : #tests }
StIteratorsTest >> testSubstringFilterDoesNotFetchTwiceIfTheFilterIsARefinementOfPreviousText [

	| it |
	it := (StGeneratorBlockIterator on: [ :x | x value: '1bbb'; value:'11bbb1'; error ]) substringFilter: 'b'.
	it next.
	it substringFilter: 'bb'.
	
	self assert: it next equals: '1bbb'
]

{ #category : #tests }
StIteratorsTest >> testSubstringFilterReturnsValidResults [

	| it |
	it := (StCollectionIterator on: { 'xxxaaa'. 'xxxbbb'. 'xxxccc' }) substringFilter: 'b'.
	self assert: it next equals: 'xxxbbb'
]

{ #category : #tests }
StIteratorsTest >> testSubstringFilterReturnsValidResultsWithTheSameFilter [
	| it |

	it := (StCollectionIterator on: { 'aaa'. 'xxxbbb'. 'ccc' }) substringFilter: 'b'.
	it substringFilter: 'b'.
	
	self assert: it next equals: 'xxxbbb'
]

{ #category : #tests }
StIteratorsTest >> testWordsAwareIteratorFiltersByASequenceOfCamelCase [

	| inner it |
	
	inner := (StCollectionIterator on: { 'aaa'. 'xxxyyybbb'. 'xxxcccbbb' }) asSubstringFilter.
	it := StWordsAwareFilter new
		inner: inner;
		yourself.
		
	it filteringText: 'xxxBbb'.
	
	self assert: it next equals: 'xxxyyybbb'.
	self assert: it next equals: 'xxxcccbbb'	
]

{ #category : #tests }
StIteratorsTest >> testWordsAwareIteratorFiltersByASequenceOfCamelCaseMixingCase [

	| inner it |
	
	inner := (StCollectionIterator on: { 'aaa'. 'xxxyyyBBB'. 'XXXcccbbb'. 'xxxcccbbb' }) asSubstringFilter.
	it := StWordsAwareFilter new
		inner: inner;
		yourself.
		
	it filteringText: 'xxxBbb'.
	
	self assert: it next equals: 'xxxyyyBBB'.
	self assert: it next equals: 'XXXcccbbb'.
	self assert: it next equals: 'xxxcccbbb'	
]

{ #category : #tests }
StIteratorsTest >> testWordsAwareIteratorFiltersByASequenceOfCamelCaseWithUppercase [

	| inner it |
	
	inner := (StCollectionIterator on: { 'aaa'. 'xxxyyybbb'. 'xxxcccbbb' }) asSubstringFilter.
	it := StWordsAwareFilter new
		inner: inner;
		yourself.
		
	it filteringText: 'XxxBbb'.
	
	self assert: it next equals: 'xxxyyybbb'.
	self assert: it next equals: 'xxxcccbbb'	
]

{ #category : #tests }
StIteratorsTest >> testWordsAwareIteratorFiltersByASequenceOfWords [

	| inner it |
	
	inner := (StCollectionIterator on: { 'aaa'. 'xxxyyybbb'. 'xxxcccbbb' }) asSubstringFilter.
	it := StWordsAwareFilter new
		inner: inner;
		yourself.
		
	it filteringText: 'xxx bbb'.
	
	self assert: it next equals: 'xxxyyybbb'.
	self assert: it next equals: 'xxxcccbbb'	
]

{ #category : #tests }
StIteratorsTest >> testWordsAwareIteratorFiltersByASingleWord [

	| inner it |
	
	inner := (StCollectionIterator on: { 'aaa'. 'xxxyyybbb'. 'xxxcccbbb' }) asSubstringFilter.
	it := StWordsAwareFilter new
		inner: inner;
		yourself.
		
	it filteringText: 'xxx'.
	
	self assert: it next equals: 'xxxyyybbb'.
	self assert: it next equals: 'xxxcccbbb'	
]

{ #category : #tests }
StIteratorsTest >> testWordsAwareIteratorFiltersByASingleWordFindingNothing [

	| inner it |
	
	inner := (StCollectionIterator on: { 'aaa'. 'xxxyyybbb'. 'xxxcccbbb' }) asSubstringFilter.
	it := StWordsAwareFilter new
		inner: inner;
		yourself.
		
	it filteringText: 'zzz'.
	
	self assert: it next equals: nil
]

{ #category : #tests }
StIteratorsTest >> testWordsAwareIteratorFiltersLeftOutBecauseSecondWord [

	| inner it |
	
	inner := (StCollectionIterator on: { 'aaa'. 'xxxyyybbb'. 'xxxcccbbb' }) asSubstringFilter.
	it := StWordsAwareFilter new
		inner: inner;
		yourself.
		
	it filteringText: 'xxx aaa'.
	
	self assert: it next equals: nil.

]
