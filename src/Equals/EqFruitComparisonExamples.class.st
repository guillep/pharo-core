Class {
	#name : #EqFruitComparisonExamples,
	#superclass : #EqAbstractComparisonExamples,
	#category : #'Equals-Examples'
}

{ #category : #comparisons }
EqFruitComparisonExamples class >> compareApplesOfDifferentColors [
	<script>
	"self compareApplesOfDifferentColors"

	| apple1 apple2 |
	apple1 := EqApple color: Color red.
	apple2 := EqApple color: Color yellow.
	self display: apple1 = apple2
]

{ #category : #comparisons }
EqFruitComparisonExamples class >> compareApplesOfSameColor [
	<script>
	"self compareApplesOfSameColor"

	| apple1 apple2 |
	apple1 := EqApple color: Color red.
	apple2 := EqApple color: Color red.
	self display: apple1 = apple2
]

{ #category : #comparisons }
EqFruitComparisonExamples class >> compareApplesOfSameColorAtDifferentStages [
	<script>
	"self compareApplesOfSameColorAtDifferentStages"

	| apple1 apple2 |
	apple1 := EqApple color: Color red.
	apple1 beRipe.
	apple2 := EqApple color: Color yellow.
	apple2 beRotten.	
	self display: apple1 = apple2
]

{ #category : #comparisons }
EqFruitComparisonExamples class >> compareYellowAppleAndBanana [
	<script>
	"self compareYellowAppleAndBanana"

	| apple banana |
	apple := EqApple color: Color yellow.
	banana := EqBanana new.
	self display: apple = banana
]
