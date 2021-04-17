"
My instances represent IEEE-754 floating-point double-precision numbers.  They have about 16 digits of accuracy and their range is between plus and minus 10^307. Some valid examples are:
	
	8.0 13.3 0.3 2.5e6 1.27e-30 1.27e-31 -12.987654e12

Mainly: no embedded blanks, little e for tens power, and a digit on both sides of the decimal point.  It is actually possible to specify a radix for Float constants.  This is great for teaching about numbers, but may be confusing to the average reader:

	3r20.2 --> 6.66666666666667
	8r20.2 --> 16.25

If you don't have access to the definition of IEEE-754, you can figure out what is going on by printing various simple values in Float hex.  It may help you to know that the basic format is...
	sign		1 bit
	exponent	11 bits with bias of 1023 (16r3FF) to produce an exponent
						in the range -1023 .. +1024
				- 16r000:
					significand = 0: Float zero
					significand ~= 0: Denormalized number (exp = -1024, no hidden '1' bit)
				- 16r7FF:
					significand = 0: Infinity
					significand ~= 0: Not A Number (NaN) representation
	mantissa	53 bits, but only 52 are stored (20 in the first word, 32 in the second).  This is because a normalized mantissa, by definition, has a 1 to the right of its floating point, and IEEE-754 omits this redundant bit to gain an extra bit of precision instead.  People talk about the mantissa without its leading one as the FRACTION, and with its leading 1 as the SIGNFICAND.

The single-precision format is...
	sign		1 bit
	exponent	8 bits, with bias of 127, to represent -126 to +127
                    - 0x0 and 0xFF reserved for Float zero (mantissa is ignored)
                    - 16r7F reserved for Float underflow/overflow (mantissa is ignored)
	mantissa	24 bits, but only 23 are stored
This format is used in FloatArray (qv), and much can be learned from the conversion routines, Float asIEEE32BitWord, and Float class fromIEEE32Bit:.

Thanks to Rich Harmon for asking many questions and to Tim Olson, Bruce Cohen, Rick Zaccone and others for the answers that I have collected here.
"
Class {
	#name : #Float,
	#superclass : #Number,
	#classVars : [
		'E',
		'Epsilon',
		'Halfpi',
		'Infinity',
		'Ln10',
		'Ln2',
		'MaxVal',
		'MaxValLn',
		'MinValLogBase2',
		'NaN',
		'NegativeInfinity',
		'NegativeZero',
		'Pi',
		'RadiansPerDegree',
		'Sqrt2',
		'ThreePi',
		'Twopi'
	],
	#category : #'Kernel-Numbers'
}

