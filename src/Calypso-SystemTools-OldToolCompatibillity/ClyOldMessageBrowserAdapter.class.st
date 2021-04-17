"
I am a special adapter for the old message browser interface which users call using: 

	Smalltalk tools messageList 

The most of system queries are triggered by SystemNavigation which collects list of result methods and pass them to the registered message browser.
In contrast Calypso needs instance of query.

So to suppord old (current) approach I build special ClyOldMessageBrowserQuery on constant list of methods and then I open ClyQueryBrowser on it.
 
When Calypso is registered as default browser I am used as #messageList.
In future we should introduce #queryBrowser instead of it with direct usage of Calypso queries.

Internal Representation and Key Implementation Points.

    Instance Variables
	autoSelect:		<Boolean>
	messages:		<Collection of<CompiledMethod>>
	refreshingBlock:		<BlockClosure>
	title:		<String>
"
Class {
	#name : #ClyOldMessageBrowserAdapter,
	#superclass : #Object,
	#instVars : [
		'messages',
		'title',
		'autoSelect',
		'refreshingBlock',
		'openedBrowser'
	],
	#category : #'Calypso-SystemTools-OldToolCompatibillity'
}

{ #category : #'tools registration' }
ClyOldMessageBrowserAdapter class >> beDefaultBrowser [
	<script>
	self registerToolsOn: Smalltalk tools
]

{ #category : #opening }
ClyOldMessageBrowserAdapter class >> browse: methods [
	^ self new
		messages: methods;
		open
]

{ #category : #opening }
ClyOldMessageBrowserAdapter class >> browse: methods title: aString [
	^ self new
		messages: methods;
		title: aString;
		open
]

{ #category : #opening }
ClyOldMessageBrowserAdapter class >> browse: methods title: aString autoSelect: aSelectString [
	^ self new
		messages: methods;
		title: aString;
		autoSelect: aSelectString;
		open
]

{ #category : #opening }
ClyOldMessageBrowserAdapter class >> browseClasses: classes [ 
	^ClyQueryBrowser browseClasses: classes
]

{ #category : #opening }
ClyOldMessageBrowserAdapter class >> browseImplementorsOf: aSymbol [ 
	^ClyQueryBrowser browseImplementorsOf: aSymbol 

]

{ #category : #opening }
ClyOldMessageBrowserAdapter class >> browseSendersOf: aSymbol [ 
	^ClyQueryBrowser browseSendersOf: aSymbol 

]

{ #category : #'tools registration' }
ClyOldMessageBrowserAdapter class >> registerToolsOn: registry [
	"Add ourselves to registry. See [Smalltalk tools]" 
	registry register: self as: #messageList
]

{ #category : #accessing }
ClyOldMessageBrowserAdapter >> autoSelect [
	^ autoSelect
]

{ #category : #accessing }
ClyOldMessageBrowserAdapter >> autoSelect: anObject [
	autoSelect := anObject
]

{ #category : #opening }
ClyOldMessageBrowserAdapter >> close [
	openedBrowser ifNotNil: #close
]

{ #category : #initialization }
ClyOldMessageBrowserAdapter >> initialize [
	super initialize.
	
	title := 'MessageBrowser'
]

{ #category : #accessing }
ClyOldMessageBrowserAdapter >> messages [
	^ messages
]

{ #category : #accessing }
ClyOldMessageBrowserAdapter >> messages: anObject [
	messages := anObject
]

{ #category : #opening }
ClyOldMessageBrowserAdapter >> open [
	| query methods comments |
	methods := messages 
		select: [:each | (each isRingObject and: [ each isMethod ]) or: [ each isCompiledMethod  ] ]
		thenCollect: [ :each | each compiledMethod ].
	comments := messages 
		select: [:each | each isRingObject and: [ each isComment  ]]
		thenCollect: [ :each | ClyClassComment of: each realParent ].
	query := ClyOldMessageBrowserQuery named: title with: methods asOrderedCollection, comments.
	query
		criteriaString: autoSelect;
		criteriaBlock: refreshingBlock.
	openedBrowser := ClyQueryBrowser openOn: query.
]

{ #category : #accessing }
ClyOldMessageBrowserAdapter >> refreshingBlock [
	^ refreshingBlock
]

{ #category : #accessing }
ClyOldMessageBrowserAdapter >> refreshingBlock: anObject [
	refreshingBlock := anObject
]

{ #category : #accessing }
ClyOldMessageBrowserAdapter >> title [
	^ title
]

{ #category : #accessing }
ClyOldMessageBrowserAdapter >> title: anObject [
	title := anObject
]
