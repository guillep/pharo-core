"
A PDAbstractItemDiff is a object which represent an item who added/modified/removed from an old analysis.
"
Class {
	#name : #DAAbstractItemDiff,
	#superclass : #Object,
	#instVars : [
		'new',
		'underteminate',
		'content',
		'diff',
		'removed'
	],
	#category : #'Tool-DependencyAnalyser-Diff'
}

{ #category : #testing }
DAAbstractItemDiff class >> isAbstract [

	^self == DAAbstractItemDiff
]

{ #category : #'instance creation' }
DAAbstractItemDiff class >> newWith: aContent [
	^ (self new)
		content: aContent;
		yourself
]

{ #category : #actions }
DAAbstractItemDiff >> beNew [
	new := true
]

{ #category : #actions }
DAAbstractItemDiff >> beRemoved [
	removed := true
]

{ #category : #testing }
DAAbstractItemDiff >> beUnderteminate [
	underteminate := true
]

{ #category : #testing }
DAAbstractItemDiff >> canBeDisplay [
	^ (self isNew or: [ self isRemoved ]) or: [ self hasChanged ].
]

{ #category : #accessing }
DAAbstractItemDiff >> content [
	 ^ content
]

{ #category : #accessing }
DAAbstractItemDiff >> content: aContent [
	content := aContent
]

{ #category : #accessing }
DAAbstractItemDiff >> diff [
	^ diff
]

{ #category : #accessing }
DAAbstractItemDiff >> diff: anObject [
	diff := anObject
]

{ #category : #testing }
DAAbstractItemDiff >> hasChanged [
	self subclassResponsibility 
]

{ #category : #initialization }
DAAbstractItemDiff >> initialize [
	new := false.
	removed := false.
	underteminate := false
]

{ #category : #testing }
DAAbstractItemDiff >> isNew [
	^ new
]

{ #category : #testing }
DAAbstractItemDiff >> isRemoved [
	^ removed
]

{ #category : #testing }
DAAbstractItemDiff >> isUnderteminate [
	 ^ underteminate 
]

{ #category : #printing }
DAAbstractItemDiff >> printOn: aStream [
	self subclassResponsibility 
]
