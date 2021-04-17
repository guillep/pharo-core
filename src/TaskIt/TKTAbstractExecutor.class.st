"
I am an abstract class defining the basic behaviour and state to execute a task:
  - the basic executeTask: method
  - an exception handler meant to manage unhandled exception
"
Class {
	#name : #TKTAbstractExecutor,
	#superclass : #Object,
	#traits : 'TTaskExecutor',
	#classTraits : 'TTaskExecutor classTrait',
	#instVars : [
		'exceptionHandler',
		'busy'
	],
	#category : #'TaskIt-Kernel'
}

{ #category : #testing }
TKTAbstractExecutor class >> isAbstract [

	^self == TKTAbstractExecutor 
]

{ #category : #accessing }
TKTAbstractExecutor >> exceptionHandler [
	^ exceptionHandler
]

{ #category : #accessing }
TKTAbstractExecutor >> exceptionHandler: aHandler [
	
	exceptionHandler := aHandler
]

{ #category : #initialization }
TKTAbstractExecutor >> initialize [
	super initialize.
	busy := false.
	exceptionHandler := TKTConfiguration errorHandler
]

{ #category : #testing }
TKTAbstractExecutor >> isBusy [

	^ busy
]

{ #category : #testing }
TKTAbstractExecutor >> isFree [

	^ busy not
]

{ #category : #'as yet unclassified' }
TKTAbstractExecutor >> noteBusy [

	busy := true
]

{ #category : #'as yet unclassified' }
TKTAbstractExecutor >> noteFree [

	busy := false
]

{ #category : #polymorphism }
TKTAbstractExecutor >> start [
 " nothing to do "
]

{ #category : #polymorphism }
TKTAbstractExecutor >> stop [

]
