Class {
	#name : #StNullFilter,
	#superclass : #StStringFilter,
	#category : #'NewTools-Spotter-Filters'
}

{ #category : #public }
StNullFilter class >> stListFilter [

	^ StFilterSubstring new
]

{ #category : #private }
StNullFilter >> doApplyFilterWithQuery [

	self streamed 
		ifTrue: [
			" this will be more responsive (faster) for very large collections and/or expensive filters "
			| allItems |
			self filteredItems: (allItems := OrderedCollection new).
			self allItems withIndexDo: [ :each :index |				
				allItems add: each.
				self addItem: each.
				index = self itemsLimit ifTrue: [ StLimitArrived signal ] ] ]
		ifFalse: [
			" this will be much much faster for small collections and/or very quick filters " 
			self filteredItems: self allItems.
			self addItems: (self allItems first: (self itemsLimit min: self allItems size)) ]
]

{ #category : #public }
StNullFilter >> stListFilter [

	^ StFilterSubstring new
]
