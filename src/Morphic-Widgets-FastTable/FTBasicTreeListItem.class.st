"
FTBasicTreeListItem holds the state of a element in FTBasicTreeListDataSource.

Instance variables: 

|< expanded >|< Private  >|< aBoolean >[ 
	remembers if this it is currently expanded or not.
}.

|< depth >|< Private  >|< aNumber >[
	The depth of this item from the root.
 ].

< item > [  anyObject. 
	The raw item which is wrapped by this class.	
].

< children > [ aCollection.
	cache for holding currently expaned children
 ].

< dataSource > [ aFBasicTreeListDataSource
	reference to the datasource
 ].
"
Class {
	#name : #FTBasicTreeListItem,
	#superclass : #Object,
	#instVars : [
		'expanded',
		'depth',
		'item',
		'children',
		'dataSource'
	],
	#category : #'Morphic-Widgets-FastTable-Tree-Basic'
}

{ #category : #querying }
FTBasicTreeListItem >> availableRows [

	^expanded ifTrue: [ 
		children
			inject: 1 
			into: [ :sum :each | sum + each availableRows ] 
			
	] ifFalse: [ 1 ]
]

{ #category : #accessing }
FTBasicTreeListItem >> cellMorphFor: aDataSource [

	| morph |
	
	morph := FTIndentedCellMorph new.
	morph depthIndent: depth.
	
	self hasChildren 
		ifTrue: [ morph addMorphBack: self generateButton ]
		ifFalse: [ morph addIndendtation: 15 ].
	
	dataSource displayBlock value: item value: morph.
	
	^morph
]

{ #category : #accessing }
FTBasicTreeListItem >> children [

	^children
]

{ #category : #'button-interaction' }
FTBasicTreeListItem >> collapseItem [

	dataSource updateAvailableRows: 1 - self availableRows.
	
	children := #().
	
	expanded := false.
]

{ #category : #button }
FTBasicTreeListItem >> collapsedButton [

	^self defaultButton
		actionSelector: #expandItem;
		labelGraphic: Smalltalk ui theme treeUnexpandedForm;
		helpText: 'Expand Item';
		yourself
]

{ #category : #construction }
FTBasicTreeListItem >> datasource: aDS [

	dataSource := aDS
]

{ #category : #button }
FTBasicTreeListItem >> defaultButton [

	^IconicButtonMorph new
		target: self;
		color: Color transparent;
		borderWidth: 0;
		yourself.
]

{ #category : #construction }
FTBasicTreeListItem >> depth: aNumber [

	depth := aNumber 
]

{ #category : #'button-interaction' }
FTBasicTreeListItem >> expandItem [

	expanded := true.
	
	children := (dataSource childrenFor: item) collect: [ :each | self treeItemFor: each ].
	
	dataSource updateAvailableRows: self availableRows - 1.
]

{ #category : #interaction }
FTBasicTreeListItem >> expandToDepth: aNumber [
	
	depth = aNumber ifTrue: [ ^self ].
	
	self expandItem.
	
	children do: [ :each | each expandToDepth: aNumber ].
]

{ #category : #button }
FTBasicTreeListItem >> expandedButton [

	^self defaultButton
		actionSelector: #collapseItem;
		labelGraphic: Smalltalk ui theme treeExpandedForm;
		helpText: 'Collapse Item';
		yourself
]

{ #category : #button }
FTBasicTreeListItem >> generateButton [
	^expanded 
		ifTrue: [ self expandedButton ]
		ifFalse: [ self collapsedButton ]
]

{ #category : #querying }
FTBasicTreeListItem >> hasChildren [

	^(dataSource childrenBlock value: item) isNotEmpty
]

{ #category : #initialization }
FTBasicTreeListItem >> initialize [

	expanded := false.
	depth := 0.
	children := #()
]

{ #category : #accessing }
FTBasicTreeListItem >> item [

	^item
]

{ #category : #construction }
FTBasicTreeListItem >> item: anItem [

	item := anItem
]

{ #category : #'button-interaction' }
FTBasicTreeListItem >> treeItemFor: anItem [

	^FTBasicTreeListItem new 
		datasource: dataSource;
		depth: depth + 1;
		item: anItem
]
