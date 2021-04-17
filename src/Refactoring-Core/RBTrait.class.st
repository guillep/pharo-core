"
I represent the instance side of a trait in a refactoring namespace. 

I shouldn't be created directly, but always be part of a refactoring namespace.
My  namespace usally knows me and my meta class.
"
Class {
	#name : #RBTrait,
	#superclass : #RBClass,
	#instVars : [
		'users'
	],
	#category : #'Refactoring-Core-Model'
}

{ #category : #accessing }
RBTrait >> definesInstanceVariable: aString [ 
	^ self directlyDefinesInstanceVariable: aString
]

{ #category : #testing }
RBTrait >> isTrait [
	^ true
]

{ #category : #accessing }
RBTrait >> superclass [
	^ nil
]

{ #category : #accessing }
RBTrait >> users [
	^ users ifNil: [ users := realClass users collect: [ :e | model classNamed: e name ] ]
]
