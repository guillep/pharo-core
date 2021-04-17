"
I'm a table layout for PanedLayouts. 
I add some posibilities to layouting (like defining the initial position in proportional 
numbers instead a fixed number).

This is needed because sometimes I want to express a position like: 

SpecPanedLayout new 
	position: 80 percent;
	...
	
instead a fixed number I may change in other places.
 
"
Class {
	#name : #SpMorphicPanedLayout,
	#superclass : #TableLayout,
	#instVars : [
		'position'
	],
	#category : #'Spec2-Adapters-Morphic-Layout'
}

{ #category : #private }
SpMorphicPanedLayout >> ensureHeightPosition: aMorph in: aRect [
	| firstMorph height |

	self position ifNil: [ ^ self ].

	firstMorph := aMorph submorphs first.
	firstMorph vResizing = #rigid 
		ifFalse: [ firstMorph vResizing: #rigid ].
	height := self heightPositionIn: aRect extent.
	firstMorph height = height
		ifFalse: [ firstMorph height: height ]
]

{ #category : #private }
SpMorphicPanedLayout >> ensureWidthPosition: aMorph in: aRect [
	| firstMorph width |

	self position ifNil: [ ^ self ].

	firstMorph := aMorph submorphs first.
	firstMorph hResizing = #rigid 
		ifFalse: [ firstMorph hResizing: #rigid ].
	width := self widthPositionIn: aRect extent.
	firstMorph width = width 
		ifFalse: [ firstMorph width: width ].
	 
]

{ #category : #private }
SpMorphicPanedLayout >> heightPositionIn: aPoint [ 

	^ self position < 1 
		ifTrue: [ (aPoint y * self position) asInteger ]
		ifFalse: [ self position ]
]

{ #category : #testing }
SpMorphicPanedLayout >> isHorizontal [

	^ (properties listDirection == #topToBottom 
		or: [ properties listDirection == #bottomToTop ]) not
]

{ #category : #private }
SpMorphicPanedLayout >> layoutLeftToRight: aMorph in: newBounds [

	self ensureWidthPosition: aMorph in: newBounds.
	super layoutLeftToRight: aMorph in: newBounds
]

{ #category : #private }
SpMorphicPanedLayout >> layoutTopToBottom: aMorph in: newBounds [

	self ensureHeightPosition: aMorph in: newBounds.
	super layoutTopToBottom: aMorph in: newBounds
]

{ #category : #accessing }
SpMorphicPanedLayout >> position [
	^ position
]

{ #category : #accessing }
SpMorphicPanedLayout >> position: anObject [
	position := anObject
]

{ #category : #accessing }
SpMorphicPanedLayout >> preservePositionProportionOn: layoutedMorph [

	| referenceMorph |
	referenceMorph := layoutedMorph submorphs first.
	position := self isHorizontal
		            ifTrue: [ (referenceMorph width * 100 / layoutedMorph width) asInteger percent ]
		            ifFalse: [ (referenceMorph height * 100 / layoutedMorph height) asInteger percent ]
]

{ #category : #accessing }
SpMorphicPanedLayout >> resetPosition [

	position := nil
]

{ #category : #private }
SpMorphicPanedLayout >> widthPositionIn: aPoint [

	^ self position < 1
		  ifTrue: [ (aPoint x * self position) asInteger ]
		  ifFalse: [ self position ]
]
