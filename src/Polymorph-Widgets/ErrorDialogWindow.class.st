"
A message dialog with an error icon.
"
Class {
	#name : #ErrorDialogWindow,
	#superclass : #MessageDialogWindow,
	#category : #'Polymorph-Widgets-Windows'
}

{ #category : #icons }
ErrorDialogWindow class >> taskbarIconName [
	"Answer the icon for the receiver in a task bar."

	^#smallErrorIcon
]

{ #category : #accessing }
ErrorDialogWindow >> icon [
	"Answer an icon for the receiver."

	^ self iconNamed: #errorIcon
]
