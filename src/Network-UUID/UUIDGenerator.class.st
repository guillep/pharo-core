"
I am UUIDGenerator, I generate UUIDs.

An RFC4122 Universally Unique Identifier (UUID) is an opaque 128-bit number that can be used for identification purposes. Concretely, a UUID is a 16 element byte array.

The intent of UUIDs is to enable distributed systems to uniquely identify information without significant central coordination. In this context the word unique should be taken to mean ""practically unique"" rather than ""guaranteed unique"".
 
I generate UUIDs similar, in spirit, to those defined in RFC4122, though I use version 0 to indicate that I follow none of the defined versions. This does not matter much, if at all, in practice.

I try to conform to the following aspects:
 - each 'node' (machine, image, instance) should generate unique UUIDs
 - even when generating UUIDs at a very fast rate, they should remain unique
 - be fast and efficient

To achieve this goal, I
- take several aspects into account to generate a unique node ID
- combine a clock, a counter and some random bits
- hold a state, protected for multi user access

I can generate about 500K UUIDs per second.

Implementation:

Although a UUID should be seen as totally opaque, here is the concrete way I generate one:
- the first 8 bytes are the microsecond clock value with the smallest quantity first; this means that the later of these 8 bytes will be identical when generated with small(er) timespans; within the same clock resolution interval, the full first 8 bytes will be identical
- the next 2 bytes represent a counter with safe overflow, held as protected state inside me; after 2*16 this value will repeat; the counter initalizes with a random value
- the next 2 bytes are simply random, based on the system PRNG, Random
- the final 4 bytes represent the node ID; the node ID is unique per instance of me, across OS environments where the image might run; the node ID is the MD5 hash of a string that is the concatenation of several elements (see #computeNodeIdentifier)
 
Some bits are set to some predefined value, to indicate the variant and version (see #setVariantAndVersion:)

Usage:

  UUIDGenerator next.
  UUIDGenerator current next.
  UUIDGenerator new next.

Sharing an instance is more efficient and correct.
Instances should be reset whenever the image comes up.

See also:

  http://en.wikipedia.org/wiki/UUID
  https://tools.ietf.org/html/rfc4122

"
Class {
	#name : #UUIDGenerator,
	#superclass : #Object,
	#instVars : [
		'node',
		'random',
		'counter',
		'lock'
	],
	#classVars : [
		'Default'
	],
	#category : #'Network-UUID-Base'
}

{ #category : #accessing }
UUIDGenerator class >> default [
	"Return the default UUID generator.
	Sharing an instance is more efficient and correct."
	
	^ Default ifNil: [ Default := self new ]
]

{ #category : #initialization }
UUIDGenerator class >> initialize [
	SessionManager default
		registerNetworkClassNamed: self name
]

{ #category : #accessing }
UUIDGenerator class >> next [
	"Return a UUID using the shared generator"
	
	"self next"
	
	"[ UUIDGenerator next ] bench"
	
	^ self default next
]

{ #category : #'system startup' }
UUIDGenerator class >> startUp [
	"Whenever the image comes up, reset so that a new node ID is computed."
	
	Default := nil
]

{ #category : #private }
UUIDGenerator >> clockOn: stream [
	"Write 8 bytes from the microsecond clock to stream"
	
	| microseconds |
	microseconds := Time microsecondClockValue.
	1 to: 8 do: [ :each |
		stream nextPut: (microseconds byteAt: each) ]
]

{ #category : #private }
UUIDGenerator >> computeNodeIdentifier [
	"Compute and return a 'node identifier', a 16 element byte array that should be unique to this image, vm, invocation, network, machine combination"
	
	| nodeData |
	nodeData := String streamContents: [ :out |
		Smalltalk at: #NetNameResolver ifPresent: [ :netNameResolver |
			out print: netNameResolver localHostAddress.
			out print: netNameResolver localHostName].
		out print: SystemVersion current.
		out print: Smalltalk vm imagePath.
		out print: Smalltalk commandLine options.
		out print: SessionManager default currentSession hash.
		out print: self hash ].
	^ (MD5 hashMessage: nodeData) hash asByteArrayOfSize: 4
]

{ #category : #initialization }
UUIDGenerator >> initialize [
	super initialize.
	random := Random new.
	"This prior usage of a Semaphore has been exchanged because there are reports that
	the Semaphore did not work in concurrent situations. So the Mutex adds some extra 
	bits here for usage in multi threaded environments"
	lock := Mutex new.
	node := self computeNodeIdentifier.
	counter := self nextRandom16
	
]

{ #category : #accessing }
UUIDGenerator >> next [
	"Return the next UUID, see my class comment"
	
	| uuid |
	uuid := UUID nilUUID.
	self placeFields: uuid.
	^ uuid
]

{ #category : #private }
UUIDGenerator >> nextCounter16 [
	"Return the next 16-bit counter value with safe overflow"
	
	counter := (counter + 1) \\ 16r10000.
	^ counter
]

{ #category : #private }
UUIDGenerator >> nextRandom16 [
	"Return the next 16-bit random value from my random generator"

	^ (random nextInteger: 16r10000) - 1
]

{ #category : #private }
UUIDGenerator >> placeFields: uuid [
	"Fill the fields of uuid, effectively generating a new UUID in place, see my class comment"
	
	| byteStream |
	lock critical: [ 
		byteStream := uuid writeStream.
		self clockOn: byteStream.
		byteStream
			uint16: self nextCounter16;
			uint16: self nextRandom16;
			nextPutAll: node.
		self setVariantAndVersion: uuid ] 
]

{ #category : #accessing }
UUIDGenerator >> randomGenerator [
	"Return the random generator that I use"
	
	^ random
]

{ #category : #private }
UUIDGenerator >> setVariantAndVersion: uuid [
	"Set the version (top four most significant bits) to 0, an undefined version in RFC 4122"
	
	uuid at: 7 put: ((uuid at: 7) bitAnd: 2r1111).
	"Set the variant (top two most significant bits) to '10', the RFC 4122 variant"
	uuid at: 9 put: (((uuid at: 9) bitAnd: 2r111111) bitOr: 2r10000000)
]
