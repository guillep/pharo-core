"
This is the abstract superclass for archive members, which are files or directories stored in archives.
"
Class {
	#name : #ArchiveMember,
	#superclass : #Object,
	#instVars : [
		'fileName',
		'isCorrupt'
	],
	#category : #'Compression-Archives'
}

{ #category : #'instance creation' }
ArchiveMember class >> newDirectoryNamed: aString [
	self subclassResponsibility
]

{ #category : #'instance creation' }
ArchiveMember class >> newFromFile: aFileName [
	self subclassResponsibility
]

{ #category : #'instance creation' }
ArchiveMember class >> newFromString: aString [
	self subclassResponsibility
]

{ #category : #initialization }
ArchiveMember >> close [

]

{ #category : #accessing }
ArchiveMember >> fileName [
	^fileName
]

{ #category : #accessing }
ArchiveMember >> fileName: aName [
	fileName := aName
]

{ #category : #initialization }
ArchiveMember >> initialize [
	super initialize.
	fileName := ''.
	isCorrupt := false
]

{ #category : #accessing }
ArchiveMember >> isCorrupt [
	^isCorrupt ifNil: [ isCorrupt := false ]
]

{ #category : #accessing }
ArchiveMember >> isCorrupt: aBoolean [
	"Mark this member as being corrupt."
	isCorrupt := aBoolean
]

{ #category : #accessing }
ArchiveMember >> localFileName: aString [
	"Set my internal filename.
	Returns the (possibly new) filename"

	^ fileName := aString
		copyReplaceAll: FileSystem disk delimiter asString
		with: UnixStore delimiter asString
]

{ #category : #printing }
ArchiveMember >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPut: $(;
		nextPutAll: self fileName;
		nextPut: $)
]

{ #category : #testing }
ArchiveMember >> usesFile: aFileReferenceOrFileName [
	"Do I require aFileName? That is, do I care if it's clobbered?"
	^false
]
