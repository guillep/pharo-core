"
I show a menu as a text. 
I'm the simplest mechanism and then, the default.
"
Class {
	#name : #ToggleWithTextMenuItemShortcut,
	#superclass : #ToggleMenuItemShortcut,
	#category : #'Morphic-Base-Menus'
}

{ #category : #testing }
ToggleWithTextMenuItemShortcut class >> canBeUsed [
	"this is the default and is available as default to all platforms"
	^ true
]

{ #category : #accessing }
ToggleWithTextMenuItemShortcut class >> priority [
	"Lowest priority... last to be choosen"
	^ 999
]

{ #category : #drawing }
ToggleWithTextMenuItemShortcut >> drawOn: aCanvas [
	| keyBounds |
	
	keyBounds := self boundsForKeyText: self keyText font: self owner fontToUse.
	self owner
		drawText: keyText
		on: aCanvas
		in: keyBounds
		color: self color
]

{ #category : #accessing }
ToggleWithTextMenuItemShortcut >> text [

	^ keyText
]
