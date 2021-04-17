Class {
	#name : #GLMPaginatedResizableMorphTreeMorph,
	#superclass : #GLMPaginatedMorphTreeMorph,
	#category : #'Glamour-Morphic-Widgets'
}

{ #category : #private }
GLMPaginatedResizableMorphTreeMorph >> resizeColumns [
	| rowMorphsWidths |
	
	self columns size > 1 ifFalse: [ ^ self ].
	rowMorphsWidths := self rowMorphsWidths.
	self allNodeMorphs do: [ :node |
		node submorphs doWithIndex: [ :each :index | each hResizing: #rigid; width: (rowMorphsWidths at: index) ] ].
	self hHideScrollBar.
]

{ #category : #'events-processing' }
GLMPaginatedResizableMorphTreeMorph >> toggleExpandedState: aMorph event: event [
	super toggleExpandedState: aMorph event: event.
	self resizeColumns 
]

{ #category : #updating }
GLMPaginatedResizableMorphTreeMorph >> updateColumnMorphs [
	super updateColumnMorphs.
	self resizeColumns
		
	
]
