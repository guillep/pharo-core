"
see BorderedMorph.

poly := polygon250 

baseColor := Color blue twiceLighter.
border := (ComplexBorder framed: 10) baseColor: poly color.
border frameRectangle: ((100@100 extent: 200@200) insetBy: -5) on: Display getCanvas.
baseColor := Color red twiceLighter.
border := (ComplexBorder framed: 10) baseColor: baseColor.
border drawPolygon: {100@100. 300@100. 300@300. 100@300} on: Display getCanvas.

border drawPolyPatchFrom: 100@200 via: 100@100 via: 200@100 to: 200@200 on: Display getCanvas.
border drawPolyPatchFrom: 100@100 via: 200@100 via: 200@200 to: 100@200 on: Display getCanvas.
border drawPolyPatchFrom: 200@100 via: 200@200 via: 100@200 to: 100@100 on: Display getCanvas.
border drawPolyPatchFrom: 200@200 via: 100@200 via: 100@100 to: 200@100 on: Display getCanvas.

border := (ComplexBorder raised: 10) baseColor: poly color.
border drawPolygon: poly getVertices on: Display getCanvas

360 / 16.0 22.5
points := (0 to: 15) collect:[:i| (Point r: 100 degrees: i*22.5) + 200].
Display getCanvas fillOval: (100@100 extent: 200@200) color: baseColor.
border drawPolygon: points on: Display getCanvas.

-1 to: points size + 1 do:[:i|
	border drawPolyPatchFrom: (points atWrap: i) via: (points atWrap: i+1) via: (points atWrap: i+2) to: (points atWrap: i+3) on: Display getCanvas.
].

Display getCanvas fillOval: (100@100 extent: 200@200) color: baseColor.
0 to: 36 do:[:i|
	border drawLineFrom: (Point r: 100 degrees: i*10) + 200 to: (Point r: 100 degrees: i+1*10) + 200
		on: Display getCanvas.
].
drawPolygon:
Point r: 1.0 degrees: 10
MessageTally spyOn:[
Display deferUpdates: true.
t1 := [1 to: 1000 do:[:i|
	border drawLineFrom: (100@100) to: (300@100) on: Display getCanvas.
	border drawLineFrom: (300@100) to: (300@300) on: Display getCanvas.
	border drawLineFrom: (300@300) to: (100@300) on: Display getCanvas.
	border drawLineFrom: (100@300) to: (100@100) on: Display getCanvas]] timeToRun.
Display deferUpdates: false.
].

MessageTally spyOn:[
Display deferUpdates: true.
t2 := [1 to: 1000 do:[:i|
	border drawLine2From: (100@100) to: (300@100) on: Display getCanvas.
	border drawLine2From: (300@100) to: (300@300) on: Display getCanvas.
	border drawLine2From: (300@300) to: (100@300) on: Display getCanvas.
	border drawLine2From: (100@300) to: (100@100) on: Display getCanvas]] timeToRun.
Display deferUpdates: false.
].


"
Class {
	#name : #ComplexBorderStyle,
	#superclass : #SimpleBorderStyle,
	#instVars : [
		'style',
		'colors',
		'lineStyles'
	],
	#category : #'Morphic-Base-Borders'
}

