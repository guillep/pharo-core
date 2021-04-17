"
This kind of critiques occur when a method is missing. The critique knows what is the selector of the missing method, and it's perspective class. The critique provides a change which is a creation of the missing method. Also a sourcecode of a method can be specified. For now there are two shortcuts for the source code, that set it to either subclassResponsability or shouldBeImplemented 
"
Class {
	#name : #ReMissingMethodCritique,
	#superclass : #ReAbstractCritique,
	#instVars : [
		'selector',
		'class',
		'source'
	],
	#category : #'Renraku-Critiques'
}

{ #category : #'as yet unclassified' }
ReMissingMethodCritique class >> for: anEntity by: aRule class: aClass selector: aSymbol [

	^ self basicNew 
		initializeRule: aRule target: anEntity class: aClass selector: aSymbol;
		yourself 
]

{ #category : #actions }
ReMissingMethodCritique >> beShouldBeImplemented [
	"set the sorce code of the method-to-be-created to shouldBeImplemented"

	source := '^ self shouldBeImplemented' 
]

{ #category : #actions }
ReMissingMethodCritique >> beSubclassResponsibility [
	"set the sorce code of the method-to-be-created to subclassResponsibility"

	source := '^ self subclassResponsibility' 
]

{ #category : #accessing }
ReMissingMethodCritique >> change [
	"an 'add method' change that create the missing method"
	
	^ (RBRefactoryChangeFactory instance) 
		addMethodSource: (self methodHeader), String cr, String tab, source
		in: class
]

{ #category : #initialization }
ReMissingMethodCritique >> initialize [
	super initialize.
	source := ''
]

{ #category : #initialization }
ReMissingMethodCritique >> initializeRule: aRule target: anEntity class: aClass selector: aSymbol [

	self initializeRule: aRule target: anEntity.
	class := aClass.
	selector :=  aSymbol.
	
	tinyHint := class == self entity 
		ifTrue: [ selector ]
		ifFalse: [ class name, '>>#', selector ]
]

{ #category : #private }
ReMissingMethodCritique >> methodHeader [

	 ^ ($: split: selector) allButLast
		ifEmpty: [ selector ]
		ifNotEmpty: [ :keywords |
			| index |
			index := 0.
			keywords inject: '' into: [ :header :keyword |
				header, keyword, ': arg', (index := index + 1) asString, ' ' ] ]
]

{ #category : #testing }
ReMissingMethodCritique >> providesChange [
	^ true
]

{ #category : #accessing }
ReMissingMethodCritique >> source [
	"source code of the method-to-be-created excluding selector and args"
	^ source
]

{ #category : #accessing }
ReMissingMethodCritique >> source: anObject [
	"set the source code of the method-to-be-created. This should not include the selector and args"

	source := anObject
]
