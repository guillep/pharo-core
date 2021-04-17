Class {
	#name : #SpRubScrolledTextMorph,
	#superclass : #RubScrolledTextMorph,
	#category : #'Spec2-Adapters-Morphic-Support'
}

{ #category : #'drag and drop' }
SpRubScrolledTextMorph >> acceptDroppingMorph: aTransferMorph event: anEvent [

	^ self model model acceptDrop cull: (SpDragAndDropTransfer new
			   passenger: aTransferMorph passenger;
			   yourself)
]

{ #category : #'drag and drop' }
SpRubScrolledTextMorph >> wantsDroppedMorph: aTransferMorph event: anEvent [

	^ aTransferMorph isTransferable and: [ 
		  self model model wantsDrop cull: (SpDragAndDropTransfer new
				   passenger: aTransferMorph passenger;
				   yourself) ]
]
