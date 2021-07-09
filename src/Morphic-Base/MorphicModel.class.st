"
MorphicModels are used to represent structures with state and behavior as well as graphical structure.  A morphicModel is usually the root of a morphic tree depicting its appearance.  The tree is constructed concretely by adding its consituent morphs to a world.

When a part is named in a world, it is given a new slot in the model.  When a part is sensitized, it is named, and a set of mouse-driven methods is also generated in the model.  These may be edited to induce particular behavior.  When a variable is added through the morphic world, it is given a slot in the model, along with a set of access methods.

In addition for public variables (and this is the default for now), methods are generated and called in any outer model in which this model gets embedded, thus propagating variable changes outward.
"
Class {
	#name : #MorphicModel,
	#superclass : #ModelMorphic,
	#category : #'Morphic-Base-Kernel'
}

{ #category : #testing }
MorphicModel class >> isDeprecated [ 
	^ true
]
