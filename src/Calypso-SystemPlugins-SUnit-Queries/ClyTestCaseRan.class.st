"
I represent event about test run. I am passed to environment instead of native SUnit events.
 
Internal Representation and Key Implementation Points.

    Instance Variables
	testCase:		<TestCase>
"
Class {
	#name : #ClyTestCaseRan,
	#superclass : #ClassAnnouncement,
	#instVars : [
		'testCase'
	],
	#category : #'Calypso-SystemPlugins-SUnit-Queries'
}

{ #category : #'instance creation' }
ClyTestCaseRan class >> testCase: aClass [
	^self new 
		testCase: aClass
]

{ #category : #testing }
ClyTestCaseRan >> affectsCritiques [
	"It should be packages in critic plugin package 
	but for such simple message we can not do it"
	^false
]

{ #category : #'event processing' }
ClyTestCaseRan >> affectsMethods [
	^true
]

{ #category : #'event processing' }
ClyTestCaseRan >> affectsMethodsDefinedInClass: aClass [

	^testCase == aClass
]

{ #category : #'event processing' }
ClyTestCaseRan >> affectsMethodsDefinedInPackage: aPackage [

	^testCase package == aPackage or: [ aPackage extendsClass: testCase ]
]

{ #category : #'event processing' }
ClyTestCaseRan >> affectsMethodsTaggedWith: tagName [
	^testCase tagsForMethods includes: tagName
]

{ #category : #'event processing' }
ClyTestCaseRan >> affectsPackages [
	"we do not want update packages after every test case run"
	^false
]

{ #category : #'event processing' }
ClyTestCaseRan >> canAffectResultOfMethodQuery: aMethodQuery [

	^true
]

{ #category : #accessing }
ClyTestCaseRan >> classAffected [
	^testCase
]

{ #category : #printing }
ClyTestCaseRan >> printOn: aStream [
	super printOn: aStream.
	aStream nextPut: $(.
	testCase printOn: aStream.
	aStream nextPut: $).
]

{ #category : #accessing }
ClyTestCaseRan >> testCase [
	^ testCase
]

{ #category : #accessing }
ClyTestCaseRan >> testCase: anObject [
	testCase := anObject
]
