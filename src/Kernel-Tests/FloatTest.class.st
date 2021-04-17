"
I provide a test suite for Float values. Examine my tests to see how Floats should behave, and see how to use them.
"
Class {
	#name : #FloatTest,
	#superclass : #ClassTestCase,
	#category : #'Kernel-Tests-Numbers'
}

{ #category : #coverage }
FloatTest >> classToBeTested [
	
	^ Float
]

{ #category : #test }
FloatTest >> testAsScaledDecimal [

	self
		assert: 0.00000000000006 asScaledDecimal asString
		equals: '0.00000000000006s14'.
	self
		assert: 9.99999999999999 asScaledDecimal asString
		equals: '9.99999999999999s14'.
	self
		assert:
		(ScaledDecimal newFromNumber: 9.999999999999999 scale: 15) asString
		equals: '9.999999999999998s15'.
		self assert: (ScaledDecimal  newFromNumber: 9.999999999999994 scale: 15) asString 
		equals: '9.999999999999995s15'
]

{ #category : #'tests - conversion' }
FloatTest >> testCeiling [

	self assert: 1.0 ceiling equals: 1.
	self assert: 1.1 ceiling equals: 2.
	self assert: -2.0 ceiling equals: -2.
	self assert: -2.1 ceiling equals: -2
]

{ #category : #'tests - compare' }
FloatTest >> testComparisonWhenPrimitiveFails [
	"This is related to http://bugs.squeak.org/view.php?id=7361"

	self deny: 0.5 < (1/4).
	self deny: 0.5 < (1/2).
	self assert: 0.5 < (3/4).
	
	self deny: 0.5 <= (1/4).
	self assert: 0.5 <= (1/2).
	self assert: 0.5 <= (3/4).
	
	self assert: 0.5 > (1/4).
	self deny: 0.5 > (1/2).
	self deny: 0.5 > (3/4).
	
	self assert: 0.5 >= (1/4).
	self assert: 0.5 >= (1/2).
	self deny: 0.5 >= (3/4).
	
	self deny: 0.5 equals: (1/4).
	self assert: 0.5 equals: (1/2).
	self deny: 0.5 equals: (3/4).
	
	self assert: 0.5 ~= (1/4).
	self deny: 0.5 ~= (1/2).
	self assert: 0.5 ~= (3/4)
]

{ #category : #'tests - arithmetic' }
FloatTest >> testContinuedFractions [
	self assert: (Float pi asApproximateFractionAtOrder: 1) equals: (22/7).
	self assert: (Float pi asApproximateFractionAtOrder: 3) equals: (355/113)
]

{ #category : #tests }
FloatTest >> testCopy [
	"Elementary tests"
	
	self assert: 2.0 copy equals: 2.0.
	self assert: -0.5 copy equals: -0.5.
	
	"Are exceptional Floats preserved by the copy ?"
	self assert: Float nan copy isNaN.
	self assert: Float infinity copy equals: Float infinity.
	self assert: Float infinity negated copy equals: Float infinity negated.
	
	"Is the sign of zero preserved by the copy ?"
	self assert: 0.0 copy hex equals: 0.0 hex.
	self assert: Float negativeZero copy hex equals: Float negativeZero hex
]

{ #category : #'tests - mathematical functions' }
FloatTest >> testCopySignTo [
      "Set up"

      | negatives negz positives strictNegatives strictPositives zero |
      strictPositives := {2. 2.5. Float infinity}.
      strictNegatives := {-3. -3.25. Float infinity negated}.
      zero := 0.0.
      negz := Float negativeZero.
      positives := strictPositives copyWith: zero.
      negatives := strictNegatives copyWith: negz.

      "Test the copy sign functions"
      positives do: [:aPositiveSign |
              positives do: [:aPositive |
                      self assert: (aPositiveSign copySignTo: aPositive) equals: aPositive].
              negatives do: [:aNegative |
                      self assert: (aPositiveSign copySignTo: aNegative) equals: aNegative negated].
              
				  self assert: (aPositiveSign copySignTo: zero) sign equals: 0.
              self assert: (aPositiveSign copySignTo: negz) sign equals: 0].

      negatives do: [:aNegativeSign |
              positives do: [:aPositive |
                      self assert: (aNegativeSign copySignTo: aPositive) equals: aPositive negated].
              negatives do: [:aNegative |
                      self assert: (aNegativeSign copySignTo: aNegative) equals: aNegative].
              self assert: (aNegativeSign copySignTo: zero) sign equals: 0.
              self assert: (aNegativeSign copySignTo: negz) sign equals: 0]
]

{ #category : #'tests - arithmetic' }
FloatTest >> testDivide [

	self assert: 1.5 / 2.0 equals: 0.75.	
	self assert: 2.0 / 1 equals: 2.0.
	
	self should: [ 2.0 / 0 ] raise: ZeroDivide.
	self should: [ 2.0 / 0.0 ] raise: ZeroDivide.
	self should: [ 1.2 / Float negativeZero ] raise: ZeroDivide.
	self should: [ 1.2 / (1.3 - 1.3) ] raise: ZeroDivide
	
]

{ #category : #'tests - printing' }
FloatTest >> testFloatPrintPolicy [
	"It is hard to test printing Floats reliably, but this at least covers the code path"

	| pi |	
	pi := FloatPrintPolicy value: InexactFloatPrintPolicy new during: [ Float pi printString ].
	self assert: (pi beginsWith: '3.14159').
	
	pi := FloatPrintPolicy value: ExactFloatPrintPolicy new during: [ Float pi printString ].
	self assert: (pi beginsWith: '3.14159')
]

{ #category : #'tests - conversion' }
FloatTest >> testFloatTruncated [
	"(10 raisedTo: 16) asFloat has an exact representation (no round off error).
	It should convert back to integer without loosing bits.
	This is a no regression test on http://bugs.impara.de/view.php?id=3504"
	
	| x y int r |
	int := 10 raisedTo: 16.
	x := int asFloat.
	y := (5 raisedTo: 16) asFloat timesTwoPower: 16.
	self assert: x equals: y.
	
	self assert: x asInteger equals: int.
	
	"this one should be true for any float"
	self assert: x asInteger equals: x asTrueFraction asInteger.

	"a random test"
	r := Random new.
	10000 timesRepeat: [
		x := r next * 1.9999e16 + 1.0e12 .
		self assert: x truncated equals: x asTrueFraction truncated ]
]

{ #category : #'tests - conversion' }
FloatTest >> testFloor [

	self assert: 1.0 floor equals: 1.
	self assert: 1.1 floor equals: 1.
	self assert: -2.0 floor equals: -2.
	self assert: -2.1 floor equals: -3
]

{ #category : #tests }
FloatTest >> testFractionAsFloatWithUnderflow [
	"test rounding to nearest even"

	| underflowPower |
	underflowPower := Float emin - Float precision.
	self assert: (2 raisedTo: underflowPower) asFloat equals: 0.0.	
	self assert: (2 raisedTo: underflowPower) negated asFloat equals: 0.0.
	self assert: (2 raisedTo: underflowPower) negated asFloat signBit = 1 description: 'a negative underflow should return a negative zero'
]

{ #category : #tests }
FloatTest >> testHash [
	self assert: 2 = 2.0 ==> (2 hash = 2.0 hash).
	self assert: 1 / 2 = 0.5 ==> ((1 / 2) hash = 0.5 hash).
	Float nan hash.
	Float infinity hash
]

{ #category : #'tests - infinity behavior' }
FloatTest >> testInfinity1 [

	| i1  i2 |
	i1 := 10000 exp.
	i2 := 1000000000 exp.
	self assert: i1 isInfinite & i2 isInfinite & (i1 = i2)
	"All infinities are equal. (This is a very substantial difference to NaN's, which are never equal."

]

{ #category : #'tests - infinity behavior' }
FloatTest >> testInfinity2 [
	| i1 i2 |
	i1 := 10000 exp.
	i2 := 1000000000 exp.
	i2 := 0 - i2.	" this is entirely ok. You can compute with infinite values."

	self assert: i1 isInfinite & i2 isInfinite & i1 positive & i2 negative.
	self deny: i1 equals: i2
	"All infinities are signed. Negative infinity is not equal to Infinity"
]

{ #category : #'tests - conversion' }
FloatTest >> testIntegerAsFloat [
	"assert IEEE 754 round to nearest even mode is honoured"

	self deny: 16r1FFFFFFFFFFFF0801 asFloat equals: 16r1FFFFFFFFFFFF0800 asFloat.	"this test is on 65 bits"
	self deny: 16r1FFFFFFFFFFFF0802 asFloat equals: 16r1FFFFFFFFFFFF0800 asFloat.	"this test is on 64 bits"
	self assert: 16r1FFFFFFFFFFF1F800 asFloat equals: 16r1FFFFFFFFFFF20000 asFloat.	"nearest even is upper"
	self assert: 16r1FFFFFFFFFFFF0800 asFloat equals: 16r1FFFFFFFFFFFF0000 asFloat	"nearest even is lower"
]

{ #category : #'tests - zero behavior' }
FloatTest >> testIsZero [

	self assert: 0.0 isZero.
	self deny: 0.1 isZero
]

{ #category : #'tests - compare' }
FloatTest >> testLiteralEqual [

	self deny: (0.0 literalEqual: 0.0 negated).
	self deny: (-0.0 literalEqual: -0.0 negated).
	self deny: (0.0 literalEqual: -0.0)

]

{ #category : #'tests - characterization' }
FloatTest >> testMaxExactInteger [
	self assert: Float maxExactInteger asFloat truncated equals: Float maxExactInteger.
	0 to: 10000 do: [ :j | self assert: (Float maxExactInteger - j) asFloat truncated equals: Float maxExactInteger - j ].
	self deny: (Float maxExactInteger + 1) asFloat truncated equals: Float maxExactInteger + 1
]

{ #category : #'tests - NaN behavior' }
FloatTest >> testNaN1 [
	self assert: Float nan identicalTo: Float nan.
	self deny: Float nan equals: Float nan
	"a NaN is not equal to itself."
]

{ #category : #'tests - NaN behavior' }
FloatTest >> testNaN2 [
	"Two NaN values are always considered to be different.
	On an little-endian machine (32 bit Intel), Float nan is 16rFFF80000 16r00000000.
	On a big-endian machine (PowerPC), Float nan is 16r7FF80000 16r00000000. Changing
	the bit pattern of the first word of a NaN produces another value that is still
	considered equal to NaN. This test should work on both little endian and big
	endian machines. However, it is not guaranteed to work on future 64 bit versions, for which Float may have different internal representations."

	| nan1 nan2 |
	nan1 := Float nan copy.
	nan2 := Float nan copy.

	"test two instances of NaN with the same bit pattern"
	self deny: nan1 equals: nan2.
	self deny: nan1 identicalTo: nan2.
	self deny: nan1 equals: nan1.
	self assert: nan1 identicalTo: nan1.

	"change the bit pattern of nan1"
	self assert: nan1 size equals: 2.
	self assert: (nan1 at: 2) equals: 0.
	nan1 at: 1 put: (nan1 at: 1) + 999.
	self assert: nan1 isNaN.
	self assert: nan2 isNaN.
	self deny: (nan1 at: 1) equals: (nan2 at: 1).

	"test two instances of NaN with different bit patterns"
	self deny: nan1 equals: nan2.
	self deny: nan1 identicalTo: nan2.
	self deny: nan1 equals: nan1.
	self assert: nan1 identicalTo: nan1
]

{ #category : #'tests - NaN behavior' }
FloatTest >> testNaN3 [

   	| set item identitySet |
	set := Set new.
	set add: (item := Float nan).
	self deny: (set includes: item).
	identitySet := IdentitySet new.
	identitySet add: (item := Float nan).
	self assert: (identitySet includes: item)
	"as a NaN is not equal to itself, it can not be retrieved from a set"

]

{ #category : #'tests - NaN behavior' }
FloatTest >> testNaN4 [

	| dict |
	dict := Dictionary new.
	dict at: Float nan put: #NaN.
	self deny: (dict includes: Float nan)
	"as a NaN is not equal to itself, it can not be retrieved when it is used as a dictionary key"

]

{ #category : #'tests - NaN behavior' }
FloatTest >> testNaNCompare [
	"IEEE 754 states that NaN cannot be ordered.
	As a consequence, every arithmetic comparison involving a NaN SHOULD return false.
	Except the is different test (~=).
	This test does verify this rule"
	
	| compareSelectors theNaN anotherNaN comparand brokenMethods warningMessage |
	self skip.
	compareSelectors := #(#< #<= #> #>= #=).
	theNaN := Float nan.
	anotherNaN := Float infinity - Float infinity.
	comparand := {1. 2.3. Float infinity. 2/3. 1.25s2. 2 raisedTo: 50}.
	comparand := comparand , (comparand collect: [:e | e negated]).
	comparand := comparand , {theNaN. anotherNaN}.

"do a first pass to collect all broken methods"
	brokenMethods := Set new.
	comparand do: [:comp |
		compareSelectors do: [:op |
			(theNaN perform: op with: comp) ifTrue: [brokenMethods add: (theNaN class lookupSelector: op)].
			(comp perform: op with: theNaN) ifTrue: [brokenMethods add: (comp class lookupSelector: op)]].
		(theNaN ~= comp) ifFalse: [brokenMethods add: (theNaN class lookupSelector: #~=)].
		(comp ~= theNaN) ifFalse: [brokenMethods add: (comp class lookupSelector: #~=)]].
	
"build a warning message to tell about all broken methods at once"
	warningMessage := String streamContents: [:s |
			s nextPutAll: 'According to IEEE 754 comparing with a NaN should always return false, except ~= that should return true.'; cr.
			s nextPutAll: 'All these methods failed to do so. They are either broken or call a broken one'.
			brokenMethods do: [:e | s cr; print: e methodClass; nextPutAll: '>>'; print: e selector]].
		
"Redo the tests so as to eventually open a debugger on one of the failures"
	brokenMethods := Set new.
	comparand do: [:comp2 |
		compareSelectors do: [:op2 |
			self deny: (theNaN perform: op2 with: comp2) description: warningMessage.
			self deny: (comp2 perform: op2 with: theNaN) description: warningMessage].
		self assert: (theNaN ~= comp2) description: warningMessage.
		self assert: (comp2 ~= theNaN) description: warningMessage].
]

{ #category : #'tests - NaN behavior' }
FloatTest >> testNaNisLiteral [

	self deny: Float nan isLiteral description: 'there is no literal representation of NaN'
]

{ #category : #'tests - zero behavior' }
FloatTest >> testNegativeZeroAbs [

	self assert: Float negativeZero abs sign positive description: 'the absolute value of a negative zero is zero'
]

{ #category : #'tests - zero behavior' }
FloatTest >> testNegativeZeroSign [

	self assert: Float negativeZero sign equals: 0. "Like any other zero, a negative zero has its sign being zero"
	self assert: Float negativeZero signBit equals: 1 "But it can be distinguished with its signBit"
]

{ #category : #'tests - printing' }
FloatTest >> testPrintPaddedWithTo [
	"The problem was caused by treating the format specifier as a number rather than
	as a string, such the the number may be a Float subject to floating point rounding
	errors. The solution to treat the format specifier as a string, and extract the integer
	fields before and after the decimal point in the string."

	self assert: (1.0 printPaddedWith: $0 to: 2.2) equals: '01.00'.
	self assert: (1.0 printPaddedWith: $X to: 2.2) equals: 'X1.0X'.
	self assert: (1.0 printPaddedWith: $0 to: 2) equals: '01.0'.
	self assert: (12345.6789 printPaddedWith: $0 to: 2) equals: '12345.6789'.
	self assert: (12345.6789 printPaddedWith: $0 to: 2.2) equals: '12345.6789'.
	self assert: (12.34 printPaddedWith: $0 to: 2.2) equals: '12.34'.
	self assert: (12345.6789 printPaddedWith: $0 to: 2.2) equals: '12345.6789'.
	self assert: (123.456 printPaddedWith: $X to: 4.4) equals: 'X123.456X'.
	self assert: (1.0 printPaddedWith: $0 to: 2.1) equals: '01.0'.
	self assert: (1.0 printPaddedWith: $0 to: 2.2) equals: '01.00'.
	self assert: (1.0 printPaddedWith: $0 to: 2.3) equals: '01.000'. "previously failed due to float usage"
	self assert: (1.0 printPaddedWith: $0 to: 2.4) equals: '01.0000'. "previously failed due to float usage"
	self assert: (1.0 printPaddedWith: $0 to: 2.5) equals: '01.00000'


]

{ #category : #'tests - mathematical functions' }
FloatTest >> testRaisedTo [

	self should: [ -1.23 raisedTo: 1/4 ] raise: ArithmeticError
]

{ #category : #'tests - conversion' }
FloatTest >> testReadFromManyDigits [
	"A naive algorithm may interpret these representations as Infinity or NaN.
	This is http://bugs.squeak.org/view.php?id=6982"
	
	| s1 s2 |
	s1 := '1' , (String new: 321 withAll: $0) , '.0e-321'.
	s2 := '0.' , (String new: 320 withAll: $0) , '1e321'.
	self assert: (Number readFrom: s1) equals: 1.
	self assert: (Number readFrom: s2) equals: 1 
]

{ #category : #'tests - conversion' }
FloatTest >> testReadingTooLargeExponents [
	self assert: (Float readFrom: '7.5e333') equals: Float infinity.
	self assert: (Float readFrom: '7.5e-333') equals: Float zero.
	self assert: (Float readFrom: '-7.5e333') equals: Float infinity negated.
	self assert: (Float readFrom: '-7.5e-333') equals: Float zero.

	self assert: (Float readFrom: '7.5e3333') equals: Float infinity.
	self assert: (Float readFrom: '7.5e-3333') equals: Float zero.
	self assert: (Float readFrom: '-7.5e3333') equals: Float infinity negated.
	self assert: (Float readFrom: '-7.5e-3333') equals: Float zero.
]

{ #category : #'tests - NaN behavior' }
FloatTest >> testReciprocal [

	self 
		assert: 1.0 reciprocal equals: 1.0;
		assert: 2.0 reciprocal equals: 0.5;
		assert: -1.0 reciprocal equals: -1.0;
		assert: -2.0 reciprocal equals: -0.5.
		
	self should: [ 0.0 reciprocal ] raise: ZeroDivide
]

{ #category : #'tests - conversion' }
FloatTest >> testRounded [

	self assert: 0.9 rounded equals: 1.
	self assert: 1.0 rounded equals: 1.
	self assert: 1.1 rounded equals: 1.
	self assert: -1.9 rounded equals: -2.
	self assert: -2.0 rounded equals: -2.
	self assert: -2.1 rounded equals: -2.
	
	"In case of tie, round to upper magnitude"
	self assert: 1.5 rounded equals: 2.
	self assert: -1.5 rounded equals: -2
]

{ #category : #'tests - compare' }
FloatTest >> testSetOfFloat [
	"Classical disagreement between hash and = did lead to a bug.
	 This is a non regression test from http://bugs.squeak.org/view.php?id=3360"
	
	| size3 size4 |
	size3 := (Set new: 3) add: 3; add: 3.0; size.
	size4 := (Set new: 4) add: 3; add: 3.0; size.
	self assert: size3 = size4 description: 'The size of a Set should not depend on its capacity.'
]

{ #category : #'tests - mathematical functions' }
FloatTest >> testSign [
      "Set up"

      | negatives negz positives strictNegatives strictPositives zero |
      strictPositives := {2. 2.5. Float infinity}.
      strictNegatives := {-3. -3.25. Float infinity negated}.
      zero := 0.0.
      negz := Float negativeZero.
      positives := strictPositives copyWith: zero.
      negatives := strictNegatives copyWith: negz.

      "The sign of non zeros"
      strictPositives do: [:aPositive | self assert: aPositive sign equals: 1].
      strictNegatives do: [:aNegative | self assert: aNegative sign equals: -1].

      "The sign of zeros"
      self assert: zero sign equals: 0.
      self assert: negz sign equals: 0.

      "Test the copy sign functions"
      positives do: [:aPositiveSign |
              positives do: [:aPositive |
                      self assert: (aPositive sign: aPositiveSign) equals: aPositive].
              negatives do: [:aNegative |
                      self assert: (aNegative sign: aPositiveSign) equals: aNegative negated].
              self assert: (zero sign: aPositiveSign) sign equals: 0.
              self assert: (negz sign: aPositiveSign) sign equals: 0.
              self assert: (zero sign: aPositiveSign) signBit equals: 0.
              self assert: (negz sign: aPositiveSign) signBit equals: 0].

      negatives do: [:aNegativeSign |
              positives do: [:aPositive |
                      self assert: (aPositive sign: aNegativeSign) equals: aPositive negated].
              negatives do: [:aNegative |
                      self assert: (aNegative sign: aNegativeSign) equals: aNegative].
              self assert: (zero sign: aNegativeSign) sign equals: 0.
              self assert: (negz sign: aNegativeSign) sign equals: 0.
              self assert: (zero sign: aNegativeSign) signBit equals: 1.
              self assert: (negz sign: aNegativeSign) signBit equals: 1]
]

{ #category : #'tests - printing' }
FloatTest >> testStoreBase16 [
	"This bug was reported in mantis http://bugs.squeak.org/view.php?id=6695"

	self
		assert: (20.0 storeStringBase: 16) = '16r14.0'
		description: 'the radix prefix should not be omitted, except in base 10'
]

{ #category : #'tests - printing' }
FloatTest >> testStoreOn [
	| float |
	float := -1.2.
	self assert: (String streamContents: [ :s | float storeOn: s ]) equals: ' -1.2'.
	
	float := 1.2.	
	self assert: (String streamContents: [ :s | float storeOn: s ]) equals: '1.2'
]

{ #category : #'tests - conversion' }
FloatTest >> testStringAsNumber [
	"This covers parsing in Number>>readFrom:"

	| aFloat |
	aFloat := '10r-12.3456' asNumber.
	self assert: -12.3456 equals: aFloat.
	aFloat := '10r-12.3456e2' asNumber.
	self assert: -1234.56 equals: aFloat.
	aFloat := '10r-12.3456d2' asNumber.
	self assert: -1234.56 equals: aFloat.
	aFloat := '10r-12.3456q2' asNumber.
	self assert: -1234.56 equals: aFloat.
	aFloat := '-12.3456q2' asNumber.
	self assert: -1234.56 equals: aFloat.
	aFloat := '12.3456q2' asNumber.
	self assert: 1234.56 equals: aFloat

]

{ #category : #'tests - conversion' }
FloatTest >> testTruncated [

	self assert: 1.0 truncated equals: 1.
	self assert: 1.1 truncated equals: 1.
	self assert: -2.0 truncated equals: -2.
	self assert: -2.1 truncated equals: -2
]

{ #category : #'tests - zero behavior' }
FloatTest >> testZero1 [

	self assert: Float negativeZero equals: 0 asFloat.
	self assert: (Float negativeZero at: 1) ~= (0 asFloat at: 1)

	"The negative zero has a bit representation that is different from the bit representation of the positive zero. Nevertheless, both values are defined to be equal."

]

{ #category : #'tests - arithmetic' }
FloatTest >> testZeroRaisedToNegativePower [
	"this is a test related to http://bugs.squeak.org/view.php?id=6781"
	
	self should: [0.0 raisedTo: -1] raise: ZeroDivide.
	self should: [0.0 raisedTo: -1.0] raise: ZeroDivide
]

{ #category : #'tests - zero behavior' }
FloatTest >> testZeroSignificandAsInteger [
	"This is about http://bugs.squeak.org/view.php?id=6990"
	
	self assert: 0.0 significandAsInteger equals: 0
]
