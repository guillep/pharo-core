"
I'm a model datasource to handle glamour fast table presentations.

Description 
--------------------

I am a GLMFastListDataSource that can also manage multi columns.

I work with a GLMFastTablePresentation and a GLMMorphicFastTableRenderer.  

 I rely on TGLMFastTableColumnsRenderer for the logic that actually builds the row morphs. 

"
Class {
	#name : #GLMFastTableDataSource,
	#superclass : #GLMFastListDataSource,
	#traits : 'TGLMFastTableColumnsRenderer',
	#classTraits : 'TGLMFastTableColumnsRenderer classTrait',
	#instVars : [
		'columnToSortBy'
	],
	#category : #'Glamour-FastTable-Model'
}

{ #category : #private }
GLMFastTableDataSource >> dataFromPresentationItem: anItem [
	^ anItem
]

{ #category : #private }
GLMFastTableDataSource >> elementsSorted [
	elements ifNil: [ ^ nil ].
	^ columnToSortBy 
		ifNotNil: [ elements sorted: self sortBlock ]
		ifNil: [ self calculateElements ]
]

{ #category : #accessing }
GLMFastTableDataSource >> rowMorphElementsForFirstColumn: aColumn item: anItem in: rowElements [
	
	(self iconFor: anItem) ifNotNil: [ :anIcon | rowElements add: anIcon asMorph ] 
]

{ #category : #private }
GLMFastTableDataSource >> sortBlock [
	^ columnToSortBy sortBlock ifNil: [ 
		columnToSortBy defaultSortBlockForPresentation: self glamourPresentation ]
]

{ #category : #accessing }
GLMFastTableDataSource >> sortByColumn: aGlamourColumn [
	columnToSortBy := (columnToSortBy == aGlamourColumn 
		ifTrue: [ nil ]
		ifFalse: [ aGlamourColumn ]).
	elements := self elementsSorted.
	self glamourPresentation changed.
]