{ #category : #'instance creation' }
ComplexBorderStyle class >> style: aSymbol [
	^self new style: aSymbol
]

{ #category : #accessing }
ComplexBorderStyle >> colors [
	^colors ifNil:[colors := self computeColors].
]

{ #category : #private }
ComplexBorderStyle >> colorsForDirection: direction [ 
	"Return an array of colors describing the receiver in the given direction"

	| colorArray dT cc |
	cc := self colors.
	direction x * direction y <= 0 
		ifTrue: 
			["within up->right or down->left transition; no color blend needed"

			colorArray := (direction x > 0 or: [direction y < 0]) 
						ifTrue: 
							["up->right"
							cc copyFrom: 1 to: width]
						ifFalse: 
							["down->left"
							"colors are stored in reverse direction when following a line"
							(cc copyFrom: width + 1 to: cc size) reversed]]
		ifFalse: 
			["right->down or left->up transition; need color blend"

			colorArray := Array new: width.
			dT := direction x asFloat / (direction x + direction y).
			(direction x > 0 or: [direction y >= 0]) 
				ifTrue: 
					["top-right"

					1 to: width
						do: 
							[:i | 
							colorArray at: i put: ((cc at: i) mixed: dT with: (cc at: cc size - i + 1))]]
				ifFalse: 
					["bottom-left"

					1 to: width
						do: 
							[:i | 
							colorArray at: i put: ((cc at: cc size - i + 1) mixed: dT with: (cc at: i))]]].
	^colorArray
]

{ #category : #private }
ComplexBorderStyle >> computeAltFramedColors [
	| base light dark w hw colorArray param |
	base := self color asColor.
	light := Color white.
	dark := Color black.
	w := self width isPoint ifTrue:[self width x max: self width y] ifFalse:[self width].
	w := w asInteger.
	w = 1 ifTrue:[^{base mixed: 0.5 with: light. base mixed: 0.5 with: dark}].
	colorArray := Array new: w.
	hw := w // 2.
	"brighten"
	0 to: hw-1 do:[:i|
		param := 0.5 + (i asFloat / hw * 0.5).
		colorArray at: i+1 put: (base mixed: param with: dark). "brighten"
		colorArray at: w-i put: (base mixed: param with: light). "darken"
	].
	w odd ifTrue:[colorArray at: hw+1 put: base].
	^colorArray, colorArray
]

{ #category : #private }
ComplexBorderStyle >> computeAltInsetColors [
	| base light dark w colorArray param hw |
	base := self color asColor.
	light := Color white.
	dark := Color black.
	w := self width isPoint 
				ifTrue: [self width x max: self width y]
				ifFalse: [self width].
	w := w asInteger.
	colorArray := Array new: w * 2.
	hw := 0.5 / w.
	0 to: w - 1
		do: 
			[:i | 
			param := false 
						ifTrue: 
							["whats this ???! false ifTrue:[]"

							0.5 + (hw * i)]
						ifFalse: [0.5 + (hw * (w - i))].
			colorArray at: i + 1 put: (base mixed: param with: dark).	"darken"
			colorArray at: colorArray size - i put: (base mixed: param with: light)	"brighten"].
	^colorArray
]

{ #category : #private }
ComplexBorderStyle >> computeAltRaisedColors [
	| base light dark w colorArray param hw |
	base := self color asColor.
	light := Color white.
	dark := Color black.
	w := self width isPoint 
				ifTrue: [self width x max: self width y]
				ifFalse: [self width].
	w := w asInteger.
	colorArray := Array new: w * 2.
	hw := 0.5 / w.
	0 to: w - 1
		do: 
			[:i | "again ! false ifTrue:[] ?!"
			param := false ifTrue: [0.5 + (hw * i)] ifFalse: [0.5 + (hw * (w - i))].
			colorArray at: i + 1 put: (base mixed: param with: light).	"brighten"
			colorArray at: colorArray size - i put: (base mixed: param with: dark)	"darken"].
	^colorArray
]

{ #category : #private }
ComplexBorderStyle >> computeColors [
	width = 0 ifTrue:[^colors := #()].
	style == #complexFramed ifTrue:[^self computeFramedColors].
	style == #complexAltFramed ifTrue:[^self computeAltFramedColors].
	style == #complexRaised ifTrue:[^self computeRaisedColors].
	style == #complexAltRaised ifTrue:[^self computeAltRaisedColors].
	style == #complexInset ifTrue:[^self computeInsetColors].
	style == #complexAltInset ifTrue:[^self computeAltInsetColors].
	self error:'Unknown border style: ', style printString.
]

{ #category : #private }
ComplexBorderStyle >> computeFramedColors [
	| base light dark w hw colorArray param |
	base := self color asColor.
	light := Color white.
	dark := Color black.
	w := self width isPoint ifTrue:[self width x max: self width y] ifFalse:[self width].
	w := w asInteger.
	w = 1 ifTrue:[^{base mixed: 0.5 with: light. base mixed: 0.5 with: dark}].
	colorArray := Array new: w.
	hw := w // 2.
	"brighten"
	0 to: hw-1 do:[:i|
		param := 0.5 + (i asFloat / hw * 0.5).
		colorArray at: i+1 put: (base mixed: param with: light). "brighten"
		colorArray at: w-i put: (base mixed: param with: dark). "darken"
	].
	w odd ifTrue:[colorArray at: hw+1 put: base].
	^colorArray, colorArray
]

{ #category : #private }
ComplexBorderStyle >> computeInsetColors [
	| base light dark w colorArray param hw |
	base := self color asColor.
	light := Color white.
	dark := Color black.
	w := self width isPoint 
				ifTrue: [self width x max: self width y]
				ifFalse: [self width].
	w := w asInteger.
	colorArray := Array new: w * 2.
	hw := 0.5 / w.
	0 to: w - 1
		do: 
			[:i | 
			param := true 
				ifTrue: [ 0.5 + (hw * i)]
				ifFalse: [0.5 + (hw * (w - i))].
			colorArray at: i + 1 put: (base mixed: param with: dark).	"darken"
			colorArray at: colorArray size - i put: (base mixed: param with: light)	"brighten"].
	^colorArray
]

{ #category : #private }
ComplexBorderStyle >> computeRaisedColors [
	| base light dark w colorArray param hw |
	base := self color asColor.
	light := Color white.
	dark := Color black.
	w := self width isPoint 
				ifTrue: [self width x max: self width y]
				ifFalse: [self width].
	w := w asInteger.
	colorArray := Array new: w * 2.
	hw := 0.5 / w.
	0 to: w - 1
		do: 
			[:i | 
			param := true ifTrue: [0.5 + (hw * i)] ifFalse: [0.5 + (hw  * (w - i))].
			colorArray at: i + 1 put: (base mixed: param with: light).	"brighten"
			colorArray at: colorArray size - i put: (base mixed: param with: dark)	"darken"].
	^colorArray
]

{ #category : #drawing }
ComplexBorderStyle >> drawLineFrom: startPoint to: stopPoint on: aCanvas [ 
	"Here we're using the balloon engine since this is much faster than BitBlt w/ brushes."

	| delta length dir cos sin tfm w h w1 w2 h1 h2 fill |
	width isPoint 
		ifTrue: 
			[w := width x.
			h := width y]
		ifFalse: [w := h := width].
	w1 := w // 2.
	w2 := w - w1.
	h1 := h // 2.
	h2 := h - h1.
	"Compute the rotational transform from (0@0) -> (1@0) to startPoint -> stopPoint"
	delta := stopPoint - startPoint.
	length := delta r.
	dir := length > 1.0e-10 ifTrue: [delta / length] ifFalse: [ 1 @ 0].
	cos := dir dotProduct: 1 @ 0.
	sin := dir crossProduct: 1 @ 0.
	tfm := (MatrixTransform2x3 new)
				a11: cos;
				a12: sin;
				a21: sin negated;
				a22: cos.
	"Install the start point offset"
	tfm offset: startPoint.
	"Now get the fill style appropriate for the given direction"
	fill := self fillStyleForDirection: dir.
	"And draw..."
	aCanvas transformBy: tfm
		during: 
			[:cc | 
			cc drawPolygon: { 
						(0 - w1) @ (0 - h1).	"top left"
						(length + w2) @ (0 - h1).	"top right"
						(length + w2) @ h2.	"bottom right"
						(0 - w1) @ h2	"bottom left"}
				fillStyle: fill]
]

{ #category : #drawing }
ComplexBorderStyle >> drawPolyPatchFrom: startPoint to: stopPoint on: aCanvas usingEnds: endsArray [

	| cos sin tfm fill dir fsOrigin fsDirection points x y |
	dir := (stopPoint - startPoint) normalized.
	"Compute the rotational transform from (0@0) -> (1@0) to startPoint -> stopPoint"
	cos := dir dotProduct: (1@0).
	sin := dir crossProduct: (1@0).
	"Now get the fill style appropriate for the given direction"
	fill := self fillStyleForDirection: dir.
false ifTrue:[
	"Transform the fill appropriately"
	fill := fill shallowCopy.
	"Note: Code below is inlined from tfm transformPoint:/transformDirection:"
	x := fill origin x. y := fill origin y.
	fsOrigin := ((x * cos) + (y * sin) + startPoint x) @
					((y * cos) - (x * sin) + startPoint y).
	x := fill direction x. y := fill direction y.
	fsDirection := ((x * cos) + (y * sin)) @ ((y * cos) - (x * sin)).
	fill origin: fsOrigin; 
		direction: fsDirection rounded; "NOTE: This is a bug in the balloon engine!!!"
		normal: nil.
	aCanvas drawPolygon: endsArray fillStyle: fill.
] ifFalse:[
	"Transform the points rather than the fills"
	tfm := (MatrixTransform2x3 new) a11: cos; a12: sin; a21: sin negated; a22: cos.
	"Install the start point offset"
	tfm offset: startPoint.
	points := endsArray collect:[:pt| tfm invertPoint: pt].
	aCanvas transformBy: tfm during:[:cc|
		cc drawPolygon: points fillStyle: fill.
	].
].
]

{ #category : #private }
ComplexBorderStyle >> fillStyleForDirection: direction [
	"Fill the given form describing the receiver's look at a particular direction"
	| index fill dir |
	index := direction degrees truncated // 10 + 1.
	lineStyles ifNotNil:[
		fill := lineStyles at: index.
		fill ifNotNil:[^fill].
	].
	dir := Point r: 1.0 degrees: index - 1 * 10 + 5.
	fill := GradientFillStyle colors: (self colorsForDirection: dir).
	fill direction: 0 @ width asPoint y; radial: false.
	fill origin: ((width asPoint x // 2) @ (width asPoint y // 2)) negated.
	fill pixelRamp: (fill computePixelRampOfSize: 16).
	fill isTranslucent. "precompute"
	lineStyles ifNil:[lineStyles := Array new: 37].
	lineStyles at: index put: fill.
	^fill
]

{ #category : #drawing }
ComplexBorderStyle >> framePolygon: vertices on: aCanvas [
	| dir1 dir2 dir3 nrm1 nrm2 nrm3 point1 point2 point3 
	 cross1 cross2 pointA pointB pointC pointD w p1 p2 p3 p4 balloon ends pointE pointF |
	balloon := aCanvas.
	balloon == aCanvas ifFalse:[balloon deferred: true].
	ends := Array new: 6.
	w := width * 0.5.
	pointA := nil.
	1 to: vertices size do:[:i|
		p1 := vertices atWrap: i.
		p2 := vertices atWrap: i+1.
		p3 := vertices atWrap: i+2.
		p4 := vertices atWrap: i+3.

		dir1 := p2 - p1.
		dir2 := p3 - p2.
		dir3 := p4 - p3.

		(i = 1 | true) ifTrue:[
			"Compute the merge points of p1->p2 with p2->p3"
			cross1 := dir2 crossProduct: dir1.
			nrm1 := dir1 normalized. nrm1 := (nrm1 y * w) @ (0 - nrm1 x * w).
			nrm2 := dir2 normalized. nrm2 := (nrm2 y * w) @ (0 - nrm2 x * w).
			cross1 < 0 ifTrue:[nrm1 := nrm1 negated. nrm2 := nrm2 negated].
			point1 := (p1 x + nrm1 x) @ (p1 y + nrm1 y).
			point2 := (p2 x + nrm2 x) @ (p2 y + nrm2 y).
			pointA := self intersectFrom: point1 with: dir1 to: point2 with: dir2.
			point1 := (p1 x - nrm1 x) @ (p1 y - nrm1 y).
			point2 := (p2 x - nrm2 x) @ (p2 y - nrm2 y).
			pointB := point1 + dir1 + point2 * 0.5.
			pointB := p2 + ((pointB - p2) normalized * w).
			pointC := point2.
		].

		"Compute the merge points of p2->p3 with p3->p4"
		cross2 := dir3 crossProduct: dir2.
		nrm2 := dir2 normalized. nrm2 := (nrm2 y * w) @ (0 - nrm2 x * w).
		nrm3 := dir3 normalized. nrm3 := (nrm3 y * w) @ (0 - nrm3 x * w).
		cross2 < 0 ifTrue:[nrm2 := nrm2 negated. nrm3 := nrm3 negated].
		point2 := (p2 x + nrm2 x) @ (p2 y + nrm2 y).
		point3 := (p3 x + nrm3 x) @ (p3 y + nrm3 y).
		pointD := self intersectFrom: point2 with: dir2 to: point3 with: dir3.
		point2 := (p2 x - nrm2 x) @ (p2 y - nrm2 y).
		point3 := (p3 x - nrm3 x) @ (p3 y - nrm3 y).
		pointF := point2 + dir2.
		pointE := pointF + point3 * 0.5.
		pointE := p3 + ((pointE - p3) normalized * w).
		cross1 * cross2 < 0.0 ifTrue:[
			ends
				at: 1 put: pointA;
				at: 2 put: pointB;
				at: 3 put: pointC;
				at: 4 put: pointD;
				at: 5 put: pointE;
				at: 6 put: pointF.
		] ifFalse:[
			ends 
				at: 1 put: pointA; 
				at: 2 put: pointB;
				at: 3 put: pointC; 
				at: 4 put: pointF; 
				at: 5 put: pointE;
				at: 6 put: pointD.
		].
		self drawPolyPatchFrom: p2 to: p3 on: balloon usingEnds: ends.
		pointA := pointD.
		pointB := pointE.
		pointC := pointF.
		cross1 := cross2.
	].
	balloon == aCanvas ifFalse:[balloon flush].
]

{ #category : #drawing }
ComplexBorderStyle >> frameRectangle: aRectangle on: aCanvas [
	"Note: This uses BitBlt since it's roughly a factor of two faster for rectangles"
	| w h r |
	self colors ifNil:[^super frameRectangle: aRectangle on: aCanvas].
	w := self width.
	w isPoint ifTrue:[h := w y. w := w x] ifFalse:[h := w].
	1 to: h do:[:i| "top/bottom"
		r := (aRectangle topLeft + (i-1)) extent: (aRectangle width - (i-1*2))@1. "top"
		aCanvas fillRectangle: r color: (colors at: i).
		r := (aRectangle bottomLeft + (i @ (0-i))) extent: (aRectangle width - (i-1*2) - 1)@1. "bottom"
		aCanvas fillRectangle: r color: (colors at: colors size - i + 1).
	].
	1 to: w do:[:i| "left/right"
		r := (aRectangle topLeft + (i-1)) extent: 1@(aRectangle height - (i-1*2)). "left"
		aCanvas fillRectangle: r color: (colors at: i).
		r := aRectangle topRight + ((0-i)@i) extent: 1@(aRectangle height - (i-1*2) - 1). "right"
		aCanvas fillRectangle: r color: (colors at: colors size - i + 1).
	].
]

{ #category : #private }
ComplexBorderStyle >> intersectFrom: startPt with: startDir to: endPt with: endDir [
	"Compute the intersection of two lines. Return nil if either
		* the intersection does not exist, or
		* the intersection is 'before' startPt, or
		* the intersection is 'after' endPt
	"
	| det deltaPt alpha beta |
	det := (startDir x * endDir y) - (startDir y * endDir x).
	det = 0.0 ifTrue:[^nil]. "There's no solution for it"
	deltaPt := endPt - startPt.
	alpha := (deltaPt x * endDir y) - (deltaPt y * endDir x).
	beta := (deltaPt x * startDir y) - (deltaPt y * startDir x).
	alpha := alpha / det.
	beta := beta / det.
	alpha < 0 ifTrue:[^nil].
	beta > 1.0 ifTrue:[^nil].
	"And compute intersection"
	^(startPt x + (alpha * startDir x)) @ (startPt y + (alpha * startDir y))
]

{ #category : #testing }
ComplexBorderStyle >> isComplex [
	^true
]

{ #category : #initialize }
ComplexBorderStyle >> releaseCachedState [
	colors := nil.
	lineStyles := nil.
]

{ #category : #accessing }
ComplexBorderStyle >> style [
	^style
]

{ #category : #accessing }
ComplexBorderStyle >> style: newStyle [
	style == newStyle ifTrue:[^self].
	style := newStyle.
	self releaseCachedState.
]

{ #category : #'color tracking' }
ComplexBorderStyle >> trackColorFrom: aMorph [
	baseColor ifNil:[self color: aMorph raisedColor].
]

{ #category : #accessing }
ComplexBorderStyle >> widthForRounding [
	^0
]
