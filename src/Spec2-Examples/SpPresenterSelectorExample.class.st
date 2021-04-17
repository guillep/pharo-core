"
I am an example of a presenter chooser.
I will show a list and a way to select it.
"
Class {
	#name : #SpPresenterSelectorExample,
	#superclass : #SpPresenter,
	#instVars : [
		'list',
		'choice'
	],
	#category : #'Spec2-Examples-Standalone'
}

{ #category : #specs }
SpPresenterSelectorExample class >> defaultSpec [

	^ SpPanedLayout newLeftToRight
		add: #list;
		add: #choice;
		yourself.

]

{ #category : #initialization }
SpPresenterSelectorExample >> initializePresenters [
	"self new openWithSpec"

	list := self newList items: #(1 2 3).
	choice := self newPresenterSelector
		when: [ :aNumber | aNumber = 1 ] show: [ self newLabel label: 'One' ];
		when: [ :aNumber | aNumber = 2 ] show: [ self newLabel label: 'Two' ];
		when: [ :aNumber | aNumber = 3 ] show: [ self newLabel label: 'Three' ];
		defaultShow: [ self newLabel label: 'Choose one!' ];
		"update presenter is needed to make sure the presenter will have correct initial 
		 value (before anything happens)"
		updatePresenter.
		
	list transmitTo: choice
]

{ #category : #initialization }
SpPresenterSelectorExample >> initializeWindow: aWindowPresenter [

	aWindowPresenter title: 'Presenter Selector Example'
]
