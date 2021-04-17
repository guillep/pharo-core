"
I describe the status of a context:
- I can print a meaningful description of the context
- I can tell if the current context is steppable (predicates)

I reference the context I describe.
I become obsolete as soon as an action is performed on the context.
"
Class {
	#name : #StDebuggerContextPredicate,
	#superclass : #Object,
	#instVars : [
		'context',
		'postMortem'
	],
	#category : #'NewTools-Debugger-Model'
}

{ #category : #'instance creation' }
StDebuggerContextPredicate class >> context: anObject [

	^ self new context: anObject
]

{ #category : #accessing }
StDebuggerContextPredicate >> context [
	^ context
]

{ #category : #accessing }
StDebuggerContextPredicate >> context: aContext [
	context := aContext
]

{ #category : #testing }
StDebuggerContextPredicate >> contextSignalsException [
	^false
]

{ #category : #initialization }
StDebuggerContextPredicate >> initialize [ 
	super initialize.
	postMortem := false
]

{ #category : #predicates }
StDebuggerContextPredicate >> isContextAnAssertionFailure [
	^false
]

{ #category : #predicates }
StDebuggerContextPredicate >> isContextDead [
	^context isDead
]

{ #category : #predicates }
StDebuggerContextPredicate >> isContextDoesNotUnderstand [
	^false
]

{ #category : #predicates }
StDebuggerContextPredicate >> isContextMissingClassException [
	^false
]

{ #category : #predicates }
StDebuggerContextPredicate >> isContextPostMortem [
	^postMortem
]

{ #category : #predicates }
StDebuggerContextPredicate >> isContextSubclassResponsibilityException [
	^false
]

{ #category : #predicates }
StDebuggerContextPredicate >> isSteppable [

	^ self isContextPostMortem not and: [ self isContextDead not ]
]

{ #category : #accessing }
StDebuggerContextPredicate >> postMortem: aBoolean [
	postMortem := aBoolean
]

{ #category : #printing }
StDebuggerContextPredicate >> printDescription [
	|str|
	str := WriteStream on: String new.
	self printDescriptionPrefixOn: str.
	str << context printString.
	^str contents
]

{ #category : #printing }
StDebuggerContextPredicate >> printDescriptionPrefixOn: str [

	self printPostMortemDescriptionOn: str.
	self printHaltDescriptionOn: str
]

{ #category : #printing }
StDebuggerContextPredicate >> printHaltDescriptionOn: str [

	context sourceNodeExecuted isHaltNode ifFalse: [ ^ self ].
	str << 'Halt in'.
	str space
]

{ #category : #printing }
StDebuggerContextPredicate >> printPostMortemDescriptionOn: str [

	postMortem ifFalse: [ ^ self ].
	str << '[Post-mortem]'.
	str space
]

{ #category : #updating }
StDebuggerContextPredicate >> updateSessionForModel: aStDebuggerActionModel [
	aStDebuggerActionModel updateDebugSessionException: OupsNullException new
	
]
