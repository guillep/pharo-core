Extension { #name : #SystemWindow }

{ #category : #'*Morphic-Widgets-Taskbar' }
SystemWindow >> basicTaskThumbnailOfSize: thumbExtent [
	"Answer a new task thumbnail for the receiver."
	
	^super taskThumbnailOfSize: thumbExtent
]

{ #category : #'*Morphic-Widgets-Taskbar' }
SystemWindow >> isTaskbarPresent [
	"Answer whether there is a taskbar in the world."

	^self worldTaskbar notNil
]

{ #category : #'*Morphic-Widgets-Taskbar' }
SystemWindow >> minimizeAfterGeneratingThumbnail [
	"Minimize the window after thumbnail generation."
	
	self isMinimized ifTrue: [^self].
	isCollapsed := true.
	paneMorphs
		do: [:m | m delete; releaseCachedState].
	self setBoundsWithFlex: (-10 @ -10 extent: 2 @ 2).
	self hide.
	self layoutChanged
	
]

{ #category : #'*Morphic-Widgets-Taskbar' }
SystemWindow >> restoreBeforeGeneratingThumbnail [
	"Restore the window without activating unlocking or stepping."
	
	self isMinimized ifFalse: [^self].
	isCollapsed := false.
	self show.
	self setBoundsWithFlex: fullFrame.
	paneMorphs reverseDo: [:m | 
		self addMorph: m].
	self layoutChanged
]

{ #category : #'*Morphic-Widgets-Taskbar' }
SystemWindow >> taskThumbnailOfSize: thumbExtent [
	"Answer a new task thumbnail for the receiver."
	
	|min thumb|
	min := self isMinimized
		ifTrue: [self restoreBeforeGeneratingThumbnail.
				true]
		ifFalse: [false].
	thumb := self basicTaskThumbnailOfSize: thumbExtent.
	min ifTrue: [self minimizeAfterGeneratingThumbnail].
	^thumb
]

{ #category : #'*Morphic-Widgets-Taskbar' }
SystemWindow >> taskbarButtonClicked [
	"The taskbar button for the receiver has been clicked.
	If minimised then restore.
	If active then minimize.
	Otherwise make active."

	self isMinimized
		ifTrue: [self restore]
		ifFalse: [self isActive
					ifTrue: [self minimize]
					ifFalse: [self activate]]
]

{ #category : #'*Morphic-Widgets-Taskbar' }
SystemWindow >> taskbarButtonEntered: aButton event: evt in: aMorph [
	"The mouse has entered out taskbar button.
	Show a thumbnail."

	aButton owner ifNotNil: [:buttonBar | |thumb|
		buttonBar showWindowPreview ifFalse: [^self].
		thumb := self valueOfProperty: #taskbarThumbnail.
		thumb
			ifNil: [thumb := self theme newTaskbarThumbnailIn: self for: self]
			ifNotNil: [^self].
		self setProperty: #taskbarThumbnail toValue: thumb.
		thumb bottomLeft: ((aButton left min: aButton owner right - thumb width)@ (aButton owner top - 4)).
		thumb openInWorld]
]

{ #category : #'*Morphic-Widgets-Taskbar' }
SystemWindow >> taskbarButtonFor: aTaskbar [
	"Answer a new task bar button for the receiver.
	Answer nil if not required."

	^aTaskbar theme
		newTaskbarButtonIn: aTaskbar
		for: self
]

{ #category : #'*Morphic-Widgets-Taskbar' }
SystemWindow >> taskbarButtonLeft: aButton event: evt in: aMorph [
	"The mouse has left our taskbar button.
	Remove our thumbnail."

	self
		valueOfProperty: #taskbarThumbnail
		ifPresentDo: [:thumb |
			thumb delete.
			self removeProperty: #taskbarThumbnail]
]

{ #category : #'*Morphic-Widgets-Taskbar' }
SystemWindow >> taskbarButtonMenu: aMenu [
	"Answer the menu for the task bar button."

	| menu theme submenu  |
	theme :=  self theme.	
	menu := theme newMenuIn: self for: self.
	
	menu
		addToggle: 'Restore' translated
		target: self
		selector: #restore
		getStateSelector: nil
		enablementSelector: #isNotRestored.
	menu lastItem
		icon: self theme windowMaximizeForm;
		font: theme menuFont.
		
	menu
		addToggle: 'Minimize' translated
		target: self
		selector: #minimize
		getStateSelector: nil
		enablementSelector: #isNotMinimized.
	menu lastItem
		icon: self theme windowMinimizeForm;
		font: theme menuFont.
		
	menu
		addToggle: 'Maximize' translated
		target: self
		selector: #maximize
		getStateSelector: nil
		enablementSelector: #canBeMaximized.
	menu lastItem
		icon: self theme windowMaximizeForm;
		font: theme menuFont.
		
	menu addLine.

	submenu := theme newMenuIn: self for: self.
	menu
		add: 'Close all'
		icon: self theme windowCloseForm
		subMenu: submenu.
	submenu
		addToggle: 'windows to left' translated
		target: self
		selector: #taskbarCloseAllToLeft
		getStateSelector: nil
		enablementSelector: true.
	submenu
		addToggle: 'windows to right' translated
		target: self
		selector: #taskbarCloseAllToRight
		getStateSelector: nil
		enablementSelector: true.
	submenu
		addToggle: 'windows like this' translated
		target: self
		selector: #taskbarCloseAllLikeThis
		getStateSelector: nil
		enablementSelector: true.
	submenu
		addToggle: 'unchanged windows' translated
		target: self currentWorld
		selector: #closeAllUnchangedWindows
		getStateSelector: nil
		enablementSelector: true.
	submenu
		addToggle: 'close all debuggers' translated
		target: OupsDebuggerSystem
		selector: #closeAllDebuggers
		getStateSelector: nil
		enablementSelector: true.

	menu
		addToggle: 'Close' translated
		target: self
		selector: #closeBoxHit
		getStateSelector: nil
		enablementSelector: #allowedToClose.
	menu lastItem
		icon: self theme windowCloseForm;
		font: theme menuFont.

	^menu
]

{ #category : #'*Morphic-Widgets-Taskbar' }
SystemWindow >> taskbarCloseAllLikeThis [

	(SystemWindow allSubInstances select: [ :w | w labelString = self labelString]) do: [ :w | w delete ].
]

{ #category : #'*Morphic-Widgets-Taskbar' }
SystemWindow >> taskbarCloseAllToLeft [
	| wasFound |
	wasFound := false.
	self worldTaskbar ifNotNil: [ :worldTaskbar |
		worldTaskbar orderedTasks copy do: [ :task | 
			(task morph == self) ifTrue: [ ^ self ].
			task morph delete ] ].
]

{ #category : #'*Morphic-Widgets-Taskbar' }
SystemWindow >> taskbarCloseAllToRight [
	| wasFound |
	wasFound := false.
	self worldTaskbar ifNotNil: [ :worldTaskbar |
		worldTaskbar orderedTasks copy do: [ :task | 
			wasFound 
				ifTrue:  [ task morph delete ] 
				ifFalse: [ wasFound := task morph == self ].
			]. 
		].
]

{ #category : #'*Morphic-Widgets-Taskbar' }
SystemWindow >> taskbarLabel [
	"Answer the label to use for a taskbar button for the receiver."

	self model ifNotNil: [self model taskbarLabel ifNotNil: [:str | ^str]].
	^self labelString
]

{ #category : #'*Morphic-Widgets-Taskbar' }
SystemWindow >> taskbarState [
	"Answer one of #minimized, #restored, #maximized or #active."

	^self isMinimized
		ifTrue: [#minimized]
		ifFalse: [self isMaximized
			ifTrue: [#maximized]
			ifFalse: [self isActive
						ifTrue: [#active]
						ifFalse: [#restored]]]
]

{ #category : #'*Morphic-Widgets-Taskbar' }
SystemWindow >> taskbarTask [
	"Answer a new taskbar task for the receiver.
	Answer nil if not required."

	(self valueOfProperty: #noTaskbarTask ifAbsent: [false]) ifTrue: [^nil].
	^TaskbarTask
		morph: self
		state: self taskbarState
		icon: self taskbarIcon
		label: self taskbarLabel
]

{ #category : #'*Morphic-Widgets-Taskbar' }
SystemWindow >> taskbarThumbnailExtent [
	"Answer the size of a taskbar thumbnail for the receiver."

	^self isMinimized
		ifTrue: [self fullFrame extent min: self defaultTaskbarThumbnailExtent]
		ifFalse: [super taskbarThumbnailExtent]
]

{ #category : #'*Morphic-Widgets-Taskbar' }
SystemWindow >> worldTaskbar [
	"Answer the world taskbar or nil if none."

	^self world ifNotNil: [ :world | 
		world 
		submorphThat: [ :morph | morph isTaskbar ] 
		ifNone: [ nil ]
	] 
]
