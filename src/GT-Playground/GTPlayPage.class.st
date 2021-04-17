"
It holds one page of code. It is the model behind the Playground.

It also knows how to store itself on disk, and every time its content changes, it updates the corresponding file.
"
Class {
	#name : #GTPlayPage,
	#superclass : #Object,
	#instVars : [
		'title',
		'content',
		'creationTime',
		'publishedUrl',
		'persistenceStrategies'
	],
	#category : #'GT-Playground'
}

{ #category : #private }
GTPlayPage class >> basicLoadFromPublishUrl: aString [
	^ GTPlayPage new 
		saveContent: (GTUrlProvider new get: aString)
		yourself
]

{ #category : #'instance creation' }
GTPlayPage class >> creationTimeFrom: aFileReference [
	^ [ self creationTimeFromString: aFileReference basenameWithoutExtension ] 
		on: Error 
		do: [ aFileReference creationTime ]
]

{ #category : #'instance creation' }
GTPlayPage class >> creationTimeFromString: aString [
	" this is really ugly, but hopefully only a temporary solution untill we come up with somthing more reliable and more beautiful "
	| subexpressions |
	subexpressions := OrderedCollection new.
	'(\d+)-(\d+)-(\d+)T(\d+)-(\d+)-(\d+)(-(\d+))?([-+]\d+)-(\d+)(-(\d+))?' asRegex 
		matchesIn: aString
		subexpressionsDo: [ :expression :expressionFragments | 
			subexpressions addAll: (expressionFragments collect: [ :each | 
				[ each squeezeOutNumber ] on: Error do: [ 0 ] ]) ].
	^ DateAndTime 
		year: subexpressions first 
		month: subexpressions second 
		day: subexpressions third 
		hour: subexpressions fourth 
		minute: subexpressions fifth 
		second: subexpressions sixth 
		nanoSecond: subexpressions eighth * 100000 " 7 == full match "
		offset: (Duration 
						days: 0 
						hours: subexpressions ninth 
						minutes: (subexpressions at: 10) 
						seconds: (subexpressions at: 12)) " 11 == full match "
]

{ #category : #'accessing-dynamic' }
GTPlayPage class >> fileExtension [
	^ 'ph'
]

{ #category : #'instance creation' }
GTPlayPage class >> fromFileReference: aFileReference [
	^ self new
		content: (aFileReference readStreamDo: #contents); 
		creationTime: (self creationTimeFrom: aFileReference);
		yourself
]

{ #category : #examples }
GTPlayPage class >> gtExampleEmpty [
	<gtExample>
	<label: 'Empty'>
	
	^ self new
]

{ #category : #'instance creation' }
GTPlayPage class >> loadFromPublishUrl: aString [
	^ [ self basicLoadFromPublishUrl: aString ] 
		on: Error 
		do: [ nil ]
]

{ #category : #'instance creation' }
GTPlayPage class >> loadFromPublishUrl: aString thenDo: aBlock [
	| page |
	page := self loadFromPublishUrl: aString.
	page ifNotNil: [ aBlock value: page ].
	^ page
]

{ #category : #'compatibility-tools' }
GTPlayPage >> acceptContents: aStringOrtext [

	self flag: #TODO. "Need support for what lies in the comment down here"
	"self fileName ifNotNil: [ self saveString: aStringOrtext toFile: self fileName ].

	acceptAction ifNotNil:[acceptAction value: aStringOrtext]."
	self saveContent: aStringOrtext.
	^ true
]

{ #category : #accessing }
GTPlayPage >> content [
	^ content
]

{ #category : #accessing }
GTPlayPage >> content: aString [
	content := aString asString
]

{ #category : #'accessing-dynamic' }
GTPlayPage >> contentString [
	" strange, sometimes #content is aText not aString ! "
	^ self content asString
]

{ #category : #accessing }
GTPlayPage >> creationTime [
	^ creationTime
]

{ #category : #accessing }
GTPlayPage >> creationTime: anObject [
	creationTime := anObject
]

{ #category : #'accessing-defaults' }
GTPlayPage >> creationTimeForFileName [
	^ (self creationTime asString copyReplaceAll: ':' with: '-') copyReplaceAll: '.' with: '-'
]

{ #category : #ui }
GTPlayPage >> displayStringOn: stream [
	stream nextPutAll: (self contentString copyReplaceAll: String cr with: String space)
]

{ #category : #'accessing-dynamic' }
GTPlayPage >> ensureStashPersistency [
	(self persistenceStrategies noneSatisfy: [ :each | each isStash ])
		ifTrue: [ self persistenceStrategies add: (GTPlayPageStashPersistence new page: self) ]
]

{ #category : #ui }
GTPlayPage >> gtDisplayOn: stream [
	stream nextPutAll: (self contentString copyReplaceAll: String cr with: String space)
]

{ #category : #ui }
GTPlayPage >> gtInspectorContentIn: composite [
	<gtInspectorPresentationOrder: 0>
	composite pharoScript 
		title: 'Content';
		display: #content;
		installDefaultSelectionActions
]

{ #category : #initialization }
GTPlayPage >> initialize [
	super initialize.
	self content: ''.
	self creationTime: DateAndTime now.
	persistenceStrategies := OrderedCollection with: (GTPlayPageCachePersistence new page: self)
]

{ #category : #testing }
GTPlayPage >> isInteresting [
	^ self contentString trimBoth isEmpty not
]

{ #category : #accessing }
GTPlayPage >> persistenceStrategies [
	^ persistenceStrategies
]

{ #category : #accessing }
GTPlayPage >> persistenceStrategies: anObject [
	persistenceStrategies := anObject
]

{ #category : #actions }
GTPlayPage >> publish [
	(self confirm: 'Publish playground content to the cloud?')
        ifFalse: [ ^ self ].
    self content ifEmpty: [ 
        self inform: 'Nothing was published because the playground is empty'.
        ^ self ].
    Clipboard clipboardText: (publishedUrl := (GTUrlProvider new post: self contentString) asString).
    self inform: publishedUrl , ' was published and the url was copied to clipboard'
]

{ #category : #actions }
GTPlayPage >> save [
	persistenceStrategies do: [ :each | each save ]
]

{ #category : #actions }
GTPlayPage >> saveContent: aStringOrText [
	self content: aStringOrText.
	self save.
]

{ #category : #'accessing-dynamic' }
GTPlayPage >> setTitleAndEnsureInStash: aString [
	self title: aString.
	self ensureStashPersistency.
	self save
]

{ #category : #'accessing-dynamic' }
GTPlayPage >> title [
	^ title ifNil: [ 'Page' ]
]

{ #category : #'accessing-dynamic' }
GTPlayPage >> title: aString [
	title := aString
]
