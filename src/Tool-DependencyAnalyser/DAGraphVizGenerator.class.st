"
A class able to generate a dot file to represent a graph.
"
Class {
	#name : #DAGraphVizGenerator,
	#superclass : #Object,
	#instVars : [
		'builder',
		'graphviz',
		'nameOfGraph'
	],
	#category : #'Tool-DependencyAnalyser-Core'
}

{ #category : #testing }
DAGraphVizGenerator class >> isAbstract [

	^ self == DAGraphVizGenerator
]

{ #category : #'instance creation' }
DAGraphVizGenerator class >> newWith: aContent named: aString [
	self subclassResponsibility
]

{ #category : #'build items' }
DAGraphVizGenerator >> buildGraphViz [
	graphviz := (self class environment at: #GVGraphViz) new.
	graphviz
		beDirected;
		name: self nameOfGraph.
	graphviz add: #node with: {(#shape -> #box)}.
	graphviz add: #graph with: { (#label -> self nameOfGraph). (#fontsize -> 20) }.	
	
	self
		buildNodes;
		buildEdges.
]

{ #category : #accessing }
DAGraphVizGenerator >> builder [
	^ builder
]

{ #category : #accessing }
DAGraphVizGenerator >> graphviz [
	^ graphviz
]

{ #category : #accessing }
DAGraphVizGenerator >> nameOfGraph [
	^ nameOfGraph ifNil: [ 'UnamedGraph' ]
]

{ #category : #accessing }
DAGraphVizGenerator >> nameOfGraph: anObject [
	nameOfGraph := anObject
]

{ #category : #saving }
DAGraphVizGenerator >> openWith: extension [
	"make sure the .gv is generated and converted into a image format"
	graphviz openInWindowWith: extension
]

{ #category : #saving }
DAGraphVizGenerator >> saveDotFileAndGenerateForType: extension [
	^ graphviz generator makeNoWait: extension.
]
