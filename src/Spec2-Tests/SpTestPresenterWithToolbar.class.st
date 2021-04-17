"
A presenter with a tollbar and a button to use in Window / World tests.
"
Class {
	#name : #SpTestPresenterWithToolbar,
	#superclass : #SpPresenter,
	#instVars : [
		'button'
	],
	#category : #'Spec2-Tests-Core-Support'
}

{ #category : #specs }
SpTestPresenterWithToolbar class >> defaultSpec [

	^ SpBoxLayout newTopToBottom
		add: (SpPanedLayout newTopToBottom
			add: #button;
			yourself);
		yourself
]

{ #category : #initialization }
SpTestPresenterWithToolbar >> initializePresenters [
	button := self newButton
		label: 'test';
		yourself.
]

{ #category : #initialization }
SpTestPresenterWithToolbar >> initializeWindow: aWindowPresenter [
	| toolbar |
	toolbar := SpToolbarPresenter new
		addItemLeft: (SpToolbarButtonPresenter new
			label: 'toolbar button';
			yourself);
		yourself.
	aWindowPresenter
		title: self class name;
		initialExtent: 700 @ 500;
		toolbar: toolbar
]
