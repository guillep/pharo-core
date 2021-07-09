"
Dialog style window with no window controls (expand, collapse etc). Usually opened modally (the morph that is used to modally open determines the modal scope, use of World implies ""system modal"").
Designed to be subclassed with content.
Supports Escape key for cancel and Enter key for default button.
"
Class {
	#name : #DialogWindow,
	#superclass : #DialogWindowMorph,
	#category : #'Morphic-Widgets-Windows-Widgets'
}

{ #category : #testing }
DialogWindow class >> isDeprecated [ 
	^ true
]
