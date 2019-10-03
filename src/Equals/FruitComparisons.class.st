Class {
	#name : #FruitComparisons,
	#superclass : #Comparisons,
	#category : #'Equals-Examples'
}

{ #category : #comparisons }
FruitComparisons class >> compareApplesOfDifferentColors [
	"self compareApplesOfDifferentColors"

	| apple1 apple2 |
	apple1 := Apple color: Color red.
	apple2 := Apple color: Color yellow.
	self display: apple1 = apple2
]

{ #category : #comparisons }
FruitComparisons class >> compareApplesOfSameColor [
	"self compareApplesOfSameColor"

	| apple1 apple2 |
	apple1 := Apple color: Color red.
	apple2 := Apple color: Color red.
	self display: apple1 = apple2
]

{ #category : #comparisons }
FruitComparisons class >> compareApplesOfSameColorAtDifferentStages [
	"self compareApplesOfSameColorAtDifferentStages"

	| apple1 apple2 |
	apple1 := Apple color: Color red.
	apple1 beRipe.
	apple2 := Apple color: Color yellow.
	apple2 beRotten.	
	self display: apple1 = apple2
]

{ #category : #comparisons }
FruitComparisons class >> compareYellowAppleAndBanana [
	"self compareYellowAppleAndBanana"

	| apple banana |
	apple := Apple color: Color yellow.
	banana := Banana new.
	self display: apple = banana
]
