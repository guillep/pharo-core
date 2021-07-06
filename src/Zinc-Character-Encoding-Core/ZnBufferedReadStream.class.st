"
I am ZnBufferedReadStream.

I wrap another ReadStream and add efficient buffering for the typical access pattern of parsers: sending lots of #next, #peek and #atEnd messages.

By design I do not implement #position and #position: or anything based on that.

I can wrap both binary or character streams and act accordingly.

Part of Zinc HTTP Components.
"
Class {
	#name : #ZnBufferedReadStream,
	#superclass : #Object,
	#instVars : [
		'stream',
		'buffer',
		'position',
		'limit'
	],
	#category : #'Zinc-Character-Encoding-Core'
}

{ #category : #'instance creation' }
ZnBufferedReadStream class >> on: readStream [
	^ self new
		on: readStream;
		yourself
]

{ #category : #convenience }
ZnBufferedReadStream class >> on: readStream do: block [
	"Execute block with as argument a ZnBufferedReadStream on readStream.
	Return the value of block."

	^ block value: (self on: readStream)
]

{ #category : #testing }
ZnBufferedReadStream >> atEnd [
	^ position > limit and: [ stream atEnd ]
	
]

{ #category : #'initialize-release' }
ZnBufferedReadStream >> close [
	stream close
]

{ #category : #testing }
ZnBufferedReadStream >> closed [
	^ stream closed
]

{ #category : #accessing }
ZnBufferedReadStream >> collectionSpecies [
	^ stream isBinary
		ifTrue: [ ByteArray ]
		ifFalse: [ String ]
]

{ #category : #accessing }
ZnBufferedReadStream >> contents [
	
	^ self upToEnd
]

{ #category : #accessing }
ZnBufferedReadStream >> defaultBufferSize [
	^ 2 raisedToInteger: 16
]

{ #category : #private }
ZnBufferedReadStream >> discardBuffer [
	limit := 0.
	position := 1
]

{ #category : #initialization }
ZnBufferedReadStream >> initialize [
	super initialize.
	position := 1.
	limit := 0
]

{ #category : #'accessing - bytes' }
ZnBufferedReadStream >> int16 [
	^ self nextIntegerOfSize: 2 signed: true bigEndian: true 
]

{ #category : #'accessing - bytes' }
ZnBufferedReadStream >> int32 [
	^ self nextIntegerOfSize: 4 signed: true bigEndian: true
]

{ #category : #'accessing - bytes' }
ZnBufferedReadStream >> int8 [
	^ self nextIntegerOfSize: 1 signed: true bigEndian: true 
]

{ #category : #accessing }
ZnBufferedReadStream >> isBinary [
	^ stream isBinary
]

{ #category : #testing }
ZnBufferedReadStream >> isStream [
	^ true
]

{ #category : #accessing }
ZnBufferedReadStream >> next [
	"Return the next element and move over it"
	
	position > limit
		ifTrue: [ self nextBuffer ].
	^ position <= limit
		ifTrue: [ 
			| char |
			char := buffer at: position.
			position := position + 1.
			char ]
		ifFalse: [ nil ]
]

{ #category : #accessing }
ZnBufferedReadStream >> next: requestedCount [ 
	"Read requestedCount elements and return them as a collection.
	If less are available, a smaller collection will be returned."

	^ self 
		next: requestedCount 
		into: (self collectionSpecies new: requestedCount)
]

{ #category : #accessing }
ZnBufferedReadStream >> next: requestedCount into: collection [
	"Read requestedCount elements into collection,
	returning a copy if less elements are available"
	
	^ self 
		next: requestedCount 
		into: collection 
		startingAt: 1   
]

{ #category : #accessing }
ZnBufferedReadStream >> next: requestedCount into: collection startingAt: offset [
	"Read requestedCount elements into collection starting at offset,
	returning a copy if less elements are available"
	
	| read |
	read := self 
		readInto: collection 
		startingAt: offset 
		count: requestedCount.
	^ read = requestedCount 
		ifTrue: [ collection ]
		ifFalse: [ collection copyFrom: 1 to: offset + read - 1 ]     
]

{ #category : #private }
ZnBufferedReadStream >> nextBuffer [
	limit := stream readInto: buffer startingAt: 1 count: buffer size.
	position := 1
]

{ #category : #'accessing - bytes' }
ZnBufferedReadStream >> nextInt32 [
	^ self nextIntegerOfSize: 4 signed: true bigEndian: true
]

{ #category : #'accessing - bytes' }
ZnBufferedReadStream >> nextIntegerOfSize: numberOfBytes signed: signed bigEndian: bigEndian [
	"Assuming the receiver is a stream of bytes, read the next integer of size numberOfBytes.
	If bigEndian is true, use network byte order, most significant byte first, 
	else use little endian order, least significant byte first.
	If signed is true, interpret as a two-complement signed value, 
	else interpret as a plain unsigned value."
	
	| value |
	value := 0.
	bigEndian
		ifTrue: [ 
			(numberOfBytes - 1) * 8 to: 0 by: -8 do: [ :shift |
				value := value + (self next bitShift: shift) ] ]
		ifFalse: [ 
			0 to: (numberOfBytes - 1) * 8 by: 8 do: [ :shift |
				value := value + (self next bitShift: shift) ] ].
	^ (signed and: [ (value bitAt: numberOfBytes * 8) = 1 ])
		ifTrue: [ value - (1 << (numberOfBytes * 8)) ]
		ifFalse: [ value ]
]

{ #category : #accessing }
ZnBufferedReadStream >> nextInto: collection [
	"Read the next elements of the receiver into collection,
	returning a copy if less elements are available"
	
	^ self
		next: collection size
		into: collection
]

{ #category : #'accessing - bytes' }
ZnBufferedReadStream >> nextLittleEndianNumber: numberOfBytes [
	^ self nextIntegerOfSize: numberOfBytes signed: false bigEndian: false
]

{ #category : #'accessing - bytes' }
ZnBufferedReadStream >> nextNumber: numberOfBytes [
	^ self nextIntegerOfSize: numberOfBytes signed: false bigEndian: true
]

{ #category : #'accessing - bytes' }
ZnBufferedReadStream >> nextWord [
	^ self nextIntegerOfSize: 2 signed: false bigEndian: true
]

{ #category : #'initialize-release' }
ZnBufferedReadStream >> on: readStream [
	stream := readStream.
	self sizeBuffer: self defaultBufferSize
]

{ #category : #accessing }
ZnBufferedReadStream >> peek [
	"Return the next element but do not move over it"
	
	position > limit
		ifTrue: [ self nextBuffer ].
	^ position <= limit
		ifTrue: [ buffer at: position ]
		ifFalse: [ nil ]
]

{ #category : #accessing }
ZnBufferedReadStream >> peekFor: object [
	"Answer false and do not move over the next element if it is not equal to object, or if the receiver is at the end. 
	Answer true and move over the next element when it is equal to object."

	^ self peek = object
		ifTrue: [ 
			self next.
			true ]
		ifFalse: [ false ]
]

{ #category : #accessing }
ZnBufferedReadStream >> position [
	
	"If the buffer advanced, we need to check the original stream position, minus what we have read.
	The -1 is because the buffer is base 1"
	^ stream position - limit + position - 1
]

{ #category : #accessing }
ZnBufferedReadStream >> position: anInteger [ 
	
	| bufferEnd bufferStart |
	bufferEnd := stream position.
	bufferStart := bufferEnd - limit.
	(anInteger between: bufferStart and: bufferEnd)
		ifTrue: [ position := anInteger - bufferStart + 1 ]
		ifFalse: [ 
			"We reset the buffer and update the position in the underlying stream"
			limit := 0.
			position := 1.
			stream position: anInteger ]
]

{ #category : #private }
ZnBufferedReadStream >> readFromBufferInto: collection startingAt: offset count: requestedCount [
	"Read up to requestedCount elements into collection starting at offset,
	from my buffer, answering the number of elements read.
	There could be fewer elements buffered."

	| read |
	read := 0.
	position <= limit
		ifTrue: [ read := limit - position + 1 min: requestedCount.
			collection
				replaceFrom: offset
				to: offset + read - 1
				with: buffer
				startingAt: position.
			position := position + read ].
	^ read
]

{ #category : #accessing }
ZnBufferedReadStream >> readInto: collection startingAt: offset count: requestedCount [
	"Read requestedCount elements into collection starting at offset,
	answering the number of elements read, there could be fewer elements available."

	| countRead countYetToRead |
	"First, read from elements already in my buffer."
	countRead := self readFromBufferInto: collection startingAt: offset count: requestedCount.
	countYetToRead := requestedCount - countRead.
	countYetToRead > 0
		ifTrue: [ "See if there are more elements to be read from the underlying stream"
			| newOffset |
			newOffset := offset + countRead.
			(self shouldBufferReadOfCount: countYetToRead)
				ifTrue: [ self nextBuffer.
					limit > 0
						ifTrue:
							[ countRead := countRead + (self readInto: collection startingAt: newOffset count: countYetToRead) ] ]
				ifFalse:
					[ countRead := countRead + (stream readInto: collection startingAt: newOffset count: countYetToRead) ] ].
	^ countRead
]

{ #category : #accessing }
ZnBufferedReadStream >> setToEnd [
	
	self position: stream size
]

{ #category : #private }
ZnBufferedReadStream >> shouldBufferReadOfCount: elementCount [
	"For larger read requests, buffering fails to give an advantage."

	^ elementCount < (buffer size / 2)
]

{ #category : #accessing }
ZnBufferedReadStream >> size [

	^ stream size
]

{ #category : #'initialize-release' }
ZnBufferedReadStream >> sizeBuffer: size [
	buffer := self collectionSpecies new: size
]

{ #category : #accessing }
ZnBufferedReadStream >> skip: count [
	"Skip over count elements.
	This could be further optimzed."
	
	count timesRepeat: [ self next ]
]

{ #category : #'accessing - bytes' }
ZnBufferedReadStream >> uint16 [
	^ self nextIntegerOfSize: 2 signed: false bigEndian: true 
]

{ #category : #'accessing - bytes' }
ZnBufferedReadStream >> uint32 [
	^ self nextIntegerOfSize: 4 signed: false bigEndian: true 
]

{ #category : #'accessing - bytes' }
ZnBufferedReadStream >> uint8 [
	^ self nextIntegerOfSize: 1 signed: false bigEndian: true
]

{ #category : #accessing }
ZnBufferedReadStream >> upTo: value [ 
	"Read upto but not including value and return them as a collection.
	If value is not found, return the entire contents of the stream.
	This could be further optimzed."
	
	^ self collectionSpecies 
		streamContents: [ :writeStream | | element |
			[ self atEnd or: [ (element := self next) = value ] ] whileFalse: [ 
				writeStream nextPut: element ] ]
]

{ #category : #accessing }
ZnBufferedReadStream >> upToEnd [
	"Read elements until the stream is atEnd and return them as a collection."

	^ self collectionSpecies
		streamContents: [ :out | 
			[ self atEnd ] whileFalse: [ 
				position > limit
					ifTrue: [ self nextBuffer ].	
				out next: limit - position + 1 putAll: buffer startingAt: position.
				position := limit + 1 ] ]
]

{ #category : #accessing }
ZnBufferedReadStream >> wrappedStream [
	^ stream
]
