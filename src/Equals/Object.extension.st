Extension { #name : #Object }

{ #category : #'*Equals' }
Object class >> allInstVarNamesForEqualityComparison [
	^self superclass allInstVarNamesForEqualityComparison, self instVarNamesForEqualityComparison
]

{ #category : #'*Equals' }
Object class >> instVarNamesForEqualityComparison [
	^self instVarNames
]

{ #category : #'*Equals' }
Object >> instVarNamesForEqualityComparison [
	^self class allInstVarNamesForEqualityComparison
]

{ #category : #'*Equals' }
Object >> valuesToCompareForEquality [
	^self instVarNamesForEqualityComparison collect: [:ivName|
		self instVarNamed: ivName]
]
