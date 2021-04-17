"
I am preview to select variables (Class Variable) 
"
Class {
	#name : #RBVariablesSelectionPresenter,
	#superclass : #RBItemsSelectionPresenter,
	#category : #'SystemCommands-RefactoringSupport'
}

{ #category : #example }
RBVariablesSelectionPresenter class >> example [
	<script>
	^ (self label: 'example ...' 
		withItems: {(ClassVariable named: #a) . (ClassVariable named: #b) . (ClassVariable named: #z) } 
		selecting: {(ClassVariable named: #z) . (ClassVariable named: #a) } )
]

{ #category : #specs }
RBVariablesSelectionPresenter class >> title [ 
	^ 'Class variables'
]

{ #category : #attributes }
RBVariablesSelectionPresenter >> columnName [
	^ 'Variables'
]

{ #category : #attributes }
RBVariablesSelectionPresenter >> columnSelector [ 
	^ #name
]
