"
I am a command to replace senders of message selector.
"
Class {
	#name : #SycReplaceMessageCommand,
	#superclass : #SycChangeMessageSignatureCommand,
	#instVars : [
		'newSelector'
	],
	#category : #'SystemCommands-MessageCommands'
}

{ #category : #activation }
SycReplaceMessageCommand class >> methodContextMenuActivation [
	<classAnnotation>
	
	^ SycMethodMenuActivation byRootGroupItemOrder: 1100 for: ClyMethod asCalypsoItemContext
]

{ #category : #execution }
SycReplaceMessageCommand >> createRefactoring [
	self flag: 'TODO'."Improve preview to add args when change the sender with empty args"
	^ (RBReplaceMethodRefactoring
		model: model
		replaceMethod: originalMessage selector 
		in: originalMessage contextUser origin
		to: newSelector selector
		permutation: newSelector permutation
		inAllClasses: self replaceInAllClasses)
		initializers: newSelector newArgs values
]

{ #category : #accessing }
SycReplaceMessageCommand >> defaultMenuIconName [
	^#edit
]

{ #category : #accessing }
SycReplaceMessageCommand >> defaultMenuItemName [
	^ 'Replace senders'
]

{ #category : #testing }
SycReplaceMessageCommand >> isComplexRefactoring [
	^true
]

{ #category : #execution }
SycReplaceMessageCommand >> prepareFullExecutionInContext: aToolContext [
	
	| methodName dialog |
	super prepareFullExecutionInContext: aToolContext.
	
	methodName := RBMethodName selector: originalMessage selector arguments: originalMessage argumentNames copy.
	dialog := SycMethodNameEditorPresenter openOn: methodName.
	dialog cancelled ifTrue: [  CmdCommandAborted signal ].
	
	originalMessage selector = methodName selector ifTrue: [ CmdCommandAborted signal].
	newSelector := methodName.
]

{ #category : #execution }
SycReplaceMessageCommand >> replaceInAllClasses [
	^ self confirm: 'Do you want replace senders of method in the whole classes?'
]
