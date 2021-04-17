"
This class holds the pages that are loaded in the image.

At class initialization time, it loads pages from the cacheDirectory and then maintains the pages in memory.
"
Class {
	#name : #GTPlayBook,
	#superclass : #Object,
	#instVars : [
		'pages',
		'pagesLimit'
	],
	#classVars : [
		'DefaultCacheDirectory',
		'DefaultStashDirectory'
	],
	#classInstVars : [
		'instance',
		'cacheDirectory',
		'stashDirectory'
	],
	#category : #'GT-Playground'
}

{ #category : #accessing }
GTPlayBook class >> cacheDirectory [
	" lazy initialize the cache and always ensure its existence - especially while the image is running "
	cacheDirectory ifNil: [ cacheDirectory := self defaultCacheDirectory ].
	cacheDirectory fileSystem isWritable ifFalse: [ ^ cacheDirectory ].
	^ cacheDirectory ensureCreateDirectory
]

{ #category : #accessing }
GTPlayBook class >> cacheDirectory: aStringOrFileReference [

	cacheDirectory := self 
							ensureDirectory: aStringOrFileReference 
							distinctFrom: self defaultCacheDirectory
]

{ #category : #private }
GTPlayBook class >> cleanUp [
	
	self reset
]

{ #category : #accessing }
GTPlayBook class >> customDirectory: aFileReference [ 
	"this is here for preserving backward compatibility with 
	older settings that relied on customDirectory instead
	of cacheDirectory"
	self cacheDirectory: aFileReference
]

{ #category : #'accessing-defaults' }
GTPlayBook class >> defaultCacheDirectory [
	^ (DefaultCacheDirectory ifNil: [ DefaultCacheDirectory := FileLocator localDirectory / 'play-cache' ]) asFileReference
]

{ #category : #'accessing-defaults' }
GTPlayBook class >> defaultCacheDirectory: aFileReference [
	DefaultCacheDirectory := aFileReference
]

{ #category : #'accessing-defaults' }
GTPlayBook class >> defaultStashDirectory [
	^ (DefaultCacheDirectory ifNil: [ DefaultCacheDirectory := FileLocator localDirectory / 'play-stash' ]) asFileReference
]

{ #category : #'accessing-defaults' }
GTPlayBook class >> defaultStashDirectory: aFileReference [
	^ DefaultStashDirectory := aFileReference
]

{ #category : #private }
GTPlayBook class >> ensureDirectory: aStringOrFileReference distinctFrom: aDefaultDirectory [
		" Ensure aStringOrFileReference is either nil or a valid file-reference object distinct from the default one.
	  Do not create any directory on disk yet - the first access to any directory will handle that.
	  #asFileReference and #absolutePath may raise anError! "
	| fileReference |

	^ [ 
		fileReference := aStringOrFileReference asFileReference.
		^ fileReference absolutePath = aDefaultDirectory absolutePath
			ifTrue: [ nil ]
			ifFalse: [ fileReference ]
			
		" Background: The behavior of the default directory is being relative to the image. Therefore the default file-reference is relative to the image. If the image is moved/copied around the file-reference will stay relative to the image. We assume this is the expected behavior for the default directory. Therefore we prevent the user from setting that value as an absolute file-reference, since an absolute file-reference would behave differently when an image is moved/copied around. "	
		]
			on: Error
			do: [ nil ]
]

{ #category : #examples }
GTPlayBook class >> gtExampleEmpty [
	<gtExample>
	<label: 'Empty'>
	
	^ self new
]

{ #category : #initializing }
GTPlayBook class >> initialize [
	" we have to make sure the cached references are up-to-date after the image starts up "
	
	Smalltalk addToStartUpList: self
]

{ #category : #accessing }
GTPlayBook class >> instance [
	^ instance ifNil: [ instance := self new ]
]

{ #category : #initialization }
GTPlayBook class >> reset [
	
	instance := nil.
	stashDirectory := nil.
	self resetDirectories
]

{ #category : #private }
GTPlayBook class >> resetDirectories [

	cacheDirectory := nil
]

{ #category : #initializing }
GTPlayBook class >> startUp [

	cacheDirectory := nil.
]

{ #category : #initializing }
GTPlayBook class >> startUp: resuming [

	cacheDirectory := nil.
]

{ #category : #accessing }
GTPlayBook class >> stashDirectory [
	" lazy initialize the stash and always ensure its existence - especially while the image is running "
	(stashDirectory notNil and: [ stashDirectory exists ])
		ifFalse: [ stashDirectory := self defaultStashDirectory ].
	^ stashDirectory ensureCreateDirectory
]

{ #category : #accessing }
GTPlayBook class >> stashDirectory: aStringOrFileReference [

	stashDirectory := self 
							ensureDirectory: aStringOrFileReference 
							distinctFrom: self defaultStashDirectory
]

{ #category : #actions }
GTPlayBook >> addPage: aPage [
	self pages addFirst: aPage
]

{ #category : #actions }
GTPlayBook >> addPageIfInteresting: aPage [
	aPage isInteresting ifFalse: [ ^ self ].
	self addPage: aPage
]

{ #category : #'accessing-dynamic' }
GTPlayBook >> allFiles [
	^ self class cacheDirectory files select: [ :each | 
		each extension = GTPlayPage fileExtension ]
]

{ #category : #'accessing-dynamic' }
GTPlayBook >> allFilesSorted [
	^ self allFiles sorted: [ :a :b | 
		a modificationTime > b modificationTime ]
]

{ #category : #'accessing-defaults' }
GTPlayBook >> defaultPages [
	^ OrderedCollection new
]

{ #category : #'accessing-defaults' }
GTPlayBook >> defaultPagesLimit [
	" page list in ui might get too long / holding too many object might decrease performance "
	^ 100
]

{ #category : #'accessing-dynamic' }
GTPlayBook >> files [
	^ self allFilesSorted takeFirst: self pagesLimit
]

{ #category : #ui }
GTPlayBook >> gtPagesIn: composite [
	<gtInspectorPresentationOrder: 0>
	composite list 
		title: 'Pages';
		display: [ self pages ];
		format: #displayString;
		filterOn: [ :text :each | text match: each content ]
]

{ #category : #initialization }
GTPlayBook >> initialize [
	self flag: 'error handling'.
	
	self pages: self defaultPages.
	self files do: [ :each | 
		[ self pages add: (GTPlayPage fromFileReference: each) ] " bypass "
			on: Error 
			do: [ " unhandled exceptions are bad design - we should handle it somehow " ] ]
]

{ #category : #accessing }
GTPlayBook >> pages [
	^ pages ifNil: [ pages := self defaultPages ]
]

{ #category : #accessing }
GTPlayBook >> pages: anObject [
	pages := anObject
]

{ #category : #accessing }
GTPlayBook >> pagesLimit [
	^ pagesLimit ifNil: [ self defaultPagesLimit ]
]

{ #category : #accessing }
GTPlayBook >> pagesLimit: anObject [
	pagesLimit := anObject
]

{ #category : #actions }
GTPlayBook >> removePage: aPage [
	self pages remove: aPage ifAbsent: [ " ignore if aPage is not registered " ]
]
