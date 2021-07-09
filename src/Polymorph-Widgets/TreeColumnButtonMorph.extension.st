Extension { #name : #TreeColumnButtonMorph }

{ #category : #'*Polymorph-Widgets' }
TreeColumnButtonMorph >> themeChanged [
	self fillStyle: (self theme morphTreeColumnFillStyleFor: self).
	self borderStyle: (self theme morphTreeColumnBorderStyleFor: self).
	super themeChanged
]
