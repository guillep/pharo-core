Class {
	#name : #StFilterImplementor,
	#superclass : #StFilterSubstring,
	#category : #'NewTools-Spotter-Extensions'
}

{ #category : #public }
StFilterImplementor class >> gtListFilter [
	^ GTFilterSubstring new
]

{ #category : #private }
StFilterImplementor >> applyFilterWithQuery [

	super applyFilterWithQuery.
	self filteredItems: (self filteredItems reject: [ :each | each isFromTrait ])
]

{ #category : #'private-model' }
StFilterImplementor >> itemFilterNameFor: each [

	self flag: 'this filter wants to filter items by #selector (speed 10x), but dive-in-category wants to filter by #printString. Most filters in dive-in-category wants to filter by #printString, but not all. Others: files, topics, help, ... ?'.
	^ each selector
]

{ #category : #public }
StFilterImplementor >> stListFilter [

	^ StFilterSubstring new
]
