"
ProtoObject establishes minimal behavior required of any object in Pharo, even objects that should balk at normal object behavior. 

Generally these are proxy objects designed to read themselves in from the disk, or to perform some wrapper behavior, before responding to a message. 

ProtoObject has no instance variables, nor should any be added.
"
Class {
	#name : #ProtoObject,
	#superclass : #nil,
	#category : #'Kernel-Objects'
}

{ #category : #comparing }
ProtoObject >> == anObject [ 
	"Primitive. Answer whether the receiver and the argument are the same 
	object (have the same object pointer). Do not redefine the message == in 
	any other class! Essential. No Lookup. Do not override in any subclass. 
	See Object documentation whatIsAPrimitive."

	<primitive: 110>
	self primitiveFailed
]

{ #category : #'reflective operations' }
ProtoObject >> basicIdentityHash [
	"Answer a 22 bits unsigned SmallInteger whose value is related to the receiver's identity.
	
	Primitive. Fails if the receiver is an immediate. Essential.
	See Object documentation whatIsAPrimitive.
	
	Do not override, use #identityHash instead"

	<primitive: 75>
	self primitiveFailed
]

{ #category : #'reflective operations' }
ProtoObject >> become: otherObject [
	"Primitive. Swap the object pointers of the receiver and the argument.
	All variables in the entire system that used to point to the 
	receiver now point to the argument, and vice-versa.
	Fails if either object is a SmallInteger"

	{self} elementsExchangeIdentityWith: {otherObject}
]

{ #category : #'reflective operations' }
ProtoObject >> becomeForward: otherObject [ 
	"Primitive. All variables in the entire system that used to point
	to the receiver now point to the argument.
	Fails if either argument is a SmallInteger."

	{self} elementsForwardIdentityTo: {otherObject}
]

{ #category : #'reflective operations' }
ProtoObject >> becomeForward: otherObject copyHash: copyHash [
	"Primitive. All variables in the entire system that used to point to the receiver now point to the argument.
	If copyHash is true, the argument's identity hash bits will be set to those of the receiver.
	Fails if either argument is a SmallInteger."

	{self} elementsForwardIdentityTo: {otherObject} copyHash: copyHash
]

{ #category : #'reflective operations' }
ProtoObject >> cannotInterpret: aMessage [ 
	 "Handle the fact that there was an attempt to send the given message to the receiver but a null methodDictionary was encountered while looking up the message selector.  Hopefully this is the result of encountering a stub for a swapped out class which induces this exception on purpose."

"If this is the result of encountering a swap-out stub, then simulating the lookup in Smalltalk should suffice to install the class properly, and the message may be resent."

	(self class lookupSelector: aMessage selector) ifNotNil:
		["Simulated lookup succeeded -- resend the message."
		^ aMessage sentTo: self].

	"Could not recover by simulated lookup -- it's an error"
	Error signal: 'MethodDictionary fault'.

	"Try again in case an error handler fixed things"
	^ aMessage sentTo: self
]

{ #category : #'class membership' }
ProtoObject >> class [
	"Primitive. Answer the object which is the receiver's class. Essential. See 
	Object documentation whatIsAPrimitive."

	<primitive: 111>
	self primitiveFailed
]

{ #category : #debugging }
ProtoObject >> doOnlyOnce: aBlock [
	"If the 'one-shot' mechanism is armed, evaluate aBlock once and disarm the one-shot mechanism.  To rearm the mechanism, evaluate  'self rearmOneShot' manually."

	(self class environment at: #OneShotArmed ifAbsent: [ true ])
		ifTrue: [ 
			self class environment at: #OneShotArmed put: false.
			aBlock value ]
]

{ #category : #'reflective operations' }
ProtoObject >> doesNotUnderstand: aMessage [

	<debuggerCompleteToSender>

	^ MessageNotUnderstood new 
		message: aMessage;
		receiver: self;
		signal
]

{ #category : #executing }
ProtoObject >> executeMethod: compiledMethod [
	^ self withArgs: #( ) executeMethod: compiledMethod
]

{ #category : #flagging }
ProtoObject >> flag: aSymbol [

	"Send this message, with a relevant symbol as argument, to flag a message for subsequent retrieval.  For example, you might put the following line in a number of messages:
	self flag: #returnHereUrgently
	Then, to retrieve all such messages, browse all senders of #returnHereUrgently."
]

{ #category : #comparing }
ProtoObject >> identityHash [
	"Answer a SmallInteger whose value is related to the receiver's identity.
	 This method must not be overridden, except by SmallInteger.  As of
	 2014, the 32-bit Spur VM has 22 bits of hash and 31-bit SmallIntegers
	 (30 bits + 1 sign bit).  Shifting by 8 will not create large integers.
	
	 Do not override."

	^self basicIdentityHash bitShift: 8
]

{ #category : #testing }
ProtoObject >> ifNil: nilBlock [
	"Return self, or evaluate the block if I'm == nil (q.v.)"
	"Might be compiled inline for speed, see RBMessageNode>>#isInlineIfNil"
	^ self
]

{ #category : #testing }
ProtoObject >> ifNil: nilBlock ifNotNil: ifNotNilBlock [
	"If the receiver is not nil, pass it as argument to the ifNotNilBlock block. else execute the nilBlock block"
	"Might be compiled inline for speed, see RBMessageNode>>#isInlineIfNil"
	
	"(nil ifNil: [42] ifNotNil: [:o | o +3 ] ) >>> 42"
	"(3  ifNil: [42] ifNotNil: [:o | o +3 ]) >>> 6"
	
	^ ifNotNilBlock cull: self
]

{ #category : #testing }
ProtoObject >> ifNotNil: ifNotNilBlock [
	"Evaluate the block, unless I'm == nil (q.v.). If the receiver is not nil, pass it as argument to the block."
	"Might be compiled inline for speed, see RBMessageNode>>#isInlineIfNil"

	"(2 ifNotNil: [ :o | o + 3]) >>> 5"
	"(nil ifNotNil: [:o | o +3 ]) >>> nil"

	^ ifNotNilBlock cull: self
]

{ #category : #testing }
ProtoObject >> ifNotNil: ifNotNilBlock ifNil: nilBlock [ 
	"If the receiver is not nil, pass it as argument to the ifNotNilBlock block. else execute the nilBlock block"
	"Might be compiled inline for speed, see RBMessageNode>>#isInlineIfNil"

	"(nil ifNotNil: [:o | o +3 ] ifNil: [42]) >>> 42"
	"(3 ifNotNil: [:o | o +3 ] ifNil: [42]) >>> 6"

	^ ifNotNilBlock cull: self
]

{ #category : #initialization }
ProtoObject >> initialize [
	"Subclasses should redefine this method to perform initializations on instance creation" 
]

{ #category : #introspection }
ProtoObject >> instVarsInclude: anObject [
"Answers true if anObject is among my named or indexed instance variables, and false otherwise"

	<primitive: 132>
	1 to: self class instSize do:
		[:i | (self instVarAt: i) == anObject ifTrue: [^ true]].
	1 to: self basicSize do:
		[:i | (self basicAt: i) == anObject ifTrue: [^ true]].
	^ false
]

{ #category : #testing }
ProtoObject >> isImmediateObject [
	^ self class isImmediateClass
]

{ #category : #testing }
ProtoObject >> isNil [
	"Coerces nil to true and everything else to false."

	^false
]

{ #category : #'write barrier' }
ProtoObject >> modificationForbiddenFor: selector index: index value: value [
	^ (ModificationForbidden 
		for: self
		at: index
		with: value
		retrySelector: selector) signal
]

{ #category : #'write barrier' }
ProtoObject >> modificationForbiddenFor: selector value: value [
	^ self modificationForbiddenFor: selector index: nil value: value 
	

]

{ #category : #'block support' }
ProtoObject >> mustBeBoolean [
	"Catches attempts to test truth of non-Booleans.  This message is sent from the VM.  The sending context is rewound to just before the jump causing this exception."
	^ Boolean mustBeBooleanDeOptimize
		ifTrue: [ self mustBeBooleanDeOptimizeIn: thisContext sender  ]
		ifFalse: [ self mustBeBooleanIn: thisContext sender ]
]

{ #category : #'block support' }
ProtoObject >> mustBeBooleanIn: context [
	"context is the where the non-boolean error occurred. Rewind context to before jump then raise error."
	
	"Some constructs are optimized in the compiler :
	#whileTrue:
	#whileFalse:
	#ifTrue:
	#ifFalse:
	#ifTrue:ifFalse:
	#ifFalse:ifTrue:
	So you cannot by default use them on non boolean objects."
	
	"If you really need to use optimized constructs, you can enable Opal compiler and do one of the following :
		- recompile your method with the pragma : <compilerOptions: #(+ optIlineNone)>
		- recompile your class with the method : MyClass class>>compiler 
			^ super compiler options: #(+ optIlineNone)
		- enable the option mustBeBooleanDeOptimize to call mustBeBooleanDeOptimizeIn: instead of this method "

	| proceedValue |
	
	"Set the pc back to the point just before the conditional jump that set off the must be boolean"
	context pc: context previousPc.
	proceedValue := NonBooleanReceiver new
		object: self;
		signal: 'proceed for truth.'.
	^ proceedValue ~~ false
]

{ #category : #'memory scanning' }
ProtoObject >> nextInstance [
	"Primitive. Answer the next instance after the receiver in the 
	enumeration of all instances of this class. Fails if all instances have been 
	enumerated. Essential. See Object documentation whatIsAPrimitive."

	<primitive: 78>
	^nil
]

{ #category : #'memory scanning' }
ProtoObject >> nextObject [
	"Primitive. Answer the next object after the receiver in the 
	enumeration of all objects. Return 0 when all objects have been 
	enumerated."

	<primitive: 139>
	self primitiveFailed.
]

{ #category : #'pointing to' }
ProtoObject >> pointersTo [
	^self pointersToExcept: #()
]

{ #category : #'pointing to' }
ProtoObject >> pointersToAmong: aCollectionOfObjects [
	"Meant to be used as: 
	Smalltalk garbageCollect.
	objs := SystemNavigation default allObjects.
	anyObject pointersToAmong: objs.
	otherObject pointersToAmong: objs.
	
	Avoid multiple calls to allObjects Primitive and multiple gcs.
	"

	^ self pointersToExcept: #() among: aCollectionOfObjects
]

{ #category : #'pointing to' }
ProtoObject >> pointersToExcept: objectsToExclude [
	"Find all objects in the system that hold a pointer to me, excluding those listed"
	| c pointers objectsToAlwaysExclude closure|
	Smalltalk garbageCollect.
	pointers := OrderedCollection new.
	closure := [ :e | (e pointsTo: self) ifTrue: [ pointers add: e ]  ].
	SystemNavigation default allObjectsDo: closure.

	objectsToAlwaysExclude := {
		thisContext.
		thisContext sender.
		thisContext sender sender.
		closure.
		objectsToExclude.
	}.
	c := thisContext.
	^(pointers removeAllSuchThat: [ :ea |
		(ea == thisContext sender) or: [ "warning: this expression is dependent on closure structure of this method"
			(objectsToAlwaysExclude identityIncludes: ea)
				or: [objectsToExclude identityIncludes: ea ]] ]) asArray
]

{ #category : #'pointing to' }
ProtoObject >> pointersToExcept: objectsToExclude among: aCollectionOfObjects [
	"Find all objects in the system that hold a pointer to me, excluding those listed.
	This method is meant to be a faster solution if used several times on several objects rather than calling the GC multiples times.
	See pointersToExcept: for usage.
	"

	| pointers objectsToAlwaysExclude |
	pointers := OrderedCollection new.
	pointers := aCollectionOfObjects select: [ :e | e pointsTo: self ].
	objectsToAlwaysExclude := {thisContext.
	thisContext sender.
	thisContext sender sender.
	objectsToExclude}.
	^ (pointers
		removeAllSuchThat: [ :ea | 
			ea == thisContext sender
				or:
					[ "warning: this expression is dependent on closure structure of this method"
					(objectsToAlwaysExclude identityIncludes: ea)
						or: [ objectsToExclude identityIncludes: ea ] ] ]) asArray
]

{ #category : #'pointing to' }
ProtoObject >> pointsTo: anObject [
	"Answers true if I hold a reference to anObject, or false otherwise
	an object points to a class via the header either directly or indirectly 
	via the compact classes array"

	^ (self instVarsInclude: anObject) or: [ ^self class == anObject]
]

{ #category : #'primitive failure' }
ProtoObject >> primitiveFail [
	"primitiveFail may be invoked by certain methods whose code is translated in C. In such a case primitiveFail and not primitiveFailed
	 should be invoked. The reason is that this code is translated to C by VMMaker. #primitiveFail is 
	implemented in Interpreter of VMMaker."

	^ self primitiveFailed
]

{ #category : #'primitive failure' }
ProtoObject >> primitiveFailed [
	"Announce that a primitive has failed and there is no appropriate Smalltalk code to run."

	self primitiveFailed: thisContext sender selector
]

{ #category : #'primitive failure' }
ProtoObject >> primitiveFailed: selector [
	"Announce that a primitive has failed and there is no appropriate Smalltalk code to run."
	
	PrimitiveFailed signalFor: selector
]

{ #category : #debugging }
ProtoObject >> rearmOneShot [
	"Call this manually to arm the one-shot mechanism; use the mechanism in code by calling
		self doOnlyOnce: <a block>"

	self class environment at: #OneShotArmed put: true

	"self rearmOneShot"

]

{ #category : #'apply primitives' }
ProtoObject >> tryPrimitive: primIndex withArgs: argumentArray [
	"This method is a template that the Smalltalk simulator uses to 
	execute primitives. See Object documentation whatIsAPrimitive."

	<primitive: 118 error: code >
	^ Context primitiveFailTokenFor: code
]

{ #category : #executing }
ProtoObject >> withArgs: argArray executeMethod: compiledMethod [
	"Execute compiledMethod against the receiver and args in argArray"

	<primitive: 188>
	self primitiveFailed
]

{ #category : #comparing }
ProtoObject >> ~~ anObject [
	"Primitive. Answer whether the receiver and the argument are different objects
	(do not have the same object pointer). Do not redefine the message ~~ in 
	any other class! Optional (Assuming == is essential). No Lookup. Do not override in any subclass. 
	See Object documentation whatIsAPrimitive."
	
	<primitive: 169>
	self == anObject
		ifTrue: [^ false]
		ifFalse: [^ true]
]
