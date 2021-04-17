"
I provide a specialized context description in the case where an exception was found on the stack of the context.

I reference that exception.
"
Class {
	#name : #StDebuggerErrorContextPredicate,
	#superclass : #StDebuggerContextPredicate,
	#instVars : [
		'exception'
	],
	#category : #'NewTools-Debugger-Model'
}

{ #category : #accessing }
StDebuggerErrorContextPredicate >> assertEqualsSelectors [
	self flag: 'Add the denies... use a pragma?'.
	^ #(#assert:equals: #assert:closeTo:precision: #assert:closeTo: #assert:identicalTo: #assertCollection:equals: #assertCollection:hasSameElements:)
	
"#( #assert:equals: #assert:closeTo:precision:
	     #assert:closeTo: #assert:identicalTo: #assertCollection:equals:
	     #assertCollection:hasSameElements: )"
]

{ #category : #testing }
StDebuggerErrorContextPredicate >> contextSignalsException [
	^true
]

{ #category : #accessing }
StDebuggerErrorContextPredicate >> exception: anObject [
	exception := anObject
]

{ #category : #accessing }
StDebuggerErrorContextPredicate >> exceptionWhiteList [

	^ { 
		  Warning.
		  OupsNullException.
		  Halt }
]

{ #category : #predicates }
StDebuggerErrorContextPredicate >> isContextDoesNotUnderstand [

	^ exception class = MessageNotUnderstood and: [ 
		  | message |
		  message := exception message.
		  
			  (exception receiver respondsTo: message selector) not and: [ 
				  exception signalerContext method methodClass == Object ] ]
]

{ #category : #predicates }
StDebuggerErrorContextPredicate >> isContextMissingClassException [

	^ exception class == VariableNotDeclared
]

{ #category : #predicates }
StDebuggerErrorContextPredicate >> isContextSubclassResponsibilityException [
	^ exception class == SubclassResponsibility
]

{ #category : #predicates }
StDebuggerErrorContextPredicate >> isSteppable [

	super isSteppable ifFalse: [ ^ false ].

	(exception isKindOf: MessageNotUnderstood) ifTrue: [ 
		^ self isContextDoesNotUnderstand not and: [ 
			  self isContextMissingClassException not ] ].

	^ exception isResumable
]

{ #category : #printing }
StDebuggerErrorContextPredicate >> printDescription [

	| str |
	str := WriteStream on: String new.
	self printDescriptionPrefixOn: str.
	str << ((exception isKindOf: OupsNullException)
		 ifTrue: [ context printString ]
		 ifFalse: [ exception description ]).
	^ str contents
]

{ #category : #updating }
StDebuggerErrorContextPredicate >> updateSessionForModel: aStDebuggerActionModel [

	aStDebuggerActionModel updateDebugSessionException: exception
]
