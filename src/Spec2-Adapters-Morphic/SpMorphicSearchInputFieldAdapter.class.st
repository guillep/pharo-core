"
I'm a morphic adapter to provide a search input field
"
Class {
	#name : #SpMorphicSearchInputFieldAdapter,
	#superclass : #SpMorphicTextInputFieldAdapter,
	#category : #'Spec2-Adapters-Morphic-Base'
}

{ #category : #factory }
SpMorphicSearchInputFieldAdapter >> buildWidget [
	| textMorph iconsContainer |
	
	textMorph := super buildWidget.

	iconsContainer := Morph new
		extent: 12 @ 12;
		color: Color transparent;
		changeTableLayout;
		listDirection: #topToBottom;
		addMorph: (IconicButtonMorph new
			target: self;
			actionSelector: #clearText;
			labelGraphic: (self iconNamed: #windowCloseInactive);
			color: Color transparent;
			extent: 16 @ 8;
			borderWidth: 0;
			yourself);
		yourself.

	"With the layout frame I set next it, the arrows will be at the top right of the 
	 text morph. We should be able to make it vertically centered but I don't know 
	 how to do that with morphs. If someone knows, please do :)"
	textMorph
		changeProportionalLayout;
		addMorph: iconsContainer
			fullFrame: (LayoutFrame identity
				bottomFraction: 0;
				leftFraction: 1;
				topOffset: 4;
				leftOffset: -25;
				yourself).

	^ textMorph
]

{ #category : #actions }
SpMorphicSearchInputFieldAdapter >> clearText [

	self widgetDo: [ :w | w setTextWith: '' ] 
]
