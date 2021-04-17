Class {
	#name : #SpMorphicPanedLayoutTest,
	#superclass : #TestCase,
	#instVars : [
		'instance'
	],
	#category : #'Spec2-Morphic-Backend-Tests'
}

{ #category : #running }
SpMorphicPanedLayoutTest >> tearDown [

	instance ifNotNil: [ 
		instance window close.
		instance := nil ].
	super tearDown
]

{ #category : #tests }
SpMorphicPanedLayoutTest >> testListTakesAssignedSpace [
	| list |

	(instance := SpPresenter new) 
		layout: (SpPanedLayout newVertical 
			add: (SpPanedLayout newHorizontal
				add: (list := instance newTree);
				add: (instance newLabel);
				yourself);
			add: instance newText;
			yourself).
		
	list items: #(a).
	
	instance openWithSpec.

	self 
		assert: list adapter widget container width 
		equals: list adapter widget width
]
