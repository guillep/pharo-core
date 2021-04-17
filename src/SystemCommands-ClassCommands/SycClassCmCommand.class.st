"
This class is an extension so we can mix command of Commander2 with Commander.
"
Class {
	#name : #SycClassCmCommand,
	#superclass : #SycCmCommand,
	#instVars : [
		'targetClass'
	],
	#category : #'SystemCommands-ClassCommands'
}

{ #category : #adding }
SycClassCmCommand class >> activationStrategy [ 
	^ SycClassMenuActivation
]

{ #category : #preparation }
SycClassCmCommand >> prepareFullExecution [
	super prepareFullExecution.
	targetClass := context lastSelectedClass.
]
