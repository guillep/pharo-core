"
A class able to generate a dot file from a relationGraph (PDPackageRelationGraph)
"
Class {
	#name : #DAPackageRelationGraphGenerator,
	#superclass : #DAGraphVizGenerator,
	#instVars : [
		'relationGraph'
	],
	#category : #'Tool-DependencyAnalyser-Core'
}

{ #category : #'instance creation' }
DAPackageRelationGraphGenerator class >> newWith: aRelationGraph named: aString [

	| generator |
	generator := self new.
	generator relationGraph: aRelationGraph.
	generator nameOfGraph: aString.
	generator buildGraphViz.
	^ generator
]

{ #category : #'build items' }
DAPackageRelationGraphGenerator >> buildEdges [
	relationGraph packages
		do: [ :package | 
			package dependencies
				do: [ :dependency | 
					graphviz
						add: dependency source packageName -> dependency target packageName
						with: {(#label -> dependency numberOfDependencies)} ] ]
		displayingProgress: 'Building edges'
]

{ #category : #'build items' }
DAPackageRelationGraphGenerator >> buildNodes [
	relationGraph seenPackages do: [ :package | graphviz add: package packageName ] displayingProgress: 'Building nodes'
]

{ #category : #accessing }
DAPackageRelationGraphGenerator >> relationGraph [
	^ relationGraph
]

{ #category : #accessing }
DAPackageRelationGraphGenerator >> relationGraph: anObject [
	relationGraph := anObject
]
