"
I'm a refactoring to rename a package.

My preconditions verify that the new name is different from the current package name and is a valid name.

I change all the references of the classes that are defined within the package, and if there is a manifest, it is updated with the new name of the package. 

Example
---------
```
(RBRenamePackageRefactoring 
				rename: (self getPackageNamed: #'Refactoring-Tests-Core')
				to: #'Refactoring-Tests-Core1') execute.
```
"
Class {
	#name : #RBRenamePackageRefactoring,
	#superclass : #RBPackageRefactoring,
	#instVars : [
		'package'
	],
	#category : #'Refactoring-Core-Refactorings'
}

{ #category : #'instance creation' }
RBRenamePackageRefactoring class >> model: aRBSmalltalk rename: aSymbol to: aNewName [ 
	^ self new
		model: aRBSmalltalk;
		packageName: aSymbol newName: aNewName;
		yourself
]

{ #category : #'instance creation' }
RBRenamePackageRefactoring class >> rename: aString to: aNewName [
	^self new packageName: aString newName: aNewName
]

{ #category : #transforming }
RBRenamePackageRefactoring >> manifestClassNameFor: aPackageName [
	"Returns a symbol representing a suitable name for a Manifest class for the given package"
	
	^('Manifest', (aPackageName select: [:each | each isAlphaNumeric ])) asSymbol
]

{ #category : #initialization }
RBRenamePackageRefactoring >> packageName: aName newName: aNewName [ 
	packageName := aName asSymbol.
	package := self model packageNamed: packageName.
	newName := aNewName asSymbol
]

{ #category : #preconditions }
RBRenamePackageRefactoring >> preconditions [ 
	^ super preconditions & (RBCondition withBlock: [ newName = package name ifTrue: 
		[ self refactoringError: 'Use a different name' ].
		true ]) &
	(RBCondition withBlock: [ [RPackage organizer validatePackageDoesNotExist: newName. true]
			on: Error 
			do: [ :e | self refactoringError: e messageText ]
		])
	
]

{ #category : #transforming }
RBRenamePackageRefactoring >> renameManifestClass [ 
	|refactoring manifest|
	manifest := package realPackage packageManifestOrNil.
	manifest ifNotNil: [
	refactoring := RBRenameClassRefactoring 
		model: self model
		rename: manifest
		to: (self manifestClassNameFor: newName).
	self performCompositeRefactoring: refactoring]
]

{ #category : #transforming }
RBRenamePackageRefactoring >> renamePackage [
	self model renamePackage: package to: newName
]

{ #category : #printing }
RBRenamePackageRefactoring >> storeOn: aStream [ 
	aStream nextPut: $(.
	self class storeOn: aStream.
	aStream nextPutAll: ' rename: '.
	aStream nextPutAll: package name.
	aStream
		nextPutAll: ' to: #';
		nextPutAll: newName;
		nextPut: $)
]

{ #category : #transforming }
RBRenamePackageRefactoring >> transform [

	self renamePackage.
	self renameManifestClass.
]
