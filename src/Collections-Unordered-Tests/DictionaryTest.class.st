"
SUnit tests for dictionaries
"
Class {
	#name : #DictionaryTest,
	#superclass : #CollectionRootTest,
	#traits : 'TIncludesTest + TDictionaryAddingTest + TDictionaryComparingTest + TDictionaryCopyingTest + TDictionaryEnumeratingTest + (TDictionaryPrintingTest - {#testPrintElementsOn. #testStoreOn}) + TDictionaryRemovingTest + (TPutBasicTest - {#testAtPutOutOfBounds}) + TAsStringCommaAndDelimiterTest + TPrintTest + TConvertTest + TConvertAsSortedTest + (TCopyTest - {#testCopyEmptyWithout. #testCopyNonEmptyWithout. #testCopyNonEmptyWithoutNotIncluded}) + TSetArithmetic + TDictionaryIncludesWithIdentityCheckTest + TDictionaryValueAccessTest + TDictionaryKeysValuesAssociationsAccess + TDictionaryKeyAccessTest + TDictionaryAssociationAccessTest + TStructuralEqualityTest + TOccurrencesForMultiplinessTest',
	#classTraits : 'TIncludesTest classTrait + TDictionaryAddingTest classTrait + TDictionaryComparingTest classTrait + TDictionaryCopyingTest classTrait + TDictionaryEnumeratingTest classTrait + TDictionaryPrintingTest classTrait + TDictionaryRemovingTest classTrait + TPutBasicTest classTrait + TAsStringCommaAndDelimiterTest classTrait + TPrintTest classTrait + TConvertTest classTrait + TConvertAsSortedTest classTrait + TCopyTest classTrait + TSetArithmetic classTrait + TDictionaryIncludesWithIdentityCheckTest classTrait + TDictionaryValueAccessTest classTrait + TDictionaryKeysValuesAssociationsAccess classTrait + TDictionaryKeyAccessTest classTrait + TDictionaryAssociationAccessTest classTrait + TStructuralEqualityTest classTrait + TOccurrencesForMultiplinessTest classTrait',
	#instVars : [
		'emptyDict',
		'nonEmptyDict',
		'nonEmpty5ElementsNoDuplicates',
		'indexArray',
		'valueArray',
		'nonEmpty1Element',
		'collectionNotIncluded',
		'collectionIncluded',
		'associationNotIn',
		'valueNotIn',
		'keyNotIn',
		'dictionaryNotIncluded',
		'dictionaryWithDuplicateValues',
		'duplicateValue',
		'nonEmptyWithString'
	],
	#category : #'Collections-Unordered-Tests-Dictionaries'
}

