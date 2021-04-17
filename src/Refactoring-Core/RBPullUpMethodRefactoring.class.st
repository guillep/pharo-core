"
I am a refactoring for moving a method up to the superclass. 

My precondition verify that this method does not refere to instance variables not accessible in the superclass. And this method does not sends a super message that is defined in the superclass.
If the method already exists and the superclass is abstract or not referenced anywhere, replace that implementation and push down the old method to all other existing subclasses.



"
Class {
	#name : #RBPullUpMethodRefactoring,
	#superclass : #RBMethodRefactoring,
	#instVars : [
		'removeDuplicates',
		'selectors',
		'targetSuperclass'
	],
	#category : #'Refactoring-Core-Refactorings'
}

{ #category : #'instance creation' }
RBPullUpMethodRefactoring class >> model: aRBSmalltalk pullUp: selectorCollection from: aClass [ 
	^(self new)
		model: aRBSmalltalk;
		pullUp: selectorCollection from: aClass;
		yourself
]

{ #category : #'instance creation' }
RBPullUpMethodRefactoring class >> model: aRBSmalltalk pullUp: selectorCollection from: aClass to: aSuperClass [
	^ self new
		model: aRBSmalltalk;
		pullUp: selectorCollection from: aClass to: aSuperClass;
		yourself
]

{ #category : #'instance creation' }
RBPullUpMethodRefactoring class >> pullUp: selectorCollection from: aClass [ 
	^self new pullUp: selectorCollection from: aClass
]

{ #category : #'instance creation' }
RBPullUpMethodRefactoring class >> pullUp: selectorCollection from: aClass to: aSuperClass [
	^self new pullUp: selectorCollection from: aClass to: aSuperClass 
]

{ #category : #preconditions }
RBPullUpMethodRefactoring >> checkBackReferencesTo: aSelector [ 
	| definingClass pushUpParseTree |
	definingClass := targetSuperclass whoDefinesMethod: aSelector.
	definingClass ifNil: [^self].
	pushUpParseTree := class parseTreeFor: aSelector.
	targetSuperclass allSubclasses do: 
			[:each | 
			each selectors do: 
					[:sel | 
					| parseTree |
					parseTree := each parseTreeFor: sel.
					(parseTree notNil and: 
							[(parseTree superMessages includes: aSelector) 
								and: [definingClass == (each whoDefinesMethod: aSelector)]]) 
						ifTrue: 
							[removeDuplicates := true.
							(aSelector == sel 
								and: [parseTree equalTo: pushUpParseTree exceptForVariables: #()]) 
									ifFalse: 
										[self 
											refactoringError: ('Cannot pull up <1s> since it would override the method defined in <2p>' 
													expandMacrosWith: aSelector
													with: definingClass)]]]]
]

{ #category : #preconditions }
RBPullUpMethodRefactoring >> checkClassVars [
	selectors do: [:each | self checkClassVarsFor: each]
]

{ #category : #preconditions }
RBPullUpMethodRefactoring >> checkClassVarsFor: aSelector [ 
	class instanceSide classVariableNames do: 
		[ :each | 
		((class whichSelectorsReferToClassVariable: each) includes: aSelector) ifTrue: 
			[ self refactoringError: ('<1p> refers to <2s> which is defined in <3p>' 
					expandMacrosWith: aSelector
					with: each
					with: class) ] ]
]

{ #category : #preconditions }
RBPullUpMethodRefactoring >> checkInstVars [
	selectors do: [:each | self checkInstVarsFor: each]
]

{ #category : #preconditions }
RBPullUpMethodRefactoring >> checkInstVarsFor: aSelector [ 
	class instanceVariableNames do: 
			[:each | 
			((class whichSelectorsReferToInstanceVariable: each) includes: aSelector) ifTrue: 
					[ (self confirm: ('<1p> refers to #<2s> which is defined in <3p>. Do you want push up variable #<2s> also?' expandMacrosWith: aSelector
								with: each
								with: class)) 
						ifTrue: [ self pushUpVariable: each ]
						ifFalse: [ self refactoringError: 'You are about to push your method without the instance variable it uses. 
						It will bring the system is an inconsistent state. But this may be what you want.
						So do you want to push up anyway?' ] ]]
]

{ #category : #preconditions }
RBPullUpMethodRefactoring >> checkSiblingSuperSendsFrom: aRBClass [ 
	aRBClass selectors do: 
			[:each | 
			| tree |
			tree := aRBClass parseTreeFor: each.
			tree ifNotNil: 
					[tree superMessages do: 
							[:aSelector | 
							(selectors includes: aSelector) 
								ifTrue: 
									[| definer |
									definer := aRBClass superclass whoDefinesMethod: aSelector.
									(definer notNil and: [class includesClass: definer]) 
										ifTrue: 
											[self 
												refactoringError: ('Cannot pull up <1s> since <2p>>><3s> sends a super message to it.' 
														expandMacrosWith: aSelector
														with: aRBClass
														with: each)]]]]].
	aRBClass allSubclasses do: [:each | self checkSiblingSuperSendsFrom: each]
]

{ #category : #preconditions }
RBPullUpMethodRefactoring >> checkSuperMessages [
	self checkSuperSendsFromPushedUpMethods.
	self checkSuperSendsFromSiblings
]

{ #category : #preconditions }
RBPullUpMethodRefactoring >> checkSuperSendsFromPushedUpMethods [
	selectors do: 
			[:each | 
			| parseTree |
			parseTree := class parseTreeFor: each.
			parseTree superMessages 
				detect: [:sup | targetSuperclass directlyDefinesMethod: sup]
				ifFound: 
					[self 
						refactoringError: ('Cannot pull up <1s> since it sends a super message that is defined in the superclass.' 
								expandMacrosWith: each)]]
]

{ #category : #preconditions }
RBPullUpMethodRefactoring >> checkSuperSendsFromSiblings [
	| siblings |
	siblings := targetSuperclass subclasses reject: [:each | each = class].
	siblings do: [:aRBClass | self checkSiblingSuperSendsFrom: aRBClass]
]

{ #category : #preconditions }
RBPullUpMethodRefactoring >> checkSuperclass [
	| overrideSelectors |
	overrideSelectors := selectors
		select: [ :each | targetSuperclass directlyDefinesMethod: each ].
	overrideSelectors := overrideSelectors
		reject: [ :each | 
			| myTree superTree |
			myTree := class parseTreeFor: each.
			superTree := targetSuperclass parseTreeFor: each.
			superTree equalTo: myTree exceptForVariables: #() ].
	overrideSelectors ifEmpty: [ ^ self ].
	targetSuperclass isAbstract
		ifFalse: [ self
				refactoringError:
					('Non-abstract class <2p> already defines <1p>'
						expandMacrosWith: overrideSelectors asArray first
						with: targetSuperclass) ].
	overrideSelectors do: [ :each | self checkBackReferencesTo: each ]
]

{ #category : #private }
RBPullUpMethodRefactoring >> copyDownMethod: aSelector [ 
	| oldProtocol oldSource superclassDefiner subclasses refactoring |
	superclassDefiner := targetSuperclass whoDefinesMethod: aSelector.
	superclassDefiner ifNil: [^ self ].
	oldSource := superclassDefiner sourceCodeFor: aSelector.
	oldSource ifNil: 
			[ self 
				refactoringFailure: ('Source code for <1s> superclass method not available' 
						expandMacrosWith: aSelector)].
	oldProtocol := superclassDefiner protocolsFor: aSelector.
	subclasses := targetSuperclass subclasses 
				reject: [:each | each directlyDefinesMethod: aSelector].
	subclasses ifEmpty: [^ self ].
	(superclassDefiner parseTreeFor: aSelector) superMessages 
		detect: [:each | superclassDefiner directlyDefinesMethod: each]
		ifFound: 
			[self 
				refactoringError: ('Cannot pull up <1s> since we must copy down the superclass method in <2p><n>to the other subclasses, and the superclass method sends a super message which is overriden.' 
						expandMacrosWith: aSelector
						with: superclassDefiner)].
	self 
		refactoringWarning: 'Do you want to copy down the superclass method to the classes that don''t define ' 
				, aSelector, '?'.
	refactoring := RBExpandReferencedPoolsRefactoring 
				model: self model
				forMethod: (superclassDefiner parseTreeFor: aSelector)
				fromClass: superclassDefiner
				toClasses: subclasses.
	self performCompositeRefactoring: refactoring.
	subclasses do: [:each | each compile: oldSource classified: oldProtocol]
]

{ #category : #transforming }
RBPullUpMethodRefactoring >> copyDownMethods [
	selectors do: [:each | self copyDownMethod: each]
]

{ #category : #preconditions }
RBPullUpMethodRefactoring >> preconditions [
	self requestSuperClass.
	^(selectors inject: (RBCondition hasSuperclass: class)
		into: [:cond :each | cond & (RBCondition definesSelector: each in: class)]) 
			& (RBCondition withBlock: 
						[self checkInstVars.
						self checkClassVars.
						self checkSuperclass.
						self checkSuperMessages.
						true])
]

{ #category : #transforming }
RBPullUpMethodRefactoring >> pullUp: aSelector [ 
	| source refactoring |
	source := class sourceCodeFor: aSelector.
	source ifNil: [self refactoringFailure: 'Source for method not available'].
	refactoring := RBExpandReferencedPoolsRefactoring 
				model: self model
				forMethod: (class parseTreeFor: aSelector)
				fromClass: class
				toClasses: (Array with: targetSuperclass).
	self performCompositeRefactoring: refactoring.
	targetSuperclass compile: source
		classified: (class protocolsFor: aSelector)
]

{ #category : #initialization }
RBPullUpMethodRefactoring >> pullUp: selectorCollection from: aClass [ 
	self pullUp: selectorCollection from: aClass to: aClass superclass 
]

{ #category : #initialization }
RBPullUpMethodRefactoring >> pullUp: selectorCollection from: aClass to: aSuperClass [
	self setOption: #superClass toUse: [ :ref | ].
	class := self classObjectFor: aClass.
	targetSuperclass := self classObjectFor: aSuperClass .
	selectors := selectorCollection.
	removeDuplicates := false
]

{ #category : #transforming }
RBPullUpMethodRefactoring >> pullUpMethods [
	selectors do: [:each | self pullUp: each]
]

{ #category : #preconditions }
RBPullUpMethodRefactoring >> pushUpVariable: aVariable [
	| refactoring |
	refactoring :=  RBPullUpInstanceVariableRefactoring 
			model: self model
			variable: aVariable
			class: targetSuperclass.
	self performCompositeRefactoring: refactoring.
]

{ #category : #transforming }
RBPullUpMethodRefactoring >> removeDuplicateMethods [
	selectors do: [:each | self removeDuplicatesOf: each]
]

{ #category : #transforming }
RBPullUpMethodRefactoring >> removeDuplicatesOf: aSelector [ 
	| tree |
	tree := targetSuperclass parseTreeFor: aSelector.
	targetSuperclass allSubclasses do: 
			[:each | 
			((each directlyDefinesMethod: aSelector) and: 
					[(tree equalTo: (each parseTreeFor: aSelector) exceptForVariables: #()) 
						and: [(each superclass whoDefinesMethod: aSelector) == targetSuperclass]]) 
				ifTrue: 
					[removeDuplicates 
						ifFalse: 
							[removeDuplicates := 
							self 
								refactoringConfirmWarning: 'Do you want to remove duplicate subclass methods?'].
					removeDuplicates ifTrue:[
					each removeMethod: aSelector]]]
]

{ #category : #transforming }
RBPullUpMethodRefactoring >> removePulledUpMethods [
	selectors do: [:each | class removeMethod: each]
]

{ #category : #preconditions }
RBPullUpMethodRefactoring >> requestSuperClass [
	^(self options at: #superClass) value: self
]

{ #category : #initialization }
RBPullUpMethodRefactoring >> selectors [
	^ selectors
]

{ #category : #initialization }
RBPullUpMethodRefactoring >> selectors: aList [
	selectors := aList
]

{ #category : #printing }
RBPullUpMethodRefactoring >> storeOn: aStream [ 
	aStream nextPut: $(.
	self class storeOn: aStream.
	aStream nextPutAll: ' pullUp: '.
	selectors asArray storeOn: aStream.
	aStream nextPutAll: ' from: '.
	class storeOn: aStream.
	aStream nextPut: $)
]

{ #category : #initialization }
RBPullUpMethodRefactoring >> superClass: anObject [
	(anObject allSubclasses includes: class realClass ) 
		ifFalse: [ self refactoringError: 
			('<1s> is not a superclass of <2p>' expandMacrosWith: anObject with: class name ) ].
	targetSuperclass := self classObjectFor: anObject.
]

{ #category : #initialization }
RBPullUpMethodRefactoring >> targetClass [
	^ class
]

{ #category : #transforming }
RBPullUpMethodRefactoring >> transform [
	self
		copyDownMethods;
		pullUpMethods;
		removePulledUpMethods;
		removeDuplicateMethods
]
