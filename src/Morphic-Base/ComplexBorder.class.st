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
	#name : #ComplexBorder,
	#superclass : #ComplexBorderStyle,
	#category : #'Morphic-Base-Borders'
}

{ #category : #testing }
ComplexBorder class >> isDeprecated [ 
	^ true
]
