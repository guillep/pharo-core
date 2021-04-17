Class {
	#name : #SpOverlayLayoutAdapterTest,
	#superclass : #SpLayoutAdapterTest,
	#category : #'Spec2-Backend-Tests-Layout'
}

{ #category : #tests }
SpOverlayLayoutAdapterTest >> newLayout [

	^ SpOverlayLayout new
]

{ #category : #tests }
SpOverlayLayoutAdapterTest >> testAddTwiceReplacesChild [

	| first second |
	layout child: (first := SpButtonPresenter new).
	layout child: (second := SpButtonPresenter new).
	self assert: self adapter children first equals: second adapter widget
]

{ #category : #tests }
SpOverlayLayoutAdapterTest >> testAddTwiceSetsChildrenSingleTime [

	| first second |
	layout child: (first := SpButtonPresenter new).
	layout child: (second := SpButtonPresenter new).
	self assert: self adapter children size equals: 1
]

{ #category : #tests }
SpOverlayLayoutAdapterTest >> testLayoutWithChildAndOverlayHasBothElements [

	| overlay |
	layout child: SpButtonPresenter new.
	layout addOverlay: (overlay := SpButtonPresenter new).
	self assert: self adapter children size equals: 2
]

{ #category : #tests }
SpOverlayLayoutAdapterTest >> testLayoutWithChildIsNotEmpty [

	layout child: SpButtonPresenter new.
	self deny: self adapter isEmpty
]

{ #category : #tests }
SpOverlayLayoutAdapterTest >> testLayoutWithOverlayIsNotEmpty [

	layout addOverlay: SpButtonPresenter new.
	self deny: self adapter isEmpty
]

{ #category : #tests }
SpOverlayLayoutAdapterTest >> testOverlaysAreAddedInOrder [
	| first |

	layout addOverlay: SpButtonPresenter new.
	layout addOverlay: (first := SpButtonPresenter new).
	self assert: self adapter children first equals: first adapter widget
]

{ #category : #tests }
SpOverlayLayoutAdapterTest >> testOverlaysAreBeforeMainChild [

	| overlay |
	layout child: SpButtonPresenter new.
	layout addOverlay: (overlay := SpButtonPresenter new).
	self assert: self adapter children first equals: overlay adapter widget
]

{ #category : #tests }
SpOverlayLayoutAdapterTest >> testRemoveChildAddedAfterOpenRemovesFromAdapter [

	| element |
	layout child: (element := SpButtonPresenter new).
	self openInstance.
	
	layout remove: element.
	self assert: self adapter isEmpty
]

{ #category : #tests }
SpOverlayLayoutAdapterTest >> testRemoveChildElementRemovesFromAdapter [

	| element |
	layout child: (element := SpButtonPresenter new).
	layout remove: element.
	self assert: self adapter isEmpty
]
