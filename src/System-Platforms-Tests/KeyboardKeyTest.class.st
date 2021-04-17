"
A KeyboardKeyTest is a test class for testing the behavior of KeyboardKey
"
Class {
	#name : #KeyboardKeyTest,
	#superclass : #TestCase,
	#category : #'System-Platforms-Tests-Utilities'
}

{ #category : #tests }
KeyboardKeyTest >> testEqual [ 

	self 
		assert: (KeyboardKey fromCharacter: Character arrowUp) 
		equals: (KeyboardKey new 
			withValue: 65362;
			yourself)
]

{ #category : #tests }
KeyboardKeyTest >> testNamed [
	"These assertions have been written using data available in KeyboardKey class>>#initializeKeyTable"
	self assert: (KeyboardKey named: 'SHIFT_L') equals: (KeyboardKey value: 65505).
	
	self assert: (KeyboardKey named: 'LEFT') equals: (KeyboardKey value: 65361).
	
	self assert: (KeyboardKey named: 'ALT_R') equals: (KeyboardKey value: 65514).
	
	self should: [ KeyboardKey named: 'a' ] raise: NotFound. "We do not distinguish 'a' FROM 'A', it is always 'A'."
	
	self assert: (KeyboardKey named: 'A') equals: (KeyboardKey value: 65).
]

{ #category : #tests }
KeyboardKeyTest >> testValue [
	| key |
	key := KeyboardKey value: 65505.
	self assert: key value equals: 65505.
	self assert: key name equals: 'SHIFT_L'.
	
	key := KeyboardKey value: 65361.
	self assert: key value equals: 65361.
	self assert: key name equals: 'LEFT'.
	
	key := KeyboardKey value: 65514.
	self assert: key value equals: 65514.
	self assert: key name equals: 'ALT_R'.
	
	self should: [ KeyboardKey value: 97 ] raise: NotFound. "We do not distinguish 'a' FROM 'A', it is always 'A'."
	
	key := KeyboardKey value: 65.
	self assert: key value equals: 65.
	self assert: key name equals: 'A'.
]
