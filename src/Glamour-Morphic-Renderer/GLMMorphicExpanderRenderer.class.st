Class {
	#name : #GLMMorphicExpanderRenderer,
	#superclass : #GLMMorphicBrowserRenderer,
	#category : #'Glamour-Morphic-Renderer'
}

{ #category : #rendering }
GLMMorphicExpanderRenderer >> render: aBrowser [
	^ self renderWithExpanders: aBrowser   
]

{ #category : #rendering }
GLMMorphicExpanderRenderer >> renderWithExpanders: aBrowser [
	| morph scroll panel expander |
	panel := GLMPanelMorph new.
	panel 
		fillStyle: Color transparent;
		hResizing: #spaceFill;
		vResizing: #shrinkWrap;
		changeTableLayout;
		layoutInset: 2;
		cellInset: 2.
	scroll := GeneralScrollPaneMorph new.
	scroll 
		changeScrollerTableLayout;
		scrollTarget: panel.
	aBrowser panes do: [:each |
		expander := ExpanderMorph titleText: (each presentations titleValue ifNil: ['noname']).
		morph := GLMMorphicPaneWithoutTitleRenderer new render: each.
		morph 
			borderStyle: (UITheme current buttonSelectedBorderStyleFor: morph).
		expander addMorphBack: morph.
		panel addMorph: expander	].
	^ scroll
]

{ #category : #rendering }
GLMMorphicExpanderRenderer >> renderWithTree: aBrowser [
	| treeMorph treeModel |
	treeModel := GLMExpanderTreeMorphModel new glamourExpander: aBrowser.
	treeMorph := MorphTreeMorph new.
	treeMorph
		makeLastColumnUnbounded;
		getMenuSelector: #menu:shifted:;
		cornerStyle: treeMorph preferredCornerStyle;
		borderStyle: (BorderStyle inset width: 1);
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		layoutFrame: (LayoutFrame identity);
		preferedPaneColor: Color white;	
		model: treeModel;
		columns: ( OrderedCollection with: (MorphTreeColumn new rowMorphGetSelector: #elementColumn)).
	treeMorph vShowScrollBar.
	aBrowser when: GLMBrowserClosed send: #actOnBrowserClosed: to: self.
	^ treeMorph buildContents
]
