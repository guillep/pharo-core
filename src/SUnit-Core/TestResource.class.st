"
Normally a test will set up all the objects it needs and tear them down again after it has run.  This self-containedness makes a test more robust.  Use `TestResource` only for objects that are needed by several tests and that are too 'expensive' (in time or otherwise) to recreate and destroy for each test.  A viable approach is to develop the code in MyTestCase's `setUp` and `tearDown` methods, then at some point refactor the code into the `setUp` and `tearDown` of a `TestResource` subclass whose class is added to `MyTestCase class>>resources` method.


### TestResource design and consequence

`TestResource` uses the singleton pattern. A `TestResource` class will set up a single instance of itself when first requested and tear it down again at the end of `TestSuite>>#run` (or `TestCase>>#run`, `TestCase>>#debug` and `TestCase>>#debugAsFailure`).  Normally, a TestResource, once setUp, remains active during the running of all remaining tests and is `reset` after all tests have run.  

Users can choose to `reset` a resource in the `tearDown` of a test that alters it, sacrificing the performance gain of having a single `setUp` of the resource for the certainty that other tests using it will not see the alterations.  Generally however, this should be the exception:  if you need to reset the resource for every test that uses it, its code should just be part of your test's `setUp` and `tearDown` code.

### How to use a test resource
To use, create a subclass of `TestResource` and override the following:
- `TestCase class>>#resources`, to return a collection including the new test resources class, for all test case classes that need it a TestCase' resources are set up in the order returned and torn down in the reverse order.
- `TestResource class>>resources`, if the resource itself always needs some other resource to be present before it can set up a TestResource's resource are set up before it and torn down after it, and are set up in the order returned and torn down in the reverse order.
- `TestResource>>#setUp` and tearDown, to define initial and final behaviour (just like a test).
- `TestResource>>#isAvailable`, to return true if it is and false if it isn't (the framework calls this after setUp);  ideally, this call should not change the resource' state - that should be done in setUp.

### Implementation
`TestResource` implements the singleton pattern in its class-side `TestResource class>>#isAvailable` and `TestResource class>>#reset` methods.  Do not override these when creating specific resources;  unless you are developing a whole new pattern of use, it will always be correct to override instance-side `setUp`, `tearDown` and `isAvailable`, and dangerous to override `class>>isAvailable`, `class>>isAlreadyAvailable` and `class>>reset`.

Generally, users do not code interactions with a test's resources during the running of a test.  Code that reads a resource' values while leaving its state strictly alone is safe enough.  A test must leave a resource in a clean state:  always use `reset` if a test must protect later-running tests from unsafe changes (and review whether in such a case a resource is the right thing to use in the first place).

See my superclass' comment for assertion and logging information.

"
Class {
	#name : #TestResource,
	#superclass : #TestAsserter,
	#instVars : [
		'name',
		'description'
	],
	#classInstVars : [
		'current'
	],
	#category : #'SUnit-Core-Kernel'
}

