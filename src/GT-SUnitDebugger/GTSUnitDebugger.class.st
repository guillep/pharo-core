"
I am a custom debugger for SUnit.
I embed a textual diff when an #assert:equals: assertion fails and provide access to the setUp/tearDown methods of a test.

"
Class {
	#name : #GTSUnitDebugger,
	#superclass : #GTGenericStackDebugger,
	#category : #'GT-SUnitDebugger'
}

{ #category : #accessing }
GTSUnitDebugger class >> defaultDebuggerRank [

	^ 8
]

{ #category : #accessing }
GTSUnitDebugger class >> defaultTitle [

	^ 'SUnit'
]

{ #category : #testing }
GTSUnitDebugger class >> handlesContext: aContext [
	| activationPredicate |
	activationPredicate := self sessionClass activationPredicate.
	^ (aContext stackOfSize: self lookupStackSize) 
		anySatisfy: [ :ctx | activationPredicate matches: ctx ] 
]

{ #category : #testing }
GTSUnitDebugger class >> lookupStackSize [
	^ 512
]

{ #category : #accessing }
GTSUnitDebugger class >> sessionClass [

	^ GTSUnitDebugSession
]

{ #category : #'accessing context' }
GTSUnitDebugger >> contextToSelectFrom: aSession [
	^ aSession assertionCallerContext ifNil: [ aSession testContext ]
]

{ #category : #'building presentations' }
GTSUnitDebugger >> inspectorDiffIn: aComposite [

	^ aComposite tabulator 
		with: [ :aTabulator |
			aTabulator when: [ self session supportsDiff].
			aTabulator 
				column: #actual;
				column: #expected.
			aTabulator transmit to: #actual; andShow: [ :anotherComposite |
				anotherComposite  dynamic 
					display: [:anObject |
				 		(GTDebuggerInspector new 
							startOn: self session actualResult) ] ].
			aTabulator transmit to: #expected; andShow: [ :anotherComposite |
				anotherComposite  dynamic 
					display: [:anObject |
				 		(GTDebuggerInspector new 
							startOn: self session expectedResult) ] ] ]
]

{ #category : #'building presentations' }
GTSUnitDebugger >> inspectorIn: aComposite [

	(self textualDiffIn: aComposite) title: 'Diff (actual vs. expected)'.
	(self inspectorDiffIn: aComposite) title: 'Objects (actual vs. expected)'.
	super inspectorIn: aComposite.
	self session supportsDiff ifTrue: [ 
		aComposite last title: 'Inspector' ]
]

{ #category : #'building presentations' }
GTSUnitDebugger >> setUpCodeIn: aComposite [

	aComposite pharoMethod
		title: [ self setUpPresentationTitle ];
		format: [ self session setUpMethod sourceCode ];
		smalltalkClass: [  self session testObject class ];
		when: [ self session overridesDefaultSetUpMethod ];
		doItReceiver: [ self session testObject ].
]

{ #category : #'accessing context' }
GTSUnitDebugger >> setUpPresentationTitle [

	^ 'SetUp', 
		(self session setUpMethod methodClass ~= self session testContext methodClass
			ifTrue: [ ' (', self session setUpMethod methodClass name,')' ]
			ifFalse: [ '' ])
]

{ #category : #'building presentations' }
GTSUnitDebugger >> tearDownCodeIn: aComposite [

	aComposite pharoMethod
		title: [ self tearDownPresentationTitle ];
		format: [ self session tearDownMethod sourceCode ];
		smalltalkClass: [  self session testObject class ];
		when: [ self session overridesDefaultTearDownMethod ];
		doItReceiver: [ self session testObject ].
]

{ #category : #'accessing context' }
GTSUnitDebugger >> tearDownPresentationTitle [

	^ 'TearDown', 
		(self session tearDownMethod methodClass ~= self session testContext methodClass
			ifTrue: [ ' (', self session tearDownMethod methodClass name,')' ]
			ifFalse: [ '' ])
]

{ #category : #'building presentations' }
GTSUnitDebugger >> textualDiffIn: composite [

	^ composite diff
			when: [ self session supportsDiff];
			display: [ 
				{self session actualResult gtDebuggerSUnitPrint. self session expectedResult gtDebuggerSUnitPrint} ]
]

{ #category : #building }
GTSUnitDebugger >> transmitFromStackToCodeIn: browser [
	browser transmit
		from: #stack port: #selection;
		to: #code;
		andShow: [ :composite :aContext | 
			self methodCodeIn: composite forContext: aContext.
			self setUpCodeIn: composite.
			self tearDownCodeIn: composite ]
]

{ #category : #updating }
GTSUnitDebugger >> updateBrowser [

	super updateBrowser.
	"The transmission will select the context of the test case. 
	This should only happen the first time.
	Should find another solution so this method doesn;t have to be overridden"
	((self browser paneNamed: #stack) port: #selection) value: self session interruptedContext
]
