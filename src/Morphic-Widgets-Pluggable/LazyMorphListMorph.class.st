"
Support for morph lists in PluggableMorphListMorph.
"
Class {
	#name : #LazyMorphListMorph,
	#superclass : #LazyListMorph,
	#category : #'Morphic-Widgets-Pluggable-Lists'
}

{ #category : #private }
LazyMorphListMorph >> adjustHeight [
	"private.  Adjust our height to match the length of the underlying list.
	Automatic with table layout."

]

{ #category : #private }
LazyMorphListMorph >> adjustWidth [
	"private.  Adjust our height to match the length of the underlying list"
	
	self width: (listSource innerBounds width max: self hUnadjustedScrollRange). 
]

{ #category : #drawing }
LazyMorphListMorph >> display: item  atRow: row on: aCanvas [
	"Display the given item at the given row on the given canvas."
	
	|c frame|
	row = self mouseDownRow ifFalse: [^self].
	frame := self selectionFrameForRow: row.
	c := self colorForRow: row.
	aCanvas 
		frameRectangle: frame
		width: 1
		colors: {c. Color transparent}
		 dashes: #(1 1)
]

{ #category : #drawing }
LazyMorphListMorph >> drawBoundsForRow: row [
	"Calculate the bounds that row should be drawn at.  This might be outside our bounds!"
	
	(row between: 1 and: listItems size)
		ifFalse: [^0@0 corner: 0@0].
	^(listItems at: row) bounds
]

{ #category : #drawing }
LazyMorphListMorph >> drawSubmorphsOn: aCanvas [ 
	"Display submorphs back to front"

	| drawBlock|
	submorphs isEmpty ifTrue: [^self].
	drawBlock := [:canvas | | i |
		(self topVisibleRowForCanvas: aCanvas) to: (self bottomVisibleRowForCanvas: aCanvas) do: [ :row |
			i := self item: row.
			canvas fullDrawMorph: i]].
	self clipSubmorphs 
		ifTrue: [aCanvas clipBy: (aCanvas clipRect intersect: self clippingBounds ifNone: [ ^ self ]) during: drawBlock]
		ifFalse: [drawBlock value: aCanvas]
]

{ #category : #accessing }
LazyMorphListMorph >> hUnadjustedScrollRange [
	"Answer the width of the widest item."

	maxWidth ifNotNil:[^maxWidth].
	listItems isEmpty ifTrue: [^0].
	maxWidth := 0.
	listItems do: [:each |
		each ifNotNil: [maxWidth := maxWidth max: (each widthToDisplayInList: self)]].
	^maxWidth

]

{ #category : #initialization }
LazyMorphListMorph >> initialize [
	"Initialize the receiver."

	super initialize.
	self
		changeTableLayout;
		cellPositioning: #topLeft;
		cellInset: 2;
		vResizing: #shrinkWrap;
		hResizing: #rigid
]

{ #category : #accessing }
LazyMorphListMorph >> listChanged [
	"set newList to be the list of strings to display"
	listItems := (1 to: self getListSize) collect: [:i |
		self getListItem: i].
	self removeAllMorphs.
	self extent: 0@0.
	listItems do: [:i | self addMorphBack: i].
	selectedRow := nil.
	selectedRows := PluggableSet integerSet.
	maxWidth := nil. "recompute"
	self
		adjustHeight;
		adjustWidth.
	listItems do: [:i | i layoutChanged].
	self changed.

]

{ #category : #accessing }
LazyMorphListMorph >> rowAtLocation: aPoint [
	"return the number of the row at aPoint"

	| y |
	y := aPoint y.
	y < self top ifTrue: [ ^ 1 ].
	listItems with: (1 to: listItems size) do: [:i :row |
		(y < i bottom) ifTrue: [^row]].
	^listItems size
]

{ #category : #accessing }
LazyMorphListMorph >> selectRow: index [
	"select the index-th row"
	selectedRows add: index.
	self invalidRect: (self drawBoundsForRow: index)
]

{ #category : #accessing }
LazyMorphListMorph >> selectionFrameForRow: row [
	"Answer the selection frame rectangle."

	|frame|
	frame := self drawBoundsForRow: row.
	frame := frame expandBy: (self cellInset // 2).
	self cellInset odd ifTrue: [frame := frame bottom: frame bottom + 1].
	frame := frame intersect: self bounds ifNone: [ self error: 'should not happen' ].
	frame := self bounds: frame in: listSource.
	frame := self
		bounds: ((frame left: listSource innerBounds left) right: listSource innerBounds right)
		from: listSource.
	^frame
]

{ #category : #accessing }
LazyMorphListMorph >> userString [
	"Do I have a text string to be searched on?"

	^ String
		streamContents: [ :stream | 
			1 to: self getListSize do: [ :i | 
				(self getListItem: i) submorphs detect: [ :morph | morph userString notNil ] ifFound: [ :morph | stream nextPutAll: morph userString ].
				stream cr ] ]
]
