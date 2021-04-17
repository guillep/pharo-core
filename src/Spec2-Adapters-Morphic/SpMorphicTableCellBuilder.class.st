"
I build cells for a MorphicTableAdapter.
"
Class {
	#name : #SpMorphicTableCellBuilder,
	#superclass : #SpMorphicTableColumnVisitor,
	#instVars : [
		'dataSource',
		'rowIndex',
		'cell'
	],
	#category : #'Spec2-Adapters-Morphic-Table'
}

{ #category : #'instance creation' }
SpMorphicTableCellBuilder class >> on: aDataSource [

	^ self new dataSource: aDataSource
]

{ #category : #private }
SpMorphicTableCellBuilder >> addBackgroundColorColumn: aTableColumn item: item toMorph: aMorph [

	aTableColumn displayBackgroundColor ifNotNil: [ :block |
		(block cull: item) ifNotNil: [ :aColor |
			aMorph color: aColor ]  ].
	
	^ aMorph
	
]

{ #category : #private }
SpMorphicTableCellBuilder >> addBoldColumn: aTableColumn item: item to: content [

	aTableColumn displayBold ifNotNil: [ :block |
		(block cull: item) ifTrue: [ 
			^ content asText addAttribute: TextEmphasis bold ] ].
	
	^ content
	
]

{ #category : #private }
SpMorphicTableCellBuilder >> addCell: anObject column: aTableColumn [
	| morph |

	anObject ifNil: [ ^ self ]. 
	
	morph := 	anObject asMorph asReadOnlyMorph.
	self 
		addCellMorph: morph 
		column: aTableColumn
]

{ #category : #private }
SpMorphicTableCellBuilder >> addCellColumn: aTableColumn [
	
	self 
		addCell: (aTableColumn readObject: self item) 
		column: aTableColumn
]

{ #category : #private }
SpMorphicTableCellBuilder >> addCellMorph: morph column: aTableColumn [

	aTableColumn isExpandable ifFalse: [
		aTableColumn width: (aTableColumn width 
			ifNotNil: [ :width | width max: morph width ]
			ifNil: [ morph width ]).
		cell hResizing: #shrinkWrap.
		morph 
			hResizing: #rigid;
			width: aTableColumn width ].
	
	cell addMorphBack: morph
]

{ #category : #private }
SpMorphicTableCellBuilder >> addColorColumn: aTableColumn item: item to: content [

	aTableColumn displayColor ifNotNil: [ :block |
		(block cull: item) ifNotNil: [ :aColor |
			^ content asText addAttribute: (TextColor color: aColor) ]  ].
	
	^ content
	
]

{ #category : #private }
SpMorphicTableCellBuilder >> addItalicColumn: aTableColumn item: item to: content [

	aTableColumn displayItalic ifNotNil: [ :block |
		(block cull: item) ifTrue: [ 
			^ content asText addAttribute: TextEmphasis italic ] ].
	
	^ content
	
]

{ #category : #private }
SpMorphicTableCellBuilder >> addUnderlineColumn: aTableColumn item: item to: content [

	aTableColumn displayUnderline ifNotNil: [ :block |
		(block cull: item) ifTrue: [ 
			^ content asText addAttribute: TextEmphasis underlined ] ].
	
	^ content
	
]

{ #category : #accessing }
SpMorphicTableCellBuilder >> cell [
	^ cell
]

{ #category : #accessing }
SpMorphicTableCellBuilder >> cell: anObject [
	cell := anObject
]

{ #category : #accessing }
SpMorphicTableCellBuilder >> dataSource [
	^ dataSource
]

{ #category : #accessing }
SpMorphicTableCellBuilder >> dataSource: anObject [
	dataSource := anObject
]

{ #category : #private }
SpMorphicTableCellBuilder >> item [ 

	^ self dataSource elementAt: self rowIndex
]

{ #category : #accessing }
SpMorphicTableCellBuilder >> rowIndex [
	^ rowIndex
]

{ #category : #accessing }
SpMorphicTableCellBuilder >> rowIndex: anObject [
	rowIndex := anObject
]

{ #category : #visiting }
SpMorphicTableCellBuilder >> visitCheckboxColumn: aTableColumn [
	| presenter morph |
	
	presenter := SpCheckBoxPresenter new
		addStyle: 'compact';
		state: (aTableColumn readObject: self item);
		yourself.

	aTableColumn onActivation ifNotNil: [ :valuable | 
		presenter whenActivatedDo: [ valuable cull: self item ] ].
	aTableColumn onDeactivation ifNotNil: [ :valuable | 
		presenter whenDeactivatedDo: [ valuable cull: self item ] ].

	morph := presenter buildWithSpec.
	presenter adapter applyStyle: morph.

	self 
		addCellMorph: morph
		column: aTableColumn 
]

{ #category : #visiting }
SpMorphicTableCellBuilder >> visitCompositeColumn: aTableColumn [

	super visitCompositeColumn: aTableColumn.
	aTableColumn isExpandable ifFalse: [ 
		cell hResizing: #rigid.
		cell width: aTableColumn width ]
]

{ #category : #visiting }
SpMorphicTableCellBuilder >> visitImageColumn: aTableColumn [
	| morph imageMorph image |
	
	image := aTableColumn readObject: self item.
	image ifNil: [ ^ self ].
	
	imageMorph := image asMorph.
	morph := 	Morph new 
		color: Color transparent;
		addMorphBack: imageMorph;
		extent: imageMorph extent;
		yourself.

	self 
		addCellMorph: morph 
		column: aTableColumn
]

{ #category : #visiting }
SpMorphicTableCellBuilder >> visitIndexColumn: aTableColumn [

	self 
		addCell: self rowIndex 
		column: aTableColumn
]

{ #category : #visiting }
SpMorphicTableCellBuilder >> visitLinkColumn: aTableColumn [
	| presenter morph |
	
	presenter := SpLinkPresenter new
		addStyle: 'table';
		label: (aTableColumn readObject: self item);
		yourself.
	
	aTableColumn url 
		ifNotNil: [ presenter url: (aTableColumn url value: self item) ].
	aTableColumn action 
		ifNotNil: [ presenter action: [ aTableColumn action value: self item ] ].

	morph := presenter buildWithSpec.
	presenter adapter applyStyle: morph.

	self 
		addCellMorph: morph
		column: aTableColumn
]

{ #category : #visiting }
SpMorphicTableCellBuilder >> visitStringColumn: aTableColumn [
	| content item |
	
	item := self item.

	content := aTableColumn readObject: item.
	"add properties"
	content := self addColorColumn: aTableColumn item: item to: content.
	content := self addItalicColumn: aTableColumn item: item to: content.
	content := self addBoldColumn: aTableColumn item: item to: content.
	content := self addUnderlineColumn: aTableColumn item: item to: content.

	aTableColumn isEditable
		ifTrue: [ self visitStringColumnEditable: aTableColumn on: content ]
		ifFalse: [ "add cell"
			self addCell: content column: aTableColumn.
			"add background (this is a special case of properties, 
			since background needs to be applied to the cell and not to the text)"
			self addBackgroundColorColumn: aTableColumn item: item toMorph: cell ]
]

{ #category : #visiting }
SpMorphicTableCellBuilder >> visitStringColumnEditable: aTableColumn on: content [
	| presenter morph |

	presenter := self dataSource model newTextInput
		addStyle: 'compact';
  		text: content;
		yourself.

	aTableColumn acceptAction ifNotNil: [ :valuable | 
		presenter whenSubmitDo: [ 
			valuable cull: self item cull: presenter text ] ].
	
	"add cell"
	morph := presenter buildWithSpec.
	presenter adapter applyStyle.
	self addCellMorph: morph column: aTableColumn
]
