"
I represent an IPv4 socket or network address .
I am a ByteArray.

A standard IPv4 address consists of 4 bytes and is usually shown in its human readeable dotted format (four decimal integers between 0 and 255 separated by dots).

Examples:

	SocketAddress fromDottedString: '192.168.1.10'.
	
	#[ 192 168 1 10 ] asSocketAddress.
	
	NetNameResolver localHostAddress.

	NetNameResolver addressForName: NetNameResolver localHostName.
	
Reference

	https://en.wikipedia.org/wiki/IP_address
"
Class {
	#name : #SocketAddress,
	#superclass : #ByteArray,
	#type : #bytes,
	#category : #'Network-Kernel-Base'
}

{ #category : #'instance creation' }
SocketAddress class >> fromDottedString: string [
	"Create a SocketAddress from its dotted notation"

	"self fromDottedString: '192.168.1.1'"

	| integers |
	integers := ($. split: string) collect: [ :each | Integer readFrom: each ].
	integers size = 4 ifFalse: [ SizeMismatch signal ].
	integers do: [ :each | 
		(each between: 0 and: 255)
			ifFalse: [ DomainError signalFrom: 0 to: 255 ] ].
	^ self newFrom: integers
]

{ #category : #'instance creation' }
SocketAddress class >> fromOldByteAddress: byteArray [
	"Create a SocketAddress from byteArray, enforcing the correc length, 4"
	
	byteArray size = 4 ifFalse: [ SizeMismatch signal ].
	^ self newFrom: byteArray
]

{ #category : #'instance creation' }
SocketAddress class >> zero [
	"Return the zero SocketAddress, 0.0.0.0"
	
	^ self basicNew: 4
]

{ #category : #converting }
SocketAddress >> asSocketAddress [

]

{ #category : #printing }
SocketAddress >> displayStringOn: stream [
	"Overwrite to get standard object behaviour"
	
	^ self printOn: stream
]

{ #category : #testing }
SocketAddress >> isPrivateAddress [
	^ self first = 10
		or: [ (self first = 172 and: [ self second between: 16 and: 31 ])
				or: [ self first = 192 and: [ self second = 168 ] ] ]
]

{ #category : #printing }
SocketAddress >> printOn: stream [
	self 
		do: [ :each | each printOn: stream ] 
		separatedBy: [ stream nextPut: $. ]
]
