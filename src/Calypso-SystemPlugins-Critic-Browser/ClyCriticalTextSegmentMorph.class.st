"
I am a slight modification of the rubric text segment morph which creates custom menu items for displaying critiques
"
Class {
	#name : #ClyCriticalTextSegmentMorph,
	#superclass : #RubTextSegmentMorph,
	#instVars : [
		'entity',
		'critique'
	],
	#category : #'Calypso-SystemPlugins-Critic-Browser'
}

{ #category : #actions }
ClyCriticalTextSegmentMorph >> addItemToMenu: aMenu [
	| listItem |
	listItem := ClyCritiqueMenuItemMorph new
		layoutPolicy: TableLayout new;
		listDirection: #leftToRight;
		cellPositioning: #center;
		hResizing: #spaceFill;
		vResizing: #shrinkWrap;
		cellInset: 5;
		color: Color transparent;
		"layoutInset: (Margin left: 0 top: 0 right: 10 bottom: 0);"
			yourself.
	listItem addMorphBack: (ImageMorph withForm: critique icon).
	listItem addMorphBack: critique title asStringMorph.
	critique actions
		do: [ :action | 
			listItem
				addMorphBack:
					(IconicButtonMorph new
						target: action;
						labelGraphic: action icon;
						actionSelector: #actOnCritic:ofEntity:;
						arguments:
							{critique.
							entity};
						color: Color transparent;
						helpText: action description;
						extent: 16 @ 16;
						borderWidth: 0;
						yourself) ].
	^ aMenu addMenuItem: listItem
]

{ #category : #accessing }
ClyCriticalTextSegmentMorph >> critique [
	^ critique
]

{ #category : #accessing }
ClyCriticalTextSegmentMorph >> critique: anObject [
	critique := anObject
]

{ #category : #accessing }
ClyCriticalTextSegmentMorph >> entity [
	^ entity
]

{ #category : #accessing }
ClyCriticalTextSegmentMorph >> entity: anObject [
	entity := anObject
]
