"
I am a an object representing a Windows platform. Use myself to access platform specific features.

Please keep me polymorphic to the the other platform objects.

To get the current platform, you can evaluate:

OSPlatform current.
"
Class {
	#name : #WinPlatform,
	#superclass : #OSPlatform,
	#category : #'System-Platforms-Windows'
}

{ #category : #testing }
WinPlatform class >> isActivePlatform [
	"Answer whether the receiver is the active platform"
	^ false
]

{ #category : #visiting }
WinPlatform >> accept: aVisitor [

	^ aVisitor visitWindows: self
]

{ #category : #accessing }
WinPlatform >> defaultMaximumPathLength [
		"This method returns the default maximum path length for the getCurrentWorkingDirectory implementation. Windows default PATH_MAX is 260.  PATH_MAX is needed to avoid buffer overflow.  In case PATH_MAX is not sufficient the method currentWorkingDirectoryWithBufferSize: can be used to give desired buffer size. The path can include unicode characters, so it can be longer than 260, doubling it should be enough"
		
	 ^ 260 * 2 

]

{ #category : #accessing }
WinPlatform >> family [
	^#Windows
]

{ #category : #'library path' }
WinPlatform >> ffiLibraryName [

	^ #Kernel32
]

{ #category : #'environment-variables' }
WinPlatform >> getEnvironmentVariable: lpName into: lpBuffer size: nSize [
	"Primitive to obtain an environment variable using windows Wide Strings"
	^ self ffiCall: #(ulong GetEnvironmentVariableW (Win32WideString lpName, Win32WideString  lpBuffer, ulong nSize))
]

{ #category : #accessing }
WinPlatform >> getPwdViaFFI: buffer size: bufferSize [
	"This method calls the Standard C Library getcwd() function. The name of the argument (arg1) should fit decompiled version. This method is used in getting the current working directory. getcwd is preffered over pwd because getcwd takes care of re-initialization of environment variables, whereas pwd needs implict re- initialization.
	
	This method should be removed, as we should delegate to the VM
	
	We use FFI-OldFFIBackend for this because this is required for bootstrapping, and we ensure minimal dependencies."
	
	| wideString return |
	
	wideString := Win32WideString new: bufferSize.
	
	return := (ExternalLibraryFunction 
			name: '_wgetcwd'
			module: 'msvcrt.dll'
			callType: 0
			returnType: ExternalType char asPointerType
			argumentTypes: {
				ExternalType char asPointerType.
				ExternalType long })
					invokeWith: wideString getHandle with: bufferSize.

	return ifNil: [ ^ nil ].
	
	"The primitive is returning an string that is encoded in UTF8. We need to emulate the same behavior"
	^ wideString asString utf8Encoded asString
]

{ #category : #testing }
WinPlatform >> isWindows [
	^ true
]

{ #category : #accessing }
WinPlatform >> keyForValue: aKeyValue [
	^KeyboardKey valueForWindowsPlatform: aKeyValue.
]

{ #category : #accessing }
WinPlatform >> lastError [

	^ self ffiCall: #(ulong GetLastError())
]

{ #category : #accessing }
WinPlatform >> lineEnding [

	^ String crlf
]

{ #category : #accessing }
WinPlatform >> menuShortcutString [
	^ 'ctrl'
]

{ #category : #'string-manipulation' }
WinPlatform >> multiByteToWideCharacterCodepage: codepage flags: flags input: input inputLen: inputLen output: output outputLen: outputLen [

	^self ffiCall: #(int MultiByteToWideChar(uint codepage, ulong flags, void* input, int inputLen, Win32WideString output, int outputLen ))
]

{ #category : #'environment-variables' }
WinPlatform >> setEnvironmentVariable: nameString value: valueString [

	 ^ self ffiCall: #( int SetEnvironmentVariableW ( Win32WideString nameString, Win32WideString valueString ) )
]

{ #category : #accessing }
WinPlatform >> setLastError: aValue [

	^ self ffiCall: #(void SetLastError(ulong aValue))
]

{ #category : #accessing }
WinPlatform >> virtualKey: virtualKeyCode [
	"Win32Platform virtualKey: $C charCode"

	(virtualKeyCode between: 65 "$A charCode" and: 90 "$Z")
		ifFalse: [^nil].
	"#($a $b $c $d $e $f $g $h $i $j $k $l $m $n $o $p $q $r $s $t $u $v $w $x $y $z)"
	
	^(#($a nil $c $d nil $f $g nil nil nil nil $l $m $n nil $p nil nil $s nil nil $v nil $x nil $z)
		at: virtualKeyCode-64) ifNotNil: [:char | char charCode]
]

{ #category : #'string-manipulation' }
WinPlatform >> wideCharacterToMultiByteCodepage: codepage flags: flags input: input inputLen: inputLen output: output outputLen: outputLen [

	^self ffiCall: #(int WideCharToMultiByte(uint codepage, ulong flags, Win32WideString input, int inputLen, void* output, int outputLen, int 0, int 0))
]
