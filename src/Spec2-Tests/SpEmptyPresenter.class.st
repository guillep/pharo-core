Class {
	#name : #SpEmptyPresenter,
	#superclass : #SpPresenter,
	#category : #'Spec2-Tests-Layout'
}

{ #category : #initialization }
SpEmptyPresenter >> initializePresenters [
	
	"Empty"
	"This is required only because we are obliged to redefine initializeWidgets in SpPresenter"
]

{ #category : #accessing }
SpEmptyPresenter >> layout: aSpLayout [
	
	layout := aSpLayout
]
