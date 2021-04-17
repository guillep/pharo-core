"
I am a command decorator adding informations useful when for usage in context of a Spec application.

Basically, I add:
- an #icon (#blank by default)
- a #shortcutKey (optional)
- a #displayStrategy to handle how to show the command if it is not executable on a context (default is to be disabled)
- a #positionStrategy to handle on which side presenter with left and right side I should be (default is left)

"
Class {
	#name : #SpCommand,
	#superclass : #CmUICommand,
	#instVars : [
		'buildPresenterBlock',
		'presenter'
	],
	#category : #'Spec2-Commander2-Core'
}

{ #category : #converting }
SpCommand >> asButtonPresenter [
	self flag: #TODO. "Needs to use inform user display strategy when available, no other available strategy can be used in this context. See issue #705"
	self configureAsButton.
	^ self buildPresenter
]

{ #category : #'presenter building' }
SpCommand >> buildPresenter [
	^ presenter := self buildPresenterBlock value: self
]

{ #category : #accessing }
SpCommand >> buildPresenterBlock [
	^ buildPresenterBlock
]

{ #category : #accessing }
SpCommand >> buildPresenterBlock: anObject [
	buildPresenterBlock := anObject
]

{ #category : #'presenter building' }
SpCommand >> configureAsButton [
	self configureAsButtonOfClass: SpButtonPresenter
]

{ #category : #'presenter building' }
SpCommand >> configureAsButtonOfClass: aButtonClass [
	self
		buildPresenterBlock: [ :specCommand | 
			aButtonClass new
				label: specCommand name;
				help: specCommand description;
				in: [ :button | 
					specCommand hasIcon
						ifTrue: [ button icon: specCommand icon ] ];
				action: [ specCommand execute ];
				yourself ]
]

{ #category : #'presenter building' }
SpCommand >> configureAsToolBarToggleButton [
	self configureAsButtonOfClass: SpToolbarToggleButtonPresenter
]

{ #category : #'presenter building' }
SpCommand >> configureAsToolbarButton [
	self configureAsButtonOfClass: SpToolbarButtonPresenter
]

{ #category : #displaying }
SpCommand >> displayIn: aMenuGroupOrPresenter do: aBlock [

	self displayStrategy 
		display: self 
		in: aMenuGroupOrPresenter 
		do: aBlock
]

{ #category : #initialization }
SpCommand >> initialize [

	super initialize.
	self configureAsToolbarButton
]

{ #category : #accessing }
SpCommand >> innerCommand [
	| innerCommand |

	innerCommand := self decoratedCommand.
	[ innerCommand isKindOf: CmCommandDecorator ]
	whileTrue: [ innerCommand := innerCommand decoratedCommand ].

	^ innerCommand
]

{ #category : #accessing }
SpCommand >> presenter [
	^ presenter
]

{ #category : #updating }
SpCommand >> updateEnableStatus [ 
 	self presenter ifNil: [ ^ self ].   
	self presenter enabled: self canBeExecuted
]
