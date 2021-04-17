"
I am ZdcAbstractSocketStream, a binary read/write stream for socket communication.

Interally, IO is done through a read and a write ZdcIOBuffer.

I am abstract, my subclasses should implement actual IO through a delegate.
"
Class {
	#name : #ZdcAbstractSocketStream,
	#superclass : #Object,
	#instVars : [
		'socket',
		'readBuffer',
		'writeBuffer',
		'timeout',
		'debug'
	],
	#category : #'Zodiac-Core'
}

{ #category : #testing }
ZdcAbstractSocketStream class >> isAbstract [

	^self == ZdcAbstractSocketStream 
]

{ #category : #'instance creation' }
ZdcAbstractSocketStream class >> on: object [
	^ (self basicNew)
		initialize;
		on: object;
		yourself
]

{ #category : #testing }
ZdcAbstractSocketStream >> atEnd [
	"I am atEnd when there is no more data to be read and there never will be.
	This means that readBuffer must be empty, 
	there must be no more unread data available at the socket,
	and the socket must be closed"
	
	^ self subclassResponsibility 
]

{ #category : #compatibility }
ZdcAbstractSocketStream >> autoFlush: boolean [
	"I flush when asked to, or when my buffer is full."
]

{ #category : #compatibility }
ZdcAbstractSocketStream >> binary [
	"I am always binary."
]

{ #category : #compatibility }
ZdcAbstractSocketStream >> bufferSize: numberOfBytes [
	"Not yet implemented. See #initializeBuffers."
]

{ #category : #'initialize-release' }
ZdcAbstractSocketStream >> close [
	"Close the stream, flush if necessary"

	[ self flush ] ensure: [ 
		socket ifNotNil: [ 
			self socketClose.
			socket := nil ].
		readBuffer close.
		writeBuffer close ]
]

{ #category : #accessing }
ZdcAbstractSocketStream >> collectionSpecies [
	"Fixed to ByteArray since we are binary"
	
	^ ByteArray
	
]

{ #category : #private }
ZdcAbstractSocketStream >> debug: aBoolean [
	debug := aBoolean 
]

{ #category : #'private in' }
ZdcAbstractSocketStream >> fillReadBuffer [
	"Ask the delegate to fill the read buffer with data. 
	Wait for at least some data."
	
	self subclassResponsibility  
]

{ #category : #'stream out' }
ZdcAbstractSocketStream >> flush [
	"Flush all pending output that might be in the write buffer"
	
	self flushWriteBuffer 
]

{ #category : #'private out' }
ZdcAbstractSocketStream >> flushWriteBuffer [
	"Ask the delegate to write all data in the write buffer. Fail if not successful"
	
	self subclassResponsibility 
]

{ #category : #'initialize-release' }
ZdcAbstractSocketStream >> initialize [ 
	timeout := 5.
	debug := false.
	self initializeBuffers 
]

{ #category : #'initialize-release' }
ZdcAbstractSocketStream >> initializeBuffers [
	readBuffer := ZdcIOBuffer onByteArrayOfSize: 4096.
	writeBuffer := ZdcIOBuffer onByteArrayOfSize: 4096
]

{ #category : #testing }
ZdcAbstractSocketStream >> isBinary [
	"We are always binary"
	
	^ true
]

{ #category : #testing }
ZdcAbstractSocketStream >> isConnected [
	"Are we connected at the socket level ?"
	
	^ self subclassResponsibility 
]

{ #category : #testing }
ZdcAbstractSocketStream >> isDataAvailable [
	"Return true when there is data available for reading.
	This does not block."
	
	^ self subclassResponsibility 
]

{ #category : #testing }
ZdcAbstractSocketStream >> isStream [
	^ true
]

{ #category : #private }
ZdcAbstractSocketStream >> log: object [
	debug ifTrue: [
		self crTrace: object value ]
	
]

{ #category : #'stream in' }
ZdcAbstractSocketStream >> next [
	"Read and return a single byte"
	
	readBuffer isEmpty ifTrue: [ self fillReadBuffer ].
	^ readBuffer isEmpty
		ifTrue: [ nil ]
		ifFalse: [ readBuffer next ]
]

{ #category : #'stream in' }
ZdcAbstractSocketStream >> next: requestedCount [ 
	"Read requestedCount bytes and return them as a ByteArray.
	If less are available, a smaller ByteArray will be returned."

	^ self 
		next: requestedCount 
		into: (self collectionSpecies new: requestedCount)
]

{ #category : #'stream in' }
ZdcAbstractSocketStream >> next: requestedCount into: collection [
	"Read requestedCount elements into collection,
	returning a copy if less elements are available"
	
	^ self 
		next: requestedCount 
		into: collection 
		startingAt: 1   
]

{ #category : #'stream in' }
ZdcAbstractSocketStream >> next: requestedCount into: collection startingAt: offset [
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

{ #category : #'stream out' }
ZdcAbstractSocketStream >> next: count putAll: collection [
	"Write count bytes from collection"
	
	self 
		next: count 
		putAll: collection 
		startingAt: 1
]

{ #category : #'stream out' }
ZdcAbstractSocketStream >> next: count putAll: collection startingAt: offset [
	"Write count bytes from collection starting at offset.
	This is an inefficient abstract implementation writing bytes one by one."
	
	0 to: count - 1 do: [ :each | 
		self nextPut: (collection at: offset + each) ]
]

{ #category : #'stream in' }
ZdcAbstractSocketStream >> nextInto: collection [
	"Read the next elements of the receiver into collection,
	returning a copy if less elements are available"
	
	^ self
		next: collection size
		into: collection
]

{ #category : #'stream out' }
ZdcAbstractSocketStream >> nextPut: object [
	"Write a single byte"
	
	writeBuffer isFull ifTrue: [ self flushWriteBuffer ].
	writeBuffer nextPut: object
	
]

{ #category : #'stream out' }
ZdcAbstractSocketStream >> nextPutAll: collection [
	"Write a collection of bytes"
	
	self 
		next: collection size 
		putAll: collection 
		startingAt: 1
]

{ #category : #'initialize-release' }
ZdcAbstractSocketStream >> on: object [
	socket := object
]

{ #category : #'stream in' }
ZdcAbstractSocketStream >> peek [
	"Peek and return a single byte"
	
	readBuffer isEmpty ifTrue: [ self fillReadBuffer ].
	^ readBuffer isEmpty
		ifTrue: [ nil ]
		ifFalse: [ readBuffer peek]
]

{ #category : #printing }
ZdcAbstractSocketStream >> printOn: aStream [
	aStream 
		nextPutAll: 'a '; 
		nextPutAll: self class name
]

{ #category : #'stream in' }
ZdcAbstractSocketStream >> readInto: collection startingAt: offset count: requestedCount [
	"Read requestedCount elements into collection starting at offset,
	returning the number of elements read, there could be less elements available.
	This is an inefficient abstract implementation, reading bytes one by one."
	
	0 to: requestedCount - 1 do: [ :count | | object |
		(object := self next) ifNil: [ ^ count ].  
		collection at: offset + count put: object ].
	^ requestedCount
]

{ #category : #compatibility }
ZdcAbstractSocketStream >> shouldSignal: boolean [
	"I always signal exceptional situations."
]

{ #category : #'stream in' }
ZdcAbstractSocketStream >> skip: count [
	"Skip over count bytes.
	This is an inefficient abstract implementation skipping bytes one by one."
	
	count timesRepeat: [ self next ]
]

{ #category : #accessing }
ZdcAbstractSocketStream >> socket [
	"Return the underlying socket object that I delegate I/O to"
	
	^ socket
]

{ #category : #'private socket' }
ZdcAbstractSocketStream >> socketClose [
	socket closeAndDestroy 
]

{ #category : #'private socket' }
ZdcAbstractSocketStream >> socketConnectTo: hostAddress port: portNumber [
	socket 
		connectTo: hostAddress 
		port: portNumber 
		waitForConnectionFor: self timeout        
]

{ #category : #'private socket' }
ZdcAbstractSocketStream >> socketIsConnected [
	^ socket isConnected and: [ socket isOtherEndClosed not ]
]

{ #category : #'private socket' }
ZdcAbstractSocketStream >> socketIsDataAvailable [
	^ socket dataAvailable 
]

{ #category : #'private socket' }
ZdcAbstractSocketStream >> socketReceiveDataInto: bytes startingAt: offset count: count [
	^ socket 
		primSocket: socket socketHandle 
		receiveDataInto: bytes
		startingAt: offset
		count: count
]

{ #category : #'private socket' }
ZdcAbstractSocketStream >> socketSendData: bytes startingAt: offset count: count [
	^ socket 
		sendSomeData: bytes 
		startIndex: offset 
		count: count 
]

{ #category : #'private socket' }
ZdcAbstractSocketStream >> socketWaitForData [
	^ socket waitForDataFor: self timeout
	
]

{ #category : #'private socket' }
ZdcAbstractSocketStream >> socketWaitForSendDone [
	^ socket waitForSendDoneFor: self timeout
	
]

{ #category : #accessing }
ZdcAbstractSocketStream >> timeout [
	"Return the number of seconds we wait for socket IO operations"
	
	^ timeout 
]

{ #category : #accessing }
ZdcAbstractSocketStream >> timeout: seconds [
	"Set the number of seconds we wait for socket IO operations"
	
	timeout := seconds
]

{ #category : #'stream in' }
ZdcAbstractSocketStream >> upTo: value [ 
	"Read bytes upto but not including value and return them as a ByteArray.
	If value is not found, return the entire contents of the stream.
	This is an inefficient abstract implementation reading bytes one by one."
	
	^ self collectionSpecies 
		streamContents: [ :writeStream | | element |
			[ self atEnd or: [ (element := self next) = value ] ] whileFalse: [ 
				writeStream nextPut: element ] ]
]

{ #category : #'stream in' }
ZdcAbstractSocketStream >> upToEnd [
	"Read bytes until the stream is atEnd and return them as a ByteArray.
	This is an inefficient abstract implementation reading bytes one by one.
	Note that even when #atEnd returns false, the following #next could be nil 
	or the connection could suddenly be closed"

	^ self collectionSpecies 
		streamContents: [ :writeStream |
			[ [ self atEnd or: [ self peek isNil ] ] whileFalse: [ 
				writeStream nextPut: self next ] ]
		 		on: ConnectionClosed
				do: [ :exception | exception return ] ]
]
