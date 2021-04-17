"
A trait for test purposes
"
Class {
	#name : #WeakSetTest,
	#superclass : #TestCase,
	#category : #'Collections-Weak-Tests-Base'
}

{ #category : #'building suites' }
WeakSetTest class >> shouldInheritSelectors [

^true
]

{ #category : #requirements }
WeakSetTest >> classToBeTested [

	^ WeakSet
]

{ #category : #tests }
WeakSetTest >> testAddEqualElements [
	| ws o2 o3 |
	o2 := 1 / 2.
	o3 := '123' copy.
	ws := self classToBeTested new.
	ws add: o2.
	ws add: o3.
	self assert: ws size equals: 2.
	self assert: (ws includes: o2).
	self assert: (ws includes: o3).

	"inclusion test does use equality, not identity"
	self assert: (ws includes: o3 copy) description: 'WeakSet is not WeakIdentitySet'.

	"only one copy is added"
	ws add: o3 copy.
	self assert: ws size equals: 2
]

{ #category : #tests }
WeakSetTest >> testAddIncludesSizeReclaim [
	| ws o2 o3 |
	o2 := 1 / 2.
	o3 := '123' copy.
	ws := self classToBeTested new.
	ws add: o2.
	ws add: o3.
	self assert: ws size equals: 2.
	self assert: (ws includes: o2).
	self assert: (ws includes: o3).

	"inclusion test does use equality, not identity"
	self assert: (ws includes: o3 copy) description: 'WeakSet are not WeakIdentitySet'.

	"only one copy is added"
	ws add: o3 copy.
	self assert: ws size equals: 2.

	"reclame objects so that slots of ws are nilled out"
	o2 := o3 := nil.
	Smalltalk garbageCollect.
	self deny: (ws includes: 1 / 2).
	self deny: (ws includes: '123' copy).

	"fast #size is not updated automatically by dead object reclamation
	But there is a slowSize trying to tell the truth"
	self assert: ws slowSize equals: 0
]

{ #category : #tests }
WeakSetTest >> testAddNil [
	| ws |
	ws := self classToBeTested new.
	ws add: nil.
	self assert: (ws includes: nil)
]

{ #category : #tests }
WeakSetTest >> testAnyOneWhenAllContentsWasGarbaged [
	| ws o |
	o := Object new.
	ws := self classToBeTested with: o.
	o := nil.
	Smalltalk garbageCollect.
	self assert: ws anyOne equals: nil
]

{ #category : #tests }
WeakSetTest >> testAsArray [
	| item set |
	set := self classToBeTested new.

	self assert: set asArray equals: #().

	item := Object new.
	set add: item.

	self assert: set asArray equals: {item}.

	item := nil.
	Smalltalk garbageCollect.

	self assert: set asArray equals: #()
]

{ #category : #tests }
WeakSetTest >> testCollisions [

	| ws o1 o2 o5 on remember forget |

	"create a weak set"
	ws := self classToBeTested new: 15.
	
	"select some fractions wanting same place in ws array"
	o1 := (2 to: 100) select: [:i | (ws scanFor: 1 / i) = 1].
	o2 := (2 to: 100) select: [:i | (ws scanFor: 1 / i) = 2].
	o5 := (2 to: 100) select: [:i | (ws scanFor: 1 / i) = 5].
	on := (2 to: 200) select: [:i | (ws scanFor: 1 / i) = (ws array size - 1)].
	
	"Add some fractions to the weak set, and remember a pointer for a few of them"
	remember := OrderedCollection new.
	forget := OrderedCollection new.
	ws add: (remember add: 1 / o1 first).
	ws add: (forget add: 1 / on second).
	ws add: (forget add: 1 / o1 second).
	ws add: (forget add: 1 / o5 second).
	ws add: (forget add: 1 / o2 second).
	ws add: (forget add: 1 / o1 third).
	ws add: (remember add: 1 / o2 first).
	ws add: (forget add: 1 / o5 third).
	ws add: (forget add: 1 / on third).
	ws add: (remember add: 1 / o2 fourth).
	ws add: (remember add: 1 / on first).
	ws add: (remember add: 1 / o5 first).
	
	"forget and reclaim all entries but those in remember"
	forget := nil.
	Smalltalk garbageCollect.
	
	remember do: [:m | self assert: (ws includes: m)].
	ws add: 1/on second.
	remember do: [:m | self assert: (ws includes: m)].
	
	ws add: (remember add: 1 / o1 fourth).
	ws add: (remember add: 1 / on fourth).
	remember remove: (ws remove: (1 / o5 first)).
	remember remove: (ws remove: (1 / on first)).
	remember remove: (ws remove: (1 / o2 first)).
	remember remove: (ws remove: (1 / o1 first)).
	remember do: [:m | self assert: (ws includes: m)].
	ws add: 1/on second.
	ws add: 1/o5 second.
	remember do: [:m | self assert: (ws includes: m)].
	
]

{ #category : #tests }
WeakSetTest >> testDoAfter [
	| input weakSet array |
	input := (1 to: 11) collect: [ :each | each asString asSymbol ].	"Some symbols might be garbage collected without this variable"
	weakSet := self classToBeTested withAll: input.
	array := weakSet asArray.	"Assume that the elements will have the same order as the internal array of the weakset"
	0 to: array size do: [ :index | 
		| element result |
		element := array at: index ifAbsent: nil.
		result := Array new: weakSet size - index streamContents: [ :stream | weakSet do: [ :each | stream nextPut: each ] after: element ].
		self assert: result sort equals: (array allButFirst: index) sort ]
]

{ #category : #tests }
WeakSetTest >> testDoDontIterateOnReclaimedObjects [
	| ws o1 o2 size |
	ws := self classToBeTested new.
	2 to: 20 do: [ :i | ws add: 1 / i ].

	o1 := 3.0.
	o2 := 4.0.
	ws
		add: o1;
		add: o2.

	"Reclaim memory"
	Smalltalk garbageCollect.

	size := 0.
	ws
		do: [ :each | 
			size := size + 1.
			self deny: each isNil ].

	self assert: size equals: 2
]

{ #category : #tests }
WeakSetTest >> testDontGrowWhenUnecessary [
	| ws objs initialSize |
	objs := (2 to: 20) collect: [:i | 1 / i].
	
	ws := self classToBeTested new: 20.
	initialSize := ws array size.
	objs do: [:k | ws add: k].
	objs do: [:k | ws remove: k].
	self assert: ws array size = initialSize
		description: 'The WeakSet did not have to grow because enough room were preallocated'.
	
	objs do: [:k | ws add: k + 1].
	Smalltalk garbageCollect.
	objs do: [:k | ws add: k].
	self assert: ws array size = initialSize
		description: 'The WeakSet did not have to grow because slots of reclaimed objects were recycled'.
]

{ #category : #tests }
WeakSetTest >> testGrowWhenNecessary [
	| ws objs initialSize |
	objs := (2 to: 20) collect: [:i | 1 / i].
	ws := self classToBeTested new: 5.
	initialSize := ws array size.
	1 to: objs size do: [:k | ws add: (objs at: k)].
	self assert: ws array size > initialSize
		description: 'The WeakSet grown because not enough room were preallocated'.
]

{ #category : #tests }
WeakSetTest >> testGrowWithNil [
	"This test covers that grow take into account that nil are wrapped elements of sets"
	| set |
	set := self classToBeTested new.
	set add: nil.
	set grow.
	self assert: (set includes: nil)
]

{ #category : #tests }
WeakSetTest >> testIncludes [	
	
	| weakSet transientFakeNilObject |
	weakSet := self classToBeTested new.
	#(true nil 1) do: [ :each | self deny: (weakSet includes: each) ].
	weakSet add: true.
	self assert: (weakSet includes: true).
 	weakSet remove: true.
	self deny: (weakSet includes: true).
	transientFakeNilObject := ((1 to: 1000) detect: [ :each | each asString hash - nil hash \\ weakSet capacity = 0 ]) asString. "this string will occupy the same slot as nil would"

	weakSet add: transientFakeNilObject.
	transientFakeNilObject := transientFakeNilObject copy.
	Smalltalk garbageCollect. "get rid of transientFakeNilObject"
	self deny: (weakSet includes: transientFakeNilObject).
	self deny: (weakSet includes: nil)
]

{ #category : #tests }
WeakSetTest >> testIncludesNil [

	| ws |
	ws := self classToBeTested new.
	self deny: (ws includes: nil).
	
	"After reclamation, should not includes nil: nil counts for nothing"
	ws add: 1/2.
	ws add: 1/3.
	Smalltalk garbageCollect.
	self deny: (ws includes: nil).
]
