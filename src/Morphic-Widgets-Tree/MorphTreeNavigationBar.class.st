"
I'm a pager control used to navigate in a MorphTreeMorph that has a lot of entries.

You can see one of my subclass in action using:
""May take a while to open""
ClassListExample new open
"
Class {
	#name : #MorphTreeNavigationBar,
	#superclass : #TreeNavigationBarMorph,
	#category : #'Morphic-Widgets-Tree-Pagination'
}

{ #category : #testing }
MorphTreeNavigationBar class >> isDeprecated [ 
	^ true
]
