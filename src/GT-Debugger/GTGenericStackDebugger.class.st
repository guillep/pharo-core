"
I am a browser that provides Smalltalk debugging functionality.
 
"
Class {
	#name : #GTGenericStackDebugger,
	#superclass : #GTMoldableDebugger,
	#traits : 'TDebugger',
	#classTraits : 'TDebugger classTrait',
	#instVars : [
		'cache'
	],
	#classVars : [
		'FilterCommonMessageSends',
		'LogDebuggerStackToFile',
		'LogFileName'
	],
	#category : #'GT-Debugger-UI'
}

{ #category : #'utilities api' }
GTGenericStackDebugger class >> closeAllDebuggers [
	"GTGenericStackDebugger closeAllDebuggers"

	(SystemWindow allSubInstances select: [ :w | w model isKindOf: GTGenericStackDebugger ]) do: [ :w | w delete ].
	GTSpecPreDebugPresenter allInstances do: #close
]

{ #category : #'instance creation' }
GTGenericStackDebugger class >> debugSession: aDebugSession [
	| debugger |
   debugger := self on: (self spanNewSessionFrom: aDebugSession).
   debugger openWithFullView
]

{ #category : #accessing }
GTGenericStackDebugger class >> defaultDebuggerRank [

	^ 3
]

{ #category : #'settings api' }
GTGenericStackDebugger class >> defaultLogFileName [
	^ 'PharoDebug.log'
]

{ #category : #accessing }
GTGenericStackDebugger class >> defaultTitle [
	^ 'GT'
]

{ #category : #'settings api' }
GTGenericStackDebugger class >> filterCommonMessageSends [
	self flag: 'horrible hack not to break the setting browser'.
	^ false
]

{ #category : #'settings api' }
GTGenericStackDebugger class >> filterCommonMessageSends: aBoolean [
	FilterCommonMessageSends := aBoolean
]

{ #category : #'settings api' }
GTGenericStackDebugger class >> filterDoItSelectors [
	^ false
]

{ #category : #'accessing - ancient preference selectors' }
GTGenericStackDebugger class >> filterDoItSelectors: aBoolean [
	self flag: 'just for backward compatibility'
]

{ #category : #'settings api' }
GTGenericStackDebugger class >> filterKernelClasses [
	^ false
]

{ #category : #'accessing - ancient preference selectors' }
GTGenericStackDebugger class >> filterKernelClasses: aBoolean [
	self flag: 'just for backward compatibility'
]

{ #category : #'settings api' }
GTGenericStackDebugger class >> filterLinkSelectors [
	^ false
]

{ #category : #'accessing - ancient preference selectors' }
GTGenericStackDebugger class >> filterLinkSelectors: aBoolean [ 
	self flag: 'just for backward compatibility'
]

{ #category : #'settings api' }
GTGenericStackDebugger class >> filterNilSelectors [
	^ false
]

{ #category : #'accessing - ancient preference selectors' }
GTGenericStackDebugger class >> filterNilSelectors: aBoolean [ 
	self flag: 'just for backward compatibility'
]

{ #category : #'settings api' }
GTGenericStackDebugger class >> logDebuggerStackToFile [
	^ LogDebuggerStackToFile ifNil: [LogDebuggerStackToFile := true]
]

{ #category : #'settings api' }
GTGenericStackDebugger class >> logDebuggerStackToFile: aBoolean [
	 LogDebuggerStackToFile := aBoolean
]

{ #category : #'settings api' }
GTGenericStackDebugger class >> logFileName [
	^ LogFileName ifNil: [ self defaultLogFileName ] 
]

{ #category : #'settings api' }
GTGenericStackDebugger class >> logFileName: newName [
	LogFileName := newName
]

{ #category : #accessing }
GTGenericStackDebugger class >> sessionClass [

	^ DebugSession 
]

{ #category : #accessing }
GTGenericStackDebugger class >> variablesBrowserClass [

	^ GTDebuggerVariablesBrowser
]

{ #category : #callbacks }
GTGenericStackDebugger >> actOnInspectorPaneRemoved: ann [ 

	ann browser panes size == 1 ifTrue: [ 
		self selectedVariableName: nil ]
]

{ #category : #accessing }
GTGenericStackDebugger >> cache [
	^ cache ifNil: [ cache := Dictionary new ]
]

{ #category : #'building actions' }
GTGenericStackDebugger >> codeActionsPragmas [

	^ #( codeDebuggingAction )
]

{ #category : #accessing }
GTGenericStackDebugger >> codePane [

	^ self browser paneNamed: #code
]

{ #category : #accessing }
GTGenericStackDebugger >> codePresentation [
	
	^ self codePane presentations first
]

{ #category : #building }
GTGenericStackDebugger >> debuggerStructureIn: browser [
	
	browser
		row: #stack;
		row: #code span: 2;
		row: #inspector.
		
]

{ #category : #building }
GTGenericStackDebugger >> debuggerTransmissionsIn: browser [

	browser transmit
		fromOutsideEntityPort;
		to: #stack;
		andShow: [ :composite | self stackIn: composite ].
	browser transmit
		from: #stack port: #entity;
		to: #stack port: #selection;
		when: [ :session | session notNil ];
		transformed: [:session | self contextToSelectFrom: session ].
	browser transmit "need a method call when the selection is changed"
		from: #stack port: #selection;
		to: #stack port: #action;
		transformed: [ :context | 
			self selectionChanged: context ].
	self transmitFromStackToCodeIn: browser.
	browser transmit
		from: #stack port: #selection;
		to: #inspector;
		andShow: [ :composite | self inspectorIn: composite ] 

]

{ #category : #'building actions' }
GTGenericStackDebugger >> debuggingActionsPragmas [

	^ #( debuggingAction )
]

{ #category : #opening }
GTGenericStackDebugger >> filteredStack [

	^ (self session stackOfSize: 50 ) select: [ :aContext | (aContext method hasPragmaNamed: #debuggerCompleteToSender) not ]
]

{ #category : #'printing/formatting' }
GTGenericStackDebugger >> formatMethodPackageForContext: aContext [ 

	^ Text 
		string: (aContext method package 
			ifNil: ['-'] 
			ifNotNil: [ :aPackage | aPackage name  ])
		attributes: (self textAttributesForStackEntry: aContext) 
]

{ #category : #'printing/formatting' }
GTGenericStackDebugger >> formatStackClassColumnForContext: aContext [

	^ Text 
		string: (self printStackClassColumnForContext: aContext )
		attributes: (self textAttributesForStackEntry: aContext) 
	 
]

{ #category : #'printing/formatting' }
GTGenericStackDebugger >> formatStackExtraColumnForContext: aContext [ 

	^ Text 
		string: (self printStackExtraColumnForContext: aContext )
		attributes: (self textAttributesForStackEntry: aContext) 
]

{ #category : #'printing/formatting' }
GTGenericStackDebugger >> formatStackMethodColumnForContext: aContext [ 

	^ Text 
		string: (self printStackMethodColumnForContext: aContext )
		attributes: (self textAttributesForStackEntry: aContext) 
]

{ #category : #actions }
GTGenericStackDebugger >> inspect: anObject [

	"Use silentValue: instead of value: as just using value: causes the current inspector to refresh the content of it current presentations without rebuiling them (the dynamic presentation contained by the inspector does not rebuild its content)"
	((self browser paneNamed: #inspector) port: #entity) silentValue: anObject.
	
	(self browser paneNamed: #inspector) update.
	
]

{ #category : #'building presentations' }
GTGenericStackDebugger >> inspectorIn: aComposite [

	^ aComposite dynamic 
		display: [:anObject |
			self inspectorIn: GLMCompositePresentation new on: anObject ]
]

{ #category : #'building presentations' }
GTGenericStackDebugger >> inspectorIn: aComposite on: anObject [
				
	^ anObject gtConstructDebuggerInspectorIn: aComposite for: self
	
	
]

{ #category : #'building presentations' }
GTGenericStackDebugger >> installBindingsForDoItIn: aPresentation from: aContext [

	(aContext notNil and: [aContext method isDoIt and: [ aContext receiver isNil ] ]) ifTrue: [
		aPresentation variableBindings: aContext gtDebuggerDoItBindings ]

	
]

{ #category : #'building actions' }
GTGenericStackDebugger >> installCodeActionsFor: aPresentation [
	
	self installActionsForRootPragmas: self codeActionsPragmas in: aPresentation
]

{ #category : #'building actions' }
GTGenericStackDebugger >> installDebuggingActionsFor: aPresentation [

	self installActionsForRootPragmas: self debuggingActionsPragmas in: aPresentation
]

{ #category : #'building actions' }
GTGenericStackDebugger >> installStackDebuggingActionsFor: aPresentation [

	self 
		installActionsForRootPragmas: self stackDebuggingActionsPragmas 
		in: aPresentation
]

{ #category : #'building presentations' }
GTGenericStackDebugger >> methodCodeIn: composite forContext: aContext [

	(self methodCodeWidgetIn: composite forContext: aContext)
		initialize: [ :code | 
			code selectionInterval: (self session selectedCodeRangeForContext: self currentContext) ];
		with: [ :code | 
			self installCodeActionsFor: code ]
]

{ #category : #'building presentations' }
GTGenericStackDebugger >> methodCodeWidgetIn: composite forContext: aContext [

	^ composite pharoMethod
		title: 'Source';
		format: [ aContext sourceCode ];
		smalltalkClass: [  aContext methodClass ];
		doItReceiver: [ aContext receiver ];
		doItContext: [  aContext ];
		with: [ :codePresentation | 
			self installBindingsForDoItIn: codePresentation from: aContext ]
]

{ #category : #opening }
GTGenericStackDebugger >> openWithFullView [
	"Create and schedule a full debugger with the given label. Do not terminate the current active process.
	
	We also select the first non filtered context, this mean that we will ignore some methods like halts or debug method to select the first interesting line in the debugger."

	self setDebuggerToFirstNonFilteredContext.
	self open
]

{ #category : #opening }
GTGenericStackDebugger >> openWithNotification: notificationString [
	"Create and schedule a notifier view with the given label and message.
	A notifier view shows just the message or the first several lines of the
	stack, with a menu that allows the user to open a full debugger if so
	desired. "

	"NOTE: When this method returns, a new process has been scheduled to
	run the windows, and thus this notifier, but the previous active porcess
	has not been suspended. The sender will do this."

	(GTSpecPreDebugPresenter on: self)
		message: notificationString;
		openWithSpec;
		setTitle: self title
]

{ #category : #'printing/formatting' }
GTGenericStackDebugger >> printStackClassColumnForContext: aContext [
	| outer class methodClass |
	
	outer := aContext outerMostContext.
	^ String streamContents: [ :aStream |
		class := outer receiver class.
		aStream nextPutAll: class name.
		methodClass := outer methodClass.
		methodClass == class
			ifFalse:
				[ aStream 
						nextPut: $(;
						nextPutAll: methodClass name;
						nextPut: $) ] ]  
]

{ #category : #'printing/formatting' }
GTGenericStackDebugger >> printStackExtraColumnForContext: aContext [ 

	| selector |
	^ aContext outerContext 
		ifNil: [ 
			String streamContents: [ :aStream |
				selector := aContext selector ifNil: [ aContext method defaultSelector ].
				selector = #doesNotUnderstand:
					ifTrue:[ 
						aStream space.
						(aContext tempAt: 1) selector printOn: aStream ]
					ifFalse: [ '' ] ] ]
		ifNotNil: [ aContext closure printString  ]
]

{ #category : #'printing/formatting' }
GTGenericStackDebugger >> printStackMethodColumnForContext: aContext [ 
	| outer selector |
	
	outer := aContext outerMostContext.
	^ String streamContents: [ :aStream |
		selector := outer selector ifNil: [ outer method defaultSelector ].
		aStream nextPutAll: selector ]
]

{ #category : #'building presentations' }
GTGenericStackDebugger >> retrieveStackFrom: aSession [

	^ aSession stack
		
]

{ #category : #updating }
GTGenericStackDebugger >> selectTopContext [
	((self browser paneNamed: #stack) port: #selection) value: self interruptedContext
]

{ #category : #'accessing context' }
GTGenericStackDebugger >> selectedContext [

	^ ((self browser paneNamed: #stack) port: #selection) value
]

{ #category : #accessing }
GTGenericStackDebugger >> selectedText [

	^ (self codePane port: #selectedText) value
]

{ #category : #accessing }
GTGenericStackDebugger >> selectedVariableName [
	^ self cache at: #selectedVariableName ifAbsent: [ nil ]
]

{ #category : #accessing }
GTGenericStackDebugger >> selectedVariableName: anObject [
	self cache at: #selectedVariableName put: anObject
]

{ #category : #updating }
GTGenericStackDebugger >> selectionChanged: aContext [

	aContext isNotNil ifTrue: [ self announce: (GTGenericStackDebuggerSelectionChanged forDebugger: self) ].

	UIManager default defer: [ 
		self session ifNotNil: [
			(self browser paneNamed: #stack) presentations updateToolbar ] ].
	
	self class enableStackColoring ifFalse: [ ^ self ].  

	UIManager default defer: [
		(self browser paneNamed: #stack) presentations presentations ifNotEmpty: [ :p | 
			self session interruptedProcess ifNotNil: [ p first update ] ] ]
]

{ #category : #accessing }
GTGenericStackDebugger >> selectionInterval [

	^ self selectionIntervalForPane: #code
]

{ #category : #accessing }
GTGenericStackDebugger >> selectionInterval: anInterval [

	^ ((self browser paneNamed: #code) port: #selectionInterval) value: anInterval
]

{ #category : #accessing }
GTGenericStackDebugger >> selectionIntervalForPane: aSymbol [

	^ ((self browser paneNamed: aSymbol) port: #selectionInterval) value ifNil: [ ^ 1 to: 0 ]
]

{ #category : #'old api' }
GTGenericStackDebugger >> send [
	
	self session stepInto: self currentContext.
	self updateBrowser.

]

{ #category : #opening }
GTGenericStackDebugger >> setDebuggerToFirstNonFilteredContext [
	"I set the debugger to the first non filtered stack"

	| selection |
	selection := self stackPresentation selection.
	(selection isNil or: [ selection method hasPragmaNamed: #debuggerCompleteToSender ])
		ifTrue: [
			  self filteredStack ifNotEmpty: [ :stack | self stackPresentation selection: stack first ]]
]

{ #category : #accessing }
GTGenericStackDebugger >> sourceCode: aString [

	^ ((self browser paneNamed: #code) port: #text) value: aString
]

{ #category : #'building actions' }
GTGenericStackDebugger >> stackDebuggingActionsPragmas [

	^ #( stackDebuggingAction )

]

{ #category : #'building presentations' }
GTGenericStackDebugger >> stackIn: composite [

	^ (self stackWidgetIn: composite)
		with: [ :stackWidget | self installStackDebuggingActionsFor: stackWidget ]
]

{ #category : #accessing }
GTGenericStackDebugger >> stackPresentation [
	
	^ (self browser paneNamed: #stack) presentations first
]

{ #category : #'building presentations' }
GTGenericStackDebugger >> stackWidgetIn: composite [

	^ composite fastTable	
		title: 'Stack';
		useCache;
		display: [:aSession | self retrieveStackFrom: aSession];
		column: 'Class' 
			evaluated: [ :aContext | self formatStackClassColumnForContext: aContext]
			width: 300;
		column: 'Method' 
			evaluated: [ :aContext | self formatStackMethodColumnForContext: aContext ];
		column: 'Other' 
			evaluated: [ :aContext | self formatStackExtraColumnForContext: aContext ];
		column: 'Package' 
			evaluated: [ :aContext | self formatMethodPackageForContext: aContext ]
]

{ #category : #'printing/formatting' }
GTGenericStackDebugger >> textAttributesForStackEntry: aContext [

	(self selectedContext isNil or: self class enableStackColoring not) 
		ifTrue: [ ^ {TextColor color: self theme textColor} ].

	^ self theme styleContext: aContext from: self.
]

{ #category : #'printing/formatting' }
GTGenericStackDebugger >> theme [ 
	^ Smalltalk ui theme
]

{ #category : #building }
GTGenericStackDebugger >> transmitFromStackToCodeIn: browser [
	browser transmit
		from: #stack port: #selection;
		to: #code;
		andShow: [ :composite :aContext | self methodCodeIn: composite forContext: aContext ]
]

{ #category : #updating }
GTGenericStackDebugger >> updateCodeEditor [
	self codePane update.
	self updateSelectionInterval.
]

{ #category : #updating }
GTGenericStackDebugger >> updateSelectionInterval [

	self selectedContext ifNil: [ ^ self ].
	self selectionInterval: (self session selectedCodeRangeForContext:  self selectedContext )
]
