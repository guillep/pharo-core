"
I represent the context of given browser tab (tool).
I show kind of path to the tab model.
For example for the method editor it would be package/class string.

In addition I provide a button to force browser to restore state when the tool was created.
I simply ask the tool: 

	ownerTool restoreBrowserState
 

"
Class {
	#name : #ClyToolContextNavigatorMorph,
	#superclass : #ClyStatusBarItemMorph,
	#category : #'Calypso-Browser-UI'
}

{ #category : #building }
ClyToolContextNavigatorMorph >> build [
	| goButton contextLabel |
	contextLabel := ownerTool printContext.
	contextLabel ifEmpty: [ ^self ]. "if ownerTool not defines meaningfull context name we ignore it"
	self addMorphBack: (self iconNamed: #uncommentedClass) asMorph.
	self addMorphBack: contextLabel asMorph.
	goButton := IconicButtonMorph new
		target: self;
		actionSelector: #restoreBrowserState;
		arguments: {};
		labelGraphic: (self iconNamed: #forward);
		color: Color transparent;
		helpText: 'Move browser to ', contextLabel;
		borderWidth: 0.
	self addMorphBack: goButton
]

{ #category : #operations }
ClyToolContextNavigatorMorph >> restoreBrowserState [
	ownerTool restoreBrowserState 
]
