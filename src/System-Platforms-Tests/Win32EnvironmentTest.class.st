Class {
	#name : #Win32EnvironmentTest,
	#superclass : #TestCase,
	#category : #'System-Platforms-Tests-Win32'
}

{ #category : #tests }
Win32EnvironmentTest >> testExistingEnvironmentVariableLongerThanBufferShouldReturnValue [

	| value aExpectedValue |
	
	OSPlatform current isWindows 
		ifFalse: [ ^self skip ].

	aExpectedValue := String loremIpsum: 1500.

	OSEnvironment current at: 'ExistingNonEmpty' put: aExpectedValue.
		
	value := OSEnvironment current at: 'ExistingNonEmpty'.
	
	self assert: value equals: aExpectedValue
]

{ #category : #tests }
Win32EnvironmentTest >> testExistingEnvironmentVariableShouldReturnValue [

	| value |
	
	OSPlatform current isWindows 
		ifFalse: [ ^self skip ].

	OSEnvironment current at: 'ExistingNonEmpty' put: 'IamAValue'.
		
	value := OSEnvironment current at: 'ExistingNonEmpty'.
	
	self assert: value equals: 'IamAValue'
]

{ #category : #tests }
Win32EnvironmentTest >> testNonExistingEnvironmentVariableShouldGenerateException [

	OSPlatform current isWindows 
		ifFalse: [ ^self skip ].
		
	self should: [ OSEnvironment current at: 'NonExistingVariable' ] raise: NotFound.
]
