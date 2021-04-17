"
I am a refactoring for removing a method.

My preconditions verify that this method is not referenced anywhere.
"
Class {
	#name : #RBRemoveMethodRefactoring,
	#superclass : #RBMethodRefactoring,
	#instVars : [
		'selectors'
	],
	#category : #'Refactoring-Core-Refactorings'
}

{ #category : #'instance creation' }
RBRemoveMethodRefactoring class >> model: aRBSmalltalk removeMethods: selectorCollection from: aClass [ 
	^(self new)
		model: aRBSmalltalk;
		removeMethods: selectorCollection from: aClass;
		yourself
]

{ #category : #'instance creation' }
RBRemoveMethodRefactoring class >> removeMethods: selectorCollection from: aClass [
	^self new removeMethods: selectorCollection from: aClass
]

{ #category : #preconditions }
RBRemoveMethodRefactoring >> checkBrowseAllOccurrences: anCollectionOfOccurrences [
	| methods callers |
	methods := anCollectionOfOccurrences collect: [ :c | c key ] as: Set.
	callers := anCollectionOfOccurrences collect: [ :v | v value ].
	methods size = 1
		ifTrue: [ 
			self
				refactoringError:
					('Possible call to <2s> in <1p> methods.<n>Browse references?'
						expandMacrosWith: anCollectionOfOccurrences size
						with: methods anyOne)
				with: [ self openBrowserOn: (RBBrowserEnvironment new referencesTo: methods anyOne) ] ]
		ifFalse: [ 
			self
				refactoringError:
					('Possible call to the <2p> selectors in <1p> methods.<n>Browse references?'
						expandMacrosWith: callers size
						with: methods size)
				with: [ 
					| env |
					env := RBSelectorEnvironment new.
					callers do: [ :d | env addMethod: d method ].
					self openBrowserOn: env ] ]
]

{ #category : #preconditions }
RBRemoveMethodRefactoring >> checkBrowseOccurrenceOf: selector in: aRBMethod [
	self
		refactoringError:
			('Possible call to <2s> in <1p><n>Browse references?' expandMacrosWith: aRBMethod modelClass with: selector)
		with: [ self openBrowserOn: (RBBrowserEnvironment new referencesTo: selector) ]
]

{ #category : #preconditions }
RBRemoveMethodRefactoring >> checkBrowseOccurrences: anCollectionOfOccurrences [
	^ anCollectionOfOccurrences size = 1
		ifTrue: [ self checkBrowseOccurrenceOf: anCollectionOfOccurrences first key in: anCollectionOfOccurrences first value ]
		ifFalse: [ self checkBrowseAllOccurrences: anCollectionOfOccurrences ]
]

{ #category : #preconditions }
RBRemoveMethodRefactoring >> checkReferencesToAnyOf: aSelectorCollection [
	| occurrences |
	occurrences := OrderedCollection new.
	aSelectorCollection
		do: [ :each | 
			self model
				allReferencesTo: each
				do: [ :aRBMethod | 
					(aSelectorCollection includes: aRBMethod selector)
						ifFalse: [ occurrences add: each -> aRBMethod ] ] ].
	occurrences ifEmpty: [ ^ self ].
	^ self checkBrowseOccurrences: occurrences
]

{ #category : #preconditions }
RBRemoveMethodRefactoring >> checkReferencesToSuperSendsToAnyOf: superMessages [ 
	[superMessages isEmpty] whileFalse: 
			[self 
				refactoringWarning: ('Although <1s> is equivalent to a superclass method,<n>it contains a super send so it might modify behavior.<n>Proceed anyway?' 
						expandMacrosWith: superMessages first).
			superMessages remove: superMessages first]
]

{ #category : #preconditions }
RBRemoveMethodRefactoring >> checkSuperMethods [
	| superMessages nonSupers |
	nonSupers := OrderedCollection new.
	superMessages := OrderedCollection new.
	(selectors reject: [:each | self justSendsSuper: each]) do: 
			[:each | 
			(self superclassEquivalentlyDefines: each) 
				ifTrue: 
					[(class parseTreeFor: each) superMessages isEmpty 
						ifFalse: [superMessages add: each]]
				ifFalse: [nonSupers add: each]].
	nonSupers isEmpty & superMessages isEmpty ifTrue: [^self].
	self checkReferencesToAnyOf: nonSupers.
	self checkReferencesToSuperSendsToAnyOf: superMessages
]

{ #category : #preconditions }
RBRemoveMethodRefactoring >> justSendsSuper: aSelector [

	| matcher parseTree superclass |

	matcher := self parseTreeSearcherClass justSendsSuper.
	parseTree := class parseTreeFor: aSelector.
	( matcher executeTree: parseTree initialAnswer: false )
		ifFalse: [ ^ false ].
	parseTree lastIsReturn
		ifTrue: [ ^ true ].
	superclass := class superclass whichClassIncludesSelector: aSelector.
	superclass ifNil: [ ^ true ].	"Since there isn't a superclass that implements the message, we can 
								 delete it since it would be an error anyway."
	parseTree := superclass parseTreeFor: aSelector.
	matcher := self parseTreeSearcher.
	matcher
		matches: '^``@object'
		do: [ :aNode :answer | 
			answer
				add: aNode value;
				yourself
			].
	matcher executeTree: parseTree initialAnswer: Set new.
	^ ( matcher answer anySatisfy: [ :each | each isSelfVariable not ]) not
]

{ #category : #preconditions }
RBRemoveMethodRefactoring >> preconditions [

	^ (selectors
		   inject: self emptyCondition
		   into: [ :cond :each | 
		   cond & (RBCondition definesSelector: each in: class) ])
	  & (RBCondition withBlock: [ 
			   self checkSuperMethods.
			   true ])
]

{ #category : #initialization }
RBRemoveMethodRefactoring >> removeMethods: selectorCollection from: aClass [ 
	class := self classObjectFor: aClass.
	selectors := selectorCollection
]

{ #category : #printing }
RBRemoveMethodRefactoring >> storeOn: aStream [ 
	aStream nextPut: $(.
	self class storeOn: aStream.
	aStream nextPutAll: ' removeMethods: '.
	selectors asArray storeOn: aStream.
	aStream nextPutAll: ' from: '.
	class storeOn: aStream.
	aStream nextPut: $)
]

{ #category : #preconditions }
RBRemoveMethodRefactoring >> superclassEquivalentlyDefines: aSelector [

	| superTree myTree |

	class superclass ifNil: [ ^ false ].
	superTree := class superclass parseTreeFor: aSelector.
	myTree := class parseTreeFor: aSelector.
	( superTree isNil or: [ myTree isNil ] )
		ifTrue: [ ^ false ].
	^ superTree equalTo: myTree exceptForVariables: #()
]

{ #category : #transforming }
RBRemoveMethodRefactoring >> transform [
	selectors do: [:each | class removeMethod: each]
]
