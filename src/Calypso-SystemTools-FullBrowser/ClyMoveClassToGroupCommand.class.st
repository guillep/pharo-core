"
I am a command to move classes into given class group.

By default I only available by dragging classes into the target class group.

Internal Representation and Key Implementation Points.

    Instance Variables
	classGroup:		<ClyClassGroup>
"
Class {
	#name : #ClyMoveClassToGroupCommand,
	#superclass : #SycClassCommand,
	#instVars : [
		'classGroup'
	],
	#category : #'Calypso-SystemTools-FullBrowser-Commands-Classes'
}

{ #category : #activation }
ClyMoveClassToGroupCommand class >> browserContextMenuActivation [
	<classAnnotation>
	
	^ SycClassMenuActivation byRootGroupItemOrder: 1000 for: ClyClass asCalypsoItemContext
]

{ #category : #activation }
ClyMoveClassToGroupCommand class >> fullBrowserDragAndDropActivation [
	<classAnnotation>
	
	^CmdDragAndDropActivation 
		for: ClyClass asCalypsoItemContext 
		toDropIn: RPackage asCalypsoItemContext
]

{ #category : #activation }
ClyMoveClassToGroupCommand class >> fullBrowserDragAndDropActivation2 [
	<classAnnotation>
	
	^CmdDragAndDropActivation 
		for: ClyClass asCalypsoItemContext 
		toDropIn: ClyTaggedClassGroup asCalypsoItemContext
]

{ #category : #activation }
ClyMoveClassToGroupCommand class >> fullBrowserDragAndDropActivation3 [
	<classAnnotation>
	
	^CmdDragAndDropActivation 
		for: ClyClass asCalypsoItemContext 
		toDropIn: ClyNoTagClassGroup asCalypsoItemContext
]

{ #category : #activation }
ClyMoveClassToGroupCommand class >> fullBrowserShortcutActivation [
	<classAnnotation>
	
	^CmdShortcutActivation by: $m meta, $c meta for: ClyFullBrowserClassContext 
]

{ #category : #accessing }
ClyMoveClassToGroupCommand >> classGroup [
	^ classGroup
]

{ #category : #accessing }
ClyMoveClassToGroupCommand >> classGroup: anObject [
	classGroup := anObject
]

{ #category : #accessing }
ClyMoveClassToGroupCommand >> defaultMenuIconName [ 
	^ #smallRedo
]

{ #category : #accessing }
ClyMoveClassToGroupCommand >> defaultMenuItemName [ 
	^'Move to package'
]

{ #category : #execution }
ClyMoveClassToGroupCommand >> execute [

	classGroup importClasses: classes
]

{ #category : #execution }
ClyMoveClassToGroupCommand >> prepareExecutionInDropContext: aToolContext [
	super prepareExecutionInDropContext: aToolContext.
	classGroup := aToolContext lastSelectedClassGroup
	"this command can be also activated on package which is polimorphic to class group.
	If given context is package context then it will return package as class group"
]

{ #category : #execution }
ClyMoveClassToGroupCommand >> prepareFullExecutionInContext: aToolContext [
	super prepareFullExecutionInContext: aToolContext.
	"class group could be package. In this activation it is only make sense to request user for package"
	
	classGroup := aToolContext requestSinglePackage: 'Choose package'
]