{ #category : #helpers }
DictionaryTest >> aValue [

	^ 33
]

{ #category : #helpers }
DictionaryTest >> anIndex [

	^ #GG
]

{ #category : #requirements }
DictionaryTest >> anotherElementNotIn [
	
	^ 42
]

{ #category : #requirements }
DictionaryTest >> anotherElementOrAssociationIn [
	" return an element (or an association for Dictionary ) present  in 'collection' "
	^ self collection associations anyOne.
]

{ #category : #requirements }
DictionaryTest >> anotherElementOrAssociationNotIn [
	" return an element (or an association for Dictionary )not present  in 'collection' "
	
	^ associationNotIn 
]

{ #category : #helpers }
DictionaryTest >> anotherValue [

	^ 66
]

{ #category : #requirements }
DictionaryTest >> associationWithKeyAlreadyInToAdd [
	" return an association that will be used to add to nonEmptyDict (the key of this association is already included in nonEmptyDict)"
	^ (self nonEmptyDict keys anyOne)->valueNotIn .
]

{ #category : #requirements }
DictionaryTest >> associationWithKeyNotInToAdd [
	" return an association that will be used to add to nonEmptyDict"
	^ associationNotIn 
]

{ #category : #requirements }
DictionaryTest >> canBeUnhealthy [
	^ true
]

{ #category : #coverage }
DictionaryTest >> classToBeTested [ 

	^ Dictionary
]

{ #category : #requirements }
DictionaryTest >> collection [
	^ self nonEmptyDict
]

{ #category : #requirements }
DictionaryTest >> collectionClass [
	"Return the class to be used to create instances of the class tested"

	^ self classToBeTested
]

{ #category : #requirements }
DictionaryTest >> collectionNotIncluded [
" return a collection for wich each element is not included in 'nonEmpty' "
	^collectionNotIncluded 
]

{ #category : #requirements }
DictionaryTest >> collectionWithElement [
	"Returns a collection that already includes what is returned by #element."
	^ nonEmpty5ElementsNoDuplicates add: self element ;yourself.
]

{ #category : #requirements }
DictionaryTest >> collectionWithElementsToRemove [
" return a collection of elements included in 'nonEmpty'  "
	^ collectionIncluded  
]

{ #category : #requirements }
DictionaryTest >> collectionWithEqualElements [
" return a collecition including atLeast two elements equal"

^ dictionaryWithDuplicateValues 
]

{ #category : #requirements }
DictionaryTest >> collectionWithSortableElements [
" return a collection elements that can be sorte ( understanding message ' < '  or ' > ')"
	^ nonEmpty5ElementsNoDuplicates 
]

{ #category : #requirements }
DictionaryTest >> collectionWithoutEqualElements [
" return a collection without equal elements"
	^ nonEmpty5ElementsNoDuplicates 
]

{ #category : #requirements }
DictionaryTest >> collectionWithoutNilElements [
" return a collection that doesn't includes a nil element  and that doesn't includes equal elements'"
	^nonEmpty5ElementsNoDuplicates 
]

{ #category : #requirements }
DictionaryTest >> element [
	^ 30
]

{ #category : #requirements }
DictionaryTest >> elementNotIn [
	"return an element not included in 'nonEmpty' "
	^ valueNotIn
]

{ #category : #requirements }
DictionaryTest >> elementNotInForOccurrences [
	^ 666
]

{ #category : #requirements }
DictionaryTest >> elementToAdd [
" return an element of type 'nonEmpy' elements'type'"
	^ #u->5.
]

{ #category : #requirements }
DictionaryTest >> elementTwiceInForOccurrences [
" return an element included exactly two time in # collectionWithEqualElements"
^ duplicateValue 
]

{ #category : #requirements }
DictionaryTest >> empty [
	^ emptyDict
]

{ #category : #requirements }
DictionaryTest >> emptyDict [
	^ emptyDict
]

{ #category : #requirements }
DictionaryTest >> expectedElementByDetect [
	^ 30
]

{ #category : #requirements }
DictionaryTest >> indexInNonEmpty [
	"Return an index key between bounds of 'nonEmpty'"

	^ #a
]

{ #category : #requirements }
DictionaryTest >> integerCollectionWithoutEqualElements [
" return a collection of integer without equal elements"
	^ nonEmpty5ElementsNoDuplicates 
]

{ #category : #requirements }
DictionaryTest >> keyNotIn [
" return a key not included in nonEmpty"
^ keyNotIn 
]

{ #category : #requirements }
DictionaryTest >> keyNotInNonEmpty [
	" return a key not included in nonEmpty"
	^ keyNotIn 
]

{ #category : #requirements }
DictionaryTest >> keyNotInNonEmptyDict [
" return a key not included in nonEmptyDict"
	^ keyNotIn 
]

{ #category : #requirements }
DictionaryTest >> newEmptyDict [
	^ self emptyDict copy
]

{ #category : #requirements }
DictionaryTest >> nonEmpty [
	^ nonEmptyDict
]

{ #category : #requirements }
DictionaryTest >> nonEmpty1Element [
" return a collection of size 1 including one element"
	^ nonEmpty1Element 
]

{ #category : #requirements }
DictionaryTest >> nonEmptyDict [
	^ nonEmptyDict 
]

{ #category : #requirements }
DictionaryTest >> nonEmptyDifferentFromNonEmptyDict [
" return a dictionary for which all keys are not included in nonEmptyDict"
^ dictionaryNotIncluded 
]

{ #category : #requirements }
DictionaryTest >> nonEmptyWithCopyNonIdentical [
" return a collection including elements for wich copy is not identical to the initial element ( this is not the cas of Integer )"
^nonEmptyWithString 
]

{ #category : #requirements }
DictionaryTest >> nonEmptyWithoutEqualsValues [
" return a dictionary that doesn't include equal values'"
^nonEmpty5ElementsNoDuplicates 
]

{ #category : #requirements }
DictionaryTest >> otherCollection [
	"Returns a collection that does not include what is returned by #element."
	^ nonEmpty5ElementsNoDuplicates 
]

{ #category : #requirements }
DictionaryTest >> otherDictionaryClasses [
	"(DictionaryTest withAllSubclasses collect: [:each | each new classToBeTested]) asArray"
	^ {SmallDictionary. IdentityDictionary. PluggableDictionary.
		WeakValueDictionary. SystemDictionary. WeakKeyDictionary. SmallIdentityDictionary.
		WeakIdentityKeyDictionary. WeakKeyToCollectionDictionary. Dictionary}
			reject: [:each | each new species == self classToBeTested new species]
]

{ #category : #requirements }
DictionaryTest >> result [
	^ self collectionClass newFromPairs: {
		#a . SmallInteger .
		#b . SmallInteger .
		#c . SmallInteger .
		#d . SmallInteger }
]

{ #category : #running }
DictionaryTest >> setUp [
	super setUp.
	emptyDict := self classToBeTested new.
	nonEmptyDict := self classToBeTested new.
	nonEmptyDict
		at: #a
			put: self elementTwiceIn;
		at: #b
			put: 30;
		at: #c
			put: self elementTwiceIn;
		at: #d
			put: -2.
	nonEmpty5ElementsNoDuplicates := self classToBeTested new
		at: #a
			put: 5;
		at: #b
			put: 4;
		at: #c
			put: 7;
		at: #d
			put: 6;
		at: #e
			put: 9;
		yourself.
	valueNotIn := 666.
	keyNotIn := #z .
	associationNotIn := keyNotIn->valueNotIn.
	dictionaryNotIncluded := Dictionary new add: associationNotIn ;yourself.
	collectionNotIncluded := {  valueNotIn. valueNotIn  }.
	collectionIncluded := {  (self elementTwiceIn)  }.
	indexArray := #(2 3 1 ).
	valueArray := #(5 5 5 ).
	nonEmpty1Element := self classToBeTested new
		at: #a
			put: 5;
		yourself.
	nonEmptyWithString := Dictionary new add: #A->'foo'; add: #b->'bar' ; yourself.
	duplicateValue := 2.5.
	dictionaryWithDuplicateValues := 	Dictionary new add: #A->duplicateValue ; add: #b->3.5 ; add: #C->duplicateValue  ; yourself.


]

{ #category : #requirements }
DictionaryTest >> sizeCollection [
	^ nonEmptyDict
]

{ #category : #requirements }
DictionaryTest >> speciesClass [
	^ Dictionary
]

{ #category : #'tests - adding' }
DictionaryTest >> testAdd [
	"| dict |
	dict := self emptyDict.
	dict add: #a -> 1.
	dict add: #b -> 2.
	self assert: (dict at: #a) = 1.
	self assert: (dict at: #b) = 2"

	| dictionary result |
	dictionary := self nonEmptyDict.
	result := dictionary add: self associationWithKeyNotInToAdd.
	self assert: result equals: self associationWithKeyNotInToAdd
]

{ #category : #'tests - adding' }
DictionaryTest >> testAddWithKeyAlreadyIn [
	| dictionary result association |
	dictionary := self nonEmptyDict.
	association := self associationWithKeyNotInToAdd.
	result := dictionary add: association.
	self assert: result equals: association.
	self assert: (dictionary at: association key) equals: association value
]

{ #category : #'tests - adding' }
DictionaryTest >> testAddWithKeyNotIn [
	| dictionary result association |
	dictionary := self nonEmptyDict.
	association := self associationWithKeyNotInToAdd.
	result := dictionary add: association.
	self assert: result equals: association.
	self assert: (dictionary at: association key) equals: association value
]

{ #category : #tests }
DictionaryTest >> testAsSet [
	
	| aDictionary aSet assoc0 assoc1 |
	aDictionary := Dictionary new.
	aSet := aDictionary asSet.
	"Add two associations to it"	
	assoc0 := #first -> 0.
	assoc1 := #first -> 1.
	aSet add: assoc0 copy; add: assoc1.
	
	"Check if the two associations were added (that should happen if they are different)"
	self
		assert: (assoc0 copy ~= assoc1) ==> (aSet size > 1)
		description:
  			'When adding two different elements, the set size should be greater than one'
]

{ #category : #tests }
DictionaryTest >> testAtUpdate [
	| dict |
	dict := {2->10. 100->5} asDictionary.
	dict at: 2 update: [ :v | v+10 ].
	self assert: (dict at: 2) equals: 20.
	self should: [ dict at: 5 update: [ :v | v+1 ] ] raise: KeyNotFound .
	
	
	
]

{ #category : #tests }
DictionaryTest >> testAtUpdateInitial [
	| dict |
	dict := {2->10. 100->5} asDictionary.
	dict at: 5 update: [ :v | v+1 ] initial: [17].
	dict at: 2 update: [ :v | v+10 ] initial: [0].
	self assert: (dict at: 5) equals: 17.
	self assert: (dict at: 2) equals: 20
	
]

{ #category : #tests }
DictionaryTest >> testDictionaryPublicProtocolCompatibility [
	"Tests that other dictionaries and their classes respond to the messages
	in the public protocols (ignoring extensions, private, printing, copying,
	and comparing) that Dictionary and its metaclass implement."

	| dict |
	self collectionClass == Dictionary
		ifTrue: [ ^ self ].
	dict := self emptyDict.
	{(dict -> Dictionary).
	(dict class -> Dictionary class)}
		do: [ :assoc | 
			assoc value protocols
				reject: [ :protocol | 
					#('private' 'print' 'undeclared' 'copy' 'compar' '*')
						anySatisfy: [ :each | protocol asString beginsWith: each ] ]
				thenDo: [ :protocol | 
					(assoc value selectorsInProtocol: protocol)
						do: [ :each | self assert: (assoc key respondsTo: each) ] ] ]
]

{ #category : #'tests - flatCollect' }
DictionaryTest >> testFlatCollect [

	| res |
 	res := {#first -> -1. #second -> 5 . #three -> -33} asDictionary flatCollect: [:e | { e abs } ].
 	self assert: res asSet equals: #(1 5 33) asSet. 
	
 
]

{ #category : #'tests - flatCollect' }
DictionaryTest >> testFlatCollect2 [

	| res |
 	res := {#first -> #(-2 3). #second -> #(-4 5)} asDictionary flatCollect: [:e | e collect: [:each | each abs]].
 	self assert: res asSet equals: #(2 3 4 5) asSet. 
	
 
]

{ #category : #'tests - flatCollect' }
DictionaryTest >> testFlatCollect3 [

	| res |
 	res := {#first -> #(-2 3). #second -> #(-4 5)} asDictionary flatCollect: [:e | {e collect: [:each | each abs]}].
 	self assert: res asSet equals: #(#(2 3) #(4 5)) asSet. 
	
 
]

{ #category : #'tests - testing' }
DictionaryTest >> testHasBindingThatBeginsWith [
	| newDict |
	newDict := self collectionClass new 
		at: #abc put: 10; 
		at: #abcd put: 100; 
		at: #def put: 20; 
		yourself.
	self assert: (newDict hasBindingThatBeginsWith: 'ab').
	self assert: (newDict hasBindingThatBeginsWith: 'def').
	self deny: (newDict hasBindingThatBeginsWith: 'defg').
]

{ #category : #'tests - testing' }
DictionaryTest >> testIncludeAssociation [
	self assert: (nonEmptyDict includesAssociation: #a -> self elementTwiceIn).
	self assert: (nonEmptyDict includesAssociation: (nonEmptyDict associations first)).

]

{ #category : #'tests - testing' }
DictionaryTest >> testIncludes [
	| o1 o2 newDict |
	self assert: (nonEmptyDict includes: self element).

	o1 := 2 @ 3.
	o2 := 2 @ 3.
	self deny: o1 identicalTo: o2.
	self assert: o1 equals: o2.
	newDict := self collectionClass new.
	newDict at: #a put: o1.

	self assert: (newDict includes: o2)
]

{ #category : #'tests - testing' }
DictionaryTest >> testIncludesAssociationNoValue [

	| association dictionary |
	
	association := Association key: #key.
	
	self assert: association value isNil.
	
	dictionary := self collectionClass new.
	
	dictionary add: association.
	
	self assert: (dictionary at: #key) isNil

	
	
	
]

{ #category : #'tests - testing' }
DictionaryTest >> testIncludesAssociationWithValue [
	| association dictionary |
	association := Association key: #key value: 1.
	dictionary := self collectionClass new.
	dictionary add: association.

	self assert: (dictionary at: #key) equals: 1
]

{ #category : #'tests - includes' }
DictionaryTest >> testIncludesElementIsNotThere [
	
	self deny: (self nonEmpty includes: self elementNotInForOccurrences).
	self assert: (self nonEmpty includes: self nonEmpty anyOne).
	self deny: (self empty includes: self elementNotInForOccurrences)
]

{ #category : #'tests - testing' }
DictionaryTest >> testIsDictionary [
	self deny: Object new isDictionary.
	self assert: nonEmptyDict isDictionary.
	self assert: emptyDict isDictionary.
]

{ #category : #'tests - integrity' }
DictionaryTest >> testIsHealthy [
	| dict |
	self canBeUnhealthy
		ifFalse: [
			self assert: self nonEmpty isHealthy.
			^ self ].
	dict := self emptyDict.
	[ | a1 a2 |
	"we use associations as keys on purpose, because they change their
	hash depending on the key"
	a1 := 1 -> 2.
	a2 := 2 -> 2.
	dict
		at: a1 put: 2;
		at: a2 put: 3.
	self assert: dict isHealthy.
	a1 key: 0.
	a2 key: 0.
	self deny: dict isHealthy ]
		ensure: [ dict removeAll ]
]

{ #category : #'tests - dictionary key access' }
DictionaryTest >> testKeyAtValueIfAbsent [
 
	| dict value result |
	dict := self nonEmpty.
	value := dict values anyOne.
	result := dict keyAtValue: value ifAbsent: [ nil ].
	self assert: (dict at: result) equals: value.
	self assert: (dict keyAtValue: self valueNotIn ifAbsent: [ nil ]) isNil
]

{ #category : #'tests - testing' }
DictionaryTest >> testKeyForIdentity [
	self assert: (nonEmptyDict keyForIdentity: 30) equals: #b.

	"The value 20 is associated to two different associations"
	self assert: (#(a c) includes: (nonEmptyDict keyForIdentity: self elementTwiceIn))
]

{ #category : #'tests - new' }
DictionaryTest >> testNew [
	| d |
	d := self classToBeTested new: 10.
	self assert: d size equals: 0

	"Why 14? Mysterious"
	"self assert: d capacity = 14"
]

{ #category : #'tests - new' }
DictionaryTest >> testNewFrom [
	| assocs |
	self assert: (self classToBeTested newFrom: {}) equals: self emptyDict.

	self assert: (self classToBeTested newFrom: nonEmptyDict copy) equals: self nonEmptyDict.

	assocs := self nonEmptyDict associations collect: [ :each | each copy ].
	self assert: (self classToBeTested newFrom: assocs) equals: self nonEmptyDict
]

{ #category : #'tests - new' }
DictionaryTest >> testNewFromKeysAndValues [
 
	| keys values newDict |
	keys := self nonEmptyDict keys.
	values := self nonEmptyDict values.
	newDict := self classToBeTested newFromKeys: keys andValues: values.
	self nonEmptyDict keysAndValuesDo: [:k :v|
		self assert: (newDict at: k) equals: v ]. 
]

{ #category : #'tests - new' }
DictionaryTest >> testNewFromKeysAndValues2 [
 
	| dict newDict |
	dict := self classToBeTested new
		at: #a put: 1;
		at: #b put: 2;
		at: #c put: 3; yourself.
	newDict := self classToBeTested newFromKeys: dict keys andValues: dict values.
	dict keysAndValuesDo: [:k :v|
		self assert: (newDict at: k) equals: v ]. 
]

{ #category : #'tests - new' }
DictionaryTest >> testNewFromPairs [
	| assocs pairs |
	assocs := self nonEmptyDict associations.
	pairs := OrderedCollection new.
	assocs
		do: [ :each | 
			pairs
				add: each key;
				add: each value ].
	0 to: pairs size do: [ :i | 
		| dictFromPairs dictFromAssocs |
		dictFromPairs := self classToBeTested newFromPairs: (pairs copyFrom: 1 to: i).
		dictFromAssocs := self classToBeTested newFrom: (assocs copyFrom: 1 to: (i / 2) floor).
		self assert: dictFromPairs equals: dictFromAssocs ]
]

{ #category : #tests }
DictionaryTest >> testNilHashCollision [

	"Ensures that fixCollisionsFrom: does the right thing in the presence of a nil key.
	To do that, we must have a key with the same hash as nil."

	| dict key |
	self supportsNilKey ifFalse: [ ^ self ].
	dict := self collectionClass new.
	key := ObjectWithSettableHash new.
	key hash: nil hash.
	self assert: key hash equals: nil hash.
	dict at: key put: 1.
	dict at: nil put: 2.
	self assert: (dict includesKey: nil).
	dict removeKey: key.
	self assert: (dict includesKey: nil)
]

{ #category : #'tests - testing' }
DictionaryTest >> testOccurrencesOf [
	
	| dict |
	dict := self collectionClass new.
	dict at: #a put: 1.
	dict at: #b put: 2.
	dict at: #c put: 1.
	dict at: #d put: 3.
	dict at: nil put: nil.
	dict at: #z put: nil.
		
	self assert: (dict occurrencesOf: 1 ) equals: 2.
	self supportsNilKey 
		ifTrue: [ self assert: (dict occurrencesOf: nil ) equals: 2 ]
		ifFalse: [ self assert: (dict occurrencesOf: nil ) equals: 1 ]	
	
	
	
]

{ #category : #'tests - comparing' }
DictionaryTest >> testOtherDictionaryEquality [
	self otherDictionaryClasses
		do: [ :each | 
			| nonEmptyDict2 |
			nonEmptyDict2 := each new.
			self deny: self empty equals: nonEmptyDict2.
			self deny: nonEmptyDict2 equals: self empty.

			self nonEmptyDict keysAndValuesDo: [ :key :value | nonEmptyDict2 at: key put: value ].
			self deny: self nonEmptyDict equals: nonEmptyDict2.
			self deny: nonEmptyDict2 equals: self nonEmptyDict ]
]

{ #category : #tests }
DictionaryTest >> testRemoveAll [
	"Allows one to remove all elements of a collection"

	| dict1 dict2 s2 |
	dict1 := self collectionClass new.
	dict1
		at: #a put: 1;
		at: #b put: 2.

	dict2 := dict1 copy.
	s2 := dict2 size.

	dict1 removeAll.

	self assert: dict1 size equals: 0.
	self assert: dict2 size = s2 description: 'the copy has not been modified'
]

{ #category : #tests }
DictionaryTest >> testSelectIsNotShallowCopy [
		
	| original even |
	original := self collectionClass new.
	original at: #one put: 1.
	original at: #two put: 2.

	even := original select: [:value |value even].
	even at: #two put: 'deux'.

	self assert: (original at: #two) = 2
 	   description: 'modifying a selection should not modify the original'
]

{ #category : #'tests - printing' }
DictionaryTest >> testStoreOnWithNegativeInteger [
	| dictionary |
	dictionary := { 'x' -> -1 } as: self classToBeTested.
	
	self
		assert: (String streamContents: [ :s | dictionary storeOn: s ])
		equals: '((',self classToBeTested name,' new) add: (''x''-> -1); yourself)'
]

{ #category : #requirements }
DictionaryTest >> valueNotIn [
" return a value not included in nonEmpty "
^valueNotIn 
]

{ #category : #requirements }
DictionaryTest >> valueNotInNonEmpty [
	" return a value not included in nonEmpty"
	^ valueNotIn 
]
