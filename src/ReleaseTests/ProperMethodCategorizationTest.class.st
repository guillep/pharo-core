"
Tests to enforce proper categorization of methods
"
Class {
	#name : #ProperMethodCategorizationTest,
	#superclass : #TestCase,
	#category : #'ReleaseTests-Categorization'
}

{ #category : #utilities }
ProperMethodCategorizationTest >> assureAll: selector areCategorizedIn: protocol whenSubclassOf: aClass [

	| violating |
	violating := OrderedCollection new.
	aClass allSubclassesDo: [:cls | cls methods do: [:m |
			(m selector = selector and: [ m protocol ~= protocol ])
				ifTrue: [ violating add: m -> m protocol ] ] ].
	self 
		assert: violating isEmpty 
		description: ('Violations: {1}.
		Reason: {1} subclasses should have #{2} in protocol {3}' 
			format: { self explanationFrom: violating . aClass asString. selector. protocol })

]

{ #category : #utilities }
ProperMethodCategorizationTest >> assureAll: selector areCategorizedInProtocols: protocols whenSubclassOf: aClass [
	"Test whether the selector is categorized in at least the collection of protocols"
	
	| violating |
	violating := OrderedCollection new.
	aClass allSubclassesDo: [:cls | cls methods do: [:m |
			(m selector = selector 
				and: [ (protocols includes: m protocol) not ])
					ifTrue: [ violating add: m -> m protocol ] ] ].
	self 
		assert: violating isEmpty 
		description: ('Violations are: {1}. 
		Reason: {2} subclasses should have #{3} in protocols: {4}' 
			format: { self explanationFrom: violating . aClass asString. selector. protocols })

]

{ #category : #utilities }
ProperMethodCategorizationTest >> explanationFrom: aCol [

	^ (String streamContents: [:str | 
				aCol do: [:p | p key printOn: str]
					separatedBy: [ str nextPutAll: ' ,'] ]).
]

{ #category : #'tests - object' }
ProperMethodCategorizationTest >> testCloneMethodNeedsToBeInCopyingProtocol [
	"The #clone methods should be in method protocol 'copying'"
	
	self assureAll: #clone areCategorizedIn: #copying whenSubclassOf: Object

]

{ #category : #'tests - object' }
ProperMethodCategorizationTest >> testCopyMethodNeedsToBeInCopyingProtocol [
	"The #copy methods should be in method protocol 'copying'"
	
	self assureAll: #copy areCategorizedIn: #copying whenSubclassOf: Object

]

{ #category : #'tests - object' }
ProperMethodCategorizationTest >> testDeepCopyMethodNeedsToBeInCopyingProtocol [
	"The #deepCopy methods should be in method protocol 'copying'"
	
	self assureAll: #deepCopy areCategorizedIn: #copying whenSubclassOf: Object

]

{ #category : #'tests - object' }
ProperMethodCategorizationTest >> testEqualMethodNeedsToBeInComparingProtocol [
	"The #= method should be in method protocol 'comparing'"
	
	self assureAll: #= areCategorizedIn: #comparing whenSubclassOf: Object

]

{ #category : #'tests - object' }
ProperMethodCategorizationTest >> testFinalizeMethodNeedsToBeInComparingProtocol [
	"The #finalize method should be in method protocol 'finalization'"
	
	self assureAll: #finalize areCategorizedIn: #finalization whenSubclassOf: Object

]

{ #category : #'tests - object' }
ProperMethodCategorizationTest >> testFinalizeValuesMethodNeedsToBeInComparingProtocol [
	"The #finalizeValues methods should be in method protocol 'finalization'"
	
	self assureAll: #finalizeValues areCategorizedIn: #finalization whenSubclassOf: Object

]

{ #category : #'tests - object' }
ProperMethodCategorizationTest >> testHashMethodNeedsToBeInComparingProtocol [
	"The #hash method should be in method protocol 'comparing'"
	
	self assureAll: #hash areCategorizedIn: #comparing whenSubclassOf: Object

]

{ #category : #tests }
ProperMethodCategorizationTest >> testNoEmptyProtocols [
	"Check that we have no protocols left without methods"

	| violating protocolsWithoutMethods |
	violating := Dictionary new.
	ProtoObject withAllSubclasses
		do: [ :cls | 
			protocolsWithoutMethods := cls organization protocolOrganizer protocols select: [ :e | e isEmpty and: [ e canBeRemoved ] ].
			protocolsWithoutMethods notEmpty ifTrue: [ violating at: cls put: protocolsWithoutMethods ] ].

	self assertEmpty: violating
]

{ #category : #tests }
ProperMethodCategorizationTest >> testNoUncategorizedMethods [

	"Check that we have no #'as yet unclassified' protocols left"

	| violating |
	violating := Smalltalk globals allBehaviors select: [ :class | 
		             class protocols includes: #'as yet unclassified' ].

	"we lock in the number of problematic classes, this way it can only improve"
	self assert: violating size <= 151
]

{ #category : #'tests - object' }
ProperMethodCategorizationTest >> testPostCopyMethodNeedsToBeInCopyingProtocol [
	"The #postCopy methods should be in method protocol 'copying'"
	
	self assureAll: #postCopy areCategorizedIn: #copying whenSubclassOf: Object

]

{ #category : #'tests - sunit' }
ProperMethodCategorizationTest >> testRunCaseMethodInSUnitTestsNeedsToBeInRunningProtocol [
	"The #tearDown method in SUnit test classes should be in method protocol 'running'"
	
	self assureAll: #runCase areCategorizedIn: #running whenSubclassOf: TestCase

]

{ #category : #'tests - sunit' }
ProperMethodCategorizationTest >> testSetUpMethodInSUnitTestsNeedsToBeInRunningProtocol [
	"The #setUp method in SUnit test classes should be in method protocol 'running'"

	self assureAll: #setUp areCategorizedInProtocols: #(#running) whenSubclassOf: TestCase

]

{ #category : #'tests - object' }
ProperMethodCategorizationTest >> testShallowCopyMethodNeedsToBeInCopyingProtocol [
	"The #shallowCopy methods should be in method protocol 'copying'"
	
	self assureAll: #shallowCopy areCategorizedIn: #copying whenSubclassOf: Object

]

{ #category : #'tests - sunit' }
ProperMethodCategorizationTest >> testTearDownMethodInSUnitTestsNeedsToBeInRunningProtocol [
	"The #tearDown method in SUnit test classes should be in method protocol 'running'"
	
	self assureAll: #tearDown areCategorizedInProtocols: #(#running) whenSubclassOf: TestCase

]

{ #category : #'tests - object' }
ProperMethodCategorizationTest >> testVeryDeepCopyMethodNeedsToBeInCopyingProtocol [
	"The #veryDeepCopy methods should be in method protocol 'copying'"
	
	self assureAll: #veryDeepCopy areCategorizedIn: #copying whenSubclassOf: Object

]
