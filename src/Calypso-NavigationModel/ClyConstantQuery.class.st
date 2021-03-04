"
I am special kind of typed query which always return constant collection of items independently of scope.
Items are supposed to be homogeneous collection (a kind of same class).

To create my instance use following methods: 

	ClyConstantQuery returning: { Object. String }.
	ClyConstantQuery returning: { Object. String } as: (ClySortedQueryResult using: ClySortByNameFunction ascending).
	ClyConstantQuery returning: { Object. String } from: aScope 
	
 
Internal Representation and Key Implementation Points.

    Instance Variables
	resultItems:		<Collection>

"
Class {
	#name : #ClyConstantQuery,
	#superclass : #ClyTypedQuery,
	#instVars : [
		'resultItems'
	],
	#category : #'Calypso-NavigationModel-Query'
}

{ #category : #'items type' }
ClyConstantQuery class >> resultItemsType [
	self shouldNotImplement 
]

{ #category : #'instance creation' }
ClyConstantQuery class >> returning: objects [
	^self new 
		resultItems: objects
]

{ #category : #'instance creation' }
ClyConstantQuery class >> returning: objects as: aQueryResult [
	^self new 
		resultItems: objects;
		requiredResult: aQueryResult 
]

{ #category : #'instance creation' }
ClyConstantQuery class >> returning: objects from: aScope [
	^(self from: aScope)
		resultItems: objects
]

{ #category : #comparing }
ClyConstantQuery >> = anObject [
	"Answer whether the receiver and anObject represent the same object."

	self == anObject ifTrue: [ ^ true ].
	super = anObject ifFalse: [ ^ false ].
		
	^ resultItems = anObject resultItems
]

{ #category : #converting }
ClyConstantQuery >> async [
	^self
]

{ #category : #execution }
ClyConstantQuery >> buildResult: aQueryResult [
	aQueryResult fillWith: resultItems
]

{ #category : #execution }
ClyConstantQuery >> checkEmptyResult [
	^resultItems isEmpty
]

{ #category : #execution }
ClyConstantQuery >> collectMetadataOf: aQueryResult by: anEnvironmentPlugin [

]

{ #category : #printing }
ClyConstantQuery >> description [

	^', ' join: (resultItems collect: [:each | each printAsConstantQueryItem])
]

{ #category : #execution }
ClyConstantQuery >> execute [
	| result |
	result := self prepareNewResult.
	result initializeItems.
	self buildResult: result.
	^result
]

{ #category : #printing }
ClyConstantQuery >> fullDescription [
	"Constant query do not depends on scope. And in many cases it is default empty scope.
	So scope here is useless and confusing information. And we just return simple description"
	^self description 
]

{ #category : #comparing }
ClyConstantQuery >> hash [
	"Answer an integer value that is related to the identity of the receiver."

	^super hash bitXor: resultItems hash
]

{ #category : #'system changes' }
ClyConstantQuery >> isResult: aQueryResult affectedBy: aSystemAnnouncement [
	^false
]

{ #category : #accessing }
ClyConstantQuery >> resultItems [
	^ resultItems
]

{ #category : #accessing }
ClyConstantQuery >> resultItems: anObject [
	resultItems := anObject
]

{ #category : #testing }
ClyConstantQuery >> retrievesItem: anObject [
	^resultItems includes: anObject
]

{ #category : #testing }
ClyConstantQuery >> retrievesItemsOfType: itemTypeClass [
	^resultItems anySatisfy: [ :each | 
		each calypsoEnvironmentType = itemTypeClass  ]
]

{ #category : #converting }
ClyConstantQuery >> semiAsync [
	^self
]

{ #category : #converting }
ClyConstantQuery >> withMetaLevelScope: aScopeClass [ 
	^self withScope: (scope withMetaLevel: aScopeClass)
]
