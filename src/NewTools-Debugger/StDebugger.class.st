"
The StDebugger is a presenter that provides Pharo debugging functionality by using a DebugSession.

The debugging logic is in DebugSession and the corresponding debugging actions. 

SpecDebugger only provides a graphical interface to access that functionality. 
To interact with the DebugSession, the debugger uses a StDebuggerActionModel, which has responsibility to perform actions to the execution context.


!!Structure of the Pharo debugger

!!!Sub-presenters and layouts
The debugger is composed of default views and extension views.
Default views are the stack, the commands, the status line, the code pane and the inspector.
An extension view automatically appears if any debugging extension is present and if extensions are activated in the settings.
If not, extensions do not appear.

Default and extension views are available in a vertical and an horizontal layout.
It is configureable in the settings under ==Tools >> Debugging >> Debugger layout==.
It is possible to fully customize the debugger layout, and therefore to add or remove any view.
The customized layout must then me selected in the aforementioned setting to be set as default.
To appear in that setting's list of possible values, the layout must be implemented in a method under the ==specs== protocol of the ==StDebugger== class side.

""""The stack.""""
It shows the call stack of the current interrupted context.
Each element in the stack is a context representing a message send.

The context menu (through right click) provides different interactions with the selected stack element: inspection, exploration, exportation, etc.

By default, only a small part of the stack is shown.
More of the stack is observable by either clicking on the bottom context (the last in the stack) or through the context menu.

""""Commands.""""
Commands are actions applicable to the current context
After each debugging action (''e.g.'', a step), the list of commands is being updated.
New commands may appear or disappear.
It depends if they are applicable or not to the current context and debugging session.
For instance, when a ==doesNotUnderstand== exception is raised (''i.e.'', a method does not exist), the command ''createMethod'' will appear.
In that case, it gives users the possibility to create the missing method and continue the execution.

""""The status line.""""
This view provides information about the current context.
Non-critical information, such as the current instruction being stepped, are displayed in gray.
Critical information ,such as halts or breakpoints or DNU exceptions, are displayed in red.

""""The code.""""
The code pane shows the source code of the interrupted context's method.
The source code is annotated with informations about the position of the interrupted execution.
This position corresponds to the next execution that will be executed if a step action is performed.
It is coloured in blue if that instruction is selected in the source code, or in orange and underlined if the selection is empty.

A context menu (through right click) provides inspection, exploration, and stepping actions applicable to the context.
Such actions include, ''e.g.'', browse implementors of a selected message or skip execution of selected parts of the code.

""""The inspector.""""
It provides views on the current context.
It contains tabs with different inspections or views on the current context or on the system.

The raw inspection shows three items: ''Receiver'', ''Temps'' and ''Context''.
The receiver item shows information about the receiver of the message, or the object executing the method from the context.
The temps item shows the temporary variables of the current context.
Finally, the context item shows lower-level details, such as the interrupted context, the debug session or the debugger itself.
Double-clicking on an item will spawn a new view in the same inspector, with an inspection on the selected item.

The breakpoints inspection shows all breakpoints installed for the current receiver.
Those breakpoints are either installed on the receiver's class (''e.g.'', halts) or on that specific receiver (''i.e.'', object-centric breakpoints or halts.)
Ticking or unticking a breakpoint in that list will activate or deactivate that breakpoint.

The meta inspection shows methods of the receiver's class hierarchy.
Methods can be modified and saved in directly in that pane.
"
Class {
	#name : #StDebugger,
	#superclass : #StPresenter,
	#traits : 'TDebugger',
	#classTraits : 'TDebugger classTrait',
	#instVars : [
		'sessionHolder',
		'code',
		'toolbar',
		'stackTable',
		'inspector',
		'breakpointInspector',
		'stackHeader',
		'extensionTools',
		'extensionToolsNotebook',
		'toolbarCommandGroup',
		'debuggerActionModel',
		'unsavedCodeChanges',
		'programmaticallyClosed'
	],
	#classVars : [
		'ActivateDebuggerExtensions',
		'ErrorRecursion',
		'FastTDD',
		'UsingSpecSelector'
	],
	#category : #'NewTools-Debugger-View'
}

