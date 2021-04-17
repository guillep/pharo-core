"
KMRepository reset
"
Class {
	#name : #GTSpotterGlobalShortcut,
	#superclass : #KMCategory,
	#category : #'GT-Spotter-UI-Widgets'
}

{ #category : #testing }
GTSpotterGlobalShortcut class >> isGlobalCategory [
	^ true
]

{ #category : #accessing }
GTSpotterGlobalShortcut class >> openGlobalSpotter [

	Smalltalk tools spotter open
]

{ #category : #accessing }
GTSpotterGlobalShortcut class >> openGlobalSpotterDebug [

	GTSpotterMorph new
		extent: (self currentWorld width / 2.25 @ (self currentWorld height / 1.25)) asIntegerPoint;
		spotterModel: (GTSpotter new
			beDebugging;
			yourself);
		openInWindowLabeled: 'Spotter Debug Mode';
		showPreview
]

{ #category : #initialization }
GTSpotterGlobalShortcut class >> reset [
	
	(self currentWorld findA: GTSpotterMorph) ifNotNil: [ :aSpotterMorph | aSpotterMorph spotterModel exitDueTo: #reset ]
]

{ #category : #shortcuts }
GTSpotterGlobalShortcut >> keymapToggle [
	"KMRepository reset"
	<shortcut>
	^ KMKeymap
			shortcut: Character cr shift
			action: [ self class openGlobalSpotter ]
]

{ #category : #shortcuts }
GTSpotterGlobalShortcut >> keymapToggleDebug [
	"KMRepository reset"
	"This shortcut is still using command because the current Virtual Machine interprets Ctrl-cr as a different KEY.
	This should be replaced for #meta as soon as the new VMs are fixed and shipped"
	<shortcut>
	^ KMKeymap
			shortcut: Character cr command shift
			action: [ self class openGlobalSpotterDebug ]
]
