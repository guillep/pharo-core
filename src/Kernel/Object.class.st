"
`Object` is the root class for almost all of the other classes in the class hierarchy. The exceptions are ProtoObject (the superclass of Object) and its subclasses.

Class `Object` provides default behavior common to all normal objects, such as access, copying, comparison, error handling, message sending, and reflection. Also utility messages that all objects should respond to are defined here.

`Object` has no instance variables, nor should any be added. This is due to several classes of objects that inherit from Object that have special implementations (SmallInteger and UndefinedObject for example) or the VM knows about and depends on the structure and layout of certain standard classes.

Class Variables:
	DependentsFields		an IdentityDictionary
		Provides a virtual 'dependents' field so that any object may have one
		or more dependent views, synchronized by the changed:/update: protocol.
		Note that class Model has a real slot for its dependents, and overrides
		the associated protocol with more efficient implementations.

Because `Object` is the root of the inheritance tree, methods are often defined in Object to give all objects special behaviors needed by certain subsystems or applications, or to respond to certain general test messages such as isMorph.


###Miscellanous Discussions

About `at:` index accepting float and not only integers
 
This behavior is also free in the sense that the failure code is only invoked when the primitive fails and so adds nothing to the cost of successful accesses, which are the high dynamic frequency operation.  It will also show up under
profiling if one is concerned about efficiency, and so isn't a hidden cost.

It is also in keeping with Pharo's mixed mode/arbitrary precision
implicit coercion number system that one *can* use fractions or floats as
indices.  Stripping out coercions like this will make the system more brittle.  So 
please do *not* remove this hack.  I think it's a feature and a useful one.

Can you give me an example that demonstrates the usefulness of this feature?

```
| a r |
a := Array new: 10 withAll: 0.
r := Random new.
100 timesRepeat: [| v | v := r next * 10 + 1. a at: v put: (a at: v) + 1].
a
```

i.e. I didn't have to provide an explicit rounding step.  That's useful.  But in general anywhere 
where an index is derived by some calculation not having to provide the rounding step could be 
useful/helpful/more concise.  e.g. (n roundTo: 0.1) * 10 vs ((n roundTo: 0.1) * 10) asInteger.

Some thought went into the original choice.  It is not a hack but there by intent.  The integers are 
simply a subset of the reals and forcing the programmer to use them is favouring the machine 
above the programmer.

But I think you should justify getting rid of it rather than my having to justify keeping it.  Getting 
rid of it risks breaking code.  If it is there but does not harm then why get rid of it?

best Eliot Miranda 
"
Class {
	#name : #Object,
	#superclass : #ProtoObject,
	#classVars : [
		'DependentsFields'
	],
	#category : #'Kernel-Objects'
}

