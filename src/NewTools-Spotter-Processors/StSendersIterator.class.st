"
I am an iterator to find the senders of a message.
I always receive a filteringText because it does not have any sense to show senders of an empty string.
Also, I lookup all the senders of the complete symbol.
"
Class {
	#name : #StSendersIterator,
	#superclass : #StGenericGenerator,
	#instVars : [
		'selector'
	],
	#category : #'NewTools-Spotter-Processors-Iterators'
}

{ #category : #enumerating }
StSendersIterator >> elementsDo: aValuable [

	selector ifNil: [ ^ self ].
	^ selector senders do: [ :aMethod | aValuable value: (StMethodEntry on: aMethod )]
]

{ #category : #filtering }
StSendersIterator >> filteringText: aString [

	selector := aString ifEmpty: [ nil] ifNotEmpty: [aString asSymbol].
	self reset.
]
