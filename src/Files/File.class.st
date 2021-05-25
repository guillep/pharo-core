"
I represent a sequential binary File and provide primitives for various file operations.
I am also the entry point of the FilePlugin primitives.

### Examples of usage:

```
""Creating a file""
file := File named: 'asd.txt' asFileReference fullName.

""Opening / closing it""
file open.
file openForAppend.
file close.

""Accessing the file properties""
file size.
file position.
file position: 0.
file seekAbsolute: 10.
file seekRelative: 10.
file atEnd.

""Writing""
file nextPutAll: 'sdd'.

""Reading""
file next: 2.

""Buffered write""
file next: 2 putAll: 'abc' startingAt: 2.

""Buffered read""
buffer := ByteArray new: 5.
file readInto: buffer startingAt: 1 count: 5.
buffer asString.
```

"
Class {
	#name : #File,
	#superclass : #Object,
	#instVars : [
		'name'
	],
	#classVars : [
		'Registry',
		'S_IFBLK',
		'S_IFCHR',
		'S_IFDIR',
		'S_IFIFO',
		'S_IFLNK',
		'S_IFMT',
		'S_IFREG',
		'S_IFSOCK'
	],
	#category : #'Files-Core'
}

{ #category : #'primitives-file' }
File class >> atEnd: id [
	"Answer true if the file position is at the end of the file."

	<primitive: 'primitiveFileAtEnd' module: 'FilePlugin'>
	self primitiveFailed

]

{ #category : #'primitives-errors' }
File class >> cantAllocateMemory [

	^-10
]

{ #category : #'primitives-errors' }
File class >> cantOpenDir [

	^-9
]

{ #category : #'primitives-errors' }
File class >> cantReadlink [

	^-8
]

{ #category : #'primitives-errors' }
File class >> cantStatPath [
	"SecurityPlugin determined that the requested path cannot be accessed."
	^-3
]

{ #category : #'primitives-file' }
File class >> close: id [
	"Close this file."

	<primitive: 'primitiveFileClose' module: 'FilePlugin'>
	
]

{ #category : #'primitives-file' }
File class >> closed: id [
	^ id isNil or: [ (self sizeOrNil: id) isNil ]
]

{ #category : #'primitives-file' }
File class >> connectToFile: filePointer writable: writableFlag [
	"Open the file with the supplied FILE* pointer, and return the file ID obtained.
	writeableFlag indicates whether to allow write operations and must be compatible with the way the file was opened.
	It is the responsibility of the caller to coordinate closing the file."

	<primitive: 'primitiveConnectToFile' module: 'FilePlugin' error: error>
	error = #'bad argument' ifTrue: [ 
		(filePointer isKindOf: ByteArray) ifFalse: 
			[ ^self error: 'filePointer must be a ByteArray' ].
		(writableFlag isKindOf: Boolean) ifFalse: 
			[ ^self error: 'writableFlag must be a boolean' ] ].
	^ self primitiveFailed 

]

{ #category : #'primitives-file' }
File class >> connectToFileDescriptor: fileDescriptor writable: writableFlag [
	"Connect to the file with fileDescriptor number, and return the file ID obtained.
	writeableFlag indicates whether to allow write operations and must be compatible with the way the file was opened.
	It is the responsibility of the caller to coordinate closing the file."

	<primitive: 'primitiveConnectToFileDescriptor' module: 'FilePlugin' error: error>
	error = #'bad argument' ifTrue: [ 
		fileDescriptor isInteger ifFalse: 
			[ ^self error: 'fileDescriptor must be an integer' ].
		(writableFlag isKindOf: Boolean) ifFalse: 
			[ ^self error: 'writableFlag must be a boolean' ] ].
	^ self primitiveFailed 

]

{ #category : #'primitives-errors' }
File class >> corruptValue [

	^-7
]

{ #category : #'primitives-path' }
File class >> createDirectory: fullPath [
	"Create a directory named by the given path. 
	Fail if the path is bad or if a file or directory by that name already exists."

 	<primitive: 'primitiveDirectoryCreate' module: 'FilePlugin'>
	^ nil

]

{ #category : #'primitives-encoding' }
File class >> decodePathString: aByteArray [

	^ ZnUTF8Encoder default decodeBytes: aByteArray asByteArray
]

{ #category : #'primitives-path' }
File class >> deleteDirectory: fullPath [
	"Delete the directory named by the given path. 
	Fail if the path is bad or if a directory by that name does not exist."

 	<primitive: 'primitiveDirectoryDelete' module: 'FilePlugin'>
	self primitiveFailed

]

{ #category : #'primitives-path' }
File class >> deleteFile: fullPathString [
	"Delete the supplied UTF8 encoded path.  Answer nil on failure."

	| utf8Path |

	utf8Path := fullPathString utf8Encoded.
	self
		retryWithGC: [ self primDeleteFile: utf8Path ]
		until: [ :result | result notNil ]
		forFileNamed: fullPathString.
	(self primExists: utf8Path) ifTrue: 
		[ (CannotDeleteFileException new messageText: 'Could not delete file ' , name,
			'. Check the file is not open.') signal ].
]

{ #category : #'primitives-path' }
File class >> delimiter [
	"Return the path delimiter for the underlying platform's file system."

 	<primitive: 'primitiveDirectoryDelimitor' module: 'FilePlugin'>
	self primitiveFailed

]

{ #category : #'primitives-encoding' }
File class >> encodePathString: aString [

	^ ZnUTF8Encoder default encodeString: aString
]

{ #category : #testing }
File class >> exists: aString [

	^self primExists: (self encodePathString: aString)
]

{ #category : #attributes }
File class >> file: pathString posixPermissions: anInteger [
	"Set the mode of pathString to anInteger (as defined by chmod())"

	^self primFile: (self encodePathString: pathString) posixPermissions: anInteger
]

{ #category : #attributes }
File class >> file: pathString symlinkUid: uidInteger gid: gidInteger [
	"Set the owner and group of pathString by numeric id."

	^self primFile: (self encodePathString: pathString) 
		symlinkUid: (uidInteger ifNil: [ -1 ]) 
		gid: (gidInteger ifNil: [ -1 ])

]

{ #category : #attributes }
File class >> file: pathString uid: uidInteger gid: gidInteger [
	"Set the owner and group of pathString by numeric id.
	An id of nil leaves it unchanged."

	^self primFile: (self encodePathString: pathString) 
		uid: (uidInteger ifNil: [ -1 ])
		gid: (gidInteger ifNil: [ -1 ])

]

{ #category : #attributes }
File class >> fileAttribute: aString number: attributeNumber [
	"Answer the attribute identified by attributeNumber for the specified file (aString).
	For backward compatibility (on Unix) with FileReference if the file doesn't exist, and the specified path is a (broken) symbolic link, answer the requested attribute for the symbolic link."

	^self primFileAttribute: (self encodePathString: aString) number: attributeNumber
]

{ #category : #attributes }
File class >> fileAttributeNumberMap [
	"Answer a mapping of attribute number to name for #primFileAttribute:number:"
	
	^#(
		#targetName
		#mode
		#inode
		#deviceId
		#numberOfHardLinks
		#uid
		#gid
		#size
		#accessUnixTime
		#modificationUnixTime
		#changeUnixTime
		#creationUnixTime
		#isReadable
		#isWritable
		#isExecutable
		#isSymlink
		)
]

{ #category : #attributes }
File class >> fileAttributes: aString mask: attributeMask [

	| attributes statAttributes mask |

	attributes := self primFileAttributes: (self encodePathString: aString) mask: attributeMask.
	mask := attributeMask bitAnd: 2r11.
	mask = 1 ifTrue: [ statAttributes := attributes ].
	mask = 3 ifTrue: [ statAttributes := attributes at: 1 ].
	(statAttributes isNotNil and: [ (statAttributes at: 1) isNotNil ]) ifTrue: 
		[ statAttributes at: 1 put: (self decodePathString: (statAttributes at: 1)) ].
	^attributes
]

{ #category : #'primitives-version' }
File class >> fileAttributesVersionString [

	<primitive: 'primitiveVersionString' module: 'FileAttributesPlugin' error: error>
	^self primitiveFailed
]

{ #category : #'primitives-file' }
File class >> fileDescriptorIsAvailable: anInteger [
	"Answer a boolean indicating whether the supplied file descriptor (anInteger) is available.
	A file descriptor is considered available if it is connected to a console / terminal, pipe or a file.  cygwin terminals are currently not supported (the pipe is created, but nothing appears in the terminal)"

	^ (self fileDescriptorType: anInteger) between: 1 and: 3
]

{ #category : #'primitives-file' }
File class >> fileDescriptorType: fdNum [
	"Allow to test if the standard input/output files are from a console or not
	Return values:
	* -1 - Error
	* 0 - no console (windows only)
	* 1 - normal terminal (unix terminal / windows console)
	* 2 - pipe
	* 3 - file
	* 4 - cygwin terminal (windows only)"

	<primitive: 'primitiveFileDescriptorType' module: 'FilePlugin' error: error>
	error = #'bad argument'
		ifTrue: [ fdNum isInteger
				ifFalse: [ ^ self error: 'File Descriptor must be an integer!' ] ].
	^ self primitiveFailed
]

{ #category : #'primitives-file' }
File class >> flush: id [
	"On Unix, the FilePlugin uses stdio FILE* structs which maintain their
	own internal buffer to minimize write() syscalls. This flushes that buffer.
	On Windows this and primSync: do the same thing."

	<primitive: 'primitiveFileFlush' module: 'FilePlugin'>
	
	"We can't ignore fflush() failing, because it can fail for any of the
	reasons write() can."
	self primitiveFailed
]

{ #category : #attributes }
File class >> fromPlatformPath: aByteArray [
	"Convert the supplied platform encoded string to the native (UTF8) equivalent"

	^self primFromPlatformPath: aByteArray
]

{ #category : #'primitives-errors' }
File class >> getAttributesFailed [

	^-4
]

{ #category : #'primitives-path' }
File class >> getMacFile: fileName type: typeString creator: creatorString [
	"Get the Macintosh file type and creator info for the file with the given name. Fails if the file does not exist or if the type and creator type arguments are not strings of length 4. This primitive is Mac specific; it is a noop on other platforms."

 	<primitive: 'primitiveDirectoryGetMacTypeAndCreator' module: 'FilePlugin'>


]

{ #category : #'primitives-file' }
File class >> getPosition: id [
	"Get this files current position."

	<primitive: 'primitiveFileGetPosition' module: 'FilePlugin'>
	self primitiveFailed

]

{ #category : #'class initialization' }
File class >> initialize [

	SessionManager default registerSystemClassNamed: self name.
	self reset.
]

{ #category : #'primitives-errors' }
File class >> invalidArguments [

	^-6
]

{ #category : #'primitives-file modes' }
File class >> isBlock: aPath [
	"Answer a boolean indicating whether the supplied path is a Block file"

	^self modeIsBlock: (self modeOf: aPath)

]

{ #category : #'primitives-file modes' }
File class >> isCharacter: aPath [
	"Answer a boolean indicating whether the supplied path is a Character file"

	^self modeIsCharacter: (self modeOf: aPath)

]

{ #category : #'primitives-file modes' }
File class >> isDirectory: aPath [
	"Answer a boolean indicating whether the supplied path is a Directory"

	^[ self modeIsDirectory: (self modeOf: aPath) ]
		on: FileDoesNotExistException
		do: [ false ].
]

{ #category : #'primitives-file modes' }
File class >> isExecutable: aPath [
	"Answer a boolean indicating whether the supplied path is a executable file"

	^self fileAttribute: aPath number: 15

]

{ #category : #'primitives-file modes' }
File class >> isFIFO: aPath [
	"Answer a boolean indicating whether the supplied path is a FIFO file"

	^self modeIsFIFO: (self modeOf: aPath)

]

{ #category : #'primitives-file modes' }
File class >> isFile: aPathString [
	"Answer a boolean indicating whether the supplied path is a file, i.e. not a directory"

	^[ (self modeIsDirectory: (self modeOf: aPathString)) not ]
		on: FileDoesNotExistException
		do: [ false ].
]

{ #category : #'primitives-file modes' }
File class >> isReadable: aPath [
	"Answer a boolean indicating whether the supplied path is a readable file"

	^self fileAttribute: aPath number: 13

]

{ #category : #'primitives-file modes' }
File class >> isRegular: aPath [
	"Answer a boolean indicating whether the supplied path is a Regular file"

	^self modeIsRegular: (self modeOf: aPath)

]

{ #category : #'primitives-file modes' }
File class >> isSocket: aPath [
	"Answer a boolean indicating whether the supplied path is a Socket file"

	^self modeIsSocket: (self modeOf: aPath)

]

{ #category : #'primitives-file modes' }
File class >> isSymlink: aPath [
	"Answer a boolean indicating whether the supplied path is a Symlink file"

	^self fileAttribute: aPath number: 16
]

{ #category : #'primitives-file modes' }
File class >> isWritable: aPath [
	"Answer a boolean indicating whether the supplied path is a writable file"

	^self fileAttribute: aPath number: 14

]

{ #category : #'primitives-path' }
File class >> lookupDirectory: fullPath filename: fileName [

	"Look up <fileName> (a simple file name) in the directory identified by <fullPath> and return an array containing:

	<fileName> 			
	<creationTime> 			(in seconds since the start of the Smalltalk time epoch)
	<modificationTime> 	(in seconds since the start of the Smalltalk time epoch)
	<dirFlag> 				DirFlag is true if the entry is a directory
	<fileSize> 				FileSize the file size in bytes or zero for directories
	<posixPermissions> 	Numeric Notation 
	<symLinkFlag>			seemingly, symLinkFlag is true if the entry is a symLink

	On Unix, the empty path denotes '/'. 
   On Macs and PCs, it is the container of the system volumes."

 	<primitive: 'primitiveDirectoryEntry' module: 'FilePlugin'>
	
	^ #badDirectoryPath


]

{ #category : #'primitives-path' }
File class >> lookupEntryIn: fullPath index: index [
	"Look up the index-th entry of the directory with the given fully-qualified path 
	(i.e., starting from the root of the file hierarchy) and return an array containing:

	<name> <creationTime> <modificationTime> <dirFlag> <fileSize>

	The empty string enumerates the top-level files or drives. (For example, on Unix, the empty 
	path enumerates the contents of '/'. On Macs and PCs, it enumerates the mounted volumes/drives.)

	The creation and modification times are in seconds since the start of the Smalltalk time epoch. 
	DirFlag is true if the entry is a directory. FileSize the file size in bytes or zero for directories. 
	The primitive returns nil when index is past the end of the directory. It fails if the given path 
	is bad."

 	<primitive: 'primitiveDirectoryLookup' module: 'FilePlugin' error: errorCode >
	
	^ #badDirectoryPath


]

{ #category : #'primitives-file modes' }
File class >> modeIsBlock: aMode [
	"Answer a boolean indicating whether the supplied mode has the Block type bit set"

	^(aMode bitAnd: S_IFMT) = S_IFBLK
]

{ #category : #'primitives-file modes' }
File class >> modeIsCharacter: aMode [
	"Answer a boolean indicating whether the supplied mode has the Character type bit set"

	^(aMode bitAnd: S_IFMT) = S_IFCHR
]

{ #category : #'primitives-file modes' }
File class >> modeIsDirectory: aMode [
	"Answer a boolean indicating whether the supplied mode has the Directory type bit set"

	^(aMode bitAnd: S_IFMT) = S_IFDIR
]

{ #category : #'primitives-file modes' }
File class >> modeIsFIFO: aMode [
	"Answer a boolean indicating whether the supplied mode has the FIFO type bit set"

	^(aMode bitAnd: S_IFMT) = S_IFIFO
]

{ #category : #'primitives-file modes' }
File class >> modeIsRegular: aMode [
	"Answer a boolean indicating whether the supplied mode has the Regular type bit set"

	^(aMode bitAnd: S_IFMT) = S_IFREG
]

{ #category : #'primitives-file modes' }
File class >> modeIsSocket: aMode [
	"Answer a boolean indicating whether the supplied mode has the Socket type bit set"

	^(aMode bitAnd: S_IFMT) = S_IFSOCK
]

{ #category : #'primitives-file modes' }
File class >> modeIsSymlink: aMode [
	"Answer a boolean indicating whether the supplied mode has the Socket type bit set"

	^(aMode bitAnd: S_IFMT) = S_IFLNK
]

{ #category : #'primitives-file modes' }
File class >> modeOf: aPathString [
	"Answer the statBuf.st_mode for the supplied path"
	
	^self fileAttribute: aPathString number: 2
]

{ #category : #'file creation' }
File class >> named: fileName [
	"Open a file with the given name for reading and writing. If the name has no directory part, then the file will be created in the default directory. If the file already exists, its prior contents may be modified or replaced, but the file will not be truncated on close."

	^ self new named: fileName
]

{ #category : #'primitives-file' }
File class >> open: fileName writable: writableFlag [
	"Open a file of the given name, and return the file ID obtained.
	If writableFlag is true, then
		if there is none with this name, then create one
		else prepare to overwrite the existing from the beginning
	otherwise
		if the file exists, open it read-only
		else return nil"

	<primitive: 'primitiveFileOpen' module: 'FilePlugin'>
	^ nil

]

{ #category : #'file creation' }
File class >> openAndTruncateForWriteFileNamed: aName [
	self
		deprecated: 'Please use #truncatedFileNamed: instead'
		transformWith: '`@receiver openAndTruncateForWriteFileNamed: `@arg' -> '`@receiver truncatedFileNamed: `@arg'.
	^ self truncatedFileNamed: aName  

  
]

{ #category : #'file creation' }
File class >> openForReadFileNamed: aName [

	^ (self named: aName)
		openForRead
]

{ #category : #'file creation' }
File class >> openForWriteFileNamed: aName [

	^ (self named: aName) openForWrite
]

{ #category : #'primitives-file modes' }
File class >> posixPermissions: aPath [
	"Answer the posix permissions for the supplied path"

	^(self modeOf: aPath) bitAnd: 8r777

]

{ #category : #'primitives-directory' }
File class >> primClosedir: directoryPointerBytes [
	"Close the directory stream associated with directoryPointerBytes.
	Caution: do not call this twice on the same externalAddress."

	"self primClosedir: (self primOpendir: '/etc')"
	"self primClosedir: (self primOpendir: '/no/such/directory')"

	<primitive: 'primitiveClosedir' module: 'FileAttributesPlugin' error: error>
	^self signalError: error for: 'primClosedir'
]

{ #category : #'primitives-path' }
File class >> primDeleteFile: aFileName [
	"Delete the file of the given name. 
	Return self if the primitive succeeds, nil otherwise."

	<primitive: 'primitiveFileDelete' module: 'FilePlugin'>
	^ nil

]

{ #category : #'primitives-file attributes' }
File class >> primExists: aByteArray [
	"Answer a boolean indicating whether the supplied file exists."

	<primitive: 'primitiveFileExists' module: 'FileAttributesPlugin' error: error>
	^self signalError: error for: aByteArray.

]

{ #category : #'primitives-file attributes' }
File class >> primFile: pathByteArray posixPermissions: anInteger [
	"Set the mode of pathByateArray to anInteger (as defined by chmod())"

	<primitive: 'primitiveChangeMode' module: 'FileAttributesPlugin' error: error>
	^self signalError: error for: pathByteArray
]

{ #category : #'primitives-file attributes' }
File class >> primFile: pathByteArray symlinkUid: uidInteger gid: gidInteger [
	"Set the owner and group of path by numeric id."

	<primitive: 'primitiveSymlinkChangeOwner' module: 'FileAttributesPlugin' error: error>
	^self signalError: error for: pathByteArray
]

{ #category : #'primitives-file attributes' }
File class >> primFile: pathByteArray uid: uidInteger gid: gidInteger [
	"Set the owner and group of path by numeric id."

	<primitive: 'primitiveChangeOwner' module: 'FileAttributesPlugin' error: error>
	^self signalError: error for: pathByteArray
]

{ #category : #'primitives-file attributes' }
File class >> primFileAttribute: aByteArray number: attributeNumber [
	"Answer a single attribute for the supplied file.
	For backward compatibility (on Unix) with FileReference if the file doesn't exist, and the specified path is a (broken) symbolic link, answer the requested attribute for the symbolic link.

stat() information:
	
	1: name
	2: mode
	3: ino
	4: dev
	5: nlink
	6: uid
	7: gid
	8: size
	9: accessDate
	10: modifiedDate
	11: changeDate
	12: creationDate

access() information

	13: is readable
	14: is writeable
	15: is executable

symbolic link information

	16: is symbolic link
	"
	<primitive: 'primitiveFileAttribute' module: 'FileAttributesPlugin' error: error>
	"FilePlugin>>primitiveDirectoryEntry would return the symbolic link attributes if the symbolic link was broken.  This was due to the incorrect implementation of attempting to retrieve symbolic link information.
	If the old behaviour is required, the logic is:
	
		(error isPrimitiveError and: [attributeNumber ~= 16 and: [error errorCode = self cantStatPath and: [
					self platformSupportsSymbolicLinksEgUnix]]]) ifTrue:
						[DiskSymlinkDirectoryEntry fileSystem: DiskStore currentFileSystem path: aString asPath]"
	error isPrimitiveError ifTrue: [ 
		(attributeNumber = 16 and: [ error errorCode = self unsupportedOperation ]) ifTrue: 
			"If symlinks aren't supported, answer false"
			[ ^false ]].
	^self signalError: error for: aByteArray

]

{ #category : #'primitives-file attributes' }
File class >> primFileAttributes: aByteArray mask: attributeMask [
	"Answer an array of attributes for the supplied file.  The size and contents of the array are determined by the attributeMask:

Bit 0: stat() information
Bit 1: access() information
Bit 2: use lstat() (instead of stat())

On error, answer an error code (Integer).

stat() information:
	
	1: name
	2: mode
	3: ino
	4: dev
	5: nlink
	6: uid
	7: gid
	8: size
	9: accessDate
	10: modifiedDate
	11: creationDate
	12: Windows File Attributes mask (https://docs.microsoft.com/en-us/windows/win32/fileio/file-attribute-constants)

access() information

	1: is readable
	2: is writeable
	3: is executable
	"
	<primitive: 'primitiveFileAttributes' module: 'FileAttributesPlugin' error: error>
	^self signalError: error for: aByteArray

]

{ #category : #private }
File class >> primFileMasks [
	"Answer an array of well known masks:
	
	1: S_IFMT
	2: S_IFSOCK
	3: S_IFLNK
	4: S_IFREG
	5: S_IFBLK
	6: S_IFDIR
	7: S_IFCHR
	8: S_IFIFO

	For more information, see: http://man7.org/linux/man-pages/man2/stat.2.html
	"
	<primitive: 'primitiveFileMasks' module: 'FileAttributesPlugin' error: error>
	^self signalError: error for: 'primFileMasks'
]

{ #category : #'primitives-file attributes' }
File class >> primFromPlatformPath: aByteArray [
	"Convert the supplied platform encoded string to the native (UTF8) equivalent"

	<primitive: 'primitivePlatToStPath' module: 'FileAttributesPlugin' error: error>
	^self signalError: error for: 'primToPlatformPath:'
]

{ #category : #'primitives-windows' }
File class >> primLogicalDrives [
	"Answer the windows logical drive mask"
	<primitive: 'primitiveLogicalDrives' module: 'FileAttributesPlugin' error: error>
	^self signalError: error for: 'primLogicalDrives'
]

{ #category : #'primitives-directory' }
File class >> primOpendir: pathString [
	"Answer an ExternalAddress for a directory stream on pathString, or nil if
	the directory cannot be opened"

	"self primOpendir: '/etc'"
	"self primOpendir: '.'"
	"self primOpendir: '/no/such/directory'"

	<primitive: 'primitiveOpendir' module: 'FileAttributesPlugin' error: error>
	^self signalError: error for: pathString
]

{ #category : #'primitives-directory' }
File class >> primPathMax [
	"Answer the VMs PATH_MAX value"
	<primitive: 'primitivePathMax' module: 'FileAttributesPlugin' error: error>
	^self signalError: error for: 'primPathMax'
]

{ #category : #'primitives-directory' }
File class >> primReaddir: directoryPointerBytes [
	"Read the next directory entry from the directory stream associated with
	directoryPointerBytes. Answer the name of the entry, ornil for end of directory stream."

	"self primReaddir: (self primOpendir: '/etc')"
	"self primReaddir: (self primOpendir: '/no/such/directory')"

	<primitive: 'primitiveReaddir' module: 'FileAttributesPlugin' error: error>
	^self signalError: error for: 'primReaddir:'
]

{ #category : #'primitives-directory' }
File class >> primRewinddir: directoryPointerBytes [
	"Rewind the directory stream associated with directoryPointerBytes. Answer
	anExternalAddress on success, or nil on failure."

	"self primRewinddir: (self primOpendir: '/etc')"
	"self primRewinddir: (self primOpendir: '/no/such/directory')"

	<primitive: 'primitiveRewinddir' module: 'FileAttributesPlugin' error: error>
	^self signalError: error for: 'primRewinddir:'

]

{ #category : #'primitives-file attributes' }
File class >> primToPlatformPath: aByteArray [
	"Convert the supplied UTF8 encoded string to the platform encoded equivalent"

	<primitive: 'primitiveStToPlatPath' module: 'FileAttributesPlugin' error: error>
	^self signalError: error for: 'primToPlatformPath:'
]

{ #category : #'primitives-file' }
File class >> primitiveWaitForDataOn: id signalling: semaphoreIndex [

	<primitive: 'primitiveWaitForDataWithSemaphore' module: 'FilePlugin' error: ec>

	self primitiveFailed
]

{ #category : #'primitives-file' }
File class >> read: id into: byteArray startingAt: startIndex count: count [
	"Read up to count bytes of data from this file into the given string or byte array starting at the given index. Answer the number of bytes actually read."

	<primitive: 'primitiveFileRead' module: 'FilePlugin'>
	(self closed: id)
		ifTrue: [ ^ self error: 'File is closed' ].
	self error: 'File read failed'
]

{ #category : #registry }
File class >> register: anObject [
	^self registry add: anObject
]

{ #category : #registry }
File class >> registry [
	^Registry ifNil: [Registry := WeakRegistry new]

]

{ #category : #'primitives-path' }
File class >> rename: oldFileFullName to: newFileFullName [ 
	"Rename the file of the given name to the new name. Fail if there is no file of the old name 
	or if there is an existing file with the new name."

	<primitive: 'primitiveFileRename' module: 'FilePlugin'>
	^nil
]

{ #category : #initialization }
File class >> reset [
	"Initialise the receiver for the current platform"

	| masks |

	masks := self primFileMasks.
	S_IFMT := masks at: 1.
	S_IFSOCK := masks at: 2.
	S_IFLNK := masks at: 3.
	S_IFREG := masks at: 4.
	S_IFBLK := masks at: 5.
	S_IFDIR := masks at: 6.
	S_IFCHR := masks at: 7.
	S_IFIFO := masks at: 8.

]

{ #category : #registry }
File class >> retryWithGC: execBlock until: testBlock forFileNamed: fullName [
	"Some platforms, like Windows, will fail if we try to open a file twice.
	However, sometimes it may happen that a file was unreferenced and should be garbage-collected.
	The purpose of this method is to try to open the file, and if it fails, launch a garbage collection to try to close the unreferenced files.
	Then we will retry again to open the file"

	| blockValue foundIt |
	blockValue := execBlock value.
	(testBlock value: blockValue) ifTrue: [ ^ blockValue ].

	"Optimization: See if we have a file with the given name. Not really needed"
	foundIt := self registry keys "hold on strongly for now" 
		anySatisfy: [:file| file name sameAs: fullName].
	foundIt ifFalse:[^blockValue].

	Smalltalk garbageCollectMost.
	blockValue := execBlock value.
	(testBlock value: blockValue) ifTrue: [ ^ blockValue ].
	Smalltalk garbageCollect.
	^execBlock value.
]

{ #category : #'primitives-file modes' }
File class >> s_IFBLK [
	^ S_IFBLK
]

{ #category : #'primitives-file modes' }
File class >> s_IFCHR [
	^ S_IFCHR
]

{ #category : #'primitives-file modes' }
File class >> s_IFDIR [
	^ S_IFDIR
]

{ #category : #'primitives-file modes' }
File class >> s_IFIFO [
	^ S_IFIFO
]

{ #category : #'primitives-file modes' }
File class >> s_IFLNK [
	^ S_IFLNK
]

{ #category : #'primitives-file modes' }
File class >> s_IFMT [
	^ S_IFMT
]

{ #category : #'primitives-file modes' }
File class >> s_IFREG [
	^ S_IFREG
]

{ #category : #'primitives-file modes' }
File class >> s_IFSOCK [
	^ S_IFSOCK
]

{ #category : #'primitives-file' }
File class >> setPosition: id to: anInteger [
	"Set this file to the given position."

	<primitive: 'primitiveFileSetPosition' module: 'FilePlugin'>
	self primitiveFailed

]

{ #category : #private }
File class >> signalError: error for: aByteArray [
	"Raise the appropriate signal for the supplied error"

	| errorNumber pathString |

	error ifNil: [ ^self primitiveFailed ].
	error isSymbol ifTrue: [ ^self primitiveFailed: error ].
	error isPrimitiveError ifFalse: [ 
		"We shouldn't ever get here"
		^self primitiveFailed. ].

	pathString := self decodePathString: aByteArray asByteArray.
	errorNumber := error errorCode.
	errorNumber = self stringTooLong ifTrue: 
		[ ^IllegalFileName signalWith: pathString ].
	errorNumber = self cantStatPath ifTrue: 
		[ ^FileDoesNotExistException signalWith: pathString ].
	errorNumber = self getAttributesFailed ifTrue: 
		[ ^FileDoesNotExistException signalWith: pathString ].
	errorNumber = self unsupportedOperation ifTrue: 
		[ ^FileAttributeNotSupported signalWith: pathString ].
	^FileException signalWith: pathString.
]

{ #category : #'primitives-file' }
File class >> sizeOf: id [
	"Answer the size of this file."

	<primitive: 'primitiveFileSize' module: 'FilePlugin'>
	self primitiveFailed

]

{ #category : #'primitives-file' }
File class >> sizeOrNil: id [
	"Answer the size of this file."

	<primitive: 'primitiveFileSize' module: 'FilePlugin'>
	^ nil
]

{ #category : #'class initialization' }
File class >> startUp: isImageStarting [
	"Update VM constants on startup"

	isImageStarting ifTrue: [ self reset ]

]

{ #category : #'primitives-errors' }
File class >> statFailed [
	"A call to stat() or lstat() failed"
	^-2
]

{ #category : #'primitives-file' }
File class >> stdioHandles [
	<primitive: 'primitiveFileStdioHandles' module: 'FilePlugin' error: ec>
	self primitiveFailed
]

{ #category : #'primitives-file' }
File class >> stdioIsAvailable [
	"Answer a boolean indicating whether stdio is available on the current platform.
	stdio is considered available if any one of the three files (stdin, stdout, stderr) is available."

	^ (0 to: 2)
		anySatisfy: [ :fdNum | | res |
			res := self fileDescriptorType: fdNum.
			res between: 1 and: 3 ]
]

{ #category : #'primitives-errors' }
File class >> stringTooLong [
	"String too long.  A file path name was longer than PATH_MAX"
	^-1
]

{ #category : #'primitives-file' }
File class >> sync: id [
	"On Unix, this syncs any written or flushed data still in the kernel file
	system buffers to disk. On Windows this and primFlush: do the same thing"

	<primitive: 'primitiveFileSync' module: 'FilePlugin'>

	"fsync() failing cannot be ignored"
	self primitiveFailed
]

{ #category : #'primitives-errors' }
File class >> timeConversionFailed [

	^-5
]

{ #category : #attributes }
File class >> toPlatformPath: aString [
	"Convert the supplied string to the platform encoded equivalent"

	^self primToPlatformPath: (self encodePathString: aString)
]

{ #category : #'primitives-file' }
File class >> truncate: id to: anInteger [
	"Truncate this file to the given position."

	<primitive: 'primitiveFileTruncate' module: 'FilePlugin'>
	self primitiveFailed

]

{ #category : #'file creation' }
File class >> truncatedFileNamed: aName [

	^ (self named: aName)
		delete;
		openForWrite
]

{ #category : #'primitives-errors' }
File class >> unexpectedError [
	"This is normally used where a catch-all is placed, but not expected to be used"

	^-14
]

{ #category : #registry }
File class >> unregister: anObject [
	^self registry remove: anObject ifAbsent:[]
]

{ #category : #'primitives-errors' }
File class >> unsupportedOperation [
	"The requested operation is not supported on the current platform"

	^-13
]

{ #category : #'primitives-file' }
File class >> write: id from: stringOrByteArray startingAt: startIndex count: count [
	"Write count bytes onto this file from the given string or byte array starting at the given index. 	Answer the number of bytes written."

	<primitive: 'primitiveFileWrite' module: 'FilePlugin'>
	self primitiveFailed 
]

{ #category : #accessing }
File >> basename [
	^self name
]

{ #category : #'open/close' }
File >> basicOpenForWrite: writeMode [ 
	"Open the file with the given name. If writeMode is true, allow writing, otherwise open the file in read-only mode."
	
	writeMode ifTrue: [ self checkWritableFilesystem ].

	^ self class
		retryWithGC: [ self class open: name utf8Encoded writable: writeMode ]
		until:[ :id | id notNil ] 
		forFileNamed: name
]

{ #category : #testing }
File >> checkDoesNotExist [
	"This method implements a backwards compatible logic to #newFileNamed:
	
	If the file does not exist, this method has no effect, and returns self.
	
	If the file exists, it will throw a FileAlreadyExistsException.
	If unhandled, this will open a pop-up asking the user to enter a new name or to override the existing file.
	In this case, this method returns a new file with the options selected by the user.
	"
	self exists ifTrue: [
		^ FileAlreadyExistsException signalOnFile: self ]
]

{ #category : #private }
File >> checkWritableFilesystem [

	"We need to check if the image is in the read-only mode"

	SessionManager default currentSession isReadOnlyAccessMode ifTrue: [ 
		ReadOnlyFileException signal: 'Attempt to open file ', name, ' as writable on a read-only file system'].


]

{ #category : #'open/close' }
File >> delete [
	"Delete the receiver"

	^self class deleteFile: name.

]

{ #category : #testing }
File >> exists [

	| handle |
	"We open it for read. If the returned handle is nil, the file could not be opened"
	handle := self basicOpenForWrite: false.
	handle ifNil: [^ false].
	self class close: handle.
	^ true
]

{ #category : #'instance creation' }
File >> name [

	^ name
]

{ #category : #'instance creation' }
File >> named: fileName [

	name := fileName
]

{ #category : #'open/close' }
File >> openForAppend [

	| stream |
	stream := self openForWrite: true.
	^ stream setToEnd; yourself
]

{ #category : #'open/close' }
File >> openForRead [

	^ self openForWrite: false
]

{ #category : #'open/close' }
File >> openForWrite [

	^ self openForWrite: true
]

{ #category : #'open/close' }
File >> openForWrite: writeMode [
	"Open the file with the given name. If writeMode is true, allow writing, otherwise open the file in read-only mode."

	| fileHandle |
	fileHandle := self basicOpenForWrite: writeMode.
	fileHandle ifNil: [
		"Opening the file failed.
		If the file does not exist, we throw an explicit FileDoesNotExistException.
		Otherwise, we throw a generic FileException."
		self exists
			ifFalse: [ ^ FileDoesNotExistException signalWithFile: self writeMode: writeMode ].
		CannotDeleteFileException signal: name
	].

	^ (BinaryFileStream handle: fileHandle file: self forWrite: writeMode)
		register;
		yourself
]

{ #category : #streaming }
File >> readStream [
	
	^ self openForRead
]

{ #category : #streaming }
File >> readStreamDo: aBlock [
	| stream |
	stream := self readStream.
	^ [ aBlock value: stream ]
		ensure: [ stream close ]
]

{ #category : #accessing }
File >> size [

	^ self readStreamDo: [ :stream | stream size ]
]

{ #category : #registry }
File >> unregister [
	^self class unregister: self
]

{ #category : #streaming }
File >> writeStream [

	^ self openForWrite
]

{ #category : #streaming }
File >> writeStreamDo: aBlock [
	| stream |
	stream := self writeStream.
	^ [ aBlock value: stream ]
		ensure: [ stream close ]
]
