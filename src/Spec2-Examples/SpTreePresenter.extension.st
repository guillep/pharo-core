Extension { #name : #SpTreePresenter }

{ #category : #'*Spec2-Examples' }
SpTreePresenter class >> example [
	<sampleInstance>
	
	^ self new
		roots: { Object };
		children: [ :aClass | aClass subclasses ];
		displayIcon: [ :aClass | aClass systemIcon ];
		display: [ :aClass | aClass name ];
		openWithSpec
]

{ #category : #'*Spec2-Examples' }
SpTreePresenter class >> exampleExpandPath [
	
	^ self new
		roots: { Object };
		children: [ :aClass | aClass subclasses ];
		displayIcon: [ :aClass | aClass systemIcon ];
		display: [ :aClass | aClass name ];
		expandPath: #(1 1 3); "Object/Exception/Notification"
		openWithSpec
]

{ #category : #'*Spec2-Examples' }
SpTreePresenter class >> exampleExpandRoots [
	
	^ self new
		roots: { Object };
		children: [ :aClass | aClass subclasses ];
		displayIcon: [ :aClass | aClass systemIcon ];
		display: [ :aClass | aClass name ];
		expandRoots;
		openWithSpec
]

{ #category : #'*Spec2-Examples' }
SpTreePresenter class >> exampleSelectPathByItems [
	
	^ self new
		roots: { Object };
		children: [ :aClass | aClass subclasses ];
		displayIcon: [ :aClass | aClass systemIcon ];
		display: [ :aClass | aClass name ];
		openWithSpec;
		selectPathByItems: self withAllSuperclasses reversed allButFirst scrollToSelection: true
]

{ #category : #'*Spec2-Examples' }
SpTreePresenter class >> exampleWithContextMenu [
	<sampleInstance>
	| tree |
	
	^ (tree := self new)
		roots: { Object };
		children: [ :aClass | aClass subclasses ];
		displayIcon: [ :aClass | aClass systemIcon ];
		display: [ :aClass | aClass name ];
		contextMenu: [
			SpMenuPresenter new 
				addGroup: [ :group | group 
					addItem: [ :item | item name: tree selectedItem asString ] ] ];
		openWithSpec
]
