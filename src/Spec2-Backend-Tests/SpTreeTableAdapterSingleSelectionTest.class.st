Class {
	#name : #SpTreeTableAdapterSingleSelectionTest,
	#superclass : #SpAbstractListAdapterSingleSelectionTest,
	#category : #'Spec2-Backend-Tests'
}

{ #category : #accessing }
SpTreeTableAdapterSingleSelectionTest >> classToTest [

	^ SpTreeTablePresenter
]

{ #category : #running }
SpTreeTableAdapterSingleSelectionTest >> initializeTestedInstance [ 

	presenter
		beSingleSelection;
		addColumn: (SpStringTableColumn title: 'Test' evaluated: #asString);
		roots: #(10 20 30).
	
]

{ #category : #'tests-model-to-widget' }
SpTreeTableAdapterSingleSelectionTest >> testSelectManyIndexesKeepsLastSelectionInWidget [
	
	presenter selectPath: #(1).
	presenter selectPath: #(2).
	self assert: self adapter selectedPaths equals: #(#(2))
]

{ #category : #'tests-model-to-widget' }
SpTreeTableAdapterSingleSelectionTest >> testSelectPresenterIndexOutsideRangeUnsetsSelectedIndexInWidget [
	
	presenter selectPath: #(100).
	self assert: self adapter selectedPaths isEmpty
]

{ #category : #'tests-model-to-widget' }
SpTreeTableAdapterSingleSelectionTest >> testSelectPresenterIndexSetsSelectedIndexInWidget [
	
	presenter selectPath: #(1).
	self assert: (self adapter selectedPaths includes: #(1))
]

{ #category : #'tests-model-to-widget' }
SpTreeTableAdapterSingleSelectionTest >> testSelectPresenterItemSetsSelectedIndexInWidget [
	
	self skip. "No selectItem for the moment"
]

{ #category : #'tests-model-to-widget' }
SpTreeTableAdapterSingleSelectionTest >> testSelectPresenterWithScrollingMakeSelectedItemVisible [
	| visibleItems |

	presenter
		roots: (1 to: 200);
		openWithSpec.
		
	presenter selectPath: { 150 } scrollToSelection: true.
	visibleItems := presenter verticalAlignment firstVisibleRowIndex to: presenter verticalAlignment lastVisibleRowIndex.
		
	self assert: (visibleItems includes: presenter selection selectedPath first)
]

{ #category : #'tests-model-to-widget' }
SpTreeTableAdapterSingleSelectionTest >> testSelectPresenterWithoutScrollingDoesNotScroll [
	| visibleItems verticalAlignment |
	
	presenter 
		roots: (1 to: 200);
		openWithSpec.
	verticalAlignment := presenter verticalAlignment.		
	visibleItems := verticalAlignment firstVisibleRowIndex to: verticalAlignment lastVisibleRowIndex.
	
	presenter selectPath: { 150 } scrollToSelection: false.
		
	self 
		assert: (verticalAlignment firstVisibleRowIndex to: verticalAlignment lastVisibleRowIndex) 
		equals: visibleItems
]

{ #category : #tests }
SpTreeTableAdapterSingleSelectionTest >> testSelectWhenSortedTransmitsCorrectElement [
	| item |
	
	presenter columns first beSortable.
	presenter whenSelectionChangedDo: [ :selection | item := selection selectedItem ].	
	self openInstance.
	presenter clickAtPath: #(1).
	self assert: item equals: 10.
	"ascending (no change)"
	presenter adapter sortByColumn: presenter columns first. 
	"desscending (inverses numbers, there will be a change)"
	presenter adapter sortByColumn: presenter columns first.
	"click last element, since they are inversed, it will be the same as before"
	presenter clickAtPath: #(3).
	self assert: item equals: 10
]

{ #category : #'tests-model-to-widget' }
SpTreeTableAdapterSingleSelectionTest >> testSelectWidgetIndexRaisesSelectionIndexChangeEventOnce [
	| counter |
	
	counter := 0.
	presenter selection whenChangedDo: [ :selection | counter := counter + 1 ].
	self adapter selectPath: #(1).
	self assert: counter equals: 1
]

{ #category : #'tests-model-to-widget' }
SpTreeTableAdapterSingleSelectionTest >> testSelectWidgetIndexRaisesSelectionIndexChangeEventWithSelectedIndex [
	| selectedPath |
	
	presenter selection
		whenChangedDo: [ :selection | selectedPath := selection ].
	self adapter selectPath: #(1).
	self assert: selectedPath equals: #(1)
]

{ #category : #'tests-model-to-widget' }
SpTreeTableAdapterSingleSelectionTest >> testUnselectAllInWidgetNotRaisesEmptySelectionChangeEvent [
	| gotSelection |
	
	presenter selection
		whenChangedDo: [ :selection | gotSelection := selection ].
	self adapter selectPath: #().
	self assert: gotSelection isNil
]

{ #category : #'tests-model-to-widget' }
SpTreeTableAdapterSingleSelectionTest >> testUnselectAllInWidgetRaisesSelectionIndexChangeEventOnce [
	| counter |
	
	counter := 0.
	self adapter selectPath: #(1).
	presenter selection
		whenChangedDo: [ :selection | counter := counter + 1 ].
	self adapter selectPath: #().
	self assert: counter equals: 1
]

{ #category : #'tests-model-to-widget' }
SpTreeTableAdapterSingleSelectionTest >> testUnselectAllInWidgetWithoutSelectionDoesNotRaiseEvent [
	| counter |
	
	counter := 0.
	presenter selection
		whenChangedDo: [ :selection | counter := counter + 1 ].
	self adapter selectPath: #().
	self assert: counter equals: 0
]

{ #category : #'tests-model-to-widget' }
SpTreeTableAdapterSingleSelectionTest >> testUnselectPresenterIndexUnselectsIndexInWidget [
	
	presenter
		selectPath: #(1);
		unselectPath: #(1).
	self assert: self adapter selectedPaths isEmpty
]

{ #category : #'tests-model-to-widget' }
SpTreeTableAdapterSingleSelectionTest >> testUnselectPresenterItemUnselectsIndexInWidget [
	
	self skip. "No selectItem for the moment"
]

{ #category : #'tests-model-to-widget' }
SpTreeTableAdapterSingleSelectionTest >> testUnselectWidgetIndexRaisesSelectionIndexChangeEventOnce [
	| counter |
	
	counter := 0.
	self adapter selectPath: #(1).
	presenter selection
		whenChangedDo: [ :selection | counter := counter + 1 ].
	self adapter selectPath: #().
	self assert: counter equals: 1
]

{ #category : #'tests-model-to-widget' }
SpTreeTableAdapterSingleSelectionTest >> testUnselectWidgetIndexRaisesSelectionIndexChangeEventWithSelectedIndex [
	| selectedPath |
	
	self adapter selectPath: #(1).
	presenter selection 
		whenChangedDo: [ :selection | selectedPath := selection ].
	self adapter selectPath: #().
	self assertEmpty: selectedPath
]
