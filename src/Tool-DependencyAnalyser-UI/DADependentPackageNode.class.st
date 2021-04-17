"
A DADependentPackageNode is used to display a dependent package in a tree.
"
Class {
	#name : #DADependentPackageNode,
	#superclass : #DAAbstractPackageNode,
	#category : #'Tool-DependencyAnalyser-UI-Nodes'
}

{ #category : #api }
DADependentPackageNode >> childNodeClassFor: anItem [
	^ anItem nodeClass
]

{ #category : #accessing }
DADependentPackageNode >> children [
	| aCompositeDependency |
	aCompositeDependency := self compositeDependencyTo.
	^ aCompositeDependency dependencies
]

{ #category : #accessing }
DADependentPackageNode >> compositeDependencyTo [
	"should return one composite dependency anytime"
	^ self content
]

{ #category : #accessing }
DADependentPackageNode >> daPackage [
	^ self parentNode daPackage
]

{ #category : #testing }
DADependentPackageNode >> hasChildren [
	^ [ self content dependencies notEmpty ]
]

{ #category : #accessing }
DADependentPackageNode >> icon [
	^ self iconNamed: #forwardIcon
]

{ #category : #testing }
DADependentPackageNode >> isPackageNode [
	^ true
]

{ #category : #displaying }
DADependentPackageNode >> label [
	^ self rPackage packageName
]

{ #category : #accessing }
DADependentPackageNode >> rPackage [
	^ self content target rPackageSet
]
