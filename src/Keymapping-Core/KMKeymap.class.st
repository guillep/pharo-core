"
I am the real keymap.  I have an action to evaluate when my keymap sequence is pressed.
"
Class {
	#name : #KMKeymap,
	#superclass : #Object,
	#instVars : [
		'action',
		'name',
		'shortcut',
		'defaultShortcut',
		'description'
	],
	#category : #'Keymapping-Core-Base'
}

{ #category : #'instance creation' }
KMKeymap class >> named: keymapName shortcut: aShortcut action: anAction [
	^ (self new)
		name: keymapName;
		defaultShortcut: aShortcut;
		shortcut: aShortcut;
		action: anAction;
		yourself
]

{ #category : #'instance creation' }
KMKeymap class >> named: keymapName shortcut: aShortcut action: anAction description: aDescription [
	^ (self new)
		name: keymapName;
		defaultShortcut: aShortcut;
		shortcut: aShortcut;
		action: anAction;
		description: aDescription;
		yourself
]

{ #category : #'instance creation' }
KMKeymap class >> shortcut: aShortcut action: anAction [
	^ (self new)
		defaultShortcut: aShortcut;
		shortcut: aShortcut;
		action: anAction;
		yourself
]

{ #category : #comparing }
KMKeymap >> = aKeymap [
	self == aKeymap
		ifTrue: [ ^ true ].
	self species = aKeymap species
		ifFalse: [ ^ false ].
	^action = aKeymap action and: [ shortcut = aKeymap shortcut and: [ name = aKeymap name ] ]
]

{ #category : #accessing }
KMKeymap >> action [
	^ action
]

{ #category : #accessing }
KMKeymap >> action: anAction [
	action := anAction
]

{ #category : #accessing }
KMKeymap >> defaultShortcut [
	^defaultShortcut
]

{ #category : #accessing }
KMKeymap >> defaultShortcut: aShortcut [
	defaultShortcut := aShortcut.
]

{ #category : #accessing }
KMKeymap >> description [
	^description ifNil: [ '' ]
]

{ #category : #accessing }
KMKeymap >> description: aDescription [
	description := aDescription asString
]

{ #category : #printing }
KMKeymap >> displayStringOn: aStream [
	aStream 
		nextPutAll: self name displayString;
		nextPutAll: ' on ';
		nextPutAll: self shortcut displayString;
		nextPutAll: ' do ' ;
		nextPutAll: self action displayString
]

{ #category : #executing }
KMKeymap >> executeActionTargetting: target [
	^ self action cull: target cull: target
]

{ #category : #accessing }
KMKeymap >> hasName [
	^name notNil
]

{ #category : #comparing }
KMKeymap >> hash [
	^action hash bitXor: (shortcut hash bitXor: name hash)
]

{ #category : #accessing }
KMKeymap >> key [
	^ name
]

{ #category : #matching }
KMKeymap >> matches: anEventBuffer [

	^ anEventBuffer
		ifEmpty: [ false ]
		ifNotEmpty: [ self shortcut matches: anEventBuffer ]
]

{ #category : #matching }
KMKeymap >> matchesCompletely: aShortcut [
	^ self shortcut matchesCompletely: aShortcut
]

{ #category : #accessing }
KMKeymap >> name [
	^ name
]

{ #category : #accessing }
KMKeymap >> name: aName [
	name := aName
]

{ #category : #matching }
KMKeymap >> notifyCompleteMatchTo: aListener buffer: aBuffer [
	| listeners |
	aListener isCollection ifTrue: [ listeners := aListener ] ifFalse: [ listeners := { aListener } ].
	listeners do: [ :l | l completeMatch: self buffer: aBuffer ].
]

{ #category : #matching }
KMKeymap >> notifyPartialMatchTo: aListener [
	| listeners |

	listeners := aListener isCollection 
		ifTrue: [ aListener ] 
		ifFalse: [ { aListener } ].
	listeners do: [ :each | each partialMatch ]
]

{ #category : #matching }
KMKeymap >> onMatchWith: anEventBuffer notify: aMatchListener andDo: anAction [
	(self matches: anEventBuffer)
			ifTrue: [ 
				(self matchesCompletely: anEventBuffer)
					ifTrue: [ self notifyCompleteMatchTo: aMatchListener buffer: anEventBuffer ]
					ifFalse: [ self notifyPartialMatchTo: aMatchListener ].
					anAction value.
				] 
]

{ #category : #printing }
KMKeymap >> printOn: aStream [
	aStream 
		print: self name ;
		nextPutAll: ' on ';
		print: self shortcut ;
		nextPutAll: ' do ' ;
		print: self action ;
		cr.    
]

{ #category : #initialization }
KMKeymap >> reset [

	self shortcut: self defaultShortcut.
]

{ #category : #accessing }
KMKeymap >> shortcut [
	^ shortcut
]

{ #category : #accessing }
KMKeymap >> shortcut: aShortcut [
	shortcut := aShortcut.
]

{ #category : #accessing }
KMKeymap >> shortcutHasChangedBy: aShortcut [
	self defaultShortcut = self shortcut ifTrue: [ self shortcut: aShortcut ].
	self defaultShortcut: aShortcut
]
