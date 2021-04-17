"
RBSequenceNode is an AST node that represents a sequence of statements. Both RBBlockNodes and RBMethodNodes contain these.

Instance Variables:
	leftBar	<Integer | nil>	the position of the left | in the temporaries definition
	rightBar	<Integer | nil>	the position of the right | in the temporaries definition
	statements	<SequenceableCollection of: RBReturnNode or RBValueNode> the statement nodes
	periods	<SequenceableCollection of: Integer>	the positions of all the periods that separate the statements
	temporaries	<SequenceableCollection of: RBVariableNode>	the temporaries defined


"
Class {
	#name : #RBSequenceNode,
	#superclass : #RBProgramNode,
	#instVars : [
		'leftBar',
		'rightBar',
		'statements',
		'periods',
		'temporaries'
	],
	#category : #'AST-Core-Nodes'
}

{ #category : #'instance creation' }
RBSequenceNode class >> leftBar: leftInteger temporaries: variableNodes rightBar: rightInteger [ 
	^(self new)
		leftBar: leftInteger
			temporaries: variableNodes
			rightBar: rightInteger;
		yourself
]

{ #category : #'instance creation' }
RBSequenceNode class >> statements: statementNodes [ 
	^self temporaries: #() statements: statementNodes
]

{ #category : #'instance creation' }
RBSequenceNode class >> temporaries: variableNodes statements: statementNodes [ 
	^(self new)
		temporaries: variableNodes;
		statements: statementNodes;
		yourself
]

{ #category : #comparing }
RBSequenceNode >> = anObject [ 
	"Can't send = to the temporaries and statements collection since they might change from arrays to OCs"

	self == anObject ifTrue: [^true].
	self class = anObject class ifFalse: [^false].
	self temporaries size = anObject temporaries size ifFalse: [^false].
	self temporaries
		with: anObject temporaries
		do: [:first :second | first = second ifFalse: [^false]].
	self statements size = anObject statements size ifFalse: [^false].
	self statements
		with: anObject statements
		do: [:first :second | first = second ifFalse: [^false]].
	^true
]

{ #category : #visiting }
RBSequenceNode >> acceptVisitor: aProgramNodeVisitor [
	^ aProgramNodeVisitor visitSequenceNode: self
]

{ #category : #'adding nodes' }
RBSequenceNode >> addFaultyNode: aNode [
"just like addNode, but ignore if we already include a return node, as we are faulty"
	aNode parent: self.
	statements := statements asOrderedCollection
		add: aNode;
		yourself.
	^ aNode
]

{ #category : #'adding nodes' }
RBSequenceNode >> addNode: aNode [
	aNode parent: self.
	(statements notEmpty and: [ statements last isReturn ])
		ifTrue: [ self error: 'Cannot add statement after return node' ].
	statements := statements asOrderedCollection
		add: aNode;
		yourself.
	^ aNode
]

{ #category : #'adding nodes' }
RBSequenceNode >> addNode: aNode after: anotherNode [

	| index |
	index := self indexOfNode: anotherNode.
	index = 0
		ifTrue: [ ^ self addNode: aNode ].
	statements := statements asOrderedCollection
		add: aNode afterIndex: index;
		yourself.
	aNode parent: self.
	^ aNode
]

{ #category : #'adding nodes' }
RBSequenceNode >> addNode: aNode before: anotherNode [
	| index |
	index := self indexOfNode: anotherNode.
	index = 0
		ifTrue: [ ^ self addNode: aNode ].
	statements := statements asOrderedCollection
		add: aNode beforeIndex: index;
		yourself.
	aNode parent: self.
	^ aNode
]

{ #category : #'adding nodes' }
RBSequenceNode >> addNodeFirst: aNode [
	aNode parent: self.
	statements := statements asOrderedCollection
		addFirst: aNode;
		yourself.
	^ aNode
]

{ #category : #'adding nodes' }
RBSequenceNode >> addNodeLast: aNode [

	self lastIsReturn
		ifTrue: [ self addNode: aNode before: self statements last ]
		ifFalse: [ self addNode: aNode ]
]

{ #category : #'adding nodes' }
RBSequenceNode >> addNodes: aCollection [
	aCollection do: [ :each | each parent: self ].
	(statements notEmpty and: [ statements last isReturn ])
		ifTrue: [ self error: 'Cannot add statement after return node' ].
	statements := statements asOrderedCollection
		addAll: aCollection;
		yourself.
	^ aCollection
]

{ #category : #'adding nodes' }
RBSequenceNode >> addNodes: aCollection before: anotherNode [
	aCollection do: [ :each | self addNode: each before: anotherNode ].
	^ aCollection
]

{ #category : #'adding nodes' }
RBSequenceNode >> addNodesFirst: aCollection [
	aCollection do: [ :each | each parent: self ].
	statements := statements asOrderedCollection
		addAllFirst: aCollection;
		yourself.
	^ aCollection
]

{ #category : #'adding nodes' }
RBSequenceNode >> addReturn [
	| node |
	statements isEmpty
		ifTrue: [ ^ nil ].
	statements last isReturn
		ifTrue: [ ^ statements last ].
	node := RBReturnNode value: statements last.
	statements at: statements size put: node.
	node parent: self.
	^ node
]

{ #category : #'adding nodes' }
RBSequenceNode >> addSelfReturn [
	| node |
	self lastIsReturn
		ifTrue: [ ^ self statements last ].
	node := RBReturnNode value: RBVariableNode selfNode.
	^ self addNode: node
]

{ #category : #'adding nodes' }
RBSequenceNode >> addTemporariesNamed: aCollection [
	^ aCollection collect: [ :each | self addTemporaryNamed: each ]
]

{ #category : #'adding nodes' }
RBSequenceNode >> addTemporaryNamed: aString [ 
	| variableNode |
	variableNode := RBVariableNode named: aString.
	variableNode parent: self.
	temporaries := temporaries copyWith: variableNode.
	^ variableNode
]

{ #category : #accessing }
RBSequenceNode >> allDefinedVariables [
	^(self temporaryNames asOrderedCollection)
		addAll: super allDefinedVariables;
		yourself
]

{ #category : #accessing }
RBSequenceNode >> allStatements [
	^ statements asOrderedCollection copy
			addAll: super allStatements;
			yourself

]

{ #category : #accessing }
RBSequenceNode >> allTemporaryVariables [
	^(self temporaryNames asOrderedCollection)
		addAll: super allTemporaryVariables;
		yourself
]

{ #category : #converting }
RBSequenceNode >> asSequenceNode [
	^self
]

{ #category : #querying }
RBSequenceNode >> bestNodeFor: anInterval [ 
	| node |
	node := super bestNodeFor: anInterval.
	node == self 
		ifTrue: 
			[(temporaries isEmpty and: [statements size == 1]) 
				ifTrue: [^statements first]].
	^node
]

{ #category : #accessing }
RBSequenceNode >> children [
	^(OrderedCollection new)
		addAll: temporaries;
		addAll: statements;
		yourself
]

{ #category : #matching }
RBSequenceNode >> copyInContext: aDictionary [ 
	^ self class new
		temporaries: (self copyList: self temporaries inContext: aDictionary);
		statements: (self copyList: self statements inContext: aDictionary);
		yourself
]

{ #category : #testing }
RBSequenceNode >> defines: aName [ 
	^temporaries anySatisfy: [:each | each name = aName]
]

{ #category : #testing }
RBSequenceNode >> directlyUses: aNode [ 
	^false
]

{ #category : #comparing }
RBSequenceNode >> equalTo: anObject withMapping: aDictionary [ 
	self class = anObject class ifFalse: [^false].
	self statements size = anObject statements size ifFalse: [^false].
	self statements
		with: anObject statements
		do: [:first :second | (first equalTo: second withMapping: aDictionary) ifFalse: [^false]].
	aDictionary values asSet size = aDictionary size ifFalse: [^false].	"Not a one-to-one mapping"
	self temporaries
		do: [:each | aDictionary removeKey: each name ifAbsent: []].
	^true
]

{ #category : #testing }
RBSequenceNode >> hasTemporaries [

	^ temporaries isNotEmpty
]

{ #category : #testing }
RBSequenceNode >> hasTemporaryNamed: aString [

	^ temporaries anySatisfy: [ :temp | temp name = aString ]
]

{ #category : #comparing }
RBSequenceNode >> hash [
	^ (self hashForCollection: self temporaries) bitXor: (self hashForCollection: self statements)
]

{ #category : #private }
RBSequenceNode >> indexOfNode: aNode [ 
	"Try to find the node by first looking for ==, and then for ="

	^(1 to: statements size) detect: [:each | (statements at: each) == aNode]
		ifNone: [statements indexOf: aNode]
]

{ #category : #initialization }
RBSequenceNode >> initialize [
	super initialize.
	periods := statements := temporaries := OrderedCollection new.
]

{ #category : #testing }
RBSequenceNode >> isFaulty [
	^self statements anySatisfy: [:each | each isFaulty]
]

{ #category : #testing }
RBSequenceNode >> isLast: aNode [ 
	| last |
	statements isEmpty ifTrue: [^false].
	last := statements last.
	^last == aNode or: 
			[last isMessage and: 
					[(#(#ifTrue:ifFalse: #ifFalse:ifTrue:) includes: last selector) 
						and: [last arguments anySatisfy: [:each | each isLast: aNode]]]]
]

{ #category : #testing }
RBSequenceNode >> isSequence [
	^true
]

{ #category : #testing }
RBSequenceNode >> lastIsReturn [
	^statements notEmpty and: [statements last lastIsReturn]
]

{ #category : #'accessing-token' }
RBSequenceNode >> leftBar [
	^ leftBar
]

{ #category : #'accessing-token' }
RBSequenceNode >> leftBar: anInteger [
	leftBar := anInteger
]

{ #category : #initialization }
RBSequenceNode >> leftBar: leftInteger temporaries: variableNodes rightBar: rightInteger [ 
	leftBar := leftInteger.
	self temporaries: variableNodes.
	rightBar := rightInteger
]

{ #category : #matching }
RBSequenceNode >> match: aNode inContext: aDictionary [ 
	self class = aNode class ifFalse: [^false].
	^(self 
		matchList: temporaries
		against: aNode temporaries
		inContext: aDictionary) and: 
				[self 
					matchList: statements
					against: aNode statements
					inContext: aDictionary]
]

{ #category : #'accessing-token' }
RBSequenceNode >> periods [
	^ periods
]

{ #category : #'accessing-token' }
RBSequenceNode >> periods: anArray [
	periods := anArray
]

{ #category : #copying }
RBSequenceNode >> postCopy [
	super postCopy.
	self temporaries: (self temporaries collect: [ :each | each copy ]).
	self statements: (self statements collect: [ :each | each copy ])
]

{ #category : #testing }
RBSequenceNode >> references: aVariableName [ 
	^statements anySatisfy: [:each | each references: aVariableName]
]

{ #category : #replacing }
RBSequenceNode >> removeDeadCode [
	(self isUsed ifTrue: [statements size - 1] ifFalse: [statements size]) 
		to: 1
		by: -1
		do: 
			[:i | 
			(statements at: i) isImmediateNode 
				ifTrue: 
					[self clearReplacements.
					statements removeAt: i]].
	super removeDeadCode
]

{ #category : #replacing }
RBSequenceNode >> removeNode: aNode [
	self replaceNode: aNode withNodes: #()
]

{ #category : #accessing }
RBSequenceNode >> removeTemporaryNamed: aName [ 
	temporaries := temporaries reject: [:each | each name = aName]
]

{ #category : #replacing }
RBSequenceNode >> replaceNode: aNode withNode: anotherNode [ 
	self statements: (statements 
				collect: [:each | each == aNode ifTrue: [anotherNode] ifFalse: [each]]).
	self temporaries: (temporaries 
				collect: [:each | each == aNode ifTrue: [anotherNode] ifFalse: [each]])
]

{ #category : #replacing }
RBSequenceNode >> replaceNode: aNode withNodes: aCollection [ 
	| index newStatements |
	self clearReplacements.
	index := self indexOfNode: aNode.
	newStatements := OrderedCollection new: statements size + aCollection size.
	1 to: index - 1 do: [:i | newStatements add: (statements at: i)].
	newStatements addAll: aCollection.
	index + 1 to: statements size
		do: [:i | newStatements add: (statements at: i)].
	aCollection do: [:each | each parent: self].
	statements := newStatements
]

{ #category : #'accessing-token' }
RBSequenceNode >> rightBar [
	^ rightBar
]

{ #category : #'accessing-token' }
RBSequenceNode >> rightBar: anInteger [
	rightBar := anInteger
]

{ #category : #accessing }
RBSequenceNode >> start [
	^ leftBar 
		ifNil: [statements isEmpty ifTrue: [1] ifFalse: [statements first start]]
]

{ #category : #accessing }
RBSequenceNode >> statements [
	^statements
]

{ #category : #accessing }
RBSequenceNode >> statements: stmtCollection [ 
	statements := stmtCollection.
	statements do: [:each | each parent: self]
]

{ #category : #accessing }
RBSequenceNode >> stop [
	^{  
	temporaries isEmpty ifTrue: [0] ifFalse: [ self temporaries last stop]. 
	periods isEmpty ifTrue: [0] ifFalse: [periods last].
	statements isEmpty ifTrue: [0] ifFalse: [statements last stop]
	} max
]

{ #category : #accessing }
RBSequenceNode >> temporaries [
	^temporaries
]

{ #category : #accessing }
RBSequenceNode >> temporaries: tempCollection [ 
	temporaries := tempCollection.
	temporaries do: [:each | each parent: self]
]

{ #category : #accessing }
RBSequenceNode >> temporaryNames [
	^temporaries collect: [:each | each name]
]

{ #category : #accessing }
RBSequenceNode >> temporaryVariables [
	^(super temporaryVariables asOrderedCollection)
		addAll: self temporaryNames;
		yourself
]

{ #category : #'adding nodes' }
RBSequenceNode >> transformLastToReturn [
	"transform the last statement, but this method returns the sequence, not the returnNode"
	self addReturn
]

{ #category : #testing }
RBSequenceNode >> uses: aNode [ 
	statements isEmpty ifTrue: [^false].
	aNode == statements last ifFalse: [^false].
	^self isUsed
]

{ #category : #querying }
RBSequenceNode >> whichNodeIsContainedBy: anInterval [ 
	| node |
	node := super whichNodeIsContainedBy: anInterval.
	node == self 
		ifTrue: 
			[(temporaries isEmpty and: [statements size == 1]) 
				ifTrue: [^statements first]].
	^node
]
