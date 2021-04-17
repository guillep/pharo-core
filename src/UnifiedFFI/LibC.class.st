"
I'm a module defining access to standard LibC. 
I'm available under Linux and OSX.
Under windows I provide similar functionality through the functions defined in msvcrt.dll
"
Class {
	#name : #LibC,
	#superclass : #FFILibrary,
	#category : #'UnifiedFFI-Libraries'
}

{ #category : #'api - accessing' }
LibC class >> fgetc: aCStream [
	"Get character from the given C stream."
	
	^self uniqueInstance fgetc: aCStream
]

{ #category : #'api - misc' }
LibC class >> memCopy: from to: to size: size [
	^ self uniqueInstance  
		memCopy: from 
		to: to 
		size: size
]

{ #category : #'api - piping' }
LibC class >> pipe: command mode: mode [
	"Initiate pipe streams to or from a process."
	
	^ self uniqueInstance pipe: command mode: mode
]

{ #category : #'api - piping' }
LibC class >> pipeClose: stream [
	"Close the given pipe stream."
	
	^ self uniqueInstance pipeClose: stream
]

{ #category : #'process actions' }
LibC class >> resultOfCommand: aCommand [

	^self uniqueInstance resultOfCommand: aCommand  
]

{ #category : #'process actions' }
LibC class >> runCommand: aCommand [

	^self uniqueInstance system: aCommand  
]

{ #category : #'api - misc' }
LibC class >> system: command [
	^ self uniqueInstance system: command
]

{ #category : #'api - processes' }
LibC >> currentProcessId [
	"Returns the process identifier (PID) of the calling process."
 
	 ^self ffiCall: #(int getpid(void)) 
]

{ #category : #'api - accessing' }
LibC >> fgetc: stream [
	"Get character from stream."
	 
	 ^self ffiCall: #(int* fgetc(void* stream))
]

{ #category : #'private - accessing' }
LibC >> macLibraryName [
	^ 'libc.dylib'
]

{ #category : #'api - misc' }
LibC >> memCopy: src to: dest size: n [
	^ self
		ffiCall: #(#void #* #memcpy #(#void #* #dest #, #const #void #* #src #, #size_t #n))
]

{ #category : #'api - processes' }
LibC >> parentProcessId [
	"Returns the process ID of the parent of the calling process."
	 
	 ^self ffiCall: #(int getppid(void))
]

{ #category : #'api - piping' }
LibC >> pipe: command mode: mode [
	"Initiate pipe streams to or from a process."

	^self ffiCall: (Smalltalk os isWindows
							ifTrue:  [ #(void* _popen(char* command, char* mode)) ]
							ifFalse: [ #(void* popen(char* command, char* mode)) ])

	
			 
]

{ #category : #'api - piping' }
LibC >> pipeClose: stream [
	"Close the given pipe stream."

	^self ffiCall: (Smalltalk os isWindows
							ifTrue: [ #(int* _pclose(void* stream)) ]
							ifFalse: [ #(int* pclose(void* stream)) ])
]

{ #category : #'process actions' }
LibC >> resultOfCommand: cmd [
	|file last s |
	file := self pipe: cmd mode: 'r'.
	s := String new writeStream.
	[[ last := (self fgetc: file) value.
	  last = 16rFFFFFFFF ] whileFalse: [ 	 
			s nextPut: (Character value: last)
	]] ensure: [ self pipeClose: file ].
	^s contents
]

{ #category : #'process actions' }
LibC >> runCommand: cmd [

	^self system: cmd
]

{ #category : #'api - misc' }
LibC >> system: command [
	^ self ffiCall: #(int system #(char * command))
]

{ #category : #'private - accessing' }
LibC >> unixLibraryName [
	^ 'libc.so.6'
]

{ #category : #'private - accessing' }
LibC >> win32LibraryName [
	"While this is not a 'libc' properly, msvcrt has the functions we are defining here"
	^ 'msvcrt.dll'
]
