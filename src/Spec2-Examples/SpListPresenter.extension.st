Extension { #name : #SpListPresenter }

{ #category : #'*Spec2-Examples' }
SpListPresenter class >> example [
	<sampleInstance>
	^ self new
		items: self environment allClasses;
		openWithSpec;
		yourself
]

{ #category : #'*Spec2-Examples' }
SpListPresenter class >> exampleDragAndDrop [
	| list1 list2 |

	(list1 := self new)
		items: #( 'abc' 'def' 'xyz' );
		dragEnabled: true.
		
	(list2 := self new)
		dropEnabled: true;
		wantsDrop: [ :transfer | transfer passenger allSatisfy: #isString ];
		acceptDrop: [ :transfer | list2 items: (list2 items, transfer passenger) ].
				
	SpPresenter new 
		layout: (SpBoxLayout newHorizontal
			add: list1;
			add: list2;
			yourself);
		openWithSpec
]

{ #category : #'*Spec2-Examples' }
SpListPresenter class >> exampleMultipleSelection [
	<sampleInstance>
	^ self new
		items: self environment allClasses;
		beMultipleSelection;
		openWithSpec;
		yourself
]

{ #category : #'*Spec2-Examples' }
SpListPresenter class >> exampleWithHeaderTitle [
	<sampleInstance>
	^ self new
		items: self environment allClasses;
		headerTitle: 'Title';
		openWithSpec;
		yourself
]

{ #category : #'*Spec2-Examples' }
SpListPresenter class >> exampleWithIcons [
	<sampleInstance>
	^ self new
		displayIcon: [ :e | self iconNamed: #forwardIcon ];
		items: (1 to: 10) asArray;
		openWithSpec;
		yourself
]
