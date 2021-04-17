"
I am a command to move method to another package.

I am used to convert method to extension.
 
Internal Representation and Key Implementation Points.

    Instance Variables
	package:		<RPackage>
"
Class {
	#name : #SycMoveMethodsToPackageCommand,
	#superclass : #SycMethodRepackagingCommand,
	#instVars : [
		'package'
	],
	#category : #'SystemCommands-MethodCommands'
}

{ #category : #'instance creation' }
SycMoveMethodsToPackageCommand class >> for: methods to: aPackage [
	^(self for: methods) 
		package: aPackage
]

{ #category : #activation }
SycMoveMethodsToPackageCommand class >> methodContextMenuActivation [
	<classAnnotation>
	
	^ SycMethodMenuActivation byRootGroupItemOrder: 70 for: ClyMethod asCalypsoItemContext
]

{ #category : #accessing }
SycMoveMethodsToPackageCommand >> defaultMenuIconName [ 
	^ #smallRedo
]

{ #category : #accessing }
SycMoveMethodsToPackageCommand >> defaultMenuItemName [
	^'Move to package'
]

{ #category : #execution }
SycMoveMethodsToPackageCommand >> execute [
	
	methods do: [ :each | 
		self moveMethod: each toPackage: package]

]

{ #category : #accessing }
SycMoveMethodsToPackageCommand >> package [
	^ package
]

{ #category : #accessing }
SycMoveMethodsToPackageCommand >> package: anObject [
	package := anObject
]

{ #category : #execution }
SycMoveMethodsToPackageCommand >> prepareExecutionInDropContext: aToolContext [
	super prepareExecutionInDropContext: aToolContext.
	package := aToolContext lastSelectedPackage
]

{ #category : #execution }
SycMoveMethodsToPackageCommand >> prepareFullExecutionInContext: aToolContext [
	super prepareFullExecutionInContext: aToolContext.
	
	package := aToolContext requestSinglePackage: 'Choose package'
]
