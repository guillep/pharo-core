"
I'm an util to convert a shortcut into the representation used in a platform (they change, as the shortcut themselves are different sometimes)

"
Class {
	#name : #KMShortcutPrinter,
	#superclass : #OSPlatformVisitor,
	#classVars : [
		'SymbolTable'
	],
	#category : #'Keymapping-Core-Base'
}

{ #category : #private }
KMShortcutPrinter class >> createSymbolTable [

	^ Dictionary newFromPairs: { 
		#Cmd. 		(Character value: 16r2318) asString.
		#Meta. 	(Character value: 16r2318) asString.
		#Alt. 		(Character value: 16r2325) asString. 
		#Ctrl.  	(Character value: 16r2303) asString. 
		#Shift. 	(Character value: 16r21E7) asString.
		#Enter. 	(Character value: 16r23ce) asString }
]

{ #category : #private }
KMShortcutPrinter class >> symbolTable [

	^ SymbolTable ifNil: [ SymbolTable := self createSymbolTable ]
]

{ #category : #private }
KMShortcutPrinter class >> symbolTableAt: anObject ifAbsent: aBlock [

	^ self symbolTable 
		at: anObject 
		ifAbsent: aBlock
]

{ #category : #'instance creation' }
KMShortcutPrinter class >> toString: aShortcut [

	^ self new
		shortcut: aShortcut;
		visit
]

{ #category : #private }
KMShortcutPrinter >> basicModifierStringsOf: aShortcut [
		
	^ (aShortcut platformModifier asString substrings: '+') collect: [:each | each trimBoth]
]

{ #category : #visiting }
KMShortcutPrinter >> mapSpecialCharacter: char [ 

	char = KeyboardKey enter ifTrue: [ ^ 'Enter' ].
	char = (KeyboardKey fromCharacter: Character space) ifTrue: [ ^ 'Space' ].
	^ char	 name
]

{ #category : #private }
KMShortcutPrinter >> shortcutModifiersOf: aShortcut [
	| modifiers |
	
	modifiers := self basicModifierStringsOf: aShortcut.
	modifiers replaceAll: 'Meta' with: 'Ctrl'.
	
	"Ensure shift is first"
	((modifiers includes: 'Shift') 
		and: [ modifiers first ~= 'Shift' ])
		ifTrue: [ modifiers := (modifiers copyWithout: 'Shift') copyWithFirst: 'Shift' ].
	
	^ modifiers		
]

{ #category : #visiting }
KMShortcutPrinter >> visitCombinationShortcut: aShortcut [

	^ (aShortcut sequence collect: [ :e | self visitSingleShortcut: e ]) joinUsing: ','
]

{ #category : #visiting }
KMShortcutPrinter >> visitSingleShortcut: aShortcut [

	| char |
	char := self mapSpecialCharacter: aShortcut platformCharacter.
	^ String streamContents: [ :stream | 
		  (self shortcutModifiersOf: aShortcut)
			  do: [ :each | stream << each ]
			  separatedBy: [ stream << '+' ].
		  stream << '+'.
		  stream << char ]
]
