"
Morph with an inset border by default and theme access. Overrides openModal: to allow multiple free example dialogs to be presented.
"
Class {
	#name : #ExampleBuilderMorph,
	#superclass : #ModelMorphic,
	#traits : 'TEasilyThemed',
	#classTraits : 'TEasilyThemed classTrait',
	#category : #'Morphic-Examples-Widgets'
}

{ #category : #services }
ExampleBuilderMorph >> chooseColor: aColor title: label [
	"Answer the user choice of a colour."
	
	^ self theme 
		chooseColorIn: self modalMorph
		title: (label ifNil: ['Choose Color' translated])
		color: aColor
]
