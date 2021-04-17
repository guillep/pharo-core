Class {
	#name : #ClySubclassLOfClass2FromP1,
	#superclass : #ClyClass2FromP1,
	#classVars : [
		'SubclassClassVar'
	],
	#category : #'Calypso-SystemQueries-Tests-P1WithHierarchy'
}

{ #category : #accessing }
ClySubclassLOfClass2FromP1 >> subclassClassVar1Reader [
	^ClassVar1
]

{ #category : #accessing }
ClySubclassLOfClass2FromP1 >> subclassClassVar1Writer [
	ClassVar1 := #subclassClassVar1Value
]

{ #category : #accessing }
ClySubclassLOfClass2FromP1 >> subclassClassVarReader [
	^SubclassClassVar
]
