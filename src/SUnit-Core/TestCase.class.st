"
`TestCase` instances are created with the class method `TestCase class>>#selector:`, passing the symbol that names the method to be executed when the test case runs.  TestCase instances are then executed using the method `TestCase>>#run`. Now usually you do not execute your tests that primitive way
but tests are grouped in `TestSuite` (a.k.a. a composite of TestCase) and run using a test runner.
Various UIs exist to run these instances and they can also be created and run programmatically.

Each method of a `TestCase` subclass starting with 'test' acts an executable test. When you create a subclass of `TestCase`, the framework automatically builds a test suite from the test methods of such class. 
The methods `setUp` and `tearDown` are always executed before and after the execution of a test method. You use them to set a specific context in which your test methods are executed. 

### As you go...

When you discover a new fixture (context) for your test, encapsulates it in a specific TestCase subclass. 
You can create a #test... method for the first test.  As that method develops and more #test... methods are added, you will find yourself refactoring temps into instance variables for the objects in the fixture and overriding #setUp to initialize these variables.  
As required, override #tearDown to nil references, release objects and deallocate.

### Design Point

A TestCase is an implementation of the Command pattern to run a test. 

### Mini tutorial - step one

Create a specific subclass

```
TestCase << #MyExampleSetTest
	package: 'MySetTest'
```

### Mini tutorial - step two 

Define a test method

```
MyExampleSetTest >> testIncludes
	| full empty |
	full := Set with: 5 with: 6.
	empty := Set new.
	self assert: (full includes: 5).
	self assert: (full includes: 6).
	self assert: (empty includes: 5) not
```	

### Mini tutorial - step three

Execute your tests

```
MyExampleSetTest run: testIncludes 
```

See my superclass' comment for assertion and logging information.

### Mini tutorial - step four

Create a setUp method (add the empty and full instances to the class)

```
MyExampleSetTest >> setUp
	super setUp.
	empty := Set new.
	full := Set with: 5 with: 6
```

Redefine your method to avoid duplicating the setUp logic
```
MyExampleSetTest >> testIncludes

	self assert: (full includes: 5).
	self assert: (full includes: 6).
	self assert: (empty includes: 5) not
```	

Run your test!

```
MyExampleSetTest run: testIncludes 
```

You are done. Remember tests are your best friends. 
And enjoy coding in the debugger.
"
Class {
	#name : #TestCase,
	#superclass : #TestAsserter,
	#instVars : [
		'testSelector',
		'expectedFails'
	],
	#classVars : [
		'Announcers',
		'DefaultTimeLimit',
		'HistoryAnnouncer'
	],
	#classInstVars : [
		'history'
	],
	#category : #'SUnit-Core-Kernel'
}

