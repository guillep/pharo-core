"
I am in charge of building a Trait composition. 

aTraitCompositionNode is composed of TraitNode.
"
Class {
	#name : #CDTraitCompositionBuilder,
	#superclass : #Object,
	#category : #'ClassParser-Model'
}

{ #category : #building }
CDTraitCompositionBuilder >> buildFrom: aNode [
	
	^ aNode acceptVisitor: self
]

{ #category : #visiting }
CDTraitCompositionBuilder >> visitArrayNode: aRBArrayNode [ 
	| parent argumentName |
	self flag: #todo. 
	"It needs to be refactored. I do not know how it was supposed to be handle properly.
	Here is workaround to fix issue with empty #uses section"
	parent := aRBArrayNode parent.
	parent isMessage ifTrue: [ 
		argumentName := parent keywords at: (parent arguments indexOf: aRBArrayNode).
		(argumentName = #uses:) | (argumentName = #trait:) ifTrue: [ 
			aRBArrayNode statements ifEmpty: [ 
				^CDTraitCompositionSequenceNode new 
					sequence: #();
					originalNode: aRBArrayNode;
					yourself].
			self error: 'Is not supported yet']].
	
	^aRBArrayNode statements collect: [ :each | 
		each isLiteralNode
			ifTrue: [ each value ]
			ifFalse: [ each receiver value -> each arguments first value ] ]
]

{ #category : #visiting }
CDTraitCompositionBuilder >> visitGlobalNode: aRBGlobalNode [ 
	
	^self visitVariableNode: aRBGlobalNode
]

{ #category : #visiting }
CDTraitCompositionBuilder >> visitGlobalVariableNode: aRBGlobalNode [ 
	
	^self visitVariableNode: aRBGlobalNode
]

{ #category : #visiting }
CDTraitCompositionBuilder >> visitLiteralNode: aRBLiteralValueNode [ 
	
	^ aRBLiteralValueNode value
]

{ #category : #visiting }
CDTraitCompositionBuilder >> visitLiteralValueNode: aRBLiteralValueNode [
	"Redirect the message by default to #visitLiteralNode: for retrocompatibility (pharo 8)"

	^ self visitLiteralNode: aRBLiteralValueNode
]

{ #category : #visiting }
CDTraitCompositionBuilder >> visitLiteralVariableNode: aRBGlobalNode [ 
	
	^self visitVariableNode: aRBGlobalNode
]

{ #category : #visiting }
CDTraitCompositionBuilder >> visitMessageNode: aRBMessageNode [ 
	
	| node receiver argument |
	
	aRBMessageNode selector = #classTrait
		ifTrue: [ 
			^ CDClassTraitNode new
				originalNode: aRBMessageNode;
				name: aRBMessageNode receiver name;
				yourself  ].
	
	receiver := aRBMessageNode receiver acceptVisitor: self.
	argument := aRBMessageNode arguments first acceptVisitor: self.
	
	node := receiver perform: aRBMessageNode selector with: argument.
	node originalNode: aRBMessageNode.
	^ node
]

{ #category : #visiting }
CDTraitCompositionBuilder >> visitVariableNode: aRBVariableNode [ 
	
	^ CDTraitNode new
		originalNode: aRBVariableNode;
		name: aRBVariableNode name;
		yourself
]
