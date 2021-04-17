"
I'm an adapter for Paned Layouts.
A paned layout will split (horizontally or vertically) a panel and allow its resize. 
"
Class {
	#name : #SpMorphicPanedAdapter,
	#superclass : #SpMorphicLayoutAdapter,
	#instVars : [
		'children'
	],
	#category : #'Spec2-Adapters-Morphic-Layout'
}

{ #category : #'adding/removing' }
SpMorphicPanedAdapter >> addConstraints: constraints toChild: childMorph [
	"Adds constraits by child"
	
	| theMorph |	
	theMorph := childMorph.
	"Keep constraints to layout usage"
	theMorph setProperty: #constraints toValue: constraints. 
	
	^ theMorph 
]

{ #category : #'adding/removing' }
SpMorphicPanedAdapter >> addSplitterIn: aPanel for: childMorph [

	aPanel submorphs size = 1 ifFalse: [ ^ self ].
	aPanel addMorphBack: self direction newSplitter
]

{ #category : #'adding/removing' }
SpMorphicPanedAdapter >> basicAdd: aPresenter constraints: constraints to: aPanel [
	| childMorph |

	childMorph := self buildMorph: aPresenter constraints: constraints.	
	children add: childMorph.
	aPanel addMorphBack: childMorph.
	self addSplitterIn: aPanel for: childMorph.
	
	^ childMorph
]

{ #category : #accessing }
SpMorphicPanedAdapter >> children [

	^ children
]

{ #category : #accessing }
SpMorphicPanedAdapter >> direction [

	^ self layout direction
]

{ #category : #initialization }
SpMorphicPanedAdapter >> initialize [

	super initialize.
	children := OrderedCollection new
]

{ #category : #accessing }
SpMorphicPanedAdapter >> layout [

	^ layout
]

{ #category : #factory }
SpMorphicPanedAdapter >> layout: aLayout [

	layout := aLayout.
	widget ifNil: [ 
		widget := aLayout direction newWidgetOn: self.
		widget layoutPolicy position: aLayout position.
		self selector: self splitterNewSelector ].

	layout whenChildrenAddedDo: [ :ann |
		self 
			basicAdd: ann child
			constraints: (layout constraintsFor: ann child) 
			to: widget ].
		
	layout whenChildrenRemovedDo: [ :ann |
		self removeChild: ann child ].

	super layout: aLayout
]

{ #category : #factory }
SpMorphicPanedAdapter >> newHorizontal [

	^ self newPanel 
		listDirection: #leftToRight;
		yourself
]

{ #category : #factory }
SpMorphicPanedAdapter >> newPanel [

	^ super newPanel
		layoutPolicy: SpMorphicPanedLayout new;
		yourself
]

{ #category : #factory }
SpMorphicPanedAdapter >> newVertical [

	^ self newPanel 
		listDirection: #topToBottom;
		yourself	
]

{ #category : #'adding/removing' }
SpMorphicPanedAdapter >> removeChild: aPresenter [
	
	| morph |
	morph := aPresenter adapter widget.
	children remove: morph.
	widget removeMorph: morph
]

{ #category : #private }
SpMorphicPanedAdapter >> resizingSetSelector [

	^ layout isHorizontal
		  ifTrue: [ #hResizing: ]
		  ifFalse: [ #vResizing: ]
]

{ #category : #private }
SpMorphicPanedAdapter >> splitterNewSelector [

	^ layout isHorizontal
		  ifTrue: [ #newHorizontal ]
		  ifFalse: [ #newVertical ]
]
