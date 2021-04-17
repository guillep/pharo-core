Class {
	#name : #SpRubTextFieldMorph,
	#superclass : #RubTextFieldMorph,
	#instVars : [
		'drawKeyboardFocus'
	],
	#category : #'Spec2-Adapters-Morphic-Support'
}

{ #category : #'drag and drop' }
SpRubTextFieldMorph >> acceptDroppingMorph: aTransferMorph event: anEvent [

	^ self model model acceptDrop cull: (SpDragAndDropTransfer new
			   passenger: aTransferMorph passenger;
			   yourself)
]

{ #category : #accessing }
SpRubTextFieldMorph >> drawKeyboardFocus: aBoolean [

	self drawFocusBorder: aBoolean.
	drawKeyboardFocus := aBoolean
]

{ #category : #drawing }
SpRubTextFieldMorph >> drawKeyboardFocusOn: aCanvas [

	drawKeyboardFocus ifFalse: [ ^ self ].
	^ super drawKeyboardFocusOn: aCanvas
]

{ #category : #initialization }
SpRubTextFieldMorph >> initialize [

	super initialize. 
	drawKeyboardFocus := true
]

{ #category : #'drag and drop' }
SpRubTextFieldMorph >> wantsDroppedMorph: aTransferMorph event: anEvent [

	^ aTransferMorph isTransferable and: [ 
		  self model model wantsDrop cull: (SpDragAndDropTransfer new
				   passenger: aTransferMorph passenger;
				   yourself) ]
]
