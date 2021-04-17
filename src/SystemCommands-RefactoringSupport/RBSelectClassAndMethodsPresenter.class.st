Class {
	#name : #RBSelectClassAndMethodsPresenter,
	#superclass : #RBAbstractSelectionPresenter,
	#category : #'SystemCommands-RefactoringSupport'
}

{ #category : #example }
RBSelectClassAndMethodsPresenter class >> example [
	<script>
	^ (self label: 'example ...' 
		dropLabel: 'Pull up methods'
		withItems: SycExtractMethodCommand methods
		selecting: {}
		dropItems: SycExtractMethodCommand allSuperclasses
		acceptBlock: [ :item :items |  ] )
]

{ #category : #specs }
RBSelectClassAndMethodsPresenter class >> title [ 
	^ 'Methods'
]

{ #category : #attributes }
RBSelectClassAndMethodsPresenter >> columnName [ 
	^ 'Methods'
]

{ #category : #attributes }
RBSelectClassAndMethodsPresenter >> columnSelector [
	^ #selector
]
