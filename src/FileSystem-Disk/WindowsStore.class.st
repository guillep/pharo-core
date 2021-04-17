"
I'm a specific store for Windows file systems
"
Class {
	#name : #WindowsStore,
	#superclass : #DiskStore,
	#instVars : [
		'disk'
	],
	#category : #'FileSystem-Disk-Store'
}

{ #category : #accessing }
WindowsStore class >> delimiter [
	^ $\
]

{ #category : #accessing }
WindowsStore class >> isCaseSensitive [
	^ false
]

{ #category : #accessing }
WindowsStore class >> maxFileNameLength [
	self flag: #pharoTodo. "More tests needed here!".
	^ 255
]

{ #category : #accessing }
WindowsStore class >> readOnlyVariant [

	^ ReadOnlyWindowsStore
]

{ #category : #accessing }
WindowsStore class >> separator [ 
	^ $\
]

{ #category : #accessing }
WindowsStore >> accessTimeOf: aPath [
	"Answer the access time of aPath."

	aPath isRoot ifTrue: [ ^self rootEntry accessTime ].
	^super accessTimeOf: aPath
]

{ #category : #accessing }
WindowsStore >> changeTimeOf: aPath [
	"Answer the change time of aPath."

	aPath isRoot ifTrue: [ ^self rootEntry changeTime ].
	^super changeTimeOf: aPath
]

{ #category : #public }
WindowsStore >> checkName: aFileName fixErrors: fixing [
	"Check if the file name contains any invalid characters"
	
	| fName badChars |
	fName := super checkName: aFileName fixErrors: fixing.
	badChars := (#( $: $< $> $| $/ $\ $? $* $"), ((0 to: 31) collect: [:n | n asCharacter])) asSet.
	
	(fName includesAnyOf: badChars)
		ifFalse: [^ fName].
	
	fixing ifFalse: [^self error: 'filename contains invalid characters'].
	
	^ fName collect:
		[:char | (badChars includes: char) 
				ifTrue: [$#] 
				ifFalse: [char]]
]

{ #category : #accessing }
WindowsStore >> creationTimeOf: aPath [
	"Answer the creation time of aPath.  If the platform doesn't support creation time, use change time"

	aPath isRoot ifTrue: [ ^self rootEntry creationTime ].
	^super creationTimeOf: aPath
]

{ #category : #converting }
WindowsStore >> currentDisk [
	^ disk ifNil: [  disk := FileSystem workingDirectory path segments first ]
]

{ #category : #accessing }
WindowsStore >> deviceIdOf: aPath [
	"Return the device id of the file at aPath"

	aPath isRoot ifTrue: [ ^self rootEntry deviceId ].
	^super deviceIdOf: aPath
]

{ #category : #private }
WindowsStore >> directoryAt: aPath nodesDo: aBlock [

	| mask drive node |

	aPath isRoot ifFalse: [ ^super directoryAt: aPath nodesDo: aBlock ].

	mask := File primLogicalDrives.
	0 to: 25 do: [ :i |
		(mask bitAnd: (1 bitShift: i)) ~= 0 ifTrue: [ 
			drive := String with: (Character value: ($A asciiValue + i)) with: $:.
			node := Array
				with: drive
				with: drive asFileReference entry statAttributes.
			aBlock value: node.
			]
		]
]

{ #category : #private }
WindowsStore >> entryAt: aPath fileSystem: aFilesystem [

	aPath isRoot ifTrue: [ ^aFilesystem store rootEntry ].
	^super entryAt: aPath fileSystem: aFilesystem
]

{ #category : #accessing }
WindowsStore >> gidOf: aPath [
	"Return the gid of the file at aPath"

	aPath isRoot ifTrue: [ ^self rootEntry gid ].
	^super gidOf: aPath
]

{ #category : #accessing }
WindowsStore >> inodeOf: aPath [
	"Return the inode of the file at aPath"

	aPath isRoot ifTrue: [ ^self rootEntry inode ].
	^super inodeOf: aPath
]

{ #category : #accessing }
WindowsStore >> isBlock: aPath [
	"Answer a boolean indicating whether the supplied path is a Block file"

	aPath isRoot ifTrue: [ ^self rootEntry isBlock ].
	^super isBlock: aPath
]

{ #category : #accessing }
WindowsStore >> isCharacter: aPath [
	"Answer a boolean indicating whether the supplied path is a Character file"

	aPath isRoot ifTrue: [ ^self rootEntry isCharacter ].
	^super isCharacter: aPath
]

{ #category : #accessing }
WindowsStore >> isExecutable: aPath [
	"Answer a boolean indicating whether the supplied path is executable"

	aPath isRoot ifTrue: [ ^self rootEntry isExecutable ].
	^super isExecutable: aPath
]

{ #category : #testing }
WindowsStore >> isFIFO: aPath [
	"Answer a boolean indicating whether the supplied path is a FIFO file (pipe)"

	aPath isRoot ifTrue: [ ^self rootEntry isFIFO ].
	^super isFIFO: aPath
]

{ #category : #testing }
WindowsStore >> isHidden: aPath attributes: statAttributesArray [
	"Answer a boolean indicating whether the file is hidden or not.
	statAttributesArray is optional and may be supplied for performance.  It is the result of File>>fileAttributes:mask: or nil"

	| attributesArray |
	
	attributesArray := statAttributesArray ifNil: 
		[ File fileAttributes: (self stringFromPath: aPath) mask: 1 ].

	^(attributesArray at: 13) anyMask: 16r2
]

{ #category : #testing }
WindowsStore >> isReadable: aPath [
	"Answer a boolean indicating whether the supplied path is readable"

	aPath isRoot ifTrue: [ ^self rootEntry isReadable ].
	^super isReadable: aPath
]

{ #category : #testing }
WindowsStore >> isRegular: aPath [
	"Answer a boolean indicating whether the supplied path is a Regular file"

	aPath isRoot ifTrue: [ ^self rootEntry isRegular ].
	^super isRegular: aPath
]

{ #category : #testing }
WindowsStore >> isSocket: aPath [
	"Answer a boolean indicating whether the supplied path is a Socket file"

	aPath isRoot ifTrue: [ ^self rootEntry isSocket ].
	^super isSocket: aPath
]

{ #category : #testing }
WindowsStore >> isWritable: aPath [
	"Answer a boolean indicating whether the supplied path can be written to"

	aPath isRoot ifTrue: [ ^self rootEntry isWritable ].
	^super isWritable: aPath
]

{ #category : #accessing }
WindowsStore >> modificationTimeOf: aPath [
	"Answer the modification time of aPath."

	aPath isRoot ifTrue: [ ^self rootEntry modificationTime ].
	^super modificationTimeOf: aPath
]

{ #category : #accessing }
WindowsStore >> numberOfHardLinks: aPath [
	"Return the number of hard links for the File described by aPath"

	aPath isRoot ifTrue: [ ^self rootEntry numberOfHardLinks ].
	^super numberOfHardLinks: aPath
]

{ #category : #converting }
WindowsStore >> pathFromString: aString [
	"Need to distinguish '' and '/' , so tag latter with invalid character ':'  "
	| normalized pathClass pathElements |
	normalized := aString copy replaceAll: UnixStore delimiter with: self delimiter.
	pathElements := self delimiter split: normalized.
	pathClass := (Path isAbsoluteWindowsPath: normalized)
		ifTrue: [ (normalized = self delimiter asString) ifTrue: [ pathElements := { ':' } ].
			AbsolutePath ]
		ifFalse: [ self stripDrive: pathElements.
			RelativePath ].
	^pathClass withAll: pathElements
]

{ #category : #accessing }
WindowsStore >> permissions: aPath [
	"Answer the FileSystemPermissions for the supplied path"

	aPath isRoot ifTrue: [ ^self rootEntry permissions ].
	^super permissions: aPath
]

{ #category : #converting }
WindowsStore >> printPath: aPath on: aStream [
	| hasDrive |
	aPath isRoot
		ifTrue: [ ^ self ].	"effectively Windows root is empty string"
	aPath isWorkingDirectory
		ifTrue: [ ^ aPath printOn: aStream delimiter: self delimiter ].
	aPath isRelative
		ifTrue: [ ^ aPath printOn: aStream delimiter: self delimiter ].
	aPath segments first first = $:
		ifTrue: [ ^ aStream nextPut: self delimiter ].	"as tagged in #pathFromString:  "
	hasDrive := aPath segments first second = $:.
	(hasDrive not )
		ifTrue: [ aStream nextPut: self delimiter ].
	aPath printOn: aStream delimiter: self delimiter.
	(hasDrive and: [ aPath segments size = 1 ])
		ifTrue: [ aStream nextPut: self delimiter ]
]

{ #category : #accessing }
WindowsStore >> sizeOf: aPath [
	"Return the size of the File described by aPath"
	aPath isRoot ifTrue: [ ^self rootEntry size ].
	^super sizeOf: aPath.
]

{ #category : #converting }
WindowsStore >> stripDrive: pathElements [
	pathElements ifNotEmpty: [ pathElements at: 1 put: ( ($: split: pathElements first) last)  ]
]

{ #category : #accessing }
WindowsStore >> uidOf: aPath [
	"Return the uid of the File described by aPath"
	aPath isRoot ifTrue: [ ^self rootEntry uid ].
	^super uidOf: aPath.
]
