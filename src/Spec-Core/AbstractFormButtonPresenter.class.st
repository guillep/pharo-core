"
AbstractFormButtonPresenter is an abstract class for button of form (like radiobuttons or checkbox).
See AbstractWidgetPresenter

self example

I provide the following variables and their accessors
- activationAction and desactivationAction are actions to perform when I am activeted / desactivated.
- label is the text displayed near the box.
- state is a boolean representing if I am activated, it is false by default

I provide the following methods
- click to simulate a click on me.
- toggleState to reverse my state.

"
Class {
	#name : #AbstractFormButtonPresenter,
	#superclass : #AbstractWidgetPresenter,
	#instVars : [
		'actionWhenActivatedHolder',
		'stateHolder',
		'labelClickableHolder',
		'labelHolder',
		'actionWhenDeactivatedHolder'
	],
	#category : #'Spec-Core-Widgets-Support'
}

{ #category : #api }
AbstractFormButtonPresenter >> activationAction: aBlock [
	"<api: #block getter: #activationAction registration: #whenActivationActionChanged:>"
	"This method is used to set the action to perform when I am activated"
	
	actionWhenActivatedHolder value: aBlock
]

{ #category : #api }
AbstractFormButtonPresenter >> click [
	"<api: #do>"
	"Simulate a click on the checkbox
	Used when the checkboc is a list item"

	self toggleState
]

{ #category : #legacy }
AbstractFormButtonPresenter >> deactivationAction: aBlock [
	"<api: #block getter: #desactivationAction registration: #whenDeactivationActionChanged:>"
	"This method is used to set the action to perform when I am deactivated"
	
	actionWhenDeactivatedHolder value: aBlock
]

{ #category : #initialization }
AbstractFormButtonPresenter >> initialize [

	super initialize.
	actionWhenActivatedHolder := [] asValueHolder.
	actionWhenDeactivatedHolder := [] asValueHolder.
	enabledHolder := true asValueHolder.
	stateHolder := false asValueHolder.
	labelClickableHolder := true asValueHolder. 
	labelHolder := '' asValueHolder.
	stateHolder whenChangedDo: [:bool |
		bool
			ifTrue: actionWhenActivatedHolder value
			ifFalse: actionWhenDeactivatedHolder value.
		self changed: #state ].
	
	labelClickableHolder whenChangedDo: [:aBoolean | self changed: { #labelClickable: . aBoolean } ].
	labelHolder whenChangedDo: [:label | self changed: { #label: . label } ].
]

{ #category : #api }
AbstractFormButtonPresenter >> label [
	"<api: #inspect>"
	^ labelHolder value
]

{ #category : #api }
AbstractFormButtonPresenter >> label: aString [
	"<api: #string getter: #label>"
	"Set the label of the checkbox"

	labelHolder value: aString
]

{ #category : #api }
AbstractFormButtonPresenter >> labelClickable [
"	<api: #inspect>"
	"Return true if the label can be clicked to select the checkbox"

	^ labelClickableHolder value
]

{ #category : #api }
AbstractFormButtonPresenter >> labelClickable: aBoolean [
	"<api: #boolean getter: #labelClickable registration: #whenLabelClickableChanged:>"
	"Set if the label can be clicked to select the checkbox"
	
	labelClickableHolder value: aBoolean
]

{ #category : #'api-valueHolder' }
AbstractFormButtonPresenter >> labelHolder [

	^ labelHolder
]

{ #category : #api }
AbstractFormButtonPresenter >> state [
	"<api: #inspect>"

	"Return the current state of the form button"

	^ stateHolder value
]

{ #category : #api }
AbstractFormButtonPresenter >> state: aBoolean [
	"Set if the checkbox is activated or not"
	"<api: #boolean getter: #state>"
	stateHolder value: aBoolean
]

{ #category : #api }
AbstractFormButtonPresenter >> toggleState [
	"<api: #do>"
	"Toogle the current state of the checkbox"

	self state: self state not
]

{ #category : #'api-events' }
AbstractFormButtonPresenter >> whenActivatedDo: aBlock [
	"This method is used to propagate the event that I have been activated" 
	
	stateHolder whenChangedDo: [:bool | bool ifTrue: aBlock ]
]

{ #category : #'api-events' }
AbstractFormButtonPresenter >> whenActivationActionChanged: aBlock [
	"A block performed when the activation action changed"
	actionWhenActivatedHolder whenChangedDo: aBlock 
]

{ #category : #'api-events' }
AbstractFormButtonPresenter >> whenChangedDo: aBlock [
	"This method is used to propagate the event that I have changed"
	
	stateHolder whenChangedDo: aBlock
]

{ #category : #legacy }
AbstractFormButtonPresenter >> whenDeactivatedDo: aBlock [
	"This method is used to propagate the event that I have been deactivated"
	
	stateHolder whenChangedDo: [:bool | bool ifFalse: aBlock ]
]

{ #category : #legacy }
AbstractFormButtonPresenter >> whenDeactivationActionChanged: aBlock [
	"A block performed when the deactivation action changed"
	actionWhenDeactivatedHolder whenChangedDo:  aBlock 
]

{ #category : #'api-events' }
AbstractFormButtonPresenter >> whenLabelClickableChanged: aBlock [
	"A block performed when the label click is activated or descativated"
	
	labelClickableHolder whenChangedDo:  aBlock 
]
