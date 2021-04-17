"
I am a command to remove existing argument from the message.

Internal Representation and Key Implementation Points.

    Instance Variables
	argumentName:		<String>
"
Class {
	#name : #SycRemoveMessageArgumentCommand,
	#superclass : #SycChangeMessageSignatureCommand,
	#instVars : [
		'argumentName'
	],
	#category : #'SystemCommands-MessageCommands'
}

{ #category : #testing }
SycRemoveMessageArgumentCommand class >> canBeExecutedInContext: aToolContext [
	^(super canBeExecutedInContext: aToolContext)
		and: [ aToolContext lastSelectedMessage argumentNames notEmpty]
]

{ #category : #activation }
SycRemoveMessageArgumentCommand class >> methodContextMenuActivation [
	<classAnnotation>
	
	^ SycMethodMenuActivation byRootGroupItemOrder: 40 for: ClyMethod asCalypsoItemContext
]

{ #category : #accessing }
SycRemoveMessageArgumentCommand >> argumentName [
	^ argumentName
]

{ #category : #accessing }
SycRemoveMessageArgumentCommand >> argumentName: anObject [
	argumentName := anObject
]

{ #category : #execution }
SycRemoveMessageArgumentCommand >> createRefactoring [

	^RBRemoveParameterRefactoring
		model: model
		removeParameter: argumentName
		in: (SycMessageOriginHack of: originalMessage) "look at SycMessageOriginHack comment"
		selector: originalMessage selector
]

{ #category : #accessing }
SycRemoveMessageArgumentCommand >> defaultMenuIconName [ 
	^#remove

]

{ #category : #accessing }
SycRemoveMessageArgumentCommand >> defaultMenuItemName [
	^'Remove argument'
]

{ #category : #execution }
SycRemoveMessageArgumentCommand >> prepareFullExecutionInContext: aToolContext [
	super prepareFullExecutionInContext: aToolContext.
	
	argumentName := originalMessage argumentNames size = 1 
		ifTrue: [ originalMessage argumentNames first]
		ifFalse: [ UIManager default
						chooseFrom: originalMessage argumentNames 
						values: originalMessage argumentNames 
						message: 'Choose an argument to remove:'].
					
	(originalMessage argumentNames includes: argumentName) 
		ifFalse: [ CmdCommandAborted signal ].
]

{ #category : #execution }
SycRemoveMessageArgumentCommand >> resultMessageSelector [
	| argIndex keywords |
	argIndex := originalMessage argumentNames indexOf: argumentName.
	keywords := originalMessage selector keywords asOrderedCollection.
	keywords size = 1
		ifTrue: [ ^ (keywords first copyWithout: $:) asSymbol ].
	keywords removeAt: argIndex.
	^(keywords joinUsing: '') asSymbol
]
