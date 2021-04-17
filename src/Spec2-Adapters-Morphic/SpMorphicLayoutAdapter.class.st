"
I'm a base adapter for layouts.
"
Class {
	#name : #SpMorphicLayoutAdapter,
	#superclass : #SpAbstractMorphicAdapter,
	#instVars : [
		'layout'
	],
	#category : #'Spec2-Adapters-Morphic-Layout'
}

{ #category : #accessing }
SpMorphicLayoutAdapter >> adapter [
	
	^ nil
]

{ #category : #accessing }
SpMorphicLayoutAdapter >> add: aPresenter constraints: constraints [
 
	aPresenter owner: self model. 
	self widgetDo: [ :aPanel |
		self 
			basicAdd: aPresenter
			constraints: constraints 
			to: aPanel ]
]

{ #category : #private }
SpMorphicLayoutAdapter >> addConstraints: constraints toChild: childMorph [

	self subclassResponsibility
]

{ #category : #initialization }
SpMorphicLayoutAdapter >> addKeyBindingsTo: aMorph [
	"This is called before the layout actually exists. 
	 Skipping it."
	
]

{ #category : #private }
SpMorphicLayoutAdapter >> applyChildrenAlignmentTo: childMorph constraints: constraints [
	"When it applies (like the case of SpGridLayout), widgets may want to configure alignment 
	 here."
	
	^ childMorph
]

{ #category : #styling }
SpMorphicLayoutAdapter >> applyStyle: aPresenter to: aMorph [
	self flag: #TODO. "This is a HACK, to apply styles just when I'm using new layouts 
	(otherwise, it interferes on how the old layout is displayed). 
	 Of course, this needs to be applied where it belongs, but for now we need to keep 
	 it this way :("
	
	aPresenter adapter ifNil: [ ^ self ].
	aPresenter adapter applyStyle: aMorph
]

{ #category : #private }
SpMorphicLayoutAdapter >> basicAdd: aPresenter constraints: constraints to: aPanel [ 

	self subclassResponsibility
]

{ #category : #private }
SpMorphicLayoutAdapter >> buildMorph: aPresenter constraints: constraints [ 
	| childMorph |
	
	childMorph := aPresenter buildWithSpec: constraints spec.
	self applyStyle: aPresenter to: childMorph.
	"Add children alignment constraints (if applies)"
	childMorph := self 
		applyChildrenAlignmentTo: childMorph 
		constraints: constraints. 
	childMorph := self 
		addConstraints: constraints 
		toChild: childMorph.
	
	^ childMorph
]

{ #category : #building }
SpMorphicLayoutAdapter >> buildWidget [

	^ nil
]

{ #category : #building }
SpMorphicLayoutAdapter >> buildWithSpec [
	
	^ self widget
]

{ #category : #building }
SpMorphicLayoutAdapter >> buildWithSpec: aString [ 

	^ self buildWithSpec
]

{ #category : #accessing }
SpMorphicLayoutAdapter >> children [

	^ self subclassResponsibility
]

{ #category : #testing }
SpMorphicLayoutAdapter >> isEmpty [

	^ self children isEmpty
]

{ #category : #protocol }
SpMorphicLayoutAdapter >> layout: aLayout [

	"Basic apply visibility to the widget.
	This call is here because layouts and widgets work differently"
	self applyVisibility.
	self applyStyle
]

{ #category : #factory }
SpMorphicLayoutAdapter >> newPanel [

	^ Morph new
		  changeTableLayout;
		  hResizing: #spaceFill;
		  vResizing: #spaceFill;
		  color: Color transparent;
		  borderColor: Color transparent;
		  clipSubmorphs: true;
		  "stop being grabbed"beSticky;
		  borderWidth: 0;
		  extent: 0 @ 0;
		  yourself
]

{ #category : #initialization }
SpMorphicLayoutAdapter >> replaceLayoutWith: aLayout [ 

	| oldAdapter |
	self widget owner ifNil: [ ^ self ].

	oldAdapter := self.
	self model adapter: (aLayout
		buildAdapterFor: self model
		bindings: self model application adapterBindings).
		
	oldAdapter widget owner 
		replaceSubmorph: oldAdapter widget  
		by: self model adapter widget
]

{ #category : #protocol }
SpMorphicLayoutAdapter >> takeKeyboardFocus [

	self presenter presentersInFocusOrder 
		ifNotEmpty: [ :presenters | presenters first takeKeyboardFocus ]
]

{ #category : #updating }
SpMorphicLayoutAdapter >> updateBorderWidth [

	widget borderWidth: layout borderWidth
]
