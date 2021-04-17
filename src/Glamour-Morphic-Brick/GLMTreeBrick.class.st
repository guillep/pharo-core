Class {
	#name : #GLMTreeBrick,
	#superclass : #GLMBandBrick,
	#category : #'Glamour-Morphic-Brick-Widgets-UI'
}

{ #category : #examples }
GLMTreeBrick class >> exampleOpen [
	self gtExample openInBrickWindowLabeled: 'Tree Example'
	
]

{ #category : #examples }
GLMTreeBrick class >> gtExample [
	<gtExample>
	<label: 'Simple tree with a few elements'>
	
	^ self new
		hSpaceFill;
		vShrinkWrap;
		on: {
			'First' -> '1'.
			'Second' -> '2'.
			'Third' -> { 
				'Sub First' -> '3-1'.
				'Sub Second' -> '3-2' } }
	
]

{ #category : #accessing }
GLMTreeBrick >> collapsableFor: anObject [
	|collapsable|
	
	collapsable := GLMCollapsableBrick new.
	collapsable
		vShrinkWrap;
		hSpaceFill.
	
	collapsable headerBrick: (self headerFor: anObject in: collapsable).
	(self hasChildren: anObject)
		ifTrue: [
			collapsable contentBrick: (self class new on: anObject value).
			collapsable contentBrick
				vShrinkWrap;
				hSpaceFill;
				marginLeft: 19 ].
	collapsable expand.
	^ collapsable
]

{ #category : #protocol }
GLMTreeBrick >> hasChildren: anObject [

	anObject ifNil: [ ^ false ].
	anObject isVariableBinding ifFalse: [ ^ false ].
	anObject value ifNil: [ ^ false ].
	anObject value isCollection ifTrue: [ ^ anObject value isEmpty not ].
	^ true
]

{ #category : #accessing }
GLMTreeBrick >> headerFor: anObject in: aCollapsable [
	|header|
	
	header := GLMBrick new.
	header
		hSpaceFill;
		vShrinkWrap.
		
	header addBrickBack:
		((anObject isVariableBinding
			ifTrue: [ anObject key asBrick ]
			ifFalse: [ anObject asBrick ])
				hSpaceFill).
				
	(self hasChildren: anObject) ifTrue: [
		header addBrickFirst: (self newToggleButtonFor: aCollapsable) ].
	
	^ header
]

{ #category : #'instance creation' }
GLMTreeBrick >> newToggleButtonFor: aCollapsable [

	^ (GLMActionButtonBrick new
			icon: GLMUIThemeExtraIcons glamorousRight;
			checkedImage: GLMUIThemeExtraIcons glamorousDown;
			height: [ :b | b icon height * 1.2 ];
			width: [ :b | b icon width * 1.2 ];
			action: [ :b | 
				aCollapsable toggle.
				aCollapsable isExpanded
					ifTrue: [ b check ]
					ifFalse: [ b uncheck ] ])
]

{ #category : #'instance creation' }
GLMTreeBrick >> on: anObject [
	"{ 'first'-> { 'sub 1' -> '11' . 'sub 2' -> '12' } }"
	
	self removeAllBricks.
	(anObject isCollection & anObject isString not)
		ifFalse: [ self addBrickBack: (self collapsableFor: anObject) ]
		ifTrue: [ anObject do: [ :each | self addBrickBack: (self collapsableFor: each) ] ].
	
	
]
