"
I am responsible for maintaining what version of Pharo and the VM is running.  I also track all of the update items that have been included in the image.

I'm invoked at auto start to get the latest plugins, etc.

Some queries are
	SystemVersion current major
	SystemVersion current minor
	SystemVersion current suffix
	SystemVersion current	highestUpdate
"
Class {
	#name : #SystemVersion,
	#superclass : #Object,
	#instVars : [
		'date',
		'highestUpdate',
		'type',
		'major',
		'minor',
		'patch',
		'suffix',
		'build',
		'commitHash'
	],
	#classVars : [
		'Current'
	],
	#category : #'System-Support-Image'
}

{ #category : #accessing }
SystemVersion class >> current [
	^Current ifNil: [Current := self new]
]

{ #category : #'private - accessing' }
SystemVersion class >> invalidBuildNumber [
	"Return -1 to depict an invalid build number (allows to also accept 0 as build number)"
	
	^ -1

]

{ #category : #'instance creation' }
SystemVersion class >> major: major minor: minor patch: patch [
	"Create a new instance of the receiver with the given major minor number.

		SystemVersion major: 6 minor: 1 patch: 199
	"

	^self major: major minor: minor patch: patch suffix: ''
]

{ #category : #'instance creation' }
SystemVersion class >> major: major minor: minor patch: patch suffix: aString [ 
	"Create a new instance of the receiver with the given major minor number and suffix.

	 	SystemVersion major: 6 minor: 1 patch: 199 suffix: 'alpha'     
	"
	
	^self major: major minor: minor patch: patch suffix: aString build: self invalidBuildNumber
]

{ #category : #'instance creation' }
SystemVersion class >> major: major minor: minor patch: patch suffix: aString build: build [
	"Create a new instance of the receiver with the given major minor number and suffix.

	 	SystemVersion major: 6 minor: 1 patch: 199 suffix: 'alpha' build: 148
	"

	^ self new
		major: major;
		minor: minor;
		patch: patch;
		suffix: aString;
		build: build;
		yourself
]

{ #category : #'instance creation' }
SystemVersion class >> major: major minor: minor patch: patch suffix: aString build: build commitHash: hashString [
	"Create a new instance of the receiver with the given major minor number and suffix.

	 	SystemVersion major: 6 minor: 1 suffix: 'alpha'     
	"
	
	^(self new)
		major: major;
		minor: minor;
		patch: patch;
		suffix: aString;
		build: build;
		commitHash: hashString;
		yourself
]

{ #category : #'accessing - properties' }
SystemVersion >> build [

	 ^build
]

{ #category : #'accessing - properties' }
SystemVersion >> build: aBuildNumber [

	build := aBuildNumber
]

{ #category : #private }
SystemVersion >> calculateHighestUpdate [ 
	|result|
	result := (major * 10000) + (minor * 1000).
	self hasValidBuildNumber ifTrue: [ result := result + build ].
	^result 
	

]

{ #category : #'accessing - properties' }
SystemVersion >> commitHash [
	"Answer the hash of a Git commit from which the image was bootstrapped, e.g. '9ce829e86f978a84fa68df20008a3c1ee52e1fae'"

	^ commitHash
]

{ #category : #'accessing - properties' }
SystemVersion >> commitHash: aString [

	"Set the hash of a Git commit from which the image was bootstrapped"

	commitHash := aString
]

{ #category : #accessing }
SystemVersion >> commitHashShort [
	"Answer the shorten hash of a Git commit from which the image was bootstrapped, e.g. '9ce829e"

	^ commitHash ifNotNil: [ commitHash first: (7 min: commitHash size) ]
]

{ #category : #'accessing - properties' }
SystemVersion >> date [
	^date
]

{ #category : #'accessing - properties' }
SystemVersion >> date: newDate [
	date := newDate
]

{ #category : #'accessing - version strings' }
SystemVersion >> datedVersion [
	" E.g. 'Pharo2.0a of ''18 April 2012''' "

	^ self version asString , ' of ' , self date printString.
]

{ #category : #accessing }
SystemVersion >> dottedMajorMinor [
	
	^ self majorMinor: '.'
]

{ #category : #accessing }
SystemVersion >> dottedMajorMinorPatch [
	
	^ self majorMinorPatch: '.'.
]

{ #category : #testing }
SystemVersion >> hasMetadataIdentifiers [
	"Return true if we have metadata identifiers (see rule 10 on semver.org) that need to be separated with a + sign"
	
	^self suffix notEmpty | self hasValidBuildNumber | self commitHash notEmpty 
]

{ #category : #testing }
SystemVersion >> hasValidBuildNumber [
	"Return true if we have a valid build number"
	
	 ^self build ~= self class invalidBuildNumber
]

{ #category : #compatibility }
SystemVersion >> highestUpdate [
	 ^highestUpdate ifNil: [ highestUpdate := self calculateHighestUpdate ].

	

]

{ #category : #compatibility }
SystemVersion >> highestUpdate: anInteger [
	highestUpdate := anInteger
]

{ #category : #'accessing - version strings' }
SystemVersion >> imageVersionString [
	"Print the version compatibile with naming the image."
	
	^String streamContents: [:str |
		str nextPutAll: self type;
			 nextPut: $-;
			 nextPutAll: (self majorMinorPatch: '.').
			
		self hasMetadataIdentifiers ifTrue: [ str nextPut: $+ ].		
		self suffix ifNotEmpty: [ str nextPutAll: self suffix ].
		self hasValidBuildNumber ifTrue: [ 
			self suffix ifNotEmpty: [ str nextPut: $.].
			str nextPutAll: 'build.'; nextPutAll: self build asString ].	
		self commitHash ifNotEmpty: [ str nextPutAll: '.sha.'; nextPutAll: self commitHash ].
		
		Smalltalk vm is32bit ifTrue: [ str nextPutAll: ' (32 Bit)' ]
								   ifFalse: [ str nextPutAll: ' (64 Bit)' ].					
	]
]

{ #category : #initialization }
SystemVersion >> initialize [
	super initialize.
	type := 'Pharo'.
	major := 0.
	minor := 0.
	patch := 0.
	suffix := ''.
	build := self class invalidBuildNumber.
	commitHash := ''.
	date := Date today.
]

{ #category : #'accessing - properties' }
SystemVersion >> major [
	"Answer the major number of a version. 1 in '1.2'"

	^ major
]

{ #category : #'accessing - properties' }
SystemVersion >> major: anInteger [
	"Set the major part of the receiver"

	major := anInteger
]

{ #category : #utilities }
SystemVersion >> majorMinor: aSeparatingString [
	"Return the major/minor version number of the form XaSeparatingStringY, without any 'alpha' or 'beta' or other suffix."
	"SystemVersion current majorMinor: '-'"
	"SystemVersion current majorMinor: ''"

	^String streamContents: [:str |
		str 
			nextPutAll: self major printString; 
			nextPutAll: aSeparatingString;
			nextPutAll: self minor printString ]
]

{ #category : #utilities }
SystemVersion >> majorMinorPatch: aSeparatingString [
	"Return the major/minor/patch version number of the form XaSeparatingStringY, without any 'alpha' or 'beta' or other suffix."
	"SystemVersion current majorMinorPatch: '-'"
	"SystemVersion current majorMinorPatch: ''"

	^String streamContents: [:str |
		str 
			nextPutAll: self major printString; 
			nextPutAll: aSeparatingString;
			nextPutAll: self minor printString;
			nextPutAll: aSeparatingString;
			nextPutAll: self patch printString ]
]

{ #category : #accessing }
SystemVersion >> majorMinorVersion [
	
	^ self type, self dottedMajorMinorPatch
]

{ #category : #'accessing - properties' }
SystemVersion >> minor [
	"Answer the minor number of a version. 2 in '1.2'"

	^ minor
]

{ #category : #'accessing - properties' }
SystemVersion >> minor: anInteger [
	"Set the minor part of the receiver"

	minor := anInteger
]

{ #category : #accessing }
SystemVersion >> patch [
	^ patch
]

{ #category : #accessing }
SystemVersion >> patch: anObject [
	patch := anObject
]

{ #category : #printing }
SystemVersion >> printOn: stream [
	stream nextPutAll: self imageVersionString
]

{ #category : #'accessing - version strings' }
SystemVersion >> shortVersionString [
	"Print a short version string."
	
	self type ifNil: [^'No version set'].
	^String streamContents: [:str |
		str 
			nextPutAll: self type;
			nextPutAll: self major printString;
			nextPut: $.;
			nextPutAll: self minor printString;
			nextPut: $.;
			nextPutAll: self patch printString;
			nextPutAll: self suffix ]
]

{ #category : #'accessing - properties' }
SystemVersion >> suffix [
	"Answer the suffix (alpha, beta, rc  of a version. beta in '1.2beta'"

	^ suffix
]

{ #category : #'accessing - properties' }
SystemVersion >> suffix: anObject [
	"Set the value of suffix"

	suffix := anObject
]

{ #category : #'accessing - properties' }
SystemVersion >> type [
	"Answer the value of type"

	^ type
]

{ #category : #'accessing - properties' }
SystemVersion >> type: anObject [
	"Set the value of type"

	type := anObject
]

{ #category : #accessing }
SystemVersion >> version [
	"Answer the short version string. If the receiver needs upgrading, do it."
	
	^self shortVersionString
]

{ #category : #accessing }
SystemVersion >> versionWithoutPatch [
	
	^ self type , (self majorMinor: '.')
]
