Class {
	#name : #StPresenter,
	#superclass : #SpPresenter,
	#category : #'NewTools-Core-Presenters'
}

{ #category : #private }
StPresenter class >> currentApplication [

	^ SpToolCurrentApplication value ifNil: [ StPharoApplication current ]
]

{ #category : #'instance creation' }
StPresenter class >> new [

	^ self newApplication: self currentApplication
]

{ #category : #'instance creation' }
StPresenter class >> owner: anOwningPresenter [

	^ self 
		newApplication: self currentApplication
		owner: anOwningPresenter
]

{ #category : #'instance creation' }
StPresenter class >> owner: anOwningPresenter on: aDomainObject [

	^ self 
		newApplication: self currentApplication
		owner: anOwningPresenter
		model: aDomainObject
]

{ #category : #accessing }
StPresenter class >> preferredExtent [

	^ 600@400
]

{ #category : #initialization }
StPresenter >> initializeWindow: aWindowPresenter [
	"All tools should call its parent"

	self traversePresentersDo: [ :each |
		each addWindowShortcutsTo: aWindowPresenter ]
]

{ #category : #initialization }
StPresenter >> preferredExtent [

	^ self class preferredExtent
]

{ #category : #private }
StPresenter >> shortcutForPanel: aNumber [
	"This is a convenience method to assign shortcuts to panels. 
	 panels will be different areas of a tool: a package panel in a browser, an inspector in 
	 the debugger."
	| char |
	
	char := aNumber asString first.
	^ char command mac 
		| char control win 
		| char control unix
]
