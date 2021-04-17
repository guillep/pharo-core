"
I am a message that a MockObject instance has been trained to expect.
"
Class {
	#name : #MockMessageSend,
	#superclass : #Object,
	#instVars : [
		'selector',
		'arguments',
		'behavior'
	],
	#category : #'SUnit-MockObjects'
}

{ #category : #'instance creation' }
MockMessageSend class >> on: aSymbol with: anArray do: aBlock [

	^ self new
		  on: aSymbol with: anArray do: aBlock;
		  yourself
]

{ #category : #testing }
MockMessageSend >> matches: aMessage [

	^ (self matchesSelector: aMessage selector) and: [ 
		  self matchesArguments: aMessage arguments ]
]

{ #category : #testing }
MockMessageSend >> matchesArguments: anArray [

	arguments ifNil: [ ^ true ].
	arguments size = anArray size ifFalse: [ ^ false ].
	anArray with: arguments do: [ :actual :expected | 
		(expected ~= MockObject any and: [ actual ~= expected ]) ifTrue: [ 
			^ false ] ].
	^ true
]

{ #category : #testing }
MockMessageSend >> matchesSelector: aSymbol [

	^ selector = aSymbol
]

{ #category : #initialization }
MockMessageSend >> on: aSymbol with: anArray do: aBlock [

	selector := aSymbol.
	arguments := anArray.
	behavior := aBlock
]

{ #category : #accessing }
MockMessageSend >> selector [

	^ selector
]

{ #category : #evaluating }
MockMessageSend >> valueWithPossibleArgs: anArray [

	^ behavior valueWithPossibleArgs: anArray
]
