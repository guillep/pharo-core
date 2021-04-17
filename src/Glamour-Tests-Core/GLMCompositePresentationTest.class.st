Class {
	#name : #GLMCompositePresentationTest,
	#superclass : #TestCase,
	#category : #'Glamour-Tests-Core'
}

{ #category : #tests }
GLMCompositePresentationTest >> testAdd [
	| composite |
	composite := GLMCompositePresentation new.
	composite add: GLMPresentation new.
	self deny: composite isEmpty.
	self assert: composite presentations size equals: 1
]

{ #category : #tests }
GLMCompositePresentationTest >> testAddRaisesAnnouncement [
	| composite announcementCount pane |
	composite := GLMCompositePresentation new.
	pane := composite pane.
	announcementCount := 0.
	composite entity: 42.
	pane when: GLMMatchingPresentationsChanged do: [:ann | 
		announcementCount := announcementCount + 1 ].
	composite add: GLMPresentation new.
	self assert: announcementCount equals: 1
]

{ #category : #tests }
GLMCompositePresentationTest >> testAddSetsCorrectPane [
	| composite presentation |
	composite := GLMCompositePresentation new.
	presentation := GLMPresentation new.
	composite add: presentation.
	self assert: composite pane equals: presentation pane
]

{ #category : #'tests - composer' }
GLMCompositePresentationTest >> testCompositeWithinCompositeOuterPortEvents [
	| childComposite finder parentComposite count |
	count := 0.
	childComposite := GLMCompositePresentation new.
	finder := childComposite finder.
	finder show: [ :a | a list display: [ :x | 1 to: x ] ].
	finder
		when: GLMPaneAdded
		do: [ :a | count := count + 1 ].
	parentComposite := GLMCompositePresentation new.
	parentComposite custom: childComposite.
	parentComposite startOn: 10.
	self assert: count equals: 1
]

{ #category : #'tests - composer' }
GLMCompositePresentationTest >> testCompositeWithinCompositePanePropagation [
	| composite0 composite1 composite21 composite22 pane |
	composite0 := GLMCompositePresentation new.
	composite1 := GLMCompositePresentation new.
	composite21 := GLMCompositePresentation new.
	composite22 := GLMCompositePresentation new.
	composite21 add: GLMPresentation new.
	composite1 add: composite21.
	composite22 add: GLMPresentation new.
	composite1 add: composite22.
	composite0 add: composite1.
	pane := GLMPane new.
	pane presentations: composite0.
	self assert: composite0 first first first pane equals: pane.
	self assert: (composite0 first at: 2) pane equals: pane.
	self assert: composite0 first first first pane equals: pane.
	self assert: (composite0 first at: 2) first pane equals: pane
]

{ #category : #'tests - composer' }
GLMCompositePresentationTest >> testCreateFinder [
	| show |
	show := GLMCompositePresentation new.
	show finder with: [ :b | b show: [ :a | a text ] ].
	self assert: show size equals: 1.
	self assert: (show first isKindOf: GLMFinder).
	show startOn: 42.
	self assert: show first panes size equals: 1.
	self assert: (show first panes first port: #entity) value equals: 42
]

{ #category : #'tests - composer' }
GLMCompositePresentationTest >> testCreateTabulator [
	| show |
	show := GLMCompositePresentation new.
	show tabulator
		with: [ :b | 
			b row: #one.
			b transmit
				to: #one;
				transformed: [ :x | x + 1 ];
				andShow: [ :a | a text ] ].
	self assert: show size equals: 1.
	self assert: (show first isKindOf: GLMTabulator).
	show startOn: 41.
	self assert: show first panes size equals: 1.
	self assert: (show first panes first port: #entity) value equals: 42
]

{ #category : #tests }
GLMCompositePresentationTest >> testCreation [
	self assertEmpty: GLMCompositePresentation new
]

{ #category : #tests }
GLMCompositePresentationTest >> testDefaultPane [
	| composite |
	composite := GLMCompositePresentation new.
	self assert: composite pane presentations equals: composite
]

{ #category : #tests }
GLMCompositePresentationTest >> testPane [
	| pane composite presentation |
	pane := GLMPane new.
	composite := GLMCompositePresentation new.
	presentation := GLMPresentation new.
	composite add: presentation.
	composite pane: pane.
	self assert: composite pane identicalTo: pane.
	self assert: composite first pane identicalTo: pane
]

{ #category : #tests }
GLMCompositePresentationTest >> testStartingPreservesItself [
	| composite finder |
	composite := GLMCompositePresentation new.
	finder := composite finder.
	composite startOn: 42.
	self assert: composite pane presentations equals: composite.
	self assert: composite first identicalTo: finder
]
