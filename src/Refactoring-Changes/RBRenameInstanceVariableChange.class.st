"
I am a refactory change for a instance variable renaming. The RBRefactory api is implemented in my super class, I just define
the concrete ""instance variable"" renaming.
"
Class {
	#name : #RBRenameInstanceVariableChange,
	#superclass : #RBRenameVariableChange,
	#category : #'Refactoring-Changes'
}

{ #category : #private }
RBRenameInstanceVariableChange >> addNewVariable [
	(self changeClass allInstVarNames includes: newName) 
		ifFalse: [ (changeFactory addInstanceVariable: newName to: self changeClass) execute ]
]

{ #category : #private }
RBRenameInstanceVariableChange >> copyOldValuesToNewVariable [
	self changeClass withAllSubclasses do: [ :class |
		class allInstances 
			do: [ :each | each instVarNamed: newName asString put: (each instVarNamed: oldName asString) ] ]
]

{ #category : #printing }
RBRenameInstanceVariableChange >> printOn: aStream [
	aStream
		nextPutAll: self displayClassName;
		nextPutAll: ' removeInstVarName: ';
		print: self oldName;
		nextPut: $!; cr.
	aStream
		nextPutAll: self displayClassName;
		nextPutAll: ' addInstVarName: ';
		print: self newName;
		nextPut: $!
]

{ #category : #private }
RBRenameInstanceVariableChange >> removeOldVariable [
	(self changeClass allInstVarNames includes: oldName) 
		ifTrue: [ (changeFactory removeInstanceVariable: oldName from: self changeClass) execute ]
]
