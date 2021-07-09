"
Class Number holds the most general methods for dealing with numbers. Subclasses Float, Fraction, and Integer, and their subclasses, provide concrete representations of a numeric quantity.

All of Number's subclasses participate in a simple type coercion mechanism that supports mixed-mode arithmetic and comparisons.  It works as follows:  If
	self<typeA> op: arg<typeB>
fails because of incompatible types, then it is retried in the following guise:
	(arg adaptTypeA: self) op: arg adaptToTypeA.
This gives the arg of typeB an opportunity to resolve the incompatibility, knowing exactly what two types are involved.  If self is more general, then arg will be converted, and viceVersa.  This mechanism is extensible to any new number classes that one might wish to add to Pharo.  The only requirement is that every subclass of Number must support a pair of conversion methods specific to each of the other subclasses of Number.

Implementation notes
----------------------------------
The implementation of #degreeCos and #degreeSin is such that results are exact for any multiple of 90.

Care is also taken to evaluate the sine between -90° and 90°, this will avoid #degreesToRadians and i386 FPU sine function to accumulate round off errors due to approximate representation of pi.
We can thus evaluate 240 degreeCos with at most 1 ulp error. It's not perfect, but better than previous implementation.

For cosine, we know that:
	cosd(x)=cosd(abs(x))
	cosd(x)=sind(90-x)
