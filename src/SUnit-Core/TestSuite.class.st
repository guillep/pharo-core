"
I'm a Composite of tests, either `TestCase`s or other `TestSuite`s. The top-level protocol is `#run`. This creates a`TestResult` and sends `self run: aTestResult`.
Then ensures that any `TestResource`s made available during the run are reset.  These, and the dependencies protocol, are common between `TestSuite` and `TestCase`.

### Implementation
While I implement a composite I do not inherit from a common superclass such as we could expect. 
It is just like that. Newer versions of the frameworks may want to introduce a more conventional design. 

"
Class {
	#name : #TestSuite,
	#superclass : #Object,
	#instVars : [
		'tests',
		'resources',
		'name',
		'announcer'
	],
	#category : #'SUnit-Core-Kernel'
}

{ #category : #'instance creation' }
TestSuite class >> named: aString [

	^self new
		name: aString;
		yourself
]

{ #category : #composing }
TestSuite >> , aTestSuite [ 

		^ TestSuite new
			addTests: self tests;
			addTests: aTestSuite tests;
			yourself
]

{ #category : #dependencies }
TestSuite >> addDependentToHierachy: anObject [
	self addDependent: anObject.
	self tests do: [ :each | each addDependentToHierachy: anObject]
			
]

{ #category : #accessing }
TestSuite >> addTest: aTest [
	self tests add: aTest 
]

{ #category : #accessing }
TestSuite >> addTests: aCollection [ 
	aCollection do: [:eachTest | self addTest: eachTest]
]

{ #category : #announcements }
TestSuite >> announceTest: aTest [
	^ self testSuiteAnnouncer announce: (TestAnnouncement with: aTest).
]

{ #category : #running }
TestSuite >> debug [
	self setUp.
	[
		self tests do: [:each | 
					each debug.
					self announceTest: each.
					self changed: each.
		]
	] ensure:[ 
		self tearDown. 
	].


]

{ #category : #accessing }
TestSuite >> defaultResources [
	^self tests
		inject: OrderedCollection new
		into:
			[:coll :testCase |
			testCase resources do:
				[:each |
				(coll includes: each) ifFalse: [coll add: each]].
			coll]
]

{ #category : #accessing }
TestSuite >> name [

	^name
]

{ #category : #accessing }
TestSuite >> name: aString [

	name := aString
]

{ #category : #dependencies }
TestSuite >> removeDependentFromHierachy: anObject [
	self removeDependent: anObject.
	self tests do: [ :each | each removeDependentFromHierachy: anObject]
			
]

{ #category : #running }
TestSuite >> resourceClass [

	^ TestResource
]

{ #category : #accessing }
TestSuite >> resources [

	^ resources ifNil: [ resources := self defaultResources ]
]

{ #category : #accessing }
TestSuite >> resources: someOrderedTestResourceClasses [
	"The parameter should understand reverseDo: and should not contain duplicates."

	resources := someOrderedTestResourceClasses
]

{ #category : #running }
TestSuite >> resultClass [

	^ TestAsserter classForTestResult
]

{ #category : #running }
TestSuite >> run [
	| result |
	result := self resultClass new.
	self run: result.
	^result
]

{ #category : #running }
TestSuite >> run: aResult [
	CurrentExecutionEnvironment runTestsBy: [
		self runUnmanaged: aResult ]
]

{ #category : #running }
TestSuite >> runUnmanaged: aResult [
	self setUp.
	[ self tests
		do: [ :each | 
			each run: aResult.
			self announceTest: each.
			self changed: each ] ]
		ensure: [ self tearDown ]
]

{ #category : #running }
TestSuite >> setUp [
	self resources do: [:each |
			each isAvailable ifFalse: [ each signalInitializationError ]].
]

{ #category : #deprecated }
TestSuite >> subscribe: aAnnouncement do: aBlock [
	
	self
		deprecated: 'Please use #when:send:to: instead'
		transformWith: '`@receiver subscribe: `@statements1 do: `@statements2' 
						-> '`@receiver when: `@statements1 do: `@statements2'.
	^ self when: aAnnouncement do: aBlock
]

{ #category : #running }
TestSuite >> tearDown [
	self resourceClass resetResources: self resources.
]

{ #category : #announcements }
TestSuite >> testSuiteAnnouncer [
	^ announcer ifNil: [ announcer := Announcer new. ]
]

{ #category : #accessing }
TestSuite >> tests [

	^ tests ifNil: [ tests := OrderedCollection new ]
]

{ #category : #announcements }
TestSuite >> unsubscribe: anAnnouncementClass [ 
	self testSuiteAnnouncer unsubscribe: anAnnouncementClass.
]

{ #category : #announcements }
TestSuite >> when: aAnnouncement do: aBlock [
	self testSuiteAnnouncer when: aAnnouncement do: aBlock
]
