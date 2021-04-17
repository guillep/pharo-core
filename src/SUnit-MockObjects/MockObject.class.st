"
I am a test double object that can be used as a stub, a fake, or a mock.

I provide a simple protocol so that the user can teach me what messages to expect, and how to behave or respond to these messages.

# Usage
A new object can be created with ```MockObject new```, or using the utility methods on the class side _instance creation_ protocol.

The main message to teach a MockObject is ```#on:withArguments:verify:```; the other methods in the _teaching_ protocol all send this message.
This message takes a selector symbol, a collection of arguments, and a block. By sending this message, the mock object is trained to evaluate the block when receiving a message matching the selector and the arguments.
Other variations of this message have more specialized behaviour: ```#on:withArguments:respond:``` will simply return its third argument when the mock receives a matching message; likewise ```:#on:withArguments:``` will return the mock itself.
The other methods in the _teaching_ protocol provide an ergonomic API for this behaviour.

A mock object will expect to receive only the messages it has been trained on, in the same order and number as it was trained. If it receives an unknown message, or a known message but in the wrong order, it will simply return itself.


# Stubs, Fakes, and Mocks
A MockObject can be used as a stub by not using the ```verify:``` variants of the _teaching_ protocol.

It can also be used as a fake by using the ```verify:``` variants with a non-trivial block.

To use the MockObject as a real mock, the user needs to verify its use. This is done by means of the ```TestCase>>verify:``` message. Verification needs to be triggered by the user - it's not automatic.

The ```#verify:``` message will assert 1) that the mock has received all the messages it has been trained on 2) that it has not received only those messages 3) that it has received the messages it has been trained on.
"
Class {
	#name : #MockObject,
	#superclass : #Object,
	#instVars : [
		'messages',
		'failed'
	],
	#classInstVars : [
		'any'
	],
	#category : #'SUnit-MockObjects'
}

{ #category : #accessing }
MockObject class >> any [

	^ any ifNil: [ any := Object new ]
]

{ #category : #'instance creation' }
MockObject class >> on: aSymbol [

	^ self new
		  on: aSymbol;
		  yourself
]

{ #category : #'instance creation' }
MockObject class >> on: aSymbol respond: anObject [

	^ self new
		  on: aSymbol respond: anObject;
		  yourself
]

{ #category : #'reflective operations' }
MockObject >> doesNotUnderstand: aMessage [
	messages isEmpty
		ifTrue: [ failed := true ]
		ifFalse: [ | expected |
			expected := messages removeFirst.
			(expected matches: aMessage)
				ifTrue: [ ^ expected valueWithPossibleArgs: aMessage arguments ]
				ifFalse: [ messages addFirst: expected.
					failed := true ] ]
]

{ #category : #'reflective operations' }
MockObject >> initialize [

	messages := OrderedCollection new.
	failed := false
]

{ #category : #teaching }
MockObject >> on: aSymbol [

	self on: aSymbol respond: self
]

{ #category : #teaching }
MockObject >> on: aSymbol respond: anObject [

	self on: aSymbol withArguments: nil respond: anObject
]

{ #category : #teaching }
MockObject >> on: aSymbol verify: aBlock [

	self on: aSymbol withArguments: nil verify: aBlock
]

{ #category : #teaching }
MockObject >> on: aSymbol with: anObject [

	self on: aSymbol withArguments: { anObject } respond: self
]

{ #category : #teaching }
MockObject >> on: aSymbol with: anObject respond: anotherObject [

	self
		on: aSymbol
		withArguments: { anObject }
		verify: [ anotherObject ]
]

{ #category : #teaching }
MockObject >> on: aSymbol with: anObject verify: aBlock [

	self on: aSymbol withArguments: { anObject } verify: aBlock
]

{ #category : #teaching }
MockObject >> on: aSymbol with: anObject with: anotherObject [

	self
		on: aSymbol
		withArguments: { 
				anObject.
				anotherObject }
		respond: self
]

{ #category : #teaching }
MockObject >> on: aSymbol with: anObject with: anotherObject respond: aResponseObject [

	self
		on: aSymbol
		withArguments: { 
				anObject.
				anotherObject }
		verify: [ aResponseObject ]
]

{ #category : #teaching }
MockObject >> on: aSymbol with: anObject with: anotherObject verify: aBlock [

	self
		on: aSymbol
		withArguments: { 
				anObject.
				anotherObject }
		verify: aBlock
]

{ #category : #teaching }
MockObject >> on: aSymbol with: anObject with: anotherObject with: aThirdObject [

	self
		on: aSymbol
		withArguments: { 
				anObject.
				anotherObject.
				aThirdObject }
		respond: self
]

{ #category : #teaching }
MockObject >> on: aSymbol with: anObject with: anotherObject with: aThirdObject respond: aResponseObject [

	self
		on: aSymbol
		withArguments: { 
				anObject.
				anotherObject.
				aThirdObject }
		verify: [ aResponseObject ]
]

{ #category : #teaching }
MockObject >> on: aSymbol with: anObject with: anotherObject with: aThirdObject verify: aBlock [

	self
		on: aSymbol
		withArguments: { 
				anObject.
				anotherObject.
				aThirdObject }
		verify: aBlock
]

{ #category : #teaching }
MockObject >> on: aSymbol withArguments: aCollection [

	self on: aSymbol withArguments: aCollection respond: self
]

{ #category : #teaching }
MockObject >> on: aSymbol withArguments: anArray respond: anObject [

	self on: aSymbol withArguments: anArray verify: [ anObject ]
]

{ #category : #teaching }
MockObject >> on: aSymbol withArguments: anArray verify: aBlock [
	
	messages add: (MockMessageSend on: aSymbol with: anArray do: aBlock).
	failed := false
]

{ #category : #verifying }
MockObject >> verifyIn: aTestCase [

	aTestCase deny: failed description: 'Incorrect message sequence'.
	aTestCase
		assert: messages isEmpty
		description: 'Mock still has messages pending'
]
