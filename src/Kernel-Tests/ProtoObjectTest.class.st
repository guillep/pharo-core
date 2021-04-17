"
This is the unit test for the class ProtoObject. Unit tests are a good way to exercise the functionality of your system in a repeatable and automatic manner. They are therefore recommended if you plan to release anything. For more information, see: 
	- http://www.c2.com/cgi/wiki?UnitTest
	- there is a chapter in the PharoByExample book (http://pharobyexample.org)
	- the sunit class category
"
Class {
	#name : #ProtoObjectTest,
	#superclass : #ClassTestCase,
	#category : #'Kernel-Tests-Objects'
}

{ #category : #coverage }
ProtoObjectTest >> classToBeTested [
	
	^ ProtoObject
]

{ #category : #'tests - testing' }
ProtoObjectTest >> testFastPointersTo [
	| myObject myArray myObject2 allObjects |
	self timeLimit: 1 minute.
	myObject := Object new.
	myObject2 := Object new.
	myArray := {myObject.
	myObject2}.
	allObjects := SystemNavigation default allObjects.
	self
		assert: (myObject pointersToAmong: allObjects) asArray
		equals: {myArray}.
	self
		assert: (myObject2 pointersToAmong: allObjects) asArray
		equals: {myArray}
]

{ #category : #'tests - testing' }
ProtoObjectTest >> testFlag [
	ProtoObject new flag: #hallo
]

{ #category : #'tests - testing' }
ProtoObjectTest >> testIfNil [
	| object block reachabilityTest |
	reachabilityTest := false.
	object := ProtoObject new.
	object ifNil: [ reachabilityTest := true ].
	self assert: (object ifNil: [ nil ]) identicalTo: object.
	self assert: reachabilityTest equals: false.
	"Now the same test without inlining."
	reachabilityTest := false.
	block := [ reachabilityTest := true ].
	object ifNil: block.
	block := [ nil ].
	self assert: (object ifNil: block) identicalTo: object.
	self assert: reachabilityTest equals: false
]

{ #category : #'tests - testing' }
ProtoObjectTest >> testIfNilIfNotNil [
	| object returnValue block notReached1 reached1 notReached2 reached2 reached3 notReached3 reached4 notReached4 |
	notReached1 := false.
	reached1 := false.
	notReached2 := false.
	reached2 := false.
	notReached3 := false.
	reached3 := false.
	notReached4 := false.
	reached4 := false.
	object := ProtoObject new.
	returnValue := Object new.

	object ifNil: [ notReached1 := true ] ifNotNil: [ reached1 := true ].
	self assert: notReached1 equals: false.
	self assert: reached1 equals: true.

	object ifNil: [ notReached2 := true ] ifNotNil: [ :o | reached2 := true ].
	self assert: notReached2 equals: false.
	self assert: reached2 equals: true.

	self assert: (object ifNil: [ false ] ifNotNil: [ :o | o == object ]).
	self assert: (object ifNil: [ nil ] ifNotNil: [ returnValue ]) identicalTo: returnValue.
	self assert: (object ifNil: [ nil ] ifNotNil: [ :o | returnValue ]) identicalTo: returnValue.

	"Now the same without inlining."
	block := [ reached3 := true ].
	object ifNil: [ notReached3 := true ] ifNotNil: block.
	self assert: notReached3 equals: false.
	self assert: reached3 equals: true.

	block := [ :o | reached4 := true ].
	object ifNil: [ notReached4 := true ] ifNotNil: block.
	self assert: notReached4 equals: false.
	self assert: reached4 equals: true.

	block := [ :o | o == object ].
	self assert: (object ifNil: [ false ] ifNotNil: block).
	block := [ returnValue ].
	self assert: (object ifNil: [ nil ] ifNotNil: block) equals: returnValue.
	block := [ :o | returnValue ].
	self assert: (object ifNil: [ nil ] ifNotNil: block) equals: returnValue
]

{ #category : #'tests - testing' }
ProtoObjectTest >> testIfNotNil [
	| object returnValue block reached |
	object := ProtoObject new.
	returnValue := Object new.
	reached := false.
	object ifNotNil: [ reached := true ].
	self assert: reached equals: true.
	reached := false.
	object ifNotNil: [ :o | reached := true ].
	self assert: reached equals: true.
	self assert: (object ifNotNil: [ :o | o == object ]).
	self assert: (object ifNotNil: [ returnValue ]) identicalTo: returnValue.
	self assert: (object ifNotNil: [ :o | returnValue ]) identicalTo: returnValue.
	"Now the same without inlining."
	block := [ reached := true ].
	object ifNotNil: block.
	self assert: reached equals: true.
	reached := false.
	block := [ :o | reached := true ].
	object ifNotNil: block.
	self assert: reached equals: true.
	block := [ :o | o == object ].
	self assert: (object ifNotNil: block).
	block := [ returnValue ].
	self assert: (object ifNotNil: block) equals: returnValue.
	block := [ :o | returnValue ].
	self assert: (object ifNotNil: block) equals: returnValue
]

{ #category : #'tests - testing' }
ProtoObjectTest >> testIfNotNilIfNil [
	| object returnValue block reached notReached |
	object := ProtoObject new.
	returnValue := Object new.

	reached := false.
	notReached := false.
	object ifNotNil: [ reached := true ] ifNil: [ notReached := true ].
	self assert: reached equals: true.
	self assert: notReached equals: false.

	reached := false.
	notReached := false.
	object ifNotNil: [ :o | reached := true ] ifNil: [ notReached := true ].
	self assert: reached equals: true.
	self assert: notReached equals: false.

	reached := false.
	notReached := false.
	self assert: (object ifNotNil: [ :o | o == object ] ifNil: [ false ]).
	self assert: (object ifNotNil: [ returnValue ] ifNil: [ false ]) identicalTo: returnValue.
	self assert: (object ifNotNil: [ :o | returnValue ] ifNil: [ false ]) identicalTo: returnValue.
	"Now the same without inlining."
	reached := false.
	notReached := false.
	block := [ reached := true ].
	object ifNotNil: block ifNil: [ notReached := true ].
	self assert: reached equals: true.
	self assert: notReached equals: false.

	reached := false.
	notReached := false.
	block := [ :o | reached := true ].
	object ifNotNil: block ifNil: [ notReached := true ].
	self assert: reached equals: true.
	self assert: notReached equals: false.

	block := [ :o | o == object ].
	self assert: (object ifNotNil: block ifNil: [ false ]).
	block := [ returnValue ].
	self assert: (object ifNotNil: block ifNil: [ false ]) identicalTo: returnValue.
	block := [ :o | returnValue ].
	self assert: (object ifNotNil: block ifNil: [ false ]) identicalTo: returnValue
]

{ #category : #'tests - testing' }
ProtoObjectTest >> testIsImmediateObject [
	self deny: Object new isImmediateObject.
	self deny: Array new isImmediateObject.
	self assert: 1 isImmediateObject.
	self assert: 1 isImmediateObject equals: 1 class isImmediateClass.
	self assert: 1.2 isImmediateObject equals: 1.2 class isImmediateClass.
	self assert: $a isImmediateObject equals: $a class isImmediateClass
]

{ #category : #'tests - testing' }
ProtoObjectTest >> testIsNil [

	self deny: ProtoObject new isNil
]

{ #category : #tests }
ProtoObjectTest >> testNextObject [
	"In issue 4011 (https://github.com/pharo-project/pharo/issues/4011), "
	"the image crashed if nextObject was called on a Character, SmallInteger or a SmallFloat64"
	
	self assert: (nil nextObject notNil).
	self assert: ('test' nextObject notNil).
	
	self should: [42 nextObject notNil] raise: ShouldNotImplement.
	self should: [$x nextObject notNil] raise: ShouldNotImplement.

	"Small Floats are only available in 64 bits VMs"	
	Smalltalk vm hasSmallFloats 
		ifTrue: [self should: [3.14 nextObject notNil] raise: ShouldNotImplement].

]

{ #category : #'tests - testing' }
ProtoObjectTest >> testNotTheSame [

	| object1 object2 |
	object1 := ProtoObject new.
	object2 := ProtoObject new.
	self assert: object1 ~~ object2.
	self deny: object1 ~~ object1.
]

{ #category : #'tests - testing' }
ProtoObjectTest >> testPointersTo [
	| myObject myArray pointers |
	myObject := Object new.
	pointers := myObject pointersTo.
	self assertEmpty: pointers.
	myArray := {myObject . myObject}.
	self assert: myObject pointersTo asArray equals: {myArray}
]
