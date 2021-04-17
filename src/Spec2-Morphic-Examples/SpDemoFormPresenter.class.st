"
This demo shows, how to create a simple form with basic elements and how to connect this form to a model. 

In this case, the model is represented by instances of the class SpecDemoFormModel created in the #initialize. It is a simple structure-like class with some default values. The model is not held directly but using a value holder named announcingObject (see ComposablePresenterWithModel>>#model:). The encapsulating value holder would not be needed if our model would be a subclass of ""Model"" (instances of Model provide an announcer by default).

This component has two main subcomponents. The form and a table that shows the current state of the model.

The form is a standalone Spec presenter, an instance of SpecDemoStandaloneFormPresenter. It works with two instances of the model, ""workingModel"" which holds a working copy of the model and a model shared with its parent. When the form is restored, the working copy of the model is thrown away and replaced with a new copy of the model. When the form is submitted, the new model is stored (into the value holder and its change is propagated so the table showing the state of the model is refreshed).

The data exchange between the model and form elements is done in these methods:
SpecDemoStandaloneFormPresenter>>#fillFormWithWorkingModel
SpecDemoStandaloneFormPresenter>>#fillModelWithFormContent

The two parts of this window (form and table) should be rendered in boxes with an outline. Spec in Morphic does not have such functionality now. SpecDemoLabeledContainer is used now.

Text input for number 1 is limited directly on the level of user input. See SpecDemoStandaloneFormPresenter>>#initializePresenter. 

For displaying of the model state, the FastTable Morph is used. Currently, Spec does not provide a presenter for such tables. The class SpecDemoFormTableDataSource is used for interaction between the table and model. 




"
Class {
	#name : #SpDemoFormPresenter,
	#superclass : #SpPresenterWithModel,
	#instVars : [
		'form',
		'resultPane',
		'table'
	],
	#category : #'Spec2-Morphic-Examples-Demo-Forms'
}

{ #category : #specs }
SpDemoFormPresenter class >> defaultSpec [
	^ SpPanedLayout newLeftToRight
		position: (StandardFonts defaultFont widthOfString: 'M') * 35;
		add: #form;
		add: #resultPane;
		yourself
]

{ #category : #accessing }
SpDemoFormPresenter >> form [
	^ form
]

{ #category : #accessing }
SpDemoFormPresenter >> form: anObject [
	form := anObject
]

{ #category : #initialization }
SpDemoFormPresenter >> initialize [
	self model: SpDemoFormModel new.
	super initialize
]

{ #category : #initialization }
SpDemoFormPresenter >> initializePresenters [

	form := self newPresenter 
		layout: (SpBoxLayout newTopToBottom
			add: 'form' expand: false;
			add: (self instantiate: SpDemoStandaloneFormPresenter on: self announcingObject);
			yourself);
		yourself.

	resultPane := self newPresenter 
		layout: (SpBoxLayout newTopToBottom
			add: 'result' expand: false;
			add: (table := self newTable);
			yourself);
		yourself.

	table
		addColumn: (SpStringTableColumn title: 'Name' evaluated: #key);
		addColumn: (SpStringTableColumn title: 'Value' evaluated: #value);
		items: self model elements;
		beResizable
]

{ #category : #accessing }
SpDemoFormPresenter >> modelChanged [
	table items: self model elements
]

{ #category : #accessing }
SpDemoFormPresenter >> resultPane [
	^ resultPane
]

{ #category : #accessing }
SpDemoFormPresenter >> resultPane: anObject [
	resultPane := anObject
]

{ #category : #accessing }
SpDemoFormPresenter >> table [
	^ table
]

{ #category : #accessing }
SpDemoFormPresenter >> table: anObject [
	table := anObject
]
