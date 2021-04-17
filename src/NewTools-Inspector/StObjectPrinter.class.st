"
This is a utility class for printing objects to Text or String.

"
Class {
	#name : #StObjectPrinter,
	#superclass : #Object,
	#category : #'NewTools-Inspector-Model'
}

{ #category : #converting }
StObjectPrinter class >> asNonTruncatedTextFrom: anObject [
	"I return a representation of the receiver in which all lines breaks 
	are replaced by spaces. I return a String unless there is an error 
	printing the object. In this case I return a Text highlighted in red."
	^ [ anObject asString replaceAll: String cr with: String space ] 
			on: Error 
			do: [ Text string: 'error printing' attribute: TextColor red ]
]

{ #category : #converting }
StObjectPrinter class >> asTruncatedTextFrom: anObject [
	"I return a truncated representation of the receiver in which all lines breaks 
	are replaced by spaces. I return a String unless there is an error printing the
	object. In this case I return a Text highlighted in red."
	^ [ (anObject displayString copyReplaceAll: String cr with: String space) replaceAll: String lf with: String space ]
		on: Error
		do: [ Text string: 'error printing' attribute: TextColor red ]
]

{ #category : #printing }
StObjectPrinter >> asNonTruncatedTextFrom: anObject [
	^ self class asNonTruncatedTextFrom: anObject
]

{ #category : #printing }
StObjectPrinter >> asTruncatedTextFrom: anObject [
	^ self class asTruncatedTextFrom: anObject
]
