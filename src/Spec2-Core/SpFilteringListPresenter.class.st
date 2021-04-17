"
I am a presenter that has a list and a text input for filtering the elements on the list.

The list items are filtered based on what the `display` method of the list returns. In other words, what you see is what is used to filter.

I have two predefined filter methods: `self enableItemBeginsWithFilter` and `self enableItemSubstringFilter`. You can set your own method be calling `self itemFilter: aBlock` with a block that has two parameters: the item and the pattern. See the definitions of the above methods for details.

I have two subwidgets:
- A List (`SpListPresenter`) that has the items.
- A Text Input Field (`SpTextInputFieldPresenter`) for entering the filter text.
"
Class {
	#name : #SpFilteringListPresenter,
	#superclass : #SpPresenter,
	#instVars : [
		'unfilteredItems',
		'listPresenter',
		'filterInputPresenter',
		'itemFilterBlock'
	],
	#category : #'Spec2-Core-Widgets-Advanced'
}

{ #category : #specs }
SpFilteringListPresenter class >> bottomLayout [

	^ SpBoxLayout newTopToBottom
		  add: #listPresenter;
		  add: #filterInputPresenter expand: false;
		  yourself
]

{ #category : #specs }
SpFilteringListPresenter class >> defaultSpec [

	^ self bottomLayout
]

{ #category : #specs }
SpFilteringListPresenter class >> topLayout [

	^ SpBoxLayout newTopToBottom
		  add: #filterInputPresenter expand: false;
		  add: #listPresenter;
		  yourself
]

{ #category : #api }
SpFilteringListPresenter >> applyFilter: aString [

	self filterInputPresenter text: aString
]

{ #category : #initialization }
SpFilteringListPresenter >> connectPresenters [

	filterInputPresenter whenTextChangedDo: [ :text | self filterListItems: text ]
]

{ #category : #api }
SpFilteringListPresenter >> contextMenu: aValuable [
 
	self listPresenter contextMenu: aValuable
]

{ #category : #api }
SpFilteringListPresenter >> display [ 

	^ self listPresenter display
]

{ #category : #api }
SpFilteringListPresenter >> display: aBlock [

	self listPresenter display: aBlock
]

{ #category : #api }
SpFilteringListPresenter >> displayIcon: aBlock [

	self listPresenter displayIcon: aBlock
]

{ #category : #accessing }
SpFilteringListPresenter >> filterInputPresenter [

	^ filterInputPresenter
]

{ #category : #private }
SpFilteringListPresenter >> filterListItems: pattern [
	| filteredItems |
	
	unfilteredItems ifNil: [ 
		unfilteredItems := self items ].
	
	pattern ifEmpty: [ 
		self items: unfilteredItems.
		^ self ].

	filteredItems := unfilteredItems select: [ :item |
		itemFilterBlock
			value: (self display value: item)
			value: pattern ].

	listPresenter items: filteredItems
]

{ #category : #api }
SpFilteringListPresenter >> filterText [

	^  self filterInputPresenter text
]

{ #category : #initialization }
SpFilteringListPresenter >> initializePresenters [

	filterInputPresenter := self newTextInput
		placeholder: 'Filter...';
		yourself.
	listPresenter := self newListToFilter.
	self matchSubstring
]

{ #category : #private }
SpFilteringListPresenter >> itemFilter [

	^ itemFilterBlock
]

{ #category : #api }
SpFilteringListPresenter >> itemFilter: aBlock [

	itemFilterBlock := aBlock
]

{ #category : #api }
SpFilteringListPresenter >> items [

	^ listPresenter items
]

{ #category : #api }
SpFilteringListPresenter >> items: aCollection [

	listPresenter items: aCollection.
	unfilteredItems := nil
]

{ #category : #accessing }
SpFilteringListPresenter >> listPresenter [
	^ listPresenter
]

{ #category : #initialization }
SpFilteringListPresenter >> matchBeginOfString [

	itemFilterBlock := [ :each :pattern | 
	              each asLowercase beginsWith: pattern asLowercase ]
]

{ #category : #initialization }
SpFilteringListPresenter >> matchSubstring [

	itemFilterBlock := [ :each :pattern | 
	              each asLowercase includesSubstring: pattern asLowercase ]
]

{ #category : #initialization }
SpFilteringListPresenter >> newListToFilter [
	
	^ self newList
]

{ #category : #api }
SpFilteringListPresenter >> selectItem: anObject [
	
	listPresenter selectItem: anObject
]

{ #category : #api }
SpFilteringListPresenter >> selectedItem [
	
	^ listPresenter selectedItem
]
