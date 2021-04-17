"
I am a morphic adapter used to show a modal for a ModalWindowPresenter in Morphic.
"
Class {
	#name : #SpMorphicModalWindowAdapter,
	#superclass : #SpMorphicDialogWindowAdapter,
	#instVars : [
		'backdropMorph'
	],
	#category : #'Spec2-Adapters-Morphic-Base'
}

{ #category : #protocol }
SpMorphicModalWindowAdapter >> close [
 
	backdropMorph ifNotNil: [ 
		backdropMorph delete.
		backdropMorph := nil ].
	super close
]

{ #category : #testing }
SpMorphicModalWindowAdapter >> closeOnBackdropClick [

	^ self model closeOnBackdropClick
]

{ #category : #'event handling' }
SpMorphicModalWindowAdapter >> mouseClick: evt onBackdrop: aMorph [

	self closeOnBackdropClick ifFalse: [ ^ self ].

	self model triggerCancelAction.
	self model close. "Ensure the modal is closed"
	aMorph delete
]

{ #category : #protocol }
SpMorphicModalWindowAdapter >> open [

	backdropMorph := FullscreenMorph new
		color: self theme modalBackdropColor;
		on: #click send: #mouseClick:onBackdrop: to: self;
		openInWorld;
		yourself.

	self widget beSticky.
	self presenter windowIsOpening.
	"I am copying here what is defined in SystemWindow>>#openModal (but introducing the centered 
	 check inbetween because #openInWorld will use the RealEstateAgent to position the window 
	 and we want to (maybe) center it before showing it."
	self widget openInWorld.
	self presenter isCentered 
		ifTrue: [ self centered ].
	MorphicRenderLoop new doOneCycleWhile: [ self widget isInWorld ]
]