{ #category : #'instance creation' }
Float class >> basicNew [
	^BoxedFloat64 basicNew: 2
]

{ #category : #'instance creation' }
Float class >> basicNew: anInteger [
	^BoxedFloat64 basicNew: 2
]

{ #category : #constants }
Float class >> denormalized [
	"Answer whether implementation supports denormalized numbers (also known as gradual underflow)."
	
	^true
]

{ #category : #constants }
Float class >> e [
	"Answer the constant, E."

	^E
]

{ #category : #constants }
Float class >> emax [
	"Answer exponent of maximal representable value"
	
	^1023
]

{ #category : #constants }
Float class >> emin [
	"Answer exponent of minimal normalized representable value"
	
	^-1022
]

{ #category : #'instance creation' }
Float class >> fromIEEE32Bit: word [
	"Convert the given 32 bit word (which is supposed to be a positive 32-bit value) from
	 a 32 bit IEEE floating point representation into an actual float object (being
	 64 bits wide). Should only be used for conversion in FloatArrays or likewise objects."
	
	| sign mantissa exponent delta |
	word <= 0 ifTrue:
		[^word negative
			ifTrue: [self error: 'Cannot deal with negative numbers']
			ifFalse: [self zero]].
	sign := word bitAnd: 16r80000000.
	word = sign ifTrue:
		[^self negativeZero].
	
	exponent := ((word bitShift: -23) bitAnd: 16rFF) - 127.
	mantissa := word bitAnd:  16r7FFFFF.

	exponent = 128 ifTrue: "Either NAN or INF"
		[^mantissa = 0
			ifTrue:
				[sign = 0 
					ifTrue: [self infinity]
					ifFalse: [self negativeInfinity]]
			ifFalse: [self nan]].

	exponent = -127 ifTrue:
		"gradual underflow (denormalized number)
		 Remove first bit of mantissa and adjust exponent"
		[delta := mantissa highBit.
		 mantissa := (mantissa bitAnd: (1 bitShift: delta - 1) - 1) bitShift: 24 - delta.
		 exponent := exponent + delta - 23].
	
	"Create new float"
	^(self basicNew: 2)
		basicAt: 1 put: ((sign bitOr: (1023 + exponent bitShift: 20)) bitOr: (mantissa bitShift: -3));
		basicAt: 2 put: ((mantissa bitAnd: 7) bitShift: 29);
		* 1.0 "reduce to SmallFloat64 if possible"
]

{ #category : #'instance creation' }
Float class >> fromIEEE64Bit: doubleWord [

    ^ (self new: 2) basicAt: 1 put: (doubleWord bitShift: -32); basicAt: 2 put: (doubleWord bitAnd: 16rFFFFFFFF); yourself
]

{ #category : #constants }
Float class >> halfPi [
	^ Halfpi
]

{ #category : #constants }
Float class >> infinity [
	"Answer the value used to represent an infinite magnitude"

	^ Infinity
]

{ #category : #'class initialization' }
Float class >> initialize [
	"Float initialize"
	"Constants from Computer Approximations, pp. 182-183:
		Pi = 3.14159265358979323846264338327950288
		Pi/2 = 1.57079632679489661923132169163975144
		Pi*2 = 6.28318530717958647692528676655900576
		Pi/180 = 0.01745329251994329576923690768488612
		2.0 ln = 0.69314718055994530941723212145817657
		2.0 sqrt = 1.41421356237309504880168872420969808"

	Pi := 3.14159265358979323846264338327950288.
	Halfpi := Pi / 2.0.
	Twopi := Pi * 2.0.
	ThreePi := Pi * 3.0.
	RadiansPerDegree := Pi / 180.0.

	Ln2 := 0.69314718055994530941723212145817657.
	Ln10 := 10.0 ln.
	Sqrt2 := 1.41421356237309504880168872420969808.
	E := 2.718281828459045235360287471353.

	Epsilon := 0.000000000001.  "Defines precision of mathematical functions"

	MaxVal := 1.7976931348623157e308.
	MaxValLn := 709.782712893384.
	MinValLogBase2 := -1074.

	Infinity := MaxVal * MaxVal.
	NegativeInfinity := 0.0 - Infinity.
	NaN := Infinity - Infinity.
	NegativeZero := 1.0 / Infinity negated.

]

{ #category : #constants }
Float class >> maxExactInteger [
	"Answer the biggest integer such that it is exactly represented in a float, and all smaller integers also are"
	^1 bitShift: self precision
]

{ #category : #constants }
Float class >> nan [
	"Answer the canonical value used to represent Not-A-Number"

	^ NaN
]

{ #category : #constants }
Float class >> negativeInfinity [
	"Answer the value used to represent a negative infinite magnitude"

	^ NegativeInfinity
]

{ #category : #constants }
Float class >> negativeZero [

	^ NegativeZero
]

{ #category : #constants }
Float class >> one [
	
	^1.0
]

{ #category : #constants }
Float class >> pi [
	"Answer the constant, Pi."

	^Pi
]

{ #category : #constants }
Float class >> precision [
	"Answer the apparent precision of the floating point representation.
	That is the maximum number of radix-based digits (bits if radix=2) representable in floating point without round off error.
	Technically, 52 bits are stored in the representation, and normalized numbers have an implied leading 1 that does not need to be stored.
	Note that denormalized floating point numbers don't have the implied leading 1, and thus gradually loose precision.
	This format conforms IEEE 754 double precision standard."
	
	^53
]

{ #category : #constants }
Float class >> radix [
	"Answer the radix used for internal floating point representation."
	
	^2
]

{ #category : #'instance creation' }
Float class >> readFrom: aStream [ 
	"Answer a new Float as described on the stream, aStream."

	^(super readFrom: aStream) asFloat
]

{ #category : #'instance creation' }
Float class >> readFrom: aStream ifFail: aBlock [
	"Answer a new Float as described on the stream, aStream."

	^(super readFrom: aStream ifFail: [^aBlock value]) asFloat
]

{ #category : #constants }
Float class >> threePi [

	^ ThreePi

]

{ #category : #constants }
Float class >> twoPi [

	^ Twopi

]

{ #category : #constants }
Float class >> zero [
	^ 0.0
]

{ #category : #arithmetic }
Float >> abs [
	"This is faster than using Number abs and works for negativeZero."
	self <= 0.0
		ifTrue: [^ 0.0 - self]
		ifFalse: [^ self]
]

{ #category : #printing }
Float >> absPrintExactlyOn: aStream base: base [
	"Print my value on a stream in the given base.  Assumes that my value is strictly
	positive; negative numbers, zero, NaNs and infinite numbers have already been handled elsewhere.
	Based upon the algorithm outlined in:
	Robert G. Burger and R. Kent Dybvig
	Printing Floating Point Numbers Quickly and Accurately
	ACM SIGPLAN 1996 Conference on Programming Language Design and Implementation
	June 1996.
	This version guarantees that the printed representation exactly represents my value
	by using exact integer arithmetic."

	| fBase significand exp baseExpEstimate be be1 r s mPlus mMinus scale roundingIncludesLimits d tc1 tc2 fixedFormat decPointCount |
	fBase := base asFloat.
	significand := self significandAsInteger.
	roundingIncludesLimits := significand even.
	exp := (self exponent - 52) max: MinValLogBase2.
	baseExpEstimate := (self exponent * fBase reciprocalLogBase2 - 1.0e-10) ceiling.
	exp >= 0
		ifTrue:
			[be := 1 << exp.
			significand ~= 16r10000000000000
				ifTrue:
					[r := significand * be * 2.
					s := 2.
					mPlus := be]
				ifFalse:
					[be1 := be * 2.
					r := significand * be1 * 2.
					s := 4.
					mPlus := be1].
				mMinus := be]
		ifFalse:
			[(exp = MinValLogBase2) | (significand ~= 16r10000000000000)
				ifTrue:
					[r := significand * 2.
					s := (1 << (exp negated)) * 2.
					mPlus := 1]
				ifFalse:
					[r := significand * 4.
					s := (1 << (exp negated + 1)) * 2.
					mPlus := 2].
				mMinus := 1].
	baseExpEstimate >= 0
		ifTrue: [s := s * (base raisedToInteger: baseExpEstimate)]
		ifFalse:
			[scale := base raisedToInteger: baseExpEstimate negated.
			r := r * scale.
			mPlus := mPlus * scale.
			mMinus := mMinus * scale].
	(r + mPlus > s) | (roundingIncludesLimits & (r + mPlus = s))
		ifTrue: [baseExpEstimate := baseExpEstimate + 1]
		ifFalse:
			[r := r * base.
			mPlus := mPlus * base.
			mMinus := mMinus * base].
	(fixedFormat := baseExpEstimate between: -3 and: 6)
		ifTrue:
			[decPointCount := baseExpEstimate.
			baseExpEstimate <= 0
				ifTrue: [aStream nextPutAll: ('0.000000' truncateTo: 2 - baseExpEstimate)]]
		ifFalse:
			[decPointCount := 1]. 
	[d := r // s.
	r := r \\ s.
	(tc1 := (r < mMinus) | (roundingIncludesLimits & (r = mMinus))) |
	(tc2 := (r + mPlus > s) | (roundingIncludesLimits & (r + mPlus = s)))] whileFalse:
		[aStream nextPut: (Character digitValue: d).
		r := r * base.
		mPlus := mPlus * base.
		mMinus := mMinus * base.
		decPointCount := decPointCount - 1.
		decPointCount = 0 ifTrue: [aStream nextPut: $.]].
	tc2 ifTrue:
		[tc1 not | (tc1 & (r*2 >= s)) ifTrue: [d := d + 1]].
	aStream nextPut: (Character digitValue: d).
	decPointCount > 0
		ifTrue:
		[decPointCount - 1 to: 1 by: -1 do: [:i | aStream nextPut: $0].
		aStream nextPutAll: '.0'].
	fixedFormat ifFalse:
		[aStream nextPut: $e.
		aStream nextPutAll: (baseExpEstimate - 1) printString]
]

{ #category : #printing }
Float >> absPrintInexactlyOn: aStream base: base [
	"Print my value on a stream in the given base.  Assumes that my value is strictly
	positive; negative numbers, zero, NaNs and infinite numbers have already been handled elsewhere.
	Based upon the algorithm outlined in:
	Robert G. Burger and R. Kent Dybvig
	Printing Floating Point Numbers Quickly and Accurately
	ACM SIGPLAN 1996 Conference on Programming Language Design and Implementation
	June 1996.
	This version performs all calculations with Floats instead of LargeIntegers, and loses
	about 3 lsbs of accuracy compared to an exact conversion."

	| significantBits fBase exp baseExpEstimate r s mPlus mMinus scale d tc1 tc2 fixedFormat decPointCount |
	significantBits := 50.  "approximately 3 lsb's of accuracy loss during conversion"
	fBase := base asFloat.
	exp := self exponent.
	baseExpEstimate := (exp * fBase reciprocalLogBase2 - 1.0e-10) ceiling.
	exp >= 0
		ifTrue:
			[r := self.
			s := 1.0.
			mPlus := 1.0 timesTwoPower: exp - significantBits.
			mMinus := self significand ~= 1.0 ifTrue: [mPlus] ifFalse: [mPlus / 2.0]]
		ifFalse:
			[r := self timesTwoPower: significantBits.
			s := 1.0 timesTwoPower:  significantBits.
			mMinus := 1.0 timesTwoPower: (exp max: -1024).
			mPlus :=
				(exp = MinValLogBase2) | (self significand ~= 1.0)
					ifTrue: [mMinus]
					ifFalse: [mMinus * 2.0]].
	baseExpEstimate >= 0
		ifTrue:
			[s := s * (fBase raisedToInteger: baseExpEstimate).
			exp = 1023
				ifTrue:   "scale down to prevent overflow to Infinity during conversion"
					[r := r / fBase.
					s := s / fBase.
					mPlus := mPlus / fBase.
					mMinus := mMinus / fBase]]
		ifFalse:
			[exp < -1023
				ifTrue:   "scale up to prevent denorm reciprocals overflowing to Infinity"
					[d := (53 * fBase reciprocalLogBase2 - 1.0e-10) ceiling.
					scale := fBase raisedToInteger: d.
					r := r * scale.
					mPlus := mPlus * scale.
					mMinus := mMinus * scale.
					scale := fBase raisedToInteger: (baseExpEstimate + d) negated]
				ifFalse:
				[scale := fBase raisedToInteger: baseExpEstimate negated].
			s := s / scale].
	(r + mPlus >= s)
		ifTrue: [baseExpEstimate := baseExpEstimate + 1]
		ifFalse:
			[s := s / fBase].
	(fixedFormat := baseExpEstimate between: -3 and: 6)
		ifTrue:
			[decPointCount := baseExpEstimate.
			baseExpEstimate <= 0
				ifTrue: [aStream nextPutAll: ('0.000000' truncateTo: 2 - baseExpEstimate)]]
		ifFalse:
			[decPointCount := 1].
	[d := (r / s) truncated.
	r := r - (d * s).
	(tc1 := r <= mMinus) | (tc2 := r + mPlus >= s)] whileFalse:
		[aStream nextPut: (Character digitValue: d).
		r := r * fBase.
		mPlus := mPlus * fBase.
		mMinus := mMinus * fBase.
		decPointCount := decPointCount - 1.
		decPointCount = 0 ifTrue: [aStream nextPut: $.]].
	tc2 ifTrue:
		[tc1 not | (tc1 & (r*2.0 >= s)) ifTrue: [d := d + 1]].
	aStream nextPut: (Character digitValue: d).
	decPointCount > 0
		ifTrue:
		[decPointCount - 1 to: 1 by: -1 do: [:i | aStream nextPut: $0].
		aStream nextPutAll: '.0'].
	fixedFormat ifFalse:
		[aStream nextPut: $e.
		aStream nextPutAll: (baseExpEstimate - 1) printString]
]

{ #category : #private }
Float >> absPrintOn: aStream base: base digitCount: digitCount [ 
	"Print me in the given base, using digitCount significant figures."

	| fuzz x exp q fBase scale logScale xi |
	self isInfinite ifTrue: [^ aStream nextPutAll: 'Infinity'].
	fBase := base asFloat.
	"x is myself normalized to [1.0, fBase), exp is my exponent"
	exp := self floorLog: fBase.
	scale := 1.0.
	logScale := 0.
	[(x := fBase raisedTo: (exp + logScale)) = 0]
		whileTrue:
			[scale := scale * fBase.
			logScale := logScale + 1].
	x := self * scale / x.
	fuzz := fBase raisedTo: 1 - digitCount.
	"round the last digit to be printed"
	x := 0.5 * fuzz + x.
	x >= fBase
		ifTrue: 
			["check if rounding has unnormalized x"
			x := x / fBase.
			exp := exp + 1].
	(exp < 6 and: [exp > -4])
		ifTrue: 
			["decimal notation"
			q := 0.
			exp < 0 ifTrue: [1 to: 1 - exp do: [:i | aStream nextPut: ('0.0000'
at: i)]]]
		ifFalse: 
			["scientific notation"
			q := exp.
			exp := 0].
	[x >= fuzz]
		whileTrue: 
			["use fuzz to track significance"
			xi := x asInteger.
			aStream nextPut: (Character digitValue: xi).
			x := x - xi asFloat * fBase.
			fuzz := fuzz * fBase.
			exp := exp - 1.
			exp = -1 ifTrue: [aStream nextPut: $.]].
	[exp >= -1]
		whileTrue: 
			[aStream nextPut: $0.
			exp := exp - 1.
			exp = -1 ifTrue: [aStream nextPut: $.]].
	q ~= 0
		ifTrue: 
			[aStream nextPut: $e.
			q printOn: aStream]
]

{ #category : #converting }
Float >> adaptToFraction: rcvr andCompare: selector [ 
	"If I am involved in comparison with a Fraction, convert myself to a
	Fraction. This way, no bit is lost and comparison is exact."
	
	self isFinite
		ifFalse: [
			selector == #= ifTrue: [^false].
			selector == #~= ifTrue: [^true].
			self isNaN ifTrue: [^ false].
			(selector = #< or: [selector = #'<='])
				ifTrue: [^ self positive].
			(selector = #> or: [selector = #'>='])
				ifTrue: [^ self positive not].
			^self error: 'unknow comparison selector'].
		
	"Try to avoid asTrueFraction because it can cost"
	selector == #= ifTrue: [
		rcvr denominator isPowerOfTwo ifFalse: [^false]].
	selector == #~= ifTrue: [
		rcvr denominator isPowerOfTwo ifFalse: [^true]].

	^ rcvr perform: selector with: self asTrueFraction
]

{ #category : #converting }
Float >> adaptToFraction: rcvr andSend: selector [
	"If I am involved in arithmetic with a Fraction, convert it to a Float."
	^ rcvr asFloat perform: selector with: self
]

{ #category : #converting }
Float >> adaptToInteger: rcvr andCompare: selector [ 
	"If I am involved in comparison with an Integer, convert myself to a
	Fraction. This way, no bit is lost and comparison is exact."
	
	self isFinite
		ifFalse: [
			selector == #= ifTrue: [^false].
			selector == #~= ifTrue: [^true].
			self isNaN ifTrue: [^ false].
			(selector = #< or: [selector = #'<='])
				ifTrue: [^ self positive].
			(selector = #> or: [selector = #'>='])
				ifTrue: [^ self positive not].
			^self error: 'unknow comparison selector'].
		
	"Try to avoid asTrueFraction because it can cost"
	selector == #= ifTrue: [
		self fractionPart = 0.0 ifFalse: [^false]].
	selector == #~= ifTrue: [
		self fractionPart = 0.0 ifFalse: [^true]].
	
	^ rcvr perform: selector with: self asTrueFraction
]

{ #category : #converting }
Float >> adaptToInteger: rcvr andSend: selector [
	"If I am involved in arithmetic with an Integer, convert it to a Float."
	^ rcvr asFloat perform: selector with: self
]

{ #category : #converting }
Float >> asApproximateFraction [
	"Answer a Fraction approximating the receiver. This conversion uses the 
	continued fraction method to approximate a floating point number."

	^ self asApproximateFractionAtOrder: 0
]

{ #category : #converting }
Float >> asApproximateFractionAtOrder: maxOrder [
	"Answer a Fraction approximating the receiver. This conversion uses the 
	continued fraction method to approximate a floating point number. If maxOrder
	is zero, use maximum order"

	| num1 denom1 num2 denom2 int frac newD temp order |
	num1 := self asInteger.	"The first of two alternating numerators"
	denom1 := 1.		"The first of two alternating denominators"
	num2 := 1.		"The second numerator"
	denom2 := 0.		"The second denominator--will update"
	int := num1.		"The integer part of self"
	frac := self fractionPart.		"The fractional part of self"
	order := maxOrder = 0 ifTrue: [-1] ifFalse: [maxOrder].
	[frac = 0 or: [order = 0] ]
		whileFalse: 
			["repeat while the fractional part is not zero and max order is not reached"
			order := order - 1.
			newD := 1.0 / frac.			"Take reciprocal of the fractional part"
			int := newD asInteger.		"get the integer part of this"
			frac := newD fractionPart.	"and save the fractional part for next time"
			temp := num2.				"Get old numerator and save it"
			num2 := num1.				"Set second numerator to first"
			num1 := num1 * int + temp.	"Update first numerator"
			temp := denom2.				"Get old denominator and save it"
			denom2 := denom1.			"Set second denominator to first"
			denom1 := int * denom1 + temp.		"Update first denominator"
			10000000000.0 < denom1
				ifTrue: 
					["Is ratio past float precision?  If so, pick which 
					of the two ratios to use"
					num2 = 0.0 
						ifTrue: ["Is second denominator 0?"
								^ Fraction numerator: num1 denominator: denom1].
					^ Fraction numerator: num2 denominator: denom2]].
	"If fractional part is zero, return the first ratio"
	denom1 = 1
		ifTrue: ["Am I really an Integer?"
				^ num1 "Yes, return Integer result"]
		ifFalse: ["Otherwise return Fraction result"
				^ Fraction numerator: num1 denominator: denom1]
]

{ #category : #converting }
Float >> asFloat [
	"Answer the receiver itself."

	^self
]

{ #category : #converting }
Float >> asFraction [
	^ self asTrueFraction 
]

{ #category : #printing }
Float >> asMinimalDecimalFraction [
	"Answer the shortest decimal Fraction that will equal self when converted back asFloat.
	A decimal Fraction has only powers of 2 and 5 as decnominator.
	For example, 0.1 asMinimalDecimalFraction = (1/10)."

	| significand exp baseExpEstimate r s mPlus mMinus scale roundingIncludesLimits d tc1 tc2 fixedFormat decPointCount slowbit shead denominator numerator |
	self isFinite ifFalse: [self error: 'Only finite Float can be converted to a Fraction'].
	self = 0.0 ifTrue: [^0].
	self < 0.0 ifTrue: [^self negated asMinimalDecimalFraction negated].
	numerator := 0.
	denominator := 0.
	significand := self significandAsInteger.
	roundingIncludesLimits := significand even.
	exp := (self exponent - 52) max: MinValLogBase2.
	baseExpEstimate := (self exponent * 10 asFloat reciprocalLogBase2 - 1.0e-10) ceiling.
	exp >= 0
		ifTrue:
			[significand ~= 16r10000000000000
				ifTrue:
					[r := significand bitShift: 1 + exp.
					s := 2.
					mPlus := mMinus := 1 bitShift: exp]
				ifFalse:
					[r := significand bitShift: 2 + exp.
					s := 4.
					mPlus := 2 * (mMinus := 1 bitShift: exp)]]
		ifFalse:
			[(exp = MinValLogBase2 or: [significand ~= 16r10000000000000])
				ifTrue:
					[r := significand bitShift: 1.
					s := 1 bitShift: 1 - exp.
					mPlus := mMinus := 1]
				ifFalse:
					[r := significand bitShift: 2.
					s := 1 bitShift: 2 - exp.
					mPlus := 2.
					mMinus := 1]].
	baseExpEstimate >= 0
		ifTrue: [s := s * (10 raisedToInteger: baseExpEstimate)]
		ifFalse:
			[scale := 10 raisedToInteger: baseExpEstimate negated.
			r := r * scale.
			mPlus := mPlus * scale.
			mMinus := mMinus * scale].
	((r + mPlus < s) not and: [roundingIncludesLimits or: [r + mPlus > s]])
		ifTrue: [baseExpEstimate := baseExpEstimate + 1]
		ifFalse:
			[r := r * 10.
			mPlus := mPlus * 10.
			mMinus := mMinus * 10].
	(fixedFormat := baseExpEstimate between: -3 and: 6)
		ifTrue:
			[decPointCount := baseExpEstimate.
			baseExpEstimate <= 0
				ifTrue: [denominator := 10 raisedTo: baseExpEstimate negated]]
		ifFalse:
			[decPointCount := 1].
	slowbit := 1 - s lowBit .
	shead := s bitShift: slowbit.
	[d := (r bitShift: slowbit) // shead.
	r := r - (d * s).
	(tc1 := (r > mMinus) not and: [roundingIncludesLimits or: [r < mMinus]]) |
	(tc2 := (r + mPlus < s) not and: [roundingIncludesLimits or: [r + mPlus > s]])] whileFalse:
		[numerator := 10 * numerator + d.
		denominator := 10 * denominator.
		r := r * 10.
		mPlus := mPlus * 10.
		mMinus := mMinus * 10.
		decPointCount := decPointCount - 1.
		decPointCount = 0 ifTrue: [denominator := 1]].
	tc2 ifTrue:
		[(tc1 not or: [r * 2 >= s]) ifTrue: [d := d + 1]].
	numerator := 10 * numerator + d.
	denominator := 10 * denominator.
	decPointCount > 0
		ifTrue:
		[numerator := (10 raisedTo: decPointCount - 1) * numerator].
	fixedFormat ifFalse:
		[(baseExpEstimate - 1) > 0
			ifTrue: [numerator := (10 raisedTo: baseExpEstimate - 1) * numerator]
			ifFalse: [denominator := (10 raisedTo: 1 - baseExpEstimate) * (denominator max: 1)]].
	denominator < 2 ifTrue: [^numerator].
	^numerator / denominator
]

{ #category : #converting }
Float >> asScaledDecimal [

	"Answer a scaled decimal number approximating the receiver.
	
	IEEE 754 double precision numbers use 53 bits to encode mantissa. This means
	that the maximum amount of decimal digits that can be represented is log10(2^53).
	
	Due to the fact that at least one of the decimal digits has to be placed to 
	the left of the decimal point, the scale was set to 15 - 1 = 14."

	^ self asScaledDecimal: 14
]

{ #category : #converting }
Float >> asTrueFraction [
	" Answer a fraction that EXACTLY represents self,
	  a double precision IEEE floating point number.
	  Floats are stored in the same form on all platforms.
	  (Does handle gradual underflow but not NANs.)
	  By David N. Smith with significant performance
	  improvements by Luciano Esteban Notarfrancesco.
	  (Version of 11April97)"
	| signexp positive expPart exp fraction fractionPart signedFraction result zeroBitsCount |
	self isInfinite ifTrue: [self error: 'Cannot represent infinity as a fraction'].
	self isNaN ifTrue: [self error: 'Cannot represent Not-a-Number as a fraction'].


	" Extract the sign and the biased exponent "
	signexp := (self basicAt: 1) bitShift: -20.
	positive := (signexp bitAnd: 16r800) = 0.
	expPart := signexp bitAnd: 16r7FF.

	" Extract fractional part; answer 0 if this is a true 0.0 value "
	fractionPart := (((self basicAt: 1) bitAnd: 16rFFFFF) bitShift: 32)+ (self basicAt: 2).
	( expPart=0 and: [ fractionPart=0 ] ) ifTrue: [ ^ 0  ].

	" Replace omitted leading 1 in fraction unless gradual underflow"
	fraction := expPart = 0
		ifTrue: [fractionPart bitShift: 1]
		ifFalse: [fractionPart bitOr: 16r0010000000000000].
	signedFraction := positive ifTrue: [fraction] ifFalse: [fraction negated].
	
	"Unbias exponent: 16r3FF is bias; 52 is fraction width"
	exp := 16r3FF + 52 - expPart.

	" Form the result. When exp>52, the exponent is adjusted by
	  the number of trailing zero bits in the fraction to minimize
	  the (huge) time otherwise spent in #gcd:. "
	exp negative
		ifTrue: [
			result := signedFraction bitShift: exp negated ]
		ifFalse:	[
			zeroBitsCount := fraction lowBit - 1.
			exp := exp - zeroBitsCount.
			exp <= 0
				ifTrue: [
					zeroBitsCount := zeroBitsCount + exp.
					"exp := 0."   " Not needed; exp not
refernced again "
					result := signedFraction bitShift:
zeroBitsCount negated ]
				ifFalse: [
					result := Fraction
						numerator: (signedFraction
bitShift: zeroBitsCount negated)
						denominator: (1 bitShift:
exp) ] ].

	"Low cost validation omitted after extensive testing"
	"(result asFloat = self) ifFalse: [self error: 'asTrueFraction validation failed']."
	^ result 
]

{ #category : #accessing }
Float >> at: index [ 
	^self basicAt: index
]

{ #category : #accessing }
Float >> at: index put: value [ 
	^self basicAt: index put: value
]

{ #category : #accessing }
Float >> basicAt: index [
	"Primitive. Assumes receiver is indexable. Answer the value of an 
	indexable element in the receiver. Fail if the argument index is not an 
	Integer or is out of bounds. Essential. Do not override in a subclass. See 
	Object documentation whatIsAPrimitive.

	This version of basicAt: is specifically for floats, answering the most significant
	word for index 1 and the least significant word for index 2.  This alows the VM
	to store floats in whatever order it chooses while it appears to the image that
	they are always in big-endian/PowerPC order."

	<primitive: 38>
	^super basicAt: index.
	
]

{ #category : #accessing }
Float >> basicAt: index put: value [
	"Primitive. Assumes receiver is indexable. Store the second argument 
	value in the indexable element of the receiver indicated by index. Fail 
	if the index is not an Integer or is out of bounds. Or fail if the value is 
	not of the right type for this kind of collection. Answer the value that 
	was stored. Essential. Do not override in a subclass. See Object 
	documentation whatIsAPrimitive.

	This version of basicAt: is specifically for floats, answering the most significant
	word for index 1 and the least significant word for index 2.  This alows the VM
	to store floats in whatever order it chooses while it appears to the image that
	they are always in big-endian/PowerPC order."

	<primitive: 39>
	^super basicAt: index put: value
]

{ #category : #printing }
Float >> binaryLiteralString [

	^ String streamContents: [ :stream | self printBinaryLiteralOn: stream ]
]

{ #category : #copying }
Float >> deepCopy [

	^self copy
]

{ #category : #'mathematical functions' }
Float >> exponent [
	^ self subclassResponsibility
]

{ #category : #'mathematical functions' }
Float >> floorLog: radix [
	"Answer the floor of the log base radix of the receiver.
	The result may be off by one due to rounding errors, except in base 2."

	(radix = 2 and: [self > 0.0]) ifTrue: [^self exponent].
	^ (self log: radix) floor

]

{ #category : #comparing }
Float >> hash [
	"Hash is reimplemented because = is implemented. Both words of the float are used; 8 bits are removed from each end to clear most of the exponent regardless of the byte ordering. (The bitAnd:'s ensure that the intermediate results do not become a large integer.) Slower than the original version in the ratios 12:5 to 2:1 depending on values. (DNS, 11 May, 1997)"

	(self isFinite and: [self fractionPart = 0.0]) ifTrue: [^self truncated hash].
	^ (((self basicAt: 1) bitAnd: 16r00FFFF00) +
	   ((self basicAt: 2) bitAnd: 16r00FFFF00)) bitShift: -8

]

{ #category : #printing }
Float >> hex [  

	^ String streamContents:
		[:strm | | word nibble |
		1 to: 2 do:
			[:i | word := self at: i.
			1 to: 8 do: 
				[:s | nibble := (word bitShift: -8+s*4) bitAnd: 16rF.
				strm nextPut: ('0123456789ABCDEF' at: nibble+1)]]]
"
(-2.0 to: 2.0) collect: [:f | f hex]
"
]

{ #category : #testing }
Float >> isFinite [
	"simple, byte-order independent test for rejecting Not-a-Number and (Negative)Infinity"

	^(self - self) = 0.0
]

{ #category : #testing }
Float >> isFloat [
	^ true
]

{ #category : #testing }
Float >> isInfinite [
	"Return true if the receiver is positive or negative infinity."

	^ self = Infinity or: [self = NegativeInfinity]

]

{ #category : #testing }
Float >> isLiteral [
	"There is no literal representation of NaN.
	However, there are literal representations of Infinity, like 1.0e1000.
	But since they are not able to print properly, only case of finite Float is considered."
	
	^self isFinite
]

{ #category : #testing }
Float >> isNaN [
	"simple, byte-order independent test for Not-a-Number"

	^ self ~= self
]

{ #category : #testing }
Float >> isPowerOfTwo [
	"Return true if the receiver is an integral power of two.
	Floats never return true here."
	^false
]

{ #category : #testing }
Float >> isSelfEvaluating [
    ^true
]

{ #category : #testing }
Float >> isZero [
	^self = 0.0
]

{ #category : #comparing }
Float >> literalEqual: other [

	^ (super literalEqual: other) and: [ self isZero not or: [ self signBit = other signBit ] ]
]

{ #category : #arithmetic }
Float >> negated [
	"Answer a Number that is the negation of the receiver.
	Implementation note: this version cares of negativeZero."

	^-1.0 * self
]

{ #category : #printing }
Float >> printBinaryLiteralOn: stream [

	"Floats represent those numbers that can be written in Pharo notation as literals of the form {sign}2r1.{fraction}e{exponent} -- where {sign} is the minus
	sign or is empty, {fraction} is a sequence of 52 bits and {exponent} is an integer from -1022 to 1023 -- as well as those numbers that can be written
	as {sign}2r0.{fraction}e-1022 and some special values. This method prints a Float as such a literal expression, or a message expression in the case of
	the special values. Evaluating the expression always results in a Float with the exact same bit pattern, with the exception of the not-a-number Floats
	which all get printed as 'Float nan'. The following article has a table in the section 'Summary' at the end which enumerates the different bit patterns
	of Floats and how to interpret them, which was used in writing this method: http://steve.hollasch.net/cgindex/coding/ieeefloat.html"

	| signBit exponentBits fractionBits |

	signBit := (self basicAt: 1) bitShift: -31.
	exponentBits := ((self basicAt: 1) bitShift: -20) bitAnd: 2r11111111111.
	fractionBits := (((self basicAt: 1) bitAnd: 2r11111111111111111111) bitShift: 32) bitOr: (self basicAt: 2).

	(exponentBits = 2047) ifTrue: [ 
		(fractionBits = 0) ifTrue: [
			stream nextPutAll: 'Float infinity'.
			(signBit = 1) ifTrue: [ stream nextPutAll: ' negated' ].
		] ifFalse: [
			stream nextPutAll: 'Float nan'.
		].
		^ self
	].

	(signBit = 1) ifTrue: [ stream nextPut: $- ].
	(exponentBits = 0) ifTrue: [ 
		(fractionBits = 0) ifTrue: [
			stream nextPutAll: '0.0'
		] ifFalse: [
			stream nextPutAll: '2r0.'.
			fractionBits printOn: stream base: 2 length: (Float precision - 1) padded: true.
			stream nextPutAll: 'e-1022'.
		].
		^ self
	].

	stream nextPutAll: '2r1.'.
	fractionBits printOn: stream base: 2 length: (Float precision - 1) padded: true.
	stream nextPut: $e.
	(exponentBits - 1023) printOn: stream base: 10.
]

{ #category : #printing }
Float >> printOn: stream base: base [
	"Handle sign, zero, and NaNs; all other values passed to FloatPrintPolicy" 

	self isNaN ifTrue: [ ^ stream nextPutAll: 'Float nan' ]. "check for NaN before sign"
	self isInfinite 
		ifTrue: [ 
			stream nextPutAll: 'Float infinity'.
			^ self sign = -1 ifTrue: [ stream nextPutAll: ' negated' ] ].
	self > 0.0
		ifTrue: [ FloatPrintPolicy absPrint: self on: stream base: base ]
		ifFalse: [
			self signBit = 1 ifTrue: [ stream nextPut: $- ].
			self = 0.0
				ifTrue: [ stream nextPutAll: '0.0' ]
				ifFalse: [ FloatPrintPolicy absPrint: self negated on: stream base: base ] ]
]

{ #category : #printing }
Float >> printPaddedWith: aCharacter to: aNumber [ 
	"Answer the string containing the ASCII representation of the receiver 
	padded on the left with aCharacter to be at least on aNumber 
	integerPart characters and padded the right with aCharacter to be at 
	least anInteger fractionPart characters."
	| aStream digits fPadding fLen iPadding iLen curLen periodIndex |
	#Numeric.
	"2000/03/04  Harmon R. Added Date and Time support"
	aStream := (String new: 10) writeStream.
	self printOn: aStream.
	digits := aStream contents.
	periodIndex := digits indexOf: $..
	curLen := periodIndex - 1.
	iLen := aNumber integerPart.
	curLen < iLen
		ifTrue: [iPadding := (String new: (iLen - curLen) asInteger) atAllPut: aCharacter;
					 yourself]
		ifFalse: [iPadding := ''].
	curLen := digits size - periodIndex.
	"n.b. Treat aNumber as a string format specifier rather than as a number, because
	floating point truncation can produce incorrect results for the fraction part."
	fLen := (aNumber asString copyAfterLast: $. )
		ifNotEmpty: [:s | s asInteger]
		ifEmpty: [ 0 ].
	curLen < fLen
		ifTrue: [fPadding := (String new: fLen - curLen) atAllPut: aCharacter;
					 yourself]
		ifFalse: [fPadding := ''].
	^ iPadding , digits , fPadding
]

{ #category : #printing }
Float >> printShowingDecimalPlaces: placesDesired [
	"This implementation avoids any rounding error caused by rounded or roundTo:"
	
	^self asTrueFraction printShowingDecimalPlaces: placesDesired
]

{ #category : #'mathematical functions' }
Float >> reciprocalFloorLog: radix [ 
	"Quick computation of (self log: radix) floor, when self < 1.0.
	Avoids infinite recursion problems with denormalized numbers"

	| adjust scale n |
	adjust := 0.
	scale := 1.0.
	[(n := radix / (self * scale)) isInfinite]
		whileTrue:
			[scale := scale * radix.
			adjust := adjust + 1].
	^ ((n floorLog: radix) + adjust) negated
]

{ #category : #'mathematical functions' }
Float >> reciprocalLogBase2 [
	"optimized for self = 10, for use in conversion for printing"

	^ self = 10.0
		ifTrue: [Ln2 / Ln10]
		ifFalse: [Ln2 / self ln]
]

{ #category : #copying }
Float >> shallowCopy [

	^self - 0.0
]

{ #category : #'mathematical functions' }
Float >> signBit [
	"Answer 1 if the receiver has sign bit set (including case of IEEE-754 negative-zero).
	Answer 0 otherwise"

	^((self at: 1) bitShift: -31)
]

{ #category : #'mathematical functions' }
Float >> significand [

	^ self timesTwoPower: (self exponent negated)
]

{ #category : #'mathematical functions' }
Float >> significandAsInteger [
	"Answer the mantissa of a Float shifted so as to have the ulp equal to 1.
	For exceptional values, infinity and nan, just answer the bit pattern."

	self isFinite ifTrue:
		[^(self timesTwoPower: self class precision - 1 - (self exponent max: self class emin)) truncated abs].
	^(((self basicAt: 1) bitAnd: 16r000FFFFF) bitShift: 32) bitOr: (self basicAt: 2)
]

{ #category : #printing }
Float >> storeOn: aStream [ 
	"Print the Number exactly so it can be interpreted back unchanged"
	
	self storeOn: aStream base: 10
]

{ #category : #printing }
Float >> storeOn: aStream base: base [ 
	"Print the Number exactly so it can be interpreted back unchanged"
	self isFinite
		ifTrue: [self signBit = 1 ifTrue: [aStream nextPutAll: ' -'].
			base = 10 ifFalse: [aStream print: base; nextPut: $r].
			self = 0.0
				ifTrue: [aStream nextPutAll: '0.0']
				ifFalse: [self abs absPrintExactlyOn: aStream base: base]]
		ifFalse: [self isNaN
				ifTrue: [aStream nextPutAll: 'Float nan']
				ifFalse: [self > 0.0
						ifTrue: [aStream nextPutAll: 'Float infinity']
						ifFalse: [aStream nextPutAll: 'Float infinity negated']]]
]

{ #category : #'mathematical functions' }
Float >> timesTwoPower: anInteger [ 
	^ self subclassResponsibility
]

{ #category : #copying }
Float >> veryDeepCopyWith: deepCopier [
	"Return self.  Do not record me."

	^ self shallowCopy
]
