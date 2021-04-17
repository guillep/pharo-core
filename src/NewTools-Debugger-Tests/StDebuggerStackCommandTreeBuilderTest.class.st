Class {
	#name : #StDebuggerStackCommandTreeBuilderTest,
	#superclass : #StDebuggerToolCommandTreeBuilderTest,
	#category : #'NewTools-Debugger-Tests-Model'
}

{ #category : #helper }
StDebuggerStackCommandTreeBuilderTest >> newBuilder [
	^ StDebuggerStackCommandTreeBuilder
		buildCommandsGroupWith: debugger
		forRoot: rootGroup
]

{ #category : #tests }
StDebuggerStackCommandTreeBuilderTest >> testBrowseGroupDescription [
	self
		assert: builder browseGroupDescription
		equals: 'Navigate the system from the stack'
]

{ #category : #tests }
StDebuggerStackCommandTreeBuilderTest >> testBrowseGroupName [
	self assert: builder browseGroupName equals: 'Browse'
]

{ #category : #tests }
StDebuggerStackCommandTreeBuilderTest >> testCommandGroupStructure [
	|stackGroup|
	stackGroup := rootGroup groups first.	
	self assert: stackGroup entries size equals: 4.
	self assert: stackGroup groups first name equals: builder browseGroupName.
	self assert: stackGroup groups first description equals: builder browseGroupDescription.
	self assert: stackGroup groups second name equals: builder stackContextMenuExplorationGroupName.
	self assert: stackGroup groups second description equals: builder stackContextMenuExplorationDescription.
	self assert: stackGroup groups third name equals: builder stackGroupName.
	self assert: stackGroup groups third description equals: builder stackGroupDescription.
	self assert: stackGroup groups fourth name equals: builder stackContextMenuActionsGroupName.
	self assert: stackGroup groups fourth description equals: builder stackContextMenuActionsDescription.
]

{ #category : #tests }
StDebuggerStackCommandTreeBuilderTest >> testDisplayStrategy [
	self
		assert: builder class displayStrategy
		equals: CmUIDisplayAsSubMenu
]

{ #category : #tests }
StDebuggerStackCommandTreeBuilderTest >> testGroupDescription [
	self
		assert: builder class groupDescription
		equals: 'Actions on the debugger stack.'
]

{ #category : #tests }
StDebuggerStackCommandTreeBuilderTest >> testGroupName [
	self assert: builder class groupName equals: 'Stack'
]

{ #category : #tests }
StDebuggerStackCommandTreeBuilderTest >> testNavigationCommandForContext [
	| cmd |
	
	cmd := builder buildSpecCommand: StMockDebugCommand forContext: self.
	self assert: cmd innerCommand class identicalTo: StMockDebugCommand.
	self assert: cmd context identicalTo: self
]

{ #category : #tests }
StDebuggerStackCommandTreeBuilderTest >> testStackActionsCommandsClasses [
	self
		assertCollection: builder stackActionsCommandsClasses
		equals: {StReturnValueCommand}
]

{ #category : #tests }
StDebuggerStackCommandTreeBuilderTest >> testStackContextMenuActionsCommands [
	self
		assertCommandGroup: builder stackContextMenuActionsCommands
		hasSameCommands: builder stackActionsCommandsClasses
		withContext: debugger
		displayStrategy: CmUIDisplayAsGroup
]

{ #category : #tests }
StDebuggerStackCommandTreeBuilderTest >> testStackContextMenuActionsDescription [
	self
		assert: builder stackContextMenuActionsDescription
		equals: 'Actions on the selected context'
]

{ #category : #tests }
StDebuggerStackCommandTreeBuilderTest >> testStackContextMenuActionsGroupName [
	self
		assert: builder stackContextMenuActionsGroupName
		equals: 'Context Actions'
]

{ #category : #tests }
StDebuggerStackCommandTreeBuilderTest >> testStackContextMenuBrowseCommands [
	|cmdGroup cmdEntries expectedEntries|	

	cmdGroup := builder stackContextMenuBrowseCommands.
	
	self deny: cmdGroup isRoot.
	self assert: cmdGroup groups size equals: 4.
	self assert: cmdGroup name equals: builder browseGroupName.
	self assert: cmdGroup description equals: builder browseGroupDescription.
	self assert: cmdGroup displayStrategy class identicalTo: CmUIDisplayAsSubMenu.
	
	cmdEntries := self commandsFromSpecGroup: (cmdGroup / builder stackContextNavigationGroupName).
	expectedEntries := self commandsFromSpecGroup: builder stackContextNavigationCommands. 	
	self assertCommands: cmdEntries equals: expectedEntries.
	
	cmdEntries := self commandsFromSpecGroup: (cmdGroup / builder stackMethodNavigationGroupName).
	expectedEntries := self commandsFromSpecGroup: builder stackMethodNavigationCommands. 	
	self assertCommands: cmdEntries equals: expectedEntries.
	
	cmdEntries := self commandsFromSpecGroup: (cmdGroup / builder stackMethodSelectorNavigationGroupName).
	expectedEntries := self commandsFromSpecGroup: builder stackMethodSelectorNavigationCommands. 	
	self assertCommands: cmdEntries equals: expectedEntries.
	
	cmdEntries := self commandsFromSpecGroup: (cmdGroup / builder stackReceiverClassNavigationGroupName).
	expectedEntries := self commandsFromSpecGroup: builder stackReceiverClassNavigationCommands. 	
	self assertCommands: cmdEntries equals: expectedEntries
	
]

{ #category : #tests }
StDebuggerStackCommandTreeBuilderTest >> testStackContextMenuExplorationCommands [
	|  cmdGroup cmdEntries |
	
	cmdGroup := builder stackContextMenuExplorationCommands.
	cmdEntries := cmdGroup allCommands 
		collect:[ :spCmd| spCmd innerCommand ].
	self deny: cmdGroup isRoot.
	self assert: cmdEntries size equals: 3.
	self assert: cmdGroup name equals: builder stackContextMenuExplorationGroupName.
	self assert: cmdGroup description equals: builder stackContextMenuExplorationDescription.
	self
		assertCommandGroupEntries: cmdEntries
		hasCommands: builder stackExplorationCommandsClasses.
	self
		assertCommandGroup: cmdGroup
		hasDisplayStrategy: CmUIDisplayAsSubMenu.
	self
		assertCommands:
			{cmdEntries first.
			cmdEntries second}
		haveContext: debugger stackTable selection selectedItem receiver class.
	self
		assertCommands: {cmdEntries last}
		haveContext: debugger stackTable selection selectedItem receiver 
]

{ #category : #tests }
StDebuggerStackCommandTreeBuilderTest >> testStackContextMenuExplorationDescription [
	self
		assert: builder stackContextMenuExplorationDescription
		equals: 'Explore the receiver object''s graph'
]

{ #category : #tests }
StDebuggerStackCommandTreeBuilderTest >> testStackContextMenuExplorationGroupName [
	self
		assert: builder stackContextMenuExplorationGroupName
		equals: 'Explore'
]

{ #category : #tests }
StDebuggerStackCommandTreeBuilderTest >> testStackContextMenuStackEditionsCommands [
	self
		assertCommandGroup: builder stackContextMenuStackEditionsCommands
		hasSameCommands: builder stackEditionCommandsClasses
		withContext: debugger
		displayStrategy: CmUIDisplayAsSubMenu
]

{ #category : #tests }
StDebuggerStackCommandTreeBuilderTest >> testStackContextNavigationCommands [
	| cmdGroup commands |

	cmdGroup := builder stackContextNavigationCommands.
	commands := cmdGroup allCommands
		collect: [ :spCommand | spCommand innerCommand ].
		
	self deny: cmdGroup isRoot.
	
	self assert: commands first class identicalTo: SpBrowseClassCommand.
	self assert: commands first name equals: 'method'.
	"self assert: commands first context identicalTo: debugger stackTable selection selectedItem method."
	self assert: commands first selector equals: #doBrowseClass.
	
	self assert: commands second class identicalTo: SpBrowseClassCommand.
	self assert: commands second name equals: 'receiver'.
	"self assert: commands second context identicalTo: debugger stackTable selection selectedItem receiver class"
	self assert: commands second selector equals: #doBrowseReceiverClass.
	
]

{ #category : #tests }
StDebuggerStackCommandTreeBuilderTest >> testStackContextNavigationGroupName [
	self
		assert: builder stackContextNavigationGroupName
		equals: 'Receiver class code navigation commands'
]

{ #category : #tests }
StDebuggerStackCommandTreeBuilderTest >> testStackEditionCommandsClasses [
	self
		assertCollection: builder stackEditionCommandsClasses
		equals:
			{StCopyStackToClipboardCommand.
			StShowFullStackCommand.
			StPeelToFirstCommand.
			StFileOutMethodCommand}
]

{ #category : #tests }
StDebuggerStackCommandTreeBuilderTest >> testStackExplorationCommandsClasses [
	self
		assertCollection: builder stackExplorationCommandsClasses
		equals:
			(OrderedCollection new
				addAll: builder stackReceiverClassExplorationCommandsClasses;
				addAll: builder stackReceiverExplorationCommandsClasses;
				yourself)
]

{ #category : #tests }
StDebuggerStackCommandTreeBuilderTest >> testStackGroupDescription [
	self assert: builder stackGroupDescription equals: 'Stack edition'
]

{ #category : #tests }
StDebuggerStackCommandTreeBuilderTest >> testStackGroupName [
	self assert: builder stackGroupName equals: 'Stack'
]

{ #category : #tests }
StDebuggerStackCommandTreeBuilderTest >> testStackMethodCommandsClasses [
	self
		assertCollection: builder stackMethodCommandsClasses
		equals:
			{SpBrowseMethodInheritanceCommand.
			SpBrowseMethodVersionsCommand}
]

{ #category : #tests }
StDebuggerStackCommandTreeBuilderTest >> testStackMethodNavigationCommands [
	self
		assertCommandGroup: builder stackMethodNavigationCommands
		hasSameCommands: builder stackMethodCommandsClasses
		withContext: debugger stackTable selection selectedItem home method
		displayStrategy: CmUIDisplayAsGroup
]

{ #category : #tests }
StDebuggerStackCommandTreeBuilderTest >> testStackMethodNavigationGroupName [
	self
		assertCollection: builder stackMethodNavigationGroupName
		equals: 'Selected method navigation commands'
]

{ #category : #tests }
StDebuggerStackCommandTreeBuilderTest >> testStackMethodSelectorCommandsClasses [
	self
		assertCollection: builder stackMethodSelectorCommandsClasses
		equals:
			{SpBrowseImplementorsCommand.
			SpBrowseSendersCommand.
			SpBrowseMethodReferencesCommand}
]

{ #category : #tests }
StDebuggerStackCommandTreeBuilderTest >> testStackMethodSelectorNavigationCommands [
	self
		assertCommandGroup: builder stackMethodSelectorNavigationCommands
		hasSameCommands: builder stackMethodSelectorCommandsClasses
		withContext: debugger stackTable selection selectedItem method selector
		displayStrategy: CmUIDisplayAsGroup
]

{ #category : #tests }
StDebuggerStackCommandTreeBuilderTest >> testStackMethodSelectorNavigationGroupName [
	self
		assert: builder stackMethodSelectorNavigationGroupName
		equals: 'Selected method''s selector navigation commands'
]

{ #category : #tests }
StDebuggerStackCommandTreeBuilderTest >> testStackReceiverClassExplorationCommandsClasses [
	self
		assertCollection: builder stackReceiverClassExplorationCommandsClasses
		equals:
			{SpBrowseInstancesCommand.
			SpBrowseSubInstancesCommand}
]

{ #category : #tests }
StDebuggerStackCommandTreeBuilderTest >> testStackReceiverClassNavigationCommands [
	self
		assertCommandGroup: builder stackReceiverClassNavigationCommands
		hasSameCommands: builder stackReceiverCommandsClasses
		withContext: debugger stackTable selection selectedItem receiver class
		displayStrategy: CmUIDisplayAsGroup
]

{ #category : #tests }
StDebuggerStackCommandTreeBuilderTest >> testStackReceiverClassNavigationGroupName [
	self
		assert: builder stackReceiverClassNavigationGroupName
		equals: 'Receiver class navigation commands'
]

{ #category : #tests }
StDebuggerStackCommandTreeBuilderTest >> testStackReceiverCommandsClasses [
	self
		assertCollection: builder stackReceiverCommandsClasses
		equals:
			{SpBrowseClassReferencesCommand.
			SpBrowseClassHierarchyCommand.
			SpBrowseClassVariablesCommand.
			SpBrowseClassVarRefsCommand.
			SpBrowseInstVarRefsCommand}
]

{ #category : #tests }
StDebuggerStackCommandTreeBuilderTest >> testStackReceiverExplorationCommandsClasses [
	self
		assertCollection: builder stackReceiverExplorationCommandsClasses
		equals: {SpBrowsePointersToCommand}
]
