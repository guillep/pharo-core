"
I represent an occurrence of a pragma in a compiled method.  A pragma is a literal message pattern that occurs between angle brackets at the start of a method after any temporaries.  A common example is the primitive pragma:
	<primitive: 123 errorCode: 'errorCode'>
but one can add one's own and use them as metadata attached to a method.  Because pragmas are messages one can browse senders and implementors and perform them.  One can query a method for its pragmas by sendng it the pragmas message, which answers an Array of instances of me, one for each pragma in the method.

I can provide information about the defining class, method, its selector, as well as the information about the pragma keyword and its arguments. See the two 'accessing' protocols for details. 'accessing-method' provides information about the method the pragma is found in, while 'accessing-pragma' is about the pragma itself.

Instances are retrieved using one of the pragma search methods of the 'finding' protocol on the class side.

To browse all methods with pragmas in the system evaluate
	SystemNavigation new browseAllSelect: [:m| m pragmas notEmpty]
and to browse all nonprimitive methods with pragmas evaluate
	SystemNavigation new browseAllSelect: [:m| m primitive isZero and: [m pragmas notEmpty]]
"
Class {
	#name : #Pragma,
	#superclass : #Object,
	#instVars : [
		'method',
		'arguments',
		'selector'
	],
	#classInstVars : [
		'pragmaCache'
	],
	#category : #'Kernel-Pragmas'
}

