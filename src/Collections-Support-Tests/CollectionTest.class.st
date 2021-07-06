"
Basic Collection tests
"
Class {
	#name : #CollectionTest,
	#superclass : #TestCase,
	#category : #'Collections-Support-Tests-Base'
}

{ #category : #tests }
CollectionTest >> testCopyWithoutDuplicates [
 	| a b |
	a := #(1 2 3 4 4 5 6 1) copyWithoutDuplicates.
	b := #(4 2 3 1 6 5).
	self assert: [(a includesAll: b) and: [ b includesAll: a ]].

	a := #('do' 'la' 'si' 'do' 'la') copyWithoutDuplicates .
	b := #('do' 'la' 'si' ).
	self assert: [(a includesAll: b) and: [ b includesAll: a ]].

	a := #(#do #la #si #do #la) copyWithoutDuplicates.
	b := #(#si #la #do).
	self assert: [(a includesAll: b) and: [ b includesAll: a ]].
]

{ #category : #tests }
CollectionTest >> testGroupedByGroupsOrderSimple [
	| dataCollection grouped keys |
	"test of preserving groups order according to source collection order"
	dataCollection := OrderedCollection new
		add: #('ZZZ' '1');
		add: #('ZZZ' '2');
		add: #('ZZZ' '3');
		add: #('SSS' '4');
		add: #('SSS' '5');
		add: #('SSS' '6');
		add: #('BFLM' 'X');
		add: #('AAA' '1');
		add: #('AAA' '2');
		yourself.
	
	grouped := dataCollection groupedBy: [ :arrItem | arrItem at: 1 ].
	keys := grouped keys.
	self assert: (keys at: 1) equals: 'ZZZ'.
	self assert: (keys at: 2) equals: 'SSS'.
	self assert: (keys at: 3) equals: 'BFLM'.
	self assert: (keys at: 4) equals: 'AAA'.
	
	"---"
	
	dataCollection := OrderedCollection new
		add: #('k' 1);
		add: #('f' 2);
		add: #('k' 3);
		add: #('k' 4);
		add: #('k' 5);
		add: #('f' 6);
		add: #('f' 7);
		add: #('k' 8);
		yourself.
	grouped := dataCollection groupedBy: [ :arrItem | arrItem at: 1 ].
	keys := grouped keys.
	self assert: (keys at: 1) equals: 'k'.
	self assert: (keys at: 2) equals: 'f'.
	self assert: (grouped at: 'k') asArray equals: #(#('k' 1) #('k' 3) #('k' 4) #('k' 5) #('k' 8)).
	self assert: (grouped at: 'f') asArray equals: #(#('f' 2) #('f' 6) #('f' 7)).
]

{ #category : #tests }
CollectionTest >> testGroupedByGroupsOrderWithSortedCollectionOfDates [
	| dataCollection grouped keys |
	"data collection full of Date instances is sorted ascending"
	dataCollection := OrderedCollection new.
	0 to: 10 do: [ :i | 0 to: 5 do: [ :j | dataCollection add: (Date year: 2000 month: 1 day: 1) + i years + j weeks ] ].
	
	"group dates collection by year"
	grouped := dataCollection groupedBy: [ :dateItem | dateItem year ].

	"test if groups (Years) order is preserved after groupedBy"	
	keys := grouped keys.
	1 to: grouped size do: [ :i |
		self assert: (keys at: i) equals: 2000 + i - 1.
		].

]

{ #category : #tests }
CollectionTest >> testSelectAs [
	| collection result |
	collection := OrderedCollection new add: 1; add: 3; add: 2; yourself.
	result  := collection select: [:i | i even not] as: Array.
	self assert: result class equals: Array.
	self assert: result equals: #(1 3).
]
