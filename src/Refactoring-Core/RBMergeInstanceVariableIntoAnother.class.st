"
I am a refactoring for merge an instance variable into another.

I replace an instance variable by other, in all methods refering to this variable and rename the old accessors, then if the instance variable renamed is directly defined in class it is removed.

My precondition verifies that the new variable is a defined instance variable in class.

Example
----------------------------
Script
```
(RBMergeInstanceVariableIntoAnother rename: 'x' to: 'y' in: Foo) execute.
```

Before refactoring:
```
Class Foo -> inst vars: x, y 

Foo >> foobar
	^ x 

Foo >> foo
	^ x + y 
```
After refactoring merging X into Y
```
Class Foo -> inst vars: y 

Foo >> foobar
	^ y

Foo >> foo 
	^ y + y
```
"
Class {
	#name : #RBMergeInstanceVariableIntoAnother,
	#superclass : #RBRenameInstanceVariableRefactoring,
	#category : #'Refactoring-Core-Refactorings'
}

{ #category : #preconditions }
RBMergeInstanceVariableIntoAnother >> preconditions [
	^(RBCondition definesInstanceVariable: variableName in: class) 
			& (RBCondition definesInstanceVariable: newName in: class) 
]

{ #category : #transforming }
RBMergeInstanceVariableIntoAnother >> renameVariable [ 
	model 
		renameInstanceVariable: variableName
		to: newName
		in: class
		around: [ self renameReferences ].
]

{ #category : #transforming }
RBMergeInstanceVariableIntoAnother >> transform [
	renameAccessors ifTrue: [ 
		self removeOldAccessors 
	].
	
	self renameVariable.
	
	renameAccessors ifFalse: [ ^ self ].
	self addNewAccessors.
	self renameAccessorsReferences.
]
