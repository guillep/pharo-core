"
I am the abstract super class of **Oups**' debugger selection strategies. My subclasses are responsible for selecting a debugger from a given list of debuggers, and for opening a given error with it.

**Oups** has a setting to define which strategy it should use to find a debugger for the error whose debugging was requested.
The debugger infrastructure implements a default strategy `OupsDebuggerSelector` which is interchangeable with user-defined strategies.
"
Class {
	#name : #OupsDebuggerSelectionStrategy,
	#superclass : #Object,
	#instVars : [
		'debuggers',
		'handled',
		'error'
	],
	#classInstVars : [
		'debuggerSelectionStrategy'
	],
	#category : #'Debugger-Oups-Strategies'
}

{ #category : #settings }
OupsDebuggerSelectionStrategy class >> debuggerSelectionStrategy [

	^ debuggerSelectionStrategy ifNil: [ 
		  debuggerSelectionStrategy := self defaultDebuggerSelectionStrategy ]
]

{ #category : #settings }
OupsDebuggerSelectionStrategy class >> debuggerSelectionStrategy: aClass [
	debuggerSelectionStrategy := aClass
]

{ #category : #settings }
OupsDebuggerSelectionStrategy class >> debuggerSelectionStrategySettingsOn: aBuilder [
	<systemsettings>
	(aBuilder pickOne: #debuggerSelectionStrategy)
		label: 'Debugger selection strategy';
		target: self;
		default: self defaultDebuggerSelectionStrategy;
		parent: #debugging;
		domainValues: (self allSubclasses);
		description: 'Sets the strategy to open a debugger.'
]

{ #category : #settings }
OupsDebuggerSelectionStrategy class >> defaultDebuggerSelectionStrategy [
	^OupsSingleDebuggerSelector
]

{ #category : #instance }
OupsDebuggerSelectionStrategy class >> with: aCollection [
	^ self new
		debuggers: aCollection;
		yourself
]

{ #category : #accessing }
OupsDebuggerSelectionStrategy >> debuggers [
	^ debuggers
]

{ #category : #accessing }
OupsDebuggerSelectionStrategy >> debuggers: aCollection [ 
	debuggers := aCollection
]

{ #category : #'error handling' }
OupsDebuggerSelectionStrategy >> error [
	^error
]

{ #category : #accessing }
OupsDebuggerSelectionStrategy >> handled [
	^handled ifNil:[handled := false]
]

{ #category : #accessing }
OupsDebuggerSelectionStrategy >> hasErrors [ 
	^error notNil
]

{ #category : #iterating }
OupsDebuggerSelectionStrategy >> nextDebugger [
	^ self subclassResponsibility
]

{ #category : #debuggers }
OupsDebuggerSelectionStrategy >> openDebuggerForSession: aDebugSession [
	self subclassResponsibility 
]

{ #category : #'error handling' }
OupsDebuggerSelectionStrategy >> signalErrorHandlingErrorForSession: aDebugSession [

	DebuggerEmmergencyLogger new
		logError: error
		forSession: aDebugSession crTrace
]
