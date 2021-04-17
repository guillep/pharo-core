"
I am a refactory change for a class variable renaming. The RBRefactory api is implemented in my super class, I just define
the concrete ""classvariable"" renaming.
"
Class {
	#name : #RBRenameClassVariableChange,
	#superclass : #RBRenameVariableChange,
	#category : #'Refactoring-Changes'
}

{ #category : #private }
RBRenameClassVariableChange >> addNewVariable [
	(changeFactory addClassVariable: newName to: self changeClass)
		execute
]

{ #category : #private }
RBRenameClassVariableChange >> copyOldValuesToNewVariable [
	| oldValue |
	oldValue := self changeClass classPool at: oldName ifAbsent: [ nil ].
	self changeClass classPool at: newName asSymbol put: oldValue
]

{ #category : #printing }
RBRenameClassVariableChange >> printOn: aStream [ 
	aStream
		nextPutAll: self displayClassName;
		nextPutAll: ' removeClassVarName: ';
		print: self oldName;
		nextPut: $!; cr.
	aStream
		nextPutAll: self displayClassName; 
		nextPutAll: ' addClassVarName: '; 
		print: self newName;
		nextPut: $!
]

{ #category : #private }
RBRenameClassVariableChange >> removeOldVariable [
	(changeFactory removeClassVariable: oldName from: self changeClass)
		execute
]
