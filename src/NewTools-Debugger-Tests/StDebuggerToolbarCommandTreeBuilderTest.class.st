Class {
	#name : #StDebuggerToolbarCommandTreeBuilderTest,
	#superclass : #StDebuggerToolCommandTreeBuilderTest,
	#category : #'NewTools-Debugger-Tests-Model'
}

{ #category : #'instance creation' }
StDebuggerToolbarCommandTreeBuilderTest >> newBuilder [
	^ StDebuggerToolbarCommandTreeBuilder
		buildCommandsGroupWith: debugger
		forRoot: rootGroup
]

{ #category : #tests }
StDebuggerToolbarCommandTreeBuilderTest >> testBuildCommandGroupFromNamedDescription [
	| group spCommands |
	group := builder
		buildCommandGroupFrom:
			{StMockDebugCommand.
			StMockDebugCommand}
		named: #testName
		description: #testDescription.
	self assert: group name equals: #testName.	
	self assert: group description equals: #testDescription.
	spCommands := group allCommands.
	self assert: spCommands size equals: 2.
	self assert: spCommands first innerCommand class equals: StMockDebugCommand.
	self assert: spCommands second innerCommand class equals: StMockDebugCommand.
	self assert: spCommands first context identicalTo: debugger.
	self assert: spCommands second context identicalTo: debugger
]

{ #category : #tests }
StDebuggerToolbarCommandTreeBuilderTest >> testCommandGroupStructure [
	|stackGroup|
	stackGroup := rootGroup groups first.	
	self assert: stackGroup entries size equals: 3.
	self assert: stackGroup groups first name equals: builder executionControlGroupName.
	self assert: stackGroup groups first description equals: builder executionControlGroupDescription.
	self assert: stackGroup groups second name equals: builder contextRequestGroupName.
	self assert: stackGroup groups second description equals: builder contextRequestGroupDescription.
	self assert: stackGroup groups third name equals: builder contextControlGroupName.
	self assert: stackGroup groups third description equals: builder contextControlGroupDescription.

]

{ #category : #tests }
StDebuggerToolbarCommandTreeBuilderTest >> testContextControlCommandClasses [
	self
		assertCollection: builder contextControlCommandClasses
		equals: {StDefineMissingEntityCommand}
]

{ #category : #tests }
StDebuggerToolbarCommandTreeBuilderTest >> testContextControlDebuggingCommands [
	self
		assertCommandGroup: builder contextControlDebuggingCommands
		hasSameCommands: builder contextControlCommandClasses
		withContext: debugger
		displayStrategy: CmUIDisplayAsGroup
]

{ #category : #tests }
StDebuggerToolbarCommandTreeBuilderTest >> testContextControlGroupDescription [
	self
		assert: builder contextControlGroupDescription
		equals: 'Actions performed on the interrupted context'
]

{ #category : #tests }
StDebuggerToolbarCommandTreeBuilderTest >> testContextControlGroupName [
	self
		assert: builder contextControlGroupName
		equals: 'Context control'
]

{ #category : #tests }
StDebuggerToolbarCommandTreeBuilderTest >> testContextRequestCommandClasses [
	self
		assertCollection: builder contextRequestCommandClasses
		equals: {StWhereIsCommand}
]

{ #category : #tests }
StDebuggerToolbarCommandTreeBuilderTest >> testContextRequestDebuggingCommands [
	self
		assertCommandGroup: builder contextRequestDebuggingCommands
		hasSameCommands: builder contextRequestCommandClasses
		withContext: debugger
		displayStrategy: CmUIDisplayAsGroup
]

{ #category : #tests }
StDebuggerToolbarCommandTreeBuilderTest >> testContextRequestGroupDescription [
	self
		assert: builder contextRequestGroupDescription
		equals: 'Requests on the interrupted context'
]

{ #category : #tests }
StDebuggerToolbarCommandTreeBuilderTest >> testContextRequestGroupName [
	self
		assert: builder contextRequestGroupName
		equals: 'Context requests'
]

{ #category : #tests }
StDebuggerToolbarCommandTreeBuilderTest >> testDefaultDebugActionsDescription [
	self
		assert: builder defaultDebugActionsDescription
		equals: 'Defaults debugging actions'
]

{ #category : #tests }
StDebuggerToolbarCommandTreeBuilderTest >> testDefaultDebugActionsGroupName [
	self
		assert: builder defaultDebugActionsGroupName
		equals: 'Debugging actions'
]

{ #category : #tests }
StDebuggerToolbarCommandTreeBuilderTest >> testDisplayStrategy [
	self assert: builder class displayStrategy equals: CmUIDisplayAsGroup
]

{ #category : #tests }
StDebuggerToolbarCommandTreeBuilderTest >> testExecutionControlCommandClasses [
	self
		assertCollection: builder executionControlCommandClasses
		equals:
			{StProceedCommand.
			StStepIntoCommand.
			StStepOverCommand.
			StStepThroughCommand.
			StRunToSelectionCommand.
			StRestartCommand.
			StReturnValueCommand}
]

{ #category : #tests }
StDebuggerToolbarCommandTreeBuilderTest >> testExecutionControlDebuggingCommands [
	self
		assertCommandGroup: builder executionControlDebuggingCommands
		hasSameCommands: builder executionControlCommandClasses
		withContext: debugger
		displayStrategy: CmUIDisplayAsGroup
]

{ #category : #tests }
StDebuggerToolbarCommandTreeBuilderTest >> testExecutionControlGroupDescription [
	self
		assert: builder executionControlGroupDescription
		equals: 'Debug actions applied to the executed context'
]

{ #category : #tests }
StDebuggerToolbarCommandTreeBuilderTest >> testExecutionControlGroupName [
	self
		assert: builder executionControlGroupName
		equals: 'Execution control'
]

{ #category : #tests }
StDebuggerToolbarCommandTreeBuilderTest >> testExecutionControlShortcuts [

	| commandsWithShortcuts |
	commandsWithShortcuts := builder executionControlCommandClasses 
		                         select: [ :class | 
		                         class defaultShortcut notNil ].
	self assert: commandsWithShortcuts notEmpty.
	commandsWithShortcuts do: [ :class | 
		| command |
		command := builder buildSpecCommand: class forContext: self.
		self assert: command shortcutKey equals: class defaultShortcut ]
]

{ #category : #tests }
StDebuggerToolbarCommandTreeBuilderTest >> testGroupDescription [
	self assert: builder class groupDescription equals: 'Debug actions'
]

{ #category : #tests }
StDebuggerToolbarCommandTreeBuilderTest >> testGroupName [
	self assert: builder class groupName equals: 'Toolbar'
]
