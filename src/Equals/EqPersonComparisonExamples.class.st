Class {
	#name : #EqPersonComparisonExamples,
	#superclass : #EqAbstractComparisonExamples,
	#category : #'Equals-Examples'
}

{ #category : #comparisons }
EqPersonComparisonExamples class >> compareStudentsAndTeacherOfSameAge [
	<script>
	"Not equal beause instances of different classes"
	| luc tom |
	luc := EqTeacher name: 'Luc' age: 24.
	tom := EqStudent name: 'Tom' age: 24.
	self display: luc = tom
]

{ #category : #comparisons }
EqPersonComparisonExamples class >> compareStudentsAndTeacherOfSameNameAndAge [
	<script>
	"Not equal beause instances of different classes"
	| smith1 smith2 |
	smith1 := EqTeacher name: 'Smith' age: 24.
	smith2 := EqStudent name: 'Smith' age: 24.
	self display: smith1 = smith2
]

{ #category : #comparisons }
EqPersonComparisonExamples class >> compareStudentsOfDifferentAge [
	<script>
	"Not equal beause different ages"
	| luc tom |
	luc := EqStudent name: 'Luc' age: 24.
	tom := EqStudent name: 'Tom' age: 5.
	self display: luc = tom
]

{ #category : #comparisons }
EqPersonComparisonExamples class >> compareStudentsOfDifferentLevels [
	<script>
	"Not equal beause of different levels"
	| luc tom |
	luc := EqStudent name: 'Luc' age: 24.
	luc level: 7.
	tom := EqStudent name: 'Tom' age: 24.
	tom level: 4.
	self display: luc = tom
]

{ #category : #comparisons }
EqPersonComparisonExamples class >> compareStudentsOfSameAgeAndLevel [
	<script>
	"Equal because same age and same level"
	| luc tom |
	luc := EqStudent name: 'Luc' age: 24.
	luc level: 5.
	tom := EqStudent name: 'Tom' age: 24.
	tom level: 5.
	self display: luc = tom
]
