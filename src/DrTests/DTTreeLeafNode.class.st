"
I am a leaf of a Result Tree.
I have te content and I know the way to browse myself. 
"
Class {
	#name : #DTTreeLeafNode,
	#superclass : #DTAbstractTreeNode,
	#instVars : [
		'content'
	],
	#category : #'DrTests-Model'
}

{ #category : #'instance creation' }
DTTreeLeafNode class >> content: aRottenTest [ 
	^ self new
		content: aRottenTest;
		yourself
]

{ #category : #visiting }
DTTreeLeafNode >> acceptVisitor: aDTResultsTreeVisitor [
	^ aDTResultsTreeVisitor visitDTTreeLeaf: self
]

{ #category : #testing }
DTTreeLeafNode >> canBeBrowsed [
	^ true
]

{ #category : #accessing }
DTTreeLeafNode >> content [
	^ content
]

{ #category : #accessing }
DTTreeLeafNode >> content: anObject [
	content := anObject
]

{ #category : #accessing }
DTTreeLeafNode >> contentForReRun [
	^ { self content }
]

{ #category : #actions }
DTTreeLeafNode >> drTestsBrowse [
	self content drTestsBrowse
]

{ #category : #menu }
DTTreeLeafNode >> drTestsBuildContextMenu: menu [
	self content drTestsBuildContextMenu: menu
]

{ #category : #accessing }
DTTreeLeafNode >> drTestsName [
	^ self content drTestsName
]

{ #category : #testing }
DTTreeLeafNode >> isLeaf [
	^ true
]
