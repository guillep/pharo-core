"
I am a command to copy given package.
 
Internal Representation and Key Implementation Points.

    Instance Variables
	newName:		<String>
	package:		<RPackage>
"
Class {
	#name : #SycCopyPackageCommand,
	#superclass : #CmdCommand,
	#instVars : [
		'package',
		'newName'
	],
	#category : #'SystemCommands-PackageCommands'
}

{ #category : #testing }
SycCopyPackageCommand class >> canBeExecutedInContext: aToolContext [
	^aToolContext isPackageSelected
]

{ #category : #accessing }
SycCopyPackageCommand >> defaultMenuIconName [
	^#smallCopy
]

{ #category : #accessing }
SycCopyPackageCommand >> defaultMenuItemName [
	^'Copy all package'
]

{ #category : #execution }
SycCopyPackageCommand >> execute [

	(RBCopyPackageRefactoring copyPackage: package name in: newName) execute
]

{ #category : #execution }
SycCopyPackageCommand >> prepareFullExecutionInContext: aToolContext [
	super prepareFullExecutionInContext: aToolContext.
	
	package := aToolContext lastSelectedPackage.	
	newName := UIManager default 
		request: 'New name of copied package' 
		initialAnswer: package name 
		title: 'Copy package'.
	newName isEmptyOrNil | (newName = package name) ifTrue: [ ^ CmdCommandAborted signal ]
]
