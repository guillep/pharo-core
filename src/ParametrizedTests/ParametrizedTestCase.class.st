"
I am a subclass of `TestCase` that implements support for parametrized tests.
A parametrized tests is a test that is run with different configurations.
These configurations are generated from a Matrix.

### How to 
To define parametrized tests just extend this class as a normal test, 
add accessors for the properties to configure and implement the class side method `testParameters`.

When the test class is executed a `TestSuite` is generated with an instance for each of the configured cases. These instances are populated using the accessors to the described properties. 

The class side method `testParameters` returns a test matrix. 
A Matrix offers two protocols: 
- `addCase:` to define an explicit configuration of parameters 
- `forSelector: addOptions:` to define all possible value of a parameter

#### Matrix with some configurations

```
PaSelectedCasesExampleTest class >> testParameters

	^ ParametrizedTestMatrix new
		addCase: { #number1 -> 2. #number2 -> 1.0. #result -> 3 };
		addCase: { #number1 -> (2/3). #number2 -> (1/3). #result -> 1 };
		yourself
```

#### Matrix with all combinations
This test matrix can be generated with cartesian product configurations or a set of well known cases.

An example of #testParameters is: 

```
PaSimpleMatrixExampleTest class >> testParameters

	^ ParametrizedTestMatrix new
		forSelector: #option1 addOptions: #(a b c);
		forSelector: #option2 addOptions: {[1].[2].[3]};
		yourself.
``` 

Each option is constituted from a set of possible values and a selector that is the name of the property to set in the test case instance.

Also each option can be a literal or a block to generate that value. The block has an optional parameter, the parameter is the test case to configure.

In this example the generated cases will be 9. One per each combination of #option1 and #option2. 
The test Case should have a setter for 

Check the `PaSimpleMatrixExampleTest` and  `PaSelectedCasesExampleTest` to see how to use the different possible configurations.
"
Class {
	#name : #ParametrizedTestCase,
	#superclass : #TestCase,
	#instVars : [
		'parametersToUse'
	],
	#category : #'ParametrizedTests-Core'
}

{ #category : #'building suites' }
ParametrizedTestCase class >> buildSuite [

	| expandedMatrix suite |
	
	expandedMatrix := self testParameters expandMatrix.

	expandedMatrix ifEmpty: [ ^ self buildSuiteFromSelectors].

	suite := self suiteClass named: self name.
	expandedMatrix do: [ :expandedParameters | |internalSuite|
		internalSuite := self buildSuiteFromSelectors.
		internalSuite tests do: [ :aTest | aTest parametersToUse: expandedParameters ].
		suite addTests: internalSuite tests.
	].

	^ suite
]

{ #category : #private }
ParametrizedTestCase class >> isAbstract [
	^ self name = #ParametrizedTestCase 
]

{ #category : #'building suites' }
ParametrizedTestCase class >> testParameters [
	"I'm the main hook to define configuration.
	See addCase and forSelector:addOptions: on ParametrizedTestMatrix."
	
	^ ParametrizedTestMatrix new
]

{ #category : #private }
ParametrizedTestCase >> instanceVariablesToKeep [

	^ super instanceVariablesToKeep, #('testSelector' 'parametersToUse')
]

{ #category : #accessing }
ParametrizedTestCase >> nameForReport [

	parametersToUse ifNil: [ ^ super nameForReport ].

	^ String streamContents: [ :s |
		s nextPutAll: self selector asString.
		parametersToUse printElementsOn: s ]

]

{ #category : #accessing }
ParametrizedTestCase >> parametersToUse [
	^ parametersToUse ifNil: [#()]
]

{ #category : #accessing }
ParametrizedTestCase >> parametersToUse: anObject [
	parametersToUse := anObject
]

{ #category : #printing }
ParametrizedTestCase >> printOn: aStream [

	super printOn: aStream.
	parametersToUse ifNotNil: [ parametersToUse printElementsOn: aStream.]
	
]

{ #category : #running }
ParametrizedTestCase >> setUp [
	super setUp.
	self parametersToUse do: [ :aParameter | aParameter applyTo: self ].
	
	"If I am executed without calling buildSuite in the class. I will use the first set of options.
	This is a workaround to work when running from Calypso"
	(self parametersToUse isEmpty and: [self class testParameters isNotEmpty]) 
		ifTrue: [ 
				self class 
						testParameters expandMatrix first 
						do: [ :aParameter | aParameter applyTo: self ] ]
]
