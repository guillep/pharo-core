"
I am a variable node for representing an  indexed variable stored in a  Context object that does not have a name.  These are values that are pushed and popped on the stack when executing message sends. For example, the parameters neede to perform a message send are pushed in a Context object.
"
Class {
	#name : #GTInspectorContextIndexedTempNode,
	#superclass : #GTInspectorVariableNode,
	#instVars : [
		'tempIndex'
	],
	#category : #'GT-Inspector'
}

{ #category : #'instance creation' }
GTInspectorContextIndexedTempNode class >> hostObject: aContext tempIndex: anInteger [
	^ (self hostObject: aContext) 
		tempIndex: anInteger;
		yourself
]

{ #category : #accessing }
GTInspectorContextIndexedTempNode >> label [
	^ self tempIndex
]

{ #category : #accessing }
GTInspectorContextIndexedTempNode >> rawValue [
	^ self hostObject at: self tempIndex
]

{ #category : #accessing }
GTInspectorContextIndexedTempNode >> tempIndex [
	^ tempIndex
]

{ #category : #accessing }
GTInspectorContextIndexedTempNode >> tempIndex: anObject [
	tempIndex := anObject
]

{ #category : #accessing }
GTInspectorContextIndexedTempNode >> variableTag [
	^  'temp' 
]
