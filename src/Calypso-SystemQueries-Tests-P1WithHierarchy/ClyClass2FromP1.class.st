Class {
	#name : #ClyClass2FromP1,
	#superclass : #Object,
	#instVars : [
		'instVar'
	],
	#classVars : [
		'ClassVar1',
		'ClassVar2'
	],
	#category : #'Calypso-SystemQueries-Tests-P1WithHierarchy'
}

{ #category : #accessing }
ClyClass2FromP1 class >> classSideClassVar1Reader [
	^ClassVar1
]

{ #category : #accessing }
ClyClass2FromP1 class >> classSideClassVar1Writer [
	ClassVar1 := #classVar1Value
]

{ #category : #accessing }
ClyClass2FromP1 >> instVar [

	 ^ instVar
]

{ #category : #'as yet unclassified' }
ClyClass2FromP1 >> instanceSideClassVar1Reader [
	^ClassVar1
]

{ #category : #accessing }
ClyClass2FromP1 >> instanceSideClassVar1Writer [
	ClassVar1 := #classVar1Value
]

{ #category : #accessing }
ClyClass2FromP1 >> instanceSideClassVar2Reader [
	^ClassVar2
]
