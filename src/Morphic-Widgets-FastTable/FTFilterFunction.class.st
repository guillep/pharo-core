"
I define a filter function for a table. 
I respond to any alphanumeric element and I add a filter box to the  owner table. 

In general, my entry point is through #keyStroke:, because I intend to react to keyboard inputs in the owner table.

I save an initial data source if the user want to see some result already filter.

I use a semaphore in order to let a delay before I filter the table. With this the user is able to type more than 1 letter before I filter.

/!\ To use me the data source must implement the method #newDataSourceMatching: aRegex
"
Class {
	#name : #FTFilterFunction,
	#superclass : #FTWithFieldFunction,
	#instVars : [
		'initialDataSource',
		'pattern',
		'isEditingSemaphore',
		'filterClass'
	],
	#category : #'Morphic-Widgets-FastTable-Functions'
}

{ #category : #updating }
FTFilterFunction >> colorText: aText [
	table dataSource numberOfRows ~= 0
		ifTrue: [ aText makeAllColor: self table theme textColor ]
		ifFalse: [ aText addAttribute: (TextColor new color: Color red) ].
	^ aText
]

{ #category : #updating }
FTFilterFunction >> filter [
	pattern ifNil: [ ^ self ].

	table dataSource: (pattern ifEmpty: [ initialDataSource ] ifNotEmpty: [ initialDataSource newDataSourceMatching: (filterClass pattern: pattern) ]).
	table refresh.
	table deselectAll.
		
	self isExplicit
		ifTrue: [ self resizeWidget ]
]

{ #category : #accessing }
FTFilterFunction >> filterClass [
	^filterClass
]

{ #category : #accessing }
FTFilterFunction >> filterClass: aFTFilterClass [
	filterClass := aFTFilterClass
]

{ #category : #updating }
FTFilterFunction >> filterWith: aStringOrText [
	initialDataSource ifNil: [ self initializeFilter ].	"I do this in case the filter is use explicictly in the FT, at the first call the Filter will not be initialize."
	pattern := aStringOrText asString trimBoth.
	isEditingSemaphore signal
]

{ #category : #'widget API' }
FTFilterFunction >> ghostText [
	^ 'Filter...'
]

{ #category : #initialization }
FTFilterFunction >> initialize [
	super initialize.
	filterClass := FTRegexFilter 
]

{ #category : #initialization }
FTFilterFunction >> initializeFilter [
	initialDataSource := table dataSource.
	isEditingSemaphore := Semaphore new.
	self spawnFilterUpdateThread
]

{ #category : #'event handling' }
FTFilterFunction >> keyDown: anEvent [
	self isExplicit ifTrue: [ ^false ].
	
	"If the user escape after a search, he want the full data source again so we reinitialize the table."
	(anEvent keyCharacter = Character escape and: [ initialDataSource isNotNil ])
		ifTrue: [ ^ self reinitializeTable ].
	^ false
]

{ #category : #'event handling' }
FTFilterFunction >> keyStroke: anEvent [
	self isExplicit ifTrue: [ ^false ].
	
	self showFilterFieldFromKeystrokeEvent: anEvent.
	^ true
]

{ #category : #updating }
FTFilterFunction >> patternFromString: aString [
	" do not throw an error if the pattern is bad - important in case of auto-accepting"

	^ [ aString asRegexIgnoringCase ]
		on: RegexSyntaxError
		do: [ :ex |  ]
]

{ #category : #initialization }
FTFilterFunction >> reinitializeTable [
	table dataSource: initialDataSource.
	^ true
]

{ #category : #initialization }
FTFilterFunction >> reset [
	"self filter"
]

{ #category : #private }
FTFilterFunction >> showFilterFieldFromKeystrokeEvent: anEvent [
	| text ed |
	text := anEvent keyCharacter asString asText.
	self initializeFilter.
	self filterWith: text.
	ed := RubFloatingEditorBuilder new
		customizeEditorWith: [ :editor | editor bounds: (self table bottomLeft + (0 @ 2) corner: self table bottomRight + (0 @ (editor font height + 6))) ];
		withEditedContentsDo: [ :contents :editor | 
			self filterWith: contents.
			editor setTextWith: (self colorText: contents) ].
	ed autoAccept: true.
	ed whenEditorEscapedDo:[self reinitializeTable ].
	ed openEditorWithContents: (self colorText: text)
]

{ #category : #updating }
FTFilterFunction >> spawnFilterUpdateThread [
	"Runs in background, thank to Henrik Johansen for this"

	[ | oldPattern |
	oldPattern := nil.
	[ isEditingSemaphore wait.
	"If pattern has changed, see if we need to filter.
	If not, it's probably an extraneous signal received while we were waiting for 0.2 seconds, and we discard then till we end up waiting for filterChangeSemaphore again"
	oldPattern ~= pattern
		ifTrue: [ oldPattern := pattern.
			0.2 seconds wait.
			"Pattern still the same? If not, just loop again and end up waiting for another 0.2 secs"
			oldPattern = pattern
				ifTrue: [ self filter ] ] ] repeat ] forkAt: Processor userBackgroundPriority
]

{ #category : #updating }
FTFilterFunction >> textUpdated: anAnnouncement [
	self filterWith: field getTextFromModel
]
