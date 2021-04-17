"
I'm a generic shortcut text to be shown in amenu item. 
I'm generic because there are different strategies to be shown: 

1) Macs want to show symbols (like those weird command and option symbols)
2) Windows wants to show  them as ""Alt + Shift + Something""
3) Linux can live with windows scheme

So, my subclasses implements text and symbol strategies. 

IMPORTANT:  I'm assuming the two current existing keyText ""disposition"" in system: 
- the ""old style"": just the letters, like 'o, t' or 'b'
- the ""full style"" (which is in part my fault, from some years ago): something like 'cmd+shift+O+T'.
I format those imputs into something similar (check #expand: method for better explanation).
"
Class {
	#name : #ToggleMenuItemShortcut,
	#superclass : #DisplayableObject,
	#instVars : [
		'keyText',
		'owner',
		'color'
	],
	#category : #'Morphic-Base-Menus'
}

{ #category : #testing }
ToggleMenuItemShortcut class >> canBeUsed [
	^ false
]

{ #category : #private }
ToggleMenuItemShortcut class >> keyTextShortcuts [
	^ #('cmd'. 'alt'. 'shift'.'ctrl'. 'meta' '⌘' '⇧')
]

{ #category : #'instance creation' }
ToggleMenuItemShortcut class >> new [ 
	self error: 'Use #owner:keyText:'
]

{ #category : #private }
ToggleMenuItemShortcut class >> normalize: aString [
	"This is a hack to show better explained menu commands. 
	 WARNING: This is now really good, but is an easy and fast way to enhance accesibility of 
	 menu commands."

	self keyTextShortcuts do: [ :each |
		(aString includesSubstring: each caseSensitive: false)
			ifTrue: [ ^ self normalizeFullStyle: aString ] ].   
	^ self normalizeCondensedStyle: aString
]

{ #category : #private }
ToggleMenuItemShortcut class >> normalizeCondensedStyle: aString [
	"Assuming a keyText 'Old Style': the menu keys will come as 'o, k'"

	^ String streamContents: [ :stream | | keys |
		keys := (aString substrings: ',') collect: [ :each | each trimBoth ].
		stream << OSPlatform current menuShortcutString capitalized << '+'.
		keys 
			do: [ :each | 
			(each first isUppercase) ifTrue: [ stream << 'Shift+' ].
			stream << each asLowercase capitalized ]
			separatedBy: [ stream << '+' ] ]
]

{ #category : #private }
ToggleMenuItemShortcut class >> normalizeFullStyle: aString [
	"Assuming is a keytext with the format: 'cmd+shift+something'"

	^ String streamContents: [ :stream | 
			((aString substrings: '+') collect: [:each | each trimBoth])
				do: [ :each | stream << (each asLowercase capitalized) ]
				separatedBy: [ stream << '+' ] ]
]

{ #category : #'instance creation' }
ToggleMenuItemShortcut class >> owner: aMenuItem keyText: aString [
	^ self shortcutClass basicNew 
		initializeOwner: aMenuItem keyText: aString;
		yourself
]

{ #category : #accessing }
ToggleMenuItemShortcut class >> priority [
	^ self subclassResponsibility
]

{ #category : #private }
ToggleMenuItemShortcut class >> shortcutClass [
	"Answers first class that can be used. 
	 WARNING: Note than for speed I'm using #subclasses instead #allSubclasses, avoiding the scan of 
	 the hierarchy. This will not work if we extend the hierarchy more than one level"
	^ (self subclasses sorted: [ :a :b | a priority < b priority ])
		detect: #canBeUsed
]

{ #category : #private }
ToggleMenuItemShortcut >> boundsForKeyText: aString font: aFont [
	| ktp ktw b |
	
	ktp := self owner hasSubMenu
		ifTrue: [ self owner right - self owner subMenuMarker width ]
		ifFalse: [ self owner right ].
	ktp := ktp - (ktw := aFont widthOfString: aString).
	b := ktp @ ((self owner bounds top + self owner bounds bottom - aFont height) // 2) extent: ktw @ self owner height.
	^ b
]

{ #category : #accessing }
ToggleMenuItemShortcut >> color [

	^ color ifNil: [ self theme ghostTextColor ]
]

{ #category : #accessing }
ToggleMenuItemShortcut >> color: aColor [

	color := aColor
]

{ #category : #drawing }
ToggleMenuItemShortcut >> drawOn: aCanvas [
	self subclassResponsibility
]

{ #category : #initialization }
ToggleMenuItemShortcut >> initializeOwner: aMenuItem keyText: aString [
	self initialize.
	owner := aMenuItem.
	keyText := self class normalize: aString
]

{ #category : #accessing }
ToggleMenuItemShortcut >> keyText [
	^ keyText
]

{ #category : #accessing }
ToggleMenuItemShortcut >> owner [
	^ owner
]
