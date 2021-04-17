"
I wrap a Window, to modify its behavior if required for the spotter
"
Class {
	#name : #StWindowEntry,
	#superclass : #StEntry,
	#category : #'NewTools-Spotter-Processors-Entries'
}

{ #category : #converting }
StWindowEntry >> asString [ 

	^ '{1} [{2}]' format: { content label. content className }
]

{ #category : #evaluating }
StWindowEntry >> doEvaluate [
	content spotterActDefault
]

{ #category : #accessing }
StWindowEntry >> icon [
	
	^ content taskbarIcon
]
