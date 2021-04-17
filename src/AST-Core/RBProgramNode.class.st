"
RBProgramNode is an abstract class that represents an abstract syntax tree node in a Smalltalk program.

Subclasses must implement the following messages:
	accessing
		start
		stop
	visitor
		acceptVisitor:
	testing
		isFaulty

The #start and #stop methods are used to find the source that corresponds to this node. ""source copyFrom: self start to: self stop"" should return the source for this node.

The #acceptVisitor: method is used by RBProgramNodeVisitors (the visitor pattern). This will also require updating all the RBProgramNodeVisitors so that they know of the new node.

The #isFaulty method is used to distinguish between valid nodes and nodes created from an invalid source Smalltalk code. For example, code parsed with RBParsers #parseFaultyExpression: or #parseFaultyMethod:.

Subclasses might also want to redefine match:inContext: and copyInContext: to do parse tree searching and replacing.

Subclasses that contain other nodes should override equalTo:withMapping: to compare nodes while ignoring renaming temporary variables, and children that returns a collection of our children nodes.

Instance Variables:
	properties	<Dictionary of: Symbol -> Object>	A set of properties set to this node, for example every node can have the Property #comment to attach the method comment or the comment of the code line this node represents. Other classes or tools may add more type of properties; for example, the reflectivity support adds properties for managing Metalinks. 
	parent	<RBProgramNode>	the node we're contained in

Class Variables:
	FormatterClass	<Behavior>	the formatter class that is used when we are formatted

"
Class {
	#name : #RBProgramNode,
	#superclass : #RBNode,
	#instVars : [
		'parent',
		'properties'
	],
	#classVars : [
		'FormatterClass'
	],
	#category : #'AST-Core-Nodes'
}

