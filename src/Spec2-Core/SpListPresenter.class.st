"
A `SpListPresenter` is presenter which handles a basic list displaying information about a domain list. 
For example a list presenter will display the name of a list of contacts. It refines the API of `SpAbstractListPresenter` that is shared with `SpComponentListPresenter` (which is a list of presenters) and `SpTablePresenter` (which is a list with multiple columns in a sense). 

### Design point
There are two design points worth notice:

A list presenter has a strategy that encapsulates specific API and action related to selection (how to select, how many items can be selected, currently selected items...). Such strategy is accessed via the `selection` message. It returns an instance of subclasses of `SpAbstractSelectionMode`: `SpMultipleSelectionMode` and `SpSingleSelectionMode`. 
It means many fonctionality related to the selection (selected items, multiple items, ....) are defined in the API of the mode and not of the main class.
 
A list presenter does not offer the possibility to add one item in isolation instead you should use the `items:` setter to set the full list domain object. The responsibility to manage the items displayed by a list presenter is not the one of that list presenter but its users e.g, the presenter you will write and that instantiates and uses the list presenter. This is normal since there is no way that the list presenter could track changes into the domain object representing the list items.
"
Class {
	#name : #SpListPresenter,
	#superclass : #SpAbstractListPresenter,
	#traits : 'SpTSearchable',
	#classTraits : 'SpTSearchable classTrait',
	#instVars : [
		'#allowToSelect => SpObservableSlot',
		'#autoDeselect => SpObservableSlot',
		'#headerTitle => SpObservableSlot',
		'#display => SpObservableSlot',
		'#icon => SpObservableSlot'
	],
	#category : #'Spec2-Core-Widgets-Table'
}

{ #category : #specs }
SpListPresenter class >> adapterName [

	^ #ListAdapter
]

{ #category : #specs }
SpListPresenter class >> title [

	^ 'List'
]

{ #category : #private }
SpListPresenter >> clickOnSelectedItem [
	| item |
	item := self selection selectedItem.
	(item notNil and: [ item respondsTo: #click ])
		ifTrue: [ ^ item click ]
		ifFalse: [ ^ false ]
]

{ #category : #api }
SpListPresenter >> display [
	"Answer the display block that will transform the objects from `SpAbstractListPresenter>>#model` into a
	 displayable string."

	^ display
]

{ #category : #api }
SpListPresenter >> display: aBlock [
	"Set the block that will be applied on each of the list items. 
	 The result of the block will be used to display the item on the screen.
	 `aBlock` receives one argument.
	 Here is the typical example:

	 initializePresenters
   		...
   		fontFamilyList := self newList.
		fontFamilyList display: [ :fontFamily | fontFamily familyName ]
   		...
	 "

	display := aBlock
]

{ #category : #api }
SpListPresenter >> displayIcon [
	"Return the block used to return an icon that will be displayed in the list"

	^ icon
]

{ #category : #api }
SpListPresenter >> displayIcon: aBlock [
	"Set a block which takes an item as argument and returns the icon to display in the list. 
	 `aBlock` receives one argument"

	icon := aBlock
]

{ #category : #private }
SpListPresenter >> displayValueAt: anIndex [
	"Return the effective string that is displayed on the list. 
	Note that it is different from the item, because often an item is an object whose only a facette (e.g., name) is displayed. In such case displayValueAt: return the string of the displayed facette"

	^ self displayValueFor: (model at: anIndex)
]

{ #category : #private }
SpListPresenter >> displayValueFor: anObject [

	^ self display value: anObject
]

{ #category : #testing }
SpListPresenter >> hasHeaderTitle [
	"Answer true if the list has a title (See `SpListPresenter>>#headerTitle:`)."

	^ headerTitle isEmptyOrNil not
]

{ #category : #testing }
SpListPresenter >> hasIcons [
	"Answer true if the list has an icon provider (See `SpListPresenter>>#icons:`)."

	^ self displayIcon notNil
]

{ #category : #api }
SpListPresenter >> headerTitle [
	"Answer the header title."

	^ headerTitle
]

{ #category : #api }
SpListPresenter >> headerTitle: aString [
	"Set the header title."

	headerTitle := aString
]

{ #category : #api }
SpListPresenter >> hideHeaderTitle [
	"Hide list header."

	headerTitle := nil
]

{ #category : #'widget API' }
SpListPresenter >> iconFor: anItem [

	^ self displayIcon 
		cull: anItem 
		cull: self
]

{ #category : #api }
SpListPresenter >> icons [
	"Return the block used to return an icon that will be displayed in the list"
	self 
		deprecated: 'Use #displayIcon' 
		transformWith: '`@receiver icons' -> '`@receiver displayIcon'.

	^ icon
]

{ #category : #api }
SpListPresenter >> icons: aBlock [
	"Set a block which takes an item as argument and returns the icon to display in the list. 
	 `aBlock` receives one argument"
	self 
		deprecated: 'Use #displayIcon:' 
		transformWith: '`@receiver icons: `@arg' -> '`@receiver displayIcon: `@arg'.

	icon := aBlock
]

{ #category : #initialization }
SpListPresenter >> initialize [

	super initialize.
	self initializeTSearchable.
	autoDeselect := true.
	allowToSelect := true.
	display := [ :object | object asStringOrText ]
]

{ #category : #private }
SpListPresenter >> prepareForFilteredDataSourceWith: items [
	model := items
]

{ #category : #private }
SpListPresenter >> registerEvents [
	super registerEvents.
	"Do not use whenAutoDeselectChangedDo: to avoid the deprecation warning."
	self 
		property: #autoDeselect 
		whenChangedDo: [ :aBoolean | self changed: #autoDeselect: with: {aBoolean} ].
	self whenDisplayChangedDo: [ 
		self withAdapterDo: [ :anAdapter | anAdapter refreshWidgetList ] ].
	self 
		property: #headerTitle 
		whenChangedDo: [ 
			self withAdapterDo: [ :anAdapter | anAdapter refreshWidgetHeaderTitle ] ]
]

{ #category : #private }
SpListPresenter >> resetListSelection [
	self selectIndex: 0
]

{ #category : #TOREMOVE }
SpListPresenter >> resetSortingBlock [
	"Reset the sortering block with the default value which consists in not sorting"

	self model sortingBlock: nil
]

{ #category : #api }
SpListPresenter >> updateList [
	"Update the list re taking the list defined in `SpAbstractListPresenter>>#model` and filling the list with 
	 them (this is useful when the list contained changed internally (like adding element to a collection, etc.). 
	 Sending this message will reset any existing selection."

	self withAdapterDo: [ :anAdapter | anAdapter refreshWidgetList ].
	self unselectAll
]

{ #category : #'api-events' }
SpListPresenter >> whenDisplayChangedDo: aBlock [
	"Inform when the display block has changed.
 	 `aBlock` has three optional arguments: 
	 - new value
	 - old value
	 - the announcement triggering this action"

	self property: #display whenChangedDo: aBlock
]

{ #category : #'api-events' }
SpListPresenter >> whenIconsChangedDo: aBlock [
	"Inform when the icons block has changed.
 	 `aBlock` has three optional arguments: 
	 - new value
	 - old value
	 - the announcement triggering this action"

	self property: #icon whenChangedDo: aBlock
]
