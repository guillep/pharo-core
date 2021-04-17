"
I represent message description which includes selector and argument names.

In addition I keep reference to so named contextUser. It is an object which uses given message, which was used to retrieve message instance.
The #contextUser is either a method or RBMessageNode.

To create my instance use following expressions: 

	SycMessageDescription ofMethod: Magnitude >> #between:and:.
	SycMessageDescription ofMessageNode: (SycRenameMessageCommand >> #createRefactoring) ast sendNodes first.

I implement suitable method for commands to request new signature: 

	aMessage requestNewSignature

It returnes new message instance.

Also I provide a method to compute argument permutations comparing to another message: 

	aMessage1 computeArgumentPermutationsFor: aMessage2
	
It is required for rename method refactoring.
 
Internal Representation and Key Implementation Points.

    Instance Variables
	argumentNames:		<Array of<String>>
	contextUser:		<Object>
	selector:		<Symbol>
"
Class {
	#name : #SycMessageDescription,
	#superclass : #Object,
	#instVars : [
		'selector',
		'argumentNames',
		'contextUser'
	],
	#category : #'SystemCommands-MessageCommands'
}

{ #category : #'instance creation' }
SycMessageDescription class >> fromContextOf: messageUserObject [
	^self new 
		contextUser: messageUserObject
]

{ #category : #'instance creation' }
SycMessageDescription class >> ofMessageNode: astMessageNode [
	^(self fromContextOf: astMessageNode) 
		selector: astMessageNode selector;
		argumentNames: (astMessageNode arguments collect: [:each | each formattedCode])
]

{ #category : #'instance creation' }
SycMessageDescription class >> ofMethod: aMethod [
	^(self fromContextOf: aMethod)
		selector: aMethod selector;
		argumentNames: aMethod argumentNames
]

{ #category : #accessing }
SycMessageDescription >> argumentNames [
	^ argumentNames
]

{ #category : #accessing }
SycMessageDescription >> argumentNames: anObject [
	argumentNames := anObject
]

{ #category : #operations }
SycMessageDescription >> computeArgumentPermutationsFor: modifiedMessageDescription [
	^modifiedMessageDescription argumentNames 
		collect: [ :each | argumentNames indexOf: each ]
]

{ #category : #accessing }
SycMessageDescription >> contextUser [
	^ contextUser
]

{ #category : #accessing }
SycMessageDescription >> contextUser: anObject [
	contextUser := anObject
]

{ #category : #testing }
SycMessageDescription >> describesSelector: someSelector withArguments: someArgumentNames [ 
	^selector = someSelector & (argumentNames = someArgumentNames) 
]

{ #category : #accessing }
SycMessageDescription >> methodClass [

	^ contextUser methodClass
]

{ #category : #operations }
SycMessageDescription >> requestNewSignature [
	| methodName dialog |
	methodName := RBMethodName selector: selector arguments: argumentNames copy.
	dialog := SycMethodNameEditorPresenter openOn: methodName.
	dialog cancelled ifTrue: [  CmdCommandAborted signal ].
	
	selector = methodName selector & (argumentNames = methodName arguments)
		ifTrue: [ CmdCommandAborted signal].
	
	^(SycMessageDescription fromContextOf: contextUser)
		selector: methodName selector;
		argumentNames: methodName arguments
]

{ #category : #accessing }
SycMessageDescription >> selector [
	^ selector
]

{ #category : #accessing }
SycMessageDescription >> selector: anObject [
	selector := anObject
]
