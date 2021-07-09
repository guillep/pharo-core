"
Morph with an inset border by default and theme access.
"
Class {
	#name : #ComposableMorph,
	#superclass : #ModelMorphic,
	#traits : 'TEasilyThemed',
	#classTraits : 'TEasilyThemed classTrait',
	#category : #'Polymorph-Widgets-Base'
}

{ #category : #initialization }
ComposableMorph >> defaultBorderColor [
	"Answer the default border color/fill style for the receiver"
	
	^#inset
]

{ #category : #initialization }
ComposableMorph >> defaultBorderWidth [
	"Answer the default border width for the receiver."
	
	^ 1
]

{ #category : #accessing }
ComposableMorph >> defaultTitle [
	"Answer the default title label for the receiver."

	^'Composite' translated
]

{ #category : #'instance creation' }
ComposableMorph >> newWindow [
	"Answer a new window with the receiver as model,
	except when the receiver is a morph."

	|w|
	w := StandardWindow new
		model: (self isMorph ifFalse: [self]);
		title: self defaultTitle;
		addMorph: self
		fullFrame: LayoutFrame identity;
		yourself.
	self borderWidth: 0.
	^w
]
