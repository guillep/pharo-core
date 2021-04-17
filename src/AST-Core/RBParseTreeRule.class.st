"
RBParseTreeRule is the abstract superclass of all of the parse tree searching rules. A parse tree rule is the first-class representation of a particular rule to search for. The owner of a rule is the algorithm that actually executes the search. This arrangement allows multiple searches to be conducted by a single Searcher.

Instance Variables:
	owner	<ParseTreeSearcher>	The searcher that is actually performing the search.
	searchTree	<RBProgramNode>	The parse tree to be searched.


"
Class {
	#name : #RBParseTreeRule,
	#superclass : #Object,
	#instVars : [
		'searchTree',
		'owner'
	],
	#category : #'AST-Core-Matching'
}

{ #category : #testing }
RBParseTreeRule class >> isAbstract [

	^ self == RBParseTreeRule
]

{ #category : #'instance creation' }
RBParseTreeRule class >> methodSearch: aString [ 
	^(self new)
		methodSearchString: aString;
		yourself
]

{ #category : #'instance creation' }
RBParseTreeRule class >> search: aString [ 
	^(self new)
		searchString: aString;
		yourself
]

{ #category : #testing }
RBParseTreeRule >> canMatch: aProgramNode [ 
	^true
]

{ #category : #private }
RBParseTreeRule >> context [
	^owner context
]

{ #category : #matching }
RBParseTreeRule >> foundMatchFor: aProgramNode [
	^aProgramNode
]

{ #category : #initialization }
RBParseTreeRule >> methodSearchString: aString [
	searchTree := self parserClass parseRewriteMethod: aString
]

{ #category : #'initialize-release' }
RBParseTreeRule >> owner: aParseTreeSearcher [
	owner := aParseTreeSearcher
]

{ #category : #initialization }
RBParseTreeRule >> parserClass [
	^ RBParser
]

{ #category : #matching }
RBParseTreeRule >> performOn: aProgramNode [ 
	self context empty.
	^((searchTree match: aProgramNode inContext: self context) 
		and: [self canMatch: aProgramNode]) 
			ifTrue:
				[owner recusivelySearchInContext.
				self foundMatchFor: aProgramNode]
			ifFalse: [nil]
			
		
]

{ #category : #initialization }
RBParseTreeRule >> searchString: aString [
	searchTree := self parserClass parseRewriteExpression: aString
]

{ #category : #accessing }
RBParseTreeRule >> sentMessages [
	^searchTree sentMessages
]
