Class {
	#name : #GLMMorphicVariablePanesFinderRenderer,
	#superclass : #GLMMorphicFinderRenderer,
	#instVars : [
		'scrollPane'
	],
	#category : #'Glamour-Morphic-Renderer'
}

{ #category : #rendering }
GLMMorphicVariablePanesFinderRenderer >> actOnPaneAdded: ann [
	self addMorphFromObject: ann pane toContainer: container.
	scrollPane hScrollbar glmAnimateValue: 1.0 duration: 2000
]

{ #category : #rendering }
GLMMorphicVariablePanesFinderRenderer >> actOnPaneRemoved: ann [
	container removeMorph: container submorphs last.
	container removeMorph: container submorphs last
]

{ #category : #rendering }
GLMMorphicVariablePanesFinderRenderer >> actOnPaneReplaced: ann [
	container removeMorph: container submorphs last.
	container removeMorph: container submorphs last.
	self addMorphFromObject: ann newPane toContainer: container.
	scrollPane hScrollbar glmAnimateValue: 1.0 duration: 200
]

{ #category : #rendering }
GLMMorphicVariablePanesFinderRenderer >> addMorphFromObject: anObject toContainer: aContainerMorph [
	| renderedMorph |
	renderedMorph := (self renderObject: anObject)
				vResizing: #spaceFill;
				hResizing: #rigid;
				minimumExtent: 200@10;
				extent: 200@10;
				yourself.
	aContainerMorph addMorphBack: renderedMorph.
	aContainerMorph addMorphBack: (EdgeGripMorph new
		width: ProportionalSplitterMorph splitterWidth;
		hResizing: #rigid; "not the default this time, vResizing is also #spaceFill by default"
		target: renderedMorph)
]

{ #category : #rendering }
GLMMorphicVariablePanesFinderRenderer >> render: aBrowser [
	container := GLMMorphic containerMorph.
	container 
		changeTableLayout;
		listDirection: #leftToRight;
		vResizing: #spaceFill;
		hResizing: #shrinkWrap.
	scrollPane := GeneralScrollPaneMorph new
		changeScrollerTableLayout;
		scrollTarget: container;
		yourself.
	self registerAnnouncementsFor: aBrowser.  
	aBrowser panes do: [ :each | self addMorphFromObject: each toContainer: container ].
	^ scrollPane
]
