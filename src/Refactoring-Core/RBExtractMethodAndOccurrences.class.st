"
I am a refactoring for creating a method from a code fragment and then find all occurrences of code fragment in its class and its hierarchy if apply.

You can select an interval of some code in a method and call this refactoring to create a new method implementing that code and replace the code by calling this method instead. Then find occurrences of extracted method in all class methods and replace the duplicated code by calling extracted method istead.
"
Class {
	#name : #RBExtractMethodAndOccurrences,
	#superclass : #RBMethodRefactoring,
	#instVars : [
		'extractionInterval',
		'selector'
	],
	#category : #'Refactoring-Core-Refactorings'
}

{ #category : #'instance creation' }
RBExtractMethodAndOccurrences class >> extract: anInterval from: aSelector in: aClass [ 
	^self new
		extract: anInterval
		from: aSelector
		in: aClass
]

{ #category : #'instance creation' }
RBExtractMethodAndOccurrences class >> model: aRBSmalltalk extract: anInterval from: aSelector in: aClass [ 
	^(self new)
		model: aRBSmalltalk;
		extract: anInterval
			from: aSelector
			in: aClass;
		yourself
]

{ #category : #'instance creation' }
RBExtractMethodAndOccurrences >> extract: anInterval from: aSelector in: aClass [ 
	class := self classObjectFor: aClass.
	selector := aSelector.
	extractionInterval := anInterval
]

{ #category : #transforming }
RBExtractMethodAndOccurrences >> extractMethod [

	| refactoring |
	refactoring := self extractMethodClass
		               model: self model
		               extract: extractionInterval
		               from: selector
		               in: class.
	self performCompositeRefactoring: refactoring.
	^ refactoring newExtractedSelector
]

{ #category : #transforming }
RBExtractMethodAndOccurrences >> extractMethodClass [

	^ RBExtractMethodRefactoring
]

{ #category : #transforming }
RBExtractMethodAndOccurrences >> findImplementorOf: aSelector [
	(class directlyDefinesMethod: aSelector) ifTrue: [ ^ true ].
	class superclass ifNotNil: [
		class := class superclass.
		^ self findImplementorOf: aSelector.
	].
	^ false
]

{ #category : #transforming }
RBExtractMethodAndOccurrences >> findOccurrencesClass [

	^ RBFindAndReplaceRefactoring
]

{ #category : #transforming }
RBExtractMethodAndOccurrences >> findOccurrencesOf: aSelector [

	| refactoring |
	(self findImplementorOf: aSelector)
		ifTrue: [ 
			refactoring := self findOccurrencesClass
				               model: self model
				               find: aSelector
				               of: class
				               inWholeHierarchy: self shouldSearchInHierarchy.
			self performCompositeRefactoring: refactoring ]
		ifFalse: [ 
			self refactoringFailure:
				aSelector , ' is not a valid selector name.' ]
]

{ #category : #preconditions }
RBExtractMethodAndOccurrences >> preconditions [

	^ self emptyCondition
]

{ #category : #asserting }
RBExtractMethodAndOccurrences >> shouldSearchInHierarchy [
	^(self options at: #searchInWholeHierarchy) value: self value: class
]

{ #category : #printing }
RBExtractMethodAndOccurrences >> storeOn: aStream [ 
	aStream nextPut: $(.
	self class storeOn: aStream.
	aStream nextPutAll: ' extract: '.
	extractionInterval storeOn: aStream.
	aStream
		nextPutAll: ' from: #';
		nextPutAll: selector;
		nextPutAll: ' in: '.
	class storeOn: aStream.
	aStream nextPut: $)
]

{ #category : #transforming }
RBExtractMethodAndOccurrences >> transform [ 
	| newExtractedSelector |
	newExtractedSelector := self extractMethod.
	self findOccurrencesOf: newExtractedSelector.
]
