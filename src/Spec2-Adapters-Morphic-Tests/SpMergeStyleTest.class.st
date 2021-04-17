Class {
	#name : #SpMergeStyleTest,
	#superclass : #TestCase,
	#instVars : [
		'result',
		'left',
		'right'
	],
	#category : #'Spec2-Adapters-Morphic-Tests'
}

{ #category : #running }
SpMergeStyleTest >> setUp [ 

	super setUp.
	
	left := SpStyle newApplication
					addClass: 'aCommonClass' with: [ :aCommonClass |
						aCommonClass addPropertyDrawWith: [ :propDraw | propDraw color: Color transparent ]];
					addClass: 'leftClass' with: [ :leftClass |
						leftClass addPropertyDrawWith: [ :propDraw | propDraw color: Color red ]].
	
	right := SpStyle newApplication
					addClass: 'aCommonClass' with: [ :aCommonClass |
						aCommonClass addClass: 'inner' with: [ :anInnerClass |  ].
						aCommonClass addPropertyDrawWith: [ :propDraw | propDraw color: Color transparent ].
						aCommonClass addPropertyDrawWith: [ :propDraw | propDraw backgroundColor: Color black ]];
					addClass: 'rightClass' with: [ :rightClass |
						rightClass addPropertyDrawWith: [ :propDraw | propDraw color: Color blue ]].

	
	
]

{ #category : #tests }
SpMergeStyleTest >> testMergingTwoStylesWithASameClassHasClassInBothSides [

	result := (left mergeWith: right) flattenClasses.

	self assert: (result anySatisfy: [ :e | e fullName = 'aCommonClass' ]).
	self assert: (result anySatisfy: [ :e | e fullName = 'aCommonClass.inner' ]).	

]

{ #category : #tests }
SpMergeStyleTest >> testMergingTwoStylesWithASameClassHasCorrectNumberOfEntries [

	result := (left mergeWith: right) flattenClasses.

	self assert: result size equals: 5.

]

{ #category : #tests }
SpMergeStyleTest >> testMergingTwoStylesWithASameClassHasLeftOnlyClass [

	result := (left mergeWith: right) flattenClasses.

	self assert: (result anySatisfy: [ :e | e fullName = 'leftClass' ]).	

]

{ #category : #tests }
SpMergeStyleTest >> testMergingTwoStylesWithASameClassHasRightOnlyClass [

	result := (left mergeWith: right) flattenClasses.

	self assert: (result anySatisfy: [ :e | e fullName = 'rightClass' ]).			

]

{ #category : #tests }
SpMergeStyleTest >> testMergingTwoStylesWithASameClassHasThePropertiesCorrectInCommonClass [

	| innerClass |

	result := (left mergeWith: right) flattenClasses.

	innerClass := result detect: [ :e | e fullName = 'aCommonClass' ].
	self assert: innerClass properties size equals: 1.
	self assert: (innerClass properties at: 1) color equals: Color transparent.
	self assert: (innerClass properties at: 1) backgroundColor equals: Color black.
]
