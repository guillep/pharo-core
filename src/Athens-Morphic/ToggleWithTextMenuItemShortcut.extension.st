Extension { #name : #ToggleWithTextMenuItemShortcut }

{ #category : #'*Athens-Morphic' }
ToggleWithTextMenuItemShortcut >> drawOnAthensCanvas: aCanvas [
	| keyBounds |
	
	keyBounds := self boundsForKeyText: self keyText font: self owner fontToUse.
	self owner
		drawText: keyText
		onAthensCanvas: aCanvas
		in: keyBounds
		color: self owner theme disabledTextColor
]
