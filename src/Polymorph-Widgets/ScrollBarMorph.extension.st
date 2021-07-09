Extension { #name : #ScrollBarMorph }

{ #category : #'*Polymorph-Widgets' }
ScrollBarMorph class >> imageColorFor: aScrollbar [
	"Return the (button) image colour for the given scrollbar."
	
	^self theme scrollbarImageColorFor: aScrollbar
]
