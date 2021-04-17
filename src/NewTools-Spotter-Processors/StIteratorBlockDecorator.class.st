"
I implement a simple block decorator, I am a abstract class that have a block.
"
Class {
	#name : #StIteratorBlockDecorator,
	#superclass : #StIteratorDecorator,
	#instVars : [
		'aBlock'
	],
	#category : #'NewTools-Spotter-Processors-Iterators'
}

{ #category : #'instance creation' }
StIteratorBlockDecorator class >> on: aStGeneratorIterator with: aBlockClosure [ 
	
	^ self new
		inner: aStGeneratorIterator;
		block: aBlockClosure;
		yourself
]

{ #category : #accessing }
StIteratorBlockDecorator >> block: aBlockClosure [

	aBlock := aBlockClosure
]
