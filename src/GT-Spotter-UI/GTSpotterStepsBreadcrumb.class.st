Class {
	#name : #GTSpotterStepsBreadcrumb,
	#superclass : #GLMBrick,
	#instVars : [
		'spotterModel',
		'items',
		'band',
		'animation'
	],
	#category : #'GT-Spotter-UI-Widgets'
}

{ #category : #'adding/removing' }
GTSpotterStepsBreadcrumb >> addItem: aBrick [

	aBrick width: [ :itemBrick | self calculateItemWidth: itemBrick ].
	aBrick layout widthDependency: self.
	
	self items size = 1 ifTrue: [
		self items first labelBrick paddingLeft: self themer spotterThemer breadcrumbSeparatorWidth / 2 ].
	
	self items addLast: aBrick.
	self band addBrickBack: aBrick.
	self items do: [ :b | b wrappedBounds markWidthDirty ].
	self band doLayoutForce.
]

{ #category : #'adding/removing' }
GTSpotterStepsBreadcrumb >> addSeparator [
	|separator|
	separator := self newSeparator.
	self themer spotterThemer breadcrumbSeparatorStyleFor: separator.
	self themer spotterThemer breadcrumbSeparatorWidgetStyleFor: separator.
	self band addBrickBack: separator
]

{ #category : #accessing }
GTSpotterStepsBreadcrumb >> animation [

	^ animation
]

{ #category : #accessing }
GTSpotterStepsBreadcrumb >> band [

	^ band
]

{ #category : #accessing }
GTSpotterStepsBreadcrumb >> band: aBrick [

	band := aBrick.
	band
		useHorizontalLinearLayout;
		hShrinkWrap;
		vSpaceFill.
	
	self band data: 0.
	self addBrickBack: band.
]

{ #category : #geometry }
GTSpotterStepsBreadcrumb >> calculateItemWidth: aBrick [
	|sWidth bWidth singleWidth lastWidth|
	sWidth := self themer spotterThemer breadcrumbSeparatorWidth.
	bWidth := self width.
	lastWidth := ((aBrick labelBrick approximateWidth min: (bWidth / 2)) max: ((bWidth - ((self maxNumberOfSteps - 1) * sWidth)) / self maxNumberOfSteps)) floor.
	singleWidth := ((bWidth - lastWidth - ((self maxNumberOfSteps - 1) * sWidth)) / (self maxNumberOfSteps - 1)) floor.
	
	"width of other bricks depends on the width of the last one"
	^ aBrick isLastInOwner
		ifTrue: [
			self items size >= self maxNumberOfSteps ifTrue: [ |fullWidth delta|
				fullWidth := lastWidth + ((self maxNumberOfSteps - 1) * (sWidth + singleWidth)).
				delta := bWidth - fullWidth.
				lastWidth := lastWidth + delta ].
			lastWidth ]
		ifFalse: [ singleWidth ]
	
]

{ #category : #accessing }
GTSpotterStepsBreadcrumb >> defaultBreadcrumbHeight [

	^ self themer spotterThemer breadcrumbHeight + self themer spotterThemer breadcrumbTriangleHeight
]

{ #category : #geometry }
GTSpotterStepsBreadcrumb >> glmAnimateBrickBounds: aValue duration: anInteger callback: aBlock [

	self animation ifNotNil: #terminate.
	animation := GLMAnimation new
		linear;
		duration: anInteger;
		from: self band brickBounds left;
		to: self band brickBounds left + aValue;
		onCompleted: aBlock;
		animation: [ :b :v | b changedWith: [ b translateXTo: v asInteger; data: b brickBounds left ] ];
		animate: self band
]

{ #category : #initialization }
GTSpotterStepsBreadcrumb >> initialize [
	super initialize.
	
	self band: self newBand
]

{ #category : #testing }
GTSpotterStepsBreadcrumb >> isVisible [

	^ self items isEmpty not
]

{ #category : #accessing }
GTSpotterStepsBreadcrumb >> items [

	^ items ifNil: [ items := OrderedCollection new ]
]

{ #category : #accessing }
GTSpotterStepsBreadcrumb >> maxNumberOfSteps [
	^ 5
]

{ #category : #'instance creation' }
GTSpotterStepsBreadcrumb >> newBand [

	^ GLMBrick new
]

{ #category : #'instance creation' }
GTSpotterStepsBreadcrumb >> newSeparator [

	^ GLMBrick new
]

{ #category : #notifying }
GTSpotterStepsBreadcrumb >> notifyBreadcrumbVisibilityChanged [

	self announcer announce: GTSpotterBreadcrumbVisibilityChanged new
]

{ #category : #'brick-layout-events' }
GTSpotterStepsBreadcrumb >> onChildrenLayouted [
	super onChildrenLayouted.
	
	self band translateXTo: (self band data ifNil: [ 0 ]).
	self scrollToTheLastOne
]

{ #category : #'events-processing' }
GTSpotterStepsBreadcrumb >> onStepAdded: ann [
	|step origin previousStep selectedCandidate|
	
	self spotterModel steps size <= 1 ifTrue: [
		^ self push: (GTSpotterStepBreadcrumbItem new
						text: self spotterModel steps first origin displayString;
						stepModel: self spotterModel steps first) ].
	
	step := ann stepModel.
	previousStep := (step spotter steps at: step spotter steps size - 1).
	selectedCandidate := previousStep selected candidate.
	origin := step origin.
	
	self push: (GTSpotterStepBreadcrumbItem new
		stepModel: step;
		text: ((selectedCandidate = origin)
			ifTrue: [ (previousStep selected renderingProcessor render: selectedCandidate) labelBrick text ]
			ifFalse: [ (origin isKindOf: Collection)
				ifTrue: [ step processors first title ]
				ifFalse: [ origin displayString] ]))
]

{ #category : #'events-processing' }
GTSpotterStepsBreadcrumb >> onStepPopped [

	self pop
	
]

{ #category : #'brick-properties-events' }
GTSpotterStepsBreadcrumb >> onThemerChanged [
	super onThemerChanged.
	
	self band subbricks withIndexDo: [ :each :index | index even ifTrue: [ self themer spotterThemer breadcrumbSeparatorWidgetStyleFor: each ] ]
]

{ #category : #'adding/removing' }
GTSpotterStepsBreadcrumb >> pop [
	
	self band layoutAfter: [
		self band removeBrick: self items removeLast.
		self items size = 1 ifTrue: [
			self items first labelBrick paddingLeft: 0 ].
		self items isEmpty ifFalse: [ self popSeparator ].
		self items do: [ :b | b wrappedBounds markWidthDirty ] ].
	
	"optimization. if last item was popped we need to update root to reposition all brick,
	otherwise only I need to be updated"
	self items size = 0
		ifTrue: [ self notifyBreadcrumbVisibilityChanged ]
		ifFalse: [
			self items last showTriangle.
			self scrollToTheLastOne.
			self changed ]
]

{ #category : #'adding/removing' }
GTSpotterStepsBreadcrumb >> popSeparator [

	self band removeBrick: self band lastSubbrick
]

{ #category : #'adding/removing' }
GTSpotterStepsBreadcrumb >> push: aBrick [

	self themer spotterThemer breadcrumbItemStyleFor: aBrick.
	
	self band layoutAfter: [
		self items isEmpty ifFalse: [
			self items last hideTriangle.
			self addSeparator ].
		self addItem: aBrick ].
	
	"optimization. if first item was added we need to update root to reposition all bricks,
	otherwise only I need to be updated"
	self items size = 1
		ifTrue: [ self notifyBreadcrumbVisibilityChanged ]
		ifFalse: [
			self scrollToTheLastOne.
			self changed ].
	
]

{ #category : #geometry }
GTSpotterStepsBreadcrumb >> scrollToTheLastOne [
	|leftDelta rightDelta delta|
	self items isEmpty ifTrue: [ ^ self ].
	
	rightDelta := self globalBounds right - self band globalBounds right.
	leftDelta := self globalBounds left - self band globalBounds left.
			
	"all visible, return"
	(leftDelta = 0  and: [ self items size <= self maxNumberOfSteps ]) ifTrue: [ ^ self ].
	
	delta := (self items size <= self maxNumberOfSteps) ifTrue: [ leftDelta ] ifFalse: [ rightDelta ].
	delta := self band brickBounds left + delta - self band data.
	
	self
		glmAnimateBrickBounds: delta
		duration: 400
		callback: nil.
	
	
]

{ #category : #accessing }
GTSpotterStepsBreadcrumb >> spotterModel [
	^ spotterModel
]

{ #category : #accessing }
GTSpotterStepsBreadcrumb >> spotterModel: aSpotterModel [
	
	spotterModel := aSpotterModel.
	
	spotterModel announcer when: GTSpotterStepAdded send: #onStepAdded: to: self.
	spotterModel announcer when: GTSpotterStepPopped send: #onStepPopped to: self.
]
