"
A silent sound theme
"
Class {
	#name : #NullSoundTheme,
	#superclass : #SoundTheme,
	#category : #'Polymorph-Widgets-Themes'
}

{ #category : #accessing }
NullSoundTheme class >> themeName [
	"Answer the friendly name of the theme."

	^'No Sounds'
]

{ #category : #initialization }
NullSoundTheme >> defaultDefaultSound [
	"Answer the default default sound!"

	^NullSound
]
