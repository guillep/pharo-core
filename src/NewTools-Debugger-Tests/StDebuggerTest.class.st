Class {
	#name : #StDebuggerTest,
	#superclass : #TestCase,
	#instVars : [
		'session',
		'debugger',
		'oldFastTDD'
	],
	#category : #'NewTools-Debugger-Tests-Presenters'
}

{ #category : #accessing }
StDebuggerTest >> debugger [
	^ debugger ifNil: [ debugger := self debuggerClass basicNew ]
]

{ #category : #accessing }
StDebuggerTest >> debuggerClass [
	^ StDebugger
]

{ #category : #accessing }
StDebuggerTest >> debuggerOn: aDebugSession [

	^ self debugger
		  session: aDebugSession;
		  application: self debuggerClass currentApplication;
		  initialize;
		  yourself
]

{ #category : #accessing }
StDebuggerTest >> executionControlCommandFrom: aDebugger [

	^ debugger toolbar leftItems select: [ :p | 
		  #( 'Proceed' 'Into' 'Over' 'Through' ) includes: p label ]
]

{ #category : #accessing }
StDebuggerTest >> initializedDebugger [
	| dbg |
	dbg := self debugger.
	dbg application: self debuggerClass currentApplication.
	dbg initialize.
	^ dbg
]

{ #category : #accessing }
StDebuggerTest >> inspectorTableFor: inspector [
	|contextInspector|
	contextInspector := (inspector class slotNamed: #contextInspector) read: inspector.
	^(contextInspector class slotNamed: #attributeTable) read: contextInspector
]

{ #category : #running }
StDebuggerTest >> setUp [	
	super setUp.	
	session := StTestDebuggerProvider new sessionForDebuggerTests.
	oldFastTDD := self debuggerClass fastTDD.
	self debuggerClass fastTDD: true
]

{ #category : #running }
StDebuggerTest >> tearDown [

	session clear.
	self debuggerClass fastTDD: oldFastTDD.
	debugger ifNotNil: [ 
		debugger unsubscribeFromSystemAnnouncer.
		debugger close.
		debugger session ifNotNil: [ :s | s clear ] ].
	StTestDebuggerProvider removeSelector: #foobar. 
	StDebuggerObjectForTests compile: 'haltingMethod <haltOrBreakpointForTesting> self halt. ^self' classified: 'util'.
	super tearDown
]

{ #category : #'tests - code pane' }
StDebuggerTest >> testAcceptCodeChangesForContext [

	| dbg context newSource |
	dbg := StTestDebuggerProvider new debuggerWithObjectHalting.
	dbg
		application: dbg class currentApplication;
		initialize;
		buildContextMenus.
	context := dbg stackTable items first.
	newSource := 'haltingMethod ^1+1 squared'.	
	dbg code type: newSource.
	dbg code update.
	dbg unsavedCodeChanges at: 4 put: 2.
	
	dbg acceptCodeChanges: newSource forContext: context.
	self assertEmpty: dbg unsavedCodeChanges.
	self assert: dbg code text equals: newSource
]

{ #category : #'tests - code pane' }
StDebuggerTest >> testCancelCodeChangesFor [
	| dbg firstContext lastContext |
	dbg := self debuggerOn: session.
	dbg stepInto; stepInto.
	firstContext := dbg stackTable items first.	
	lastContext := dbg stackTable items last.		
	dbg code type: 'a'.
	dbg code update.
	dbg stackTable selectItem: lastContext.
	
	self assert: (dbg unsavedCodeChangesFor: firstContext) equals: 'a'.
	dbg stackTable selectItem: firstContext.
	
	dbg code triggerResetAction.
	self should: [ (dbg unsavedCodeChangesFor: firstContext) ] raise: KeyNotFound.
	self assert: dbg code text equals: firstContext sourceCode
	
	
]

{ #category : #'tests - code pane' }
StDebuggerTest >> testClearUnsavedChanges [

	| dbg |
	dbg := self debuggerOn: session.
	dbg unsavedCodeChanges at: 4 put: 2.
	dbg clearUnsavedCodeChanges.
	self assertEmpty: dbg unsavedCodeChanges
]

{ #category : #'tests - actions' }
StDebuggerTest >> testClose [
	|windowPresenter|
	windowPresenter := SpWindowPresenter new.
	windowPresenter windowIsOpening.
	debugger := (self debuggerOn: session).	
	windowPresenter presenter: debugger.	
	debugger initializeWindow: windowPresenter.
	
	"We trigger the closing from the presenter instead of the debugger itself,
	because the window is not really open so the debugger will not close through debugger close."
	windowPresenter windowClosed.	
	self deny: (SystemAnnouncer uniqueInstance hasSubscriber: debugger)
]

{ #category : #'tests - code pane' }
StDebuggerTest >> testCodeChangeAfterContextChange [
	| dbg firstContext lastContext |
	dbg := self debuggerOn: session.
	dbg stepInto; stepInto.
	firstContext := dbg stackTable items first.	
	lastContext := dbg stackTable items last.	
	
	self assert: dbg code text equals: firstContext sourceCode.
	dbg stackTable selectItem: lastContext.
	self assert: dbg code text equals: lastContext sourceCode.
	dbg stackTable selectItem: firstContext.
	self assert: dbg code text equals: firstContext sourceCode.
	
	self should: [ dbg unsavedCodeChangesFor:  firstContext] raise: KeyNotFound.	
	self should: [ dbg unsavedCodeChangesFor:  lastContext] raise: KeyNotFound
]

{ #category : #'tests - code pane' }
StDebuggerTest >> testCodeSelectionAfterRestart [

	| dbg adapter segments highlightSegment pcRangeForContext |
	dbg := self debuggerOn: session.
	adapter := SpMorphicCodeAdapter new.
	adapter adapt: dbg code.	
	dbg code adapter: adapter.
	dbg code adapter buildWidget.	
	dbg
		stepInto;
		stepInto.
	dbg restartCurrentContext.
	
	pcRangeForContext := (session pcRangeForContext: dbg currentContext).
	segments := dbg code adapter widget segments.
	self assert: segments size equals: 1.
	highlightSegment := segments first.	
	
	self
		assert:  (highlightSegment firstIndex to: highlightSegment lastIndex)
		equals: (pcRangeForContext first to: pcRangeForContext last + 1)
	"The pc range is highlighted with an additionnal index to encompass the full text of the node (why?)"
]

{ #category : #'tests - code pane' }
StDebuggerTest >> testCodeSelectionAfterStepping [

	| dbg adapter segments highlightSegment pcRangeForContext |
	dbg := self debuggerOn: session.
	adapter := SpMorphicCodeAdapter new.
	adapter adapt: dbg code.	
	dbg code adapter: adapter.
	dbg code adapter buildWidget.	
	dbg
		stepInto;
		stepInto.
	
	pcRangeForContext := (session pcRangeForContext: dbg currentContext).
	segments := dbg code adapter widget segments.
	self assert: segments size equals: 1.
	highlightSegment := segments first.	
	
	self
		assert:  (highlightSegment firstIndex to: highlightSegment lastIndex)
		equals: (pcRangeForContext first to: pcRangeForContext last + 1)
	"The pc range is highlighted with an additionnal index to encompass the full text of the node (why?)"
]

{ #category : #'tests - context inspector' }
StDebuggerTest >> testContextChangedAfterStepIn [ 
	| dbg |
	dbg := self debuggerOn: session.
	dbg buildContextMenus.	
	
	dbg stepInto. "We enter the block context"
	self assert: dbg inspector inspectedObject context identicalTo: session shortStack first.
	
	dbg stepInto. "We step into the first message"
	self assert: dbg inspector inspectedObject context identicalTo:session shortStack first.

]

{ #category : #'tests - context inspector' }
StDebuggerTest >> testContextChangedAfterStepOverAndReturn [
	| dbg currentContext |
	dbg := self debuggerOn: session.	
		
	dbg stepInto; stepInto. "getting into Number>>squared"
	currentContext := dbg inspector inspectedObject context.
	dbg stepOver; stepOver.  "stepping over ^self * self (i.e. returning)"
	self
		deny: dbg inspector inspectedObject context
		equals: currentContext
]

{ #category : #'tests - context inspector' }
StDebuggerTest >> testContextTempVarList [
	| dbg contextItems inspectorTable|
	dbg := self debuggerOn: session.
	inspectorTable := dbg inspector getRawInspectorPresenterOrNil attributeTable.
	
	5 timesRepeat: [ dbg stepInto  ].	
	contextItems := inspectorTable roots.
	self assert: contextItems size equals: 8. 	
		
	"First node is self"
	self assert: (contextItems at: 1) class equals: StInspectorSelfNode.	
	
	"Next nodes are temps"
	self assert: (contextItems at: 2) tempVariable isTempVariable.
	self assert: (contextItems at: 3) tempVariable isTempVariable.
	self assert: (contextItems at: 4) tempVariable isTempVariable.
	self assert: (contextItems at: 5) tempVariable isTempVariable.
	
	"receiver"	
	self assert: (contextItems at: 6) rawValue identicalTo: session shortStack first receiver session.
	
	"stackTop"
	self assert: (contextItems at: 7) rawValue equals: 1.
	
	"thisContext"
	self assert: contextItems last rawValue identicalTo: dbg currentContext
]

{ #category : #'tests - context inspector' }
StDebuggerTest >> testContextUnchangedAfterStepOver [
	| dbg currentContext |
	dbg := self debuggerOn: session.	
	
	dbg stepInto; stepInto. "getting into Number>>squared"
	currentContext := dbg inspector inspectedObject.
	"stepping over one time ^self * self (i.e. we are on the return node but still in the same context)"
	dbg stepOver. 
	self assert: dbg inspector inspectedObject identicalTo:  currentContext
]

{ #category : #'tests - actions' }
StDebuggerTest >> testCopyStackToClipboard [
	debugger := self debuggerOn: session.
	debugger copyStackToClipboard.
	self
		assert: Clipboard clipboardText string
		equals: (String streamContents: [ :s | 
				 session interruptedContext shortDebugStackOn: s ])
]

{ #category : #'tests - initialization' }
StDebuggerTest >> testDebuggerActionModel [
	"Checking that when initializing a debugger its action model is correctly set up.
	We cannot check that by calling the accessor because it is a lazy accessor. 
	We're using slot reflection instead."

	| slot debuggerActionModel |
	slot := StDebugger slotNamed: #debuggerActionModel.
	debugger := self debuggerOn: session.
	debuggerActionModel := slot read: debugger.

	self assert: debuggerActionModel notNil
]

{ #category : #'tests - initialization' }
StDebuggerTest >> testDebuggerApplication [
	self
		assert: (self debuggerOn: session) application
		identicalTo: StDebugger currentApplication
]

{ #category : #'tests - code pane' }
StDebuggerTest >> testDiscardCodeChangesFor [
	| dbg firstContext lastContext |
	dbg := self debuggerOn: session.
	dbg stepInto; stepInto.
	firstContext := dbg stackTable items first.	
	lastContext := dbg stackTable items last.		
	dbg code type: 'a'.
	dbg code update.
	dbg stackTable selectItem: lastContext.
	
	self assert: (dbg unsavedCodeChangesFor: firstContext) equals: 'a'.
	dbg stackTable selectItem: firstContext.
	
	dbg discardCodeChangesFor: firstContext.	
	self should: [ (dbg unsavedCodeChangesFor: firstContext) ] raise: KeyNotFound.
	self assert: dbg code text equals: firstContext sourceCode
	
	
]

{ #category : #'tests - initialization' }
StDebuggerTest >> testFastTDD [
	self debuggerClass fastTDD: nil.
	self deny: self debuggerClass fastTDD
]

{ #category : #'tests - code pane' }
StDebuggerTest >> testInitialCodeSelectionAfterStepping [

	| dbg adapter segments highlightSegment pcRangeForContext |
	dbg := self debuggerOn: session.
	adapter := SpMorphicCodeAdapter new.
	adapter adapt: dbg code.	
	dbg code adapter: adapter.
	dbg code adapter buildWidget.
	dbg stackTable selectItem: dbg stackTable items first.		
	
	pcRangeForContext := (session pcRangeForContext: dbg currentContext).
	segments := dbg code adapter widget segments.
	self assert: segments size equals: 1.
	highlightSegment := segments first.	
	
	self
		assert:  (highlightSegment firstIndex to: highlightSegment lastIndex)
		equals: (pcRangeForContext first to: pcRangeForContext last + 1)
	"The pc range is highlighted with an additionnal index to encompass the full text of the node (why?)"
]

{ #category : #'tests - context inspector' }
StDebuggerTest >> testNewDebuggerContext [
	|debuggerContext|
	debugger := (self debuggerOn: session).
	debuggerContext := debugger newDebuggerContext.
	self assert: debuggerContext class identicalTo: debugger class debuggerContextClass.
	self assert: debuggerContext exception equals: session exception
]

{ #category : #'tests - context inspector' }
StDebuggerTest >> testNewDebuggerContextFor [
	|debuggerContext ctx|
	debugger := (self debuggerOn: session).
	ctx := [  ] asContext.
	debuggerContext := debugger newDebuggerContextFor: ctx.
	self assert: debuggerContext class identicalTo: debugger class debuggerContextClass.
	self assert: debuggerContext exception equals: session exception.
	self assert: debuggerContext context identicalTo: ctx
]

{ #category : #'tests - stack table' }
StDebuggerTest >> testPrintReceiverClassInContext [
	|ctx result|
	ctx := Context sender: nil receiver: Set new method: (Collection>>#add:) arguments: Array new. 
	result := self debugger printReceiverClassInContext: ctx.
	self assert: result equals: 'Set (Collection)'.
	
	ctx := Context sender: nil receiver: Set new method: (Set>>#add:) arguments: Array new. 
	result := self debugger printReceiverClassInContext: ctx.
	self assert: result equals: 'Set'.
]

{ #category : #'tests - receiver inspector' }
StDebuggerTest >> testReceiverChangedAfterStepIn [ 
	| dbg |
	dbg := self debuggerOn: session.
	
	dbg stepInto. "We enter the block context"
	self assert: dbg inspector inspectedObject context receiver identicalTo: session shortStack first receiver.
	
	dbg stepInto. "We step into the first message"
	self assert: dbg inspector inspectedObject context receiver identicalTo: session shortStack first receiver.


]

{ #category : #'tests - receiver inspector' }
StDebuggerTest >> testReceiverChangedAfterStepOverAndReturn [
	| dbg currentReceiver |
	dbg := self debuggerOn: session.	
	
	dbg stepInto; stepInto. "getting into Number>>squared"
	currentReceiver := dbg inspector inspectedObject.
	dbg stepOver; stepOver. "stepping over ^self * self (i.e. returning)"
	self
		deny: dbg inspector inspectedObject
		equals: currentReceiver
]

{ #category : #'tests - receiver inspector' }
StDebuggerTest >> testReceiverList [
	| dbg currentReceiver |
	dbg := self debuggerOn: session.	
	
	dbg stepInto; stepInto. "getting into Number>>squared"
	currentReceiver := dbg inspector inspectedObject context receiver.	
	self assert: currentReceiver equals: 1

]

{ #category : #'tests - receiver inspector' }
StDebuggerTest >> testReceiverUnchangedAfterStepOver [ 
	| dbg currentReceiver |
	dbg := self debuggerOn: session.	
	
	dbg stepInto; stepInto. "getting into Number>>squared"
	currentReceiver := dbg inspector inspectedObject context receiver.
	"stepping over one time ^self * self (i.e. we are on the return node but still in the same context)"
	dbg stepOver. 
	self assert: dbg inspector inspectedObject context receiver identicalTo:  currentReceiver

]

{ #category : #'tests - code pane' }
StDebuggerTest >> testRecordUnsavedCodeChanges [
	| dbg lastContext |
	dbg := self debuggerOn: session.
	dbg stepInto; stepInto.
	lastContext := dbg stackTable items last.		
	dbg code type: 'a'.
	dbg code update.
	
	self assert: dbg code text equals: 'a'.
	self deny: dbg selectedContext sourceCode equals: dbg code text.

	dbg stackTable selectItem: lastContext.
	self assert: dbg code text equals: lastContext sourceCode.
	self assert: (dbg unsavedCodeChangesFor: dbg stackTable items first) equals: 'a'
]

{ #category : #'tests - actions' }
StDebuggerTest >> testRequestClassFrom [

	self
		assert: (self debugger requestClassFrom: self class)
		identicalTo: self class
]

{ #category : #'tests - actions' }
StDebuggerTest >> testRequestProtocolIn [

	self
		assert: (self debugger requestProtocolIn: self class)
		equals: Protocol unclassified
]

{ #category : #'tests - session' }
StDebuggerTest >> testRestartContext [

	| dbg firstContext lastContext |
	dbg := self debuggerOn: session.
	dbg stepInto; stepInto.
	firstContext := dbg stackTable items first.	
	lastContext := dbg stackTable items last.
		
	"We select the last context and we change the code but we do not save.
	The unsaved code change is kept when we select another context (the first one)"	
	dbg stackTable selectItem: lastContext.	
	dbg code type: 'a'.
	dbg code update.	
	dbg stackTable selectItem: firstContext.	
	self assert: (dbg unsavedCodeChangesFor: lastContext) equals: 'a'.	
		
	"We select again the last context and restart it:
	- unsaved code changes are dropped
	- the restarted context is now the first context of the stack
	- the code is reset to the source of the restarted context"	
	dbg stackTable selectItem: lastContext.				
	dbg restartCurrentContext. 	
	self assertEmpty: dbg unsavedCodeChanges.
	self assert: dbg code text equals: lastContext sourceCode.
	self assert: dbg stackTable items first equals: lastContext
	
	

]

{ #category : #'tests - raw inspection' }
StDebuggerTest >> testRestoreReceiverRawInspectionSelection [
	self skip.
	self flag: #DBG_TEST
]

{ #category : #'tests - raw inspection' }
StDebuggerTest >> testRestoreReceiverRawInspectionSelectionAfterContextChange [

	self skip.
	self flag: #DBG_TEST
]

{ #category : #'tests - code pane' }
StDebuggerTest >> testRestoreUnsavedCodeChanges [
	| dbg firstContext lastContext |
	dbg := self debuggerOn: session.
	dbg stepInto; stepInto.
	firstContext := dbg stackTable items first.
	lastContext := dbg stackTable items last.
	
	self assert: dbg code text equals: firstContext sourceCode.
	dbg code type: 'a'.
	dbg update.
	
	dbg stackTable selectItem: lastContext.
	self assert: dbg code text equals: lastContext sourceCode.
	
	dbg stackTable selectItem: firstContext.
	self assert: dbg code text equals: 'a'
]

{ #category : #'tests - session' }
StDebuggerTest >> testReturnEnteredValue [
	self skip.
	self flag: #DBG_TEST
]

{ #category : #'tests - code pane' }
StDebuggerTest >> testSaveCodeModification [
	| dbg context newSource |
	dbg := StTestDebuggerProvider new debuggerWithObjectHalting.
	dbg
		application: dbg class currentApplication;
		initialize;
		buildContextMenus.
	context := dbg stackTable items first.
	newSource := 'haltingMethod ^1+1 squared'.	
	dbg code type: newSource.
	dbg code update.
	dbg unsavedCodeChanges at: 4 put: 2.
	
	dbg code triggerSubmitAction.	
	self assertEmpty: dbg unsavedCodeChanges.
	self assert: context sourceCode equals: newSource.
	self assert: dbg code text equals: context sourceCode
	
	

]

{ #category : #'tests - raw inspection' }
StDebuggerTest >> testSaveReceiverRawInspectionSelection [

	self skip.
	self flag: #DBG_TEST
]

{ #category : #'tests - raw inspection' }
StDebuggerTest >> testSaveReceiverRawInspectionSelectionAfterContextChange [

	self skip.
	self flag: #DBG_TEST
]

{ #category : #'tests - stack table' }
StDebuggerTest >> testSelectLastStackElementWithMoreElements [
	| dbg stackTable selectedItem |
	dbg := self debuggerOn: session.
	stackTable := dbg stackTable.
	
	dbg stepInto; stepInto.
	stackTable items: (session stackOfSize: 1).
	
	self assert: stackTable items size equals: 1.
	self assert: stackTable items last equals: session stack first.	
		
	"As we select the last element of the stack table, 
	it should expand the size of the displayed stack"
	selectedItem := stackTable items last.
	stackTable selectItem: selectedItem.
	self assert: stackTable items size equals: session stack size.
	self assert: stackTable items equals: session stack.
	self assert: stackTable selection selectedItem identicalTo: selectedItem

	
]

{ #category : #'tests - stack table' }
StDebuggerTest >> testSelectLastStackElementWithoutMoreElements [
	| dbg stackTable startingStackSize |
	dbg := self debuggerOn: session.
	stackTable := dbg stackTable.
	startingStackSize := stackTable items size.
	stackTable selectItem: stackTable items last.
	
	self assert: stackTable items size equals: startingStackSize
]

{ #category : #'tests - stack table' }
StDebuggerTest >> testStackTableAfterReturn [
	| dbg stackTableItems stackSizeAfterStepIn |
	dbg := self debuggerOn: session.

	"we dive into a method"
	dbg stepInto; stepInto.
	stackSizeAfterStepIn := dbg stackTable items size.

	"we return from it"
	dbg stepOver; stepOver.
	stackTableItems := dbg stackTable items.
	self assert: dbg stackTable selection selectedIndex equals: 1.
	self assert: dbg stackTable selection selectedItem identicalTo: session shortStack first.
	self assert: stackTableItems size equals: stackSizeAfterStepIn - 1.
	self assert: stackTableItems equals: session shortStack
]

{ #category : #'tests - stack table' }
StDebuggerTest >> testStackTableAfterStepIn [
	| dbg stackTableItems startingStackSize |
	dbg := self debuggerOn: session.
	startingStackSize := dbg stackTable items size.
	dbg stepInto; stepInto.
	stackTableItems := dbg stackTable items.
	self assert: dbg stackTable selection selectedIndex equals: 1.
	self
		assert: dbg stackTable selection selectedItem identicalTo: session shortStack first.
	self assert: stackTableItems size equals: startingStackSize + 1.
	self assert: stackTableItems equals: session shortStack
]

{ #category : #'tests - stack table' }
StDebuggerTest >> testStackTableElementsPrinting [
	| columns classColumn methodColumn method block context |
	self debugger session: session.
	columns := self initializedDebugger stackTable columns.
	classColumn := columns second.
	methodColumn := columns third.
	"The following column was removed to experiment a new layout, just keeping the test in case of roolback."
	"senderColumn := columns third."
	method := self class >> #testStackTableElementsPrinting.
	block := [ :a | a ].
	
	context := (Context newForMethod: method) setSender: self receiver: self method: method arguments: #(  ).
	self assert: (classColumn evaluation value: context) equals: self class name.
	self assert: (methodColumn evaluation value: context) equals: method selector.
	"The following column was removed to experiment a new layout, just keeping the test in case of roolback."
	"self assert: (senderColumn evaluation value: context) equals: self stDisplayString."
	
	context := (Context newForMethod: method) setSender: self receiver: self method: block method arguments: #(  ).
	self assert: (classColumn evaluation value: context) equals: self class name.
	self assert: (methodColumn evaluation value: context) equals: block sourceNode sourceCode.
	"The following column was removed to experiment a new layout, just keeping the test in case of roolback."
	"self assert: (senderColumn evaluation value: context) equals: self stDisplayString."
]

{ #category : #'tests - stack table' }
StDebuggerTest >> testStackTableInitialization [
	self assert: self debugger stackTable isNil
]

{ #category : #'tests - stack table' }
StDebuggerTest >> testStackTablePackagesLabels [
	|stackTable packageColumn ctx|
	self debugger session: session.
	stackTable := self initializedDebugger stackTable.
	packageColumn := stackTable columns last.
	
	"The method is defined in the same package as its class"
	ctx := Context
		sender: nil
		receiver: nil
		method: (StTestDebuggerProvider >> #debuggerWithDNUContext)
		arguments: #().
	self assert: (packageColumn readObject: ctx) equals: StTestDebuggerProvider package name.
	
	"The extension method is defined in another package than its class"
	ctx := Context
		sender: nil
		receiver: nil
		method: (StDebugger >> #inspector)
		arguments: #().
	self assert: (packageColumn readObject: ctx) equals: StTestDebuggerProvider package name.
	
	"Doit methods have no package."
	ctx := Context
		sender: nil
		receiver: nil
		method: (Smalltalk compiler compile: 'doIt 1 + 1')
		arguments: #().
	self assert: (packageColumn readObject: ctx) equals: '-'
	

]

{ #category : #'tests - stack table' }
StDebuggerTest >> testStackTableSelectionChanged [
	| dbg |
	dbg := self debuggerOn: session.
	dbg stepInto; stepInto.
	dbg stackTable selectItem: dbg stackTable items second.
	self
		assert:
			dbg inspector inspectedObject context
				identicalTo: dbg stackTable selection selectedItem.
	self
		assert:
			dbg inspector inspectedObject context receiver
				identicalTo: dbg stackTable selection selectedItem receiver.
	self
		assert: dbg code text
		equals: dbg stackTable items second sourceCode
]

{ #category : #'tests - stack table' }
StDebuggerTest >> testStackTableWithNewSession [
	self debugger session: session.
	self
		assert: (self initializedDebugger stackTable) items
		equals: session shortStack.
	self
		assert: self debugger stackTable selection selectedIndex
		equals: 1.
	self
		assert:
			self debugger stackTable selection selectedItem
				identicalTo: session shortStack first
]

{ #category : #'tests - toolbar' }
StDebuggerTest >> testToolbarDisplayMode [
	debugger := self debuggerOn: session.
	self
		assert: debugger toolbar displayMode
		equals: debugger application toolbarDisplayMode
]

{ #category : #'tests - toolbar' }
StDebuggerTest >> testToolbarInDNUContext [
	|commands|
	session clear.
	session := StTestDebuggerProvider new sessionWithDNUAfterStep.

	self debuggerOn: session.
	"debugger buildContextMenus.	"
	commands := self executionControlCommandFrom: debugger.	

	"We're not in a DNU, buttons are enabled"
	commands do: [ :c| self assert: c isEnabled].
	
	"We step into the DNU, buttons should be disabled"
	debugger stepInto.
	debugger stepOver.

	commands do: [ :c| self deny: c isEnabled].

	"We define the missing method from outside the debugger, buttons should automatically be enabled"
	StTestDebuggerProvider compile: 'foobar ^self'.
	commands do: [ :c| self assert: c isEnabled].
	
	
]

{ #category : #'tests - code pane' }
StDebuggerTest >> testUnsavedCodeChanges [
	| dbg |
	dbg := self debuggerOn: session.
	self assert: dbg unsavedCodeChanges class identicalTo: IdentityDictionary.
	self assertEmpty: dbg unsavedCodeChanges 
]

{ #category : #'tests - code pane' }
StDebuggerTest >> testUnsavedCodeChangesFor [
	| dbg ctx codeChanges |
	dbg := self debuggerOn: session.
	self should: [dbg unsavedCodeChangesFor: dbg currentContext] raise: KeyNotFound.
	dbg unsavedCodeChanges at: (ctx := Object new) put: (codeChanges := Object new).
	self assert: (dbg unsavedCodeChangesFor: ctx) identicalTo: codeChanges
	

]

{ #category : #'tests - receiver inspector' }
StDebuggerTest >> testUpdateLayoutForContextsIfAssertionFailure [
	| assertionFailure currentLayout expectedLayout |
	debugger := StTestDebuggerProvider new
		            debuggerWithFailingAssertionContext.
	session := debugger session.
	debugger application: StDebugger currentApplication.
	debugger initialize.
	debugger updateInspectorFromContext: session interruptedContext.
	assertionFailure := debugger inspector assertionFailure.
	currentLayout := debugger inspector layout.
	expectedLayout := StDebuggerInspector assertionFailureSpec.
	StDebuggerInspector maximizeAssertionSpec: false.
	self assert: currentLayout direction equals: expectedLayout direction.
	self
		assertCollection: currentLayout children first class
		equals: expectedLayout children first class.
	self
		assertCollection: currentLayout children first direction
		equals: expectedLayout children first direction.
	self
		assertCollection: currentLayout children second 
		equals: expectedLayout children second.
	self assert: currentLayout position equals: expectedLayout position.
	self
		assert: currentLayout children size
		equals: expectedLayout children size.
	self
		assert: assertionFailure actualObject
		equals:
		((session interruptedContext tempNamed: #aStringOrBlock) at: 2).
	self
		assert: assertionFailure expectedObject
		equals:
		((session interruptedContext tempNamed: #aStringOrBlock) at: 1)
]

{ #category : #'tests - code pane' }
StDebuggerTest >> testUpdateSourceCodeFor [

	| dbg |
	dbg := self debuggerOn: session.
	dbg unsavedCodeChanges at: 4 put: '2'.
	
	dbg updateSourceCodeFor: 4.
	self assert: dbg code text equals: '2'.
	
	dbg updateSourceCodeFor: (self class>>#testUpdateSourceCodeFor).
	self assert: dbg code text equals: (self class>>#testUpdateSourceCodeFor) sourceCode.
]
