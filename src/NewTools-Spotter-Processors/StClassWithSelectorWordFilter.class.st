Class {
	#name : #StClassWithSelectorWordFilter,
	#superclass : #StWordsAwareFilter,
	#instVars : [
		'className'
	],
	#category : #'NewTools-Spotter-Processors-Iterators'
}

{ #category : #filtering }
StClassWithSelectorWordFilter >> additionalFilter: aString firstWord: firstWord otherWords: otherWords on: anEntry [

	^ anEntry content methodClass name = className
		and: [ otherWords
				allSatisfy: [ :otherW | anEntry asString asLowercase includesSubstring: otherW ] ]
]

{ #category : #filtering }
StClassWithSelectorWordFilter >> splitWords: aString [

	| splitted message |

	splitted := aString splitOn: '>>'.
	splitted size = 1 ifTrue: [ ^ super splitWords: aString ].
	
	className := splitted first trimBoth.
	message := (splitted second copyWithout: $#) trimBoth.
	
	className isEmpty 
		ifTrue: [ ^ super splitWords: aString ].
	
	^ super splitWords: message
		
	
]
