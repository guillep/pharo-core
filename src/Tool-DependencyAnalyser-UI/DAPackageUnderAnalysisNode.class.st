"
A DAPackageNode is used to display a package in a tree.
"
Class {
	#name : #DAPackageUnderAnalysisNode,
	#superclass : #DAAbstractPackageNode,
	#category : #'Tool-DependencyAnalyser-UI-Nodes'
}

{ #category : #comparing }
DAPackageUnderAnalysisNode >> <= aDANode [ 
	^ (aDANode class respondsTo: #packageName) and: [ self packageName <= aDANode packageName ]
]

{ #category : #dependencies }
DAPackageUnderAnalysisNode >> assemblyNodeFor: anAssemblyManifest [
	^ (DAAssemblyNode newWith: (self packageDependencies 
			select: [ :dependency | anAssemblyManifest includes: dependency packageName ]
			thenCollect: #asPackageDependencyWrapper))
		content: anAssemblyManifest packageName;
		yourself
]

{ #category : #dependencies }
DAPackageUnderAnalysisNode >> assemblyNodesFor: aListOfAssemblyManifest [
	^ aListOfAssemblyManifest 
		collect: [ :each | self assemblyNodeFor: each ]
		as: OrderedCollection
]

{ #category : #api }
DAPackageUnderAnalysisNode >> childNodeClassFor: anItem [
	 ^ anItem nodeClass
]

{ #category : #accessing }
DAPackageUnderAnalysisNode >> children [
	^ (self packageDependencies"GroupedByAssembly" sort: [ :a :b | a packageName < b packageName])
		copyWith: DAPotentialDependenciesNode new
]

{ #category : #accessing }
DAPackageUnderAnalysisNode >> daPackage [
	^ self content
]

{ #category : #testing }
DAPackageUnderAnalysisNode >> hasChildren [
	^ [ true ]
]

{ #category : #accessing }
DAPackageUnderAnalysisNode >> icon [
	^ self iconNamed: #packageIcon
]

{ #category : #testing }
DAPackageUnderAnalysisNode >> isPackageNode [
	^ true
]

{ #category : #accessing }
DAPackageUnderAnalysisNode >> manuallyResolvedDependencies [
	^ self packageUnderAnalysis manuallyResolvedDependencies
		collect: [ :packageName | DAManuallyAddedDependentPackageNode new content: packageName ]
]

{ #category : #dependencies }
DAPackageUnderAnalysisNode >> packageDependencies [
	^ self rootNode isCycle
		ifTrue: [ self rootNode content dependentPackagesFrom: self content ]
		ifFalse: [ self content dependencies ]
]

{ #category : #accessing }
DAPackageUnderAnalysisNode >> packageName [
	^ self daPackage packageName
]

{ #category : #printing }
DAPackageUnderAnalysisNode >> printOn: aStream [
	super printOn: aStream.
	aStream nextPut: $(.
	self content printOn: aStream.
	aStream nextPut: $)

]

{ #category : #'browse-nautilus' }
DAPackageUnderAnalysisNode >> selectInBrowser [
	self selectPackage: self content rPackage
]

{ #category : #dependencies }
DAPackageUnderAnalysisNode >> wrappedPackageDependencies [
	^ (self packageDependencies
		collect: #asPackageDependencyWrapper 
		as: OrderedCollection) sorted
]

{ #category : #dependencies }
DAPackageUnderAnalysisNode >> wrappedPackageDependenciesGroupedByAssembly [
	| assemblyNodes |
	assemblyNodes := self assemblyNodesFor: { CollectionsAssembly . PharoKernelAssembly }.
	^ ((self packageDependencies
		reject: [ :dependency | 
			assemblyNodes anySatisfy: [ :assemblyNode | assemblyNode includes: dependency packageName ] ]
		thenCollect: #asPackageDependencyWrapper) sorted asOrderedCollection)
		addAll: assemblyNodes;
		yourself
]
