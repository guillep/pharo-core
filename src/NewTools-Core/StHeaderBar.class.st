"
I am a generic header bar for tool component panels. 
I am used to add title, a toolbar and shortcut used to get to the panel.
"
Class {
	#name : #StHeaderBar,
	#superclass : #SpPresenter,
	#instVars : [
		'titleLabel',
		'toolbar',
		'closeButton',
		'shortcutLabel'
	],
	#category : #'NewTools-Core-Presenters'
}

{ #category : #specs }
StHeaderBar class >> defaultSpec [

	^ SpBoxLayout newHorizontal
		beNotHomogeneous;
		borderWidth: 3;
		spacing: 3;
		"add: #closeButton expand: false;"
		add: #titleLabel expand: false;
		add: #shortcutLabel expand: false;
		addLast: #toolbar expand: false;
		yourself
]

{ #category : #accessing }
StHeaderBar >> beCloseable [

	self isCloseable ifTrue: [ ^ self ].
	self enableCloseDoing: [  ]
]

{ #category : #accessing }
StHeaderBar >> beNotCloseable [

	closeButton ifNil: [ ^ self ].
	
	layout remove: closeButton.
	closeButton := nil
]

{ #category : #private }
StHeaderBar >> enableCloseDoing: aBlock [

	closeButton := self newButton
		addStyle: 'small';
		icon: (self application iconNamed: #glamorousClose);
		action: aBlock;
		yourself.
		
	layout addLast: closeButton expand: false
]

{ #category : #initialization }
StHeaderBar >> initializePresenters [

	self layout: (SpBoxLayout newHorizontal
		beNotHomogeneous;
		borderWidth: 3;
		spacing: 3;
		add: (titleLabel := self newLabel) expand: false;
		add: (shortcutLabel := self newLabel) expand: false;
		addLast: (toolbar := self newToolbar) expand: false;
		yourself).

	shortcutLabel addStyle: 'shortcut'.
	"toolbar displayMode: self application toolbarDisplayMode"
	toolbar beIcons	"is a mini toolbar, items should be... tiny :)"
]

{ #category : #testing }
StHeaderBar >> isCloseable [

	^ closeButton notNil
]

{ #category : #accessing }
StHeaderBar >> label: aString [

	titleLabel label: aString
]

{ #category : #accessing }
StHeaderBar >> shortcut: aShortcut [ 

	self shortcutLabel: (aShortcut asKeyCombination acceptVisitor: OSPlatform current shortcutPrinter	)
]

{ #category : #private }
StHeaderBar >> shortcutLabel: aString [ 

	shortcutLabel label: aString
]

{ #category : #accessing }
StHeaderBar >> toolbarActions: aCommandGroup [

	toolbar removeAllItems.
	SpToolbarPresenterBuilder new 
		toolbarPresenter: toolbar;
		visit: aCommandGroup
]

{ #category : #events }
StHeaderBar >> whenClosedDo: aBlock [

	self isCloseable ifFalse: [ self enableCloseDoing: aBlock ].
	closeButton action: aBlock
]
