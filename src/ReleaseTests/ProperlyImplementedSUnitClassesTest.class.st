"
This class checks if test classes have been properly implemented
"
Class {
	#name : #ProperlyImplementedSUnitClassesTest,
	#superclass : #TestCase,
	#category : #'ReleaseTests-CleanCode'
}

{ #category : #tests }
ProperlyImplementedSUnitClassesTest >> testAndMakeSureSuperSetupIsCalledAsFirstMessageInSetupMethodsOfTestCases [
	"Verify that each setUp method in a unit test starts with a call to super setUp as first message sent"

	| violating |
	violating := OrderedCollection new.
	TestCase
		allSubclassesDo: [ :each | 
			each
				compiledMethodAt: #setUp
				ifPresent: [ :method | 
					(ReShouldSendSuperSetUpAsFirstMessage superSetUpNotCalledFirstIn: method)
						ifTrue: [ violating add: method ] ] ].
	self assertEmpty: violating
]

{ #category : #tests }
ProperlyImplementedSUnitClassesTest >> testAndMakeSureSuperTearDownIsCalledAsLastMessageInTearDownMethodsOfTestCases [
	"Verify that each tearDown method in a unit test ends with a call to super tearDown as last message sent"

	| violating |
	violating := OrderedCollection new.
	TestCase
		allSubclassesDo: [ :each | 
			each
				compiledMethodAt: #tearDown
				ifPresent: [ :method | 
					(ReShouldSendSuperTearDownAsLastMessage
						superTearDownNotCalledLastIn: method)
						ifTrue: [ violating add: method ] ] ].
	self assertEmpty: violating
]
