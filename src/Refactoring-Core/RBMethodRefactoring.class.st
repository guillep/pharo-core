"
I am an abstract base class for method refactorings.

I only provide a helper method for generating  selector names.
"
Class {
	#name : #RBMethodRefactoring,
	#superclass : #RBRefactoring,
	#instVars : [
		'class'
	],
	#category : #'Refactoring-Core-Refactorings'
}

{ #category : #private }
RBMethodRefactoring >> buildSelectorString: aSelector [ 
	aSelector numArgs = 0 ifTrue: [^aSelector].
	^self buildSelectorString: aSelector
		withPermuteMap: (1 to: aSelector numArgs)
]

{ #category : #private }
RBMethodRefactoring >> buildSelectorString: aSelector withPermuteMap: anIntegerCollection [ 
	| stream keywords |
	aSelector numArgs == 0 ifTrue: [^aSelector asString].
	stream := WriteStream on: String new.
	keywords := aSelector keywords.
	keywords with: anIntegerCollection
		do: 
			[:each :i | 
			stream
				nextPutAll: each;
				nextPutAll: ' ``@arg';
				nextPutAll: i printString;
				nextPut: $ ].
	^stream contents
]

{ #category : #accessing }
RBMethodRefactoring >> methodClass [ 
	^ class
]
