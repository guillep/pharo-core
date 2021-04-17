Class {
	#name : #MockMethodGroupQuery,
	#superclass : #Object,
	#category : #'Calypso-SystemTools-Core-Tests-Editors-Classes'
}

{ #category : #converting }
MockMethodGroupQuery >> hasMetaProperty: Something [
	^ true
]

{ #category : #converting }
MockMethodGroupQuery >> itemCount [
	^ 1
]

{ #category : #converting }
MockMethodGroupQuery >> openBrowserCursorFor: anArg [
]

{ #category : #converting }
MockMethodGroupQuery >> scope [
	^ ClySystemScope new
]

{ #category : #converting }
MockMethodGroupQuery >> withMetaLevelScope: anArg [
]
