"
I represent a Win32 wide string, supporting non-ascii characters.
I manage the conversion between Pharo strings and Windows strings.

(Win32String fromString: 'âùö') asString = 'âùö'

! Implementation Details

I'm on purpose a subclass of ExternalObject and not FFIExternalObject.
The rationale is that the kernel should not be tied to UFFI (which depends on the compiler) to do simple ffi calls. Because of this I implement on #handle, #handle: and #asExternalTypeOn: to be compatible with UFFI external structures.
"
Class {
	#name : #Win32WideString,
	#superclass : #ExternalObject,
	#category : #'System-Platforms-Windows'
}

{ #category : #'instance creation' }
Win32WideString class >> fromByteArray: byteArray [
	^ self fromHandle: byteArray
]

{ #category : #'instance creation' }
Win32WideString class >> fromHandle: handle [
	^ self new
		setHandle: handle;
		yourself
]

{ #category : #'instance creation' }
Win32WideString class >> fromString: aString [
	| requestedSize r wideString anUTF8String codepage |

	anUTF8String := aString utf8Encoded copyWith: 0.
	codepage := 65001.

	requestedSize := OSPlatform current
		multiByteToWideCharacterCodepage: codepage
		flags: 0
		input: anUTF8String
		inputLen: anUTF8String size + 1
		output: self null
		outputLen: 0.

	requestedSize = 0 
		ifTrue: [ self error: 'Error while transforming utf8 string ', 
				aString, ' using codepage ', codepage asString  ].

	wideString := self new: requestedSize.

	r := OSPlatform current
		multiByteToWideCharacterCodepage: codepage
		flags: 0
		input: anUTF8String
		inputLen: anUTF8String size + 1
		output: wideString
		outputLen: wideString byteSize.


	r = 0 ifTrue: [ self error: 'Error while transforming utf8 string ', aString, ' using codepage ', codepage asString  ].
	
	^ wideString
]

{ #category : #'instance creation' }
Win32WideString class >> new: size [
	^ self new
		setHandle: (ByteArray new: (size + 1) * 2);
		yourself.

]

{ #category : #converting }
Win32WideString >> asString [
	| out r codepage |

	(handle isNil or: [ handle isNull ])
		ifTrue: [ ^ '' ].
	
	codepage := 65001.

	r := OSPlatform current
		wideCharacterToMultiByteCodepage: codepage
		flags: 0
		input: self
		inputLen: self size + 1
		output: ExternalAddress null
		outputLen: 0.

	r = 0 ifTrue: [ self error: 'Error while transforming windows wide string using codepage ', codepage asString ].

	out := ByteArray new: r.
	out pinInMemory.

	r := OSPlatform current
		wideCharacterToMultiByteCodepage: codepage
		flags: 0
		input: self
		inputLen: self size + 1
		output: out
		outputLen: out size.
		
	r = 0 ifTrue: [ self error: 'Error while transforming windows wide string using codepage ', codepage asString ].

	^ out allButLast utf8Decoded
]

{ #category : #converting }
Win32WideString >> asWin32WideString [
	^ self.
]

{ #category : #accessing }
Win32WideString >> byteSize [
	^ handle isExternalAddress
		ifTrue: [ (self size + 1) * 2 ]
		ifFalse: [ handle size ]
]

{ #category : #printing }
Win32WideString >> printOn: aStream [
	aStream 
		nextPutAll: 'a ' ;
		nextPutAll: self class name;
		nextPut: $(;
		print: self asString;
		nextPut: $)
]

{ #category : #accessing }
Win32WideString >> size [
	| size pos |
	size := 0.
	pos := 1.

	[ (handle unsignedByteAt: pos) = 0 and: [ (handle unsignedByteAt: pos + 1) = 0 ] ]
		whileFalse: [ size := size + 1.
			pos := pos + 2 ].

	^ size
]
