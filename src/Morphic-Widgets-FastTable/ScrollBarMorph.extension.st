Extension { #name : #ScrollBarMorph }

{ #category : #'*Morphic-Widgets-FastTable' }
ScrollBarMorph >> canScrollDown [

	^value < 1
]

{ #category : #'*Morphic-Widgets-FastTable' }
ScrollBarMorph >> canScrollUp [

	^value > 0
]

{ #category : #'*Morphic-Widgets-FastTable' }
ScrollBarMorph >> pageDelta [
	^ pageDelta
]

{ #category : #'*Morphic-Widgets-FastTable' }
ScrollBarMorph >> scrollDownByPageDelta [
	self scrollDown: self pageDelta
]

{ #category : #'*Morphic-Widgets-FastTable' }
ScrollBarMorph >> scrollRestrictedDown: aValue [

	"only scroll if the scrollbar is not at its end yet"

	self canScrollDown ifFalse: [ ^self ].
	
	self scrollDown: aValue
]

{ #category : #'*Morphic-Widgets-FastTable' }
ScrollBarMorph >> scrollRestrictedUp: aValue [

	"only scroll if the scrollbar is not at its end yet"

	self canScrollUp ifFalse: [ ^self ].
	
	self scrollUp: aValue
]

{ #category : #'*Morphic-Widgets-FastTable' }
ScrollBarMorph >> scrollUpByPageDelta [
	self scrollUp: self pageDelta
]
