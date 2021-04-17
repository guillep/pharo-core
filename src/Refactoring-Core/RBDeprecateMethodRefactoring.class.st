"
I am a refactoring to mark a method as deprecated and replace the implementation by a call to a new method.

oldSelector
	- is a selector which shouldn't be used anymore, it's deprecated
newSelector
	- is a selector which will be used instead of a deprecated one

The implementation of oldSelector is replaced by a call to `#deprecated:on:in:` and the newSelector.

The message `#deprecated:on:in:`  will be used to inform the user about the deprecation.

### Note 
It is recommended to use this refactoring only if number of arguments is either equal in both selectors, or the new one has no arguments at all.
If new selector has fewer number of arguments than the old one, it may lead to unexpected results.
If you use it in other conditions an error may be be occured.
"
Class {
	#name : #RBDeprecateMethodRefactoring,
	#superclass : #RBMethodRefactoring,
	#instVars : [
		'oldSelector',
		'newSelector'
	],
	#category : #'Refactoring-Core-Refactorings'
}

{ #category : #'intance creation' }
RBDeprecateMethodRefactoring class >> model: aRBSmalltalk deprecateMethod: aSelector in: aClass using: newSelector [
	^(self new)
		model: aRBSmalltalk;
		deprecateMethod: aSelector
			in: aClass
			using: newSelector;
		yourself
]

{ #category : #transforming }
RBDeprecateMethodRefactoring >> deprecateMethod: aSelector in: aClass using: newSel [
	oldSelector := aSelector.
	newSelector := newSel.
	class := self classObjectFor: aClass
]

{ #category : #transforming }
RBDeprecateMethodRefactoring >> formNameFor: aSelector [

	| method keywords arguments |
	method := class methodFor: aSelector.
	keywords := method parseTree keywords asOrderedCollection ifNil: [ 
		            '' ].
	arguments := method parseTree arguments ifNil: [ '' ].
	^ (keywords isNotEmpty and: [ arguments isNotEmpty ])
		  ifTrue: [ 
			  String streamContents: [ :s | 
				  keywords with: arguments do: [ :keyword :arg | 
					  s
						  nextPutAll: keyword , ' ' , arg name;
						  nextPutAll: ' ' ] ] ]
		  ifFalse: [ aSelector asString ]
]

{ #category : #transforming }
RBDeprecateMethodRefactoring >> formNewName [
	^ self formNameFor: newSelector
]

{ #category : #transforming }
RBDeprecateMethodRefactoring >> formOldName [
	^ self formNameFor: oldSelector
]

{ #category : #preconditions }
RBDeprecateMethodRefactoring >> preconditions [
	| newCondition |
	newCondition := (RBCondition 
							withBlock: [oldSelector numArgs = newSelector numArgs or: [ newSelector numArgs = 0 ]]
							errorString: 'The new selectors should have the same number of arguments as the old one, or not have them at all').
	^newCondition
]

{ #category : #printing }
RBDeprecateMethodRefactoring >> storeOn: aStream [ 
	aStream nextPut: $(.
	self class storeOn: aStream.
	aStream
		nextPutAll: ' deprecateMethod: #';
		nextPutAll: oldSelector;
		nextPutAll: ' in: '.
	class storeOn: aStream.
	aStream
		nextPutAll: ' using: #';
		nextPutAll: newSelector.
	aStream nextPut: $)
]

{ #category : #transforming }
RBDeprecateMethodRefactoring >> transform [
	| protocol deprecatedSource |
	protocol := (class methodFor: newSelector) protocols.
	deprecatedSource := self formOldName , String cr , String tab
		,
			'self 
		deprecated: ''Use ' , newSelector asString
		,
			' instead''
		on: 	''' , Date today asString
		,
			''' 
		in: ''' , SystemVersion current imageVersionString
		,
			'''.
	^ self ' , self formNewName.
	(model classNamed: class realClass name) compile: deprecatedSource classified: protocol
]
