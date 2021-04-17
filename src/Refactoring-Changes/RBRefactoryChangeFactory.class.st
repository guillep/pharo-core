"
This object is the  abstract factory of all the changes, 
the idea is to have another version of the changes that can use the atomic class installer.
"
Class {
	#name : #RBRefactoryChangeFactory,
	#superclass : #Object,
	#category : #'Refactoring-Changes'
}

{ #category : #accessing }
RBRefactoryChangeFactory class >> instance [
	^ RBRefactoryChangeManager instance changeFactory
]

{ #category : #'refactory-changes-classes' }
RBRefactoryChangeFactory >> addClassDefinition: definition [
	^ RBAddClassChange definition: definition.
]

{ #category : #'refactory-changes-classes' }
RBRefactoryChangeFactory >> addClassDefinition: definition for: aController [
	^ RBAddClassChange definition: definition for: aController.
]

{ #category : #'refactory-changes-classes' }
RBRefactoryChangeFactory >> addClassDefinition: definition for: aController context: aDictionary [
	^ RBAddClassChange definition: definition for: aController context: aDictionary.
]

{ #category : #'refactory-changes-variables' }
RBRefactoryChangeFactory >> addClassVariable: variableName to: aClass [
	^ RBAddClassVariableChange add: variableName to: aClass
]

{ #category : #'refactory-changes-variables' }
RBRefactoryChangeFactory >> addInstanceVariable: variableName to: aClass [
	^ RBAddInstanceVariableChange add: variableName to: aClass
]

{ #category : #'refactory-changes-methods' }
RBRefactoryChangeFactory >> addMethodSource: sourceCode in: aClass [
	^ RBAddMethodChange compile: sourceCode in: aClass
]

{ #category : #'refactory-changes-methods' }
RBRefactoryChangeFactory >> addMethodSource: sourceCode in: aClass classified: aProtocol [
	^ RBAddMethodChange compile: sourceCode in: aClass classified: aProtocol
]

{ #category : #'refactory-changes-methods' }
RBRefactoryChangeFactory >> addMethodSource: sourceCode in: aClass classified: aProtocol for: aController [
	^ RBAddMethodChange
		compile: sourceCode
		in: aClass
		classified: aProtocol
		for: aController
]

{ #category : #'refactory-changes-methods' }
RBRefactoryChangeFactory >> addMethodSource: sourceCode in: aClass for: aController [
	^ RBAddMethodChange
			compile: sourceCode in: aClass for: aController
]

{ #category : #'refactory-changes-packages' }
RBRefactoryChangeFactory >> addPackageNamed: aString [
	^ RBAddPackageChange addPackageNamed: aString
]

{ #category : #'refactory-changes-variables' }
RBRefactoryChangeFactory >> addPoolVariable: variableName to: aClass [
	^ RBAddPoolVariableChange add: variableName to: aClass
]

{ #category : #'refactory-changes-classes' }
RBRefactoryChangeFactory >> addTraitDefinition: definition [
	^ RBAddTraitChange definition: definition.
]

{ #category : #'refactory-changes-classes' }
RBRefactoryChangeFactory >> comment: aComment in: aRBClass [
	^ RBCommentChange comment: aComment in: aRBClass
]

{ #category : #'refactory-changes-composites' }
RBRefactoryChangeFactory >> compositeRefactoryChange [
	^ RBCompositeRefactoryChange new
]

{ #category : #'refactory-changes-composites' }
RBRefactoryChangeFactory >> compositeRefactoryChangeNamed: name [
	^ RBCompositeRefactoryChange named:name
]

{ #category : #'refactory-changes-variables' }
RBRefactoryChangeFactory >> removeClassNamed: aClassName [
	^ RBRemoveClassChange removeClassName: aClassName
]

{ #category : #'refactory-changes-variables' }
RBRefactoryChangeFactory >> removeClassVariable: variableName from: aClass [
	^ RBRemoveClassVariableChange remove: variableName from: aClass
]

{ #category : #'refactory-changes-variables' }
RBRefactoryChangeFactory >> removeInstanceVariable: variableName from: aClass [
	^ RBRemoveInstanceVariableChange remove: variableName from: aClass
]

{ #category : #'refactory-changes-methods' }
RBRefactoryChangeFactory >> removeMethod: aSelector from: aClass [
	^ RBRemoveMethodChange remove: aSelector from: aClass
]

{ #category : #'refactory-changes-packages' }
RBRefactoryChangeFactory >> removePackageNamed: aString [
	^ RBRemovePackageChange removePackageNamed: aString
]

{ #category : #'refactory-changes-variables' }
RBRefactoryChangeFactory >> removePoolVariable: variableName from: aClass [
	^ RBRemovePoolVariableChange remove: variableName from: aClass
]

{ #category : #'refactory-changes-classes' }
RBRefactoryChangeFactory >> renameClass: aRBClass to: newName [
	^ RBRenameClassChange rename: aRBClass name to: newName
]

{ #category : #'refactory-changes-variables' }
RBRefactoryChangeFactory >> renameClassVariable: oldName to: newName in: aClass [
	^ RBRenameClassVariableChange rename: oldName to: newName in: aClass 
]

{ #category : #'refactory-changes-variables' }
RBRefactoryChangeFactory >> renameInstanceVariable: oldName to: newName in: aClass [
	^ RBRenameInstanceVariableChange rename: oldName to: newName in: aClass 
]

{ #category : #'refactory-changes-packages' }
RBRefactoryChangeFactory >> renamePackage: aRBPackage to: newName [
	^ RBRenamePackageChange rename: aRBPackage name to: newName
]

{ #category : #'refactory-changes-packages' }
RBRefactoryChangeFactory >> renamePackageNamed: aRBPackage to: newName [
	^ RBRenamePackageChange rename: aRBPackage to: newName
]
