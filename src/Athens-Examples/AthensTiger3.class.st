Class {
	#name : #AthensTiger3,
	#superclass : #Object,
	#instVars : [
		'surface',
		'rotation',
		'scale',
		'zoom',
		'position',
		'parts'
	],
	#category : #'Athens-Examples-Utilities'
}

{ #category : #drawing }
AthensTiger3 >> draw [
	surface drawDuring: [ :canvas | 
		canvas pathTransform loadIdentity.
		canvas
			setPaint: Color white;
			drawShape: (0@0 corner: surface extent).
			
		canvas pathTransform
			translateX: 0.5 * (surface extent x - (self class tigerMaxX * scale * zoom))
				Y: surface extent y / -12.0;
			scaleBy: scale * zoom;
			translateBy: self class tigerCenter;
			scaleBy: 0.8;
			rotateByDegrees: rotation;
			translateBy: (self class tigerCenter * -1);
			translateBy: position.

		parts do: [ :each | each renderOn: canvas ] ].

]