{ #category : #accessing }
RBProgramNode class >> formatterClass [
	^ FormatterClass ifNil: [ RBSimpleFormatter ] ifNotNil: [ FormatterClass ]
]

{ #category : #accessing }
RBProgramNode class >> formatterClass: aClass [
	FormatterClass := aClass
		
]

{ #category : #testing }
RBProgramNode class >> isAbstract [

	^ self == RBProgramNode
]

{ #category : #accessing }
RBProgramNode class >> optimizedSelectors [
	^ #( and: caseOf: caseOf:otherwise: ifFalse: ifFalse:ifTrue: ifNil: ifNil:ifNotNil: ifNotNil: ifNotNil:ifNil: ifTrue: ifTrue:ifFalse: or: to:by:do: to:do: whileFalse whileFalse: whileTrue whileTrue: )
]

{ #category : #accessing }
RBProgramNode class >> resetFormatter [

	self formatterClass: nil

	
]

{ #category : #replacing }
RBProgramNode >> addReplacement: aStringReplacement [
	parent ifNil: [^self].
	parent addReplacement: aStringReplacement
]

{ #category : #accessing }
RBProgramNode >> allArgumentVariables [
	| children |
	children := self children.
	children isEmpty ifTrue: [^#()].
	^children inject: OrderedCollection new
		into: 
			[:vars :each | 
			vars
				addAll: each allArgumentVariables;
				yourself]
]

{ #category : #iterating }
RBProgramNode >> allChildren [
	| children |
	children := OrderedCollection new.
	self nodesDo: [ :each | children addLast: each ].
	^ children
]

{ #category : #accessing }
RBProgramNode >> allComments [
	"Answer a collection of objects representing the comments in the method. Return an empty collection if the method's source code does not contain a comment."

	^ self allChildren flatCollect: [:el| el comments]
]

{ #category : #accessing }
RBProgramNode >> allDefinedVariables [
	| children |
	children := self children.
	children isEmpty ifTrue: [^#()].
	^children inject: OrderedCollection new
		into: 
			[:vars :each | 
			vars
				addAll: each allDefinedVariables;
				yourself]
]

{ #category : #accessing }
RBProgramNode >> allParents [
	"return all my parents. 
	See discussion in issue https://github.com/pharo-project/pharo/issues/6278"
	^ parent 
		ifNil: [ OrderedCollection new ]
		ifNotNil: [ parent withAllParents ]
]

{ #category : #accessing }
RBProgramNode >> allStatements [
	| children |
	children := self children.
	children isEmpty ifTrue: [^#()].
	^children inject: OrderedCollection new
		into: 
			[:vars :each | 
			vars
				addAll: each allStatements;
				yourself]
]

{ #category : #accessing }
RBProgramNode >> allTemporaryVariables [
	| children |
	children := self children.
	children isEmpty ifTrue: [^#()].
	^children inject: OrderedCollection new
		into: 
			[:vars :each | 
			vars
				addAll: each allTemporaryVariables;
				yourself]
]

{ #category : #accessing }
RBProgramNode >> allVariables [
	"Return all the variables in subnodes"

	^ self allChildren select: [ :each | each isVariable ]
]

{ #category : #accessing }
RBProgramNode >> asReturn [
	"Change the current node to a return node."

	parent ifNil: [self error: 'Cannot change to a return without a parent node.'].
	parent isSequence 
		ifFalse: [self error: 'Parent node must be a sequence node.'].
	(parent isLast: self) ifFalse: [self error: 'Return node must be last.'].
	^parent addReturn
]

{ #category : #querying }
RBProgramNode >> assignmentNodes [
	^self allChildren select: [:each | each isAssignment].
]

{ #category : #testing }
RBProgramNode >> assigns: aVariableName [ 
	^self children anySatisfy: [:each | each assigns: aVariableName]
]

{ #category : #querying }
RBProgramNode >> bestNodeFor: anInterval [ 
	| selectedChildren selectedComments |
	anInterval ifNil: [^nil ].
	selectedComments := self getCommentsFor: anInterval.
	(self intersectsInterval: anInterval) ifFalse: [^selectedComments ifNil: [ nil ] ifNotNil: [ selectedComments size = 1 ifTrue: [ selectedComments first ] ifFalse: [ nil ] ] ].
	(self containedBy: anInterval) ifTrue: [^self].
	
	selectedChildren := self children select: [:each | 
		each intersectsInterval: anInterval
	].

	^ selectedChildren size = 1 
		ifTrue: [ selectedChildren first bestNodeFor: anInterval ]
		ifFalse: [ (selectedChildren isEmpty and: [ selectedComments size = 1 ])
							ifTrue: [ selectedComments first ]
							ifFalse: [ self ] ]
]

{ #category : #querying }
RBProgramNode >> bestNodeForPosition: aPosition [

	"aPosition is an integer that represents the position of the caret. 
	A value of N represents that the caret is between the characters N-1 and N.
	The position 1 is at beginning of the text.
	
	Position Heuristic: If the previous character is not a separator, take selection one position before.
		This heuristic is for the cases where the caret (|) is:
		   |self foo  => the caret is before self, do not move
		   self foo|  => the caret is before foo, interpret is as if we are in foo.
			self foo | => the caret is before a space, interpret is as if we are in foo.

		This heuristic introduces although an ambiguity when code is not nicely formatted:
		   self foo:|#bar => Here a user may want foo: or bar.
		For now we decided to favor foo: to motivate people to indent code correctly	"
 
	| offset position |
	offset := (aPosition = 1 or: [ (self methodNode sourceCode at: aPosition - 1) isSeparator ])
		ifTrue: [ 0 ]
		ifFalse: [ -1 ].

	position := (aPosition + offset) min: self stop.

	^ self bestNodeFor: (position to: position)
]

{ #category : #querying }
RBProgramNode >> blockNodes [
	^self allChildren select: [:each | each isBlock].
]

{ #category : #accessing }
RBProgramNode >> blockVariables [
	^parent ifNil: [#()] ifNotNil: [parent blockVariables]
]

{ #category : #'testing-matching' }
RBProgramNode >> canMatchMethod: aCompiledMethod [ 
	^self sentMessages allSatisfy: 
			[:each | 
			(self class optimizedSelectors includes: each) 
				or: [aCompiledMethod refersToLiteral: each]]
]

{ #category : #'meta variable-accessing' }
RBProgramNode >> cascadeListCharacter [
	^$;
]

{ #category : #accessing }
RBProgramNode >> children [
	^#()
]

{ #category : #replacing }
RBProgramNode >> clearReplacements [
	parent ifNil: [^self].
	parent clearReplacements
]

{ #category : #enumeration }
RBProgramNode >> collect: aBlock [ 
	"Hacked to fit collection protocols"

	^aBlock value: self
]

{ #category : #accessing }
RBProgramNode >> comments [
	"Answer the comments of the receiving parse tree node"
	
	^ (self propertyAt: #comments ifAbsent: [ #() ]) ifNil:[ #() ]
]

{ #category : #accessing }
RBProgramNode >> comments: aCollection [

	(aCollection ifNil: [#()])
		ifEmpty: [ self removeProperty: #comments ifAbsent: [] ] 
		ifNotEmpty: [ self propertyAt: #comments put: aCollection ].
]

{ #category : #testing }
RBProgramNode >> containedBy: anInterval [ 
	^anInterval first <= self start and: [anInterval last >= self stop]
]

{ #category : #testing }
RBProgramNode >> containsReturn [
	^self children anySatisfy: [:each | each containsReturn]
]

{ #category : #copying }
RBProgramNode >> copyCommentsFrom: aNode [ 
	"Add all comments from aNode to us. If we already have the comment, then don't add it."

	| newComments |
	newComments := OrderedCollection new.
	aNode nodesDo: [:each | newComments addAll: each comments].
	self nodesDo: 
			[:each | 
			each comments do: [:comment | newComments remove: comment ifAbsent: []]].
	newComments isEmpty ifTrue: [^self].
	newComments := newComments asSortedCollection: [:a :b | a start < b start].
	self comments: newComments
]

{ #category : #matching }
RBProgramNode >> copyInContext: aDictionary [
	^ self copy
]

{ #category : #matching }
RBProgramNode >> copyList: matchNodes inContext: aDictionary [ 
	| newNodes |
	newNodes := OrderedCollection new.
	matchNodes do: 
			[:each | 
			| object |
			object := each copyInContext: aDictionary.
			newNodes addAll: object].
	^newNodes
]

{ #category : #accessing }
RBProgramNode >> debugHighlightRange [

	^ self debugHighlightStart to: self debugHighlightStop
]

{ #category : #accessing }
RBProgramNode >> debugHighlightStart [

	^ self start 
]

{ #category : #accessing }
RBProgramNode >> debugHighlightStop [

	^ self stop 
]

{ #category : #testing }
RBProgramNode >> defines: aName [
	^false
]

{ #category : #testing }
RBProgramNode >> directlyUses: aNode [
	^true
]

{ #category : #enumeration }
RBProgramNode >> do: aBlock [ 
	"Hacked to fit collection protocols"

	aBlock value: self
]

{ #category : #generation }
RBProgramNode >> dump [
	"Generate a literal expression that recreates the receiver"

	| visitor |
	visitor := RBDumpVisitor new.
	self acceptVisitor: visitor.
	^ visitor stream contents
]

{ #category : #comparing }
RBProgramNode >> equalTo: aNode exceptForVariables: variableNameCollection [ 
	| dictionary |
	dictionary := Dictionary new.
	(self equalTo: aNode withMapping: dictionary) ifFalse: [^false].
	dictionary keysAndValuesDo: 
			[:key :value | 
			(key = value or: [variableNameCollection includes: key]) ifFalse: [^false]].
	^true
]

{ #category : #comparing }
RBProgramNode >> equalTo: aNode withMapping: aDictionary [ 
	^self = aNode
]

{ #category : #testing }
RBProgramNode >> evaluatedFirst: aNode [ 
	self children do: 
			[:each | 
			each == aNode ifTrue: [^true].
			each isImmediateNode ifFalse: [^false]].
	^false
]

{ #category : #accessing }
RBProgramNode >> formattedCode [
	^ self formatterClass new format: self
]

{ #category : #accessing }
RBProgramNode >> formatterClass [
	^ self class formatterClass
]

{ #category : #querying }
RBProgramNode >> getCommentsFor: anInterval [
	| selectedComments |
	selectedComments := OrderedCollection new.
	self nodesDo: 
		[ :each | 
			| comments | 
			comments := each comments select: 
				[ :com | com intersectsInterval: anInterval ]. 
	"This precaution is taken to deal with cascades multiple visit of the receiver."
			(selectedComments isNotEmpty 
				and: [ comments isNotEmpty 
				and: [ comments last = selectedComments last ]]) 
					ifFalse: [selectedComments addAll: comments ] ].
	^ selectedComments
]

{ #category : #testing }
RBProgramNode >> hasComments [
	"Answer whether the receiver as comments"
	
	^ self comments isNotEmpty
	
]

{ #category : #testing }
RBProgramNode >> hasMultipleReturns [
	| count |
	count := 0.
	self nodesDo: [:each | each isReturn ifTrue: [count := count + 1]].
	^count > 1
]

{ #category : #properties }
RBProgramNode >> hasProperty: aKey [
	"Test if the property aKey is present."
	
	^ properties notNil and: [ properties includesKey: aKey ]
]

{ #category : #comparing }
RBProgramNode >> hashForCollection: aCollection [
	^ aCollection isEmpty ifTrue: [ 0 ] ifFalse: [ aCollection first hash ]
]

{ #category : #querying }
RBProgramNode >> instanceVariableNodes [
		^self variableNodes select: [:each | each isInstanceVariable]
]

{ #category : #querying }
RBProgramNode >> instanceVariableReadNodes [
		^self variableReadNodes select: [:each | each isInstanceVariable]
]

{ #category : #querying }
RBProgramNode >> instanceVariableWriteNodes [
		^self variableWriteNodes select: [:each | each isInstanceVariable]
]

{ #category : #testing }
RBProgramNode >> intersectsInterval: anInterval [ 
	^(anInterval first between: self start and: self stop) 
		or: [self start between: anInterval first and: anInterval last]
]

{ #category : #testing }
RBProgramNode >> isArgument [
	self 
		deprecated: 'Use #isArgumentVariable instead.' 
		transformWith: '`@receiver isArgument' -> '`@receiver isArgumentVariable'.
	
	^ self isArgumentVariable
]

{ #category : #testing }
RBProgramNode >> isArgumentVariable [
	^ false
]

{ #category : #testing }
RBProgramNode >> isArrayError [
	^false
]

{ #category : #testing }
RBProgramNode >> isAssignment [
	^false
]

{ #category : #testing }
RBProgramNode >> isBlockError [
	^false
]

{ #category : #testing }
RBProgramNode >> isCascade [
	^false
]

{ #category : #testing }
RBProgramNode >> isClassVariable [
	^ false
]

{ #category : #testing }
RBProgramNode >> isCommentNode [
	^false
]

{ #category : #testing }
RBProgramNode >> isDirectlyUsed [
	"This node is directly used as an argument, receiver, or part of an assignment."

	^parent ifNil: [false] ifNotNil: [parent directlyUses: self]
]

{ #category : #testing }
RBProgramNode >> isDynamicArray [
	^ false
]

{ #category : #testing }
RBProgramNode >> isEnglobingError [
	^false
]

{ #category : #testing }
RBProgramNode >> isEvaluatedFirst [
	"Return true if we are the first thing evaluated in this statement."

	^parent isNil or: [parent isSequence or: [parent evaluatedFirst: self]]
]

{ #category : #testing }
RBProgramNode >> isFaulty [
	"return true if the AST contains a RBParseErrorNode"
	^false
]

{ #category : #testing }
RBProgramNode >> isGlobalVariable [
	^false
]

{ #category : #testing }
RBProgramNode >> isHaltNode [
	^ false
]

{ #category : #deprecated }
RBProgramNode >> isImmediate [
	^self isImmediateNode
]

{ #category : #testing }
RBProgramNode >> isImmediateNode [
	^false
]

{ #category : #testing }
RBProgramNode >> isInstanceVariable [
	^false
]

{ #category : #testing }
RBProgramNode >> isLast: aNode [ 
	| children |
	children := self children.
	^children notEmpty and: [children last == aNode]
]

{ #category : #'testing-matching' }
RBProgramNode >> isList [
	^false
]

{ #category : #testing }
RBProgramNode >> isLiteralArray [
	^false
]

{ #category : #testing }
RBProgramNode >> isLiteralArrayError [
	^false
]

{ #category : #testing }
RBProgramNode >> isLiteralNode [
	^false
]

{ #category : #testing }
RBProgramNode >> isLiteralVariable [
	^false
]

{ #category : #testing }
RBProgramNode >> isLocalVariable [
	^false
]

{ #category : #testing }
RBProgramNode >> isMessage [
	^false
]

{ #category : #testing }
RBProgramNode >> isMethod [
	^false
]

{ #category : #testing }
RBProgramNode >> isParenthesesError [
	^false
]

{ #category : #testing }
RBProgramNode >> isParseError [
	^false
]

{ #category : #'testing-matching' }
RBProgramNode >> isPatternNode [
	^false
]

{ #category : #testing }
RBProgramNode >> isPragma [
	^false
]

{ #category : #testing }
RBProgramNode >> isPragmaError [
	^false
]

{ #category : #testing }
RBProgramNode >> isReservedVariable [
	^false
]

{ #category : #testing }
RBProgramNode >> isReturn [
	^false
]

{ #category : #testing }
RBProgramNode >> isSelector [
	^false
]

{ #category : #testing }
RBProgramNode >> isSelfOrSuperVariable [
	^false
]

{ #category : #testing }
RBProgramNode >> isSelfVariable [
	^ false
]

{ #category : #testing }
RBProgramNode >> isSequence [
	^false
]

{ #category : #testing }
RBProgramNode >> isSuperVariable [
	^false
]

{ #category : #testing }
RBProgramNode >> isTempVariable [
	^ false
]

{ #category : #testing }
RBProgramNode >> isTemporariesError [
	^false
]

{ #category : #testing }
RBProgramNode >> isThisContextVariable [
	^ false
]

{ #category : #testing }
RBProgramNode >> isUndeclaredVariable [
	^false
]

{ #category : #testing }
RBProgramNode >> isUnfinishedStatement [
	^false
]

{ #category : #testing }
RBProgramNode >> isUsed [
	"Answer true if this node could be used as part of another expression. For example, you could use the 
	result of this node as a receiver of a message, an argument, the right part of an assignment, or the 
	return value of a block. This differs from isDirectlyUsed in that it is conservative since it also includes 
	return values of blocks."

	^parent ifNil: [false] ifNotNil: [parent uses: self]
]

{ #category : #testing }
RBProgramNode >> isValue [
	^false
]

{ #category : #testing }
RBProgramNode >> isVariable [
	^false
]

{ #category : #testing }
RBProgramNode >> isWorkspaceVariable [
	^false
]

{ #category : #testing }
RBProgramNode >> lastIsReturn [
	^self isReturn
]

{ #category : #'meta variable-accessing' }
RBProgramNode >> listCharacter [
	^$@
]

{ #category : #'meta variable-accessing' }
RBProgramNode >> literalCharacter [
	^$#
]

{ #category : #accessing }
RBProgramNode >> mappingFor: aNode [
	| method |
	method := self methodNode.
	method ifNil: [^aNode].
	^method mappingFor: aNode
]

{ #category : #matching }
RBProgramNode >> match: aNode inContext: aDictionary [ 
	^ self = aNode
]

{ #category : #matching }
RBProgramNode >> matchList: matchNodes against: programNodes inContext: aDictionary [ 
	^self
		matchList: matchNodes
		index: 1
		against: programNodes
		index: 1
		inContext: aDictionary
]

{ #category : #matching }
RBProgramNode >> matchList: matchNodes index: matchIndex against: programNodes index: programIndex inContext: aDictionary [ 
	| node currentIndex currentDictionary nodes |
	matchNodes size < matchIndex ifTrue: [^programNodes size < programIndex].
	node := matchNodes at: matchIndex.
	node isList 
		ifTrue: 
			[currentIndex := programIndex - 1.
			
			[currentDictionary := aDictionary copy.
			programNodes size < currentIndex or: 
					[nodes := programNodes copyFrom: programIndex to: currentIndex.
					(currentDictionary at: node ifAbsentPut: [nodes]) = nodes and: 
							[(self 
								matchList: matchNodes
								index: matchIndex + 1
								against: programNodes
								index: currentIndex + 1
								inContext: currentDictionary) 
									ifTrue: 
										[currentDictionary 
											keysAndValuesDo: [:key :value | aDictionary at: key put: value].
										^true].
							false]]] 
					whileFalse: [currentIndex := currentIndex + 1].
			^false].
	programNodes size < programIndex ifTrue: [^false].
	(node match: (programNodes at: programIndex) inContext: aDictionary) 
		ifFalse: [^false].
	^self 
		matchList: matchNodes
		index: matchIndex + 1
		against: programNodes
		index: programIndex + 1
		inContext: aDictionary
]

{ #category : #accessing }
RBProgramNode >> methodNode [
	^parent ifNotNil: [parent methodNode]
]

{ #category : #accessing }
RBProgramNode >> methodOrBlockNode [
	^ parent ifNotNil: [ parent methodOrBlockNode ]
]

{ #category : #accessing }
RBProgramNode >> newSource [
	^self formattedCode
]

{ #category : #'node access' }
RBProgramNode >> nodeForOffset: anInteger [
	| children |
	"choosing the best node on the specific offset"
	children := self children.
	"when we are on a leaf, we take the leaf node"
	(children isEmpty) ifTrue: [ (self sourceInterval includes: anInteger) ifTrue: [^self]].
	"if the node has children then we check the children"
	children do: [:each | (each sourceInterval includes: anInteger) ifTrue: [^each nodeForOffset: anInteger] ].
]

{ #category : #iterating }
RBProgramNode >> nodesDo: aBlock [ 
	aBlock value: self.
	self children do: [ :each | each nodesDo: aBlock ]
]

{ #category : #accessing }
RBProgramNode >> parent [
	^parent
]

{ #category : #accessing }
RBProgramNode >> parent: aRBProgramNode [ 
	parent := aRBProgramNode
]

{ #category : #hook }
RBProgramNode >> parserClass [
	^ RBParser
]

{ #category : #copying }
RBProgramNode >> postCopy [
	super postCopy.
	properties := properties copy
]

{ #category : #accessing }
RBProgramNode >> precedence [
	^6
]

{ #category : #printing }
RBProgramNode >> printOn: aStream [ 
	aStream
		nextPutAll: self class name;
		nextPut: $(;
		nextPutAll: self formattedCode;
		nextPut: $)
]

{ #category : #properties }
RBProgramNode >> propertyAt: aKey [
	"Answer the property value associated with aKey."
	
	^ self propertyAt: aKey ifAbsent: [ self error: 'Property not found' ]
]

{ #category : #properties }
RBProgramNode >> propertyAt: aKey ifAbsent: aBlock [
	"Answer the property value associated with aKey or, if aKey isn't found, answer the result of evaluating aBlock."
	
	^ properties 
		ifNil: aBlock
		ifNotNil: [ properties at: aKey ifAbsent: aBlock ]
]

{ #category : #properties }
RBProgramNode >> propertyAt: aKey ifAbsentPut: aBlock [
	"Answer the property associated with aKey or, if aKey isn't found store the result of evaluating aBlock as new value."
	
	^ self propertyAt: aKey ifAbsent: [ self propertyAt: aKey put: aBlock value ]
]

{ #category : #properties }
RBProgramNode >> propertyAt: aKey ifPresent: aPresentBlock ifAbsent: anAbsentBlock [
	"Answer the property value associated with aKey or, if aKey is found, answer the result of evaluating aPresentBlock, else evaluates anAbsentBlock."

	^ properties ifNil: anAbsentBlock ifNotNil: [ properties at: aKey ifPresent: aPresentBlock ifAbsent: anAbsentBlock ]
]

{ #category : #properties }
RBProgramNode >> propertyAt: aKey put: anObject [
	"Set the property at aKey to be anObject. If aKey is not found, create a new entry for aKey and set is value to anObject. Answer anObject."

	^ (properties ifNil: [ properties := SmallDictionary new: 1 ])
		at: aKey put: anObject
]

{ #category : #'testing-matching' }
RBProgramNode >> recurseInto [
	^false
]

{ #category : #'meta variable-accessing' }
RBProgramNode >> recurseIntoCharacter [
	^$`
]

{ #category : #testing }
RBProgramNode >> references: aVariableName [ 
	^self children anySatisfy: [:each | each references: aVariableName]
]

{ #category : #replacing }
RBProgramNode >> removeDeadCode [
	self children do: [:each | each removeDeadCode]
]

{ #category : #properties }
RBProgramNode >> removeProperty: aKey [
	"Remove the property with aKey. Answer the property or raise an error if aKey isn't found."
	
	^ self removeProperty: aKey ifAbsent: [ self error: 'Property not found' ].
]

{ #category : #properties }
RBProgramNode >> removeProperty: aKey ifAbsent: aBlock [
	"Remove the property with aKey. Answer the value or, if aKey isn't found, answer the result of evaluating aBlock."
	
	| answer |
	properties ifNil: [ ^ aBlock value ].
	answer := properties removeKey: aKey ifAbsent: aBlock.
	properties isEmpty ifTrue: [ properties := nil ].
	^ answer
]

{ #category : #replacing }
RBProgramNode >> replaceMethodSource: aNode [ 
	"We are being replaced with aNode -- if possible try to perform an in place edit of the source."

	| method |
	method := self methodNode.
	method notNil ifTrue: [method map: self to: aNode].
	aNode parent: self parent.
	[self replaceSourceWith: aNode] on: Error
		do: 
			[:ex | 
			self clearReplacements.
			ex return]
]

{ #category : #replacing }
RBProgramNode >> replaceNode: aNode withNode: anotherNode [ 
	self error: 'I don''t store other nodes'
]

{ #category : #'private-replacing' }
RBProgramNode >> replaceSourceFrom: aNode [
	self == aNode
		ifFalse: [ self clearReplacements ]
]

{ #category : #'private-replacing' }
RBProgramNode >> replaceSourceWith: aNode [ 
	aNode replaceSourceFrom: self
]

{ #category : #replacing }
RBProgramNode >> replaceWith: aNode [ 
	parent ifNil: [self error: 'This node doesn''t have a parent'].
	self replaceMethodSource: aNode.
	parent replaceNode: self withNode: aNode
]

{ #category : #enumeration }
RBProgramNode >> reverseNodesDo: aBlock [ 
	self children reverseDo: [ :each | each reverseNodesDo: aBlock ].
	aBlock value: self
]

{ #category : #querying }
RBProgramNode >> selfMessages [
	^(self sendNodes select: [ :node | node isSelfSend ] thenCollect: [ :node | node selector ]) asSet
]

{ #category : #accessing }
RBProgramNode >> sendNodes [
	^self allChildren select: [:each | each isMessage].
]

{ #category : #accessing }
RBProgramNode >> sentMessages [
	^ self children
		inject: Set new
		into: [ :messages :each | 
			messages
				addAll: each sentMessages;
				yourself ]
]

{ #category : #enumeration }
RBProgramNode >> size [
	"Hacked to fit collection protocols"

	^1
]

{ #category : #accessing }
RBProgramNode >> source [
	^ parent notNil ifTrue: [ parent source ] ifFalse: [ nil ]
]

{ #category : #accessing }
RBProgramNode >> sourceCode [

	| interval |
	interval := self sourceInterval.
	interval ifEmpty: [ ^ '' ].
	
	^ self source 
		copyFrom: interval first
		to: interval last
]

{ #category : #accessing }
RBProgramNode >> sourceInterval [
	^ self start to: self stop
]

{ #category : #accessing }
RBProgramNode >> start [
	self subclassResponsibility
]

{ #category : #'meta variable-accessing' }
RBProgramNode >> statementCharacter [
	^$.
]

{ #category : #accessing }
RBProgramNode >> statementComments [
	| statementComments |
	statementComments := OrderedCollection withAll: self comments.
	self children do: [:each | statementComments addAll: each statementComments].
	^statementComments asSortedCollection: [:a :b | a start < b start]
]

{ #category : #querying }
RBProgramNode >> statementNode [
	"Return your topmost node that is contained by a sequence node."

	(parent isNil or: [parent isSequence]) ifTrue: [^self].
	^parent statementNode
]

{ #category : #accessing }
RBProgramNode >> statements [
	^ #()
	
]

{ #category : #accessing }
RBProgramNode >> stop [
	self subclassResponsibility
]

{ #category : #querying }
RBProgramNode >> superMessages [
	^(self sendNodes select: [ :node | node isSuperSend ] thenCollect: [ :node | node selector ]) asSet
]

{ #category : #querying }
RBProgramNode >> tempVariableReadNodes [
		^self variableReadNodes select: [:each | each isTempVariable]
]

{ #category : #accessing }
RBProgramNode >> temporaryVariables [
	^parent ifNil: [#()] ifNotNil: [parent temporaryVariables]
]

{ #category : #testing }
RBProgramNode >> uses: aNode [
	^true
]

{ #category : #querying }
RBProgramNode >> variableDefinitionNodes [
	^ self allChildren select: [ :each | 
		  each isVariable and: [ each isDefinition ] ]
]

{ #category : #querying }
RBProgramNode >> variableNodes [

	^ self allChildren select: [ :each | 
		  each isVariable and: [ each isDefinition not ] ]
]

{ #category : #querying }
RBProgramNode >> variableReadNodes [
	^self variableNodes select: [:each | each isRead]
]

{ #category : #querying }
RBProgramNode >> variableWriteNodes [
		^self variableNodes select: [:each | each isWrite]
]

{ #category : #querying }
RBProgramNode >> whichNodeIsContainedBy: anInterval [ 
	| selectedChildren |
	(self intersectsInterval: anInterval) ifFalse: [^nil].
	(self containedBy: anInterval) ifTrue: [^self].
	selectedChildren := self children 
				select: [:each | each intersectsInterval: anInterval].
	^selectedChildren size == 1 
		ifTrue: [selectedChildren first whichNodeIsContainedBy: anInterval]
		ifFalse: [nil]
]

{ #category : #querying }
RBProgramNode >> whoDefines: aName [ 
	^(self defines: aName) 
		ifTrue: [self]
		ifFalse: [parent notNil ifTrue: [parent whoDefines: aName] ifFalse: [nil]]
]

{ #category : #accessing }
RBProgramNode >> withAllParents [
	"return me and all my parents. Topmost parent first, me last
	See discussion in issue https://github.com/pharo-project/pharo/issues/6278"
	^ parent 
		ifNil: [ OrderedCollection with: self ]
		ifNotNil: [ 
			parent withAllParents 
				addLast: self;
				yourself ]
]
