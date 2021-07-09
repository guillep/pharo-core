Class {
	#name : #ScrollbarTest,
	#superclass : #SliderTest,
	#category : #'Morphic-Tests-Widgets'
}

{ #category : #helpers }
ScrollbarTest >> createSlider [

	^ ScrollBarMorph new
		extent: 240 @ 8;
		yourself
]