{ #category : #'building suites' }
TestCase class >> addTestsFor: classNameString toSuite: suite [
	| cls |
	cls := self environment at: classNameString ifAbsent: [ ^ suite ].
	^ cls isAbstract
		ifTrue: [ 
			cls allSubclasses
				do: [ :each | 
					each isAbstract
						ifFalse: [ each addToSuiteFromSelectors: suite ] ].
			suite ]
		ifFalse: [ cls addToSuiteFromSelectors: suite ]
]

{ #category : #'building suites' }
TestCase class >> addToSuite: suite fromMethods: testMethods [ 
	testMethods do:  [ :selector | 
			suite addTest: (self selector: selector) ].
	^suite
]

{ #category : #'building suites' }
TestCase class >> addToSuiteFromSelectors: suite [
	^self addToSuite: suite fromMethods: (self shouldInheritSelectors
		ifTrue: [ self allTestSelectors ]
		ifFalse: [self testSelectors ])
]

{ #category : #accessing }
TestCase class >> allTestSelectors [
	| answer pivotClass lookupRoot |
	answer := Set withAll: self testSelectors.
	self shouldInheritSelectors
		ifTrue:
			[pivotClass := self.
			lookupRoot := self lookupHierarchyRoot.
			[pivotClass == lookupRoot]
				whileFalse:
					[pivotClass := pivotClass superclass.
					answer addAll: pivotClass testSelectors]].
	^answer asSortedCollection asOrderedCollection
]

{ #category : #events }
TestCase class >> announcer [ 
	^ self announcers at: self ifAbsentPut: [ Announcer new ]
]

{ #category : #events }
TestCase class >> announcers [
	^ Announcers ifNil: [ Announcers := Dictionary new ] 
]

{ #category : #'building suites' }
TestCase class >> buildSuite [
	"Returns a suite of test case. This suite can be composed of local and inherited methods if the superclass is declared as abstract."
	| suite |
	^self isAbstract
		ifTrue: 
			[suite := self suiteClass named: self name asString.
			self allSubclasses 
				do: [:each | each isAbstract ifFalse: [suite addTest: each buildSuiteFromSelectors]].
			suite]
		ifFalse: [self buildSuiteFromSelectors]
]

{ #category : #'building suites' }
TestCase class >> buildSuiteFromAllSelectors [

	^self buildSuiteFromMethods: self allTestSelectors
			
]

{ #category : #'building suites' }
TestCase class >> buildSuiteFromLocalSelectors [

	^self buildSuiteFromMethods: self testSelectors
			
]

{ #category : #'building suites' }
TestCase class >> buildSuiteFromMethods: testMethods [

	^testMethods
		inject: (self suiteClass named: self name asString)
		into: [:suite :selector |
			suite
				addTest: (self selector: selector);
				yourself]
]

{ #category : #'building suites' }
TestCase class >> buildSuiteFromSelectors [
	^self buildSuiteFromMethods: self allTestSelectors
]

{ #category : #'accessing comment' }
TestCase class >> classCommentBlank [
	^'This class contains tests'
]

{ #category : #coverage }
TestCase class >> coverage [
	"returns the coverage determined by a simple static analysis of test coverage 
	made by the receiver on a class that is identified by the name of the receiver.
	We assume that SetTest test Set."

	| cls className |
	(self name endsWith: 'Test')
		ifFalse: [ self error: 'Please, use #coverageForClass: instead' ].
	className := self name copyFrom: 1 to: self name size - 'Test' size.
	cls := self environment at: className asSymbol ifAbsent: [ self error: 'Please, use #coverageForClass: instead' ].	"May happen with Transcript"
	cls isBehavior
		ifFalse: [ cls := cls class ].
	^ self coverageForClass: cls
]

{ #category : #coverage }
TestCase class >> coverageAsString [
	| cov className |
	cov := self coverage first asInteger. 
	"coverage already checks that the name is ends with 'Test' and if the class tested exists"
	
	className := self name copyFrom: 1 to: (self name size - 'Test' size).
	^ self name asString, ' covers ', cov asString, '% of ', className.
]

{ #category : #coverage }
TestCase class >> coverageForClass: cls [
	"returns the test coverage of all the methods included inherited ones"
	^ self coverageForClass: cls until: ProtoObject
]

{ #category : #coverage }
TestCase class >> coverageForClass: cls until: aRootClass [
	"returns the test coverage of all the methods included inherited ones but stopping at aRootClass included"
	
	| definedMethods testedMethods untestedMethods |
	definedMethods := cls allSelectorsAboveUntil: aRootClass.
	definedMethods size = 0
		ifTrue: [^ {0. Set new}].
	testedMethods := 
		self methods inject: Set new into: 
							[:sums :cm | sums union: cm messages].
	testedMethods := testedMethods reject: [:sel | (definedMethods includes: sel) not].
	untestedMethods := definedMethods select: [:selector | (testedMethods includes: selector) not].
	^ { (testedMethods size * 100 / definedMethods size) asFloat . untestedMethods}

]

{ #category : #coverage }
TestCase class >> coveragePercentage [
	^ self coverage first
]

{ #category : #'instance creation' }
TestCase class >> debug: aSymbol [

	^(self selector: aSymbol) debug
]

{ #category : #accessing }
TestCase class >> defaultTimeLimit [
	^DefaultTimeLimit ifNil: [DefaultTimeLimit := 10 seconds]

]

{ #category : #accessing }
TestCase class >> defaultTimeLimit: aDuration [
	DefaultTimeLimit := aDuration
]

{ #category : #settings }
TestCase class >> defaultTimeLimitSecs [
	^self defaultTimeLimit asMilliSeconds / 1000.0
]

{ #category : #settings }
TestCase class >> defaultTimeLimitSecs: aNumber [
	self defaultTimeLimit: aNumber seconds
]

{ #category : #settings }
TestCase class >> defaultTimeLimitSettingOn: aBuilder [
	<systemsettings>
	
	(aBuilder group: #sunit)
		label: 'SUnit';
		parent: #pharoSystem;
		description: 'SUnit';
		with: [  
			(aBuilder setting: #defaultTimeLimitSecs)
				target: self;
				default: 10.0;
				label: 'Default time limit for tests (secs)' ;
				description: 'Detault time limit in seconds for test execution']
]

{ #category : #history }
TestCase class >> generateLastStoredRunMethod [

	self shouldGenerateLastStoredRunMethod ifTrue: [
		self class
			compile: (self lastRunMethodNamed: #lastStoredRun)
			classified: 'history' ]
]

{ #category : #'accessing comment' }
TestCase class >> hasComment [
	^true
]

{ #category : #testing }
TestCase class >> hasErrorTest [

	^ (self history at: #errors) isEmpty not 
]

{ #category : #testing }
TestCase class >> hasFailedTest [

	^ (self history at: #failures) isEmpty not 
]

{ #category : #testing }
TestCase class >> hasMethodBeenRun: aSelector [
	^ ((self lastRun at: #errors),
		(self lastRun at: #failures),
		(self lastRun at: #passed))
			includes: aSelector
]

{ #category : #testing }
TestCase class >> hasPassedTest [

	^ (self history at: #passed) isEmpty not 
]

{ #category : #testing }
TestCase class >> hasTestSelectors [

	^(self selectors anySatisfy: [ :each | 
		(each beginsWith: 'test') and: [
				each numArgs isZero 
			]
		]) or: [ 
			self superclass isTestCase and: [ 
				self shouldInheritSelectors and: [ 
						self superclass hasTestSelectors	
				]
			]
		]
	
]

{ #category : #history }
TestCase class >> history [
	^ history ifNil: [ history := self newTestDictionary ]
]

{ #category : #history }
TestCase class >> history: aDictionary [

	history := aDictionary.
	self historyAnnouncer announce: (TestSuiteEnded result: self)
]

{ #category : #accessing }
TestCase class >> historyAnnouncer [
	^ HistoryAnnouncer ifNil: [  HistoryAnnouncer := Announcer new ]
]

{ #category : #'initialize - event' }
TestCase class >> initialize [
	SystemAnnouncer uniqueInstance unsubscribe: self.
	SystemAnnouncer uniqueInstance weak
		when: MethodAdded, MethodModified, MethodRemoved 
		send: #methodChanged: 
		to: self
]

{ #category : #testing }
TestCase class >> isAbstract [
	"Override to true if a TestCase subclass is Abstract and should not have
	TestCase instances built from it"

	^self name = #TestCase
			
]

{ #category : #testing }
TestCase class >> isTestCase [
	^ true
]

{ #category : #testing }
TestCase class >> isUnitTest [
	^true
]

{ #category : #testing }
TestCase class >> isUsed [
	"all my subclasses are used by me"
	^self name = 'TestCase'
		ifTrue: [ super isUsed ]
		ifFalse: [ true ]
]

{ #category : #history }
TestCase class >> lastRun [
	^ self classForTestResult historyFor: self
]

{ #category : #history }
TestCase class >> lastRunMethodNamed: aSelector [
	
	^ String streamContents: [:str |
		str nextPutAll: aSelector asString ;cr.
		str tab; nextPutAll: '^ ', (self lastRun) storeString]

]

{ #category : #history }
TestCase class >> lastStoredRun [
	^ ((Dictionary new) add: (#failures->#()); add: (#passed->#()); add: (#errors->#()); yourself)
]

{ #category : #coverage }
TestCase class >> localCoverage [
	"returns the coverage determined by a simple static analysis of test coverage 
	made by the receiver on a class that is identified by the name of the receiver.
	We assume that SetTest test Set. The computation of the coverage takes only into
	account the methods defined locally in the tested class. See coverage for a more global 
	coverage"

	| cls className |
	(self name endsWith: 'Test')
		ifFalse: [ self error: 'Please, use #localCoverageForClass: instead' ].
	className := self name copyFrom: 1 to: self name size - 'Test' size.
	cls := self environment at: className asSymbol ifAbsent: [ self error: 'Please, use #localCoverageForClass: instead' ].
	cls isBehavior
		ifFalse: [ cls := cls class ].
	^ self localCoverageForClass: cls
]

{ #category : #coverage }
TestCase class >> localCoverageAsString [
	| cov className |
	cov := self localCoverage first asInteger. 
	"coverage already checks that the name is ends with 'Test' and if the class tested exists"
	
	className := self name copyFrom: 1 to: (self name size - 'Test' size).
	^ self name asString, ' covers ', cov asString, '% of ', className.
]

{ #category : #coverage }
TestCase class >> localCoverageForClass: cls [
	
	| definedMethods testedMethods untestedMethods |
	definedMethods := cls selectors.
	"It happens for IdentityBag / IdentityBagTest"
	definedMethods size = 0
		ifTrue: [^ {0. Set new}].

	testedMethods := 
		self methods inject: Set new into: 
							[:sums :cm | sums union: cm messages].
					
	"testedMethods contains all the methods send in test methods, which probably contains methods that have nothign to do with collection"
	testedMethods := testedMethods reject: [:sel | (definedMethods includes: sel) not].

	untestedMethods := definedMethods select: [:selector | (testedMethods includes: selector) not].

	^ { (testedMethods size * 100 / definedMethods size) asFloat . untestedMethods}

]

{ #category : #coverage }
TestCase class >> localCoveragePercentage [
	^ self localCoverage first
]

{ #category : #accessing }
TestCase class >> lookupHierarchyRoot [
	^TestCase
]

{ #category : #'initialize - event' }
TestCase class >> methodChanged: anEvent [
	"Remove the changed method from the known test results."
	
	anEvent method isTestMethod ifFalse: [ ^ self ].
	self classForTestResult removeFromTestHistory: anEvent selector in: anEvent methodClass
]

{ #category : #testing }
TestCase class >> methodFailed: aSelector [
	^ (self lastRun at: #failures) includes: aSelector
]

{ #category : #testing }
TestCase class >> methodPassed: aSelector [
	^ (self lastRun at: #passed) includes: aSelector
]

{ #category : #testing }
TestCase class >> methodProgressed: aSelector [
	^ ((self storedMethodRaisedError: aSelector) or: [self storedMethodFailed: aSelector])
		and: [self methodPassed: aSelector]
		
]

{ #category : #testing }
TestCase class >> methodRaisedError: aSelector [
	^ (self lastRun at: #errors) includes: aSelector
]

{ #category : #testing }
TestCase class >> methodRegressed: aSelector [
	^ (self storedMethodPassed: aSelector) and: [(self methodFailed: aSelector) or: [self methodRaisedError: aSelector]]
]

{ #category : #history }
TestCase class >> newTestDictionary [

	^ Dictionary new at: #timeStamp put: DateAndTime now;
		at: #passed put: Set new;
		at: #failures put: Set new;
		at: #errors put: Set new;
		yourself
		
]

{ #category : #events }
TestCase class >> resetAnnouncer [
	self announcers removeKey: self ifAbsent: []
]

{ #category : #history }
TestCase class >> resetHistory [
	history := nil
]

{ #category : #accessing }
TestCase class >> resources [

	^#()
]

{ #category : #'instance creation' }
TestCase class >> run: aSymbol [
	"Execute a testcase name, aSymbol, and return a test result."
	
	^(self selector: aSymbol) run
]

{ #category : #utilities }
TestCase class >> runAllAndLogResult [

	"runs all tests in the image"

	TestCase suite run traceCr
]

{ #category : #'instance creation' }
TestCase class >> selector: aSymbol [
	"Return a test case with aSymbol as selector but does not execute it."
	^self new setTestSelector: aSymbol
]

{ #category : #events }
TestCase class >> shouldAnnounce [
	^ self announcers includesKey: self
]

{ #category : #history }
TestCase class >> shouldGenerateLastStoredRunMethod [
	| sameRun |
	
	(self class includesSelector: #lastStoredRun)
		ifFalse: [^ true].
	sameRun := #(#passed #failures #errors) inject: true into: 
		[ :ok :set | ok and: [(self lastRun at: set) = (self lastStoredRun at: set) ]].
	^ sameRun not

]

{ #category : #testing }
TestCase class >> shouldInheritSelectors [
	"I should inherit from an Abstract superclass but not from a concrete one by default, unless I have no testSelectors in which case I must be expecting to inherit them from my superclass.  If a test case with selectors wants to inherit selectors from a concrete superclass, override this to true in that subclass."
	
	^self ~~ self lookupHierarchyRoot
		and: [self superclass isAbstract or: [self testSelectors isEmpty]]
]

{ #category : #testing }
TestCase class >> storedMethodFailed: aSelector [
	^ (self lastStoredRun at: #failures) includes: aSelector
]

{ #category : #testing }
TestCase class >> storedMethodPassed: aSelector [
	^ (self lastStoredRun at: #passed) includes: aSelector
]

{ #category : #testing }
TestCase class >> storedMethodRaisedError: aSelector [
	^ (self lastStoredRun at: #errors) includes: aSelector
]

{ #category : #'instance creation' }
TestCase class >> suite [
	"Return a test suite"
	^self buildSuite
]

{ #category : #accessing }
TestCase class >> sunitVersion [
	^'4.0'
]

{ #category : #accessing }
TestCase class >> testSelectors [
	^(self selectors select: [ :each | (each beginsWith: 'test') and: [each numArgs isZero]])
]

{ #category : #'as yet unclassified' }
TestCase class >> whichClassIncludesTestSelector: aSymbol [
	^self whichClassIncludesSelector: aSymbol
]

{ #category : #dependencies }
TestCase >> addDependentToHierachy: anObject [ 
	"an empty method. for Composite compability with TestSuite"
]

{ #category : #events }
TestCase >> announce: anAnnouncementClass [
	^ self announce: anAnnouncementClass withResult: nil
]

{ #category : #events }
TestCase >> announce: anAnnouncementClass withResult: result [
	| event |
	self shouldAnnounce ifFalse: [ ^ self ].
	
	event := anAnnouncementClass asAnnouncement.
	event testCase: self.
	event testSelector: testSelector.
	event testResult: result.
	self announcer announce: event.
]

{ #category : #events }
TestCase >> announcer [
	^ self class announcer
]

{ #category : #private }
TestCase >> cleanUpInstanceVariables [
	self class allInstVarNames do: [ :name |
		(self instanceVariablesToKeep includes: name) ifFalse: [
			self instVarNamed: name put: nil ] ]
]

{ #category : #running }
TestCase >> debug [
	| result |
	result := self classForTestResult new.
	[ result runCaseForDebug: self ]
		ensure: [ self classForTestResource resetResources: self resources.
			result updateResultsInHistory  ].
	^ result
]

{ #category : #running }
TestCase >> debugAsFailure [
	| semaphore |
	semaphore := Semaphore new.
	[ 
	semaphore wait.
	self classForTestResource resetResources: self resources ] fork.
	(self class selector: testSelector) runCaseAsFailure: semaphore
]

{ #category : #accessing }
TestCase >> defaultTimeLimit [
	^self class defaultTimeLimit
]

{ #category : #private }
TestCase >> executeShould: aBlock inScopeOf: anExceptionalEvent withDescriptionContaining: aString [
	^[aBlock value.
 	false] on: anExceptionalEvent
		do: [:ex | ex return: (ex description includesSubstring: aString) ]
			
]

{ #category : #accessing }
TestCase >> executionEnvironment [
	^CurrentExecutionEnvironment value
]

{ #category : #accessing }
TestCase >> executionProcessMonitor [
	^self executionEnvironment processMonitor
]

{ #category : #testing }
TestCase >> expectedFailures [
	| pragmas |
	^ expectedFails ifNil: [
		
		pragmas := Pragma allNamed: #expectedFailure from: self class to: TestCase.
		expectedFails := pragmas collect: [:each | each method selector  ].
	]	

]

{ #category : #running }
TestCase >> failureLog [	
	^Transcript

			
]

{ #category : #private }
TestCase >> instanceVariablesToKeep [
	^ #('testSelector')
]

{ #category : #testing }
TestCase >> isExpectedFailure [
	^self expectedFailures includes: testSelector
]

{ #category : #running }
TestCase >> isLogging [
	"By default, we're not logging failures. If you override this in 
	a subclass, make sure that you override #failureLog"
	^false
			
]

{ #category : #running }
TestCase >> logFailure: aString [
	self isLogging ifTrue: [
		self failureLog 
			cr; 
			nextPutAll: aString; 
			flush]
			
]

{ #category : #accessing }
TestCase >> nameForReport [

	^ self selector
]

{ #category : #'CI support' }
TestCase >> onPharoCITestingEnvironment [
	
	^ Smalltalk os environment at: 'PHARO_CI_TESTING_ENVIRONMENT' ifPresent: [ true ] ifAbsent: [ false ]
]

{ #category : #running }
TestCase >> openDebuggerOnFailingTestMethod [
	<haltOrBreakpointForTesting>
	"SUnit has halted one step in front of the failing test method. Step over the 'self halt' and 
	 send into 'self perform: testSelector' to see the failure from the beginning"

	self
		halt;
		performTest
]

{ #category : #private }
TestCase >> performTest [
	self perform: testSelector asSymbol
]

{ #category : #running }
TestCase >> prepareToRunAgain [ 	

	"Used by the debugger when a test is restarted
	I'm not 'hidding'' possible exceptions because I think it is best to popup a new debugger
	if some one occurs and let the programmer decide what to do - Hernan"
	self 
		tearDown;
		setUp
]

{ #category : #printing }
TestCase >> printOn: aStream [
	aStream nextPutAll: self class name asString.
	self printTestSelectorOn: aStream
]

{ #category : #printing }
TestCase >> printTestSelectorDefiningClass: aClass on: aStream [
	aStream << '('.
	aClass printOn: aStream.
	aStream << ')'
]

{ #category : #printing }
TestCase >> printTestSelectorOn: aStream [
	testSelector
		ifNotNil: [ 
			| class |
			class := self class whichClassIncludesTestSelector: testSelector.
			class ~= self class
				ifTrue: [ self printTestSelectorDefiningClass: class on: aStream ].
			aStream
				nextPutAll: '>>#';
				nextPutAll: testSelector ]
]

{ #category : #dependencies }
TestCase >> removeDependentFromHierachy: anObject [ 
	"an empty method. for Composite compability with TestSuite"
]

{ #category : #accessing }
TestCase >> resources [
	"We give TestCase this instance-side method so that methods polymorphic with TestSuite can be code-identical.  Having this instance-side method also helps when writing tests of resource behaviour. Except for such tests, it is rare to override this method and should not be done without thought.  If there were a good reason why a single test case needed to share tests requiring different resources, it might be legitimate."

	^self class resources
]

{ #category : #running }
TestCase >> run [
	"Execute the receiver and return a test result."
	| result |
	result := self classForTestResult new.
	[ result runCase: self]
		ensure: [ self classForTestResource resetResources: self resources ].
	^ result
]

{ #category : #running }
TestCase >> run: aResult [
	aResult runCase: self
]

{ #category : #running }
TestCase >> runCase [
	self resources do: [:each | each availableFor: self].
	[self setUp.
	self performTest] ensure: [
		self tearDown.
		self cleanUpInstanceVariables]
]

{ #category : #running }
TestCase >> runCaseAsFailure: aSemaphore [
	[self resources do: [:each | each availableFor: self].
	[self setUp.
	self openDebuggerOnFailingTestMethod] ensure: [self tearDown]]
		ensure: [aSemaphore signal]
]

{ #category : #running }
TestCase >> runCaseManaged [
	CurrentExecutionEnvironment runTestCase: self
]

{ #category : #accessing }
TestCase >> selector [
	^testSelector
]

{ #category : #private }
TestCase >> setTestSelector: aSymbol [
	testSelector := aSymbol
]

{ #category : #running }
TestCase >> setUp [
	"Hooks that subclasses may override to define the fixture of test."

]

{ #category : #events }
TestCase >> shouldAnnounce [
	^ self class shouldAnnounce
]

{ #category : #testing }
TestCase >> shouldPass [
	^self isExpectedFailure not
]

{ #category : #'CI support' }
TestCase >> skipOnPharoCITestingEnvironment [
	
	self onPharoCITestingEnvironment 
		ifTrue: [ self skip ].
]

{ #category : #running }
TestCase >> tearDown [
	"Hooks that subclasses may override to clean the fixture of test."
]

{ #category : #accessing }
TestCase >> timeLimit: aDuration [
	^self executionEnvironment maxTimeForTest: aDuration
]
