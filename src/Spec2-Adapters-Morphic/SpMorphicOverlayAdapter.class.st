"
I'm a morphic adapter for an overlay layout. I contain a main widget and an overlay that superposes it.

Internally, I create a normal panel morph with a SpMorphicOverlayLayout.
The SpMorphicOverlayLayout collaborates with the layout's constraints to decide wether a child is the main widget or an overlay widget.
"
Class {
	#name : #SpMorphicOverlayAdapter,
	#superclass : #SpMorphicLayoutAdapter,
	#category : #'Spec2-Adapters-Morphic-Layout'
}

{ #category : #protocol }
SpMorphicOverlayAdapter >> addConstraints: constraints toChild: childMorph [
	"Adds constraits by child"

	| theMorph |
	theMorph := childMorph.
	"Keep constraints to layout usage"
	theMorph setProperty: #constraints toValue: constraints. 
	
	^ theMorph 
]

{ #category : #protocol }
SpMorphicOverlayAdapter >> basicAdd: aPresenter constraints: constraints to: aWidget [
	| childMorph |
	
	childMorph := self buildMorph: aPresenter constraints: constraints.	
	aWidget addMorph: childMorph.
	
	^ childMorph
]

{ #category : #accessing }
SpMorphicOverlayAdapter >> children [
	
	^ widget submorphs
]

{ #category : #protocol }
SpMorphicOverlayAdapter >> layout: aLayout [

	widget ifNil: [ 
		widget := self newPanel
          layoutPolicy: SpMorphicOverlayLayout new;
          yourself ].

	aLayout whenChildrenAddedDo: [ :ann | 
		self
			basicAdd: ann child
			constraints: (aLayout constraintsFor: ann child)
			to: widget ].

	aLayout whenChildrenRemovedDo: [ :ann | self removeChild: ann child ].

	super layout: aLayout
]

{ #category : #accessing }
SpMorphicOverlayAdapter >> removeChild: aPresenter [

	| morph |
	morph := aPresenter adapter widget.
	widget removeMorph: morph
]
