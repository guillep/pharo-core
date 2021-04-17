Class {
	#name : #StCamelCaseSplitTest,
	#superclass : #TestCase,
	#category : #'NewTools-Spotter-Processors-Tests'
}

{ #category : #tests }
StCamelCaseSplitTest >> testSingleLowercaseLetter [

	self 
		assertCollection: 'a' splitCamelCase 
		hasSameElements: {'a'}
]

{ #category : #tests }
StCamelCaseSplitTest >> testSingleUppercaseLetter [

	self 
		assertCollection: 'A' splitCamelCase 
		hasSameElements: { 'A' }
]

{ #category : #tests }
StCamelCaseSplitTest >> testSplittingShouldNotLosePrefix [

	self 
		assertCollection: 'GTSpotter' splitCamelCase 
		hasSameElements: {'GTSpotter'}
]

{ #category : #tests }
StCamelCaseSplitTest >> testTwoDifferentWordsStartingWithLowerCase [

	self 
		assertCollection: 'anObject' splitCamelCase 
		hasSameElements: {'an'. 'Object'}
]

{ #category : #tests }
StCamelCaseSplitTest >> testTwoDifferentWordsStartingWithUpperCase [

	self 
		assertCollection: 'AnObject' splitCamelCase 
		hasSameElements: {'An'. 'Object'}
]