{ #category : #cache }
Pragma class >> addToCache: aPragma [
	"when a method is added to a class, the Pragma is added to the cache"
	self pragmaCache
		at: aPragma selector
		ifAbsentPut: [ WeakIdentitySet new ].
	(self pragmaCache at: aPragma selector) add: aPragma
]

{ #category : #cache }
Pragma class >> all [
	"all pragmas whose methods are currently installed in the system"
	^ self pragmaCache values flattened select: [ :each | 
		  each method isInstalled ]
]

{ #category : #finding }
Pragma class >> allNamed: aSymbol [

	"Answer a collection of all pragmas whose selector is aSymbol."

	| pragmas |
	pragmas := self pragmaCache at: aSymbol ifAbsent: [ ^ #(  ) ].
	"if there are none, we can remove the entry in the cache"
	pragmas ifEmpty: [ self pragmaCache removeKey: aSymbol ifAbsent: [  ] ].
	"we check if the pragma is really from an installed method 
	(others will be cleaned up by the gc when the method is garbadge collected)"
	^ (pragmas select: [ :each | each method isInstalled ]) asArray
]

{ #category : #finding }
Pragma class >> allNamed: aSymbol from: aSubClass to: aSuperClass [
	"Answer a collection of all pragmas found in methods of all classes between aSubClass and aSuperClass (inclusive) whose keyword is aSymbol."

	^ Array
		streamContents: [ :stream | 
			aSubClass
				withAllSuperclassesDo: [ :class | 
					class pragmasDo: [ :pragma | 
							pragma selector = aSymbol
								ifTrue: [ stream nextPut: pragma ] ].
					aSuperClass = class
						ifTrue: [ ^ stream contents ] ] ]
]

{ #category : #finding }
Pragma class >> allNamed: aSymbol from: aSubClass to: aSuperClass sortedByArgument: anInteger [
	"Answer a collection of all pragmas found in methods of all classes between aSubClass and aSuperClass (inclusive) whose keyword is aSymbol, sorted according to argument anInteger."

	^ self allNamed: aSymbol from: aSubClass to: aSuperClass sortedUsing: [ :a :b | (a argumentAt: anInteger) < (b argumentAt: anInteger) ].
]

{ #category : #finding }
Pragma class >> allNamed: aSymbol from: aSubClass to: aSuperClass sortedUsing: aSortBlock [
	"Answer a collection of all pragmas found in methods of all classes between aSubClass and aSuperClass (inclusive) whose keyword is aSymbol, sorted according to aSortBlock."
	
	^ (self allNamed: aSymbol from: aSubClass to: aSuperClass) sort: aSortBlock.
]

{ #category : #finding }
Pragma class >> allNamed: aSymbol in: aClass [
	"Answer a collection of all pragmas found in methods of aClass whose selector is aSymbol."
	
	^ Array streamContents: [ :stream |
		 aClass pragmasDo: [ :pragma |
			pragma selector = aSymbol
				ifTrue: [ stream nextPut: pragma ] ] ]
]

{ #category : #finding }
Pragma class >> allNamed: aSymbol in: aClass sortedByArgument: anInteger [
	"Answer a collection of all pragmas found in methods of aClass whose keyword is aSymbol, sorted according to argument anInteger."

	^ self allNamed: aSymbol in: aClass sortedUsing: [ :a :b | (a argumentAt: anInteger) < (b argumentAt: anInteger) ].
]

{ #category : #finding }
Pragma class >> allNamed: aSymbol in: aClass sortedUsing: aSortBlock [
	"Answer a collection of all pragmas found in methods of aClass whose keyword is aSymbol, sorted according to aSortBlock."
	
	^ (self allNamed: aSymbol in: aClass) sort: aSortBlock.
]

{ #category : #'instance creation' }
Pragma class >> for: aMethod selector: aSelector arguments: anArray [
	^self new
		method: aMethod;
		selector: aSelector;
		arguments: anArray;
		yourself
]

{ #category : #cache }
Pragma class >> pragmaCache [

	^ pragmaCache ifNil: [ pragmaCache := Dictionary new ]
]

{ #category : #private }
Pragma class >> selector: aSymbol arguments: anArray [
	^ self new
		selector: aSymbol;
		arguments: anArray;
		yourself
]

{ #category : #comparing }
Pragma >> = aPragma [

	self == aPragma ifTrue: [^true].
	self species == aPragma species ifFalse: [^false].

	self method = aPragma method ifFalse: [^false].
	self method selector = aPragma method selector ifFalse: [ ^false ].
	self selector = aPragma selector ifFalse: [^false].
	self arguments = aPragma arguments ifFalse: [^false].

	^true.
]

{ #category : #comparing }
Pragma >> analogousCodeTo: anObject [ 
	^self class == anObject class
	  and: [self selector == anObject selector
	  and: [arguments = anObject arguments]]
]

{ #category : #'accessing-pragma' }
Pragma >> argumentAt: anInteger [
	"Answer one of the arguments of the pragma."
	
	^ self arguments at: anInteger.
]

{ #category : #'accessing-pragma' }
Pragma >> argumentNamed: aSymbol [
	"Answer the argument of the pragma after the keyword given as parameter.
	If none, raise an error."

	^ self argumentNamed: aSymbol ifNone: [ self error: 'No argument of this name.' ]
]

{ #category : #'accessing-pragma' }
Pragma >> argumentNamed: aSymbol ifNone: aBlockClosure [
	"Answer the argument of the pragma after the keyword given as parameter.
	If none, return the result of the block given as parameter.
	
	I am more readable than #argumentAt: but also slower."

	^ self argumentAt:
		(self selector keywords
			indexOf: aSymbol asMutator
			ifAbsent: [ ^ aBlockClosure value])
]

{ #category : #'accessing-pragma' }
Pragma >> arguments [
	"Answer the arguments of the receiving pragma. For a pragma defined as <key1: val1 key2: val2> this will answer #(val1 val2)."
	
	^ arguments
]

{ #category : #initialization }
Pragma >> arguments: anArray [
	arguments := anArray
]

{ #category : #printing }
Pragma >> displayStringOn: stream [
	self method displayStringOn: stream.
	stream space.
	self printOn: stream
]

{ #category : #testing }
Pragma >> hasLiteral: aLiteral [
	^self selector == aLiteral 
	   or: [arguments hasLiteral: aLiteral]
]

{ #category : #comparing }
Pragma >> hash [

	| hash |

	hash := self method hash bitXor: self selector hash.
	1 to: self basicSize do: [:index | hash := hash bitXor: (self basicAt: index) hash].

	^hash.
]

{ #category : #querying }
Pragma >> key [
	"Answer the keyword of the pragma (the selector of its message pattern).
	 This accessor provides polymorphism with Associations used for properties."
	^self selector
]

{ #category : #accessing }
Pragma >> message [
	"Answer the message of the receiving pragma."
	
	^ Message selector: self selector arguments: self arguments. 
]

{ #category : #'accessing-method' }
Pragma >> method [
	"Answer the compiled-method containing the pragma."
	
	^ method
]

{ #category : #initialization }
Pragma >> method: aCompiledMethod [
	method := aCompiledMethod
]

{ #category : #'accessing-method' }
Pragma >> methodClass [
	"Answer the class of the method containing the pragma."
	
	^ method methodClass
]

{ #category : #view }
Pragma >> methodSelector [
	"Answer the selector of the method containing the pragma.
	 Do not confuse this with the selector of the pragma's message pattern."
	
	^method selector
]

{ #category : #'accessing-pragma' }
Pragma >> numArgs [
	"Answer the number of arguments in the pragma."

	^ self arguments size.
]

{ #category : #printing }
Pragma >> printOn: aStream [
	aStream nextPut: $<.
	self selector precedence = 1
		ifTrue: [ aStream nextPutAll: self selector ]
		ifFalse: [
			self selector keywords with: self arguments do: [ :key :arg |
				aStream nextPutAll: key; space; print: arg; space ].
			aStream skip: -1 ].
	aStream nextPut: $>.
]

{ #category : #testing }
Pragma >> refersToLiteral: aLiteral [
	^self selector == aLiteral 
	   or: [arguments hasLiteral: aLiteral]
]

{ #category : #accessing }
Pragma >> selector [
	"Answer the selector of the pragma.
	 For a pragma defined as <key1: val1 key2: val2> this will answer #key1:key2:."
	
	^ selector
]

{ #category : #initialization }
Pragma >> selector: aSymbol [
	selector := aSymbol
]

{ #category : #sending }
Pragma >> sendTo: anObject [
	"Send the pragma keyword together with its arguments to anObject and answer the result."
	
	^ anObject perform: self selector withArguments: self arguments
]

{ #category : #processing }
Pragma >> withArgumentsDo: aBlock [
	"Pass the arguments of the receiving pragma into aBlock and answer the result."
	
	^ aBlock valueWithArguments: self arguments
]
