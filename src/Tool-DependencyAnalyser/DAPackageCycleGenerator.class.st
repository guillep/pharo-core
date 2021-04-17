"
A class able to generate a dot file from a package cycle (DAPackageCycle)
"
Class {
	#name : #DAPackageCycleGenerator,
	#superclass : #DAGraphVizGenerator,
	#instVars : [
		'packageCycle'
	],
	#category : #'Tool-DependencyAnalyser-Core'
}

{ #category : #'instance creation' }
DAPackageCycleGenerator class >> newWith: aPackageCycle named: aString [
	
	| generator |
	generator := self new.
	generator packageCycle: aPackageCycle.
	generator nameOfGraph: aString.
	generator buildGraphViz.
	^ generator
	
]

{ #category : #'build items' }
DAPackageCycleGenerator >> buildEdges [
	packageCycle packages
		do: [ :package | 
			(packageCycle dependentPackagesFrom: package)
				do: [ :dependentPackage | graphviz add: package packageName -> dependentPackage packageName with: { #label -> (package dependenciesSizeTo: dependentPackage) } ] ]
		displayingProgress: 'Building edges'
]

{ #category : #'build items' }
DAPackageCycleGenerator >> buildNodes [
	
	packageCycle packages 	
		do: [ :package |
			graphviz add: package packageName.
			 ] displayingProgress: 'Building nodes'
]

{ #category : #accessing }
DAPackageCycleGenerator >> packageCycle [
	^ packageCycle
]

{ #category : #accessing }
DAPackageCycleGenerator >> packageCycle: anObject [
	packageCycle := anObject
]
