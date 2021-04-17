"
My instances are 31-bit numbers or 63-bit numbers depending on the image architecture, stored in twos complement form. The allowable range is approximately +- 1 billion (31 bits), 1 quintillion (63 bits)  (see SmallInteger minVal, maxVal).
"
Class {
	#name : #SmallInteger,
	#superclass : #Integer,
	#type : #immediate,
	#classInstVars : [
		'minVal',
		'maxVal'
	],
	#category : #'Kernel-Numbers'
}

{ #category : #'instance creation' }
SmallInteger class >> basicNew [

	self error: 'SmallIntegers can only be created by performing arithmetic'
]

{ #category : #documentation }
SmallInteger class >> guideToDivision [
	"Handy guide to the kinds of Integer division: 
	/  exact division, returns a fraction if result is not a whole integer. 
	//  returns an Integer, rounded towards negative infinity. 
	\\ is modulo rounded towards negative infinity. 
	quo:  truncated division, rounded towards zero."
]

{ #category : #'initialize-release' }
SmallInteger class >> initialize [
	SessionManager default
		registerSystemClassNamed: self name
		atPriority: 10.
	self startUp: true
]

{ #category : #constants }
SmallInteger class >> maxVal [
	"Answer the maximum value for a SmallInteger."
	^ maxVal
]

{ #category : #constants }
SmallInteger class >> minVal [
	"Answer the minimum value for a SmallInteger."
	^ minVal
]

{ #category : #'instance creation' }
SmallInteger class >> new [

	self basicNew	"generates an error"
]

{ #category : #'system startup' }
SmallInteger class >> startUp: isImageStarting [
	"The image is either being newly started (isImageStarting is true), or it's just been snapshotted.
	 If this has just been a snapshot, skip all the startup stuff."
	| next val |
	isImageStarting ifFalse: [^self].
	val := -32768. "Assume at least 16 bits"
	[next := val + val.
	next class == self] whileTrue:
		[val := next].
	minVal := val.
	maxVal := -1 - val
]

{ #category : #arithmetic }
SmallInteger >> * aNumber [ 
	"Primitive. Multiply the receiver by the argument and answer with the
	result if it is a SmallInteger. Fail if the argument or the result is not a
	SmallInteger. Essential. No Lookup. See Object documentation whatIsAPrimitive."

	<primitive: 9>
	^ super * aNumber
]

{ #category : #arithmetic }
SmallInteger >> + aNumber [ 
	"Primitive. Add the receiver to the argument and answer with the result
	if it is a SmallInteger. Fail if the argument or the result is not a
	SmallInteger  Essential  No Lookup. See Object documentation whatIsAPrimitive."

	<primitive: 1>
	^ super + aNumber
]

{ #category : #arithmetic }
SmallInteger >> - aNumber [ 
	"Primitive. Subtract the argument from the receiver and answer with the
	result if it is a SmallInteger. Fail if the argument or the result is not a
	SmallInteger. Essential. No Lookup. See Object documentation
	whatIsAPrimitive."

	<primitive: 2>
	^super - aNumber
]

{ #category : #arithmetic }
SmallInteger >> / aNumber [ 
	"Primitive. This primitive (for /) divides the receiver by the argument
	and returns the result if the division is exact. Fail if the result is not a
	whole integer. Fail if the argument is 0 or is not a SmallInteger. Optional.
	No Lookup. See Object documentation whatIsAPrimitive."

	<primitive: 10>
	aNumber = 0 ifTrue: [^(ZeroDivide dividend: self) signal].
	^super / aNumber
]

{ #category : #arithmetic }
SmallInteger >> // aNumber [ 
	"Primitive. Divide the receiver by the argument and answer with the
	result. Round the result down towards negative infinity to make it a
	whole integer. Fail if the argument is 0 or is not a SmallInteger.
	Essential. No Lookup. See Object documentation whatIsAPrimitive. "

	<primitive: 12>
	^ super // aNumber 	"Do with quo: if primitive fails"
]

{ #category : #comparing }
SmallInteger >> < aNumber [ 
	"Primitive. Compare the receiver with the argument and answer with
	true if the receiver is less than the argument. Otherwise answer false.
	Fail if the argument is not a SmallInteger. Essential. No Lookup. See
	Object documentation whatIsAPrimitive."

	<primitive: 3>
	^super < aNumber
]

{ #category : #comparing }
SmallInteger >> <= aNumber [ 
	"Primitive. Compare the receiver with the argument and answer true if
	the receiver is less than or equal to the argument. Otherwise answer
	false. Fail if the argument is not a SmallInteger. Optional. No Lookup.
	See Object documentation whatIsAPrimitive. "

	<primitive: 5>
	^super <= aNumber
]

{ #category : #comparing }
SmallInteger >> = aNumber [ 
	"Primitive. Compare the receiver with the argument and answer true if
	the receiver is equal to the argument. Otherwise answer false. Fail if the
	argument is not a SmallInteger. Essential. No Lookup. See Object
	documentation whatIsAPrimitive. "

	<primitive: 7>
	^super = aNumber
]

{ #category : #comparing }
SmallInteger >> > aNumber [ 
	"Primitive. Compare the receiver with the argument and answer true if
	the receiver is greater than the argument. Otherwise answer false. Fail if
	the argument is not a SmallInteger. Essential. No Lookup. See Object
	documentation whatIsAPrimitive."

	<primitive: 4>
	^super > aNumber
]

{ #category : #comparing }
SmallInteger >> >= aNumber [ 
	"Primitive. Compare the receiver with the argument and answer true if
	the receiver is greater than or equal to the argument. Otherwise answer
	false. Fail if the argument is not a SmallInteger. Optional. No Lookup.
	See Object documentation whatIsAPrimitive."

	<primitive: 6>
	^super >= aNumber
]

{ #category : #arithmetic }
SmallInteger >> \\ aNumber [ 
	"Primitive. Take the receiver modulo the argument. The result is the
	remainder rounded towards negative infinity, of the receiver divided by
	the argument Fail if the argument is 0 or is not a SmallInteger. Optional.
	No Lookup. See Object documentation whatIsAPrimitive."

	<primitive: 11>
	^ super \\ aNumber 	"will use // to compute it if primitive fails"
]

{ #category : #converting }
SmallInteger >> as31BitSmallInt [
	"Polymorphic with LargePositiveInteger (see comment there).
	 Return self since all SmallIntegers are 31 bits"

	^ self
]

{ #category : #converting }
SmallInteger >> asCharacter [
	<primitive: 170>
	^self primitiveFailed
]

{ #category : #converting }
SmallInteger >> asFloat [
	"Primitive. Answer a Float that represents the value of the receiver.
	Essential. See Object documentation whatIsAPrimitive."

	<primitive: 40>
	self primitiveFailed
]

{ #category : #'system primitives' }
SmallInteger >> basicIdentityHash [
	"The value answered is signed, within the full 
	 SmallInteger range, on the contrary to normal objects."
	^self
]

{ #category : #'bit manipulation' }
SmallInteger >> bitAnd: arg [ 
	"Primitive. Answer an Integer whose bits are the logical AND of the
	receiver's bits and those of the argument, arg.
	Numbers are interpreted as having 2's-complement representation.
	Essential.  See Object documentation whatIsAPrimitive."

	<primitive: 14>
	self >= 0 ifTrue: [^ arg bitAnd: self].
	^ (self bitInvert bitOr: arg bitInvert) bitInvert.
]

{ #category : #'bit manipulation' }
SmallInteger >> bitOr: arg [ 
	"Primitive. Answer an Integer whose bits are the logical OR of the
	receiver's bits and those of the argument, arg.
	Numbers are interpreted as having 2's-complement representation.
	Essential.  See Object documentation whatIsAPrimitive."

	<primitive: 15>
	self >= 0 ifTrue: [^ arg bitOr: self].
	^ arg < 0
		ifTrue: [(self bitInvert bitAnd: arg bitInvert) bitInvert]
		ifFalse: [(self bitInvert bitClear: arg) bitInvert]
]

{ #category : #'bit manipulation' }
SmallInteger >> bitShift: arg [ 
	"Primitive. Answer an Integer whose value is the receiver's value shifted
	left by the number of bits indicated by the argument. Negative arguments
	shift right. The receiver is interpreted as having 2's-complement representation.
	Essential.  See Object documentation whatIsAPrimitive."

	<primitive: 17>
	self >= 0 ifTrue: [^ super bitShift: arg].
	^ arg >= 0
		ifTrue: [(self negated bitShift: arg) negated]
		ifFalse: [(self bitInvert bitShift: arg) bitInvert].
]

{ #category : #'bit manipulation' }
SmallInteger >> bitStringLength [
      "Always use as many bits as the native format to represent a SmallInteger"

      ^self class maxVal highBit + 1
]

{ #category : #'bit manipulation' }
SmallInteger >> bitXor: arg [ 
	"Primitive. Answer an Integer whose bits are the logical XOR of the
	receiver's bits and those of the argument, arg.
	Numbers are interpreted as having 2's-complement representation.
	Essential.  See Object documentation whatIsAPrimitive."

	<primitive: 16>
	self >= 0 ifTrue: [^ arg bitXor: self].
	^ arg < 0
		ifTrue: [self bitInvert bitXor: arg bitInvert]
		ifFalse: [(self bitInvert bitXor: arg) bitInvert].
]

{ #category : #'system primitives' }
SmallInteger >> byteAt: n [
	"Answer the value of an apparent byte-indexable field in the receiver,
	 analogous to the large integers, which are organized as bytes."

	n = 1
		ifTrue: [ 
			"Negate carefully in case the receiver is SmallInteger minVal"
			^ self < 0
				ifTrue: [ -256 - self bitAnd: 255 ]
				ifFalse: [ self bitAnd: 255 ] ].
	^ self < 0
		ifTrue: [ (-256 - self bitShift: -8) + 1 byteAt: n - 1 ]
		ifFalse: [ (self bitShift: 8 - (n bitShift: 3)) bitAnd: 255 ]
]

{ #category : #'system primitives' }
SmallInteger >> byteAt: n put: value [ 
	"Fails. The digits of a small integer can not be modified."

	self error: 'You can''t store in a SmallInteger'
]

{ #category : #'system primitives' }
SmallInteger >> bytesCount [
	"Answer the number of indexable fields in the receiver. This value is the 
	 same as the largest legal subscript. Included so that a SmallInteger can 
	 behave like a LargePositiveInteger or LargeNegativeInteger."
	
	"32768 == (1 bitShift: 15)"
	"32768 bytesCount >>> 2"
	
	"65536 == (1 bitShift: 16)"
	"65536 bytesCount >>> 3"
	
	| value length |
	length := 1.
	value := self.
	value >= 0
		ifTrue:
			[[value > 255] whileTrue:
				[value := value bitShift: -8.
				 length := length + 1]]
		ifFalse:
			[[value < -255] whileTrue:
				[value := value bitShift: -8.
				 length := length + 1]].
	^length
]

{ #category : #printing }
SmallInteger >> decimalDigitLength [
	"Answer the number of digits printed out in base 10.
	 Note that this only works for positive SmallIntegers up to 64-bits."
	"1 decimalDigitLength >>> 1"
	"100000000 decimalDigitLength >>> 9"
	"SmallInteger maxVal decimalDigitLength >>> 19"
	
	^self < 10000
		ifTrue:
			[self < 100
				ifTrue:
					[self < 10 ifTrue: [1] ifFalse: [2]]
				ifFalse:
					[self < 1000 ifTrue: [3] ifFalse: [4]]]
		ifFalse:
			[self < 100000000
				ifTrue:
					[self < 1000000
						ifTrue: [self < 100000 ifTrue: [5] ifFalse: [6]]
						ifFalse: [self < 10000000 ifTrue: [7] ifFalse: [8]]]
				ifFalse:
					[self < 1000000000000
						ifTrue:
							[self < 10000000000
								ifTrue: [self < 1000000000 ifTrue: [9] ifFalse: [10]]
								ifFalse: [self < 100000000000 ifTrue: [11] ifFalse: [12]]]
						ifFalse:
							[self < 10000000000000000
								ifTrue:
									[self < 100000000000000
										ifTrue: [self < 10000000000000 ifTrue: [13] ifFalse: [14]]
										ifFalse: [self < 1000000000000000 ifTrue: [15] ifFalse: [16]]]
								ifFalse:
									[self < 1000000000000000000
										ifTrue: [self < 100000000000000000 ifTrue: [17] ifFalse: [18]]
										ifFalse: [self < 10000000000000000000 ifTrue: [19] ifFalse: [20]]]]]]
]

{ #category : #copying }
SmallInteger >> deepCopy [
]

{ #category : #testing }
SmallInteger >> even [
	" 0 even >>> true"
	" 2 even >>> true"
	"-2 even >>> true"
	" 3 even >>> false"
	"-3 even >>> false"
	
	^(self bitAnd: 1) = 0
]

{ #category : #'mathematical functions' }
SmallInteger >> gcd: anInteger [ 
	"See SmallInteger (Integer) | gcd:"
	| n m |
	n := self.
	m := anInteger.
	[n = 0]
		whileFalse: 
			[n := m \\ (m := n)].
	^ m abs
]

{ #category : #comparing }
SmallInteger >> hash [

    "Spread consecutive integers or integers related by some other pattern
    throughout the hash table, reducing the length of scans required."
    
    ^ self hashMultiply
]

{ #category : #'bit manipulation' }
SmallInteger >> hashMultiply [
	"This is a multiplication of hashes by 1664525 mod 2^28 written to avoid overflowing into large integers.
	 The primitive is able to perform the operation with modulo arihmetic.
	
	Example of usage:
	  hash
	    ^ (super hash + variableName hash) hashMultiply 	
	"
	
	
	<primitive: 159>
	| low |
	low := self bitAnd: 16383.
	^(16r260D * low + ((16r260D * (self bitShift: -14) + (16r0065 * low) bitAnd: 16383) * 16384))
			bitAnd: 16r0FFFFFFF
]

{ #category : #'bit manipulation' }
SmallInteger >> highBit [
	"Answer the index of the high order bit of the receiver, or zero if the  
	receiver is zero. Raise an error if the receiver is negative, since  
	negative integers are defined to have an infinite number of leading 1's 
	in 2's-complement arithmetic. Use >>highBitOfMagnitude if you want to 
	get the highest bit of the magnitude."
	"2r00101000 highBit >>> 6"
	"0 highBit >>> 0"
	
	self < 0 ifTrue: [^ self error: 'highBit is not defined for negative integers'].
	^ self highBitOfPositiveReceiver
]

{ #category : #'bit manipulation' }
SmallInteger >> highBitOfMagnitude [
	"Answer the index of the high order bit of the receiver, or zero if the  
	receiver is zero. This method is used for negative SmallIntegers as well,  
	since Pharo's LargeIntegers are sign/magnitude."
	
	self < 0 ifTrue: [
		"Beware: do not use highBitOfPositiveReceiver
		because self negated is not necessarily a SmallInteger
		(see SmallInteger minVal)"
		^self negated highBitOfMagnitude].
	
	"Implementation note: this method could be as well inlined here."
	^self highBitOfPositiveReceiver
]

{ #category : #private }
SmallInteger >> highBitOfPositiveReceiver [
	| shifted bitNo |
	"Answer the index of the high order bit of the receiver, or zero if the 
	receiver is zero. Receiver has to be positive!"
	shifted := self.
	bitNo := 0.
	[shifted < 65536]
		whileFalse: 
			[shifted := shifted bitShift: -16.
			bitNo := bitNo + 16].
	shifted < 256
		ifFalse: 
			[shifted := shifted bitShift: -8.
			bitNo := bitNo + 8].
		
	"The high bits table can be obtained with:
	(1 to: 8) inject: #[0] into: [:highBits :rank | highBits , (highBits collect: [:e | rank])]."
	^bitNo + ( #[0 1 2 2 3 3 3 3 4 4 4 4 4 4 4 4 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8] at: shifted + 1)
]

{ #category : #comparing }
SmallInteger >> identityHash [
	"Answer a SmallInteger whose value is related to the receiver's identity.
	 Specific override here to decrease the number of conflicts"
	^ self hashMultiply
]

{ #category : #testing }
SmallInteger >> isImmediateObject [
	"This is needed for the boostrap"
	^ true
]

{ #category : #testing }
SmallInteger >> isLarge [
	^false
]

{ #category : #'bit manipulation' }
SmallInteger >> lowBit [
	" Answer the index of the low order one bit.
	  First we skip bits in groups of 8, then do a lookup in a table.
	  While not optimal, this is a good tradeoff; long
	  integer #lowBit always invokes us with bytes."
	"2r00101000 lowBit >>> 4"
	"2r-00101000 lowBit >>> 4"
	| n result lastByte |
	n := self.
	n = 0 ifTrue: [ ^ 0 ].
	result := 0.
	[(lastByte := n bitAnd: 16rFF) = 0]
		whileTrue: [
			result := result + 8.
			n := n bitShift: -8 ].

	"The low bits table can be obtained with:
	((1 to: 8) inject: #[1] into: [:lowBits :rank | (lowBits copy at: 1 put: lowBits first + 1; yourself) , lowBits]) allButFirst."
	^result + ( #[1 2 1 3 1 2 1 4 1 2 1 3 1 2 1 5 1 2 1 3 1 2 1 4 1 2 1 3 1 2 1 6 1 2 1 3 1 2 1 4 1 2 1 3 1 2 1 5 1 2 1 3 1 2 1 4 1 2 1 3 1 2 1 7 1 2 1 3 1 2 1 4 1 2 1 3 1 2 1 5 1 2 1 3 1 2 1 4 1 2 1 3 1 2 1 6 1 2 1 3 1 2 1 4 1 2 1 3 1 2 1 5 1 2 1 3 1 2 1 4 1 2 1 3 1 2 1 8 1 2 1 3 1 2 1 4 1 2 1 3 1 2 1 5 1 2 1 3 1 2 1 4 1 2 1 3 1 2 1 6 1 2 1 3 1 2 1 4 1 2 1 3 1 2 1 5 1 2 1 3 1 2 1 4 1 2 1 3 1 2 1 7 1 2 1 3 1 2 1 4 1 2 1 3 1 2 1 5 1 2 1 3 1 2 1 4 1 2 1 3 1 2 1 6 1 2 1 3 1 2 1 4 1 2 1 3 1 2 1 5 1 2 1 3 1 2 1 4 1 2 1 3 1 2 1] at: lastByte)
]

{ #category : #'system primitives' }
SmallInteger >> nextInstance [
	"SmallIntegers can't be enumerated this way.  There are a finite number of them from from (SmallInteger minVal) to (SmallInteger maxVal), but you'll have to enumerate them yourself with:
	(SmallInteger minVal) to: (SmallInteger maxVal) do: [:integer | <your code here>].
	"

	self shouldNotImplement 
]

{ #category : #'system primitives' }
SmallInteger >> nextObject [
	"SmallIntegers are immediate objects, and, as such, do not have successors in object memory."

	self shouldNotImplement 
]

{ #category : #printing }
SmallInteger >> numberOfDigitsInBase: b [ 
	"Return how many digits are necessary to print this number in base b.
	Mostly same as super but an optimized version for base 10 case"
	
	b = 10 ifFalse: [^super numberOfDigitsInBase: b].
	self < 0 ifTrue: [^self negated numberOfDigitsInBase: b].
	^self decimalDigitLength
]

{ #category : #testing }
SmallInteger >> odd [
	" 0 odd >>> false"
	" 2 odd >>> false"
	"-2 odd >>> false"
	" 3 odd >>> true"
	"-3 odd >>> true"
	^(self bitAnd: 1) = 1
]

{ #category : #pointers }
SmallInteger >> pointsTo: anObject [
	"Answers true if I hold a reference to anObject, or false otherwise. But since SmallIntegers do not have pointers, it always answers false"
	^false

]

{ #category : #printing }
SmallInteger >> printOn: stream base: base [ 
	"Append a representation of this number in base b on aStream."

	self printOn: stream base: base length: 0 padded: false
]

{ #category : #printing }
SmallInteger >> printOn: stream base: base length: minimumLength padded: padWithZeroes [
	"Return a String representation of this number in base b with a minimum length and padded by 0 if zeroFlag is set"
	
	"(String streamContents: [ :s | 10 printOn: s base: 10 length: 4 padded: true] ) >>> '0010'"
	"(String streamContents: [ :s | -10 printOn: s base: 10 length: 4 padded: true] ) >>> '-010'"

	| n numberOfDigits totalLength divisor |
	self < 0
		ifTrue: [
			n := self negated.
			totalLength := 1 ]
		ifFalse: [
			n := self.
			totalLength := 0 ].
	numberOfDigits := n numberOfDigitsInBase: base.
	totalLength := totalLength + numberOfDigits.
	padWithZeroes ifFalse: [
		[ totalLength < minimumLength ] whileTrue: [
			stream space.
			totalLength := totalLength + 1 ] ].
	n = self ifFalse: [ stream nextPut: $- ].
	padWithZeroes ifTrue: [
		[ totalLength < minimumLength ] whileTrue: [
			stream nextPut: $0.
			totalLength := totalLength + 1 ] ].
	divisor := (base raisedToInteger: numberOfDigits - 1).
	[ divisor > 0 ] whileTrue: [
		| digit |
		digit := n // divisor.
		stream nextPut: ('0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ' at: digit + 1).
		n := n - (digit * divisor).
		divisor := divisor // base ]
]

{ #category : #printing }
SmallInteger >> printOn: aStream base: b nDigits: n [ 
	"Append a representation of this number in base b on aStream using nDigits.
	self must be positive."

	self printOn: aStream base: b length: n padded: true
]

{ #category : #printing }
SmallInteger >> printString [
	"Highly optimized version for base 10
	and that we know it is a SmallInteger.
	Don't follow this example. It breaks the
	rule that printOn: is where strings are usually built."
	
	| integer next result len |
	self = 0 ifTrue: [^'0'].
	self < 0 ifTrue: [^'-', self negated printString].
	len := self decimalDigitLength.
	result := String new: len.
	integer := self.
	len to: 1 by: -1 do: [:i |
		next := integer // 10.
		result byteAt: i put: 48 + (integer - (next * 10)).
		integer := next].
	^result
]

{ #category : #printing }
SmallInteger >> printStringBase: b [ 
	"Return a String representation of this number in base b.
	For SmallIntegers, it is more efficient to print directly in a String,
	rather than using a Stream like super."
	
	"(10 printStringBase: 10) >>> '10'"
	"(-10 printStringBase: 10) >>> '-10'"
	"(10 printStringBase: 2) >>> '1010'"
	"(10 printStringBase: 16) >>> 'A'"
	
	self < 0
		ifTrue: [^ '-'
				, (self negated printStringBase: b)].
	self < b
		ifTrue: [^ String
				with: (Character digitValue: self)].
	^ self printStringBase: b nDigits: (self numberOfDigitsInBase: b)
]

{ #category : #printing }
SmallInteger >> printStringBase: b nDigits: n [
	"Return a string representation of this number in base b with n digits (left padded with 0).
	Should be invoked with: 0 <= self < (b raisedToInteger: n)."
	
	| integer next result |
	result := String new: n.
	integer := self.
	n to: 1 by: -1 do: [:i |
		next := integer // b.
		result byteAt: i put: (Character digitValue: (integer - (next * b))).
		integer := next].
	^result
]

{ #category : #arithmetic }
SmallInteger >> quo: aNumber [ 
	"Primitive. Divide the receiver by the argument and answer with the 
	result. Round the result down towards zero to make it a whole integer. 
	Fail if the argument is 0 or is not a SmallInteger. Optional. See Object 
	documentation whatIsAPrimitive."
	
	<primitive: 13>
	aNumber = 0 ifTrue: [^ (ZeroDivide dividend: self) signal].
	(aNumber isMemberOf: SmallInteger)
		ifFalse: [^ super quo: aNumber].
	(aNumber = -1 and: [self = self class minVal])
		ifTrue: ["result is aLargeInteger" ^ self negated].
	self primitiveFailed
]

{ #category : #copying }
SmallInteger >> shallowCopy [
]

{ #category : #copying }
SmallInteger >> veryDeepCopyWith: deepCopier [
	"Return self.  I can't be copied.  Do not record me."
]

{ #category : #comparing }
SmallInteger >> ~= aNumber [ 
	"Primitive. Compare the receiver with the argument and answer true if
	the receiver is not equal to the argument. Otherwise answer false. Fail if
	the argument is not a SmallInteger. Essential. No Lookup. See Object
	documentation whatIsAPrimitive."

	<primitive: 8>
	^super ~= aNumber
]
