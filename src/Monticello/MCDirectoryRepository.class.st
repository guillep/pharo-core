"
A metacello repository in a directory 
"
Class {
	#name : #MCDirectoryRepository,
	#superclass : #MCFileBasedRepository,
	#instVars : [
		'directory'
	],
	#classVars : [
		'DefaultDirectoryName'
	],
	#category : #'Monticello-Repositories'
}

{ #category : #accessing }
MCDirectoryRepository class >> defaultDirectoryName [
	^ DefaultDirectoryName ifNil: [ FileSystem workingDirectory fullName].
]

{ #category : #accessing }
MCDirectoryRepository class >> defaultDirectoryName: aDirectoryName [
	DefaultDirectoryName := aDirectoryName.
]

{ #category : #accessing }
MCDirectoryRepository class >> description [
	^ 'directory'
]

{ #category : #'instance creation' }
MCDirectoryRepository class >> morphicConfigure [
	^ (UIManager default chooseDirectoryFrom: self defaultDirectoryName asFileReference) ifNotNil:
		[:directory |
		self new directory: directory]
]

{ #category : #accessing }
MCDirectoryRepository >> allFileNamesForVersionNamed: aString [
	"avoid slow default implementation and directly check for existing files"
	|extensions|
	extensions := MCReader concreteSubclasses collect: [ :class| class extension ].
	^ extensions 
		collect: [ :extension| aString , '.', extension ]
		thenSelect: [ :fileName| self includesFileNamed: fileName ]
]

{ #category : #accessing }
MCDirectoryRepository >> description [
	^ directory fullName
]

{ #category : #accessing }
MCDirectoryRepository >> directory [
	^ directory
]

{ #category : #accessing }
MCDirectoryRepository >> directory: aDirectory [
	directory := aDirectory
]

{ #category : #printing }
MCDirectoryRepository >> displayStringOn: aStream [
	aStream nextPutAll: self description
]

{ #category : #comparing }
MCDirectoryRepository >> hash [
	^ directory hash
]

{ #category : #testing }
MCDirectoryRepository >> includesFileNamed: aString [
	"HACK: speed up the cache hits"
	^ (directory / aString) exists.
]

{ #category : #testing }
MCDirectoryRepository >> includesVersionNamed: aString [
	"avoid slow default implementation and directly check for existing files"
	^ (self allFileNamesForVersionNamed: aString) isEmpty not
]

{ #category : #initialization }
MCDirectoryRepository >> initialize [
	super initialize.
	directory := FileSystem workingDirectory
]

{ #category : #testing }
MCDirectoryRepository >> isValid [
	^directory exists
]

{ #category : #interface }
MCDirectoryRepository >> loadAllFileNames [
	^ (directory entries sort: [:a :b | a modificationTime >= b modificationTime]) collect: [:ea | ea basename]
]

{ #category : #loading }
MCDirectoryRepository >> pathForFileNamed: aFileName [
  ^ (directory / aFileName) fullName
]

{ #category : #'i/o' }
MCDirectoryRepository >> readStreamForFileNamed: aString do: aBlock [
	| val |
	directory / aString binaryReadStreamDo: [ :stream|
		val := aBlock value: stream ].
	^ val
]

{ #category : #'i/o' }
MCDirectoryRepository >> writeStreamForFileNamed: aString replace: shouldReplace do: aBlock [

	| file |
	file := directory / aString.

	shouldReplace ifTrue: [ file ensureDelete ].

	file binaryWriteStreamDo: aBlock
]
