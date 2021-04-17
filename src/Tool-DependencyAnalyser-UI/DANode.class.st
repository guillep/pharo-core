"
This is an abstract class for to display nodes in a tree.
"
Class {
	#name : #DANode,
	#superclass : #TreeNodePresenter,
	#instVars : [
		'treeModelParent',
		'cycle',
		'browser'
	],
	#category : #'Tool-DependencyAnalyser-UI-Nodes'
}

{ #category : #testing }
DANode class >> isAbstract [

	^ self == DANode
]

{ #category : #'building-menu' }
DANode >> addMenuEntriesOn: aMenuGroup [
	"overide this method to add contextual menu on nodes"
]

{ #category : #'browse-nautilus' }
DANode >> browseClass: classToBrowse [
	Smalltalk tools browser openOnClass: classToBrowse
]

{ #category : #accessing }
DANode >> browser [
	^ browser
]

{ #category : #accessing }
DANode >> browser: anObject [
	browser := anObject
]

{ #category : #accessing }
DANode >> cycle: anObject [
	cycle := anObject
]

{ #category : #testing }
DANode >> isClassToDependencyNode [
	^ false
]

{ #category : #testing }
DANode >> isCycle [
	^ cycle
]

{ #category : #testing }
DANode >> isCycleNode [
	^ false
]

{ #category : #testing }
DANode >> isPackageNode [
 	^ false
]

{ #category : #testing }
DANode >> isReferenceNode [
	^ false
]

{ #category : #displaying }
DANode >> label [
	^ self content displayString
]

{ #category : #accessing }
DANode >> packageUnderAnalysis [
	^ self rootNode daPackage rPackageSet packages first
]

{ #category : #private }
DANode >> rootNode [
	| rootNode currentNode |
	currentNode := self.
	rootNode := currentNode parentNode.
	[ rootNode isNil ]
		whileFalse: [ 
			currentNode := rootNode.
			rootNode := currentNode parentNode ].
	^ currentNode.
]

{ #category : #'browse-nautilus' }
DANode >> selectClass: aClass [
	| aBrowser |
	
	aBrowser := self rootNode browser.
	aBrowser selectClass: aClass
]

{ #category : #'browse-nautilus' }
DANode >> selectInBrowser [
	^ self subclassResponsibility
]

{ #category : #'browse-nautilus' }
DANode >> selectMethod: aMethod [
	| classToBrowse aBrowser compiledMethod |
	aBrowser := self rootNode browser.
	classToBrowse := aMethod methodClass.
	compiledMethod := classToBrowse>>aMethod selector.
	aBrowser selectMethod: compiledMethod
]

{ #category : #'browse-nautilus' }
DANode >> selectPackage: aPackage [
	| aBrowser |
	aBrowser := self rootNode browser.
	aBrowser selectPackage: aPackage
]

{ #category : #'browse-nautilus' }
DANode >> spawnNewBrowser [
	"do nothing by default"
]

{ #category : #accessing }
DANode >> treeModelParent [
	^ treeModelParent
]

{ #category : #accessing }
DANode >> treeModelParent: anObject [
	treeModelParent := anObject
]
