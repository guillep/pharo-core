"
I combine a filesystem and path, which is sufficient to refer to a concrete file or directory. I provide methods for navigating my filesystem, performing filesystem operations and opening and closing files. 
I am the primary mechanism for working with files and directories. 

###Examples

```
| working |
working := FileSystem disk workingDirectory.
working files 
```
```
| disk |
disk := FileSystem disk.
disk root.                               	""a reference to the root directory""
disk working.                         	""a reference to the working directory""
```
"
Class {
	#name : #FileReference,
	#superclass : #AbstractFileReference,
	#instVars : [
		'filesystem'
	],
	#category : #'FileSystem-Core-Public'
}

{ #category : #'cross platform' }
FileReference class >> / aString [
	"Answer a reference to the argument resolved against the root of the current disk filesystem."
	
	^ FileSystem disk / aString
]

{ #category : #'instance creation' }
FileReference class >> fileSystem: aFilesystem path: aPath [
	^ self new setFileSystem: aFilesystem path: aPath
]

{ #category : #'instance creation' }
FileReference class >> newTempFilePrefix: prefix suffix: suffix [
	| tmpDir random fileName |
	
	tmpDir := FileLocator temp asFileReference.
	[ 
		random := UUID new asInteger asString.
		fileName := prefix , random , suffix.
		(tmpDir / fileName) exists ] whileTrue.
	^ tmpDir / fileName
]

{ #category : #navigating }
FileReference >> , extension [
	^ self withPath: self path, extension
]

{ #category : #comparing }
FileReference >> = other [
	"Two FileReferences are considered equal if they refer to the same file / directory.
	As paths can have multiple relative representations, compare the absolute paths."
	"Perform the path comparison last as conversion to absolute paths is relatively expensive"
	^ self species = other species
		and: [self fileSystem = other fileSystem
			and: [self absolutePath = other absolutePath]]

]

{ #category : #accessing }
FileReference >> absolutePath [
	"Return the absolute of the receiver"
	^ self path isRelative
		ifFalse: [ self path ]
		ifTrue: [ filesystem resolve: self path ]
]

{ #category : #accessing }
FileReference >> accessTime [ 
	^ filesystem accessTimeOf: self path
]

{ #category : #converting }
FileReference >> asAbsolute [
	"Return the receiver as an absolute file reference."
	
	^ self isAbsolute
		ifTrue: [ self ]
		ifFalse: [ filesystem referenceTo: (filesystem resolve: path) ]
]

{ #category : #converting }
FileReference >> asFileLocatorOrReference [
	^ self path asFileLocatorOrReference
]

{ #category : #converting }
FileReference >> asFileReference [
	^ self
]

{ #category : #converting }
FileReference >> asPath [
	"Answer the receivers path"

	^path
]

{ #category : #streams }
FileReference >> binaryReadStream [
	"Answer a buffered binary read stream on the receiver"
	
	^ ZnBufferedReadStream on: (filesystem binaryReadStreamOn: self path)
]

{ #category : #streams }
FileReference >> binaryWriteStream [
	"Answer a buffered binary write stream on the receiver"

	^ ZnBufferedWriteStream on: (filesystem binaryWriteStreamOn: self path)
]

{ #category : #accessing }
FileReference >> changeTime [ 
	^ filesystem changeTimeOf: self path
]

{ #category : #comparing }
FileReference >> containsReference: aReference [
	^  aReference fileSystem = filesystem and: [path contains: aReference path]
]

{ #category : #operations }
FileReference >> copyTo: aFileReference [
	"Copy the receiver and create the argument, a file reference."
	
	"If you want to copy a file from a folder into a given folder, the argument should not be the future parent folder
	but a file reference of the future location.  
	Therefore use 
		(folder1 / 'foo.txt') copyTo: (folder2 / 'bar.txt')"
		
	self isDirectory
		ifTrue: [ aFileReference ensureCreateDirectory ]
		ifFalse: [ filesystem copy: path toReference: aFileReference ]
]

{ #category : #copying }
FileReference >> copyWithPath: newPath [
	^ filesystem referenceTo: newPath
]

{ #category : #accessing }
FileReference >> creationTime [
	"Answer the receivers creation time.
	Note that the interpretation varies by platform."
	^ filesystem creationTimeOf: self path
]

{ #category : #operations }
FileReference >> delete [
	"Deletes the referenced file or directory. If the directory is not empty, 
	raises an error. Use #deleteAll to delete with the children."

	(self isDirectory and:[self hasChildren]) 
		ifTrue:[DirectoryIsNotEmpty signalWith: self].
	filesystem delete: path
]

{ #category : #operations }
FileReference >> deleteIfAbsent: aBlock [
	self exists 
		ifTrue: [ self delete ]
		ifFalse: aBlock
]

{ #category : #accessing }
FileReference >> deviceId [
	"Return the device id of the file at aPath"
	^ filesystem deviceIdOf: path
]

{ #category : #printing }
FileReference >> displayStringOn: stream [
	filesystem printPath: path on: stream
]

{ #category : #operations }
FileReference >> ensureCreateDirectory [
	"Create if necessary a directory for the receiver."
	filesystem ensureCreateDirectory: path
	
]

{ #category : #navigating }
FileReference >> entries [
	"Return the entries (meta data - file description) of the direct children of the receiver"
	^ self fileSystem entriesAt: self path 
]

{ #category : #accessing }
FileReference >> entry [
	"Return the entry (meta data) describing the receiver."
	^ filesystem entryAt: path
]

{ #category : #testing }
FileReference >> exists [
	"Answer a boolean indicating whether the receiver exists on the file system"
	^ filesystem exists: path
]

{ #category : #versions }
FileReference >> extractVersionNumberFrom: filename basename: basename extension: extension [
	"Answer the version number written in filename considering 
	that it consists of basename and extension.
	For example filename=basename.10.extension will return 10.
	filename=basename.extension without number will return 0
	It returns nil if given file does not satisfy this pattern"

	"ensure prefix basename."
	| versionStart versionEnd |
	(filename beginsWith: basename) ifFalse: [^nil].
	(filename size > basename size and: [(filename at: basename size + 1) = $.]) 
		ifFalse: [ ^nil ].
	"ensure suffix .extension"
	(filename endsWith: extension) ifFalse: [^nil].
	(filename size > extension size and: [(filename at: filename size - extension size) = $.])
		 ifFalse: [ ^nil ].
	
	versionStart := basename size + 2.
	versionEnd := filename size - extension size - 1.
	versionStart to: versionEnd do: [:i | 
		(filename at: i) isDigit ifFalse: [ ^nil ] ].
	versionStart > versionEnd ifTrue: [ ^0]. "means pattern baseline.extension"
	^(filename copyFrom: versionStart to: versionEnd) asNumber
]

{ #category : #accessing }
FileReference >> fileSystem [
	"Return the filesystem to which the receiver belong."
	^ filesystem
]

{ #category : #accessing }
FileReference >> fullName [
	"Return the full path name of the receiver."
	^ filesystem stringFromPath: (filesystem resolve: path)
]

{ #category : #accessing }
FileReference >> fullPath [
	^ self path
]

{ #category : #accessing }
FileReference >> gid [
	"Return the gid of the file at aPath"
	^ filesystem gidOf: path
]

{ #category : #testing }
FileReference >> hasChildren [
	"Return whether the receiver has any children."
	"FileSystem workingDirectory hasChildren"
	
	^ filesystem hasChildren: path
]

{ #category : #testing }
FileReference >> hasDirectories [
	"Return whether the receiver has children that are directories."
	"FileSystem workingDirectory hasDirectories"
	
	^ filesystem hasDirectories: path
]

{ #category : #testing }
FileReference >> hasFiles [
	"Return whether the receiver has children that are files."
	"FileSystem workingDirectory hasFiles"
	
	^ filesystem hasFiles: path
]

{ #category : #comparing }
FileReference >> hash [
	^ path hash bitXor: filesystem hash
]

{ #category : #accessing }
FileReference >> inode [
	"Return the inode of the file at aPath"
	^ filesystem inodeOf: path
]

{ #category : #testing }
FileReference >> isAbsolute [
	^ path isAbsolute
]

{ #category : #testing }
FileReference >> isBlock [
	"Return a boolean indicating whether the File described by aPath is a block device"
	^ filesystem isBlock: path
]

{ #category : #testing }
FileReference >> isCharacter [
	"Return a boolean indicating whether the File described by aPath is character based"
	^ filesystem isCharacter: path
]

{ #category : #testing }
FileReference >> isDirectory [
	^ filesystem isDirectory: path
]

{ #category : #testing }
FileReference >> isExecutable [
	"Answer a boolean indicating whether the receiver has the executable flag set"
	^ filesystem isExecutable: path
]

{ #category : #testing }
FileReference >> isFIFO [
	"Return a boolean indicating whether the File described by aPath is FIFO (i.e. a pipe)"
	^ filesystem isFIFO: path
]

{ #category : #testing }
FileReference >> isFile [
	^ filesystem isFile: path
]

{ #category : #testing }
FileReference >> isReadable [
	^ filesystem isReadable: path
]

{ #category : #testing }
FileReference >> isRegular [
	"Return a boolean indicating whether the File described by aPath is a regular file"
	^ filesystem isRegular: path
]

{ #category : #testing }
FileReference >> isRelative [
	^ path isRelative
]

{ #category : #testing }
FileReference >> isRoot [
	^ path isRoot
]

{ #category : #testing }
FileReference >> isSocket [
	"Return a boolean indicating whether the File described by aPath is a socket"
	^ filesystem isSocket: path
]

{ #category : #testing }
FileReference >> isSymlink [
	"Answer a boolean indicating whether the receiver is a symlink"
	^ filesystem isSymlink: path
]

{ #category : #testing }
FileReference >> isWritable [
	^ filesystem isWritable: path
]

{ #category : #utilities }
FileReference >> lastFileFor: baseFileName extension: extension [
	"Assumes a file is named using a version number encoded as '.' followed by digits
  preceding the file extension, e.g., games.22.ston
  Answer the file name with the largest number.
  If a version number is not found, raises an error"

	"FileSystem workingDirectory lastFileFor: 'games' extension: 'ston'"

	| version |

	version := self versionNumberFor: baseFileName extension: extension.
	^(version
		ifNil: [ self error: 'No file with number pattern' ]
		ifNotNil: [ version = 0
			ifTrue: [ baseFileName, '.', extension ]
			ifFalse: [ baseFileName , '.' , version asString , '.' , extension ] ]) asFileReference 

]

{ #category : #accessing }
FileReference >> modificationTime [ 
	"Returns the last date of modification of self"
	^ filesystem modificationTimeOf: self path
]

{ #category : #operations }
FileReference >> moveTo: aReference [
	"Move the receiver in the location passed as argument.
	
	(FileSystem disk workingDirectory / 'paf' ) ensureCreateFile.
	(FileSystem disk workingDirectory / 'fooFolder') ensureCreateDirectory. 
	(FileSystem disk workingDirectory / 'paf' ) moveTo: (FileSystem disk workingDirectory / 'fooFolder' / 'paf')
	
	Note that the receiver is modified to point to the new location."
	
	| result |
	result := self fileSystem 
		move: self path
		to: aReference resolve.
	result ifNotNil: [
		self setFileSystem: result fileSystem path: result path ].		
]

{ #category : #utilities }
FileReference >> nextNameFor: baseFileName extension: extension [
  "Assumes a file name includes a version number encoded as '.' followed by digits 
   preceding the file extension, e.g., games.22.ston
   Increment the version number (of the largest one) and answer the new file name, e.g., games23.ston
   If a version number is not found, set the version to 1 and answer a new file name"

	"(FileSystem workingDirectory nextNameFor: 'games' extension: 'ston') asFileReference ensureCreateFile"

	| version |

	version := self versionNumberFor: baseFileName extension: extension.
	^version
		ifNil: [ baseFileName, '.1.', extension ]
		ifNotNil: [ baseFileName , '.' , (version+1) asString , '.' , extension ]
]

{ #category : #utilities }
FileReference >> nextVersion [
	"Assumes a file (or folder) name includes a version number encoded as '.' followed by digits 
	preceding the file extension.  Increment the version number and answer the new file name.
	If a version number is not found, return just the file"

	| parent basename nameWithoutExtension extension max index |

	self exists
		ifFalse: [ ^ self ].

	parent := self parent.
	extension := self extension.
	basename := self basename.
	nameWithoutExtension := basename copyFrom: 1 to: (basename size - extension size - 1).
	"At this stage nameWithoutExtension may still include a version number.  Remove it if necessary"
	index := nameWithoutExtension size.
	[ index > 0 and: [ (nameWithoutExtension at: index) isDigit ] ] whileTrue:
		[ index := index - 1 ].
	((index between: 1 and: nameWithoutExtension size - 1) and: [ (nameWithoutExtension at: index) = $. ]) ifTrue: 
		[ nameWithoutExtension := nameWithoutExtension copyFrom: 1 to: index-1 ].

	max := parent versionNumberFor: nameWithoutExtension extension: extension.
	^ parent / (nameWithoutExtension, '.', (max+1) asString) , self extension
]

{ #category : #accessing }
FileReference >> numberOfHardLinks [
	"Return the number of hard links to the File described by aPath"
	^ filesystem numberOfHardLinks: path
]

{ #category : #streams }
FileReference >> openWritable: aBoolean [ 
	^ filesystem open: path writable: aBoolean
]

{ #category : #printing }
FileReference >> pathString [
	"Return the full path name of the receiver."
	
	^ filesystem stringFromPath: (filesystem resolve: path)
]

{ #category : #accessing }
FileReference >> permissions [
	^ filesystem permissions: self path
]

{ #category : #operations }
FileReference >> permissions: permissions [
	"Set the receivers mode to anInteger (as defined by chmod())"

	^filesystem file: self path posixPermissions: permissions posixPermission
]

{ #category : #printing }
FileReference >> printOn: aStream [
	filesystem forReferencePrintOn: aStream.
	filesystem printPath: path on: aStream
]

{ #category : #streams }
FileReference >> readStream [

	^ self readStreamEncoded: 'utf8'
]

{ #category : #operations }
FileReference >> renameTo: newBasename [
	
	| destinationPath |
	destinationPath := self fileSystem 
		rename: self 
		to: self parent / newBasename.
	
	destinationPath ifNotNil: [
		self 
			setFileSystem: filesystem 
			path: destinationPath ].
	^ self
		
]

{ #category : #accessing }
FileReference >> resolve [
	^ self
]

{ #category : #resolving }
FileReference >> resolvePath: anObject [
	^ self withPath: (path resolve: anObject)
]

{ #category : #resolving }
FileReference >> resolveReference: aReference [
	
	^ (filesystem = aReference fileSystem or: [aReference isRelative])
		ifTrue: [filesystem referenceTo: (path resolvePath: aReference path)]
		ifFalse: [aReference]
]

{ #category : #resolving }
FileReference >> resolveString: aString [ 
	| thePath |
	thePath := filesystem pathFromString: aString.
	^ filesystem referenceTo: (path resolve: thePath)
]

{ #category : #initialization }
FileReference >> setFileSystem: aFilesystem path: aPath [
	filesystem := aFilesystem.
	path := aPath
]

{ #category : #accessing }
FileReference >> size [
	^ filesystem sizeOf: path
]

{ #category : #accessing }
FileReference >> symlinkEntry [
	"Return the symlink entry (meta data) describing the receiver."
	^ filesystem symlinkEntryAt: path
]

{ #category : #accessing }
FileReference >> symlinkUid: uid gid: gid [
	"Set the owner and group of the receiver by numeric id.
	An id of nil leaves it unchanged."

	^filesystem file: self path symlinkUid: uid gid: gid.
]

{ #category : #accessing }
FileReference >> targetPath [
	"Return the target file of the File described by aPath.  For a regular file, this is itself, for a symbolic link, it is the file pointed to by the symbolic link"
	^ self class fileSystem: filesystem path: (filesystem targetPath: path)
]

{ #category : #accessing }
FileReference >> uid [
	"Return the gid of the file at aPath"
	^ filesystem uidOf: path
]

{ #category : #accessing }
FileReference >> uid: uid gid: gid [
	"Set the owner and group of the receiver by numeric id.
	An id of nil leaves it unchanged."

	^filesystem file: self path uid: uid gid: gid
]

{ #category : #streams }
FileReference >> unbufferedBinaryWriteStream [
	"Answer a binary read/write stream on the receiver"

	^ filesystem binaryWriteStreamOn: self path
]

{ #category : #versions }
FileReference >> versionNumberFor: basename extension: extension [
	"Answer the latest (largest) version number for the specified file.
	0 = basename.extension exists, but nothing later.
	nil = no file exists"
	| maxVersion |
	maxVersion := 0.
	self fileSystem childNamesAt: self path do: [ :child | | childVersion |
		childVersion := self extractVersionNumberFrom: child basename: basename extension: extension.
		childVersion ifNotNil: [ maxVersion := maxVersion max: childVersion ]].
	^maxVersion = 0
		ifTrue: [ (self / (basename, '.', extension)) asFileReference exists 
			ifTrue: [ 0 ]
			ifFalse: [ nil ] ]
		ifFalse: [ maxVersion ]
]

{ #category : #streams }
FileReference >> writeStream [
	
	^ self writeStreamEncoded: 'utf8'
]
