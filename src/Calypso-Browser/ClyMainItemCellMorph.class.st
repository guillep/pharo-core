"
I represent main cell in table row. 
I responsible to show expansion icon, current depth indentation when tree structure is specified.
I allow to decorate me with
- definition morph which will be placed before label
	cellMorph definitionMorph: aMorph
	cellMorph definitionIcon: iconName
- extraToolMorphs which will be placed after label
	cellMorph addExtraTool: aMorph
	cellMorph addExtraIcon: iconName
- any kind of properties for my label
	cellMorph label emphasis: TextEmphasis italic emphasisCode.

I implement layout logic in method #build.

My instances are created using:
	ClyMainItemCellMorph on: aDataSourceItem

I provide two identation strategies which you can switch using fullIndentation variable.
In full identation mode children items are shifted together with collapsing button.
Otherwise collapsion button is always in same place but label and icons are shifted.

Internal Representation and Key Implementation Points.

    Instance Variables
	definitionMorph:		<Morph>
	extraToolMorphs:		<OrderedCollection of<Morph>>
	item:		<ClyDataSourceItem>
	itemDepth:		<Integer>
	fullIndentation: <Boolean>
"
Class {
	#name : #ClyMainItemCellMorph,
	#superclass : #ClyItemCellMorph,
	#instVars : [
		'item',
		'definitionMorph',
		'extraToolMorphs',
		'itemDepth',
		'fullIndentation'
	],
	#category : #'Calypso-Browser-Table'
}

{ #category : #'instance creation' }
ClyMainItemCellMorph class >> on: aDataSourceItem [
	^self new 
		item: aDataSourceItem
]

{ #category : #accessing }
ClyMainItemCellMorph >> actualObject [
	^item actualObject
]

{ #category : #building }
ClyMainItemCellMorph >> addBarForFullIndentation [

	| mainItemsCount absentItemsCount requiredWidth |
	mainItemsCount := 0.
	absentItemsCount := mainItemsCount - submorphs size.

	requiredWidth := absentItemsCount * 16 + (self itemDepth * 8).
	requiredWidth = 0 ifTrue: [ ^self ].
	
	self addMorphBack: (self emptyBarWithWidth: requiredWidth)
]

{ #category : #building }
ClyMainItemCellMorph >> addBarForLabelIndentation [

	| placeForExpansionRequired mainItemsCount absentItemsCount requiredWidth |
	placeForExpansionRequired := item rootDataSource definesChildren.
	mainItemsCount := placeForExpansionRequired ifTrue: [ 2 ] ifFalse: [ 1 ].
	absentItemsCount := mainItemsCount - submorphs size.

	requiredWidth := absentItemsCount * 16 + (self itemDepth * 8).
	requiredWidth = 0 ifTrue: [ ^self ].
	
	self addMorphBack: (self emptyBarWithWidth: requiredWidth)
]

{ #category : #accessing }
ClyMainItemCellMorph >> addExtraIcon: iconName [
	
	| icon |
	icon := self iconNamed: iconName.
	^self addExtraTool: icon asMorph
]

{ #category : #accessing }
ClyMainItemCellMorph >> addExtraTool: aMorph [
	
	extraToolMorphs ifNil: [ extraToolMorphs := OrderedCollection new].
	extraToolMorphs add: aMorph.
	^aMorph
]

{ #category : #accessing }
ClyMainItemCellMorph >> browser [
	^item browser
]

{ #category : #accessing }
ClyMainItemCellMorph >> browserItem [
	^item browserItem
]

{ #category : #building }
ClyMainItemCellMorph >> build [

	fullIndentation 
		ifTrue: [ self buildWithFullIndentation ]
		ifFalse: [ self buildWithLabelIndentation  ].
	
]

{ #category : #building }
ClyMainItemCellMorph >> buildWithFullIndentation [

	| expansionButton |
	self addBarForFullIndentation.
	item supportsExpansion ifTrue: [ 
		expansionButton := self currentExpansionButton.
		self addMorphBack: expansionButton].
	definitionMorph ifNotNil: [
		definitionMorph width: 16.
		 self addMorphBack: definitionMorph].
	
	
	self addMorphBack: label.
	extraToolMorphs ifNotNil: [ extraToolMorphs do: [:each |
			each width: 16.
			 self addMorphBack: each  ] ]
]

{ #category : #building }
ClyMainItemCellMorph >> buildWithLabelIndentation [

	| expansionButton |
	item supportsExpansion ifTrue: [ 
		expansionButton := self currentExpansionButton.
		self addMorphBack: expansionButton].
	definitionMorph ifNotNil: [
		definitionMorph width: 16.
		 self addMorphBack: definitionMorph].
	
	self addBarForLabelIndentation.
	self addMorphBack: label.
	extraToolMorphs ifNotNil: [ extraToolMorphs do: [:each |
			each width: 16.
			 self addMorphBack: each  ] ]
]

{ #category : #buttons }
ClyMainItemCellMorph >> collapsedButton [
	^ IconicButtonMorph new
		target: item;
		actionSelector: #expand;
		arguments: {};
		labelGraphic: self theme treeUnexpandedForm;
		color: Color transparent;
		helpText: 'Expand Item';
		borderWidth: 0
]

{ #category : #buttons }
ClyMainItemCellMorph >> currentExpansionButton [

	item hasChildren ifFalse: [^FTTreeDataSource emptyMorph].
	
	^item isExpanded 
		ifTrue: [ self expandedButton ]
		ifFalse: [self collapsedButton]
]

{ #category : #accessing }
ClyMainItemCellMorph >> definitionIcon: iconName [
	
	| icon |
	icon := self iconNamed: iconName.
	^self definitionMorph: icon asMorph
]

{ #category : #accessing }
ClyMainItemCellMorph >> definitionMorph: aMorph [
	
	definitionMorph := aMorph.
	definitionMorph width: 16.
	^definitionMorph 
]

{ #category : #building }
ClyMainItemCellMorph >> emptyBarWithWidth: aNumber [
	| bar |
	bar := Morph new.
	bar 
		setNamePropertyTo: 'emptyBar';
		color: Color transparent;
		changeTableLayout;		
		vResizing: #spaceFill;
		hResizing: #rigid;
		minWidth: 0;
		width: aNumber.
	^bar
]

{ #category : #buttons }
ClyMainItemCellMorph >> expandedButton [
	^ IconicButtonMorph new
		target: item;
		actionSelector: #collapse;
		arguments: {};
		labelGraphic: self theme treeExpandedForm;
		color: Color transparent;
		helpText: 'Unexpand Item';
		borderWidth: 0
]

{ #category : #initialization }
ClyMainItemCellMorph >> initialize [
	super initialize.
	fullIndentation := false.
	self cellInset: 2@0
]

{ #category : #accessing }
ClyMainItemCellMorph >> item [
	^ item
]

{ #category : #accessing }
ClyMainItemCellMorph >> item: aDataSourceItem [
	item := aDataSourceItem
]

{ #category : #accessing }
ClyMainItemCellMorph >> itemDepth [
	^itemDepth ifNil: [item depth]
]

{ #category : #accessing }
ClyMainItemCellMorph >> overrideItemDepthByDelta: delta [ 
	^itemDepth := item depth + delta
]

{ #category : #accessing }
ClyMainItemCellMorph >> useFullIndentation [
	fullIndentation := true
]
