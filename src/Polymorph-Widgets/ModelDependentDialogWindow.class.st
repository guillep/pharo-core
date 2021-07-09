"
DialogWindow that updates content based upon its model.
"
Class {
	#name : #ModelDependentDialogWindow,
	#superclass : #DialogWindowMorph,
	#category : #'Polymorph-Widgets-Windows'
}

{ #category : #'as yet unclassified' }
ModelDependentDialogWindow >> addInitialPanel [
	"Don't until the model is set."
]

{ #category : #'as yet unclassified' }
ModelDependentDialogWindow >> model: anObject [
	"Set the model and add the panel for it."
	
	super model: anObject.
	self paneMorphs copy do: [:p | p delete].
	self addMainPanel
]
