"
I am a base class for commands which perform operations with collection of classes
 
Internal Representation and Key Implementation Points.

    Instance Variables
	classes:		<Colletion of<Class>>
"
Class {
	#name : #SycClassCommand,
	#superclass : #CmdCommand,
	#instVars : [
		'classes'
	],
	#category : #'SystemCommands-ClassCommands'
}

{ #category : #testing }
SycClassCommand class >> canBeExecutedInContext: aToolContext [
	^aToolContext isClassSelected
]

{ #category : #'instance creation' }
SycClassCommand class >> for: classes [
	^self new 
		classes: classes
]

{ #category : #testing }
SycClassCommand class >> isAbstract [
	^self = SycClassCommand 
]

{ #category : #accessing }
SycClassCommand >> classes [
	^ classes
]

{ #category : #accessing }
SycClassCommand >> classes: anObject [
	classes := anObject
]

{ #category : #'activation-drag and drop' }
SycClassCommand >> prepareExecutionInDragContext: aToolContext [
	super prepareExecutionInDragContext: aToolContext.
	
	classes := aToolContext selectedClasses
]

{ #category : #execution }
SycClassCommand >> prepareFullExecutionInContext: aToolContext [
	super prepareFullExecutionInContext: aToolContext.
	
	classes := aToolContext selectedClasses
]
