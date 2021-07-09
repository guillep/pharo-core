"
This is a helper class that is supposed to be subclassed for each rendering logic of a specific morph. For example, there will be a TreeRenderer, a TextRenderer etc
"
Class {
	#name : #GLMMorphicWidgetRenderer,
	#superclass : #Object,
	#instVars : [
		'renderer'
	],
	#category : #'Glamour-Morphic-Renderer'
}

{ #category : #'instance creation' }
GLMMorphicWidgetRenderer class >> render: aPresentation from: aRenderer [
	^ self new 
		renderer: aRenderer;
		render: aPresentation
]

{ #category : #private }
GLMMorphicWidgetRenderer >> dropDownMenuFrom: aBlock withIcon: anIcon [
	| activeForm passiveForm menuButton | 
	
	activeForm := anIcon.
	passiveForm := anIcon.
	menuButton := MultistateButtonMorph new extent: activeForm extent.
	^ menuButton
		extent: activeForm extent;
				activeEnabledOverUpFillStyle: (ImageFillStyle form: activeForm);
				passiveEnabledOverUpFillStyle: (ImageFillStyle form: activeForm);
				activeEnabledOverDownFillStyle: (ImageFillStyle form: passiveForm);
		passiveEnabledOverDownFillStyle: (ImageFillStyle form: passiveForm);
		addUpAction: aBlock;
		setBalloonText: 'Menu' translated;
		yourself


]

{ #category : #private }
GLMMorphicWidgetRenderer >> installActionsOnModel: aMorphicModel fromPresentation: aPresentation [ 
	aMorphicModel when: GLMMenuItemSelected do: [ :ann | ann action morphicActOn: aPresentation ].
	aMorphicModel when: GLMKeyStroke do: [ :ann | ann action actOn: aPresentation ].
]

{ #category : #rendering }
GLMMorphicWidgetRenderer >> installKeystrokeActionsOnMorph: aMorph fromPresentation: aPresentation [
	aPresentation allActionsWithShortcuts do: [ :each |
		each installKeyCombinationForPresentation: aPresentation onMorph: aMorph ]
]

{ #category : #private }
GLMMorphicWidgetRenderer >> labelActionBrickFor: aPresentation [
	^ aPresentation titleAction
		ifNotNil: [ :labelAction | 
			((labelAction isAvailableOn: aPresentation) and: [ labelAction hasIcon ])
				ifTrue: [ GLMActionButtonBrick new
						icon: labelAction icon;
						setBalloonText: labelAction title;
						action: [ labelAction actOn: aPresentation ] ]
				ifFalse: [ nil ] ]
]

{ #category : #private }
GLMMorphicWidgetRenderer >> labelActionMorphFor: aPresentation [
	^ aPresentation titleAction
		ifNotNil: [ :labelAction | 
			((labelAction isAvailableOn: aPresentation) and: [ labelAction hasIcon ])
				ifTrue: [ MultistateButtonMorph new
						extent: labelAction icon extent;
						activeEnabledOverUpFillStyle: (ImageFillStyle form: labelAction icon);
						setBalloonText: labelAction title;
						addUpAction: [ labelAction actOn: aPresentation ] ]
				ifFalse: [ nil ] ]
]

{ #category : #private }
GLMMorphicWidgetRenderer >> menuIn: aMenuMorph for: aPresentation [
	| subMenus targetMenuMorph subMenu |
	subMenus := Dictionary new.
	(aPresentation allActions select: [:each | each isMenu ]) do: [ :action |
		targetMenuMorph := action category notNil 
			ifTrue: [ subMenus at: action category ifAbsentPut: [ 
					subMenu :=  MenuMorph new.
					aMenuMorph add: action category subMenu: subMenu.
					subMenu ] ]
			ifFalse: [ aMenuMorph ].
		(targetMenuMorph 
			add: action title
			target: action 
			selector: #morphicActOn:
			argument: aPresentation)
			enabled: (action isEnabledOn: aPresentation);
			icon:  action icon;
			keyText: (action hasShortcut 
				ifTrue: [ action shortcutAsString ]
				ifFalse: [ nil ]) ].
	^ aMenuMorph
]

{ #category : #private }
GLMMorphicWidgetRenderer >> moreToolbarActions: noIconActions on: aBrowser [
	| menuMorph |
	menuMorph := MenuMorph new.
	noIconActions do: [ :each | 
		(menuMorph 
			add: each title
			target: each
			selector: #actOn:
			argument: aBrowser)
			enabled: (each isEnabledOn: aBrowser);
 			yourself].
	^ menuMorph
]

{ #category : #private }
GLMMorphicWidgetRenderer >> morph: aMorph withTitleOf: aPresentation [	
	| tabs |
	tabs := LazyTabGroupMorph new.
	tabs
		vResizing: #spaceFill;
		hResizing: #spaceFill;
		cornerStyle: (self theme tabGroupCornerStyleIn: nil);
		font: self theme labelFont.
	self flag: 'add a regular page instead of a lazy one'.
	self flag: 'handle the PresentationChanged announcement to update the label in the morph. 
	The problem is that at the moment I do not know how to link to the label in the tabSelectorMorph'.
	tabs 
		addLazyPage: aMorph
		label: (self titleOrIconOf: aPresentation in: tabs)
		toolbar: (self renderToolbarForPresentation: aPresentation inMorph: aMorph)
		action: (self labelActionBrickFor: aPresentation).
	tabs selectedPageIndex: 1.
	^ tabs
]

{ #category : #private }
GLMMorphicWidgetRenderer >> morph: aMorph withTitleOrNilOf: aPresentation [
	(aPresentation hasTitle or: [aPresentation hasTitleIcon]) ifFalse: [
		"we render at least the toolbar"
		^ self morph: aMorph withToolbarOf: aPresentation ].
	^ self morph: aMorph withTitleOf: aPresentation
]

{ #category : #private }
GLMMorphicWidgetRenderer >> morph: aMorph withToolbarOf: aPresentation [
	| container offset dock |
	aPresentation hasActions
		ifFalse: [ ^ aMorph ].
	container := GLMMorphic containerMorph.
	offset := 0.
	dock := self renderToolbarForPresentation: aPresentation inMorph: container.
	offset := dock minExtent y.
	container
		addMorph: dock
		fullFrame:
			(LayoutFrame identity
				bottomFraction: 0; 
				bottomOffset: offset).
	container addMorph: aMorph fullFrame: (LayoutFrame identity topOffset: offset).
	^ container
]

{ #category : #rendering }
GLMMorphicWidgetRenderer >> render: aPresentation [
	^ self subclassResponsibility 
]

{ #category : #private }
GLMMorphicWidgetRenderer >> renderObject: anObject [
	^ self renderer render: anObject 
]

{ #category : #private }
GLMMorphicWidgetRenderer >> renderToolbarForPresentation: aPresentation inMorph: aMorph [
	| dock buttons |
	
	dock := aMorph theme newToolDockingBarIn: aMorph.
	buttons := self toolbarButtonsForPresentation: aPresentation.
	dock addAllMorphs: buttons.
	(aPresentation allActions select: #isMenu) ifNotEmpty: [
			dock addMorphBack: (self 
				dropDownMenuFrom: [ | menu |
					menu := self menuIn: MenuMorph new for: aPresentation.
					menu popUpEvent: self currentEvent in: aMorph world ]
				withIcon: GLMUIThemeExtraIcons glamorousMore)].
	^ dock
]

{ #category : #private }
GLMMorphicWidgetRenderer >> renderWithTitle: aPresentation [
	| morph |
	morph := self renderObject: aPresentation.
	^ self morph: morph withTitleOf: aPresentation
]

{ #category : #private }
GLMMorphicWidgetRenderer >> renderWithTitleOrNil: aPresentation [
	| morph |
	morph := self renderObject: aPresentation.
	^ self morph: morph withTitleOrNilOf: aPresentation
]

{ #category : #private }
GLMMorphicWidgetRenderer >> renderWithToolbar: aPresentation [
	| presentationMorph |
	presentationMorph := self renderObject: aPresentation.
	^ self morph: presentationMorph withToolbarOf: aPresentation
]

{ #category : #accessing }
GLMMorphicWidgetRenderer >> renderer [
	^ renderer ifNil: [renderer := GLMMorphicRenderer new]
]

{ #category : #accessing }
GLMMorphicWidgetRenderer >> renderer: anObject [
	renderer := anObject
]

{ #category : #private }
GLMMorphicWidgetRenderer >> scrollMorphFor: aMorph [
	^ GeneralScrollPaneMorph new
			changeScrollerTableLayout;
			scrollTarget: aMorph;
			layoutFrame: (LayoutFrame identity topOffset: 25);
			yourself
	
]

{ #category : #factory }
GLMMorphicWidgetRenderer >> theme [
	^ UITheme current
]

{ #category : #private }
GLMMorphicWidgetRenderer >> titleOrIconOf: aPresentation in: container [
	^ aPresentation hasTitleIcon 
		ifTrue: [
			| image |
			image := GLMInteractableBrick new
						normalImage: aPresentation titleIconValue.
			image maxWidth: [ aPresentation titleIconValue width * 2 ].
			image hSpaceFill.
			image vSpaceFill.
			aPresentation titleValue ifNotNil: [
				image setBalloonText: aPresentation titleValue maxLineLength: 100 ].
			image  ]
		ifFalse: [ aPresentation titleValue ifNil: [''] ]
]

{ #category : #private }
GLMMorphicWidgetRenderer >> titleOrIconOrNilOf: aPresentation in: container [

	^ aPresentation hasTitleIcon
		ifTrue: [ | image |

			image := self theme newImageIn: container form: aPresentation titleIconValue.
			aPresentation titleValue
				ifNotNil: [ image setBalloonText: aPresentation titleValue maxLineLength: 10 ]
			]
		ifFalse: [ aPresentation hasTitle
				ifTrue: [ aPresentation titleValue ]
				ifFalse: [ nil ]
			]
]

{ #category : #private }
GLMMorphicWidgetRenderer >> toolbarButtonsForPresentation: aPresentation [

	^ (aPresentation allActions select: [:each | each isButton ]) 
		collect: [:each | |actionMorph|
			actionMorph := (each renderGlamorouslyOn: self renderer).
			actionMorph arguments 
				ifNil: [ actionMorph arguments: { aPresentation } ]
				ifNotNil: [ actionMorph arguments: ({ aPresentation }, actionMorph arguments) ].
			actionMorph ].
	
]
