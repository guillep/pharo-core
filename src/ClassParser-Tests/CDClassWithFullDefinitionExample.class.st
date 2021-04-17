Class {
	#name : #CDClassWithFullDefinitionExample,
	#superclass : #Object,
	#instVars : [
		'instVar1',
		'instVar2'
	],
	#classVars : [
		'ClassVar1',
		'ClassVar2'
	],
	#classInstVars : [
		'classSideVar1',
		'classSideVar2'
	],
	#category : #'ClassParser-Tests'
}

{ #category : #accessing }
CDClassWithFullDefinitionExample class >> classSideVar1 [

	^ classSideVar1
]

{ #category : #accessing }
CDClassWithFullDefinitionExample class >> classSideVar2 [

	^ classSideVar2
]

{ #category : #accessing }
CDClassWithFullDefinitionExample >> classVar1 [
	^ClassVar1
]

{ #category : #accessing }
CDClassWithFullDefinitionExample >> classVar2 [
	^ClassVar2
]

{ #category : #accessing }
CDClassWithFullDefinitionExample >> instVar1 [

	^ instVar1
]

{ #category : #accessing }
CDClassWithFullDefinitionExample >> instVar2 [

	^ instVar2
]
