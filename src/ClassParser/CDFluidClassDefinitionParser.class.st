"
I'm parser for the new class syntax. 


### The new syntax for class definition (just for the class and not for the methods) is

```
Superclass < #MyObject
	uses: #MyTrait;
	slots: { #a. #b };
	sharedVariables: { #A. #B };
	tags: {'tag2' . 'Core'} ;
	layout: VariableLayout; 
	sharedPools: { #TextConstants } ;
	package: #MyPackage
```
Pay attention all the messages should be keyword-based.

The minimal class definition is the following one: 

```
Superclass < #MyObject
	package: #MyPackage
```

For the implementors, we see that we should either handle a simple message composition or a cascade. 

### Design Concerns 
Note that sending a message to the superclass is close to subclass: and it lets the class selects 
a class definition parser if the syntax should be extended. 
In addition having a binary message makes () unneccessary.


"
Class {
	#name : #CDFluidClassDefinitionParser,
	#superclass : #CDAbstractClassDefinitionParser,
	#category : #'ClassParser-Parser'
}

{ #category : #parsing }
CDFluidClassDefinitionParser class >> fromASTNode: aNode [ 
	
	^ self new parseRootNode: aNode
]

{ #category : #parsing }
CDFluidClassDefinitionParser class >> parse: aString [ 
	
	^ self new parse: aString
]

{ #category : #'handling  nodes' }
CDFluidClassDefinitionParser >> handleClassAndSuperclassOf: aNode [

	"Pay attention that is is important to test first traits because we have the same message to create classes and traits, but traits are sent to Trait."
	(self isTraitDefinition: aNode receiver)
		ifTrue: [ self handleClassName: aNode receiver arguments first. ^ self ].
	(self isTraitClassSideDefinition: aNode receiver)
		ifTrue: [ self handleClassName: aNode receiver receiver. ^ self].
	
	(self isInstanceSideDefinition: aNode receiver)
		ifTrue: [ 
			self handleSuperclassNode: aNode receiver receiver.
			self handleClassName: aNode receiver arguments first ]
		ifFalse: [ self handleMetaclassName: aNode ].
]

{ #category : #'handling  nodes' }
CDFluidClassDefinitionParser >> handleLayout: aNode [

	classDefinition classKind: aNode binding value kind
]

{ #category : #'handling  nodes' }
CDFluidClassDefinitionParser >> handleSharedPoolsFromNode: aNode [
	| sharedPoolNodes |
	sharedPoolNodes := aNode children
		collect: [ :aPoolNode | 
			self sharedPoolNodeClass
				node: aPoolNode
				name: aPoolNode name
				start: aPoolNode start 
				stop: aPoolNode start + aPoolNode name size
			].
	classDefinition sharedPools: sharedPoolNodes
]

{ #category : #'handling  nodes' }
CDFluidClassDefinitionParser >> handleSharedVariableNames: aNode [ 
	
	| slotNodes classVariablesString |
	classVariablesString := aNode sourceCode.
	slotNodes := aNode statements
		collect: [ :literalNode | 		
			| start literalName |
			literalName := literalNode value.
			start := aNode start + (classVariablesString findString: literalName).
			CDSharedVariableNode
				node: aNode
				name: literalName
				slotClassName: 'ClassVariableSlot'
				start: start
				stop: start + literalNode size ].
	classDefinition sharedSlots: slotNodes
]

{ #category : #'handling  nodes' }
CDFluidClassDefinitionParser >> handleSuperclassNode: aSuperclassNode [
	| aSuperclassName superclassNode |
	aSuperclassName := aSuperclassNode isLiteralNode
		ifTrue: [ nil ]
		ifFalse: [ aSuperclassNode binding value asString asSymbol ].
	superclassNode := self classNameNodeClass new
		originalNode: aSuperclassNode;
		className: aSuperclassName.
	classDefinition
		superclassName: aSuperclassName
		astNode: superclassNode
]

{ #category : #'handling  nodes' }
CDFluidClassDefinitionParser >> handleTag: aNode [

	classDefinition tag: (CDClassTagNode new name: aNode value)
]

{ #category : #testing }
CDFluidClassDefinitionParser >> isInstanceSideDefinition: aRBMessageNode [
	"Returns whether the definition is a class or instance side definition. Superclass < #myObject. Trait << are handled prior to this method."
	
	^ aRBMessageNode isMessage and: [ aRBMessageNode selector = #<< ]
	
]

{ #category : #testing }
CDFluidClassDefinitionParser >> isTraitClassSideDefinition: aRBMessageNode [
	"Based on the message structure, returns whether the definition is a trait definition."

	^ aRBMessageNode isMessage and: [ aRBMessageNode selector = #classTrait ]
	
]

{ #category : #testing }
CDFluidClassDefinitionParser >> isTraitDefinition: aRBMessageNode [
	"Returns whether the definition is a trait definition, i.e., Trait << #Tbehavior."

	^ aRBMessageNode isMessage and: [ aRBMessageNode receiver name = 'Trait' and: [ aRBMessageNode selector = #<< ]]
	
]

{ #category : #'parsing-internal' }
CDFluidClassDefinitionParser >> parseRootNode: expressionTree [
	
	expressionTree extractClassDefinitionFor: self. 
	classDefinition originalNode: expressionTree.
	expressionTree acceptVisitor: self.
	^ classDefinition
]

{ #category : #'parsing-internal' }
CDFluidClassDefinitionParser >> parseSelectorPart: aString withArgument: aNode [ 
	"We could do this with reflection, or with a dictionary and closures.
	I chose to use a series of if for readability only."
	
	aString =	 #slots:
		ifTrue: [ ^ self handleSlotsNodesFromArrayNode: aNode ].
	aString =	 #sharedVariables: 
		ifTrue: [ ^ self handleSharedVariableNames: aNode ].	
	aString =	 #package:
		ifTrue: [ ^ self handlePackage: aNode ].
	aString = #layout:
		ifTrue: [ ^ self handleLayout: aNode ].	
	aString = #tag: 
		ifTrue: [  ^self handleTag: aNode ].
	aString =	 #uses:
		ifTrue: [ ^ self handleTraitUsesFromNode: aNode ].
	aString =	 #trait:
		ifTrue: [ ^ self handleTraitUsesFromNode: aNode ].
	aString =	 #sharedPools:
		ifTrue: [ ^ self handleSharedPoolsFromNode: aNode ].
	
	CDUnrecognizedClassPart new
		classDefinition: self; 
		unrecognizedPart: aString;
		signal
]

{ #category : #internal }
CDFluidClassDefinitionParser >> setAdequateClassDefinitionFrom: expressionTree [
	"Set a class, trait, class side trait or metaclass definition as definition object."
	
	(self isTraitDefinition: expressionTree)
		ifTrue: [ self beTraitDefinition. ^ self ].
	(self isTraitClassSideDefinition: expressionTree)	
		ifTrue: [ self beClassSideTraitDefinition. ^ self ].
	super setAdequateClassDefinitionFrom: expressionTree
]

{ #category : #'parsing-internal' }
CDFluidClassDefinitionParser >> visitCascadeNode: aRBCascadeNode [ 
	"See class comment. Here we handle the cascade version of the class definition."
	" 
	Object << #Point
			uses: TraitX;
			slots: { #foo };
			package: ''Kernel-BasicObjects'''
	"
	
	self handleClassAndSuperclassOf: aRBCascadeNode.	
	aRBCascadeNode messages do: 
		[:msg | msg selectorParts
					with: msg arguments
					do: [ :selectorPart :argument |
			self parseSelectorPart: selectorPart withArgument: argument ] ]
]

{ #category : #'parsing-internal' }
CDFluidClassDefinitionParser >> visitMessageNode: aRBMessageNode [
	"See class comment. Here we handle the cascade version of the class definition."
	"
	Object << #Point
			package: ''Kernel-BasicObjects'''
	"		

	self handleClassAndSuperclassOf: aRBMessageNode.
	
	aRBMessageNode arguments ifEmpty: [ ^ self ].
	aRBMessageNode selectorParts
		with: aRBMessageNode arguments
		do: [ :selectorPart :argument |
			self parseSelectorPart: selectorPart withArgument: argument ]
]
