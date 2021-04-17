"
I'm an adapter for Box Layouts.
A paned layout will split (horizontally or vertically) panels (in fixed yet proportional spaces).
"
Class {
	#name : #SpMorphicBoxAdapter,
	#superclass : #SpMorphicLayoutAdapter,
	#instVars : [
		'startPanel',
		'endPanel'
	],
	#category : #'Spec2-Adapters-Morphic-Layout'
}

{ #category : #factory }
SpMorphicBoxAdapter >> add: aPresenter [
 
	self add: aPresenter constraints: SpBoxConstraints new
]

{ #category : #private }
SpMorphicBoxAdapter >> addConstraints: constraints toChild: childMorph [
	"Adds constraits by child"
	| theMorph |
	
	layout isHomogeneous 
		ifTrue: [ self addHomogeneousToMorph: childMorph ].
	theMorph := self addPadding: constraints padding toMorph: childMorph.
	constraints isExpand 
		ifTrue: [ 
			"if is not 'fill', in fact I need to pad it with another (since it 'expands', 
			 but does not 'fills')"
			constraints isFill ifFalse: [ 
				theMorph
					hResizing: #rigid;
					vResizing: #rigid.
				theMorph := self newPanel
					addMorphBack: theMorph;
					yourself ]. 
			"Set to fill"
			theMorph 
				hResizing: #spaceFill;
				vResizing: #spaceFill ]
		ifFalse: [
			"Set morph to stay rigid"
			layout direction setRigidityOfNonExpandedMorph: theMorph.
			constraints width ifNotNil: [ :w | theMorph width: w ].
			constraints height ifNotNil: [ :h | theMorph height: h ] ].
	
	^ theMorph 
]

{ #category : #private }
SpMorphicBoxAdapter >> addHomogeneousToMorph: aMorph [
	
	^ layout direction addHomogeneousToMorph: aMorph into: self
]

{ #category : #private }
SpMorphicBoxAdapter >> addHorizontalHomogeneousToMorph: aMorph [
	| size |
	
	self children ifEmpty: [ ^ self ].
	size := (widget width - (layout borderWidth * 2) - (layout spacing * (self children size - 1))) // self children size.
	aMorph 
		width: size;
		minWidth: size
]

{ #category : #private }
SpMorphicBoxAdapter >> addHorizontalPadding: aNumber toMorph: aMorph [

	^ self newWrapMorph
		  hResizing: aMorph hResizing;
		  vResizing: aMorph vResizing;
		  width: aMorph width + (aNumber * 2);
		  height: aMorph height;
		  addMorph: (aMorph
			   hResizing: #spaceFill;
			   vResizing: #spaceFill;
			   yourself)
		  fullFrame: (LayoutFrame identity
			   leftOffset: aNumber;
			   rightOffset: aNumber negated);
		  yourself
]

{ #category : #private }
SpMorphicBoxAdapter >> addPadding: aNumber toMorph: aMorph [
	
	aNumber = 0 ifTrue: [ ^ aMorph ].
	
	^ layout direction 
		addPadding: aNumber 
		toMorph: aMorph
		into: self
]

{ #category : #private }
SpMorphicBoxAdapter >> addVerticalHomogeneousToMorph: aMorph [
	| size |

	self children ifEmpty: [ ^ self ].

	size := (widget height - (layout borderWidth * 2) - (layout spacing * (self children size - 1))) // self children size.
	aMorph height: size.
	aMorph vResizing: #spaceFill.
]

{ #category : #private }
SpMorphicBoxAdapter >> addVerticalPadding: aNumber toMorph: aMorph [

	^ self newWrapMorph
		  hResizing: aMorph hResizing;
		  vResizing: aMorph vResizing;
		  width: aMorph width;
		  height: aMorph height + (aNumber * 2);
		  addMorph: (aMorph
			   hResizing: #spaceFill;
			   vResizing: #spaceFill;
			   yourself)
		  fullFrame: (LayoutFrame identity
			   topOffset: aNumber;
			   bottomOffset: aNumber negated);
		  yourself
]

{ #category : #private }
SpMorphicBoxAdapter >> applyAlignmentTo: aWidget [

	layout isVertical
		ifTrue: [ 
			layout vAlign ifNotNil: [ :align | 
				startPanel vResizing: #shrinkWrap.
				aWidget listCentering: align asMorphicAlign ].
			layout hAlign ifNotNil: [ :align | 
				startPanel hResizing: #shrinkWrap.
				aWidget wrapCentering: align asMorphicAlign.
				aWidget cellPositioning: align asMorphicAlign ] ]
		ifFalse: [ 
			layout vAlign ifNotNil: [ :align | 
				startPanel vResizing: #shrinkWrap.
				aWidget wrapCentering: align asMorphicAlign.
				aWidget cellPositioning: align asMorphicAlign ].
			layout hAlign ifNotNil: [ :align | 
				startPanel hResizing: #shrinkWrap.
				aWidget listCentering: align asMorphicAlign ] ].

	^ aWidget
]

{ #category : #private }
SpMorphicBoxAdapter >> applyAlignmentToChild: aWidget [

	layout vAlign 
		ifNotNil: [ aWidget vResizing: #rigid ].
	layout hAlign 
		ifNotNil: [ aWidget hResizing: #rigid ]

]

{ #category : #private }
SpMorphicBoxAdapter >> basicAdd: aPresenter constraints: constraints to: aPanel [
	| childMorph |

	childMorph := self buildMorph: aPresenter constraints: constraints.	

	self applyAlignmentToChild: childMorph.
	self verifyBoxExtentOf: aPanel withChild: childMorph.

	constraints isPlacedAtStart
		ifTrue: [ startPanel addMorphBack: childMorph ]
		ifFalse: [ endPanel addMorphBack: childMorph ].

	^ childMorph
]

{ #category : #accessing }
SpMorphicBoxAdapter >> children [

	^ startPanel submorphs, endPanel submorphs
]

{ #category : #accessing }
SpMorphicBoxAdapter >> childrenWidgets [
	
	^ self children
]

{ #category : #factory }
SpMorphicBoxAdapter >> layout: aLayout [

	layout := aLayout.
	
	widget ifNil: [
		"build of widget was differed up to here (to know what is the direction)"
		widget := aLayout direction newWidgetOn: self.
		widget borderWidth: aLayout borderWidth.
		aLayout hasAlignment 
			ifTrue: [ widget := self applyAlignmentTo: widget ].
		"the spacing needs to be applied to the inner sub-panels"
		{ startPanel. endPanel } 
			do: [ :each | each cellInset: aLayout spacing ]
		"widget homogeneous: aLayout isHomogeneous" ].

	aLayout whenChildrenAddedDo: [ :ann |
		self
			add: ann child
			constraints: (aLayout constraintsFor: ann child) ].
	
	aLayout whenChildrenRemovedDo: [ :ann |
		self remove: ann child ].
	
	super layout: aLayout
]

{ #category : #factory }
SpMorphicBoxAdapter >> newHorizontal [

	^ self newPanel
		listDirection: #leftToRight;
		addMorphBack: ((startPanel := self newPanel)
			listDirection: #leftToRight;
			yourself);
		addMorphBack: ((endPanel := self newPanel)
			listDirection: #leftToRight;
			hResizing: #shrinkWrap;
			width: 0;
			yourself);
	  yourself
]

{ #category : #factory }
SpMorphicBoxAdapter >> newVertical [

	^ self newPanel
		listDirection: #topToBottom;
		addMorphBack: ((startPanel := self newPanel)
			listDirection: #topToBottom;
			yourself);
		addMorphBack: ((endPanel := self newPanel)
			listDirection: #topToBottom;
			vResizing: #shrinkWrap;
			height: 0;
			yourself);
		yourself
]

{ #category : #private }
SpMorphicBoxAdapter >> newWrapMorph [

	^ Morph new
		  layoutPolicy: ProportionalLayout new;
		  color: Color transparent;
		  borderColor: Color transparent yourself
]

{ #category : #accessing }
SpMorphicBoxAdapter >> remove: aPresenter [

	| morph |
	morph := aPresenter adapter widget.	
	startPanel removeMorph: morph.
	endPanel removeMorph: morph.
	self verifyBoxExtent
	
]

{ #category : #accessing }
SpMorphicBoxAdapter >> removeAll [

	startPanel removeAllMorphs.
	endPanel removeAllMorphs.
	self verifyBoxExtent
]

{ #category : #factory }
SpMorphicBoxAdapter >> removeSubWidgets [

	startPanel removeAllMorphs.
	endPanel removeAllMorphs
]

{ #category : #accessing }
SpMorphicBoxAdapter >> replace: aPresenter with: otherPresenter [

	| panel oldMorph newMorph |	
	oldMorph := aPresenter adapter widget.
	panel := (startPanel submorphs includes: oldMorph)
		ifTrue: [ startPanel ] 
		ifFalse: [ endPanel ].
	
	newMorph := self 
		buildMorph: otherPresenter 
		constraints: (layout constraintsFor: otherPresenter).	
	panel replaceSubmorph: oldMorph by: newMorph
]

{ #category : #accessing }
SpMorphicBoxAdapter >> replace: aPresenter with: otherPresenter withConstraints: constraints [

	| panel oldMorph newMorph |	
	oldMorph := aPresenter adapter widget.
	panel := (startPanel submorphs includes: oldMorph)
		ifTrue: [ startPanel ] 
		ifFalse: [ endPanel ].
	
	newMorph := self buildMorph: otherPresenter constraints: constraints.
	panel replaceSubmorph: oldMorph by: newMorph
]

{ #category : #updating }
SpMorphicBoxAdapter >> updateSpacing [

	{ startPanel. endPanel } 
			do: [ :each | each cellInset: layout spacing ]
]

{ #category : #private }
SpMorphicBoxAdapter >> verifyBoxExtent [

	(startPanel hasSubmorphs not and: [ endPanel hasSubmorphs not ])
		ifTrue: [ widget extent: 0@0 ]
]

{ #category : #private }
SpMorphicBoxAdapter >> verifyBoxExtentOf: aPanel withChild: childMorph [
	| width height |

	width := childMorph width + (widget borderWidth * 2).
	height := childMorph height + (widget borderWidth * 2).

	layout isVertical 
		ifTrue: [ height := height + aPanel height + aPanel cellInset ]
		ifFalse: [ width := width + aPanel width + aPanel cellInset ].
		 
	aPanel extent: (aPanel width max: width)@(aPanel height max: height)
]
