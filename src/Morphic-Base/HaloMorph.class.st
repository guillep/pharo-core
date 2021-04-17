"
This morph provides a halo of handles for its target morph. Dragging, duplicating, rotating, and resizing to be done by mousing down on the appropriate handle. There are also handles for help and for a menu of infrequently used operations.
"
Class {
	#name : #HaloMorph,
	#superclass : #Morph,
	#instVars : [
		'target',
		'innerTarget',
		'positionOffset',
		'angleOffset',
		'growingOrRotating',
		'directionArrowAnchor',
		'haloBox',
		'originalExtent',
		'nameMorph'
	],
	#classVars : [
		'CurrentHaloSpecifications',
		'HaloEnclosesFullBounds',
		'HaloWithDebugHandle',
		'ShowBoundsInHalo'
	],
	#category : #'Morphic-Base-Widgets'
}

{ #category : #'halo theme' }
HaloMorph class >> allHaloSpecsFromArray: anArray [
	^ anArray collect: [:quin | self haloSpecFromArray: quin]
]

{ #category : #'halo theme' }
HaloMorph class >> classicHaloSpecifications [
	"Non-iconic halos with traditional placements"

	"
	self installHaloTheme: #classicHaloSpecifications
	will result in the standard default halos being reinstalled"
	"NB: listed below in clockwise order"

		^ #(
	"  	selector				horiz		vert			color info						icon key
		---------				------		-----------		-------------------------------		---------------"
	(addMenuHandle:		left			top				(red)							none)
	(addDismissHandle:		leftCenter	top				(red		muchLighter)			#haloDismissIcon)
	(addGrabHandle:			center		top				(black)							none)
	(addDragHandle:			rightCenter	top				(brown)							none)
	(addDupHandle:			right		top				(green)							none)	
	(addDebugHandle:		right		topCenter		(blue	veryMuchLighter)		none)
	(addGrowHandle:		right		bottom			(yellow)						none)
	(addScaleHandle:		right		bottom			(lightOrange)					none)
	(addFontEmphHandle:	rightCenter	bottom			(lightBrown darker)				none)
	(addFontStyleHandle:		center		bottom			(lightRed)						none)
	(addFontSizeHandle:		leftCenter	bottom			(lightGreen)						none)

	(addRecolorHandle:		right		bottomCenter	(magenta darker)				none)

	(addRotateHandle:		left			bottom			(blue)							none))


]

{ #category : #'halo theme' }
HaloMorph class >> currentHaloSpecifications [
	^ CurrentHaloSpecifications ifNil: [self installHaloTheme: #iconicHaloSpecifications]

]

{ #category : #'halo theme' }
HaloMorph class >> customHaloSpecifications [
	"Intended for you to modify to suit your personal preference.  What is implemented in the default here is just a skeleton; in comment at the bottom of this method are some useful lines you may wish to paste in to the main body here, possibly modifying positions, colors, etc..
	Note that in this example, we include:
			Dismiss handle, at top-left
			Menu handle, at top-right
			Resize handle, at bottom-right
			Rotate handle, at bottom-left
			Drag handle, at top-center
			Recolor handle, at left-center.  (this one is NOT part of the standard formulary --
											it is included here to illustrate how to
 											add non-standard halos)
			Note that the optional handles for specialized morphs, such as Sketch, Text, PasteUp, are also included"

	^ #(
	(addDismissHandle:		left			top				(red		muchLighter)			#haloDismissIcon)
	(addMenuHandle:		right		top				(red)							#haloMenuIcon)
	(addDragHandle:			center	top					(brown)							#haloDragIcon)
	(addGrowHandle:		right		bottom			(yellow)						#haloScaleIcon)
	(addScaleHandle:		right		bottom			(lightOrange)					#haloScaleIcon)

	(addRecolorHandle:		left			center			(green muchLighter lighter)		#haloRecolorIcon)
	(addFontSizeHandle:		leftCenter	bottom			(lightGreen)						#haloFontSizeIcon)
	(addFontStyleHandle:		center		bottom			(lightRed)						#haloFontStyleIcon)
	(addFontEmphHandle:	rightCenter	bottom			(lightBrown darker)				#haloFontEmphIcon)
	(addRotateHandle:		left			bottom			(blue)							#haloRotIcon)

	(addDebugHandle:		right		topCenter		(blue	veryMuchLighter)		#haloDebugIcon) )

	"  Other useful handles...

  		selector				horiz		vert			color info						icon key
		---------				------		-----------		-------------------------------		---------------

	(addTileHandle:			left			bottomCenter	(lightBrown)					#haloTileIcon)
	(addViewHandle:			left			center			(cyan)							#haloViewIcon)
	(addGrabHandle:			center		top				(black)							#haloGrabIcon)
	(addDragHandle:			rightCenter	top				(brown)							#haloDragIcon)
	(addDupHandle:			right		top				(green)							#haloDupIcon)	
	(addHelpHandle:			center		bottom			(lightBlue)						#haloHelpIcon)
	(addFewerHandlesHandle:	left		topCenter		(paleBuff)						#haloFewerHandlesIcon)
	(addPaintBgdHandle:		right		center			(lightGray)						#haloPaintIcon)
	"

]

{ #category : #settings }
HaloMorph class >> haloEnclosesFullBounds [
	^ HaloEnclosesFullBounds ifNil: [HaloEnclosesFullBounds := false]
]

{ #category : #settings }
HaloMorph class >> haloEnclosesFullBounds: aBoolean [
	HaloEnclosesFullBounds := aBoolean
]

{ #category : #'halo theme' }
HaloMorph class >> haloSpecFromArray: anArray [ 
	| aColor |
	aColor := Color.
	anArray fourth
		do: [:sel | aColor := aColor perform: sel].
	^ HaloSpec new
		horizontalPlacement: anArray second
		verticalPlacement: anArray third
		color: aColor
		iconSymbol: anArray fifth
		addHandleSelector: anArray first 
]

{ #category : #'halo theme' }
HaloMorph class >> haloSpecificationsForWorld [
	| desired |
	"Answer a list of HaloSpecs that describe which halos 
	are to be used on a world halo, what they should 
	look like, and where they should be situated"

	desired := #(addDebugHandle: addMenuHandle:   addHelpHandle:  addRecolorHandle:).
	^ self currentHaloSpecifications 
		select: [:spec | desired includes: spec addHandleSelector]
]

{ #category : #settings }
HaloMorph class >> haloWithDebugHandle [
	^ HaloWithDebugHandle ifNil: [HaloWithDebugHandle := true]
]

{ #category : #settings }
HaloMorph class >> haloWithDebugHandle: aBoolean [
	 HaloWithDebugHandle := aBoolean
]

{ #category : #'halo theme' }
HaloMorph class >> iconicHaloSpecifications [
	"Answer an array that characterizes the locations, colors, icons, and selectors of the halo handles that may be used in the iconic halo scheme"

	"self installHaloTheme: #iconicHaloSpecifications"

	^ #(
	"  	selector				horiz		vert			color info						icon key
		---------				------		-----------		-------------------------------		---------------"
	(addCollapseHandle:		left			topCenter		(tan)							#haloCollapseIcon)
	(addDebugHandle:		right		topCenter		(blue	veryMuchLighter)		#haloDebugIcon)
	(addDismissHandle:		left			top				(red		muchLighter)			#haloDismissIcon)
	(addRotateHandle:		left			bottom			(blue)							#haloRotIcon)
	(addMenuHandle:		leftCenter	top				(red)							#haloMenuIcon)
	(addGrabHandle:			center		top				(black)							#haloGrabIcon)
	(addDragHandle:			rightCenter	top				(brown)							#haloDragIcon)
	(addDupHandle:			right		top				(green)							#haloDupIcon)	
	(addHelpHandle:			center		bottom			(lightBlue)						#haloHelpIcon)
	(addGrowHandle:		right		bottom			(yellow)						#haloScaleIcon)
	(addScaleHandle:		right		bottom			(lightOrange)					#haloScaleIcon)
	(addFontSizeHandle:		leftCenter	bottom			(lightGreen)						#haloFontSizeIcon)
	(addFontStyleHandle:		center		bottom			(lightRed)						#haloFontStyleIcon)
	(addFontEmphHandle:	rightCenter	bottom			(lightBrown darker)				#haloFontEmphIcon)
	(addRecolorHandle:		right		bottomCenter	(magenta darker)				#haloRecolorIcon) )

]

{ #category : #'halo theme' }
HaloMorph class >> initialize [
	"self initialize"
	
	self installHaloTheme: #iconicHaloSpecifications

]

{ #category : #'halo theme' }
HaloMorph class >> installHaloTheme: haloSpecificationsSelector [
	^ CurrentHaloSpecifications := self allHaloSpecsFromArray: (self perform: haloSpecificationsSelector).

]

{ #category : #settings }
HaloMorph class >> showBoundsInHalo [
	^ ShowBoundsInHalo ifNil: [ShowBoundsInHalo := false]
]

{ #category : #settings }
HaloMorph class >> showBoundsInHalo: aBoolean [
	ShowBoundsInHalo := aBoolean
]

{ #category : #'halo theme' }
HaloMorph class >> simpleFullHaloSpecifications [
	"This method gives the specs for the 'full' handles variant when simple halos are in effect"

	"
	self installHaloTheme: #simpleFullHaloSpecifications
	will result in the standard default halos being reinstalled"
	"NB: listed below in clockwise order"

	^ #(
	"  	selector				horiz		vert			color info						icon key
		---------				------		-----------		-------------------------------		---------------"
	(addDebugHandle:		right		topCenter		(blue	veryMuchLighter)		#haloDebugIcon)
	(addDismissHandle:		left			top				(red		muchLighter)			#haloDismissIcon)
	(addRotateHandle:		left			bottom			(blue)							#haloRotIcon)
	(addMenuHandle:		leftCenter	top				(red)							#haloMenuIcon)
	(addGrabHandle:			center		top				(black)							#halograbIcon)
	(addDragHandle:			rightCenter	top				(brown)							#haloDragIcon)
	(addDupHandle:			right		top				(green)							#haloDupIcon)	
	(addHelpHandle:			center		bottom			(lightBlue)						#haloHelpIcon')
	(addGrowHandle:		right		bottom			(yellow)						#haloScaleIcon)
	(addScaleHandle:		right		bottom			(lightOrange)					#haloScaleIcon)
	(addFewerHandlesHandle:	left		topCenter		(paleBuff)						#haloFewerHandlesIcon')
	(addFontSizeHandle:		leftCenter	bottom			(lightGreen)						#haloFontSizeIcon)
	(addFontStyleHandle:		center		bottom			(lightRed)						#haloFontStyleIcon)
	(addFontEmphHandle:	rightCenter	bottom			(lightBrown darker)		  		#haloFontEmphIcon)
	(addRecolorHandle:		right		bottomCenter	(magenta darker)				#haloRecolorIcon) ) 
]

{ #category : #private }
HaloMorph >> addCircleHandles [
	| box |
	target isWorldMorph ifTrue: [^ self addHandlesForWorldHalos].

	self removeAllMorphs.  "remove old handles, if any"
	self bounds: (self worldBoundsForMorph: target renderedMorph).  "update my size"
	box := self basicBox.

	target addHandlesTo: self box: box.

	self addName.
	growingOrRotating := false.
	self layoutChanged.
	self changed.

]

{ #category : #handles }
HaloMorph >> addCollapseHandle: handleSpec [
	"Add the collapse handle, with all of its event handlers set up, unless the target's owner is not the world or the hand."

	| collapseHandle |
	(target owner notNil "nil happens, amazingly"
			and: [target owner isWorldOrHandMorph])
		ifFalse: [^ self].
	collapseHandle := self addHandle: handleSpec
		on: #mouseDown send: #mouseDownInCollapseHandle:with: to: self.
	collapseHandle on: #mouseUp send: #maybeCollapse:with: to: self.
	collapseHandle on: #mouseMove send: #setDismissColor:with: to: self

]

{ #category : #handles }
HaloMorph >> addDebugHandle: handleSpec [
	self class haloWithDebugHandle ifTrue:
		[self addHandle: handleSpec
			on: #mouseDown send: #doDebug:with: to: self]

]

{ #category : #private }
HaloMorph >> addDirectionHandles [

	| centerHandle d w directionShaft patch patchColor crossHairColor |
	self showingDirectionHandles ifFalse: [^ self].

	directionArrowAnchor := (target point: target referencePosition in: self world) rounded.
	patch := target imageFormForRectangle: (Rectangle center: directionArrowAnchor extent: 3@3).
	patchColor := patch colorAt: 1@1.

	(directionShaft := LineMorph newSticky makeForwardArrow)
		borderWidth: 2; borderColor: (Color green orColorUnlike: patchColor).
	self positionDirectionShaft: directionShaft.
	self addMorphFront: directionShaft.
	directionShaft setCenteredBalloonText: 'Set forward direction' translated;
		on: #mouseDown send: #doDirection:with: to: self;
		on: #mouseMove send: #trackDirectionArrow:with: to: self;
		on: #mouseUp send: #setDirection:with: to: self.

	d := 15.  "diameter"  w := 3.  "borderWidth"
	crossHairColor := Color red orColorUnlike: patchColor.
	(centerHandle := EllipseMorph newBounds: (0@0 extent: d@d) color: Color transparent)
			borderWidth: w; borderColor: (Color blue orColorUnlike: patchColor);
			addMorph: (LineMorph from: (d//2)@w to: (d//2)@(d-w-1) color: crossHairColor width: 1) lock;
			addMorph: (LineMorph from: w@(d//2) to: (d-w-1)@(d//2) color: crossHairColor width: 1) lock;
			align: centerHandle bounds center with: directionArrowAnchor.
	centerHandle wantsYellowButtonMenu: false.
	self addMorph: centerHandle.
	centerHandle setCenteredBalloonText: 'Rotation center (hold down the shift key and drag from here to change it)' translated;
			on: #mouseDown send: #prepareToTrackCenterOfRotation:with: to: self;
			on: #mouseMove send: #trackCenterOfRotation:with: to: self;
			on: #mouseUp send: #setCenterOfRotation:with: to: self

]

{ #category : #handles }
HaloMorph >> addDismissHandle: handleSpec [ 
	"Add the dismiss handle according to the spec, unless my target resists
	dismissal "
	| dismissHandle |
	target okayToAddDismissHandle
		ifTrue: [dismissHandle := self
						addHandle: handleSpec
						on: #mouseDown
						send: #mouseDownInDimissHandle:with:
						to: self.
			dismissHandle 
				on: #mouseUp
				send: #maybeDismiss:with:
				to: self.
			dismissHandle
				on: #mouseDown
				send: #setDismissColor:with:
				to: self.
			dismissHandle
				on: #mouseMove
				send: #setDismissColor:with:
				to: self]
]

{ #category : #handles }
HaloMorph >> addDragHandle: haloSpec [
	(self addHandle: haloSpec on: #mouseDown send: #startDrag:with: to: self)
		on: #mouseMove send: #doDrag:with: to: self



]

{ #category : #handles }
HaloMorph >> addDupHandle: haloSpec [
	"Add the halo that offers duplication, or, when shift is down, make-sibling"

	self addHandle: haloSpec on: #mouseDown send: #doDup:with: to: self


]

{ #category : #handles }
HaloMorph >> addFontEmphHandle: haloSpec [ 
	(innerTarget isTextMorph) 
		ifTrue: 
			[self 
				addHandle: haloSpec
				on: #mouseDown
				send: #chooseEmphasisOrAlignment
				to: innerTarget]
]

{ #category : #handles }
HaloMorph >> addFontSizeHandle: haloSpec [ 
	(innerTarget isTextMorph) 
		ifTrue: 
			[self 
				addHandle: haloSpec
				on: #mouseDown
				send: #chooseFont
				to: innerTarget]
]

{ #category : #handles }
HaloMorph >> addFontStyleHandle: haloSpec [ 
	(innerTarget isTextMorph) 
		ifTrue: 
			[self 
				addHandle: haloSpec
				on: #mouseDown
				send: #chooseStyle
				to: innerTarget]
]

{ #category : #private }
HaloMorph >> addFullHandles [
	self addCircleHandles
]

{ #category : #handles }
HaloMorph >> addGrabHandle: haloSpec [
	"If appropriate, add the black halo handle for picking up the target"

	self addHandle: haloSpec on: #mouseDown send: #doGrab:with: to: self


]

{ #category : #private }
HaloMorph >> addGraphicalHandle: formKey at: aPoint on: eventName send: selector to: recipient [
	"Add the supplied form as a graphical handle centered at the given point, and set it up to respond to the given event by sending the given selector to the given recipient.  Return the handle."
	| handle |
	handle := self addGraphicalHandleFrom: formKey at: aPoint.
	handle on: eventName send: selector to: recipient.
	handle setBalloonText: (target balloonHelpTextForHandle: handle) translated.
	^ handle

]

{ #category : #private }
HaloMorph >> addGraphicalHandleFrom: formKey at: aPoint [
	"Add the supplied form as a graphical handle centered at the given point.  Return the handle."
	| handle aForm |
	aForm := Smalltalk ui icons
		iconNamed: formKey 
		ifNone: [ self iconNamed: #solidMenuIcon ].
	handle := ImageMorph new form: aForm; bounds: (Rectangle center: aPoint extent: aForm extent).
	handle wantsYellowButtonMenu: false.
	self addMorph: handle.
	handle on: #mouseUp send: #endInteraction to: self.
	^ handle

]

{ #category : #handles }
HaloMorph >> addGrowHandle: haloSpec [
	target shouldFlex ifFalse: 
		[(self addHandle: haloSpec
				on: #mouseDown send: #startGrow:with: to: self)
				on: #mouseMove send: #doGrow:with: to: self]
	"This or addScaleHandle:, but not both, will prevail at any one time"

]

{ #category : #private }
HaloMorph >> addHandle: handleSpec on: eventName send: selector to: recipient [ 
	"Add a handle within the halo box as per the haloSpec, and set 
	it up to respond to the given event by sending the given 
	selector to the given recipient. Return the handle."
	| handle aPoint |
	aPoint := self
				positionIn: haloBox
				horizontalPlacement: handleSpec horizontalPlacement
				verticalPlacement: handleSpec verticalPlacement.
	handle := self
				addHandleAt: aPoint
				color: (Color colorFrom: handleSpec color)
				icon: handleSpec iconSymbol
				on: eventName
				send: selector
				to: recipient.
	^ handle
]

{ #category : #private }
HaloMorph >> addHandleAt: aPoint color: aColor icon: iconName on: eventName send: selector to: recipient [ 
	"Add a handle centered at the given point with the given color, 
	and set it up to respond to the given event by sending the 
	given selector to the given recipient. Return the handle."
	| handle |
	handle := self createHandleAt: aPoint color: aColor iconName: iconName.
	self addMorph: handle.

	handle on: #mouseUp send: #endInteraction to: self.
	handle on: eventName send: selector to: recipient.
	handle setBalloonText: (target balloonHelpTextForHandle: handle) translated.

	^ handle 
]

{ #category : #private }
HaloMorph >> addHandleAt: aPoint color: aColor on: eventName send: selector to: recipient [
	^ self addHandleAt: aPoint color: aColor icon: nil on: eventName send: selector to: recipient

]

{ #category : #private }
HaloMorph >> addHandles [
	self addCircleHandles.

]

{ #category : #private }
HaloMorph >> addHandlesForWorldHalos [
	"Add handles for world halos, like the man said"

	| box w |
	w := self world ifNil:[target world].
	self removeAllMorphs.  "remove old handles, if any"
	self bounds: target bounds.
	box := w bounds insetBy: 9.
	target addWorldHandlesTo: self box: box.

	self addNameBeneath: (box insetBy: (0@0 corner: 0@10)) string: innerTarget externalName.
	growingOrRotating := false.
	self layoutChanged.
	self changed.

]

{ #category : #handles }
HaloMorph >> addHelpHandle: haloSpec [
	target balloonText ifNotNil:
		[(self addHandle: haloSpec on: #mouseDown send: #mouseDownOnHelpHandle: to: innerTarget)
			on: #mouseUp send: #deleteBalloon to: innerTarget]

]

{ #category : #handles }
HaloMorph >> addMenuHandle: haloSpec [
	self addHandle: haloSpec on: #mouseDown send: #doMenu:with: to: self
]

{ #category : #private }
HaloMorph >> addName [
	"Add a name readout at the bottom of the halo."
	self addNameBeneath: self basicBox string: target externalName

]

{ #category : #private }
HaloMorph >> addNameBeneath: outerRectangle string: aString [
	"Add a name display centered beneath the bottom of the outer rectangle. Return the handle."

	| namePosition w |
	w := self world ifNil:[target world].
	
	nameMorph := StringMorph contents: aString font: StandardFonts haloFont.
	nameMorph 
	wantsYellowButtonMenu: false;
	color: self theme balloonTextColor;
	backgroundColor: self theme balloonBackgroundColor;
	target: innerTarget.
	
	namePosition := outerRectangle bottomCenter -
		((nameMorph width // 2) @ (self handleSize negated // 2 - 1)).
		
	nameMorph position: (namePosition min: w viewBox bottomRight - nameMorph extent y + 2).
	self addMorph: nameMorph.
	^ nameMorph
]

{ #category : #handles }
HaloMorph >> addRecolorHandle: haloSpec [
	"Add a recolor handle to the receiver, if appropriate"

	"since this halo now opens a more general properties panel, allow it in all cases"
	"innerTarget canSetColor ifTrue:"

	self addHandle: haloSpec on: #mouseUp send: #doRecolor:with: to: self.
]

{ #category : #handles }
HaloMorph >> addRotateHandle: haloSpec [
	(self addHandle: haloSpec on: #mouseDown send: #startRot:with: to: self)
		on: #mouseMove send: #doRot:with: to: self


]

{ #category : #handles }
HaloMorph >> addScaleHandle: haloSpec [
	target shouldFlex ifTrue: 
		[(self addHandle: haloSpec
				on: #mouseDown send: #startScale:with: to: self)
				on: #mouseMove send: #doScale:with: to: self].
	"This or addGrowHandle:, but not both, will prevail at any one time"

]

{ #category : #private }
HaloMorph >> addSimpleHandlesForWorldHalos [
	"Nothing special at present here -- just use the regular handles.  Cannot rotate or resize world"

	self addHandlesForWorldHalos

]

{ #category : #'halos and balloon help' }
HaloMorph >> addSimpleHandlesTo: aHaloMorph box: aBox [
	| aHandle |

	target isWorldMorph ifTrue: [^ self addSimpleHandlesForWorldHalos].

	self removeAllMorphs.  "remove old handles, if any"
	
	self bounds: (self worldBoundsForMorph: target renderedMorph).  "update my size"
	
	self addHandleAt: (((aBox topLeft + aBox leftCenter) // 2) + self simpleFudgeOffset) color: Color paleBuff icon: #haloMoreHandlesIcon
		on: #mouseDown send: #addFullHandles to: self.

	aHandle := self addGraphicalHandle: #rotateIcon at: aBox bottomLeft on: #mouseDown send: #startRot:with: to: self.
	aHandle on: #mouseMove send: #doRot:with: to: self.

	target shouldFlex
		ifTrue: [(self addGraphicalHandle: #scaleIcon at: aBox bottomRight  on: #mouseDown send: #startScale:with: to: self)
				on: #mouseMove send: #doScale:with: to: self]
		ifFalse: [(self addGraphicalHandle: #scaleIcon at: aBox bottomRight on: #mouseDown send: #startGrow:with: to: self)
				on: #mouseMove send: #doGrow:with: to: self].

	growingOrRotating := false.
	self layoutChanged.
	self changed.

]

{ #category : #private }
HaloMorph >> basicBox [
	| aBox minSide anExtent w |
	minSide := 4 * self handleSize.
	anExtent := ((self width + self handleSize + 8) max: minSide) @
				((self height + self handleSize + 8) max: minSide).
	aBox := Rectangle center: self center extent: anExtent.
	w := self world ifNil:[target outermostWorldMorph].
	^ w
		ifNil:
			[aBox]
		ifNotNil:
			[aBox intersect: (w viewBox insetBy: 8@8) ifNone: [self error: 'should not happen' ]]

]

{ #category : #private }
HaloMorph >> basicBoxForSimpleHalos [
	| w |
	w := self world ifNil:[target outermostWorldMorph].
	^ ((self worldBoundsForMorph: target topRendererOrSelf) expandBy: self handleAllowanceForIconicHalos)
			intersect: (w bounds insetBy: 8@8) ifNone: [self error: 'should not happen' ]

]

{ #category : #'meta-actions' }
HaloMorph >> blueButtonDown: event [
	"Transfer the halo to the next likely recipient"
	target ifNil:[^self delete].
	event hand obtainHalo: self.
	positionOffset := event position - (target point: target position in: owner).
	"wait for drags or transfer"
	event hand 
		waitForClicksOrDrag: self 
		event: event
		selectors: { #transferHalo:. nil. nil. #dragTarget:. }
		threshold: 5.
]

{ #category : #accessing }
HaloMorph >> borderStyle [
	"Answer the border style to use for the receiver.
	Depends on the target and on some settings."
	
	^(target notNil and: [self showBoundsInHalo and: [target isWorldMorph not]])
		ifTrue: [super borderStyle]
		ifFalse: [SimpleBorderStyle width: 0 color: Color transparent]
]

{ #category : #updating }
HaloMorph >> changed [
	"Quicker to invalidate handles individually if target is large (especially the world)"

	self extent > (200@200)
		ifTrue: [(target notNil and: [target ~~ self world]) ifTrue:
					["Invalidate 4 outer strips first, thus subsuming separate damage."
					(self fullBounds areasOutside: target bounds) do:
						[:r | self invalidRect: r]].
				self submorphsDo: [:m | m changed]]
		ifFalse: [super changed].

]

{ #category : #'geometry testing' }
HaloMorph >> containsPoint: aPoint [ 
	"This method is overridden so that, once up, the handles will stay up as long as the mouse is within the box that encloses all the handles even if it is not over any handle or over its owner."

	^ target ifNil: [super containsPoint: aPoint] ifNotNil: [false]
]

{ #category : #'events-processing' }
HaloMorph >> containsPoint: aPoint event: anEvent [
	"Blue buttons are handled by the halo"
	(anEvent isMouse and:[anEvent isMouseDown and:[anEvent blueButtonPressed]])
		ifFalse:[^super containsPoint: aPoint event: anEvent].
	^bounds containsPoint: anEvent position
]

{ #category : #private }
HaloMorph >> createHandleAt: aPoint color: aColor iconName: iconName [

	| bou handle |

	bou := Rectangle center: aPoint extent: self handleSize asPoint.
	self gradientHalo
		ifTrue: [ handle := Morph newBounds: bou color: aColor.
			handle borderWidth: 1.
			handle useRoundedCorners.
			handle borderColor: aColor muchDarker.
			self setColor: aColor toHandle: handle
			]
		ifFalse: [ 
			handle := EllipseMorph newBounds: bou color: aColor.
			handle borderWidth: 0 ].
	handle wantsYellowButtonMenu: false.
	iconName
		ifNotNil: [ ( self iconNamed: iconName )
				ifNotNil: [ :form | 
					| image |

					image := ImageMorph new.
					image form: form.
					image color: aColor contrastingBlackAndWhiteColor.
					image lock.
					handle addMorphCentered: image
					]
			].
	^ handle
]

{ #category : #initialization }
HaloMorph >> defaultColor [
	"Answer the default color/fill style for the receiver."
	
	^Color transparent
]

{ #category : #'submorphs-add/remove' }
HaloMorph >> delete [
	"Delete the halo.  Tell the target that it no longer has the halo; accept any pending edits to the name; and then  actually delete myself"

	target ifNotNil: [target hasHalo: false].
	super delete.
]

{ #category : #private }
HaloMorph >> directionArrowLength [
	^ 25
]

{ #category : #private }
HaloMorph >> doDebug: evt with: menuHandle [
	"Ask hand to invoke the a debugging menu for my inner target.  If shift key is down, immediately put up an inspector on the inner target"

	| menu |
	"self obtainHaloForEvent: evt andRemoveAllHandlesBut: nil."
	self world displayWorld.
	evt shiftPressed ifTrue: 
		[self delete.
		^ innerTarget inspectInMorphic: evt].

	menu := innerTarget buildDebugMenu: evt hand.
	menu buildTitle: [ :menuTitle | menuTitle
		title: (innerTarget externalName asString truncateWithElipsisTo: 40);
		"icon: Smalltalk ui icons smallDebugIcon;"
		withCloseBox;
		withPinBox
	];
	popUpEvent: evt in: self world
]

{ #category : #private }
HaloMorph >> doDirection: anEvent with: directionHandle [
	anEvent hand obtainHalo: self.
	self removeAllHandlesBut: directionHandle
]

{ #category : #private }
HaloMorph >> doDrag: evt with: dragHandle [
	| thePoint |
	evt hand obtainHalo: self.
	thePoint := target point: evt position - positionOffset from: owner.
	target setConstrainedPosition:  thePoint hangOut: true.

]

{ #category : #private }
HaloMorph >> doDup: evt with: dupHandle [
	"Ask hand to duplicate my target."

	(target isKindOf: SelectionMorph) ifTrue:
		[^ target doDup: evt fromHalo: self handle: dupHandle].

	self obtainHaloForEvent: evt andRemoveAllHandlesBut: dupHandle.
	self setTarget: (target duplicateMorph: evt).
	evt hand grabMorph: target.
	self step. "update position if necessary"
	evt hand addMouseListener: self. "Listen for the drop"
]

{ #category : #private }
HaloMorph >> doGrab: evt with: grabHandle [
	"Ask hand to grab my target."

	self obtainHaloForEvent: evt andRemoveAllHandlesBut: grabHandle.
	evt hand grabMorph: target.
	self step. "update position if necessary"
	evt hand addMouseListener: self. "Listen for the drop"
]

{ #category : #private }
HaloMorph >> doGrow: evt with: growHandle [
	"Called while the mouse is down in the grow handle"

	| newExtent extentToUse scale |
	growingOrRotating ifFalse: [ ^self ].
	evt hand obtainHalo: self.
	newExtent := (target pointFromWorld: (evt cursorPoint - positionOffset)) - target topLeft.
	evt shiftPressed ifTrue: [
		scale := (newExtent x / (originalExtent x max: 1)) min:
					(newExtent y / (originalExtent y max: 1)).
		newExtent := (originalExtent x * scale) asInteger @ (originalExtent y * scale) asInteger
	].
	(newExtent x < 1 or: [newExtent y < 1 ]) ifTrue: [^ self].
	target renderedMorph extent: (extentToUse := newExtent).
	growHandle position: evt cursorPoint - (growHandle extent // 2).
	self layoutChanged.

]

{ #category : #private }
HaloMorph >> doMenu: evt with: menuHandle [
	"Ask hand to invoke the halo menu for my inner target."

	| menu |
	self obtainHaloForEvent: evt andRemoveAllHandlesBut: nil.
	target world displayWorld.
	menu := innerTarget buildHandleMenu: evt hand.
	innerTarget addTitleForHaloMenu: menu.
	menu popUpEvent: evt in: target world.

]

{ #category : #private }
HaloMorph >> doRecolor: evt with: aHandle [
	"The mouse went down in the 'recolor' halo handle.  Allow the user to change the color of the innerTarget"

	evt hand obtainHalo: self.
	(aHandle containsPoint: evt cursorPoint)
		ifFalse:  "only do it if mouse still in handle on mouse up"
			[self delete.
			target addHalo: evt]
		ifTrue: [innerTarget changeColor].
			self showingDirectionHandles ifTrue: [self addHandles]
]

{ #category : #private }
HaloMorph >> doRot: evt with: rotHandle [
	"Update the rotation of my target if it is rotatable.  Keep the relevant command object up to date."

	| degrees |
	
	growingOrRotating ifFalse: [^self].
	evt hand obtainHalo: self.
	degrees := (evt cursorPoint - (target pointInWorld: target referencePosition)) degrees.
	degrees := degrees - angleOffset degrees.
	degrees := degrees detentBy: 10.0 atMultiplesOf: 90.0 snap: false.
	degrees = 0.0
		ifTrue: [self setColor: Color lightBlue toHandle: rotHandle]
		ifFalse: [self setColor: Color blue toHandle: rotHandle].
	rotHandle submorphsDo:
		[:m | m color: rotHandle color contrastingBlackAndWhiteColor].
	self removeAllHandlesBut: rotHandle.
	self showingDirectionHandles ifFalse:
		[self showDirectionHandles: true addHandles: false].
	self addDirectionHandles.
	target rotationDegrees: degrees.
	rotHandle position: evt cursorPoint - (rotHandle extent // 2).

]

{ #category : #private }
HaloMorph >> doScale: evt with: scaleHandle [
	"Update the scale of my target if it is scalable."
	| newHandlePos colorToUse |
	growingOrRotating ifFalse: [ ^self ].
	evt hand obtainHalo: self.
	newHandlePos := evt cursorPoint - (scaleHandle extent // 2).
	target scaleToMatch: newHandlePos.
	colorToUse := target scale = 1.0
						ifTrue: [Color yellow]
						ifFalse: [Color orange].
	self setColor: colorToUse toHandle: scaleHandle.
	scaleHandle
		submorphsDo: [:m | m color: colorToUse contrastingBlackAndWhiteColor].
	scaleHandle position: newHandlePos.

]

{ #category : #events }
HaloMorph >> dragTarget: event [
	"Begin dragging the target"
	| thePoint |
	thePoint := target point: event position - positionOffset from: owner.
	target setConstrainedPosition: thePoint hangOut: true.
	event hand newMouseFocus: self.
]

{ #category : #drawing }
HaloMorph >> drawSubmorphsOn: aCanvas [
	| alpha |
	((alpha := self magicAlpha) = 1.0)
		ifTrue:[^super drawSubmorphsOn: aCanvas].
	^super drawSubmorphsOn: (aCanvas asAlphaBlendingCanvas: alpha)
]

{ #category : #private }
HaloMorph >> endInteraction [
	"Clean up after a user interaction with the a halo control"

	| m |
	(target isInWorld not or: [owner isNil]) ifTrue: [^self].
	[target isFlexMorph and: [target hasNoScaleOrRotation]] whileTrue: 
			[m := target firstSubmorph.
			target removeFlexShell.
			target := m].
	self isInWorld 
		ifTrue: 
			["make sure handles show in front, even if flex shell added"
			self comeToFront.
			self addHandles].

]

{ #category : #settings }
HaloMorph >> gradientHalo [
	^ false
]

{ #category : #accessing }
HaloMorph >> haloBox: aBox [
	haloBox := aBox
]

{ #category : #settings }
HaloMorph >> haloEnclosesFullBounds [
	^ self class haloEnclosesFullBounds
]

{ #category : #private }
HaloMorph >> handleAllowanceForIconicHalos [
	^ 12
]

{ #category : #'events-processing' }
HaloMorph >> handleListenEvent: anEvent [
	"We listen for possible drop events here to add back those handles after a dup/grab operation"

	(anEvent isMouse and:[anEvent isMove not]) ifFalse:[^ self]. "not interested"
	anEvent hand removeMouseListener: self. "done listening"
	(self world ifNil: [target world]) ifNil: [^ self].
	self addHandles  "and get those handles back"
]

{ #category : #private }
HaloMorph >> handleSize [
	^ 30
]

{ #category : #'meta-actions' }
HaloMorph >> handlerForBlueButtonDown: anEvent [
	"Blue button was clicked within the receiver"
	^self
]

{ #category : #initialization }
HaloMorph >> initialize [
	super initialize.

	growingOrRotating := false.
	self borderStyle: (SimpleBorderStyle width: 2 color: self theme menuSelectionColor)
]

{ #category : #accessing }
HaloMorph >> innerTarget [

	^ innerTarget

]

{ #category : #testing }
HaloMorph >> isHaloMorph [ 

	^ true
]

{ #category : #'halos and balloon help' }
HaloMorph >> localHaloBoundsFor: aMorph [
	"aMorph may be in the hand and perhaps not in our world"

	| r |
	r := (self worldBoundsForMorph: aMorph) truncated.
	aMorph world = self world ifFalse: [^r].
	^((self transformFromOutermostWorld) globalBoundsToLocal: r) truncated
]

{ #category : #accessing }
HaloMorph >> magicAlpha [
	^self valueOfProperty: #magicAlpha ifAbsent:[1.0]
]

{ #category : #accessing }
HaloMorph >> magicAlpha: alpha [
	self setProperty: #magicAlpha toValue: alpha.
	self changed.
]

{ #category : #private }
HaloMorph >> maybeCollapse: evt with: collapseHandle [ 
	"Ask hand to collapse my target if mouse comes up in it."

	evt hand obtainHalo: self.
	self delete.
	(collapseHandle containsPoint: evt cursorPoint) 
		ifFalse: 
			[
			target addHalo: evt]
		ifTrue: 
			[
			target collapse]
]

{ #category : #private }
HaloMorph >> maybeDismiss: evt with: dismissHandle [ 
	"Ask hand to dismiss my target if mouse comes up
	in it." 

	| confirmed |
	evt hand obtainHalo: self.
	(dismissHandle containsPoint: evt cursorPoint)
		ifTrue: [
			target resistsRemoval ifTrue: [
				confirmed := self confirm: 'Really throw this away?' translated.
				confirmed ifFalse: [^ self]].
			evt hand removeHalo.
			self delete.
			target dismissViaHalo]
		ifFalse: [
			self delete.
			target addHalo: evt]
]

{ #category : #private }
HaloMorph >> maybeDoDup: evt with: dupHandle [
	evt hand obtainHalo: self.
	^ self doDup: evt with: dupHandle
]

{ #category : #'wiw support' }
HaloMorph >> morphicLayerNumber [

	"helpful for insuring some morphs always appear in front of or behind others.
	smaller numbers are in front"

	^7		"Halos are very front-like things"
]

{ #category : #private }
HaloMorph >> mouseDownInCollapseHandle: evt with: collapseHandle [
	"The mouse went down in the collapse handle; collapse the morph"

	self obtainHaloForEvent: evt andRemoveAllHandlesBut: collapseHandle.
	self setDismissColor: evt with: collapseHandle
]

{ #category : #private }
HaloMorph >> mouseDownInDimissHandle: evt with: dismissHandle [
	evt hand obtainHalo: self.
	self removeAllHandlesBut: dismissHandle.
	self setColor: Color darkGray toHandle: dismissHandle.

]

{ #category : #'event handling' }
HaloMorph >> mouseMove: evt [
	"Drag our target around"
	| thePoint |
	thePoint := target point: (evt position - positionOffset) from: owner.
	target setConstrainedPosition: thePoint hangOut: true.
]

{ #category : #private }
HaloMorph >> obtainHaloForEvent: evt andRemoveAllHandlesBut: aHandle [
	"Make sure the event's hand correlates with the receiver, and remove all handles except the given one.  If nil is provided as the handles argument, the result is that all handles are removed.  Note that any pending edits to the name-string in the halo are accepted at this time."

	evt hand obtainHalo: self.
	self removeAllHandlesBut: aHandle
]

{ #category : #events }
HaloMorph >> popUpFor: aMorph event: evt [

	"This message is sent by morphs that explicitly request the halo on a button click. Note: anEvent is in aMorphs coordinate frame."

	| hand anEvent |

	self flag: #workAround.	"We should really have some event/hand here..."
	anEvent := evt
		ifNil: [ hand := aMorph world ifNotNil: [ :w | w activeHand ].
			hand ifNil: [ hand := aMorph world primaryHand ].
			hand lastEvent transformedBy: ( aMorph transformedFrom: nil )
			]
		ifNotNil: [ hand := evt hand.
			evt
			].
	self target: aMorph.
	hand halo: self.
	hand world addMorphFront: self.
	positionOffset := anEvent position - ( aMorph point: aMorph position in: owner ).
	self startStepping
]

{ #category : #geometry }
HaloMorph >> position: pos [
	"Halos display imprefectly if their coordinates are non-integral
		-- especially the direction handles."

	^ super position: pos asIntegerPoint
]

{ #category : #private }
HaloMorph >> positionDirectionShaft: shaft [
	"Position the shaft."
	| alphaRadians unitVector | 
	"Pretty crude and slow approach at present, but a stake in the ground"
	alphaRadians := target heading degreesToRadians.
	unitVector := alphaRadians sin  @ alphaRadians cos negated.
	shaft setVertices: {unitVector * 6 + directionArrowAnchor.  "6 = radius of deadeye circle"
					unitVector * self directionArrowLength + directionArrowAnchor}

]

{ #category : #handles }
HaloMorph >> positionIn: aBox horizontalPlacement: horiz verticalPlacement: vert [
	| xCoord yCoord |

	horiz == #left
		ifTrue:	[xCoord := aBox left].
	horiz == #leftCenter
		ifTrue:	[xCoord := aBox left + (aBox width // 4)].
	horiz == #center
		ifTrue:	[xCoord := (aBox left + aBox right) // 2].
	horiz == #rightCenter
		ifTrue:	[xCoord := aBox left + ((3 * aBox width) // 4)].
	horiz == #right
		ifTrue:	[xCoord := aBox right].

	vert == #top
		ifTrue:	[yCoord := aBox top].
	vert == #topCenter
		ifTrue:	[yCoord := aBox top + (aBox height // 4)].
	vert == #center
		ifTrue:	[yCoord := (aBox top + aBox bottom) // 2].
	vert == #bottomCenter
		ifTrue:	[yCoord := aBox top + ((3 * aBox height) // 4)].
	vert == #bottom
		ifTrue:	[yCoord := aBox bottom].

	^ xCoord asInteger @ yCoord asInteger
]

{ #category : #private }
HaloMorph >> prepareToTrackCenterOfRotation: evt with: rotationHandle [
	evt hand obtainHalo: self.
	evt shiftPressed ifTrue:[
		self removeAllHandlesBut: rotationHandle.
	] ifFalse:[
		rotationHandle setProperty: #dragByCenterOfRotation toValue: true.
		self startDrag: evt with: rotationHandle
	].
	evt hand showTemporaryCursor: Cursor blank
]

{ #category : #'events-processing' }
HaloMorph >> rejectsEvent: anEvent [
	"Return true to reject the given event. Rejecting an event means neither the receiver nor any of it's submorphs will be given any chance to handle it."
	(super rejectsEvent: anEvent) ifTrue:[^true].
	anEvent isDropEvent ifTrue:[^true]. "never attempt to drop on halos"
	^false
]

{ #category : #private }
HaloMorph >> removeAllHandlesBut: aHandle [
	"Remove all handles except aHandle."
	submorphs copy do: [:m | m == aHandle ifFalse: [m delete]]

]

{ #category : #private }
HaloMorph >> setCenterOfRotation: evt with: rotationHandle [
	| localPt |
	evt hand obtainHalo: self.
	evt hand showTemporaryCursor: nil.
	(rotationHandle hasProperty: #dragByCenterOfRotation) ifFalse:[
		localPt := innerTarget transformFromWorld globalPointToLocal: rotationHandle center.
		innerTarget setRotationCenterFrom: localPt.
	].
	rotationHandle removeProperty: #dragByCenterOfRotation.
	self endInteraction

]

{ #category : #private }
HaloMorph >> setColor: aColor toHandle: aHandle [ 
	"private - change the color to the given handle, applying the 
	alternate look if corresponds"
	aHandle color: aColor.
	self gradientHalo
		ifTrue: [| fill | 
			fill := GradientFillStyle ramp: {0.0 -> aColor muchLighter. 1.0 -> aColor darker}.
			fill origin: aHandle topLeft.
			fill direction: aHandle extent.
			aHandle fillStyle: fill] 
]

{ #category : #private }
HaloMorph >> setDirection: anEvent with: directionHandle [
	"The user has let up after having dragged the direction arrow; now set the forward direction of the actual SketchMorph accordingly"
	anEvent hand obtainHalo: self.
	target setDirectionFrom: directionHandle center.
	self endInteraction
]

{ #category : #private }
HaloMorph >> setDismissColor: evt with: dismissHandle [
	"Called on mouseStillDown in the dismiss handle; set the color appropriately."

	| colorToUse |
	evt hand obtainHalo: self.
	colorToUse :=  (dismissHandle containsPoint: evt cursorPoint)
		ifFalse:
			[Color red muchLighter]
		ifTrue:
			[Color lightGray].
	self setColor: colorToUse toHandle: dismissHandle.

]

{ #category : #accessing }
HaloMorph >> setTarget: aMorph [
	"Private! Set the target without adding handles."

	target := aMorph topRendererOrSelf.
	innerTarget := target renderedMorph.
	innerTarget wantsDirectionHandles
		ifTrue: [self showDirectionHandles: true addHandles: false].
	target hasHalo: true.


]

{ #category : #settings }
HaloMorph >> showBoundsInHalo [
	^ self class showBoundsInHalo
]

{ #category : #private }
HaloMorph >> showDirectionHandles: wantToShow [

	self showDirectionHandles: wantToShow addHandles: true  "called from menu"

]

{ #category : #private }
HaloMorph >> showDirectionHandles: wantToShow addHandles: needHandles [ 
	directionArrowAnchor := wantToShow 
				ifTrue: [target referencePositionInWorld	"not nil means show"]
				ifFalse: [nil].
	needHandles ifTrue: [self addHandles] 
]

{ #category : #private }
HaloMorph >> showingDirectionHandles [
	^directionArrowAnchor notNil
]

{ #category : #private }
HaloMorph >> simpleFudgeOffset [
	"account for the difference in basicBoxes between regular and simple handles"

	^ 0@0

]

{ #category : #'dropping/grabbing' }
HaloMorph >> startDrag: evt with: dragHandle [
	"Drag my target without removing it from its owner."

	self obtainHaloForEvent: evt andRemoveAllHandlesBut: dragHandle.
	positionOffset := dragHandle center - (target point: target position in: owner).
]

{ #category : #private }
HaloMorph >> startGrow: evt with: growHandle [
	"Initialize resizing of my target.  Launch a command representing it, to support Undo"

	| botRt |
	growingOrRotating := true.
	self obtainHaloForEvent: evt andRemoveAllHandlesBut: growHandle.
	botRt := target point: target bottomRight in: owner.
	positionOffset := (self world viewBox containsPoint: botRt)
		ifTrue: [evt cursorPoint - botRt]
		ifFalse: [0@0].

	originalExtent := target extent
]

{ #category : #private }
HaloMorph >> startRot: evt with: rotHandle [
	"Initialize rotation of my target if it is rotatable"

	self obtainHaloForEvent: evt andRemoveAllHandlesBut: rotHandle.
	target prepareForRotating.
	growingOrRotating := true.
	angleOffset := evt cursorPoint - (target pointInWorld: target referencePosition).
	angleOffset := Point
			r: angleOffset r
			degrees: angleOffset degrees - target rotationDegrees.


]

{ #category : #private }
HaloMorph >> startScale: evt with: scaleHandle [
	"Initialize scaling of my target."

	self obtainHaloForEvent: evt andRemoveAllHandlesBut: scaleHandle.
	target prepareForScaling.
	growingOrRotating := true.
	positionOffset := 0@0.
	originalExtent := target extent

]

{ #category : #events }
HaloMorph >> staysUpWhenMouseIsDownIn: aMorph [
	^ ((aMorph == target) or: [aMorph hasOwner: self])
]

{ #category : #stepping }
HaloMorph >> step [
	| newBounds |
	target
		ifNil: [^ self].
	newBounds := target isWorldMorph
				ifTrue: [target bounds]
				ifFalse: [self localHaloBoundsFor: target renderedMorph].
	newBounds = self bounds
		ifTrue: [^ self].
	newBounds extent = self bounds extent
		ifTrue: [^ self position: newBounds origin].
	growingOrRotating
		ifFalse: [submorphs size > 1
				ifTrue: [self addHandles]].
	"adjust halo bounds if appropriate"
	self bounds: newBounds
]

{ #category : #stepping }
HaloMorph >> stepTime [

	^ 0  "every cycle"

]

{ #category : #accessing }
HaloMorph >> target [

	^ target

]

{ #category : #accessing }
HaloMorph >> target: aMorph [

	self setTarget: aMorph.
	target ifNotNil: [self addHandles].

]

{ #category : #private }
HaloMorph >> trackCenterOfRotation: anEvent with: rotationHandle [
	(rotationHandle hasProperty: #dragByCenterOfRotation) 
		ifTrue:[^self doDrag: anEvent with: rotationHandle].
	anEvent hand obtainHalo: self.
	rotationHandle center: anEvent cursorPoint.
]

{ #category : #private }
HaloMorph >> trackDirectionArrow: anEvent with: shaft [
	anEvent hand obtainHalo: self.
	shaft setVertices: {directionArrowAnchor. anEvent cursorPoint}.
	self layoutChanged
]

{ #category : #events }
HaloMorph >> transferHalo: event [
	"Transfer the halo to the next likely recipient"
	target ifNil:[^self delete].
	target transferHalo: (event transformedBy: (target transformedFrom: self)) from: target.
]

{ #category : #copying }
HaloMorph >> veryDeepFixupWith: deepCopier [
	"If target and arguments fields were weakly copied, fix them here.  If they were in the tree being copied, fix them up, otherwise point to the originals!!"

super veryDeepFixupWith: deepCopier.
target := deepCopier references at: target ifAbsent: [target].
innerTarget := deepCopier references at: innerTarget ifAbsent: [innerTarget].

]

{ #category : #copying }
HaloMorph >> veryDeepInner: deepCopier [
	"Copy all of my instance variables.  Some need to be not copied at all, but shared.  	Warning!!  Every instance variable defined in this class must be handled.  We must also implement veryDeepFixupWith:.  See DeepCopier class comment."

	super veryDeepInner: deepCopier.
	"target := target.		Weakly copied"
	"innerTarget := innerTarget.		Weakly copied"
	positionOffset := positionOffset veryDeepCopyWith: deepCopier.
	angleOffset := angleOffset veryDeepCopyWith: deepCopier.
	growingOrRotating := growingOrRotating veryDeepCopyWith: deepCopier.
	directionArrowAnchor := directionArrowAnchor.
	haloBox := haloBox.
	originalExtent := originalExtent.
	nameMorph := nameMorph.

]

{ #category : #'event handling' }
HaloMorph >> wantsKeyboardFocusFor: aSubmorph [
	"to allow the name to be edited in the halo in the old tty way; when we morphic-text-ize the name editing, presumably this method should be removed"
	^ true
]

{ #category : #accessing }
HaloMorph >> wantsToBeTopmost [
	"Answer if the receiver want to be one of the topmost objects in 
	its owner"
	^ true
]

{ #category : #menu }
HaloMorph >> wantsYellowButtonMenu [
	"Answer true if the receiver wants a yellow button menu"
	^ false
]

{ #category : #geometry }
HaloMorph >> worldBoundsForMorph: aMorph [
	"Answer the rectangle to be used as the inner dimension of aMorph halos.
	Allow for showing either bounds or fullBounds, and compensate for the optional bounds rectangle."

	| r |
	r := (self haloEnclosesFullBounds)
		ifFalse: [ aMorph boundsIn: nil ]
		ifTrue: [ aMorph fullBoundsInWorld ].
	self showBoundsInHalo ifTrue: [ ^r expandBy: 2 ].
	^r
]
