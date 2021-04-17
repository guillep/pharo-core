Class {
	#name : #KMOSXShortcutPrinter,
	#superclass : #KMShortcutPrinter,
	#category : #'Keymapping-Core-Base'
}

{ #category : #visiting }
KMOSXShortcutPrinter >> basicModifierStringsOf: aShortcut [

	| list |
	list := super basicModifierStringsOf: aShortcut.
	list replaceAll: 'Meta' with: 'Cmd'.
	^ list
]

{ #category : #visiting }
KMOSXShortcutPrinter >> mapSpecialCharacter: char [ 

	char = KeyboardKey enter ifTrue: [ ^ self class symbolTableAt: #Enter ifAbsent: [ 'Enter' ] ].	
	(char = (KeyboardKey fromCharacter: Character space))
		ifTrue: [ ^ self class symbolTableAt: #Space ifAbsent: [ 'Space' ] ].	
	^ char name asUppercase
]

{ #category : #visiting }
KMOSXShortcutPrinter >> visitSingleShortcut: aShortcut [

	| keyParts symbols char |
	keyParts := self shortcutModifiersOf: aShortcut.
	symbols := keyParts inject: '' into: [ :s :each | 
		           s , (self class
			            symbolTableAt: each
			            ifAbsent: [ each capitalized ]) ].
	char := self mapSpecialCharacter: aShortcut platformCharacter.
	^ symbols , char asString
]