{ #category : #'class initialization' }
Object class >> flushDependents [
	DependentsFields keysAndValuesDo:[:key :dep|
		key ifNotNil:[key removeDependent: nil].
	].
	DependentsFields finalizeValues.
]

{ #category : #documentation }
Object class >> howToModifyPrimitives [
	"You are allowed to write methods which specify primitives, but please use 
	caution.  If you make a subclass of a class which contains a primitive method, 
	the subclass inherits the primitive.  The message which is implemented 
	primitively may be overridden in the subclass (E.g., see at:put: in String's 
	subclass Symbol).  The primitive behavior can be invoked using super (see 
	Symbol string:). 
	 
	A class which attempts to mimic the behavior of another class without being 
	its subclass may or may not be able to use the primitives of the original class.  
	In general, if the instance variables read or written by a primitive have the 
	same meanings and are in the same fields in both classes, the primitive will 
	work.  

	For certain frequently used 'special selectors', the compiler emits a 
	send-special-selector bytecode instead of a send-message bytecode.  
	Special selectors were created because they offer two advantages.  Code 
	which sends special selectors compiles into fewer bytes than normal.  For 
	some pairs of receiver classes and special selectors, the interpreter jumps 
	directly to a primitive routine without looking up the method in the class.  
	This is much faster than a normal message lookup. 
	 
	A selector which is a special selector solely in order to save space has a 
	normal behavior.  Methods whose selectors are special in order to 
	gain speed contain the comment, 'No Lookup'.  When the interpreter 
	encounters a send-special-selector bytecode, it checks the class of the 
	receiver and the selector.  If the class-selector pair is a no-lookup pair, 
	then the interpreter swiftly jumps to the routine which implements the 
	corresponding primitive.  (A special selector whose receiver is not of the 
	right class to make a no-lookup pair, is looked up normally).  The pairs are 
	listed below.  No-lookup methods contain a primitive number specification, 
	<primitive: xx>, which is redundant.  Since the method is not normally looked 
	up, deleting the primitive number specification cannot prevent this 
	primitive from running.  If a no-lookup primitive fails, the method is looked 
	up normally, and the expressions in it are executed. 
	 
	No Lookup pairs of (class, selector) 
	 
	SmallInteger with any of		+ - * /  \\  bitOr: bitShift: bitAnd:  // 
	SmallInteger with any of		=  ~=  >  <  >=  <= 
	Any class with					== 
	Any class with 					@ 
	Point with either of				x y 
	Context with					blockCopy: 
	BlockContext with either of 		value value:
	"

	self error: 'comment only'
]

{ #category : #'class initialization' }
Object class >> initialize [
	"Object initialize"
	DependentsFields ifNil:[ self initializeDependentsFields ]
]

{ #category : #'class initialization' }
Object class >> initializeDependentsFields [
	<script: 'Object initialize'>
	
	DependentsFields := WeakIdentityKeyDictionary new

]

{ #category : #'instance creation' }
Object class >> newFrom: aSimilarObject [
	"Create an object that has similar contents to aSimilarObject. If the classes have any instance variables with the same names, copy them across. If this is bad for a class, override this method."

	^ (self isVariable
		ifTrue: [self basicNew: aSimilarObject basicSize]
		ifFalse: [self basicNew]) copySameFrom: aSimilarObject
]

{ #category : #'class initialization' }
Object class >> reInitializeDependentsFields [
	<script>

	| oldFields |
	oldFields := DependentsFields.
	DependentsFields := WeakIdentityKeyDictionary new.
	oldFields
		keysAndValuesDo: [ :obj :deps | deps do: [ :d | obj addDependent: d ] ]
]

{ #category : #'instance creation' }
Object class >> readFrom: textStringOrStream [
	"Create an object based on the contents of textStringOrStream."

	| object |
	object := self class compiler evaluate: textStringOrStream.
	(object isKindOf: self) ifFalse: [self error: self name, ' expected'].
	^object
]

{ #category : #documentation }
Object class >> whatIsAPrimitive [
	"Some messages in the system are responded to primitively. A primitive   
	response is performed directly by the interpreter rather than by evaluating   
	expressions in a method. The methods for these messages indicate the   
	presence of a primitive response by including <primitive: xx> or 
	<primitive: 79 error: ec>before the first expression in the method.   
	
	In the second case, ec is a special temporary variable that holds an error code. 
	In the VM primitive, failure is indicated by a variable called primFailCode being 
	non-zero. On activating a method with a failing primitive, if the index is in 
	bounds of the 	primitiveFailCodes array in the VMspecialObjectsArray then the 
	failure code substitutes the symbol in the 	primitiveFailCodes array, otherwise 
	it supplies the integer value.
	  
	Primitives exist for several reasons. Certain basic or 'primitive' 
	operations cannot be performed in any other way. Smalltalk without 
	primitives can move values from one variable to another, but cannot add two 
	SmallIntegers together. Many methods for arithmetic and comparison 
	between numbers are primitives. Some primitives allow Smalltalk to 
	communicate with I/O devices such as the disk, the display, and the keyboard. 
	Some primitives exist only to make the system run faster; each does the same 
	thing as a certain Smalltalk method, and its implementation as a primitive is 
	optional.  
	  
	When the Smalltalk interpreter begins to execute a method which specifies a 
	primitive response, it tries to perform the primitive action and to return a 
	result. If the routine in the interpreter for this primitive is successful, 
	it will return a value and the expressions in the method will not be evaluated. 
	If the primitive routine is not successful, the primitive 'fails', and the 
	Smalltalk expressions in the method are executed instead. These 
	expressions are evaluated as though the primitive routine had not been 
	called.  
	  
	The Smalltalk code that is evaluated when a primitive fails usually 
	anticipates why that primitive might fail. If the primitive is optional, the 
	expressions in the method do exactly what the primitive would have done (See 
	Number @). If the primitive only works on certain classes of arguments, the 
	Smalltalk code tries to coerce the argument or appeals to a superclass to find 
	a more general way of doing the operation (see SmallInteger +). If the 
	primitive is never supposed to fail, the expressions signal an error (see 
	SmallInteger asFloat).  
	  
	Each method that specifies a primitive has a comment in it. If the primitive is 
	optional, the comment will say 'Optional'. An optional primitive that is not 
	implemented always fails, and the Smalltalk expressions do the work 
	instead.  
	 
	If a primitive is not optional, the comment will say, 'Essential'. Some 
	methods will have the comment, 'No Lookup'. See Object 
	howToModifyPrimitives for an explanation of special selectors which are 
	not looked up.  
	  
	For the primitives for +, -, *, and bitShift: in SmallInteger, and truncated 
	in Float, the primitive constructs and returns a 16-bit 
	LargePositiveInteger when the result warrants it. Returning 16-bit 
	LargePositiveIntegers from these primitives instead of failing is 
	optional in the same sense that the LargePositiveInteger arithmetic 
	primitives are optional. The comments in the SmallInteger primitives say, 
	'Fails if result is not a SmallInteger', even though the implementor has the 
	option to construct a LargePositiveInteger. For further information on 
	primitives, see the 'Primitive Methods' part of the chapter on the formal 
	specification of the interpreter in the Smalltalk book."
	
	

	self error: 'comment only'
]

{ #category : #associating }
Object >> -> anObject [
	"Answer an Association between self and anObject"
	"The following example creates an association whose key is number 1 and value string 'one'."

	"(1 -> 'one') key >>> 1"
	"(1 -> 'one') value >>> 'one'"
	
	"Note that key and value can be ANY object."
	
	^Association key: self value: anObject
]

{ #category : #comparing }
Object >> = anObject [ 
	"Answer whether the receiver and the argument represent the same 
	object. If = is redefined in any subclass, consider also redefining the 
	message hash."

	^self == anObject 
]

{ #category : #finalization }
Object >> actAsExecutor [
	"Prepare the receiver to act as executor for any resources associated with it"
	self breakDependents
]

{ #category : #converting }
Object >> adaptToFloat: rcvr andCompare: selector [ 
	"If I am involved in comparison with a Float.
	Default behaviour is to process comparison as any other selectors."
	^ self adaptToFloat: rcvr andSend: selector
]

{ #category : #converting }
Object >> adaptToFloat: rcvr andSend: selector [
	"If no method has been provided for adapting an object to a Float,
	then it may be adequate to simply adapt it to a number."
	^ self adaptToNumber: rcvr andSend: selector
]

{ #category : #converting }
Object >> adaptToFraction: rcvr andCompare: selector [ 
	"If I am involved in comparison with a Fraction.
	Default behaviour is to process comparison as any other selectors."
	^ self adaptToFraction: rcvr andSend: selector
]

{ #category : #converting }
Object >> adaptToFraction: rcvr andSend: selector [
	"If no method has been provided for adapting an object to a Fraction,
	then it may be adequate to simply adapt it to a number."
	^ self adaptToNumber: rcvr andSend: selector
]

{ #category : #converting }
Object >> adaptToInteger: rcvr andCompare: selector [ 
	"If I am involved in comparison with an Integer.
	Default behaviour is to process comparison as any other selectors."
	^ self adaptToInteger: rcvr andSend: selector
]

{ #category : #converting }
Object >> adaptToInteger: rcvr andSend: selector [
	"If no method has been provided for adapting an object to a Integer,
	then it may be adequate to simply adapt it to a number."
	^ self adaptToNumber: rcvr andSend: selector
]

{ #category : #dependencies }
Object >> addDependent: anObject [
	"Make the given object one of the receiver's dependents."

	| dependents |
	dependents := self dependents.
	(dependents includes: anObject) ifFalse:
		[self myDependents: (dependents copyWithDependent: anObject)].
	^ anObject
]

{ #category : #converting }
Object >> as: aSimilarClass [
	"Create an object of class aSimilarClass that has similar contents to the receiver if the object is not already an instance of this class."

	aSimilarClass == self class ifTrue: [ ^ self ].

	^ aSimilarClass newFrom: self
]

{ #category : #converting }
Object >> asCollectionElement [
	"Answer an object, which can be put into a Set as element , wrapped
	by one of SetElement instance, if necessary. 
	Default implementation is to answer self"

]

{ #category : #converting }
Object >> asLink [
	"Answer a string that represents the receiver."

	^ ValueLink value: self
]

{ #category : #converting }
Object >> asOrderedCollection [
	"Answer an OrderedCollection with the receiver as its only element."

	^ OrderedCollection with: self
]

{ #category : #converting }
Object >> asString [
	"Answer a string that represents the receiver."

	^ self printString 
]

{ #category : #asserting }
Object >> assert: aBlock [
	"Throw an assertion error if aBlock does not evaluates to true.
	We check for true explicitly to make the assertion fail for non booleans"
	<debuggerCompleteToSender>
	self assert: aBlock description: 'Assertion failed'.
]

{ #category : #asserting }
Object >> assert: aBlock description: aStringOrBlock [
	"Throw an assertion error if aBlock does not evaluates to true."
	<debuggerCompleteToSender>
	aBlock value 
		ifFalse: [ AssertionFailure signal: aStringOrBlock value ]
]

{ #category : #accessing }
Object >> at: index [ 
	"Primitive. Assumes receiver is indexable. Answer the value of an 
	indexable element in the receiver. Fail if the argument index is not an 
	Integer or is out of bounds. Essential. See Object documentation 
	whatIsAPrimitive. Read the class comment for a discussion about that the fact
	that the index can be a float."

	<primitive: 60>
	index isInteger ifTrue:
		[self class isVariable
			ifTrue: [self errorSubscriptBounds: index]
			ifFalse: [self errorNotIndexable]].
	self errorNonIntegerIndex
]

{ #category : #accessing }
Object >> at: index put: value [ 
	"Primitive. Assumes receiver is indexable. Store the argument value in 
	the indexable element of the receiver indicated by index. Fail if the 
	index is not an Integer or is out of bounds. Or fail if the value is not of 
	the right type for this kind of collection. Answer the value that was 
	stored. Essential. See Object documentation whatIsAPrimitive."

	<primitive: 61>
	index isInteger 
		ifTrue: [self class isVariable
			ifTrue: [(index between: 1 and: self size)
				ifFalse: [ ^ self errorSubscriptBounds: index]]
			ifFalse: [ ^ self errorNotIndexable ]]
		ifFalse: [ ^ self errorNonIntegerIndex ].
	self isReadOnlyObject 
		ifTrue: [ ^ self modificationForbiddenFor: #at:put: index: index value: value ].
	self errorImproperStore 
]

{ #category : #'write barrier' }
Object >> attemptToAssign: value withIndex: index [ 
	"Called by the VM when assigning an instance variable of an immutable object.
	Upon return, executing will resume *after* the inst var assignment. If the inst var mutation has to be 
	performed, do it manually here in the call back with instVarAt:put:.
	This method has to return *no* value by jumping to the context's sender"
	
	self modificationForbiddenFor: #instVarAt:put: index: index value: value.

	thisContext sender jump
	"CAN'T REACH"
]

{ #category : #accessing }
Object >> basicAt: index [ 
	"Primitive. Assumes receiver is indexable. Answer the value of an 
	indexable element in the receiver. Fail if the argument index is not an 
	Integer or is out of bounds. Essential. Do not override in a subclass. See 
	Object documentation whatIsAPrimitive."

	<primitive: 60>
	index isInteger ifTrue: [self errorSubscriptBounds: index].
	self errorNonIntegerIndex
]

{ #category : #accessing }
Object >> basicAt: index put: value [ 
	"Primitive. Assumes receiver is indexable. Store the second argument 
	value in the indexable element of the receiver indicated by index. Fail 
	if the index is not an Integer or is out of bounds. Or fail if the value is 
	not of the right type for this kind of collection. Answer the value that 
	was stored. Essential. Do not override in a subclass. See Object 
	documentation whatIsAPrimitive."

	<primitive: 61>
	index isInteger 
		ifTrue: [self class isVariable
			ifTrue: [(index between: 1 and: self size)
				ifFalse: [ ^ self errorSubscriptBounds: index ]]
			ifFalse: [ ^ self errorNotIndexable ]]
		ifFalse: [ ^ self errorNonIntegerIndex ].
	self isReadOnlyObject 
		ifTrue: [ ^ self modificationForbiddenFor: #basicAt:put: index: index value: value ].
	self errorImproperStore 
]

{ #category : #accessing }
Object >> basicSize [
	"Primitive. Answer the number of indexable variables in the receiver. 
	This value is the same as the largest legal subscript. Essential. Do not 
	override in any subclass. See Object documentation whatIsAPrimitive."

	<primitive: 62>
	"The number of indexable fields of fixed-length objects is 0"
	^0	
]

{ #category : #'write barrier' }
Object >> beReadOnlyObject [
	"If the VM supports read-only objects it will not write to read-only objects.
	 An attempt to write to an instance variable of a read-only object will
	 cause the VM to send attemptToAssign:withIndex: to the read-only object.
	 An attempt to modify a read-only object in a primitive will cause the
	 primitive to fail with a #'no modification' error code.
	 Set the read-only flag of the receiver to true and answer the previous vaue of the flag."
	^self setIsReadOnlyObject: true
]

{ #category : #'write barrier' }
Object >> beRecursivelyReadOnlyObject [
	^self recursivelySetIsReadOnlyObject: true
]

{ #category : #'write barrier' }
Object >> beRecursivelyWritableObject [
	^self recursivelySetIsReadOnlyObject: false
]

{ #category : #'write barrier' }
Object >> beWritableObject [
	"If the VM supports read-only objects it will not write to read-only objects.
	 An attempt to write to an instance variable of a read-only object will
	 cause the VM to send attemptToAssign:withIndex: to the read-only object.
	 An attempt to modify a read-only object in a primitive will cause the
	 primitive to fail with a #'no modification' error code.
	 Set the read-only flag of the receiver to false and answer the previous vaue of the flag."
	^self setIsReadOnlyObject: false
]

{ #category : #binding }
Object >> bindingOf: aString [
	^nil
]

{ #category : #dependencies }
Object >> breakDependents [
	"Remove all of the receiver's dependents."

	self myDependents: nil
]

{ #category : #dependencies }
Object >> canDiscardEdits [
	"Answer true if none of the views on this model has unaccepted edits that matter."

	self dependents
		do: [:each | each canDiscardEdits ifFalse: [^ false]]
		without: self.
	^ true
]

{ #category : #'casing-To be deprecated' }
Object >> caseError [
	"DO NOT USE THIS METHOD! It will be removed from Pharo."
	"Report an error from an in-line or explicit case statement."

	self error: 'Case not found (', self printString, '), and no otherwise clause'
]

{ #category : #'casing-To be deprecated' }
Object >> caseOf: aBlockAssociationCollection [
	"DO NOT USE THIS METHOD! It will be removed from Pharo."

	"The elements of aBlockAssociationCollection are associations between blocks.
	 Answer the evaluated value of the first association in aBlockAssociationCollection
	 whose evaluated key equals the receiver.  If no match is found, report an error."

	^ self caseOf: aBlockAssociationCollection otherwise: [self caseError]

"| z | z := {[#a]->[1+1]. ['b' asSymbol]->[2+2]. [#c]->[3+3]}. #b caseOf: z"
"| z | z := {[#a]->[1+1]. ['d' asSymbol]->[2+2]. [#c]->[3+3]}. #b caseOf: z"
"The following are compiled in-line:"
"#b caseOf: {[#a]->[1+1]. ['b' asSymbol]->[2+2]. [#c]->[3+3]}"
"#b caseOf: {[#a]->[1+1]. ['d' asSymbol]->[2+2]. [#c]->[3+3]}"
]

{ #category : #'casing-To be deprecated' }
Object >> caseOf: aBlockAssociationCollection otherwise: aBlock [
	"DO NOT USE THIS METHOD! It will be removed from Pharo."
	
	"The elements of aBlockAssociationCollection are associations between blocks.
	 Answer the evaluated value of the first association in aBlockAssociationCollection
	 whose evaluated key equals the receiver.  If no match is found, answer the result
	 of evaluating aBlock."

	aBlockAssociationCollection associationsDo:
		[:assoc | (assoc key value = self) ifTrue: [^assoc value value]].
	^ aBlock value

"| z | z := {[#a]->[1+1]. ['b' asSymbol]->[2+2]. [#c]->[3+3]}. #b caseOf: z otherwise: [0]"
"| z | z := {[#a]->[1+1]. ['d' asSymbol]->[2+2]. [#c]->[3+3]}. #b caseOf: z otherwise: [0]"
"The following are compiled in-line:"
"#b caseOf: {[#a]->[1+1]. ['b' asSymbol]->[2+2]. [#c]->[3+3]} otherwise: [0]"
"#b caseOf: {[#a]->[1+1]. ['d' asSymbol]->[2+2]. [#c]->[3+3]} otherwise: [0]"
]

{ #category : #updating }
Object >> changed [
	"Receiver changed in a general way; inform all the dependents by 
	sending each dependent an update: message."

	self changed: self
]

{ #category : #updating }
Object >> changed: aParameter [ 
	"Receiver changed. The change is denoted by the argument aParameter. 
	Usually the argument is a Symbol that is part of the dependent's change 
	protocol. Inform all of the dependents."

	self dependents do: [:aDependent | aDependent update: aParameter]
]

{ #category : #updating }
Object >> changed: anAspect with: anObject [
	"Receiver changed. The change is denoted by the argument anAspect. 
	Usually the argument is a Symbol that is part of the dependent's change 
	protocol. Inform all of the dependents. Also pass anObject for additional information."

	self dependents do: [:aDependent | aDependent update: anAspect with: anObject]
]

{ #category : #introspection }
Object >> className [
	"Answer a string characterizing the receiver's class, for use in list views for example"

	^ self class name asString
]

{ #category : #copying }
Object >> clone [
	"Answer a shallow copy of the receiver."
	<primitive: 148 error: ec>
	| class newObject |
	ec == #'insufficient object memory' ifFalse:
		[^self primitiveFailed].
	"If the primitive fails due to insufficient memory, instantiate via basicNew: to invoke
	 the garbage collector before retrying, and use copyFrom: to copy state."
	newObject := (class := self class) isVariable
					ifTrue: 
						[class isCompiledMethodClass
							ifTrue:
								[class newMethod: self basicSize - self initialPC + 1 header: self header]
							ifFalse:
								[class basicNew: self basicSize]]
					ifFalse:
						[class basicNew].
	^newObject copyFrom: self
]

{ #category : #copying }
Object >> copy [
	"Answer another instance just like the receiver. Subclasses typically override postCopy; they typically do not override shallowCopy. Copy is a template method in the sense of Design Patterns. So do not override it. Override postCopy instead. Pay attention that normally you should call postCopy of your superclass too."

	^self shallowCopy postCopy
]

{ #category : #copying }
Object >> copyFrom: anotherObject [
	"Copy to myself all instance variables I have in common with anotherObject.  This is dangerous because it ignores an object's control over its own inst vars.  "

	| mine his |
	<primitive: 168>
	mine := self class allInstVarNames.
	his := anotherObject class allInstVarNames.
	1 to: (mine size min: his size) do: [:ind |
		(mine at: ind) = (his at: ind) ifTrue: [
			self instVarAt: ind put: (anotherObject instVarAt: ind)]].
	self class isVariable & anotherObject class isVariable ifTrue: [
		1 to: (self basicSize min: anotherObject basicSize) do: [:ind |
			self basicAt: ind put: (anotherObject basicAt: ind)]].
]

{ #category : #copying }
Object >> copySameFrom: otherObject [
	"Copy to myself all instance variables named the same in otherObject.
	This ignores otherObject's control over its own inst vars."

	| myInstVars otherInstVars |
	myInstVars := self class allInstVarNames.
	otherInstVars := otherObject class allInstVarNames.
	myInstVars doWithIndex: [:each :index | | match |
		(match := otherInstVars indexOf: each) > 0 ifTrue:
			[self instVarAt: index put: (otherObject instVarAt: match)]].
	1 to: (self basicSize min: otherObject basicSize) do: [:i |
		self basicAt: i put: (otherObject basicAt: i)].

]

{ #category : #copying }
Object >> deepCopy [
	"Answer a copy of the receiver with its own copy of each instance variable. deepCopy does a deep copy. It should never be overridden and only be used if you want to get these very specific semantics.
It doesn't handle cycles, #veryDeepCopy does. In the future we will make it handle cycles and deprecate veryDeepCopy"


	| newObject class index |
	class := self class.
	(class == Object) ifTrue: [^self].
	class isVariable
		ifTrue: 
			[index := self basicSize.
			newObject := class basicNew: index.
			[index > 0]
				whileTrue: 
					[newObject basicAt: index put: (self basicAt: index) deepCopy.
					index := index - 1]]
		ifFalse: [newObject := class basicNew].
	index := class instSize.
	[index > 0]
		whileTrue: 
			[newObject instVarAt: index put: (self instVarAt: index) deepCopy.
			index := index - 1].
	^newObject
]

{ #category : #dependencies }
Object >> dependents [
	"Answer a collection of objects that are 'dependent' on the receiver;
	 that is, all objects that should be notified if the receiver changes."

	^ self myDependents ifNil: [#()]
]

{ #category : #deprecation }
Object >> deprecated: anExplanationString [
	"Warn that the sending method has been deprecated"
	
	Deprecation new
		context: thisContext sender;
		explanation: anExplanationString;
		signal
]

{ #category : #deprecation }
Object >> deprecated: anExplanationString on: date in: version [
	"Warn that the sending method has been deprecated"
	
	Deprecation new
		context: thisContext sender;
		explanation: anExplanationString;
		date: date;
		version: version;
		signal
]

{ #category : #deprecation }
Object >> deprecated: anExplanationString on: date in: version transformWith: aRule [
	"Automatically tranform the deprecated call"
	
	Deprecation new
		context: thisContext sender;
		explanation: anExplanationString;
		date: date;
		version: version;
		rule: aRule;
		transform.
		
]

{ #category : #deprecation }
Object >> deprecated: anExplanationString on: date in: version transformWith: aRule when: conditionBlock [
	"Automatically tranform the deprecated call if it matches the condition"
	
	Deprecation new
		context: thisContext sender;
		explanation: anExplanationString;
		date: date;
		version: version;
		rule: aRule;
		condition: conditionBlock;
		transform.
		
]

{ #category : #deprecation }
Object >> deprecated: anExplanationString transformWith: aRule [
	"Automatically tranform the deprecated call"
	
	Deprecation new
		context: thisContext sender;
		explanation: anExplanationString;
		rule: aRule;
		transform.
		
]

{ #category : #deprecation }
Object >> deprecated: anExplanationString transformWith: aRule when: conditionBlock [
	"Automatically tranform the deprecated call if it matches the condition"
	
	Deprecation new
		context: thisContext sender;
		explanation: anExplanationString;
		rule: aRule;
		condition: conditionBlock;
		transform.
		
]

{ #category : #displaying }
Object >> displayString [
	"While printString is about to give a detailled information about an object, displayString is a message that should return a short string-based representation to be used by list and related UI frameworks. By default, simply return printString. Subclasses should not override this method but instead stream based method #displayStringOn:"
	
	^ self displayStringLimitedTo: 1000
]

{ #category : #displaying }
Object >> displayStringLimitedTo: limit [
	"Answer a String whose characters are a description of the receiver.
	If you want to print without a character limit, use fullDisplayString."
	^self printStringLimitedTo: limit using: [:s | self displayStringOn: s]
]

{ #category : #displaying }
Object >> displayStringOn: aStream [
	"While #printOn: is about to give a detailled information about an object, #displayStringOn: is a message that should return a string-based representation to be used by list and related UI frameworks. By default, simply use printOn: method.
	Subclasses should override this method instead of #displayString"

	self printOn: aStream
]

{ #category : #'reflective operations' }
Object >> doesNotUnderstand: aMessage [ 
	<debuggerCompleteToSender>
	 "Handle the fact that there was an attempt to send the given message to the receiver but the receiver does not understand this message (typically sent from the machine when a message is sent to the receiver and no method is defined for that selector)."
	"Testing: (3 activeProcess)"
		
	| exception resumeValue |
	(exception := MessageNotUnderstood new)
		message: aMessage;
		receiver: self.
	resumeValue := exception signal.
	^exception reachedDefaultHandler
		ifTrue: [aMessage sentTo: self]
		ifFalse: [resumeValue]
]

{ #category : #accessing }
Object >> enclosedElement [
	"The receiver is included into a set as an element. 
	Since some objects require wrappers (see SetElement) to be able to be included into a Set,
	a set sends this message to its element to make sure it getting real object,
	instead of its wrapper.
	Only SetElement instance or its subclasses allowed to answer something different than receiver itself"
	

]

{ #category : #'error handling' }
Object >> error [
	"Throw a generic Error exception."
	<debuggerCompleteToSender>
	^ self error: 'Error!'
]

{ #category : #'error handling' }
Object >> error: aString [
	"Throw a generic Error exception."
	<debuggerCompleteToSender>
	^ Error new signal: aString
]

{ #category : #private }
Object >> errorImproperStore [
	"Create an error notification that an improper store was attempted."

	self error: 'Improper store into indexable object'
]

{ #category : #private }
Object >> errorNonIntegerIndex [
	"Create an error notification that an improper object was used as an index."

	self error: 'only integers should be used as indices'
]

{ #category : #private }
Object >> errorNotIndexable [
	"Create an error notification that the receiver is not indexable."

	self error: ('Instances of {1} are not indexable' format: {self class name})
]

{ #category : #private }
Object >> errorSubscriptBounds: index [ 
	"Create an error notification that an improper integer was used as an index."

	SubscriptOutOfBounds signalFor: index
]

{ #category : #finalization }
Object >> executor [
	"Return an object which can act as executor for finalization of the receiver"
	^self shallowCopy actAsExecutor
]

{ #category : #'error handling' }
Object >> explicitRequirement [
	"If one of the superclasses can perform the selector, we execute the method of that class, otherwise, the explicit requirement error is thrown"
	<debuggerCompleteToSender>
	| originalMethod originalArguments errorBlock originalReceiver callingContext originalSelector |
	errorBlock := [ ^ self error: 'Explicitly required method' ].
	callingContext := thisContext sender.
	originalMethod := callingContext compiledCode method.
	originalMethod isFromTrait
		ifFalse: errorBlock.
	originalReceiver := callingContext receiver.
	originalSelector := originalMethod selector.
	originalArguments := callingContext arguments.
	originalReceiver class superclass
		withAllSuperclassesDo: [ :superClass | 
			superClass
				compiledMethodAt: originalSelector
				ifPresent: [ :method | 
					(method isProvided or: [ method isFromTrait not ])
						ifTrue: [ callingContext
								return:
									(method
										valueWithReceiver: originalReceiver
										arguments: originalArguments) ] ] ].
	errorBlock value
]

{ #category : #finalization }
Object >> finalizationRegistry [
	"Answer the finalization registry associated with the receiver."
	^WeakRegistry default
]

{ #category : #finalization }
Object >> finalize [
	"Finalize the resource associated with the receiver. This message should only be sent during the finalization process. There is NO garantuee that the resource associated with the receiver hasn't been free'd before so take care that you don't run into trouble - this all may happen with interrupt priority."
]

{ #category : #enumerating }
Object >> flattenOn: aStream [
		aStream nextPut: self
]

{ #category : #displaying }
Object >> fullDisplayString [
	"Answer a String whose characters are a description of the receiver suitable for UI"

	^ String streamContents: [:s | self displayStringOn: s]
]

{ #category : #printing }
Object >> fullPrintString [
	"Answer a String whose characters are a description of the receiver."

	^ String streamContents: [:s | self printOn: s]
]

{ #category : #halting }
Object >> halt [
	"This is the typical message to use for inserting breakpoints during debugging."
	<debuggerCompleteToSender>
	Halt now
]

{ #category : #halting }
Object >> halt: aString [ 
	<debuggerCompleteToSender>
	Halt now: aString
]

{ #category : #halting }
Object >> haltFromCount: anInteger [
	"Always halt after a count has been reached"

	<debuggerCompleteToSender>
	Halt fromCount: anInteger
]

{ #category : #halting }
Object >> haltIf: condition [
	<debuggerCompleteToSender>
	Halt if: condition.
]

{ #category : #testing }
Object >> haltIfNil [
]

{ #category : #halting }
Object >> haltIfNotTest [
	"Halt if execution was not started by a test. This is useful as this means one can just run tests undisturbed, while a execution for example from the Playground would be halted"
	<debuggerCompleteToSender>
	Halt ifNotTest
]

{ #category : #halting }
Object >> haltIfTest [
	"Halt if execution was started by a test. These #halts are just active in the tests, useful when you want to add a halt in methods that are executed a lot (e.g. collections)"
	<debuggerCompleteToSender>
	Halt ifTest
]

{ #category : #halting }
Object >> haltOnCount: anInteger [
	"Halts once when a count is reached"

	<debuggerCompleteToSender>
	Halt onCount: anInteger
]

{ #category : #halting }
Object >> haltOnce [
	<debuggerCompleteToSender>
	Halt once.
]

{ #category : #'process termination handling' }
Object >> handleProcessTerminationOfWaitingContext: suspendedContext [
	^suspendedContext
]

{ #category : #'error handling' }
Object >> handles: exception [
	"This method exists in case a non exception class is the first arg in an on:do: (for instance using a exception class that is not loaded). We prefer this to raising an error during error handling itself. Also, semantically it makes sense that the exception handler is not active if its exception class is not loaded"

	^ false
]

{ #category : #binding }
Object >> hasBindingOf: aString [
	^false
]

{ #category : #'literal testing' }
Object >> hasLiteralSuchThat: testBlock [
	"This is the end of the imbedded structure path so return false."

	^ false
]

{ #category : #finalization }
Object >> hasMultipleExecutors [
	"All objects, except ObjectFinalizerCollection instances should answer false to this message"
	^ false
]

{ #category : #comparing }
Object >> hash [
	"Answer a SmallInteger whose value is related to the receiver's identity.
	May be overridden, and should be overridden in any classes that define = "

	^ self identityHash 
]

{ #category : #evaluating }
Object >> in: aBlock [
	"Evaluate the given block with the receiver as its argument."

	^ aBlock value: self

]

{ #category : #introspection }
Object >> instVarAt: index [
	"Primitive. Answer a fixed variable in an object. The numbering of the variables
	 corresponds to the named instance variables, followed by the indexed instance
	 variables. Fail if the index is not an Integer or is not the index of a fixed 
	 variable or indexed variable. Essential. See Object documentation whatIsAPrimitive."

	<primitive: 173 error: ec>
	self primitiveFailed
]

{ #category : #introspection }
Object >> instVarAt: index put: anObject [
	"Primitive. Store a value into a fixed variable in an object. The numbering of the
	 variables corresponds to the named instance variables, followed by the indexed
	 instance variables. Fail if the index is not an Integer or is not the index of a fixed
	 variable or indexed variable. Essential. See Object documentation whatIsAPrimitive."

	<primitive: 174 error: ec>
	 (index isInteger 
		and: [ index between: 1 and: self class instSize + self basicSize]) 
			ifFalse: [ ^ self errorSubscriptBounds: index ].
	self isReadOnlyObject 
		ifTrue: [ ^ self modificationForbiddenFor: #instVarAt:put: index: index value: anObject ]
]

{ #category : #introspection }
Object >> instVarNamed: aString [
	"Return the value of the instance variable in me with that name.  Slow, but very useful.
	We support here all slots (even non indexed) but raise a backward compatible exception"

	^ self class
		slotNamed: aString
		ifFound: [ :slot | slot read: self ]
		ifNone: [ InstanceVariableNotFound signalFor: aString asString ]
]

{ #category : #introspection }
Object >> instVarNamed: aString put: aValue [
	"Store into the value of the instance variable in me of that name. Slow, but very useful.
	We support here all slots (even non indexed) but raise a backward compatible exception"

	^ self class
		slotNamed: aString
		ifFound: [ :slot | slot write: aValue to: self ]
		ifNone: [ InstanceVariableNotFound signalFor: aString asString ]
]

{ #category : #testing }
Object >> isArray [
	^false
]

{ #category : #testing }
Object >> isAssociation [
	^ false
]

{ #category : #testing }
Object >> isBehavior [
	"Return true if the receiver is a behavior.
	Note: Do not override in any class except behavior."
	^false
]

{ #category : #testing }
Object >> isBlock [

	^ false
]

{ #category : #testing }
Object >> isCharacter [

	^ false.

]

{ #category : #testing }
Object >> isClass [
	^ false
]

{ #category : #testing }
Object >> isClassOrTrait [
	^ self isClass or: [ self isTrait ]
]

{ #category : #testing }
Object >> isClosure [
	^false
]

{ #category : #testing }
Object >> isCollection [
	"Return true if the receiver is some sort of Collection and responds to basic collection messages such as #size and #do:"
	^false
]

{ #category : #testing }
Object >> isColor [
	"Answer true if receiver is a Color. False by default."

	^ false

]

{ #category : #testing }
Object >> isColorForm [
	^false
]

{ #category : #testing }
Object >> isCompiledBlock [

	^ false
]

{ #category : #testing }
Object >> isCompiledMethod [

	^ false
]

{ #category : #testing }
Object >> isContext [
	^false
]

{ #category : #testing }
Object >> isDictionary [
	^false
]

{ #category : #testing }
Object >> isEmbeddedBlock [
	"returns true for CleanBlockBlockClosure and CompiledBlock"
	^ false
]

{ #category : #testing }
Object >> isFloat [
	"Overridden to return true in Float, natch"
	^ false
]

{ #category : #testing }
Object >> isForm [
	^false
]

{ #category : #testing }
Object >> isFraction [
	"Answer true if the receiver is a Fraction."

	^ false
]

{ #category : #testing }
Object >> isHeap [

	^ false
]

{ #category : #testing }
Object >> isInteger [
	"Overridden to return true in Integer."

	^ false
]

{ #category : #testing }
Object >> isInterval [

	^ false
]

{ #category : #'class membership' }
Object >> isKindOf: aClass [
	"Answer whether the class, aClass, is a superclass or class of the receiver.
	The current implemementation allows for a Trait to be used as argument"

	^ self class == aClass or: [ self class inheritsFrom: aClass ]
]

{ #category : #testing }
Object >> isLiteral [
	"Answer whether the receiver has a literal text form recognized by the 
	compiler."

	^false
]

{ #category : #'class membership' }
Object >> isMemberOf: aClass [ 
	"Answer whether the receiver is an instance of the class, aClass."

	^self class == aClass
]

{ #category : #testing }
Object >> isMessageSend [
	^false

]

{ #category : #testing }
Object >> isMethodProperties [
	^false
]

{ #category : #testing }
Object >> isMorph [

	^ false
]

{ #category : #testing }
Object >> isMorphicEvent [
	^false
]

{ #category : #testing }
Object >> isNotNil [
	"Coerces nil to false and everything else to true."

	^true
]

{ #category : #testing }
Object >> isNumber [
	"Overridden to return true in Number, natch"
	^ false
]

{ #category : #pinning }
Object >> isPinned [
	"self
		deprecated: 'Please use #isPinnedInMemory instead'
		transformWith: '`@receiver isPinned' -> '`@receiver isPinnedInMemory'."
		
	^self isPinnedInMemory
]

{ #category : #pinning }
Object >> isPinnedInMemory [
	"Answer if the receiver is pinned.  The VM's garbage collector routinely moves
	 objects as it reclaims and compacts memory.  But it can also pin an object so
	 that it will not be moved, which can make it easier to pass objects out through
	 the FFI."
	<primitive: 183 error: ec>
	^self primitiveFailed
]

{ #category : #testing }
Object >> isPoint [
	"Overridden to return true in Point."

	^ false
]

{ #category : #'write barrier' }
Object >> isReadOnlyObject [
	"Answer if the receiver is read-only.
	 If the VM supports read-only objects it will not write to read-only objects.
	 An attempt to write to an instance variable of a read-only object will
	 cause the VM to send attemptToAssign:withIndex: to the read-only object.
	 An attempt to modify a read-only object in a primitive will cause the
	 primitive to fail with a #'no modification' error code."
	<primitive: 163 error: ec>
	^self isImmediateObject
]

{ #category : #testing }
Object >> isRectangle [
	^false
]

{ #category : #'self evaluating' }
Object >> isSelfEvaluating [
	^ self isLiteral
]

{ #category : #testing }
Object >> isStream [
	"Return true if the receiver responds to the stream protocol"
	^false

]

{ #category : #testing }
Object >> isString [
	"Overridden to return true in String, natch"
	^ false
]

{ #category : #testing }
Object >> isSymbol [
	^ false 
]

{ #category : #testing }
Object >> isSystemWindow [
"answer whatever the receiver is a SystemWindow"
	^ false
]

{ #category : #testing }
Object >> isText [
	^ false
]

{ #category : #flagging }
Object >> isThisEverCalled [
	^ self isThisEverCalled: thisContext sender printString
]

{ #category : #flagging }
Object >> isThisEverCalled: msg [
	"Send this message, with some useful printable argument, from methods or branches of methods which you believe are never reached."

	self error: 'This is indeed called: ', msg printString
]

{ #category : #testing }
Object >> isTrait [
	^false
]

{ #category : #testing }
Object >> isVariableBinding [
	"Return true if I represent a literal variable binding"
	^false
	
]

{ #category : #comparing }
Object >> literalEqual: other [

	^ self class == other class and: [self = other]
]

{ #category : #printing }
Object >> longPrintOn: aStream [
	"Append to the argument, aStream, the names and values of all 
	of the receiver's instance variables."

	self class allInstVarNames doWithIndex:
		[:title :index |
		aStream nextPutAll: title;
		 nextPut: $:;
		 space;
		 tab;
		 print: (self instVarAt: index);
		 cr]
]

{ #category : #printing }
Object >> longPrintOn: aStream limitedTo: sizeLimit indent: indent [
	"Append to the argument, aStream, the names and values of all of the receiver's instance variables.  Limit is the length limit for each inst var."

	self class allInstVarNames doWithIndex:
		[:title :index |
		indent timesRepeat: [aStream tab].
		aStream nextPutAll: title;
		 nextPut: $:;
		 space;
		 tab;
		 nextPutAll: 
			((self instVarAt: index) printStringLimitedTo: (sizeLimit -3 -title size max: 1));
		 cr]
]

{ #category : #printing }
Object >> longPrintString [
	"Answer a String whose characters are a description of the receiver."
	
	| str |
	str := String streamContents: [:aStream | self longPrintOn: aStream].
	"Objects without inst vars should return something"
	^ str isEmpty ifTrue: [self printString, String cr] ifFalse: [str]
]

{ #category : #printing }
Object >> longPrintStringLimitedTo: aLimitValue [
	"Answer a String whose characters are a description of the receiver."
	
	| str |
	str := String streamContents: [:aStream | self longPrintOn: aStream limitedTo: aLimitValue indent: 0].
	"Objects without inst vars should return something"
	^ str isEmpty ifTrue: [self printString, String cr] ifFalse: [str]
]

{ #category : #dependencies }
Object >> myDependents [
	"Private. Answer a list of all the receiver's dependents."

	^ DependentsFields at: self ifAbsent: []
]

{ #category : #dependencies }
Object >> myDependents: aCollectionOrNil [
	"Private. Set (or remove) the receiver's dependents list."

	aCollectionOrNil
		ifNil: [DependentsFields removeKey: self ifAbsent: []]
		ifNotNil: [DependentsFields at: self put: aCollectionOrNil]
]

{ #category : #flagging }
Object >> nominallyUnsent: aSelectorSymbol [
	"From within the body of a method which is not formally sent within the system, but which you intend to have remain in the system (for potential manual invocation, or for documentation, or perhaps because it's sent by commented-out-code that you anticipate uncommenting out someday, send this message, with the selector itself as the argument.

This will serve two purposes:

	(1)  The method will not be returned by searches for unsent selectors (because it, in a manner of speaking, sends itself).
	(2)	You can locate all such methods by browsing senders of #nominallyUnsent:"

	false ifTrue: [self flag: #nominallyUnsent:]    "So that this method itself will appear to be sent"

]

{ #category : #testing }
Object >> notNil [
	"Coerces nil to false and everything else to true."

	^true
]

{ #category : #'error handling' }
Object >> notYetImplemented [
	"Announce that this message is not yet implemented"
	<debuggerCompleteToSender>
	NotYetImplemented signalFor: thisContext sender selector
]

{ #category : #'error handling' }
Object >> notify: aString [ 
	"Create and schedule a Notifier with the argument as the message in 
	order to request confirmation before a process can proceed."
	<debuggerCompleteToSender>
	Warning signal: aString
]

{ #category : #'model - updating' }
Object >> okToChange [
	"Allows a controller to ask this of any model"
	^ true
]

{ #category : #'message performing' }
Object >> perform: aSymbol [ 
	"Send the unary selector, aSymbol, to the receiver.
	Fail if the number of arguments expected by the selector is not zero.
	Primitive. Optional. See Object documentation whatIsAPrimitive."
	
	<primitive: 83>
	^ self perform: aSymbol withArguments: #()
]

{ #category : #'message performing' }
Object >> perform: selector orSendTo: otherTarget [
	"If I wish to intercept and handle selector myself, do it; else send it to otherTarget"
	^ (self respondsTo: selector) ifTrue: [self perform: selector] ifFalse: [otherTarget perform: selector]
]

{ #category : #'message performing' }
Object >> perform: aSymbol with: anObject [ 
	"Send the selector, aSymbol, to the receiver with anObject as its argument.
	Fail if the number of arguments expected by the selector is not one.
	Primitive. Optional. See Object documentation whatIsAPrimitive."
	
	<primitive: 83>
	^ self perform: aSymbol withArguments: {anObject}
]

{ #category : #'message performing' }
Object >> perform: aSymbol with: firstObject with: secondObject [ 
	"Send the selector, aSymbol, to the receiver with the given arguments.
	Fail if the number of arguments expected by the selector is not two.
	Primitive. Optional. See Object documentation whatIsAPrimitive."

	<primitive: 83>
	^ self perform: aSymbol withArguments: {firstObject . secondObject}
]

{ #category : #'message performing' }
Object >> perform: aSymbol with: firstObject with: secondObject with: thirdObject [ 
	"Send the selector, aSymbol, to the receiver with the given arguments.
	Fail if the number of arguments expected by the selector is not three.
	Primitive. Optional. See Object documentation whatIsAPrimitive."
	
	<primitive: 83>
	^ self perform: aSymbol
		withArguments: {firstObject . secondObject . thirdObject}
]

{ #category : #'message performing' }
Object >> perform: aSymbol with: firstObject with: secondObject with: thirdObject with: fourthObject [
	"Send the selector, aSymbol, to the receiver with the given arguments.
	Fail if the number of arguments expected by the selector is not four.
	Primitive. Optional. See Object documentation whatIsAPrimitive."

	<primitive: 83>
	^ self perform: aSymbol
		withArguments: {firstObject . secondObject . thirdObject . fourthObject}
]

{ #category : #'message performing' }
Object >> perform: selector withArguments: argArray [ 
	"Send the selector, aSymbol, to the receiver with arguments in argArray.
	Fail if the number of arguments expected by the selector 
	does not match the size of argArray.
	Primitive. Optional. See Object documentation whatIsAPrimitive."
	
	<primitive: 84>
	^ self perform: selector withArguments: argArray inSuperclass: self class
]

{ #category : #'message performing' }
Object >> perform: selector withArguments: argArray inSuperclass: lookupClass [
	"NOTE:  This is just like perform:withArguments:, except that
	the message lookup process begins, not with the receivers's class,
	but with the supplied superclass instead.  It will fail if lookupClass
	cannot be found among the receiver's superclasses.
	Primitive. Essential. See Object documentation whatIsAPrimitive."

	<primitive: 100>
	selector isSymbol
		ifFalse: [ ^ self error: 'selector argument must be a Symbol' ].
	selector numArgs = argArray size
		ifFalse: [ ^ self error: 'incorrect number of arguments' ].
	(self class includesBehavior: lookupClass)
		ifFalse: [ ^ self error: 'lookupClass is not in my inheritance chain' ].
	self primitiveFailed
]

{ #category : #'message performing' }
Object >> perform: selector withEnoughArguments: anArray [
	"Send the selector, aSymbol, to the receiver with arguments in argArray.
	Only use enough arguments for the arity of the selector; supply nils for missing ones."
	| numArgs args |
	numArgs := selector numArgs.
	anArray size == numArgs
		ifTrue: [ ^self perform: selector withArguments: anArray asArray ].

	args := Array new: numArgs.
	args replaceFrom: 1
		to: (anArray size min: args size)
		with: anArray
		startingAt: 1.

	^ self perform: selector withArguments: args
]

{ #category : #pinning }
Object >> pin [
	"self
		deprecated: 'Please use #pinInMemory instead'
		transformWith: '`@receiver pin' -> '`@receiver pinInMemory'."
		
	self pinInMemory
]

{ #category : #pinning }
Object >> pinInMemory [
	"The VM's garbage collector routinely moves objects as it reclaims and compacts
	 memory. But it can also pin an object so that it will not be moved, which can make
	 it easier to pass objects out through the FFI.  Objects are unpinnned when created.
	 This method ensures an object is pinned, and answers whether it was already pinned."
	^self setPinnedInMemory: true
]

{ #category : #'pointing to' }
Object >> pointsOnlyWeaklyTo: anObject [
	"Assume, we already know that receiver points to an object,
	answer true if receiver points only weakly to it "
	
	self class isWeak ifFalse: [ ^ false ].
	1 to: self class instSize do:
		[:i | (self instVarAt: i) == anObject ifTrue: [^ false]].
	^ true
]

{ #category : #copying }
Object >> postCopy [
	"I'm a hook method in the sense of Design Patterns TemplateHook/Methods. I'm called by copy. self is a shallow copy, subclasses should copy fields as necessary to complete the full copy"

	^ self 
]

{ #category : #'reflective operations' }
Object >> primitiveChangeClassTo: anObject [
	"Primitive. Change the class of the receiver into the class of the argument given that the format of the receiver matches the format of the argument's class. Fail if receiver or argument are SmallIntegers, or the receiver is an instance of a compact class and the argument isn't, or when the argument's class is compact and the receiver isn't, or when the format of the receiver is different from the format of the argument's class, or when the arguments class is fixed and the receiver's size differs from the size that an instance of the argument's class should have.
	Note: The primitive will fail in most cases that you think might work. This is mostly because of a) the difference between compact and non-compact classes, and b) because of differences in the format. As an example, '(Array new: 3) primitiveChangeClassTo: Morph basicNew' would fail for three of the reasons mentioned above. Array is compact, Morph is not (failure #1). Array is variable and Morph is fixed (different format - failure #2). Morph is a fixed-field-only object and the array is too short (failure #3).
	The facility is really provided for certain, very specific applications (mostly related to classes changing shape) and not for casual use."

	<primitive: 115>
	self isReadOnlyObject 
		ifTrue: [ ^ self modificationForbiddenFor: #primitiveChangeClassTo: value: anObject ]. 
	self primitiveFailed
]

{ #category : #printing }
Object >> printOn: aStream [
	"Append to the argument, aStream, a sequence of characters that  
	identifies the receiver."

	| title |
	title := self class name.
	aStream
		nextPutAll: (title first isVowel ifTrue: ['an '] ifFalse: ['a ']);
		nextPutAll: title
]

{ #category : #printing }
Object >> printString [
	"Answer a String whose characters are a description of the receiver. 
	If you want to print without a character limit, use fullPrintString."

	^ self printStringLimitedTo: 50000
]

{ #category : #printing }
Object >> printStringLimitedTo: limit [
	"Answer a String whose characters are a description of the receiver.
	If you want to print without a character limit, use fullPrintString."
	^self printStringLimitedTo: limit using: [:s | self printOn: s]
]

{ #category : #printing }
Object >> printStringLimitedTo: limit using: printBlock [
	"Answer a String whose characters are a description of the receiver
	produced by given printBlock. It ensures the result will be not bigger than given limit"
	| limitedString |
	limitedString := String streamContents: printBlock limitedTo: limit.
	limitedString size < limit ifTrue: [^ limitedString].
	^ limitedString , '...etc...'
]

{ #category : #streaming }
Object >> putOn: aStream [
	"Write the receiver onto aStream.
	In general we assume aStream accepts the receiver as element type.
	Return self."
	
	aStream nextPut: self
]

{ #category : #reading }
Object >> readFromString: aString [ 
	"Create an object based on the contents of aString."
	^ self readFrom: aString readStream
]

{ #category : #introspection }
Object >> readSlot: aSlot [
	^aSlot read: self
]

{ #category : #introspection }
Object >> readSlotNamed: aName [
	^(self class slotNamed: aName) read: self
]

{ #category : #'write barrier' }
Object >> recursivelySetIsReadOnlyObject: aBoolean [
	^self recursivelySetIsReadOnlyObject: aBoolean exceptObjectsIn: IdentitySet new
]

{ #category : #'write barrier' }
Object >> recursivelySetIsReadOnlyObject: aBoolean exceptObjectsIn: alreadyDone [

	"Handle self if not already done, and note it as done."

	(alreadyDone includes: self) ifFalse:
		[	self setIsReadOnlyObject: aBoolean.
			alreadyDone add: self ].

	"Handle all instance vars of self."
	self class allSlots do: [ :ivar | 
		(ivar read: self)
			recursivelySetIsReadOnlyObject: aBoolean
			exceptObjectsIn: alreadyDone ].
	
	"Handle all indexed elements of self."
	1 to: self basicSize do: [ :i | 
		(self basicAt: i)
			recursivelySetIsReadOnlyObject: aBoolean
			exceptObjectsIn: alreadyDone ]

]

{ #category : #testing }
Object >> refersToLiteral: aLitteral [
	^ self literalEqual: aLitteral
]

{ #category : #dependencies }
Object >> release [
	"Remove references to objects that may refer to the receiver. This message 
	should be overridden by subclasses with any cycles, in which case the 
	subclass should also include the expression super release."

	
]

{ #category : #dependencies }
Object >> removeDependent: anObject [
	"Remove the given object as one of the receiver's dependents."

	| dependents |
	dependents := self dependents reject: [:each | each == anObject].
	self myDependents: (dependents isEmpty ifFalse: [dependents]).
	^ anObject
]

{ #category : #'class membership' }
Object >> respondsTo: aSymbol [ 
	"Answer whether the method dictionary of the receiver's class contains 
	aSymbol as a message selector."

	^self class canUnderstand: aSymbol
]

{ #category : #finalization }
Object >> retryWithGC: execBlock until: testBlock [
	"Retry execBlock as long as testBlock returns false. Do an incremental GC after the first try, a full GC after the second try."
	| blockValue |
	blockValue := execBlock value.
	(testBlock value: blockValue) ifTrue:[^blockValue].
	Smalltalk garbageCollectMost.
	blockValue := execBlock value.
	(testBlock value: blockValue) ifTrue:[^blockValue].
	Smalltalk garbageCollect.
	^execBlock value.
]

{ #category : #'write barrier' }
Object >> setIsReadOnlyObject: aBoolean [
	"If the VM supports read-only objects it will not write to read-only objects.
	 An attempt to write to an instance variable of a read-only object will
	 cause the VM to send attemptToAssign:withIndex: to the read-only object.
	 An attempt to modify a read-only object in a primitive will cause the
	 primitive to fail with a #'no modification' error code.
	 This primitive sets the read-only flag of the receiver to the given
	 value and answers the previous vaue of the flag.
	 Note: Some objects can't be read-only, currently contexts and objects related
	 to process scheduling (Processor, Process instances, Semaphore instances, ...)"
	<primitive: 164 error: ec>
	self isImmediateObject ifTrue: [ ^true ].
	^self primitiveFailed
	
]

{ #category : #pinning }
Object >> setPinned: aBoolean [
	"self
		deprecated: 'Please use #setPinnedInMemory: instead'
		transformWith: '`@receiver setPinned: `@statements' -> '`@receiver setPinnedInMemory: `@statements'."
		
	self setPinnedInMemory: aBoolean
]

{ #category : #pinning }
Object >> setPinnedInMemory: aBoolean [
	"The VM's garbage collector routinely moves objects as it reclaims and compacts
	 memory. But it can also pin an object so that it will not be moved around in memory,
    while still being reclamable by the garbage collector. This can make
	 it easier to pass objects out through the FFI. Objects are unpinnned when created.
	 This primitive either pins or unpins an object, and answers if it was already pinned."
	<primitive: 184 error: ec>
	^self primitiveFailed
]

{ #category : #copying }
Object >> shallowCopy [
	"Answer a copy of the receiver which shares the receiver's instance variables. It should never be overridden. I'm invoked from the copy template method. Subclasses that need to specialize the copy should specialize the postCopy hook method."
	
	| class newObject index |
	<primitive: 148>
	class := self class.
	class isVariable
		ifTrue: 
			[index := self basicSize.
			newObject := class basicNew: index.
			[index > 0]
				whileTrue: 
					[newObject basicAt: index put: (self basicAt: index).
					index := index - 1]]
		ifFalse: [newObject := class basicNew].
	index := class instSize.
	[index > 0]
		whileTrue: 
			[newObject instVarAt: index put: (self instVarAt: index).
			index := index - 1].
	^ newObject
]

{ #category : #'error handling' }
Object >> shouldBeImplemented [
	"Announce that this message should be implemented"
	<debuggerCompleteToSender>
	ShouldBeImplemented signalFor: thisContext sender selector
]

{ #category : #'literal testing' }
Object >> shouldBePrintedAsLiteral [

	^self isLiteral
]

{ #category : #'error handling' }
Object >> shouldNotImplement [
	"Announce that, although the receiver inherits this message, 
	it should not implement it."
	<debuggerCompleteToSender>
	ShouldNotImplement signalFor: thisContext sender selector
]

{ #category : #accessing }
Object >> size [
	"Primitive. Answer the number of indexable variables in the receiver. 
	This value is the same as the largest legal subscript. Essential. See Object 
	documentation whatIsAPrimitive."

	<primitive: 62>
	self class isVariable ifFalse: [self errorNotIndexable].
	^ 0
]

{ #category : #'memory usage' }
Object >> sizeInMemory [
	self class isImmediateClass
		ifTrue: [ ^ 0 ].
	^ self class isVariable
		ifTrue: [ self class byteSizeOfInstanceOfSize: self basicSize ]
		ifFalse: [ self class byteSizeOfInstance ]
]

{ #category : #'reflective operations' }
Object >> someObject [
	"Primitive. Answer the first object in the enumeration of all
	 objects."

	<primitive: 138>
	self primitiveFailed.
]

{ #category : #private }
Object >> species [
	"Answer the preferred class for reconstructing the receiver.  For example, 
	collections create new collections whenever enumeration messages such as 
	collect: or select: are invoked.  The new kind of collection is determined by 
	the species of the original collection.  Species and class are not always the 
	same.  For example, the species of Interval is Array."
	<primitive: 111>
	^self class
]

{ #category : #stepping }
Object >> stepAt: millisecondClockValue in: aWindow [

	^ self stepIn: aWindow
]

{ #category : #stepping }
Object >> stepIn: aWindow [

	^ self step
]

{ #category : #stepping }
Object >> stepTime [
	
	^ 1000 "milliseconds -- default backstop for objects serving as models of system windows"
]

{ #category : #stepping }
Object >> stepTimeIn: aSystemWindow [
	
	^ 1000 "milliseconds -- default backstop for objects serving as models of system windows"
]

{ #category : #private }
Object >> storeAt: offset inTempFrame: aContext [
	"This message had to get sent to an expression already on the stack
	as a Block argument being accessed by the debugger.
	Just re-route it to the temp frame."
	^ aContext tempAt: offset put: self
]

{ #category : #printing }
Object >> storeOn: aStream [ 
	"Append to the argument aStream a sequence of characters that is an 
	expression whose evaluation creates an object similar to the receiver."

	aStream nextPut: $(.
	self class isVariable
		ifTrue: [aStream nextPutAll: '(', self class name, ' basicNew: ';
					store: self basicSize;
					nextPutAll: ') ']
		ifFalse: [aStream nextPutAll: self class name, ' basicNew'].
	1 to: self class instSize do:
		[:i |
		aStream nextPutAll: ' instVarAt: ';
			store: i;
			nextPutAll: ' put: ';
			store: (self instVarAt: i);
			nextPut: $;].
	1 to: self basicSize do:
		[:i |
		aStream nextPutAll: ' basicAt: ';
			store: i;
			nextPutAll: ' put: ';
			store: (self basicAt: i);
			nextPut: $;].
	aStream nextPutAll: ' yourself)'

]

{ #category : #printing }
Object >> storeString [
	"Answer a String representation of the receiver from which the receiver 
	can be reconstructed."

	^ String streamContents: [:s | self storeOn: s]
]

{ #category : #'error handling' }
Object >> subclassResponsibility [
	"This message sets up a framework for the behavior of the class' subclasses.
	Announce that the subclass should have implemented this message."
	<debuggerCompleteToSender>
	SubclassResponsibility signalFor: thisContext sender selector
]

{ #category : #finalization }
Object >> toFinalizeSend: aSelector to: aFinalizer with: aResourceHandle [
	"When I am finalized (e.g., garbage collected) close the associated resource handle by sending aSelector to the appropriate finalizer (the guy who knows how to get rid of the resource).
	WARNING: Neither the finalizer nor the resource handle are allowed to reference me. If they do, then I will NEVER be garbage collected. Since this cannot be validated here, it is up to the client to make sure this invariant is not broken."
	self == aFinalizer ifTrue:[self error: 'I cannot finalize myself'].
	self == aResourceHandle ifTrue:[self error: 'I cannot finalize myself'].
	^self finalizationRegistry add: self executor:
		(ObjectFinalizer new
			receiver: aFinalizer
			selector: aSelector
			argument: aResourceHandle)
]

{ #category : #'error handling' }
Object >> traitConflict [
	self error: 'A class or trait does not properly resolve a conflict between multiple traits it uses.'
]

{ #category : #pinning }
Object >> unpin [
	"self
		deprecated: 'Please use #unpinInMemory instead'
		transformWith: '`@receiver unpin' -> '`@receiver unpinInMemory'."
		
	self unpinInMemory
]

{ #category : #pinning }
Object >> unpinInMemory [
	"The VM's garbage collector routinely moves objects as it reclaims and compacts
	 memory. But it can also pin an object so that it will not be moved, which can make
	 it easier to pass objects out through the FFI.  Objects are unpinnned when created.
	 This method ensures an object is unpinned, and answers whether it was pinned."
	^self setPinnedInMemory: false
]

{ #category : #updating }
Object >> update: aParameter [ 
	"Receive a change notice from an object of whom the receiver is a 
	dependent. The default behavior is to do nothing; a subclass might want 
	to change itself in some way."

	^ self
]

{ #category : #updating }
Object >> update: anAspect with: anObject [
	"Receive a change notice from an object of whom the receiver is a 
	dependent. The default behavior is to call update:,
	which by default does nothing; a subclass might want 
	to change itself in some way."

	^ self update: anAspect
]

{ #category : #evaluating }
Object >> value [

	^self
]

{ #category : #evaluating }
Object >> valueWithArguments: aSequenceOfArguments [

	^self
]

{ #category : #copying }
Object >> veryDeepCopy [
	"Do a complete tree copy using a dictionary.  An object in the tree twice is only copied once.  All references to the object in the copy of the tree will point to the new copy."

	| copier new |
	copier := DeepCopier new initialize: 4096 "self initialDeepCopierSize".
	new := self veryDeepCopyWith: copier.
	copier references associationsDo: [:assoc | 
		assoc value veryDeepFixupWith: copier].
	copier fixDependents.
	^ new
]

{ #category : #copying }
Object >> veryDeepCopyWith: deepCopier [
	"Copy me and the entire tree of objects I point to.  An object in the tree twice is copied once, and both references point to him.  deepCopier holds a dictionary of objects we have seen.  Some classes refuse to be copied.  Some classes are picky about which fields get deep copied."
	
	| class selfNumberOfInstanceVariables fieldOfSelf copyOfSelf currentClass hasVeryDeepInnerMethod currentNumberOfInstanceVariables |
	
	deepCopier references at: self ifPresent: [ :newer | 	"already copied" ^ newer].
	class := self class.
	class isMeta ifTrue: [ "a metaclass" ^ self ].
	copyOfSelf := self shallowCopy.
	deepCopier references at: self put: copyOfSelf.	"remember"
		
	(class isVariable and: [class isPointers]) ifTrue: [
		self basicSize to: 1 by: -1 do: [ :i |
			fieldOfSelf := self basicAt: i. 
			copyOfSelf 
				basicAt: i
				put: (deepCopier references 
					at: fieldOfSelf
					ifAbsent: [ fieldOfSelf veryDeepCopyWith: deepCopier ])]].
	
	"Ask each superclass if it wants to share (weak copy) any inst vars"
	copyOfSelf veryDeepInner: deepCopier.

	"other superclasses want all instance variables deep copied"
	currentClass := class.  
	selfNumberOfInstanceVariables := class instSize.
	
	[ selfNumberOfInstanceVariables == 0 ] whileFalse: [
		hasVeryDeepInnerMethod := currentClass includesSelector: #veryDeepInner:.
		currentNumberOfInstanceVariables := currentClass instSize - currentClass superclass instSize.
		hasVeryDeepInnerMethod 
			ifTrue: ["skip inst vars"
				selfNumberOfInstanceVariables := selfNumberOfInstanceVariables - currentNumberOfInstanceVariables]	
			ifFalse: [ 
				currentNumberOfInstanceVariables timesRepeat: [ 
					fieldOfSelf := self instVarAt: selfNumberOfInstanceVariables.
					copyOfSelf 
						instVarAt: selfNumberOfInstanceVariables 
						put: (deepCopier references 
							at: fieldOfSelf 
							ifAbsent: [ fieldOfSelf veryDeepCopyWith: deepCopier ]).
					selfNumberOfInstanceVariables := selfNumberOfInstanceVariables - 1 ]].
		currentClass := currentClass superclass ].
		
	^ copyOfSelf

]

{ #category : #copying }
Object >> veryDeepFixupWith: deepCopier [
	"I have no fields and no superclass.  Catch the super call."
	
	"avoid to use me we will deprecate it in the future"
]

{ #category : #copying }
Object >> veryDeepInner: deepCopier [
	"No special treatment for inst vars of my superclasses.  Override when some need to be weakly copied.  Object>>veryDeepCopyWith: will veryDeepCopy any inst var whose class does not actually define veryDeepInner:"

	"avoid to use me we will deprecate it in the future"
]

{ #category : #stepping }
Object >> wantsSteps [
	"Overridden by morphic classes whose instances want to be stepped,
	or by model classes who want their morphic views to be stepped."

	^ false
]

{ #category : #stepping }
Object >> wantsStepsIn: aSystemWindow [
	
	^ self wantsSteps
]

{ #category : #'model - updating' }
Object >> windowIsClosing [
	"This message is used to inform a models that its window is closing. Most models do nothing, but some, such as the Debugger, must do some cleanup. Note that this mechanism must be used with care by models that support multiple views, since one view may be closed while others left open."

]

{ #category : #introspection }
Object >> writeSlot: aSlot value: anObject [
	^aSlot write: anObject to: self
]

{ #category : #introspection }
Object >> writeSlotNamed: aName value: anObject [
	^(self class slotNamed: aName) write: anObject to: self
]

{ #category : #accessing }
Object >> yourself [
	"Answer self. The message yourself deserves a bit of explanation.
	Sending yourself is handy to get the receiver of a message. It is especially useful when using a cascade since all the cascaded messages are send to the receiver. Let us look at an example.
	
	Imagine that you have the following expression
		#('hello' 'world') at: 2 put: 'pharo'
	and that you would like to get the modified array #('hello' 'pharo') - the receiver of the message at:put:. 
	
	Right now the expression #('hello' 'world') at: 2 put: 'pharo' returns 'pharo' and not the receiver because the message at:put: always returns the second argument.
	 
	To get the receiver we can simply use a cascade as follows:
		#('hello' 'world') at: 2 put: 'pharo'; yourself
	and since yourself returns the receiver of the message we will get the modified array.
	
	Stepping back using a cascade and yourself is equivalent to declare a variable, assign the expression and return the variable as follows:
	| a |
	a := #('hello' 'world'). 
	a at: 2 put: 'pharo'.
	a 
	"
	
	^self
]

{ #category : #comparing }
Object >> ~= anObject [ 
	"Answer whether the receiver and the argument do not represent the 
	same object."

	^self = anObject == false
]

{ #category : #associating }
Object >> ~~> aValueLinkOrNil [
	"Answer a ValueLink between self and aValueLinkOrNil.
	This message allows the receiver to be inserted in a chain of objects, terminated by nil."

	"Code of ValueLink>>#nextLink: and ValueLink>>#value: are inline here for speed."

	"(1 ~~> nil) = ValueLink new value: 1"
	"(1 ~~> 'one') value >>> 1"
	"(1 ~~> nil) nextLink >>> nil"

	"Note that `value` can be ANY object; on the other hand, `nextLink` should be either another 
	ValueLink object or nil."

	^ ValueLink basicNew
		value: self;
		nextLink: aValueLinkOrNil;
		yourself
]
