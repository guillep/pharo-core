"
I am the adapter used to display a NumberInputFieldPresenter with Morphic.

I will display a text morph accepting only number from the user. The up and down keys will increase or decrease the value of the input. On top of that I also have two icons. One with an arrow up and one with an arrow down.
"
Class {
	#name : #SpMorphicNumberInputFieldAdapter,
	#superclass : #SpMorphicTextInputFieldAdapter,
	#category : #'Spec2-Adapters-Morphic-Base'
}

{ #category : #factory }
SpMorphicNumberInputFieldAdapter >> buildWidget [

	| textMorph iconsContainer |	
	textMorph := super buildWidget.
	textMorph announcer when: RubKeystroke send: #keystroke: to: self.

	"We add an arrow up and arrow down to the morph to match common input number implementations"	
	iconsContainer := Morph new
		extent: 12 @ 12;
		color: Color transparent;
		changeTableLayout;
		listDirection: #topToBottom;
		addMorph: (self newIconButtonAction: #decreaseValueOf: with: textMorph iconSelector: #arrowDoubleDownIcon);
		addMorph: (self newIconButtonAction: #increaseValueOf: with: textMorph iconSelector: #arrowDoubleUpIcon);
		yourself.

	"With the layout frame I set next to it, the arrows will be at the top right of the text morph. We should be able to make it vertically centered but I don't know how to do that with morphs. If someone knows, please do :)"
	textMorph
		changeProportionalLayout;
		addMorph: iconsContainer
			fullFrame:
			(LayoutFrame identity
				bottomFraction: 0;
				leftFraction: 1;
				topOffset: 4;
				leftOffset: -25;
				yourself).

	^ textMorph
]

{ #category : #actions }
SpMorphicNumberInputFieldAdapter >> decreaseValueOf: aTextMorph [

	aTextMorph setText: (self decreasedValueFrom: aTextMorph getText)
]

{ #category : #actions }
SpMorphicNumberInputFieldAdapter >> decreasedValueFrom: aString [
	"I get the current value from a string and decrease it by the step.
	
	In case of a float we need to print only up to a number of decimals even if the step is of the right number of decimals because float do not have a good precision."

	| newValue |
	newValue := aString ifEmpty: [ 0 ] ifNotEmpty: [ :text | text asNumber - self model climbRate ].
	newValue := self inBounds: newValue.
	
	^ self model isInteger
		ifTrue: [ newValue rounded asString ]
		ifFalse: [ newValue printShowingDecimalPlaces: self model digits ]
]

{ #category : #'ensure bounds' }
SpMorphicNumberInputFieldAdapter >> inBounds: aNumber [
	"I return a the closest number from my input that is inside the bounds defined by the user.
	
	For example with 10 as min and 20 as max I will return:
	
	- Input: 15 Result: 15
	- Input: 8  Result: 10
	- Input: 25 Result: 20"
	
	^ self inferiorToMaximum: (self superiorToMinimum: aNumber)
]

{ #category : #actions }
SpMorphicNumberInputFieldAdapter >> increaseValueOf: aTextMorph [

	aTextMorph setText: (self increasedValueFrom: aTextMorph getText)
]

{ #category : #actions }
SpMorphicNumberInputFieldAdapter >> increasedValueFrom: aString [
	"I get the current value from a aString and increase it by the step.
	
	In case of a float we need to print only up to a number of decimals even if the step is of the right number of decimals because float do not have a good precision."

	| newValue |
	newValue := aString ifEmpty: [ 0 ] ifNotEmpty: [ :text | text asNumber + self model climbRate ].
	newValue := self inBounds: newValue.
	
	^ self model isInteger
		ifTrue: [ newValue rounded asString ]
		ifFalse: [ newValue printShowingDecimalPlaces: self model digits ]
]

{ #category : #'ensure bounds' }
SpMorphicNumberInputFieldAdapter >> inferiorToMaximum: aNumber [

	^ self model maximum ifNil: [ aNumber ] ifNotNil: [ :max | aNumber min: max ]
]

{ #category : #events }
SpMorphicNumberInputFieldAdapter >> keystroke: aRubricEvent [

	aRubricEvent event keyCharacter = Character arrowUp
		ifTrue: [ self increaseValueOf: aRubricEvent morph.
			^ true ].

	aRubricEvent event keyCharacter = Character arrowDown
		ifTrue: [ self decreaseValueOf: aRubricEvent morph.
			^ true ].
		
	^ false
]

{ #category : #factory }
SpMorphicNumberInputFieldAdapter >> newIconButtonAction: aSymbol with: textMorph iconSelector: anIconSymbol [

	^ IconicButtonMorph new
		  target: self;
		  actionSelector: aSymbol;
		  arguments: { textMorph };
		  labelGraphic: (self iconNamed: anIconSymbol);
		  color: Color transparent;
		  extent: 16 @ 8;
		  borderWidth: 0;
		  yourself
]

{ #category : #testing }
SpMorphicNumberInputFieldAdapter >> shouldAccept: aText [
	| regex value |
	aText ifEmpty: [ ^ true ].

	"First we check if it matches the number type and the number of digits if it is a float."
	regex := self model isInteger
		ifTrue: [ '(\-)?[0-9]*' ]
		ifFalse: [ '(\-)?[0-9]+(\.[0-9]{0,' , self model digits asString , '})?' ].
		
	(regex asRegex matches: aText) ifFalse: [ ^ false ].

	"Then we need to verify the min and max value"
	value := aText asNumber.
	self model minimum ifNotNil: [ :min | value < min ifTrue: [ ^ false ] ].
	self model maximum ifNotNil: [ :max | value > max ifTrue: [ ^ false ] ].
	
	^ true
	
]

{ #category : #'ensure bounds' }
SpMorphicNumberInputFieldAdapter >> superiorToMinimum: aNumber [

	^ self model minimum
		  ifNil: [ aNumber ]
		  ifNotNil: [ :min | aNumber max: min ]
]
