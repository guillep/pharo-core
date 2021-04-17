Class {
	#name : #GLMPhlowTableBrick,
	#superclass : #GLMPhlowListBrick,
	#instVars : [
		'transformedEntity',
		'columns'
	],
	#category : #'Glamour-Morphic-Brick-Widgets-Phlow'
}

{ #category : #examples }
GLMPhlowTableBrick class >> example [
	<sampleInstance>
	
	^ GLMCompositeBrick gtExampleTable
]

{ #category : #accessing }
GLMPhlowTableBrick >> addColumn: aColumn [

	self columns add: aColumn
]

{ #category : #phlow }
GLMPhlowTableBrick >> column: anObject evaluated: otherObject [

	self column: anObject evaluated: otherObject styled: nil
]

{ #category : #phlow }
GLMPhlowTableBrick >> column: anObject evaluated: otherObject styled: anotherObject [

	self addColumn: (GLMPhlowTableColumn new 
		title: anObject;
		computation: otherObject;
		style: anotherObject)
]

{ #category : #accessing }
GLMPhlowTableBrick >> columns [

	^ columns ifNil: [ columns := OrderedCollection new ]
]

{ #category : #phlow }
GLMPhlowTableBrick >> display: anObject [
	
	self setProperty: #phlowDisplay toValue: anObject
	
]

{ #category : #accessing }
GLMPhlowTableBrick >> displayLogic [

	^ self valueOfProperty: #phlowDisplay ifAbsent: [ #yourself ]
]

{ #category : #phlow }
GLMPhlowTableBrick >> entity: anObject [

	self transformedEntity: (self displayLogic phlowValue: anObject).
	super entity: anObject.
]

{ #category : #private }
GLMPhlowTableBrick >> setAdaptor [
	| adaptor |
	adaptor := (GLMBrickListModel on: self transformedEntity)
		morphAtLogic: [ :index | 
			GLMPhlowTableRowBrick new
				in: self;
				entity: (self transformedEntity at: index) ].
	self listBrick model: adaptor
]

{ #category : #accessing }
GLMPhlowTableBrick >> transformedEntity [

	^ transformedEntity
]

{ #category : #accessing }
GLMPhlowTableBrick >> transformedEntity: anObject [

	transformedEntity := anObject
]
