"
A presenter to show a candidate (an option that can be choosen). 

"
Class {
	#name : #StSpotterCandidateLinkPresenter,
	#superclass : #StSpotterBasePresenter,
	#instVars : [
		'iconPresenter',
		'labelPresenter',
		'model'
	],
	#category : #'NewTools-Spotter-View'
}

{ #category : #actions }
StSpotterCandidateLinkPresenter >> activateOn: spotterPresenter [

	spotterPresenter activateLink: self model
]

{ #category : #accessing }
StSpotterCandidateLinkPresenter >> entry [

	^ self model value
]

{ #category : #initialization }
StSpotterCandidateLinkPresenter >> initializePresenters [

	self layout: (SpBoxLayout newHorizontal
		borderWidth: 2;
		spacing: 5;
		vAlignCenter;
		add: (iconPresenter := self newImage) expand: false;
		add: (labelPresenter := self newLabel);
		yourself).
		
	self addStyle: 'stSpotterLink'.
	iconPresenter image: self entry icon.
	labelPresenter label: self entry label
]

{ #category : #'accessing model' }
StSpotterCandidateLinkPresenter >> model [

	^ model
]

{ #category : #'accessing model' }
StSpotterCandidateLinkPresenter >> setModelBeforeInitialization: aCandidateLink [

	model := aCandidateLink
]
