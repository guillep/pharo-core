"
I describe the behavior of my sole instance, nil. nil represents a prior value for variables that have not been initialized, or for results which are meaningless.
"
Class {
	#name : #UndefinedObject,
	#superclass : #Object,
	#category : #'Kernel-Objects'
}

{ #category : #accessing }
UndefinedObject class >> allInstances [
	"It is well known there is a single instance"
	
	^Array with: nil
]

{ #category : #accessing }
UndefinedObject class >> allInstancesDo: aBlock [
	"It is well known there is a single instance"
	
	aBlock value: nil
]

{ #category : #'instance creation' }
UndefinedObject class >> new [
	self error: 'You may not create any more undefined objects--use nil'
]

{ #category : #'dependents access' }
UndefinedObject >> addDependent: ignored [ 
	"Refer to the comment in Object|dependents."

	self error: 'Nil should not have dependents'
]

{ #category : #'class hierarchy' }
UndefinedObject >> addSubclass: aClass [
	"Ignored -- necessary to support disjoint class hierarchies"
]

{ #category : #'class hierarchy' }
UndefinedObject >> allSuperclassesDo: aBlockContext [ 
	"Ignored -- necessary to support disjoint class hierarchies"
]

{ #category : #'sets support' }
UndefinedObject >> asCollectionElement [
	"Since nil is a singleton, we need only a single wrapper instance to represent it in set,
	created in advance"
	^ CollectionElement withNil
]

{ #category : #accessing }
UndefinedObject >> at: index put: anObject [ 
	self shouldNotImplement 
]

{ #category : #'bottom context' }
UndefinedObject >> canHandleSignal: exception [
	"When no more handler (on:do:) context left in sender chain this gets called"

	^ false
]

{ #category : #'class hierarchy' }
UndefinedObject >> classBuilder [
	"Answer the object responsible of creating subclasses of myself in the system."
	
		^ self classInstaller new builder
]

{ #category : #'class hierarchy' }
UndefinedObject >> classInstaller [
	"Answer the class responsible of creating classes in the system."
	
	^ Smalltalk classInstaller 
]

{ #category : #'class hierarchy' }
UndefinedObject >> commonSuperclassWith: aClass [ 
	^ self
]

{ #category : #copying }
UndefinedObject >> deepCopy [
	"Only one instance of UndefinedObject should ever be made, so answer 
	with self."
]

{ #category : #'reflective operations' }
UndefinedObject >> doesNotUnderstand: aMessage [

	"Handle the fact that there was an attempt to send the given message to an Undeclared variable (nil), hence the receiver does not understand this message (typically #new)."

	"Testing: (nil activeProcess)"

	<debuggerCompleteToSender>
	| exception resumeValue node |
	[ 
	node := self findUndeclaredVariableIn:
		        thisContext outerContext sender sourceNodeExecuted ] onErrorDo: [ :ex | 
				"This is ugly, but we have a dependency with Opal compiler and 
				it should be extracted. If there is a failure during the bootstrap, this
				dependency produces an infinite loop"
		 ].
	node ifNil: [ ^ super doesNotUnderstand: aMessage ].

	(exception := VariableNotDeclared new)
		message: aMessage;
		variableNode: node;
		receiver: self.

	resumeValue := exception signal.
	^ exception reachedDefaultHandler
		  ifTrue: [ aMessage sentTo: self ]
		  ifFalse: [ resumeValue ]
]

{ #category : #'class hierarchy' }
UndefinedObject >> environment [
	"Necessary to support disjoint class hierarchies."

	^self class environment
]

{ #category : #'reflective operations' }
UndefinedObject >> findUndeclaredVariableIn: ast [
	"Walk the ast of the current statment and find the undeclared variable node, or nil (if none).
	Assumes there is only one such variable in an executing statement"
	
	^ast variableNodes detect: [:node | node isUndeclaredVariable] ifNone: [ nil ]
]

{ #category : #testing }
UndefinedObject >> haltIfNil [
	<debuggerCompleteToSender>
	Halt now
]

{ #category : #'bottom context' }
UndefinedObject >> handleSignal: exception [
	"When no more handler (on:do:) context left in sender chain this gets called.  Return from signal with default action."

	^ exception resumeUnchecked: exception defaultAction
]

{ #category : #testing }
UndefinedObject >> ifNil: aBlock [
	"A convenient test, in conjunction with Object ifNil:"
	"Might be compiled inline for speed, see RBMessageNode>>#isInlineIfNil"
	^ aBlock value
]

{ #category : #testing }
UndefinedObject >> ifNil: nilBlock ifNotNil: ifNotNilBlock [
	"If the receiver is not nil, pass it as argument to the ifNotNilBlock block. else execute the nilBlock block"
	"Might be compiled inline for speed, see RBMessageNode>>#isInlineIfNil"

	"(nil ifNil: [42] ifNotNil: [:o | o +3 ] ) >>> 42"
	"(3  ifNil: [42] ifNotNil: [:o | o +3 ]) >>> 6"

	^ nilBlock value
]

{ #category : #testing }
UndefinedObject >> ifNotNil: aBlock [
	"If the receiver is not nil, pass it as argument to the block."
	"Might be compiled inline for speed, see RBMessageNode>>#isInlineIfNil"

	"(2 ifNotNil: [ :o | o + 3]) >>> 5"
	"(nil ifNotNil: [:o | o +3 ]) >>> nil"

	^ self
]

{ #category : #testing }
UndefinedObject >> ifNotNil: ifNotNilBlock ifNil: nilBlock [ 
	"If the receiver is not nil, pass it as argument to the ifNotNilBlock block. else execute the nilBlock block"
	"Might be compiled inline for speed, see RBMessageNode>>#isInlineIfNil"

	"(nil ifNotNil: [:o | o +3 ] ifNil: [42]) >>> 42"
	"(3 ifNotNil: [:o | o +3 ] ifNil: [42]) >>> 6"
	
	^ nilBlock value
]

{ #category : #testing }
UndefinedObject >> isEmptyOrNil [
	"Answer whether the receiver contains any elements, or is nil.  Useful in numerous situations where one wishes the same reaction to an empty collection or to nil"
	^ true
]

{ #category : #testing }
UndefinedObject >> isLiteral [
	^ true
]

{ #category : #testing }
UndefinedObject >> isNil [ 
	"Refer to the comment in Object|isNil."

	^true
]

{ #category : #testing }
UndefinedObject >> isNotNil [ 
	"Refer to the comment in Object|isNotNil."

	^false
]

{ #category : #testing }
UndefinedObject >> notNil [ 
	"Refer to the comment in Object|notNil."

	^false
]

{ #category : #printing }
UndefinedObject >> printOn: aStream [ 
	"Refer to the comment in Object|printOn:." 

	aStream nextPutAll: 'nil'
]

{ #category : #'class hierarchy' }
UndefinedObject >> removeSubclass: aClass [
	"Ignored -- necessary to support disjoint class hierarchies"
]

{ #category : #copying }
UndefinedObject >> shallowCopy [
	"Only one instance of UndefinedObject should ever be made, so answer 
	with self."
]

{ #category : #printing }
UndefinedObject >> storeOn: aStream [ 
	"Refer to the comment in Object|storeOn:." 

	aStream nextPutAll: 'nil'
]

{ #category : #'class hierarchy' }
UndefinedObject >> subclass: nameOfClass  
	instanceVariableNames: instVarNameList
	classVariableNames: classVarNames
	poolDictionaries: poolDictnames
	category: category [
	"Calling this method is now considered an accident.  If you really want to create a class with a nil superclass, then create the class and then set the superclass using #superclass:"
	Warning signal: ('Attempt to create ', nameOfClass, ' as a subclass of nil.  Possibly a class is being loaded before its superclass.').
	^ Object
		subclass: nameOfClass
		instanceVariableNames: instVarNameList
		classVariableNames: classVarNames
		poolDictionaries: poolDictnames
		category: category

]

{ #category : #'class hierarchy' }
UndefinedObject >> subclassDefinerClass [
	"For disjunct class hierarchies -- how should subclasses of nil be evaluated"
	^self class subclassDefinerClass
]

{ #category : #'class hierarchy' }
UndefinedObject >> subclasses [
	"Return all the subclasses of nil"
	| classList |
	classList := Array new writeStream.
	self subclassesDo:[:class| classList nextPut: class].
	^classList contents
]

{ #category : #'class hierarchy' }
UndefinedObject >> subclassesDo: aBlock [
	"Evaluate aBlock with all subclasses of nil.  Others are not direct subclasses of Class."

	^ Class subclassesDo: [:cl | 
			cl isMeta ifTrue: [aBlock value: cl soleInstance]].
]

{ #category : #'class hierarchy' }
UndefinedObject >> typeOfClass [
	"Necessary to support disjoint class hierarchies."
	^#normal
]

{ #category : #copying }
UndefinedObject >> veryDeepCopyWith: deepCopier [
	"Return self.  I can't be copied.  Do not record me."
]
