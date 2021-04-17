Class {
	#name : #StDebuggerToolCommandTreeBuilderTest,
	#superclass : #TestCase,
	#instVars : [
		'session',
		'debugger',
		'rootGroup',
		'builder'
	],
	#category : #'NewTools-Debugger-Tests-Model'
}

{ #category : #testing }
StDebuggerToolCommandTreeBuilderTest class >> isAbstract [ 
	^self class = StDebuggerToolCommandTreeBuilderTest 
]

{ #category : #assertions }
StDebuggerToolCommandTreeBuilderTest >> assertCommandGroup: cmdGroup hasDisplayStrategy: displayStrategy [
	self
		assert: cmdGroup displayStrategy class
		identicalTo: displayStrategy
]

{ #category : #assertions }
StDebuggerToolCommandTreeBuilderTest >> assertCommandGroup: cmdGroup hasSameCommands: expectedCommands withContext: expectedContext displayStrategy: displayStrategy [
	| commands |
	self deny: cmdGroup isRoot.
	self assertCommandGroup: cmdGroup hasDisplayStrategy: displayStrategy.
	commands := cmdGroup allCommands
		collect: [ :spCommand | spCommand innerCommand ].
	self
		assertCommandGroupEntries: commands
		hasCommands: expectedCommands.
	self assertCommands: commands haveContext: expectedContext
]

{ #category : #assertions }
StDebuggerToolCommandTreeBuilderTest >> assertCommandGroupEntries: commands hasCommands: expectedCommands [
	self
		assertCollection: (commands collect: [ :cmd | cmd class ])
		hasSameElements: expectedCommands
]

{ #category : #assertions }
StDebuggerToolCommandTreeBuilderTest >> assertCommands: commands equals: expectedCommands [
	self assert: commands size equals: expectedCommands size.
	commands
		with: expectedCommands
		do: [ :actual :expected | 
			self assert: actual name equals: expected name.
			self assert: actual context identicalTo: expected context.
			self assert: actual class identicalTo: expected class ]
]

{ #category : #assertions }
StDebuggerToolCommandTreeBuilderTest >> assertCommands: commands haveContext: expectedContext [
	commands
		do: [ :cmd | self assert: cmd context identicalTo: expectedContext ]
]

{ #category : #helper }
StDebuggerToolCommandTreeBuilderTest >> commandsFromSpecGroup: group [

	^ group decoratedGroup entries collect: [ :cmd | cmd innerCommand ]
]

{ #category : #'instance creation' }
StDebuggerToolCommandTreeBuilderTest >> newBuilder [
	^self subclassResponsibility 
]

{ #category : #running }
StDebuggerToolCommandTreeBuilderTest >> setUp [
	| context process |
	super setUp.
	context := [ ^ 1 + 1 ] asContext.
	process := Process
		forContext: context
		priority: Processor userInterruptPriority.
	session := DebugSession
		named: 'test session'
		on: process
		startedAt: context.
	session exception: OupsNullException new.
	debugger := StDebugger basicNew
		application: StDebugger currentApplication;
		session: session;
		initialize.
	debugger stackTable selectItem: debugger stackTable items first.
	rootGroup := (CmCommandGroup named: 'root') asSpecGroup.
	builder := self newBuilder
]

{ #category : #running }
StDebuggerToolCommandTreeBuilderTest >> tearDown [
	debugger ifNotNil:[debugger clear].
	super tearDown.

]
