"
I represent intentend to provide complete coverage for the Continuation class.
"
Class {
	#name : #ContinuationTest,
	#superclass : #TestCase,
	#instVars : [
		'tmp',
		'tmp2'
	],
	#category : #'Kernel-Tests-Methods'
}

{ #category : #utilities }
ContinuationTest >> callcc: aBlock [
	^ Continuation currentDo: aBlock
]

{ #category : #functions }
ContinuationTest >> intersect: aSet withAll: sets [
	^ sets
		ifEmpty: [ aSet ]
		ifNotEmpty: [ self
				intersect: aSet
				withCollection: (self intersect: sets first withAll: sets allButFirst) ]
]

{ #category : #functions }
ContinuationTest >> intersect: aSet withAll: sets continuation: hop [
	^ aSet
		ifEmpty: [ hop value: aSet ]
		ifNotEmpty: [ sets
				ifEmpty: [ aSet ]
				ifNotEmpty: [ self
						intersect: aSet
						withCollection:
							(self
								intersect: sets first
								withAll: sets allButFirst
								continuation: hop) ] ]
]

{ #category : #functions }
ContinuationTest >> intersect: aLinkedList withCollection: aCollection [
	^ aLinkedList
		ifNotEmpty: [ (self
				intersectValueLink: aLinkedList firstLink
				withCollection: aCollection)
				ifNil: [ LinkedList new ]
				ifNotNil: [ :link | LinkedList with: link ] ]
]

{ #category : #functions }
ContinuationTest >> intersect: aLinkedList withCollection: aCollection continuation: hop [
	^ aCollection
		ifEmpty: [ hop value: aCollection ]
		ifNotEmpty: [ self intersect: aLinkedList withCollection: aCollection ]
]

{ #category : #functions }
ContinuationTest >> intersectAll: sets [
	^ sets
		ifNotEmpty: [ self intersect: sets first withAll: sets allButFirst ]
]

{ #category : #functions }
ContinuationTest >> intersectAllWithCC: sets [
	^ sets
		ifNotEmpty: [ Continuation
				currentDo:
					[ :cc | self intersect: sets first withAll: sets allButFirst continuation: cc ] ]
]

{ #category : #functions }
ContinuationTest >> intersectValueLink: aValueLink withCollection: anotherSet [
	^ aValueLink
		ifNotNil: [ | car cdr |
			car := aValueLink value.
			cdr := self
				intersectValueLink: aValueLink nextLink
				withCollection: anotherSet.
			(anotherSet includes: car)
				ifTrue: [ car ~~> cdr ]
				ifFalse: [ cdr ] ]
]

{ #category : #functions }
ContinuationTest >> intersectWithCC: aSet withAll: sets continuation: hop [
	^ aSet
		ifEmpty: [ hop value: aSet ]
		ifNotEmpty: [ sets
				ifEmpty: [ aSet ]
				ifNotEmpty: [ self
						intersect: aSet
						withCollection:
							(self
								intersectWithCC: sets first
								withAll: sets allButFirst
								continuation: hop)
						continuation: hop ] ]
]

{ #category : #functions }
ContinuationTest >> intersectWithCCAllWithCC: sets [
	^ sets
		ifNotEmpty: [ Continuation
				currentDo: [ :cc | 
					self
						intersectWithCC: sets first
						withAll: sets allButFirst
						continuation: cc ] ]
]

{ #category : #functions }
ContinuationTest >> leftmost: aBlock tree: aTree [
	^ self
		callcc: [ :skip | self leftmost: aBlock tree: aTree continuation: skip ]
]

{ #category : #functions }
ContinuationTest >> leftmost: aBlock tree: aTree continuation: out [
	^ (aTree isNotNil and: [ aTree isMemberOf: ValueLink ])
		ifTrue: [ | car |
			car := aTree value.
			(car isKindOf: Link)
				ifTrue: [ self leftmost: aBlock tree: car continuation: out ]
				ifFalse: [ (aBlock value: car)
						ifTrue: [ out value: car ] ].
			self leftmost: aBlock tree: aTree nextLink continuation: out ]
		ifFalse: [ nil ]
]

{ #category : #printing }
ContinuationTest >> printStringOfTree: aValueLink [
	^ String
		streamContents: [ :aStream | self printStringOfTree: aValueLink onStream: aStream ]
]

{ #category : #printing }
ContinuationTest >> printStringOfTree: aValueLink onStream: aStream [
	aStream nextPut: $(.
	(aValueLink isMemberOf: Link)
		ifFalse: [ | cell |
			cell := aValueLink.
			[ | car |
			car := cell value.
			(car isKindOf: Link)
				ifTrue: [ self printStringOfTree: car onStream: aStream ]
				ifFalse: [ car printOn: aStream ].
			cell nextLink ifNotNil: [ aStream nextPut: Character space ].
			cell := cell nextLink.
			cell isMemberOf: ValueLink ] whileTrue.
			cell
				ifNotNil: [ aStream
						nextPut: $.;
						nextPut: Character space.
					cell printOn: aStream ] ].
	aStream nextPut: $)
]

{ #category : #functions }
ContinuationTest >> remove: anObj oneStar: aTree [
	| newTree sentinel |
	sentinel := #absent.
	newTree := self
		callcc: [ :oh | 
			self
				remove: anObj
				oneStar: aTree
				sentinel: sentinel
				continuation: oh ].
	^ newTree = sentinel
		ifTrue: [ aTree ]
		ifFalse: [ newTree ]
]

{ #category : #functions }
ContinuationTest >> remove: anObj oneStar: aTree sentinel: aSymbol continuation: oh [
	^ aTree
		ifNil: [ oh value: aSymbol ]
		ifNotNil: [ | car cdr naturalRecursion |
			car := aTree value.
			cdr := aTree nextLink.
			naturalRecursion := [ | newCdr |
			newCdr := self
				remove: anObj
				oneStar: cdr
				sentinel: aSymbol
				continuation: oh.
			car ~~> newCdr ].
			(car isMemberOf: ValueLink)
				ifTrue: [ | newCar |
					newCar := Continuation
						currentDo: [ :ooh | 
							self
								remove: anObj
								oneStar: car
								sentinel: aSymbol
								continuation: ooh ].
					newCar = aSymbol
						ifTrue: naturalRecursion
						ifFalse: [ newCar ~~> cdr ] ]
				ifFalse: [ anObj = car
						ifTrue: [ cdr ]
						ifFalse: naturalRecursion ] ]
]

{ #category : #functions }
ContinuationTest >> remove: anObj oneStarWithTry: aTree [
	^ Continuation
		try: [ :oh | self remove: anObj oneStarWithTry: aTree continuation: oh ]
		otherwise: [ aTree ]
]

{ #category : #functions }
ContinuationTest >> remove: anObj oneStarWithTry: aTree continuation: oh [
	^ aTree
		ifNil: [ oh value: #absent ]
		ifNotNil: [ | car cdr naturalRecursion |
			car := aTree value.
			cdr := aTree nextLink.
			naturalRecursion := [ | newCdr |
			newCdr := self remove: anObj oneStarWithTry: cdr continuation: oh.
			car ~~> newCdr ].
			(car isMemberOf: ValueLink)
				ifTrue: [ Continuation
						try: [ :ooh | 
							| newCar |
							newCar := self
								remove: anObj
								oneStarWithTry: car
								continuation: ooh.
							newCar ~~> cdr ]
						otherwise: naturalRecursion ]
				ifFalse: [ anObj = car
						ifTrue: [ cdr ]
						ifFalse: naturalRecursion ] ]
]

{ #category : #functions }
ContinuationTest >> remove: anObj uptoLast: aLinkedList [
	^ aLinkedList
		ifNotEmpty: [ | valueLink |
			valueLink := Continuation
				currentDo: [ :skip | 
					self
						remove: anObj
						uptoLastValueLink: aLinkedList firstLink
						continuation: skip ].
			LinkedList with: valueLink ]
]

{ #category : #functions }
ContinuationTest >> remove: anObj uptoLastValueLink: aValueLink continuation: skip [
	^ aValueLink
		ifNotNil: [ | car cdr |
			car := aValueLink value.
			cdr := self
				remove: anObj
				uptoLastValueLink: aValueLink nextLink
				continuation: skip.
			anObj = car
				ifTrue: [ skip value: cdr ]
				ifFalse: [ car ~~> cdr ] ]
]

{ #category : #tests }
ContinuationTest >> testBlockEscape [
	| x |
	tmp := 0.
	x := [ tmp := tmp + 1.
	tmp2 value ].
	self
		callcc: [ :cc | 
			tmp2 := cc.
			x value ].
	tmp2 := [  ].
	x value.
	self assert: tmp equals: 2
]

{ #category : #tests }
ContinuationTest >> testBlockTemps [
	| y |
	#(1 2 3)
		do: [ :i | 
			| x |
			x := i.
			tmp
				ifNil: [ tmp2 := self
						callcc: [ :cc | 
							tmp := cc.
							[ :q |  ] ] ].
			tmp2 value: x.
			x := 17 ].
	y := self
		callcc: [ :cc | 
			tmp value: cc.
			42 ].
	self assert: y equals: 1
]

{ #category : #tests }
ContinuationTest >> testBlockVars [
	| continuation |
	tmp := 0.
	tmp := (self
		callcc: [ :cc | 
			continuation := cc.
			0 ]) + tmp.
	tmp2
		ifNotNil: [ tmp2 value ]
		ifNil: [ #(1 2 3)
				do: [ :i | 
					self
						callcc: [ :cc | 
							tmp2 := cc.
							continuation value: i ] ] ].
	self assert: tmp equals: 6
]

{ #category : #tests }
ContinuationTest >> testIntersectAll [
	self
		assert:
			(self
				intersectAll:
					{(LinkedList with: 3 with: #mangos with: #and).
					(LinkedList with: 3 with: #kiwis with: #and).
					(LinkedList with: 3 with: #hamburges)})
		equals: {3}.
	self
		assert:
			(self
				intersectAll:
					{(LinkedList with: 3 with: #steaks with: #and).
					(LinkedList with: #no with: #food with: #and).
					(LinkedList with: #three with: #baked with: #potatoes).
					(LinkedList with: 3 with: #diet with: #hamburges)})
		equals: {}.
	self
		assert:
			(self
				intersectAll:
					{(LinkedList with: 3 with: #steaks with: #and).
					LinkedList new.
					(LinkedList with: #three with: #baked with: #potatoes).
					(LinkedList with: 3 with: #diet with: #hamburges)})
		equals: {}.
	self
		assert:
			(self
				intersectAllWithCC:
					{(LinkedList with: 3 with: #steaks with: #and).
					LinkedList new.
					(LinkedList with: #three with: #baked with: #potatoes).
					(LinkedList with: 3 with: #diet with: #hamburges)})
		equals: {}.
	self
		assert:
			(self
				intersectWithCCAllWithCC:
					{(LinkedList with: 3 with: #steaks with: #and).
					(LinkedList with: #no with: #food with: #and).
					(LinkedList with: #three with: #baked with: #potatoes).
					(LinkedList with: 3 with: #diet with: #hamburges)})
		equals: {}
]

{ #category : #tests }
ContinuationTest >> testIntersectWith [
	self
		assert:
			(self
				intersect: (LinkedList with: #apple with: #banana with: #avocado)
				withCollection: (LinkedList with: 1 with: 2 with: #apple))
		equals: (LinkedList with: #apple).
	self
		assert:
			(self
				intersect: ((1 to: 10) as: LinkedList)
				withCollection: (9 to: 20))
		equals: (9 to: 10).
	self
		assert:
			(self
				intersect: ((1 to: 10) as: LinkedList)
				withCollection: (11 to: 20))
		equals: {}
]

{ #category : #tests }
ContinuationTest >> testLeftmost [
	| tree |
	tree := #a ~~> nil ~~> nil
		~~> (4 ~~> (Link new ~~> (1 ~~> nil ~~> nil))).
	self
		assert: (self printStringOfTree: tree)
		equals: '(((#a)) 4 () (1))'.
	self assert: (self leftmost: #isSymbol tree: tree) equals: #a.
	self assert: (self leftmost: #isInteger tree: tree) equals: 4.
	self assert: (self leftmost: [ :v | v = 1 ] tree: tree) equals: 1.
	self assert: (self leftmost: #isNil tree: tree) equals: nil.
	self assert: (self leftmost: [ :v | v = 5 ] tree: tree) equals: nil
]

{ #category : #tests }
ContinuationTest >> testMethodTemps [
	| i continuation |
	i := 0.
	i := i + (self callcc: [:cc | continuation := cc. 1]).
	self assert: i ~= 3.
	i = 2 ifFalse: [ continuation value: 2 ]
]

{ #category : #tests }
ContinuationTest >> testReentrant [
	| assoc |
	assoc := self callcc: [ :cc | cc -> 0 ].
	assoc value: assoc value + 1.
	self assert: assoc value ~= 5.
	assoc value = 4
		ifFalse: [ assoc key value: assoc ]
]

{ #category : #tests }
ContinuationTest >> testRemoveOneStar [
	| tree1 tree2 |
	tree1 := #Swedish ~~> (#rye ~~> nil)
		~~>
			(#French ~~> (#mustard ~~> (#salad ~~> (#turkey ~~> nil)) ~~> nil)
				~~> (#salad ~~> nil)).
	tree2 := #pasta ~~> (#meat ~~> nil)
		~~>
			(#pasta
				~~>
					(#noodles ~~> (#meat ~~> (#sauce ~~> nil))
						~~> (#meat ~~> (#tomatoes ~~> nil)))).
	self
		assert: (self printStringOfTree: tree1)
		equals: '((#Swedish #rye) (#French (#mustard #salad #turkey)) #salad)'.
	self
		assert: (self printStringOfTree: tree2)
		equals: '((#pasta #meat) #pasta (#noodles #meat #sauce) #meat #tomatoes)'.
	self
		assert: (self printStringOfTree: (self remove: #salad oneStar: tree1))
		equals: '((#Swedish #rye) (#French (#mustard #turkey)) #salad)'.
	self
		assert: (self printStringOfTree: (self remove: #salad oneStarWithTry: tree1))
		equals: '((#Swedish #rye) (#French (#mustard #turkey)) #salad)'.
	self
		assert: (self printStringOfTree: (self remove: #meat oneStar: tree2))
		equals: '((#pasta) #pasta (#noodles #meat #sauce) #meat #tomatoes)'.
	self
		assert: (self printStringOfTree: (self remove: #meat oneStarWithTry: tree2))
		equals: '((#pasta) #pasta (#noodles #meat #sauce) #meat #tomatoes)'
]

{ #category : #tests }
ContinuationTest >> testRemoveUptoLast [
	self
		assert:
			(self
				remove: #cookies
				uptoLast:
					(LinkedList new
						add: #cookies;
						add: #chocolate;
						add: #mints;
						add: #caramel;
						add: #delight;
						add: #ginger;
						add: #snaps;
						add: #desserts;
						add: #chocolate;
						add: #mousse;
						add: #vanilla;
						add: #ice;
						add: #cream;
						add: #German;
						add: #chocolate;
						add: #cake;
						add: #more;
						add: #cookies;
						"from this down to the last should be kept in the result
						because the previous #cookies is the last one #cookies in the list."
							add: #gingerbreadman;
						add: #chocolate;
						add: #chip;
						add: #brownies;
						yourself))
		equals:
			(LinkedList new
				add: #gingerbreadman;
				add: #chocolate;
				add: #chip;
				add: #brownies;
				yourself)
]

{ #category : #tests }
ContinuationTest >> testSimpleCallCC [
	| x continuation |
	x := self callcc: [ :cc | continuation := cc. false ].
	x ifFalse: [ continuation value: true ].
	self assert: x
]

{ #category : #tests }
ContinuationTest >> testSimpleStoreCallCC [
	| x continuation |
	continuation := self callcc: #yourself.
	x := false.
	continuation = true
		ifTrue: [ x := true ]
		ifFalse: [ continuation value: true.
			self error: 'This message shouldn''t be sent, ever.' ].
	self assert: x
]

{ #category : #tests }
ContinuationTest >> testSimplestCallCC [
	| x |
	x := self callcc: [ :cc | cc value: true ].
	self assert: x
]

{ #category : #tests }
ContinuationTest >> testTwoInARow [
	| tree1 tree2 |
	tree1 := #solid ~~> (#food ~~> nil ~~> (Link new ~~> nil))
		~~> (#food ~~> nil ~~> nil ~~> nil ~~> nil).
	tree2 := #solid ~~> (#food ~~> nil ~~> (#marmellade ~~> nil))
		~~> (#food ~~> nil ~~> nil ~~> nil ~~> nil).
	self
		assert: (self printStringOfTree: tree1)
		equals: '((#solid (#food) ()) (((#food))))'.
	self assert: (TwoInARowStar new tree: tree1) equals: true.
	self
		assert: (self printStringOfTree: tree2)
		equals: '((#solid (#food) #marmellade) (((#food))))'.
	self assert: (TwoInARowStar new tree: tree2) equals: false
]
