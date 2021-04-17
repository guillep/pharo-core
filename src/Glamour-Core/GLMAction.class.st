"
Actions are elements of behavior that are executed upon a keyboard shortcut or other event.

Instances of Action are stored and maintained by Presentations. The exact representation is determined by the renderer, but actions can define a keyboard shortcut that should trigger the action or a title, category and position to be able to use the action as a context menu item.
"
Class {
	#name : #GLMAction,
	#superclass : #GLMLoggedObject,
	#instVars : [
		'action',
		'title',
		'help',
		'keymap',
		'position',
		'category',
		'icon',
		'condition',
		'enabledCondition',
		'separatorAfter',
		'separatorBefore',
		'shouldShowTitle'
	],
	#category : #'Glamour-Core'
}

{ #category : #'public interface' }
GLMAction >> actOn: aPresentation [ 
	 
	^ self action 
		glamourValueWithArgs: 
			(Array 
				with: aPresentation 
				withAll: aPresentation entity asGlamorousArray)
]

{ #category : #accessing }
GLMAction >> action [ 
	"The code that should be executed when this action is triggered." 
	 
	^action
]

{ #category : #accessing }
GLMAction >> action: aBlock [ 
	"The code that should be executed when this action is triggered. 
 
	The block can take optional arguments, the first will always be the 
	presentation on which this action was triggered." 
	 
	action := aBlock
]

{ #category : #accessing }
GLMAction >> category [ 
	"The name of the category that should be used when this action is displayed in a context menu." 
	 
	^category
]

{ #category : #accessing }
GLMAction >> category: aString [ 
	"The name of the category that should be used when this action is displayed in a context menu." 
	 
	category := aString
]

{ #category : #accessing }
GLMAction >> condition [
	^ condition ifNil: [ true ]
]

{ #category : #accessing }
GLMAction >> condition: anObject [
	condition := anObject
]

{ #category : #printing }
GLMAction >> displayStringOn: stream [
	self hasTitle ifTrue: [
		stream nextPutAll: self title; space ].
	self hasShortcut ifTrue: [
		self keymap displayStringOn: stream.
		stream space ].
	self action displayStringOn: stream
]

{ #category : #accessing }
GLMAction >> enabledCondition [
	^ enabledCondition ifNil: [ true ]
]

{ #category : #accessing }
GLMAction >> enabledCondition: anObject [
	enabledCondition := anObject
]

{ #category : #printing }
GLMAction >> gtDisplayOn: stream [
	self hasTitle ifTrue: [
		stream nextPutAll: self title; space ].
	self hasShortcut ifTrue: [
		self keymap displayStringOn: stream.
		stream space ].
	self action displayStringOn: stream
]

{ #category : #testing }
GLMAction >> hasIcon [
	 
	^self icon notNil
]

{ #category : #testing }
GLMAction >> hasShortcut [ 
	 
	^self keymap notNil
]

{ #category : #testing }
GLMAction >> hasTitle [ 
	 
	^self title notNil
]

{ #category : #accessing }
GLMAction >> help [
	^ help 
]

{ #category : #accessing }
GLMAction >> help: aString [ 
	help := aString
]

{ #category : #accessing }
GLMAction >> icon [
	^ icon
]

{ #category : #accessing }
GLMAction >> icon: anObject [
	icon := anObject
]

{ #category : #accessing }
GLMAction >> iconName: aSymbol [
	"Set the icon whose name is given by the aSymbol"
	self icon: (Smalltalk ui icons iconNamed: aSymbol)
]

{ #category : #testing }
GLMAction >> isAvailableOn: aPresentation [
	^ self condition glamourValueWithArgs: 
			(Array 
				with: aPresentation 
				withAll: aPresentation entity asGlamorousArray)
]

{ #category : #testing }
GLMAction >> isButton [
	^self hasIcon
]

{ #category : #testing }
GLMAction >> isCategorized [
	 
	^self category notNil
]

{ #category : #testing }
GLMAction >> isEnabledOn: aPresentation [
	^ self enabledCondition glamourValueWithArgs: 
			(Array 
				with: aPresentation 
				withAll: aPresentation entity asGlamorousArray)
]

{ #category : #testing }
GLMAction >> isMenu [
	^self hasTitle and: [ self hasIcon not]
]

{ #category : #accessing }
GLMAction >> keymap [

	^ keymap
]

{ #category : #accessing }
GLMAction >> keymap: aKeymap [

	keymap := aKeymap
]

{ #category : #accessing }
GLMAction >> position [ 
	"The relative position within a context menu." 
	 
	^position
]

{ #category : #accessing }
GLMAction >> position: anInteger [ 
	"The relative position within a context menu." 
	 
	position := anInteger
]

{ #category : #rendering }
GLMAction >> renderGlamorouslyOn: aRenderer [
	^aRenderer renderAction: self
]

{ #category : #accessing }
GLMAction >> separatorAfter [
	
	^ separatorAfter ifNil: [ false ]
]

{ #category : #accessing }
GLMAction >> separatorAfter: aBoolean [
	
	separatorAfter := aBoolean
]

{ #category : #accessing }
GLMAction >> separatorBefore [
	
	^ separatorBefore ifNil: [ false ]
]

{ #category : #accessing }
GLMAction >> separatorBefore: aBoolean [
	
	separatorBefore := aBoolean
]

{ #category : #accessing }
GLMAction >> shortcut [ 
	"Shortcut character that this action should be triggered with when the focus rests on the corresponding presentation. 
	Modifiers are platform specific an can not be defined." 
	 
	^ self keymap 
		ifNotNil: [ self keymap currentCharacter ]
]

{ #category : #accessing }
GLMAction >> shortcut: aCharacter [ 
	"Shortcut character that this action should be triggered with when the focus rests on the corresponding presentation. 
	Modifiers are platform specific an can not be defined." 
	 
	aCharacter ifNil: [ 
		keymap := nil.
		^ self ].
	keymap :=  KMModifier meta + aCharacter asKeyCombination

]

{ #category : #accessing }
GLMAction >> shortcutAsString [ 
	"Answers a string explaining shortcut"
	self shortcut ifNil: [ ^ '' ].
	^self keymap printOsRepresentation
]

{ #category : #accessing }
GLMAction >> shouldShowTitle [
	^ shouldShowTitle ifNil: [ shouldShowTitle := false ]
]

{ #category : #accessing }
GLMAction >> shouldShowTitle: anObject [
	shouldShowTitle := anObject
]

{ #category : #accessing }
GLMAction >> showTitle [
	shouldShowTitle := true
]

{ #category : #accessing }
GLMAction >> title [ 
	"Title that this action should use in a context menu." 
	 
	^title
]

{ #category : #accessing }
GLMAction >> title: anObject [ 
	"Title that this action should use in a context menu." 
	 
	title := anObject
]

{ #category : #accessing }
GLMAction >> withSeparatorAfter [

	self separatorAfter: true
]

{ #category : #accessing }
GLMAction >> withSeparatorBefore [

	self separatorBefore: true
]
