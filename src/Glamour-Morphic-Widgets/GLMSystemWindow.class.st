"
This is the window in which the Glamour browsers are rendered in Morphic.
"
Class {
	#name : #GLMSystemWindow,
	#superclass : #StandardWindow,
	#instVars : [
		'toolbarBox',
		'hasInitialStep'
	],
	#category : #'Glamour-Morphic-Widgets'
}

{ #category : #callbacks }
GLMSystemWindow >> actOnWindowRequest: ann [

	ann action value: self	
]

{ #category : #announcement }
GLMSystemWindow >> allKeystrokeActions [
	^ self model notNil 
		ifTrue: [
			(self model allActions, self model allSelectionActions) select: [ :action | 
				action hasShortcut ]]
		ifFalse: [#()]
]

{ #category : #'open/close' }
GLMSystemWindow >> delete [
	self model notNil ifTrue: [self model unregisterFromAllAnnouncements].
	super delete
]

{ #category : #building }
GLMSystemWindow >> extent: aPoint [ 
	super extent: aPoint.
	self fullBounds
]

{ #category : #'event handling' }
GLMSystemWindow >> handleKeyStroke: anEvent [

	self allKeystrokeActions
		detect:
			[ :a | anEvent commandKeyPressed and: [ a shortcut = anEvent keyCharacter ] ]
		ifFound: [ :action | self announcer announce: (GLMKeyStroke action: action) ]
]

{ #category : #initialization }
GLMSystemWindow >> initialize [ 
	super initialize.
	self
		on: #keyStroke 
		send: #handleKeyStroke: 
		to: self.
	hasInitialStep := false
]

{ #category : #accessing }
GLMSystemWindow >> setLabelWidgetAllowance [
	^ labelWidgetAllowance :=  super setLabelWidgetAllowance +
		(toolbarBox
			ifNil: [ 0 ]
			ifNotNil: [ :toolbar | toolbarBox width ])
]

{ #category : #stepping }
GLMSystemWindow >> stepAt: millisecondClockValue [
	"An alarm will also be fired the first time the window is opened, 
	even if stepTime was not reached. Ignore the very first step."
	hasInitialStep ifFalse: [ 
		hasInitialStep := true.
		^ self ].
	super stepAt: millisecondClockValue
]

{ #category : #stepping }
GLMSystemWindow >> stepTime [
	^ self model stepTime
]

{ #category : #accessing }
GLMSystemWindow >> toolbarBox: anObject [
	| previousToolbar |
	
	previousToolbar := toolbarBox ifNil: [ menuBox ].
	
	toolbarBox := anObject.
	self setLabelWidgetAllowance.
	self replacePane: previousToolbar with: toolbarBox
]

{ #category : #stepping }
GLMSystemWindow >> wantsSteps [
	^ self model wantsSteps
]

{ #category : #announcement }
GLMSystemWindow >> when: anAnnouncement do: aBlock [ 
	^ self announcer when: anAnnouncement do: aBlock
]