{ #category : #accessing }
StDebugger class >> activateDebuggerExtensions [
	^ ActivateDebuggerExtensions
		ifNil: [ ActivateDebuggerExtensions := true ]
]

{ #category : #accessing }
StDebugger class >> activateDebuggerExtensions: anObject [
	ActivateDebuggerExtensions := anObject
]

{ #category : #specs }
StDebugger class >> availableSpecSelectors [
	^ self class allSelectorsInProtocol: 'specs - selectors'
]

{ #category : #commands }
StDebugger class >> buildCommandsGroupWith: stDebuggerInstance forRoot: rootCommandGroup [
	StDebuggerStackCommandTreeBuilder
		buildCommandsGroupWith: stDebuggerInstance
		forRoot: rootCommandGroup.
	StDebuggerToolbarCommandTreeBuilder
		buildCommandsGroupWith: stDebuggerInstance
		forRoot: rootCommandGroup.
	StDebuggerCodeCommandTreeBuilder
		buildCommandsGroupWith: stDebuggerInstance
		forRoot: rootCommandGroup
]

{ #category : #utilities }
StDebugger class >> closeAllDebuggers [
	<script>
	StDebugger allInstancesDo: [ :dbg | dbg close ]
]

{ #category : #specs }
StDebugger class >> codeLayout [
	self flag: #DBG_SPEC.
	"Tool bar height is not enough to contain the buttons with icons (issue #94)."
	^ SpBoxLayout newVertical
		  add: #toolbar withConstraints: [ :constraints | 
			  constraints
				  expand: true;
				  height: self toolbarHeight + 12];
		  add: #code;
		  yourself
]

{ #category : #'instance creation' }
StDebugger class >> debugSession: aDebugSession [
	| debugger |

	debugger := self on: aDebugSession.
	aDebugSession application 
		ifNotNil: [ :app | debugger application: app ].
	debugger openWithFullView.
	
	^ debugger
]

{ #category : #accessing }
StDebugger class >> debuggerContextClass [
	^ StDebuggerContext
]

{ #category : #settings }
StDebugger class >> debuggerLayoutSettingsOn: aBuilder [
	<systemsettings>
	(aBuilder pickOne: #usingSpecSelector)
		label: 'Default debugger spec layout';
		target: self;
		default: #debuggerWithoutExtensionsSpec;
		parent: #debugging;
		domainValues: self availableSpecSelectors;
		description: 'Sets the default spec layout of the debugger.'
]

{ #category : #'specs - selectors' }
StDebugger class >> debuggerWithExtensionsSpec [
	^ SpPanedLayout newVertical
		position: 65 percent;
		add:
			(SpPanedLayout newHorizontal
				position: 65 percent;
				add: self stackAndCodeLayout;
				add: #extensionToolsNotebook;
				yourself);
		add: #inspector;
		yourself
]

{ #category : #'specs - selectors' }
StDebugger class >> debuggerWithoutExtensionsSpec [
	^ SpPanedLayout newVertical
		position: 65 percent;
		add: self stackAndCodeLayout;
		add: #inspector;
		yourself
]

{ #category : #accessing }
StDebugger class >> defaultDebuggerRank [

	^ 10
]

{ #category : #specs }
StDebugger class >> defaultSpec [
	^ self perform: self usingSpecSelector
]

{ #category : #'tools registry' }
StDebugger class >> extensionToolsClasses [
	^TStDebuggerExtension users
]

{ #category : #settings }
StDebugger class >> fastTDD [
	^FastTDD ifNil:[FastTDD := false]
]

{ #category : #settings }
StDebugger class >> fastTDD: aBoolean [

	FastTDD := aBoolean
]

{ #category : #settings }
StDebugger class >> fastTDDSettingsOn: aBuilder [
	<systemsettings>
	(aBuilder setting: #fastTDD)
		label: 'Fast TDD';
		target: self;
		default: false;
		parent: #debugging;
		description: 'Create classes and methods directly in the receiver''s class
without requesting information from the user'
]

{ #category : #'tools registry' }
StDebugger class >> hasAnyActivatedExtension: extensionsClasses [

	^ extensionsClasses anySatisfy: [ :toolClass | 
		  toolClass showInDebugger ]
]

{ #category : #'class initialization' }
StDebugger class >> initialize [ 
	self flag: 'Error recursion is used only here?'.
	ErrorRecursion := false
]

{ #category : #opening }
StDebugger class >> openOn: aDebugSession withFullView: aBool [
	
	^ self openOn: aDebugSession withFullView: aBool andNotification: nil
]

{ #category : #opening }
StDebugger class >> openOn: aDebugSession withFullView: aBool andNotification: aString [
	| debugger |
	debugger := self on: aDebugSession.
	debugger openWithFullView.
	^ debugger
]

{ #category : #accessing }
StDebugger class >> sessionClass [
	self flag: 'Should be replaced by Sindarin - should even be removed in that case!'.
	^ DebugSession
]

{ #category : #accessing }
StDebugger class >> spanNewSessionFrom: anotherSession [
	self flag: 'Where is that used? 2019-06-28'.
	^ anotherSession spanNewSession
]

{ #category : #specs }
StDebugger class >> stackAndCodeLayout [
	^ SpPanedLayout newVertical
		position: 30 percent;
		add: self stackLayout;
		add: self codeLayout;
		yourself
]

{ #category : #specs }
StDebugger class >> stackLayout [
	^ SpBoxLayout newVertical
		add: #stackHeader
			expand: false
			fill: false
			padding: 5;
		add: #stackTable;
		yourself
]

{ #category : #deprecated }
StDebugger class >> taskbarIconName [

	^#smallDebugIcon
]

{ #category : #'tools registry' }
StDebugger class >> usesExtensions [

	^ self activateDebuggerExtensions and: [ 
		  self hasAnyActivatedExtension: self extensionToolsClasses ]
]

{ #category : #specs }
StDebugger class >> usingSpecSelector [
	^ (UsingSpecSelector
		ifNil: [ UsingSpecSelector := StDebuggerSpecSelector defaultSelector ])
		selectSpecSelector
]

{ #category : #specs }
StDebugger class >> usingSpecSelector: aSelector [

	UsingSpecSelector := StDebuggerSpecSelector on: aSelector
]

{ #category : #'presenter - code' }
StDebugger >> acceptCodeChanges: newSource forContext: aContext [

	"It is wrong here that I have to use code adapter widget.
	It is expected down in the compilation call chain that the notified requestor answers to textMorph.
	This is for modifying the source code when declaring temps"

	self
		recompileMethodTo: newSource
		inContext: aContext
		notifying: code adapter widget.
	self clearUnsavedCodeChanges
]

{ #category : #'command support' }
StDebugger >> buildContextMenus [
	| stackGroup codeCommands debuggerCommandGroup |
	
	debuggerCommandGroup := self rootCommandsGroup.
	"Stack"
	stackGroup := debuggerCommandGroup / StDebuggerStackCommandTreeBuilder groupName.
	stackTable contextMenu: stackGroup beRoot asMenuPresenter.

	"Toolbar"
	toolbarCommandGroup := debuggerCommandGroup / StDebuggerToolbarCommandTreeBuilder groupName.
	SpToolbarPresenterBuilder new
		toolbarPresenter: toolbar;
		visit: toolbarCommandGroup.
	self updateToolbar.

	"Code"
	codeCommands := debuggerCommandGroup / StDebuggerCodeCommandTreeBuilder groupName.
	code contextMenu: codeCommands beRoot asMenuPresenter
]

{ #category : #'command support' }
StDebugger >> canExecuteCreateMissingClassCommand [
	^ self debuggerActionModel isInterruptedContextMissingClassException
]

{ #category : #'command support' }
StDebugger >> canExecuteCreateMissingMethodCommand [
	^ self debuggerActionModel isInterruptedContextDoesNotUnderstand
]

{ #category : #'command support' }
StDebugger >> canExecuteCreateSubclassResponsibilityCommand [
	^ self debuggerActionModel isInterruptedContextSubclassResponsibilityException
]

{ #category : #'command support' }
StDebugger >> canExecuteDebugCommand [
	^ self debuggerActionModel isContextSteppable
]

{ #category : #'command support' }
StDebugger >> canExecuteRestartCommand [

	^ (self debuggerActionModel isInterruptedContextPostMortem or: [ 
		   self debuggerActionModel isInterruptedContextDead ]) not
]

{ #category : #'command support' }
StDebugger >> canExecuteReturnCommand [

	^ self debuggerActionModel isInterruptedContextDead not
]

{ #category : #actions }
StDebugger >> clear [

	extensionToolsNotebook pages do: [ :page | 
		page activePresenter windowIsClosing ].
	extensionTools := nil.
	self unsubscribeFromSystemAnnouncer.	
	self removeActionsForSession: self session.
	
	"When we programmatically close the window, we do not need to terminate the session as it was already cleared"
	programmaticallyClosed ifTrue: [ ^ self ].
	debuggerActionModel clearDebugSession
]

{ #category : #'updating widgets' }
StDebugger >> clearCode [
	
	self code
		clearInteractionModel;
		clearSelection;
		clearContent
]

{ #category : #'presenter - code' }
StDebugger >> clearUnsavedCodeChanges [

	unsavedCodeChanges := IdentityDictionary new
]

{ #category : #opening }
StDebugger >> close [

	programmaticallyClosed := true.
	[ self withWindowDo: #close ] ensure: [ 
		debuggerActionModel ifNotNil: [ :actionModel | 
			actionModel clearDebugSession ] ]
]

{ #category : #'accessing widgets' }
StDebugger >> code [

	^ code
]

{ #category : #'accessing context' }
StDebugger >> context [
 
	^ self interruptedContext
]

{ #category : #actions }
StDebugger >> copyStackToClipboard [
	self debuggerActionModel copyStackToClipboard
]

{ #category : #actions }
StDebugger >> createMissingClass [

	| message exception variableNode |
	self flag: #DBG_MISSINGTEST.
	message := self interruptedContext tempAt: 1.
	exception := self interruptedContext tempAt: 2.
	variableNode := exception variableNode.
	[ 
	OCUndeclaredVariableWarning new
		node: variableNode;
		defineClass: variableNode name.
	self
		createMissingMethodFor: message
		in: self interruptedContext receiver class ]
		on: Abort
		do: [ ^ self ].

	self debuggerActionModel restartContext: self interruptedContext
]

{ #category : #actions }
StDebugger >> createMissingMethod [

	| msg chosenClass |
	self flag: #DBG_MISSINGTEST.
	msg := self interruptedContext tempAt: 1.
	[ 
	chosenClass := self requestClassFrom:
		               self interruptedContext receiver class.
	self createMissingMethodFor: msg in: chosenClass ]
		on: Abort
		do: [ ^ self ].
		
	code takeKeyboardFocus 
]

{ #category : #actions }
StDebugger >> createMissingMethodFor: aMessage in: aClass [
	self flag: #DBG_MISSINGTEST.
	self debuggerActionModel
		implement: aMessage
		classified: (self requestProtocolIn: aClass)
		inClass: aClass
		forContext: self interruptedContext.
	self selectTopContext
]

{ #category : #actions }
StDebugger >> createSubclassResponsibility [

	| senderContext msg msgCategory chosenClass |
	senderContext := self interruptedContext sender.
	msg := Message
		       selector: senderContext selector
		       arguments: senderContext arguments.
	msgCategory := senderContext methodClass organization 
		               categoryOfElement: msg selector.
	chosenClass := self requestClassFrom: senderContext receiver class.
	chosenClass ifNil: [ ^ self ].
	self debuggerActionModel
		implement: msg
		classified: msgCategory
		inClass: chosenClass
		forContext: senderContext
]

{ #category : #'accessing context' }
StDebugger >> currentContext [
	"I answer the context on which an action should be executed.
	This is either the selected context or if nothing is selected the interrupted context."
	
	^ self selectedContext isNil 
		ifTrue: [ self interruptedContext ]
		ifFalse: [ self selectedContext ]
]

{ #category : #accessing }
StDebugger >> debuggerActionModel [
	^ debuggerActionModel
		ifNil: [ debuggerActionModel := StDebuggerActionModel on: self session]
]

{ #category : #accessing }
StDebugger >> debuggerInspectorClass [
	^ StDebuggerInspector
]

{ #category : #accessing }
StDebugger >> debuggerInspectorModelClass [
	^ StDebuggerInspectorModel
]

{ #category : #'presenter - code' }
StDebugger >> discardCodeChangesFor: aContext [

	self unsavedCodeChanges removeKey: aContext ifAbsent: [  ].
	self code text: aContext sourceCode.
	self update
]

{ #category : #commands }
StDebugger >> doBrowseClass [

	self systemNavigation browse: self stackSelectionMethodContext value
]

{ #category : #commands }
StDebugger >> doBrowseReceiverClass [

	self systemNavigation browse: self stackSelectionReceiverClassContext value
]

{ #category : #stack }
StDebugger >> expandStackIfLastItemIsSelected [
	| selection |
	selection := stackTable selection.
	selection selectedItem == stackTable items last ifFalse: [ ^ self ].
	stackTable items: (self filterStack:
			 (self session stackOfSize: 2 * stackTable items size)).
	stackTable selectIndex: selection selectedIndex
]

{ #category : #extensions }
StDebugger >> extensionTools [
	^ extensionTools ifNil: [ extensionTools := OrderedCollection new ]
]

{ #category : #actions }
StDebugger >> fileOutSelectedContext [
	self debuggerActionModel
		fileOutMethod: stackTable selection selectedItem method
]

{ #category : #stack }
StDebugger >> filterStack: aStack [
	^self debuggerActionModel filterStack: aStack
]

{ #category : #stack }
StDebugger >> findFirstRelevantStackIndexIn: aStack [
	| counter |
	counter := 1.
	aStack do: [ :context | 
		context method methodClass == TestAsserter ifFalse: [ ^ counter ].
		counter := counter + 1 ].
	^ 1
]

{ #category : #'updating session' }
StDebugger >> forceSessionUpdate [
	self sessionHolder valueChanged
]

{ #category : #api }
StDebugger >> initialExtent [ 
	"This code was taken from the old debugger to get the same behavior. Fell free to refactor"
	self flag: 'Do it better'.
	"RealEstateAgent standardWindowExtent y < 400"true "a tiny screen" 
		ifTrue: [ ^ 1000@800 ].
	
	^ [ | w h |
		w := Display width.
		h := Display height.
		(w - (w // 3)) @ (h - (h // 5)) ]
		on: Error
		do: [ 850@650 ]
]

{ #category : #initialization }
StDebugger >> initialize [
	super initialize.
	self debuggerActionModel updateContextPredicate.			
	self setSessionHolderSubscriptions.
	self forceSessionUpdate.
	self subscribeToMethodAddedAnnouncement.
	
	programmaticallyClosed := false.
]

{ #category : #initialization }
StDebugger >> initializeBreakpointInspector [
	breakpointInspector := self
		instantiate: StDebuggerBreakpointInspection
		on: (StInspectorModel on: nil).
]

{ #category : #'presenter - code' }
StDebugger >> initializeCode [

	code := self newCode.
	code whenSubmitDo: [ :text | 
		self acceptCodeChanges: text string forContext: self selectedContext ].
	code whenResetDo: [ self discardCodeChangesFor: self selectedContext ]
]

{ #category : #extensions }
StDebugger >> initializeExtensionTools [

	| sortedToolClasses pages |
	extensionToolsNotebook := self newNotebook.

	self class usesExtensions ifFalse: [ ^ self ].
	sortedToolClasses := SortedCollection new sortBlock: [ :s1 :s2 | s1 displayOrder <= s2 displayOrder ].
	sortedToolClasses addAll: (self class extensionToolsClasses select: [ :s | s showInDebugger ]).
	pages := sortedToolClasses collect: [ :toolClass | 
		         self instantiateExtensionToolsPage: toolClass ].
	extensionToolsNotebook pages: pages
]

{ #category : #initialization }
StDebugger >> initializeInspector [

	inspector := self
		             instantiate: self debuggerInspectorClass
		             on:
		             (self debuggerInspectorModelClass on: self newDebuggerContext).
	inspector label: 'Receiver'
]

{ #category : #initialization }
StDebugger >> initializePresenter [

	super initializePresenter.
	self whenDisplayDo: [ 
		self updateToolbar.
		self updateCodeFromContext ]
]

{ #category : #initialization }
StDebugger >> initializePresenters [

	self initializeStack.
	self initializeToolbar.
	self initializeCode.
	self initializeInspector.
	self initializeExtensionTools
]

{ #category : #initialization }
StDebugger >> initializeShortcuts: aWindowPresenter [

	self flag: #DBG_TempSolvesSpecBug_RemoveWhenFixed.
	"This is only because of a problem in presenters, where shortcuts only work in the scope of their presenter.
	Consequently, debug shortcuts from the debugger toolbar only work if the mouse is over the toolbar button.
	This should be removed once the spec bug is fixed"
	aWindowPresenter
		bindKeyCombination: StProceedCommand defaultShortcut
		toAction: [ self proceedDebugSession ].
	aWindowPresenter
		bindKeyCombination: StStepIntoCommand defaultShortcut
		toAction: [ self stepInto ].
	aWindowPresenter
		bindKeyCombination: StStepOverCommand defaultShortcut
		toAction: [ self stepOver ].
	aWindowPresenter
		bindKeyCombination: StStepThroughCommand defaultShortcut
		toAction: [ self stepThrough ].
	aWindowPresenter
		bindKeyCombination: StRestartCommand defaultShortcut
		toAction: [ self restartCurrentContext ]
]

{ #category : #initialization }
StDebugger >> initializeStack [

	stackTable := self newTable.
	stackTable
		addColumn: ((SpImageTableColumn
				  title: ''
				  evaluated: [ :context | self stackIconForContext: context ])
				 width: 8;
				 sortFunction: nil;
				 yourself);
		addColumn: ((SpStringTableColumn
				  title: 'Class'
				  evaluated: [ :item | self printReceiverClassInContext: item ])
				 sortFunction: nil;
				 yourself);
		addColumn:
			((SpStringTableColumn title: 'Method' evaluated: [ :item | 
					  | method |
					  method := item method.
					  method isCompiledBlock
						  ifTrue: [ method sourceNode sourceCode ]
						  ifFalse: [ method selector ] ])
				 sortFunction: nil;
				 yourself);
		addColumn:
			((SpStringTableColumn title: 'Package' evaluated: [ :item | 
					  | package |
					  package := item method package.
					  package ifNil: [ '-' ] ifNotNil: [ package name asString ] ])
				 sortFunction: nil;
				 yourself).
	stackTable transmitDo: [ :context | 
		stackTable selection isEmpty ifFalse: [ 
			self updateInspectorFromContext: context.
			self updateCodeFromContext: context.
			self expandStackIfLastItemIsSelected.
			self updateWindowTitle ] ].
	stackHeader := self instantiate: StHeaderBar.
	stackHeader label: 'Stack'.
	stackHeader toolbarActions: (CmCommandGroup new
			 register:
				 ((StDebuggerToggleFilterStackCommand forSpecContext: self) 
					  iconName: #changeSorter);
			 register:
				 (StDebuggerSettingsCommand forSpecWithIconNamed: #configuration);
			 asSpecGroup)
]

{ #category : #initialization }
StDebugger >> initializeToolbar [

	toolbar := self newToolbar.
	toolbar displayMode: self application toolbarDisplayMode
]

{ #category : #initialization }
StDebugger >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	aWindowPresenter
		title: self debuggerActionModel statusStringForContext;
		initialExtent: self initialExtent;
		whenClosedDo: [ self clear ].

	self initializeShortcuts: aWindowPresenter
]

{ #category : #extensions }
StDebugger >> instantiateExtensionToolsPage: aToolClass [
	| toolInstance |
	toolInstance := self instantiate: aToolClass on: self.
	self registerExtensionTool: toolInstance.
	^ SpNotebookPage
		title: toolInstance debuggerExtensionToolName
		provider: [ toolInstance ]
]

{ #category : #'accessing context' }
StDebugger >> interruptedContext [

	^ self session interruptedContext
]

{ #category : #accessing }
StDebugger >> interruptedProcess [

	^ self session interruptedProcess
]

{ #category : #'instance creation' }
StDebugger >> newDebuggerContext [

	^ self class debuggerContextClass new
		  exception: self session exception;
		  yourself
]

{ #category : #'instance creation' }
StDebugger >> newDebuggerContextFor: aContext [

	^ self newDebuggerContext
		  context: aContext;
		  yourself
]

{ #category : #'accessing context' }
StDebugger >> newTitle [

	^ self debuggerActionModel statusStringForContext
]

{ #category : #api }
StDebugger >> okToChange [

	self code canDiscardEdits
		ifTrue: [ ^ true ].
	self code changed: #wantToChange.
	^ self code canDiscardEdits
]

{ #category : #opening }
StDebugger >> openWithFullView [
	"Create and schedule a full debugger with the given label. Do not
	terminate the current active process."

	self openWithSpec
]

{ #category : #opening }
StDebugger >> openWithNotification: notificationString [

	self openWithFullView
]

{ #category : #actions }
StDebugger >> peelToFirstLike: aContext [

	self debuggerActionModel peelToFirstLike: aContext.
	self clearUnsavedCodeChanges.
	self code text: self currentContext sourceCode
]

{ #category : #printing }
StDebugger >> printReceiverClassInContext: aContext [

	| receiverClass methodClass |
	receiverClass := aContext receiver class.
	methodClass := aContext method methodClass.
	receiverClass == methodClass ifTrue: [ ^ receiverClass name ].
	^ (WriteStream on: String new)
		  nextPutAll: receiverClass name;
		  space;
		  nextPut: $(;
		  nextPutAll: methodClass name;
		  nextPut: $);
		  contents
]

{ #category : #actions }
StDebugger >> proceedDebugSession [

	self removeActionsForSession: self session.
	self debuggerActionModel proceedDebugSession.
	self close
]

{ #category : #actions }
StDebugger >> recompileMethodTo: aString inContext: aContext notifying: aNotifyer [

	aContext ifNil: [ ^ self ].
	self session
		recompileMethodTo: aString
		inContext: aContext
		notifying: aNotifyer
]

{ #category : #'presenter - code' }
StDebugger >> recordUnsavedCodeChanges [

	|codeInteractionModel codeText|
	codeInteractionModel := self code interactionModel.
	codeInteractionModel hasUnsavedCodeChanges ifFalse:[^self].
	
	codeText := self code text asString.
	self unsavedCodeChanges at: codeInteractionModel context put: codeText
]

{ #category : #'updating session' }
StDebugger >> registerActionsForSession: aSession [
	self flag: 'Rewrite it'.
	aSession
		ifNotNil: [ aSession
				when: #restart send: #updateRestart to: self;
				when: #resume send: #updateResume to: self;
				when: #stepInto send: #updateStepInto to: self;
				when: #stepOver send: #updateStepOver to: self;
				when: #stepThrough send: #updateStepThrough to: self;
				when: #contextChanged send: #updateContextChanged to: self ]
]

{ #category : #extensions }
StDebugger >> registerExtensionTool: anExtension [
	self extensionTools add: anExtension
]

{ #category : #'updating session' }
StDebugger >> removeActionsForSession: aSession [
	self flag: 'Rewrite it'.
	aSession
		ifNotNil: [ aSession
				removeActionsForEvent: #restart;
				removeActionsForEvent: #resume;
				removeActionsForEvent: #stepInto;
				removeActionsForEvent: #stepOver;
				removeActionsForEvent: #stepThrough;
				removeActionsForEvent: #contextChanged ]
]

{ #category : #'updating session' }
StDebugger >> removeSessionHolderSubscriptions [
	self sessionHolder announcer unsubscribe: self sessionHolder.
	self removeActionsForSession: self session
]

{ #category : #'ui requests' }
StDebugger >> requestClassFrom: aClass [

	self class fastTDD ifTrue: [ ^ aClass ].
	^ self requestSuperclassOf: aClass to: ProtoObject
]

{ #category : #'ui requests' }
StDebugger >> requestProtocolIn: aClass [

	| entryCompletion applicants choice |
	self class fastTDD ifTrue: [ ^ Protocol unclassified ].
	applicants := AbstractTool protocolSuggestionsFor: aClass.
	entryCompletion := EntryCompletion new
		                   dataSourceBlock: [ :currText | applicants ];
		                   filterBlock: [ :currApplicant :currText | 
			                   currText size > 3 and: [ 
					                   currApplicant asLowercase includesSubstring:
							                   currText asString asLowercase ] ].

	choice := (UIManager default
		           request:
		           'Start typing for suggestions (3 characters minimum)'
		           initialAnswer: Protocol unclassified
		           title: 'Choose a protocol'
		           entryCompletion: entryCompletion) ifNil: [ Abort signal ].

	^ choice ifEmpty: [ Protocol unclassified ]
]

{ #category : #'ui requests' }
StDebugger >> requestSuperclassOf: aClass to: aSuperclass [

	| classes |
	classes := OrderedCollection with: aClass.
	classes addAll: (aClass allSuperclassesIncluding: aSuperclass).
	classes addAll:
		(aClass traits sort: [ :t1 :t2 | t1 asString < t2 asString ]).
	classes size = 1 ifTrue: [ ^ classes first ].
	^ (UIManager default
		   chooseFrom: (classes collect: [ :c | c name ])
		   values: classes
		   title: 'Define selector in:') ifNil: [ Abort signal ]
]

{ #category : #actions }
StDebugger >> restartCurrentContext [

	self debuggerActionModel restartContext: self currentContext.
	self clearUnsavedCodeChanges.
	self code text: self currentContext sourceCode.
	self updateCodeFromContext
]

{ #category : #actions }
StDebugger >> returnEnteredValue [
	| expression |
	self flag: #DBG_HowToTestNilIfUserCancels.
	expression := (UIManager default
		request: 'Enter expression for return value:') ifNil: [^self].
	self debuggerActionModel
		returnValueFromExpression: expression
		fromContext: self currentContext
]

{ #category : #actions }
StDebugger >> runToSelection [
	self debuggerActionModel
		runToSelection: self code selectionInterval
		inContext: self currentContext
]

{ #category : #actions }
StDebugger >> selectNextExecutedExpression [

	| sourceNodeExecuted |
	sourceNodeExecuted := self currentContext sourceNodeExecuted.
	self code selectionInterval:
		(sourceNodeExecuted start to: sourceNodeExecuted stop)
]

{ #category : #stack }
StDebugger >> selectTopContext [
	stackTable selectIndex: 1
]

{ #category : #'accessing context' }
StDebugger >> selectedContext [

	^ self stackTable selection selectedItem
]

{ #category : #accessing }
StDebugger >> session [
	^ self sessionHolder value
]

{ #category : #accessing }
StDebugger >> session: aSession [
	self sessionHolder value: aSession
]

{ #category : #accessing }
StDebugger >> sessionHolder [
	^ sessionHolder ifNil: [ sessionHolder := nil asValueHolder ]
]

{ #category : #initialization }
StDebugger >> setModelBeforeInitialization: aSession [

	self session: aSession
]

{ #category : #'updating session' }
StDebugger >> setSessionHolderSubscriptions [
	self sessionHolder
		whenChangedDo: [ :newSession :oldSession | 
			self removeActionsForSession: oldSession.
			self registerActionsForSession: newSession.
			self updateStackFromSession: newSession.
			self updateExtensionsFrom: newSession ]
]

{ #category : #actions }
StDebugger >> showFullStack [
	stackTable items: (self filterStack: self session stack)

]

{ #category : #stack }
StDebugger >> stackIconForContext: context [

	self unsavedCodeChanges at: context ifAbsent: [ ^ nil ].
	^ self iconNamed: #overlayDirty
]

{ #category : #'command support' }
StDebugger >> stackSelectionMethodContext [

	^ [ stackTable selection selectedItem home method ]
]

{ #category : #'command support' }
StDebugger >> stackSelectionMethodSelectorContext [

	^ [ stackTable selection selectedItem method selector ]
]

{ #category : #'command support' }
StDebugger >> stackSelectionReceiverClassContext [
	^ [ stackTable selection selectedItem receiver class ]
]

{ #category : #'command support' }
StDebugger >> stackSelectionReceiverContext [
	^ [ stackTable selection selectedItem receiver ]
]

{ #category : #'accessing widgets' }
StDebugger >> stackTable [
	^stackTable
]

{ #category : #actions }
StDebugger >> stepInto [
	self debuggerActionModel stepInto: self currentContext
]

{ #category : #actions }
StDebugger >> stepOver [
	self debuggerActionModel stepOver: self currentContext
]

{ #category : #actions }
StDebugger >> stepThrough [
	self debuggerActionModel stepThrough: self currentContext
]

{ #category : #'system subscriptions' }
StDebugger >> subscribeToMethodAddedAnnouncement [

	SystemAnnouncer uniqueInstance weak
		when: MethodAdded
		send: #updateAfterMethodAdded
		to: self
]

{ #category : #'accessing widgets' }
StDebugger >> toolbar [

	^ toolbar
]

{ #category : #'presenter - code' }
StDebugger >> unsavedCodeChanges [

	^ unsavedCodeChanges ifNil: [ 
		  unsavedCodeChanges := IdentityDictionary new ]
]

{ #category : #'presenter - code' }
StDebugger >> unsavedCodeChangesFor: aContext [ 
	^self unsavedCodeChanges at: aContext
]

{ #category : #'system subscriptions' }
StDebugger >> unsubscribeFromSystemAnnouncer [

	SystemAnnouncer uniqueInstance unsubscribe: self
]

{ #category : #'updating widgets' }
StDebugger >> updateAfterMethodAdded [
	debuggerActionModel updateContextPredicate.
	self updateToolbar 
]

{ #category : #'updating widgets' }
StDebugger >> updateCodeFromContext [

	self updateCodeFromContext: self currentContext
]

{ #category : #'presenter - code' }
StDebugger >> updateCodeFromContext: aContext [
	| selectionInterval |

	aContext ifNil: [ ^ self clearCode ].
	
	self recordUnsavedCodeChanges.
	selectionInterval := self session selectedCodeRangeForContext: aContext.
	aContext sourceCode = self code text 
		ifFalse: [ self updateSourceCodeFor: aContext ].
	self code beForContext: aContext.
	self code selectionInterval: (selectionInterval last to: selectionInterval last - 1).
	self
		updateCodeTextSegmentDecoratorsIn: aContext
		forInterval: selectionInterval.
	
]

{ #category : #'updating widgets' }
StDebugger >> updateCodeTextSegmentDecoratorsIn: aContext forInterval: selectionInterval [
	
	self code removeAllTextSegmentDecorations.
	
	"This decorates the receiver and the next node with an underline"
	"self code
		addTextSegmentDecoration:
			(SpTextPresenterDecorator new
				underlineColor: Color orange;
				interval: (aContext currentNode start to: aContext currentNode stop + 1);
				yourself)."
				
	"This decorates the next executing node"
	self code
		addTextSegmentDecoration:
			(SpTextPresenterDecorator new
				highlightColor: (Color orange alpha: 0.5);
				underlineColor: (Color white alpha: 0);
				interval: (selectionInterval first to: selectionInterval last + 1);
				yourself)
				
			"	icon: (self iconNamed: #warning);
				iconBlock: [ :n | n inspect ];
				title: 'Click me!';"
]

{ #category : #'updating actions' }
StDebugger >> updateContextChanged [
	self updateStep
]

{ #category : #'updating widgets' }
StDebugger >> updateExtensionsFrom: newSession [
	self extensionTools do:[:tool| tool updatePresenter]
]

{ #category : #'updating widgets' }
StDebugger >> updateInspectorFromContext: aContext [

	inspector
		updateLayoutForContexts: self session interruptedContext
		isAssertionFailure:
		self debuggerActionModel isInterruptedContextAnAssertEqualsFailure.
	inspector updateWith: (self newDebuggerContextFor: aContext).
	self flag: #DBG_INSPECTOR_UPDATE_BUG.
	inspector getRawInspectorPresenterOrNil ifNotNil: [ :p | p update ]
]

{ #category : #'updating widgets' }
StDebugger >> updatePredicatesForContext: aContext [

	self debuggerActionModel updateContextPredicate
]

{ #category : #initialization }
StDebugger >> updatePresenter [

	self updateStackFromSession: self session.
	self buildContextMenus
]

{ #category : #'updating actions' }
StDebugger >> updateRestart [
	self updateStep
]

{ #category : #'updating actions' }
StDebugger >> updateResume [

	
]

{ #category : #'presenter - code' }
StDebugger >> updateSourceCodeFor: aContext [

	| codeText |
	codeText := self unsavedCodeChanges
		            at: aContext
		            ifAbsent: [ aContext sourceCode ].
	self code text: codeText
]

{ #category : #stack }
StDebugger >> updateStackFromSession: aSession [
	|stack|
	stack := (self filterStack: aSession stack).
	stackTable items: stack.
	stackTable selectIndex: (self findFirstRelevantStackIndexIn: stack)
]

{ #category : #'updating actions' }
StDebugger >> updateStep [
	self flag: #DBG_UPDATE_OF_MODEL_SHOULD_BE_AUTOMATED.
	debuggerActionModel updateTopContext.
	debuggerActionModel updateContextPredicate.	
	debuggerActionModel updateDebugSession.
		
	self updateStackFromSession: self session.
	self updateWindowTitle.
	self updateExtensionsFrom: self session.	
	self updateToolbar.
	self flag: #DBG_INSPECTOR_UPDATE_BUG.
	inspector getRawInspectorPresenterOrNil ifNotNil: [ :p | p update ]
]

{ #category : #'updating actions' }
StDebugger >> updateStepInto [
	self updateStep
]

{ #category : #'updating actions' }
StDebugger >> updateStepOver [

	self updateStep 
	
]

{ #category : #'updating actions' }
StDebugger >> updateStepThrough [

	self updateStep 
]

{ #category : #'updating widgets' }
StDebugger >> updateToolbar [
	
	toolbarCommandGroup ifNil: [ ^ self ].
	toolbarCommandGroup allCommands do: [ :spCommand | 
		spCommand updateEnableStatus ]
]

{ #category : #'updating widgets' }
StDebugger >> updateWindowTitle [

	self withWindowDo: [ :window | window title: self newTitle ].
]

{ #category : #'ui requests' }
StDebugger >> warning: aString for: aPresenter [

	self newPopover
		addStyle: 'error';
		relativeTo: aPresenter;
		position: SpPopoverPosition top;
		presenter: (SpPresenter new
				 layout: (SpBoxLayout newVertical
						  borderWidth: 2;
						  spacing: 0;
						  add: (self newLabel label: aString);
						  yourself);
				 yourself);
		popup
]
