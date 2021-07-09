"
This Random Number Generator graciously contributed by David N. Smith.  It is an adaptation of the Park-Miller RNG [1] which uses Floats to avoid the need for LargeInteger arithmetic.

If you just want a quick random integer, use:
		10 atRandom
Every integer interval can give a random number:
		(6 to: 12) atRandom
SequenceableCollections can give randomly selected elements:
		'pick one of these letters randomly' atRandom
SequenceableCollections also respond to shuffled, as in:
		($A to: $Z) shuffled

The correct way to use class Random is to store one in an instance or class variable:
		myGenerator := Random new.
Then use it every time you need another number between 0.0 and 1.0 (excluding)
		myGenerator next
You can also generate a positive integer
		myGenerator nextInt: 10
		
[1] 'Random Number Generators:  Good Ones Are Hard to Find' 
by Stephen K. Park and Keith W. Miller 
(Comm. Asso. Comp. Mach., 31(10):1192--1201, 1988). http://www.firstpr.com.au/dsp/rand31/p1192-park.pdf
"
Class {
	#name : #Random,
	#superclass : #Object,
	#instVars : [
		'seed',
		'a',
		'm',
		'q',
		'r'
	],
	#category : #'Random-Core-Base'
}

{ #category : #testing }
Random class >> bucketTest: randy [
	"Execute this:   Random bucketTest: Random new"

	" A quick-and-dirty bucket test. Prints nbuckets values on the
Transcript.
	  Each should be 'near' the value of ntries. Any run with any value
'far' from ntries
	  indicates something is very wrong. Each run generates different
values.
	  For a slightly better test, try values of nbuckets of 200-1000 or
more; go get coffee.
	  This is a poor test; see Knuth.   Some 'OK' runs:
		1000 1023 998 969 997 1018 1030 1019 1054 985 1003
		1011 987 982 980 982 974 968 1044 976
		1029 1011 1025 1016 997 1019 991 954 968 999 991
		978 1035 995 988 1038 1009 988 993 976
"

	<script: 'Random bucketTest: Random new'>
	| nbuckets buckets ntrys |
	nbuckets := 20.
	buckets := Array new: nbuckets.
	buckets atAllPut: 0.
	ntrys := 100.
	ntrys * nbuckets
		timesRepeat: [ | slot |
			slot := (randy next * nbuckets) floor + 1.
			buckets at: slot put: (buckets at: slot) + 1 ].
	self
		trace:
			(String
				streamContents: [ :stream | 
					stream cr.
					1 to: nbuckets do: [ :nb | 
						(buckets at: nb) printOn: stream.
						stream space ] ])
]

{ #category : #'instance creation' }
Random class >> seed: anInteger [ 
	^self new seed: anInteger
]

{ #category : #initialization }
Random >> initialize [
	self useClockBasedSeed.
	a := 16r000041A7 asFloat.    " magic constant =      16807 = 7^5"
	m := 16r7FFFFFFF asFloat.    " magic constant = 2147483647 = 2^31 - 1"
	q := (m quo: a) asFloat.
	r  := (m \\ a) asFloat.

]

{ #category : #accessing }
Random >> next [
	"Answer a random Float in the interval [0 to 1)."

	^ self privateNextValue
]

{ #category : #accessing }
Random >> next: anInteger [
	^ self next: anInteger into: (Array new: anInteger)
]

{ #category : #accessing }
Random >> next: anInteger into: anArray [
	1 to: anInteger do: [:index | anArray at: index put: self privateNextValue].
	^ anArray
]

{ #category : #accessing }
Random >> nextBetween: lowerBound and: higherBound [
	"Answer a random float number from the range [lowerBound, higherBound)"
	^ lowerBound + (self next * (higherBound - lowerBound))
]

{ #category : #accessing }
Random >> nextInt: anInteger [
	"Answer a random integer in the interval [1, anInteger].
	Handle large numbers too (for cryptography)."

	self
		deprecated: 'Use #nextInteger: instead'
		transformWith: '`@rec nextInt: `@arg' -> '`@rec nextInteger: `@arg'.
		
	^ self nextInteger: anInteger
]

{ #category : #accessing }
Random >> nextIntBetween: lowerBound and: higherBound [
	"Answer a random integer number from the inclusive range [lowerBound, higherBound]"
	
	self
		deprecated: 'Use #nextIntegerBetween:and: instead'
		transformWith: '`@rec nextIntBetween: `@arg1 and: `@arg2' -> '`@rec nextIntegerBetween: `@arg1 and: `@arg2'.
		
	^ self nextIntegerBetween: lowerBound and: higherBound
]

{ #category : #accessing }
Random >> nextInteger: anInteger [
	"Answer a random integer in the interval [1, anInteger].
	Handle large numbers too (for cryptography)."

	anInteger strictlyPositive ifFalse: [ self error: 'Range must be positive' ].
	anInteger asFloat isInfinite "are we outside the range of float? - use fraction"
		ifTrue: [^(self privateNextValue asFraction * anInteger) truncated + 1].
	^ (self privateNextValue * anInteger) truncated + 1
]

{ #category : #accessing }
Random >> nextIntegerBetween: lowerBound and: higherBound [
	"Answer a random integer number from the inclusive range [lowerBound, higherBound]"
	^ lowerBound + (self nextInteger: (higherBound - lowerBound + 1)) - 1
]

{ #category : #private }
Random >> privateNextSeed [
	"This method generates random instances of Integer 	in the interval
	0 to 16r7FFFFFFF. This method does NOT update the seed; repeated sends
	answer the same value. The algorithm is described in detail in [1]"

	| lo hi aLoRHi |
	hi := (seed quo: q) asFloat.
	lo := seed - (hi * q).  " = seed rem: q"  
	aLoRHi := (a * lo) - (r * hi).
	^(aLoRHi > 0.0)
		ifTrue:  [aLoRHi]
		ifFalse: [aLoRHi + m].
]

{ #category : #private }
Random >> privateNextValue [
	"Answer a random Float in the interval [0 to 1)."

	^ (seed := self privateNextSeed) / m
]

{ #category : #private }
Random >> seed [
	"Since [1] says... 
	    'After initialization the ideal solution is to hide seed from the user'
	...this method is placed in the 'private' protocol. Perhaps it sould even be deleted."
	^ seed
]

{ #category : #initialization }
Random >> seed: aNumber [
	"Refer #privateNextSeed and [1], seed should be positive and less than m"
	| newSeed |
	newSeed := aNumber.
	[ newSeed > 0 ] whileFalse: 
		[ newSeed := newSeed + m ].
	[ newSeed < m ] whileFalse:
		[ newSeed := newSeed - m ].
	seed := newSeed.

]

{ #category : #initialization }
Random >> useClockBasedSeed [
	"Set a reasonable Park-Miller starting seed [1] based on the ms clock."

	[ seed := (Time millisecondClockValue bitAnd: 16r3FFFFFFF) bitXor: self hash.
	seed = 0 ] whileTrue: [ "Try again if ever get a seed = 0" ]
]

{ #category : #initialization }
Random >> useUnixRandomGeneratorSeed [
	"Try to seed the receiver using random bytes from a Unix OS' /dev/random.
	Return true if we succeeded, false otherwise.
	Note that this might block until the OS thinks it has enough entropy."

	^ [ (File named: '/dev/random') readStreamDo: [ :in | 
			[ seed := (in next: 4) asInteger.
			seed isZero ] whileTrue. "Try again if we ever get a zero value"
			true ] ]
		on: Error
		do: [ false ]
]
