"
I return all methods which have installed breakpoints or send the halt message (and friends like haltIf:)
"
Class {
	#name : #ClyActiveBreakpointsQuery,
	#superclass : #ClyMethodQuery,
	#instVars : [
		'excludesHaltsForTesting'
	],
	#category : #'Calypso-SystemPlugins-Reflectivity-Queries-Breakpoints'
}

{ #category : #'instance creation' }
ClyActiveBreakpointsQuery class >> newIncludingHaltsForTesting [
	| cab |
	cab := self new.
	cab excludesHaltsForTesting: false.
	^ cab.
]

{ #category : #comparing }
ClyActiveBreakpointsQuery >> = anObject [
	"Answer whether the receiver and anObject represent the same object."
	
	self == anObject ifTrue: [ ^ true ].
	super = anObject ifFalse: [ ^ false ].
	^excludesHaltsForTesting = anObject excludesHaltsForTesting.
]

{ #category : #printing }
ClyActiveBreakpointsQuery >> description [
	^'Active Breakpoints'
]

{ #category : #accessing }
ClyActiveBreakpointsQuery >> excludesHaltsForTesting [
	^ excludesHaltsForTesting
]

{ #category : #accessing }
ClyActiveBreakpointsQuery >> excludesHaltsForTesting: anObject [
	excludesHaltsForTesting := anObject
]

{ #category : #comparing }
ClyActiveBreakpointsQuery >> hash [
	"Answer an integer value that is related to the identity of the receiver."

	^ super hash bitXor: excludesHaltsForTesting hash
]

{ #category : #initialization }
ClyActiveBreakpointsQuery >> initialize [
	super initialize.
	excludesHaltsForTesting := true.
]

{ #category : #testing }
ClyActiveBreakpointsQuery >> selectsMethod: aMethod [
	"If the method does not contain halts or breakpoints, we do not show it"
	(aMethod hasBreakpoint or: [ aMethod containsHalt ]) ifFalse: [ ^false ].
	"If the method contains halts or breakpoints and we are not exclude halts for testing, we show it"
	(self excludesHaltsForTesting) ifFalse: [ ^true. ].
	"If we are excluding methods with halts for testing, we show the method if it has not been marked as containing halts for tests or those that implement halts (e.g. Object>>#halt)"
	^ ((aMethod hasPragmaNamed: #haltOrBreakpointForTesting) 
		or: [(aMethod hasPragmaNamed: #debuggerCompleteToSender)]) not.
]
