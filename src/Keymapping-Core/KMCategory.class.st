"
I am a keymap category.  I represent a set of keymaps that can be attached to a morph, so morphs can share my keymaps.
"
Class {
	#name : #KMCategory,
	#superclass : #Object,
	#instVars : [
		'name',
		'platforms'
	],
	#category : #'Keymapping-Core-Categories'
}

{ #category : #'instance creation' }
KMCategory class >> named: aCategorySymbol [
	^ (self new)
		name: aCategorySymbol;
		yourself
]

{ #category : #associating }
KMCategory >> addKeymapEntry: aKeymapEntry [ 
	self commonEntries add: aKeymapEntry.
]

{ #category : #associating }
KMCategory >> addKeymapEntry: aKeymapEntry at: aPlatform [
	(self entriesAt: aPlatform) add: aKeymapEntry
]

{ #category : #associating }
KMCategory >> allEntries [
	^self commonEntries, self platformEntries
]

{ #category : #binding }
KMCategory >> asKmCategoryIn: aKmRepository [

	"Maybe we should validate we exist in the repository?"
	^ self
]

{ #category : #binding }
KMCategory >> bindToObject: anObject andMorph: aMorph [
	
	^ KMCategoryBinding target: anObject morph: aMorph category: self.
]

{ #category : #initialization }
KMCategory >> buildKeymapOnMethod: method [

	self addKeymapEntry: (self perform: method selector)
]

{ #category : #accessing }
KMCategory >> categoryName [
	^ name
]

{ #category : #associating }
KMCategory >> commonEntries [
	^self entriesAt: #all
]

{ #category : #printing }
KMCategory >> displayStringOn: stream [
	super displayStringOn: stream.
	^ stream
		nextPut: $(;
		nextPutAll: self name asString;
		nextPut: $)
]

{ #category : #accessing }
KMCategory >> entriesAt: aPlatform [
	platforms ifNil: [ platforms := Dictionary new ].
	^platforms at: aPlatform ifAbsentPut: [ KMStorage new ].
]

{ #category : #associating }
KMCategory >> hasKeymapNamed: aKeymapEntryName [
	^self allEntries hasKeymapNamed: aKeymapEntryName
]

{ #category : #associating }
KMCategory >> hasKeymapNamed: aKeymapEntryName at: aPlatform [
	^ (self entriesAt: aPlatform) hasKeymapNamed: aKeymapEntryName
]

{ #category : #initialization }
KMCategory >> initialize [

	super initialize.
	self class methods
		select: [ :m | m isShortcutDeclaration ]
		thenDo: [ :m | self buildKeymapOnMethod: m ]
]

{ #category : #binding }
KMCategory >> installAsGlobalCategory [

	KMRepository default setAsGlobalCategory: self
]

{ #category : #binding }
KMCategory >> keymapForShortcut: aShortcut [

	^ self allEntries keymapForShortcut: aShortcut
]

{ #category : #associating }
KMCategory >> keymapNamed: aKeymapEntryName [
	^self allEntries keymapNamed: aKeymapEntryName
]

{ #category : #associating }
KMCategory >> keymapNamed: aKeymapEntryName at: aPlatform [
	^(self entriesAt: aPlatform) keymapNamed: aKeymapEntryName
]

{ #category : #accessing }
KMCategory >> keymaps [
	^self allEntries keymaps
]

{ #category : #testing }
KMCategory >> matches: aString [
	^ self keymaps anySatisfy: [ :entry | 
		entry matches: aString ]
]

{ #category : #testing }
KMCategory >> matchesCompletely: aString [
	^ self keymaps anySatisfy: [ :entry | 
		entry matchesCompletely: aString ]
]

{ #category : #accessing }
KMCategory >> name [
	^ name
]

{ #category : #accessing }
KMCategory >> name: aCategorySymbol [ 
	name := aCategorySymbol 
]

{ #category : #matching }
KMCategory >> onMatchWith: anEventBuffer notify: aMatchListener andDo: aBlock [
	self keymaps do: [ :entry | 
		entry onMatchWith: anEventBuffer 
			notify: aMatchListener 
			andDo: aBlock ].
]

{ #category : #associating }
KMCategory >> platformEntries [
	^self entriesAt: Smalltalk os platformFamily
]

{ #category : #associating }
KMCategory >> removeKeymapEntry: aKeymapEntry [

	[ self commonEntries remove: aKeymapEntry ] 
	on: Error
	do: [ self platformEntries remove: aKeymapEntry ]
]
