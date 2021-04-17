Class {
	#name : #StUnorderedFilter,
	#superclass : #StStringFilter,
	#category : #'NewTools-Spotter-Filters'
}

{ #category : #private }
StUnorderedFilter >> doApplyFilterWithQuery [

	| unorderedMatchedItems |

	unorderedMatchedItems := OrderedCollection new.
	self allItemsDo: [ :each | 
		(self isMatchedItem: each)
				ifTrue: [
					unorderedMatchedItems add: each.
					self addItem: each.
					unorderedMatchedItems size = self itemsLimit ifTrue: [ StLimitArrived signal ] ] ].
	self filteredItems: unorderedMatchedItems
]

{ #category : #private }
StUnorderedFilter >> isMatchedItem: anItem [
	^ false
]
