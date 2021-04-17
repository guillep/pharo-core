"
This simple example generates 2 cases. Exactly the 2 cases listed in `PaSelectedCasesExampleTest class >>#testParameters` class method.



```
PaSelectedCasesExampleTest class >> testParameters
	^ ParametrizedTestMatrix new
		addCase: { #number1 -> 2. #number2 -> 1.0. #result -> 3 };
		addCase: { #number1 -> (2/3). #number2 -> (1/3). #result -> 1 };
		yourself
```
"
Class {
	#name : #PaSelectedCasesExampleTest,
	#superclass : #ParametrizedTestCase,
	#instVars : [
		'number1',
		'number2',
		'result'
	],
	#category : #'ParametrizedTests-Examples'
}

{ #category : #'building suites' }
PaSelectedCasesExampleTest class >> testParameters [

	^ ParametrizedTestMatrix new
		addCase: { #number1 -> 2. #number2 -> 1.0. #result -> 3 };
		addCase: { #number1 -> (2/3). #number2 -> (1/3). #result -> 1 };
		yourself
]

{ #category : #accessing }
PaSelectedCasesExampleTest >> number1 [
	^ number1
]

{ #category : #accessing }
PaSelectedCasesExampleTest >> number1: anObject [
	number1 := anObject
]

{ #category : #accessing }
PaSelectedCasesExampleTest >> number2 [
	^ number2
]

{ #category : #accessing }
PaSelectedCasesExampleTest >> number2: anObject [
	number2 := anObject
]

{ #category : #accessing }
PaSelectedCasesExampleTest >> result [
	^ result
]

{ #category : #accessing }
PaSelectedCasesExampleTest >> result: anObject [
	result := anObject
]

{ #category : #tests }
PaSelectedCasesExampleTest >> testSum [
	
	self assert: number1 + number2 equals: result
]
