"
I implement a complex filter on top of my inner iterator.
I will take the filtering text and split it on the spaces, $: and camel case syntax to try to detect all the elements that have those words.

My iterator is query with the first word of the filtering text and the filtering the elements that have all the words in any part. 
For example, doing the query StoreDisk will answer also DiskStore 
"
Class {
	#name : #StWordsAwareFilter,
	#superclass : #StIteratorDecorator,
	#instVars : [
		'words',
		'realFilter'
	],
	#category : #'NewTools-Spotter-Processors-Iterators'
}

{ #category : #filtering }
StWordsAwareFilter >> additionalFilter: aString firstWord: firstWord otherWords: otherWords on: anEntry [

	^ otherWords allSatisfy: [ :otherW | anEntry asString asLowercase includesSubstring: otherW ]

]

{ #category : #filtering }
StWordsAwareFilter >> filteringText: aString [

	| firstWord otherWords |
	words := self splitWords: aString.
	words ifEmpty: [ ^ self ].
	
	firstWord := words first.
	otherWords := words allButFirst collect: [:each | each asLowercase].
		
	realFilter filteringText: firstWord.
	inner := realFilter select: [ :anEntry | 
		anEntry isNotNil and: 
		[self additionalFilter: aString firstWord: firstWord otherWords: otherWords on: anEntry ]].

]

{ #category : #accessing }
StWordsAwareFilter >> inner: anIterator [

	inner := anIterator.
	realFilter := anIterator
]

{ #category : #filtering }
StWordsAwareFilter >> splitWords: aString [

	^ (aString substrings: ' :-')
		flatCollect: [ :each | each splitCamelCase  ]
]
