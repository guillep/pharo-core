"
I'm a pager control used to navigate in a MorphTreeMorph that has a lot of entries.

You can see one of my subclass in action using:
""May take a while to open""
ClassListExample new open
"
Class {
	#name : #TreeNavigationBarMorph,
	#superclass : #BorderedMorph,
	#instVars : [
		'treeMorph',
		'pageSize',
		'computedHeight',
		'withSearch',
		'pageSearchText'
	],
	#category : #'Morphic-Widgets-Tree-Pagination'
}

{ #category : #icons }
TreeNavigationBarMorph class >> createIconMethods [
	"self createIconMethods"
	#('smallToLeft' 'smallToRight' 'smallToLeftEnd' 'smallToRightEnd' 'smallDieze' 'smallVerticalResizing')
		do: [:n | | form |
			form := PNGReadWriter formFromFileNamed: n, '.png'.
			self class compile: (n, 'Icon', String cr, String tab, '^ ', form storeString) classified: #icons]
]

{ #category : #'instance creation' }
TreeNavigationBarMorph class >> on: aTreeMorph pageSize: aPageSize [
	^ self new treeMorph: aTreeMorph  pageSize: aPageSize
]

{ #category : #icons }
TreeNavigationBarMorph class >> smallDiezeIcon [
	^ (Form
	extent: 16@16
	depth: 32
	fromArray: #( 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4279173376 4279173376 0 0 4279173376 4279173376 0 0 0 0 0 0 0 0 0 0 4279173376 0 0 0 4279173376 0 0 0 0 0 0 0 0 0 0 0 4279173376 0 0 0 4279173376 0 0 0 0 0 0 0 0 0 0 0 4279173376 0 0 0 4279173376 0 0 0 0 0 0 0 4279173376 4279173376 4279173376 4279173376 4279173376 4279173376 4279173376 4279173376 4279173376 4279173376 4279173376 0 0 0 0 0 0 0 0 4279173376 4279173376 4279173376 0 4279173376 4279173376 0 0 0 0 0 0 0 0 0 0 4279173376 0 0 0 4279173376 0 0 0 0 0 0 0 0 0 0 0 4279173376 0 0 0 4279173376 0 0 0 0 0 0 0 0 4279173376 4279173376 4279173376 4279173376 4279173376 4279173376 4279173376 4279173376 4279173376 4279173376 4279173376 0 0 0 0 0 0 0 4279173376 4279173376 4279173376 0 4279173376 4279173376 0 0 0 0 0 0 0 0 0 0 4279173376 4279173376 0 0 4279173376 4279173376 0 0 0 0 0 0 0 0 0 0 4279173376 0 0 0 4279173376 0 0 0 0 0 0 0 0 0 0 0 4279173376 0 0 0 4279173376 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
	offset: 0@0)
]

{ #category : #icons }
TreeNavigationBarMorph class >> smallToLeftEndIcon [
	^ (Form
	extent: 16@16
	depth: 32
	fromArray: #( 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4279173376 4287401100 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4279173376 4287401100 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4279173376 4287401100 0 0 0 0 4278190080 4278190080 4278190080 0 0 0 0 0 0 0 4279173376 4287401100 0 0 0 4278190080 4287401100 4287401100 4278190080 0 0 0 0 0 0 0 4279173376 4287401100 0 0 4278190080 4287401100 4287401100 4287401100 4287401100 4278190080 0 0 0 0 0 0 4279173376 4287401100 0 4278190080 4287401100 4287401100 4287401100 4287401100 4287401100 4291151301 4278190080 4278190080 4278190080 4278190080 4278190080 4278190080 4279173376 4287401100 4278190080 4287401100 4287401100 4287401100 4287401100 4287401100 4287401100 4291151301 4291151301 4291151301 4291151301 4291151301 4291151301 4278190080 4279173376 4287401100 4278190080 4287401100 4287401100 4287401100 4287401100 4287401100 4287401100 4287401100 4287401100 4287401100 4291151301 4291151301 4291151301 4278190080 4279173376 4287401100 4278190080 4287401100 4287401100 4287401100 4287401100 4287401100 4287401100 4291151301 4291151301 4291151301 4291151301 4291151301 4291151301 4278190080 4279173376 4287401100 0 4278190080 4287401100 4287401100 4287401100 4287401100 4287401100 4291151301 4278190080 4278190080 4278190080 4278190080 4278190080 4278190080 4279173376 4287401100 50353408 0 4278190080 4287401100 4287401100 4287401100 4287401100 4278190080 0 0 0 0 0 0 4279173376 4287401100 0 0 0 4278190080 4287401100 4287401100 4278190080 0 0 0 0 0 0 0 4279173376 4287401100 0 0 0 0 4278190080 4278190080 4278190080 0 0 0 0 0 0 0 4279173376 4287401100 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4279173376 4287401100 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
	offset: 0@0)
]

{ #category : #icons }
TreeNavigationBarMorph class >> smallToLeftIcon [
	^ (Form
	extent: 16@16
	depth: 32
	fromArray: #( 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4278190080 4278190080 4278190080 0 0 0 0 0 0 0 0 0 0 0 0 4278190080 4287401100 4287401100 4278190080 0 0 0 0 0 0 0 0 0 0 0 4278190080 4287401100 4287401100 4287401100 4287401100 4278190080 0 0 0 0 0 0 0 0 0 4278190080 4287401100 4287401100 4287401100 4287401100 4287401100 4291151301 4278190080 4278190080 4278190080 4278190080 4278190080 4278190080 0 0 4278190080 4287401100 4287401100 4287401100 4287401100 4287401100 4287401100 4291151301 4291151301 4291151301 4291151301 4291151301 4291151301 4278190080 0 0 4278190080 4287401100 4287401100 4287401100 4287401100 4287401100 4287401100 4287401100 4287401100 4287401100 4291151301 4291151301 4291151301 4278190080 0 0 4278190080 4287401100 4287401100 4287401100 4287401100 4287401100 4287401100 4291151301 4291151301 4291151301 4291151301 4291151301 4291151301 4278190080 0 0 0 4278190080 4287401100 4287401100 4287401100 4287401100 4287401100 4291151301 4278190080 4278190080 4278190080 4278190080 4278190080 4278190080 0 0 50353408 0 4278190080 4287401100 4287401100 4287401100 4287401100 4278190080 0 0 0 0 0 0 0 0 0 0 0 4278190080 4287401100 4287401100 4278190080 0 0 0 0 0 0 0 0 0 0 0 0 0 4278190080 4278190080 4278190080 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
	offset: 0@0)
]

{ #category : #icons }
TreeNavigationBarMorph class >> smallToRightEndIcon [
	^ (Form
	extent: 16@16
	depth: 32
	fromArray: #( 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4287401100 4279173376 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4287401100 4279173376 0 0 0 0 0 0 0 4278190080 4278190080 4278190080 0 0 0 0 4287401100 4279173376 0 0 0 0 0 0 0 4278190080 4287401100 4287401100 4278190080 0 0 0 4287401100 4279173376 0 0 0 0 0 0 4278190080 4287401100 4287401100 4287401100 4287401100 4278190080 0 50353408 4287401100 4279173376 4278190080 4278190080 4278190080 4278190080 4278190080 4278190080 4291151301 4287401100 4287401100 4287401100 4287401100 4287401100 4278190080 0 4287401100 4279173376 4278190080 4291151301 4291151301 4291151301 4291151301 4291151301 4291151301 4287401100 4287401100 4287401100 4287401100 4287401100 4287401100 4278190080 4287401100 4279173376 4278190080 4291151301 4291151301 4291151301 4287401100 4287401100 4287401100 4287401100 4287401100 4287401100 4287401100 4287401100 4287401100 4278190080 4287401100 4279173376 4278190080 4291151301 4291151301 4291151301 4291151301 4291151301 4291151301 4287401100 4287401100 4287401100 4287401100 4287401100 4287401100 4278190080 4287401100 4279173376 4278190080 4278190080 4278190080 4278190080 4278190080 4278190080 4291151301 4287401100 4287401100 4287401100 4287401100 4287401100 4278190080 0 4287401100 4279173376 0 0 0 0 0 0 4278190080 4287401100 4287401100 4287401100 4287401100 4278190080 0 0 4287401100 4279173376 0 0 0 0 0 0 0 4278190080 4287401100 4287401100 4278190080 0 0 0 4287401100 4279173376 0 0 0 0 0 0 0 4278190080 4278190080 4278190080 0 0 0 0 4287401100 4279173376 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4287401100 4279173376 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4287401100 4279173376)
	offset: 0@0)
]

{ #category : #icons }
TreeNavigationBarMorph class >> smallToRightIcon [
	^ (Form
	extent: 16@16
	depth: 32
	fromArray: #( 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4278190080 4278190080 4278190080 0 0 0 0 0 0 0 0 0 0 0 0 0 4278190080 4287401100 4287401100 4278190080 0 0 0 0 0 0 0 0 0 0 0 4278190080 4287401100 4287401100 4287401100 4287401100 4278190080 0 50353408 0 0 4278190080 4278190080 4278190080 4278190080 4278190080 4278190080 4291151301 4287401100 4287401100 4287401100 4287401100 4287401100 4278190080 0 0 0 4278190080 4291151301 4291151301 4291151301 4291151301 4291151301 4291151301 4287401100 4287401100 4287401100 4287401100 4287401100 4287401100 4278190080 0 0 4278190080 4291151301 4291151301 4291151301 4287401100 4287401100 4287401100 4287401100 4287401100 4287401100 4287401100 4287401100 4287401100 4278190080 0 0 4278190080 4291151301 4291151301 4291151301 4291151301 4291151301 4291151301 4287401100 4287401100 4287401100 4287401100 4287401100 4287401100 4278190080 0 0 4278190080 4278190080 4278190080 4278190080 4278190080 4278190080 4291151301 4287401100 4287401100 4287401100 4287401100 4287401100 4278190080 0 0 0 0 0 0 0 0 0 4278190080 4287401100 4287401100 4287401100 4287401100 4278190080 0 0 0 0 0 0 0 0 0 0 0 4278190080 4287401100 4287401100 4278190080 0 0 0 0 0 0 0 0 0 0 0 0 4278190080 4278190080 4278190080 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
	offset: 0@0)
]

{ #category : #icons }
TreeNavigationBarMorph class >> smallVerticalResizingIcon [
	^ (Form
	extent: 16@16
	depth: 32
	fromArray: #( 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4283914071 0 0 0 0 4286545791 4286545791 4287401100 4287401100 4287401100 4287401100 0 0 0 0 4286545791 4290822336 4283914071 0 0 4286611584 4293256677 4293256677 4294967295 4294967295 4294967295 4294967295 4287401100 0 0 4286545791 4290822336 4290822336 4290822336 4283914071 0 4286611584 4293256677 4293256677 4294967295 4294967295 4294967295 4294967295 4287401100 0 4283914071 4283914071 4283914071 4283914071 4283914071 4283914071 4283914071 4286611584 4293256677 4293256677 4294967295 4294967295 4294967295 4294967295 4287401100 0 0 0 0 0 0 0 0 4286611584 4293256677 4293256677 4294967295 4294967295 4294967295 4294967295 4287401100 0 0 0 0 4278190080 0 0 0 4286611584 4293256677 4293256677 4294967295 4294967295 4294967295 4294967295 4287401100 0 0 0 0 4278190080 4293256677 0 0 4286611584 4293256677 4293256677 4294967295 4294967295 4294967295 4294967295 4287401100 0 0 0 0 4278190080 4293256677 0 0 4286611584 4293256677 4293256677 4294967295 4294967295 4294967295 4294967295 4287401100 0 0 0 0 4278190080 4293256677 0 0 4286611584 4293256677 4293256677 4294967295 4294967295 4294967295 4294967295 4287401100 0 0 0 0 4278190080 4293256677 0 0 4286611584 4293256677 4293256677 4294967295 4294967295 4294967295 4294967295 4287401100 0 4283914071 4283914071 4283914071 4283914071 4283914071 4283914071 4283914071 4286611584 4287401100 4287401100 4294967295 4294967295 4294967295 4294967295 4287401100 0 0 4286545791 4290822336 4290822336 4290822336 4283914071 0 0 4287401100 4287401100 4287401100 4287401100 4287401100 4287401100 0 0 0 0 4286545791 4290822336 4283914071 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4283914071 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
	offset: 0@0)
]

{ #category : #accessing }
TreeNavigationBarMorph >> asDisabledForm: aForm [
	| disa |
	disa := aForm copy.
	(aForm colorsUsed reject: [:c | c = Color transparent])
		do: [:c | disa replaceColor: c  withColor: (c alphaMixed: 0.4 with: Color white)].
	^ disa

]

{ #category : #accessing }
TreeNavigationBarMorph >> basicButton [
	| button |
	^ (button := SimpleButtonMorph new)
		clipSubmorphs: true;
		color: self pagerColor;		
		on: #mouseEnter send: #value to: [button borderColor: self pagerColor muchDarker];
		on: #mouseLeave send: #value to: [button borderColor: self pagerColor];
		target: self;
		layoutPolicy: TableLayout new; 
		listDirection: #leftToRight; 
		listCentering: #leftCenter; 
		wrapCentering: #center;
		layoutInset: 2@0;
		cellInset: 2@0;
		borderWidth: 1;
		borderColor: self pagerColor;
		yourself
	
]

{ #category : #accessing }
TreeNavigationBarMorph >> basicIcon [
	| button |
	^ (button := IconicButtonMorph new)
		clipSubmorphs: true;
		color: self pagerColor;		
		on: #mouseEnter send: #value to: [button borderColor: self pagerColor muchDarker];
		on: #mouseLeave send: #value to: [button borderColor: self pagerColor];
		target: self;
		layoutPolicy: TableLayout new; 
		listDirection: #leftToRight; 
		listCentering: #leftCenter; 
		wrapCentering: #center;
		layoutInset: 2@0;
		cellInset: 2@0;
		borderWidth: 1;
		borderColor: self pagerColor;
		yourself
	
]

{ #category : #accessing }
TreeNavigationBarMorph >> buildPanel [
	self subclassResponsibility
]

{ #category : #accessing }
TreeNavigationBarMorph >> buttonLabel: aLabel actionSelector: aSelector arguments: aCollection getEnabled: enableSelector help: helpText [

	| b |
	b := (aLabel isString ifTrue: [self basicButton] ifFalse: [self basicIcon])
		actionSelector: aSelector;
		arguments: aCollection;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		setBalloonText: helpText;
		yourself.
		aLabel isString 
			ifTrue: [b label: aLabel font: self preferedFont]
			ifFalse: [| f | 
				f := (enableSelector isNil or: [self perform: enableSelector])
					ifTrue: [aLabel]
					ifFalse: [b lock. self asDisabledForm: aLabel].
				b labelGraphic: f].
	^ b
	
]

{ #category : #navigation }
TreeNavigationBarMorph >> changePageSize: aNumberOrNil [
	aNumberOrNil
		ifNotNil: [self updateForNewPageSize: aNumberOrNil]
		ifNil: [treeMorph removePager]

]

{ #category : #accessing }
TreeNavigationBarMorph >> computedBounds [
	| tb tbw yGap |
	tb := treeMorph bounds.
	tbw := treeMorph borderWidth.
	yGap := self layoutInset asPoint y + self cellInset asPoint y.
	^ (tb bottomLeft + (tbw @ (self computedHeight + yGap) negated)) corner: (tb bottomRight - ( (tbw * 2) @ yGap )).

]

{ #category : #accessing }
TreeNavigationBarMorph >> computedHeight [
	^ computedHeight
		ifNil: [computedHeight := self computedHeightFromContents + self layoutInset asPoint y + self cellInset asPoint y]
]

{ #category : #navigation }
TreeNavigationBarMorph >> computedHeightFromContents [
	| h |
	h := 0.
	self submorphsDo: [:sm | h := h max: sm height].
	^ h

]

{ #category : #private }
TreeNavigationBarMorph >> handlesMouseDown: anEvent [
	^ true
]

{ #category : #initialization }
TreeNavigationBarMorph >> initialize [
	super initialize.
	self hResizing: #spaceFill;
		 vResizing: #rigid;
		 changeTableLayout; 
		 listDirection: #leftToRight;
		 cellInset: 2 @ 0;
		 layoutInset: 3 @ 0;
		 listCentering: #center;
		 clipSubmorphs: true;
		 borderWidth: 0;
		 borderColor: Color lightGray
]

{ #category : #private }
TreeNavigationBarMorph >> mouseDown: anEvent [
]

{ #category : #accessing }
TreeNavigationBarMorph >> nodeList [
	^ treeMorph nodeList
]

{ #category : #navigation }
TreeNavigationBarMorph >> pageOfNodeIndex: anIndex [
	^ (anIndex > 0 and: [anIndex <= self nodeList size])
		ifTrue: [((anIndex - 1) // pageSize) + 1]
		ifFalse: [nil]
			
]

{ #category : #accessing }
TreeNavigationBarMorph >> pageSearchText [
	^ pageSearchText ifNil: [pageSearchText := '']
]

{ #category : #accessing }
TreeNavigationBarMorph >> pageSearchText: aString [
	| founds chosen chosenNode |
	pageSearchText := aString.
	self changed: #pageSearchText.
	founds := OrderedCollection new.
	self nodeList doWithIndex: [:n :idx |
		(n includesSubstringAnywhere: pageSearchText)
			ifTrue: [founds add: idx -> n]].
	founds ifEmpty: [ ^ self flash ].
	founds size > 1 
		ifTrue: [ 
			chosen := 
				UIManager default 
					chooseFrom: (founds collect: [:l | l value] ) 
					values: (founds collect: [:l | l key] ) 
					lines: nil 
					title: ''.
			chosen ifNil: [^self]]
		ifFalse: [chosen := founds first key].
	self currentPage: (self pageOfNodeIndex: chosen).
	chosenNode := self nodeList at: chosen.
	treeMorph scroller 
		submorphsDo: [:sm | 
			sm complexContents ==  chosenNode
				ifTrue: [treeMorph listManager setSelectedMorph: sm.
					^ treeMorph scrollSelectionIntoView]]

]

{ #category : #accessing }
TreeNavigationBarMorph >> pageSize [
	^ pageSize
]

{ #category : #accessing }
TreeNavigationBarMorph >> pageSize: anInteger [
	pageSize := anInteger
]

{ #category : #accessing }
TreeNavigationBarMorph >> pageSizeFromString: aString [
	| input |
	input := aString asString trimBoth.
	input ifEmpty: [input := '1'].
	(input beginsWith: '/' )
		ifTrue: [ | numberOfPages |
			input := (input copyFrom: 2 to: input size) trimBoth.
			numberOfPages := Integer readFromString: input.
			numberOfPages > 0 
				ifTrue: [self changePageSize: (self nodeList size // numberOfPages)]
				ifFalse: [treeMorph flash.
					^ false]]
		ifFalse: [ | newPageSize |
			newPageSize := Integer readFromString: input.
			newPageSize > 0 
				ifTrue: [self changePageSize: newPageSize]
				ifFalse: [treeMorph flash.
					^ false]].
	^ true

]

{ #category : #accessing }
TreeNavigationBarMorph >> pageSizeToString [
	^ self pageSize asString
]

{ #category : #accessing }
TreeNavigationBarMorph >> pagerColor [
	^ treeMorph pagerColor
]

{ #category : #accessing }
TreeNavigationBarMorph >> preferedFont [
	^ self balloonFont 
]

{ #category : #accessing }
TreeNavigationBarMorph >> spacer: hsize [
	^ (Morph new) color: Color transparent; extent: hsize @ (self hasSubmorphs  ifTrue: [self computedHeight] ifFalse: [(self preferedFont height + 8)]); yourself
]

{ #category : #accessing }
TreeNavigationBarMorph >> textEntryLabel: aLabel get: getSel set: setSel help: helpText class: aClass [
	^ RubPluggableTextFieldMorph new
		on: self
		text: getSel
		accept: setSel
		readSelection: nil
		menu: nil;
		setBalloonText: helpText;
		yourself

]

{ #category : #accessing }
TreeNavigationBarMorph >> treeMorph: aTreeMorph [ 
	treeMorph := aTreeMorph.

]

{ #category : #accessing }
TreeNavigationBarMorph >> treeMorph: aTreeMorph pageSize: anInteger [
	self treeMorph: aTreeMorph.
	self pageSize: anInteger
]

{ #category : #accessing }
TreeNavigationBarMorph >> updateContents [
	self bounds: self computedBounds.
	self color: treeMorph pagerColor.

]

{ #category : #navigation }
TreeNavigationBarMorph >> updateForNewPageSize: aPageSize [
	pageSize := aPageSize max: 1.
	self changed: #pageSize
]

{ #category : #'user interface' }
TreeNavigationBarMorph >> vScrollBarValue: scrollValue [

]

{ #category : #accessing }
TreeNavigationBarMorph >> withSearch [
	^ withSearch ifNil: [withSearch := false]
]

{ #category : #accessing }
TreeNavigationBarMorph >> withSearch: aBoolean [
	withSearch := aBoolean.
	self buildPanel
]
