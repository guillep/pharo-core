"
I am a ""show if condition is true"" presenter.
My purpose is to allow users to choose different outputs depending on the result of a condition  defined.
The basic usage would be:

[[[language=Smalltalk
choose := self newPresenterSelector
	when: [ aCondition ] show: [ aPresenter ];
	when: [ anotherCondition ] show: [ anotherPresenter ];
	defaultShow: [ defaultPresenter ]
]]]

> self example
"
Class {
	#name : #SpPresenterSelectorPresenter,
	#superclass : #SpPresenter,
	#instVars : [
		'model',
		'cases',
		'default'
	],
	#category : #'Spec2-Core-Widgets'
}

{ #category : #transmission }
SpPresenterSelectorPresenter >> defaultInputPort [

	^ self inputModelPort
]

{ #category : #'api-focus' }
SpPresenterSelectorPresenter >> defaultKeyboardFocus [

	^ layout children 
		ifNotEmpty: [ :children | children first ]
		ifEmpty: [ super defaultKeyboardFocus ]
]

{ #category : #'defining conditions' }
SpPresenterSelectorPresenter >> defaultShow: aPresenterOrBlock [

	default := aPresenterOrBlock
]

{ #category : #initialization }
SpPresenterSelectorPresenter >> initialize [

	cases := SmallDictionary new.
	super initialize.
]

{ #category : #initialization }
SpPresenterSelectorPresenter >> initializePresenters [

	layout := SpBoxLayout newTopToBottom
]

{ #category : #transmission }
SpPresenterSelectorPresenter >> inputModelPort [

	^ SpModelPort newPresenter: self
]

{ #category : #'accessing model' }
SpPresenterSelectorPresenter >> setModel: anObject [

	model := anObject.
	self updatePresenter
]

{ #category : #'accessing model' }
SpPresenterSelectorPresenter >> setModelBeforeInitialization: anObject [

	model := anObject
]

{ #category : #initialization }
SpPresenterSelectorPresenter >> updatePresenter [

	layout removeAll.
	"try to match a case"
	cases keysAndValuesDo: [ :aBlock :aPresenterOrBlock |
		(aBlock cull: model) ifTrue: [ 
			layout add: (aPresenterOrBlock cull: model).
			^ self ] ].
	"no case matches, use the default (if any)"
	default ifNotNil: [
		layout add: (default cull: model) ]
]

{ #category : #'defining conditions' }
SpPresenterSelectorPresenter >> when: conditionBlock show: aPresenterOrBlock [

	cases 
		at: conditionBlock 
		put: aPresenterOrBlock
]