{ #category : #running }
TestResource class >> availableFor: aTestAsserter [
	aTestAsserter
		assert: self isAvailable
		description:
			['Unavailable resource ' , self name , ' requested by '
				, aTestAsserter printString]
]

{ #category : #accessing }
TestResource class >> current [
	"This is a lazy accessor:  the assert of self isAvailable does no work unless current isNil.  However this method should normally be sent only to a resource that should already have been made available, e.g. in a test whose test case class has the resource class in its #resources, so should never be able to fail the assert.
	If the intent is indeed to access a possibly-unprepared or reset-in-earlier-test resource lazily, then preface the call of 'MyResource current' with 'MyResource availableFor: self'."
	
	self
		assert: self isAvailable
		description:
			'Sent #current to unavailable resource ' , self name ,
					'.  Add it to test case'' class-side #resources (recommended) or send #availableFor: beforehand'.
	^current
]

{ #category : #accessing }
TestResource class >> current: aTestResource [

	current := aTestResource
			
]

{ #category : #testing }
TestResource class >> isAbstract [
	"Override to true if a TestResource subclass is Abstract and should not have
	TestCase instances built from it"

	^self name = #TestResource
			
]

{ #category : #testing }
TestResource class >> isAlreadyAvailable [
	^current class == self
]

{ #category : #testing }
TestResource class >> isAvailable [
	"This is (and must be) a lazy method.  If my current has a value, an attempt to make me available has already been made:  trust its result.  If not, try to make me available."

	current ifNil: [self makeAvailable].
	^self isAlreadyAvailable
]

{ #category : #testing }
TestResource class >> isUnavailable [

	^self isAvailable not
			
]

{ #category : #private }
TestResource class >> makeAvailable [
	"This method must be the _only_ way to set a notNil value for the unique instance (current).  First, obtain a candidate instance and set current to a notNil placeholder (any notNil object not an instance of me would do;  this version uses false).  Next, check any subordinate resources needed by this resource.  Lastly, setUp the candidate and put it in current if it is available, ensuring that it is torn down otherwise."
	
	| candidate |
	current := nil.
	candidate := self new.
	self resources do: [:each | each availableFor: candidate].
	
	"Execute the TestResource's #setUp method within the DefaultExecutionEnvironment to prevent
	forked processes created within #setUp from being terminated by the TestExecutionEnvironment
	(in #checkForkedProcesses) it is running in."
	DefaultExecutionEnvironment beActiveDuring: [[candidate setUp.
	candidate isAvailable ifTrue: [current := candidate]]
		ensure: [current == candidate ifFalse: [candidate tearDown]]]
]

{ #category : #'instance creation' }
TestResource class >> new [
	"Use #current to get the valid current instance.  Use of #new to get an instance (that should never be the current one) could be done in bizarre circumstances, so is not blocked, but will usually be inappropriate."
	
	^super new initialize.
]

{ #category : #initialization }
TestResource class >> reset [
	[self isAlreadyAvailable ifTrue: [current tearDown]]
		ensure: [current := nil]
]

{ #category : #private }
TestResource class >> resetOrAddResourcesTo: aCollection [
	"Add correctly set-up resources to the collection unless already there. Reset any imperfectly-set-up resources, so current isNil will return true if they are re-encountered via an indirectly self-prerequing resource;  circular references cannot be set up so will never reply true to isAlreadyAvailable, but may have correctly-set-up prereqs to add and/or imperfectly-set-up ones to reset, so do not abort the loop first time round."

	current ifNil: [^self].
	self isAlreadyAvailable
		ifFalse:
			[self reset.
			self resources do: [:each | each resetOrAddResourcesTo: aCollection]]
		ifTrue:
			[(aCollection includes: self)
				ifFalse:
					[self resources do: [:each | each resetOrAddResourcesTo: aCollection].
					aCollection add: self]]

"The cloned 'self resources do: ...' line in both blocks is, I think, the best way to write this method so that its logic is clear.  The first loop resets this resource immediately, before traversing its resources;  the second traverses before adding"
]

{ #category : #running }
TestResource class >> resetResources: topLevelResources [
	"Reset all imperfectly-set-up resources while gathering the rest for ordered resetting."

	| availableResources |
	availableResources := OrderedCollection new: topLevelResources size.
	topLevelResources
		do: [:each | each resetOrAddResourcesTo: availableResources].
	availableResources reverseDo: [:each | each reset]
]

{ #category : #accessing }
TestResource class >> resources [
	^#()
]

{ #category : #running }
TestResource class >> signalInitializationError [
	^ self classForTestResult signalFailureWith:  'Resource ' , self name , ' could not be initialized'
]

{ #category : #accessing }
TestResource >> description [
	^ description ifNil: [ String empty ]
]

{ #category : #accessing }
TestResource >> description: aString [

	description := aString
]

{ #category : #testing }
TestResource >> isAvailable [
	"Override to provide information on the readiness of the resource.  Put state-changing behaviour in setUp and keep this a state-preserving check as far as possible.  Where setUp is guaranteed to provide a valid resource if it completes, there is no need to override this."
	
	^true
]

{ #category : #testing }
TestResource >> isUnavailable [
	"override to provide information on the readiness of the resource"
	
	^self isAvailable not
			
]

{ #category : #accessing }
TestResource >> name [
	name ifNil: [ ^ self printString ].
	^ name
]

{ #category : #accessing }
TestResource >> name: aString [
	name := aString
]

{ #category : #printing }
TestResource >> printOn: aStream [

	aStream nextPutAll: self class name asString
]

{ #category : #accessing }
TestResource >> resources [
	^self class resources
]

{ #category : #running }
TestResource >> setUp [
	"Does nothing. Subclasses should override this to initialize their resource"
]

{ #category : #running }
TestResource >> tearDown [
	"Does nothing. Subclasses should override this to tear down their resource"
]
