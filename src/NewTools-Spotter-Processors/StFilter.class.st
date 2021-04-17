"
I implement the select: operation on the iterator.
I apply the block and filter the elements returned by myself.

"
Class {
	#name : #StFilter,
	#superclass : #StIteratorBlockDecorator,
	#category : #'NewTools-Spotter-Processors-Iterators'
}

{ #category : #initialization }
StFilter >> filter: aValue [

	^ aBlock value: aValue
]

{ #category : #accessing }
StFilter >> next [

	| value |

	[ inner atEnd ]
		whileFalse: [ value := inner next.
			(self filter: value)
				ifTrue: [ ^ value ] ].
	^ nil
]