thus the trick is to evaluate:
	cosd(x)=sind(90-abs(x)) after appropriate modulo in [-180,180[
This way, we are sure to evaluate the sine between -90° and 90°
The #degreesToRadians and #sin are used rather than #degreeSin to avoid cycles.

For sine, it would be necessary to evaluate either
sind(x) if abs(x) <=90
or sind(180-x) if abs(x) >= 90
A possible implementation would be:
	| x |
	x := 90 + self \\ 360 - 90.
	x >= 180 ifTrue: [x := 180 - x].
	^x degreesToRadians sin
We prefer evaluating cosd(90-x) thus providing a branch free implementation.
"
Class {
	#name : #Number,
	#superclass : #Magnitude,
	#category : #'Kernel-Numbers'
}

{ #category : #'instance creation' }
Number class >> new [

	self == Number ifTrue: [
		^ self error: 'Number is an abstract class.  Make a concrete subclass.'].
	^ super new
]

{ #category : #constants }
Number class >> one [

	^1
]

{ #category : #deprecated }
Number class >> readExponent: baseValue base: base from: aStream [
	"Complete creation of a number, reading exponent from aStream. Answer the
	number, or nil if parsing fails.
	<number>(e|d|q)<exponent>>"

	| sign exp value |
	('edq' includes: aStream next) ifFalse: [^ nil].
	sign := ((aStream peek) == $-)
		ifTrue: [aStream next. -1]
		ifFalse: [1].
	(aStream atEnd or: [(aStream peek digitValue between: 0 and: 9) not])
		ifTrue: [^ nil]. "Avoid throwing an error"
	exp := (Integer readFrom: aStream base: 10) * sign.
	value := baseValue * (base raisedTo: exp).
	^ value

]

{ #category : #deprecated }
Number class >> readRemainderOf: integerPart from: aStream base: base withSign: sign [ 
	"Read optional fractional part and exponent or decimal scale, and return the final result"
	"Number readFrom: '3r-22.2'"

	| value fractionDigits fracpos fractionPart fraction pos v foundDecimal |
	value := integerPart.
	fractionDigits := 0.
	foundDecimal := false.
	(aStream peekFor: $.)
		ifTrue: ["<integer>.<fraction>"
			foundDecimal := true.
			(aStream atEnd not
					and: [aStream peek digitValue between: 0 and: base - 1])
				ifTrue: [fracpos := aStream position.
					fractionPart := Integer readFrom: aStream base: base.
					fraction := fractionPart asFloat
								/ (base raisedTo: aStream position - fracpos).
					fractionDigits := aStream position - fracpos.
					value := value asFloat + fraction]].

	pos := aStream position.
	(v := self readScaledDecimal: integerPart
			fractionPart: fractionPart
			digits: fractionDigits
			base: base
			sign: sign
			from: aStream)
		ifNil: [aStream position: pos]
		ifNotNil: [^ v "<number>s<scale>>"].

	pos := aStream position.
	(v := self readExponent: value base: base from: aStream)
		ifNil: [aStream position: pos.
			(foundDecimal and: [fractionDigits = 0])
				ifTrue: ["oops - just <integer>."
							aStream skip: -1.
							"un-gobble the period"
							^ value * sign]]
		ifNotNil: [value := v "<number>(e|d|q)<exponent>>"].

	(value isFloat
			and: [value = 0.0
					and: [sign = -1]])
		ifTrue: [^ Float negativeZero]
		ifFalse: [^ value * sign]
]

{ #category : #deprecated }
Number class >> readScaledDecimal: integerPart fractionPart: fractionPart digits: fractionDigits base: base sign: sign from: aStream [ 
	"Complete creation of a ScaledDecimal, reading scale from aStream. Answer
	a ScaledDecimal, or nil if parsing fails.
	<number>s[<scale>]"

	| scale decimalMultiplier decimalFraction |
	aStream atEnd ifTrue: [^ nil].
	(aStream next == $s) ifFalse: [^ nil].
	"<number>s<scale>"
	(aStream atEnd not and: [aStream peek digitValue between: 0 and: 9])
		ifTrue: [scale := Integer readFrom: aStream]
		ifFalse: [^ nil].
	scale 
		ifNil: ["<number>s"
			fractionDigits = 0
				ifTrue: ["<integer>s"
					scale := 0]
				ifFalse: ["<integer>.<fraction>s"
					scale := fractionDigits]].
	fractionPart 
		ifNil: [^integerPart * sign asScaledDecimal: scale]
		ifNotNil: [decimalMultiplier := base raisedTo: fractionDigits.
			decimalFraction := integerPart * decimalMultiplier + fractionPart * sign / decimalMultiplier.
			^decimalFraction asScaledDecimal: scale]
]

{ #category : #arithmetic }
Number >> * aNumber [ 
	"Answer the result of multiplying the receiver by aNumber."

	self subclassResponsibility
]

{ #category : #arithmetic }
Number >> + aNumber [ 
	"Answer the sum of the receiver and aNumber."

	self subclassResponsibility
]

{ #category : #arithmetic }
Number >> - aNumber [ 
	"Answer the difference between the receiver and aNumber."

	self subclassResponsibility
]

{ #category : #arithmetic }
Number >> / aNumber [ 
	"Answer the result of dividing the receiver by aNumber."

	self subclassResponsibility
]

{ #category : #arithmetic }
Number >> // aNumber [ 
	"Integer quotient defined by division with truncation toward negative 
	infinity. 9//4 = 2, -9//4 = -3. -0.9//0.4 = -3. \\ answers the remainder 
	from this division."

	^(self / aNumber) floor
]

{ #category : #arithmetic }
Number >> @ y [ 
	"Primitive. Answer a Point whose x value is the receiver and whose y 
	value is the argument. Optional. No Lookup. See Object documentation 
	whatIsAPrimitive."

	<primitive: 18>
	^Point x: self y: y
]

{ #category : #arithmetic }
Number >> \\ aNumber [ 
	"modulo. Remainder defined in terms of //. Answer a Number with the 
	same sign as aNumber."
	
	"9 \\ 4 >>> 1"
	"-9 \\ 4 >>> 3"
	"9 \\ -4 >>> -3"

	^self - (self // aNumber * aNumber)
]

{ #category : #arithmetic }
Number >> abs [
	"Answer a Number that is the absolute value (positive magnitude) of the 
	receiver."

	self < 0
		ifTrue: [^self negated]
		ifFalse: [^self]
]

{ #category : #converting }
Number >> adaptToFloat: rcvr andCompare: selector [ 
	"If I am involved in comparison with a Float, convert rcvr to a
	Fraction. This way, no bit is lost and comparison is exact."
	
	rcvr isFinite
		ifFalse: [
			selector == #= ifTrue: [^false].
			selector == #~= ifTrue: [^true].
			rcvr isNaN ifTrue: [^ false].
			(selector = #< or: [selector = #'<='])
				ifTrue: [^ rcvr positive not].
			(selector = #> or: [selector = #'>='])
				ifTrue: [^ rcvr positive].
			^self error: 'unknow comparison selector'].

	^ rcvr asTrueFraction perform: selector with: self
]

{ #category : #converting }
Number >> adaptToFloat: rcvr andSend: selector [ 
	"If I am involved in arithmetic with a Float, convert me to a Float."
	^ rcvr perform: selector with: self asFloat
]

{ #category : #converting }
Number >> adaptToFraction: rcvr andSend: selector [
	"If I am involved in arithmetic with a Fraction, convert us and evaluate exprBlock."
	^ self subclassResponsibility
]

{ #category : #converting }
Number >> adaptToInteger: rcvr andSend: selector [
	"If I am involved in arithmetic with a Integer, convert us and evaluate exprBlock."
	^ self subclassResponsibility
]

{ #category : #adding }
Number >> addAssignToFloatArray: aFloatArray [
	^ aFloatArray primAddScalar: self asFloat
]

{ #category : #'*Kernel-Chronology' }
Number >> asDuration [
 
 	^ Duration seconds: self asInteger
 
]

{ #category : #converting }
Number >> asFloat [
	"Answer a floating-point number approximating the receiver."

	self subclassResponsibility
]

{ #category : #converting }
Number >> asInteger [
	"Round me towards nearest integer closer to zero."
	"This violates the ANSI standard, but the system depends on this"

	^self truncated 
]

{ #category : #converting }
Number >> asMargin [
	^ Margin fromNumber: self.
]

{ #category : #converting }
Number >> asNumber [
	^ self
]

{ #category : #converting }
Number >> asPoint [
	"Answer a Point with the receiver as both coordinates; often used to 
	supply the same value in two dimensions, as with symmetrical gridding 
	or scaling."

	^self @ self
]

{ #category : #converting }
Number >> asScaledDecimal [
	"Answer a scaled decimal number approximating the receiver."
	#Numeric.

	^ self asScaledDecimal: 8

]

{ #category : #converting }
Number >> asScaledDecimal: scale [ 
	"Answer the receiver converted to a ScaledDecimal."
	
	^ ScaledDecimal newFromNumber: self scale: scale
]

{ #category : #'*Kernel-Chronology' }
Number >> asSeconds [
	^ Duration milliSeconds: self * 1000
]

{ #category : #converting }
Number >> asSmallAngleDegrees [
	"Return the receiver normalized to lie within the range (-180, 180)"

	| pos |
	pos := self \\ 360.
	pos > 180 ifTrue: [pos := pos - 360].
	^ pos

"#(-500 -300 -150 -5 0 5 150 300 500 1200) collect: [:n | n asSmallAngleDegrees]"
]

{ #category : #converting }
Number >> asSmallPositiveDegrees [
	"Return the receiver normalized to lie within the range (0, 360)"

	^self \\ 360
]

{ #category : #'truncation and round off' }
Number >> ceiling [
       "Answer the integer nearest the receiver toward  infinity."

       | truncation |
       truncation := self truncated.
       self <= 0 ifTrue: [ ^ truncation ].
       ^ self = truncation
               ifTrue: [ truncation ]
               ifFalse: [ truncation + 1 ]
]

{ #category : #converting }
Number >> copySignTo: aNumber [
	"Return a number with same magnitude as aNumber and same sign as self."

	^ self signBit = 0
		ifTrue: [aNumber abs]
		ifFalse: [aNumber abs negated].
]

{ #category : #'*Kernel-Chronology' }
Number >> day [
 
 	^ self days
]

{ #category : #'*Kernel-Chronology' }
Number >> days [
 
 	^ Duration days: self
]

{ #category : #'truncation and round off' }
Number >> detentBy: detent atMultiplesOf: grid snap: snap [
	"Map all values that are within detent/2 of any multiple of grid to that multiple.  Otherwise, if snap is true, return self, meaning that the values in the dead zone will never be returned.  If snap is false, then expand the range between dead zones so that it covers the range between multiples of the grid, and scale the value by that factor."
	| r1 r2 |
	r1 := self roundTo: grid.  "Nearest multiple of grid"
	(self roundTo: detent) = r1 ifTrue: [^ r1].  "Snap to that multiple..."
	snap ifTrue: [^ self].  "...or return self"

	r2 := self < r1  "Nearest end of dead zone"
		ifTrue: [r1 - (detent asFloat/2)]
		ifFalse: [r1 + (detent asFloat/2)].
	"Scale values between dead zones to fill range between multiples"
	^ r1 + ((self - r2) * grid asFloat / (grid - detent))
"
	(170 to: 190 by: 2) collect: [:a | a detentBy: 10 atMultiplesOf: 90 snap: true] 	(170 to: 190 by: 2) collect: [:a | a detentBy: 10 atMultiplesOf: 90 snap: false]
	(3.9 to: 4.1 by: 0.02) collect: [:a | a detentBy: 0.1 atMultiplesOf: 1.0 snap: true] 	(-3.9 to: -4.1 by: -0.02) collect: [:a | a detentBy: 0.1 atMultiplesOf: 1.0 snap: false]
"
]

{ #category : #'mathematical functions' }
Number >> exp [
	"Answer the exponential of the receiver as a floating point number."

	^self asFloat exp
]

{ #category : #'truncation and round off' }
Number >> floor [
	"Answer the integer nearest the receiver toward negative infinity."

	| truncation |
	truncation := self truncated.
	self >= 0 ifTrue: [^truncation].
	self = truncation
		ifTrue: [^truncation]
		ifFalse: [^truncation - 1]
]

{ #category : #'truncation and round off' }
Number >> fractionPart [
	"Added for ANSI compatibility"
	^self - self integerPart
]

{ #category : #'*Kernel-Chronology' }
Number >> hour [
 
 	^ self hours
]

{ #category : #'*Kernel-Chronology' }
Number >> hours [
 
 	^ Duration hours: self
]

{ #category : #'truncation and round off' }
Number >> integerPart [
	"Added for ANSI compatibility"
	^self truncated
]

{ #category : #testing }
Number >> isInfinite [

	^ false
]

{ #category : #testing }
Number >> isNaN [
	^ false
]

{ #category : #testing }
Number >> isNumber [
	^ true
]

{ #category : #testing }
Number >> isZero [
	^self = 0
]

{ #category : #'*Kernel-Chronology' }
Number >> milliSecond [
	"1 milliSecond printString >>> '0:00:00:00.001'"
	"(1 second + 1 milliSecond) printString >>> '0:00:00:01.001'"
	
 	^ self milliSeconds
 
]

{ #category : #'*Kernel-Chronology' }
Number >> milliSeconds [

	"2 milliSeconds printString >>> '0:00:00:00.002'"
	"(1 second + 2 milliSeconds) printString >>> '0:00:00:01.002'"
	
 	^ Duration milliSeconds: self
 
]

{ #category : #'*Kernel-Chronology' }
Number >> minute [
	"1 minute printString >>> '0:00:01:00'"
	"(1 hour + 1 minute) printString >>> '0:01:01:00'"
 
 	^ self minutes
 
]

{ #category : #'*Kernel-Chronology' }
Number >> minutes [
	"2 minutes printString >>> '0:00:02:00'"
	"(1 hour + 2 minutes) printString >>> '0:01:02:00'"
 
 	^ Duration minutes: self
]

{ #category : #'*Kernel-Chronology' }
Number >> nanoSecond [
	"1 nanoSecond printString >>> '0:00:00:00.000000001'"
	"(1 milliSecond + 1 nanoSecond) printString >>> '0:00:00:00.001000001'"
 
 	^ self nanoSeconds
 
]

{ #category : #'*Kernel-Chronology' }
Number >> nanoSeconds [
	"2 nanoSeconds printString >>> '0:00:00:00.000000002'"
	"(1 milliSecond + 2 nanoSeconds) printString >>> '0:00:00:00.001000002'"
 
 	^ Duration nanoSeconds: self.
]

{ #category : #arithmetic }
Number >> negated [
	"Answer a Number that is the negation of the receiver."

	^0 - self
]

{ #category : #testing }
Number >> negative [
	"Answer whether the receiver is mathematically negative."

	^ self < 0
]

{ #category : #testing }
Number >> positive [
	"Answer whether the receiver is positive or equal to 0. (ST-80 protocol).
	See also strictlyPositive"

	^ self >= 0
]

{ #category : #printing }
Number >> printOn: aStream [
	self printOn: aStream base: 10
]

{ #category : #printing }
Number >> printOn: aStream base: base [
	"This method should print a representation of the number for the given base,
	excluding the base prefix (and the letter r for radix)"
	
	self subclassResponsibility
]

{ #category : #printing }
Number >> printOn: aStream showingDecimalPlaces: placesDesired [
	"Print a representation of the receiver on aStream in decimal notation with prescribed number of places after decimal separator."

	| rounder rounded roundedFractionPart |
	placesDesired <= 0 ifTrue: [^ self rounded printOn: aStream].
	rounder := 10 raisedToInteger: placesDesired.
	rounded := self roundTo: rounder reciprocal.
	rounded negative ifTrue: [aStream nextPut: $-].
	rounded := rounded abs.
	rounded integerPart truncated printOn: aStream.
	aStream nextPut: $..
	roundedFractionPart := (rounded fractionPart * rounder) truncated.
	roundedFractionPart printOn: aStream base: 10 length: placesDesired padded: true
]

{ #category : #printing }
Number >> printShowingDecimalPlaces: placesDesired [
	"Print the receiver showing precisely the given number of places desired.  If placesDesired is positive, a decimal point and that many digits after the decimal point will always be shown.  If placesDesired is zero, a whole number will be shown, without a decimal point. Here are some examples:"
	
	"(23 printShowingDecimalPlaces: 2) >>> '23.00'"
	"(23.5698 printShowingDecimalPlaces: 2) >>> '23.57'"
	"(-234.567 printShowingDecimalPlaces: 5) >>> '-234.56700'"
	"(23.4567 printShowingDecimalPlaces: 0) >>> '23'"
	"(-23.4567 printShowingDecimalPlaces: 0) >>> '-23'"
	"(100000000 printShowingDecimalPlaces: 1) >>> '100000000.0'"
	"(0.98 printShowingDecimalPlaces: 5) >>> '0.98000'"
	"(-0.98 printShowingDecimalPlaces: 2) >>> '-0.98'"
	"(2.567 printShowingDecimalPlaces: 2) >>> '2.57'"
	"(-2.567 printShowingDecimalPlaces: 2) >>> '-2.57'"
	"(0 printShowingDecimalPlaces: 2) >>> '0.00'"

	^String new: placesDesired + 10 streamContents: [:aStream |
		self printOn: aStream showingDecimalPlaces: placesDesired]
]

{ #category : #printing }
Number >> printString [
	^self printStringBase: 10
]

{ #category : #printing }
Number >> printStringBase: base [
	"Return a String representation of this number in base b."
	"(10 printStringBase: 10) >>> '10'"
	"(-10 printStringBase: 10) >>> '-10'"
	"(10 printStringBase: 2) >>> '1010'"
	"(10 printStringBase: 16) >>> 'A'"
	
	^ String streamContents: [:strm | self printOn: strm base: base]
]

{ #category : #arithmetic }
Number >> quo: aNumber [ 
	"Integer quotient defined by division with truncation toward zero. 
	
	(-9 quo: 4) = -2.
	(-0.9 quo: 0.4) = -2. 
	
	rem: answers the remainder from this division."

	^(self / aNumber) truncated
]

{ #category : #'mathematical functions' }
Number >> raisedTo: aNumber [ 
	"Answer the receiver raised to aNumber."
	
	"(2 raisedTo: 8) >>> 256"
	"(8 raisedTo: 2) >>> 64"
	"(2 raisedTo: (1/12)) >>> 1.0594630943592953"
	"(2 raisedTo: -1) >>> (1/2)"

	aNumber isInteger ifTrue: [
		"Do the special case of integer power"
		^ self raisedToInteger: aNumber].
	aNumber isFraction ifTrue: [
		"Special case for fraction power"
		^ self raisedToFraction: aNumber].
	self < 0 ifTrue: [
		^ ArithmeticError signal: 'Negative numbers can''t be raised to float powers.' ].
	0 = aNumber ifTrue: [^ self class one].	"Special case of exponent=0"
	1 = aNumber ifTrue: [^ self].	"Special case of exponent=1"
	0 = self ifTrue: [				"Special case of self = 0"
		aNumber < 0
			ifTrue: [^ (ZeroDivide dividend: 1) signal]
			ifFalse: [^ self]].
	^ (aNumber * self ln) exp		"Otherwise use logarithms"
]

{ #category : #'mathematical functions' }
Number >> raisedToFraction: aFraction [
	self isZero
		ifTrue:
			[aFraction negative ifTrue: [^ (ZeroDivide dividend: 1) signal].
			^self].
	self negative ifFalse: [^(self ln * aFraction) exp].
	aFraction denominator even
		ifTrue: [^ ArithmeticError signal: 'nth root only defined for positive Integer n.'].
	^(self negated ln * aFraction) exp negated
]

{ #category : #'mathematical functions' }
Number >> raisedToInteger: anInteger [

	"The 0 raisedToInteger: 0 is an special case. In some contexts must be 1 and in others must
	be handled as an indeterminate form.
	I take the first context because that's the way that was previously handled.
	Maybe further discussion is required on this topic."
	
	|bitProbe result|

	anInteger negative ifTrue: [^(self raisedToInteger: anInteger negated) reciprocal].
	bitProbe := 1 bitShift: anInteger highBit - 1.
 	result := self class one.
  	[
		(anInteger bitAnd: bitProbe) = 0 ifFalse: [result := result * self].
       bitProbe := bitProbe bitShift: -1.
		bitProbe > 0 ]
	whileTrue: [result := result * result].
	
	^result
]

{ #category : #arithmetic }
Number >> reciprocal [
	"Returns the reciprocal of self.
	In case self is 0 the / signals ZeroDivide"
	
	"1/2 reciprocal >>> 2"
	"2 reciprocal >>> (1/2)"
	"1.25 reciprocal >>> 0.8"
	"-2 reciprocal >>> (-1/2)"
	
	^1 / self
]

{ #category : #'truncation and round off' }
Number >> reduce [
    "If self is close to an integer, return that integer"
    ^ self
]

{ #category : #arithmetic }
Number >> rem: aNumber [ 
	"Remainder defined in terms of quo:. Answer a Number with the same 
	sign as self. e.g. 9 rem: 4 = 1, -9 rem: 4 = -1. 0.9 rem: 0.4 = 0.1."

	^self - ((self quo: aNumber) * aNumber)
]

{ #category : #'truncation and round off' }
Number >> round: numberOfWishedDecimal [
	"Round the decimal part of the receiver to be limited to the number of wished decimal. Only leave a fixed amount of decimal"
   < expr: 10.12345 round: 2 result: 10.12 >
	< expr: 10.199999999 round: 2 result: 10.2 > 
	^ self subclassResponsibility
]

{ #category : #'truncation and round off' }
Number >> roundDownTo: aNumber [

	"Answer the next multiple of aNumber toward negative infinity that is nearest the receiver. 
	Examples:"

	"(3.1479 roundDownTo: 0.01) >>> 3.14"
	"(3.1479 roundDownTo: 0.1) >>> 3.1"
	"(1923 roundDownTo: 10) >>> 1920"
	"(3.1479 roundDownTo: 0.005) >>> 3.145"
	"(-3.1479 roundDownTo: 0.01) >>> -3.15"

	^ (self / aNumber) floor * aNumber
]

{ #category : #'truncation and round off' }
Number >> roundTo: quantum [ 
	"Answer the nearest number that is a multiple of quantum."

	^(self / quantum) rounded * quantum
]

{ #category : #'truncation and round off' }
Number >> roundUpTo: aNumber [ 
	"Answer the next multiple of aNumber toward infinity that is nearest the receiver."
	"(3.1479 roundUpTo: 0.01) >>> 3.15"
	"(3.1479 roundUpTo: 0.1) >>> 3.2"
	"(1923 roundUpTo: 10) >>> 1930"
	"(3.1479 roundUpTo: 0.005) >>> 3.15"
	"(-3.1479 roundUpTo: 0.01) >>> -3.14" 

	^(self / aNumber) ceiling * aNumber
]

{ #category : #'truncation and round off' }
Number >> rounded [
	"Answer the integer nearest the receiver."
	
	"1.4 rounded >>> 1"
	"1.5 rounded >>> 2"
	"2 rounded >>> 2"
	"-1.5 rounded >>> -2"

	^(self + (self sign / 2)) truncated
]

{ #category : #'*Kernel-Chronology' }
Number >> second [
	"1 second printString >>> '0:00:00:01'"
	"(1 minute + 1 second) printString >>> '0:00:01:01'"
	
 	^ self seconds
 
]

{ #category : #'*Kernel-Chronology' }
Number >> seconds [

	"2 seconds printString >>> '0:00:00:02'"
	"(1 minute + 2 seconds) printString >>> '0:00:01:02'"
 
 	^ Duration seconds: self
]

{ #category : #converting }
Number >> sign [
	"Answer 1 if the receiver is greater than 0, -1 if less than 0, else 0."

	self > 0 ifTrue: [^1].
	self < 0 ifTrue: [^-1].
	^0
]

{ #category : #converting }
Number >> sign: aNumber [
 	"Return a Number with the same sign as aNumber"
 
 	^ aNumber copySignTo: self.
]

{ #category : #'mathematical functions' }
Number >> signBit [
	"Answer 1 if the receiver is negative, zero otherwise."

	self < 0 ifTrue: [^1].
	^0
]

{ #category : #printing }
Number >> storeOn: aStream [ 
	self printOn: aStream
]

{ #category : #printing }
Number >> storeOn: aStream base: base [
	"This method should print a representation of the number for the given base,
	including the base prefix (with letter r for radix)"
	
	^self subclassResponsibility
]

{ #category : #printing }
Number >> storeStringBase: base [
	"Returns a string representation of the receiver in base 16 in a way that executing it will return the receiver."
	"(10 storeStringBase: 16) >>> '16rA'"
	"(10 storeStringBase: 10) >>> '10'"

	^ String streamContents: [:strm | self storeOn: strm base: base]
]

{ #category : #printing }
Number >> stringForReadout [
	^ self rounded printString
]

{ #category : #'truncation and round off' }
Number >> truncateTo: aNumber [ 
	"Answer the next multiple of aNumber toward zero that is nearest the receiver."
	"(3.1479 truncateTo: 0.01) >>>  3.14"
   "(3.1479 truncateTo: 0.1) >>>  3.1"
	"(1923 truncateTo: 10) >>>  1920"
	"(1929 truncateTo: 10) >>>  1920"
	"(-1929 truncateTo: 10) >>>  -1920"
	"(3.1479 truncateTo: 0.005) >>>  3.145"
	"(-3.1479 truncateTo: 0.01) >>>  -3.14"
             
	^(self quo: aNumber) * aNumber
]

{ #category : #'truncation and round off' }
Number >> truncated [
	"Answer an integer nearest the receiver toward zero."

	^self quo: 1
]

{ #category : #'*Kernel-Chronology' }
Number >> week [
 
 	^ self weeks
 
]

{ #category : #'*Kernel-Chronology' }
Number >> weeks [
 
 	^ Duration weeks: self
]

{ #category : #'*Kernel-Chronology' }
Number >> year [
 
 	^self years
]

{ #category : #'*Kernel-Chronology' }
Number >> years [
 
 	^ Duration years: self
]
