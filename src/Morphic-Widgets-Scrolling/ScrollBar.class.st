"
Inspired by an oiginal design of Hans-Martin Mosner, this ScrollBar is intended to exercise the handling of input events in Morphic.  With sufficient flexibility in this area, all particular behavior can be concentrated in this single class with no need to specialize any other morphs to achieve button, slider and menu-button behavior.

Once we have this working, put in logic for horizontal operation as well.

CachedImages was added to reduce the number of forms created and thrown away. This will be helpful for Nebraska and others as well.
"
Class {
	#name : #ScrollBar,
	#superclass : #ScrollBarMorph,
	#category : #'Morphic-Widgets-Scrolling'
}

{ #category : #testing }
ScrollBar class >> isDeprecated [ 
	^ true
]
