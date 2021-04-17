"
I implement the collect: operation on the iterator.
I apply the block and transform the elements returned by myself.

"
Class {
	#name : #StTransformation,
	#superclass : #StIteratorBlockDecorator,
	#category : #'NewTools-Spotter-Processors-Iterators'
}

{ #category : #accessing }
StTransformation >> next [
	^ inner next ifNotNil: [ :aValue | self transform: aValue ]
]

{ #category : #tranforming }
StTransformation >> transform: anElement [

	^ aBlock value: anElement
]
