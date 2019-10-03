Class {
	#name : #PersonComparisons,
	#superclass : #Comparisons,
	#category : #'Equals-Examples'
}

{ #category : #comparisons }
PersonComparisons class >> compareStudentsAndTeacherOfSameAge [
	"self compareStudentsAndTeacherOfSameAge"
	| luc tom |
	luc := Teacher name: 'Luc' age: 24.
	tom := Student name: 'Tom' age: 24.
	self display: luc = tom
]

{ #category : #comparisons }
PersonComparisons class >> compareStudentsAndTeacherOfSameNameAndAge [
	"self compareStudentsAndTeacherOfSameNameAndAge"
	| smith1 smith2 |
	smith1 := Teacher name: 'Smith' age: 24.
	smith2 := Student name: 'Smith' age: 24.
	self display: smith1 = smith2
]

{ #category : #comparisons }
PersonComparisons class >> compareStudentsOfDifferentAge [
	"self compareStudentsOfDifferentAge"
	| luc tom |
	luc := Student name: 'Luc' age: 24.
	tom := Student name: 'Tom' age: 5.
	self display: luc = tom
]

{ #category : #comparisons }
PersonComparisons class >> compareStudentsOfDifferentLevels [
	"self compareStudentsOfDifferentLevels"
	| luc tom |
	luc := Student name: 'Luc' age: 24.
	luc level: 7.
	tom := Student name: 'Tom' age: 24.
	tom level: 4.
	self display: luc = tom
]

{ #category : #comparisons }
PersonComparisons class >> compareStudentsOfSameAgeAndLevel [
	"self compareStudentsOfSameAgeAndLevel"
	| luc tom |
	luc := Student name: 'Luc' age: 24.
	luc level: 5.
	tom := Student name: 'Tom' age: 24.
	tom level: 5.
	self display: luc = tom
]
