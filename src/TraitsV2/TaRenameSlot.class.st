"
I am able to rename a slot in a trait, so it does not conflict with the ones in the class.
Also I rename all the uses of this slot in my methods.
I implement the #>> operator in traits.
"
Class {
	#name : #TaRenameSlot,
	#superclass : #TaSingleComposition,
	#instVars : [
		'renames'
	],
	#category : #'TraitsV2-Compositions'
}

{ #category : #'instance creation' }
TaRenameSlot class >> from:oldName to: newName on: aTrait [
	^ self new 
		oldName: oldName;
		newName: newName;
		inner: aTrait;
		yourself.
]

{ #category : #'instance creation' }
TaRenameSlot class >> rename: anArrayOfAssociations on: aTrait [
	^ self new 
		renames: anArrayOfAssociations;
		inner: aTrait;
		yourself.
]

{ #category : #copying }
TaRenameSlot >> copyTraitExpression [
	^ self class rename: renames on: inner
]

{ #category : #accessing }
TaRenameSlot >> renames [

	^ renames
]

{ #category : #accessing }
TaRenameSlot >> renames: anObject [

	renames := anObject
]

{ #category : #accessing }
TaRenameSlot >> slots [

	^ inner slots collect: [ :slot | 
		  (renames asDictionary includesKey: slot name)
			  ifTrue: [ 
				  (TaRenamedSlotWrapper for: slot) name: (renames asDictionary at: slot name) ]
			  ifFalse: [ slot ] ]
]

{ #category : #accessing }
TaRenameSlot >> sourceCodeAt: aSelector [
	| originalSourceCode parseTree rewriter |
	originalSourceCode := super sourceCodeAt: aSelector.

	parseTree := RBParser parseMethod: originalSourceCode.
	rewriter := RBParseTreeRewriter new.
	
	renames do: [:rename |
		rewriter replace: rename key asString with: rename value asString ].
	
	^(rewriter	
		executeTree: parseTree;
		tree) formattedCode.
]

{ #category : #printing }
TaRenameSlot >> traitCompositionExpression [
	
	^ self inner traitCompositionExpressionWithParens , ' @@ ' , renames printString
]
