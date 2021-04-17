"
A MethodBrowser is a simple browser using Spec to display a list of methods and their source code

self example
"
Class {
	#name : #SpMethodBrowser,
	#superclass : #SpPresenter,
	#instVars : [
		'listModel',
		'textModel',
		'toolbarModel'
	],
	#category : #'Spec2-Morphic-Examples-Standalone'
}

{ #category : #specs }
SpMethodBrowser class >> defaultSpec [
	^ SpPanedLayout newTopToBottom
		add: #listModel;
		add:
			(SpBoxLayout newTopToBottom
				add: #toolbarModel withConstraints: [ :constraints | constraints height: self toolbarHeight ];
				add: #textModel;
				yourself);
		yourself
]

{ #category : #example }
SpMethodBrowser class >> example [
	<sampleInstance>
	| example |
	example := SpMethodBrowser new.
	example methods: Object methods;
	 openWithSpec.
	^example
]

{ #category : #specs }
SpMethodBrowser class >> title [

	^ 'Method Browser'
]

{ #category : #accessing }
SpMethodBrowser >> action [
	^ textModel acceptBlock
]

{ #category : #initialization }
SpMethodBrowser >> connectPresenters [

	listModel whenSelectionChangedDo: [ :selection | 
		selection isEmpty
			ifTrue: [ 
				textModel text: ''.
				textModel beForMethod: nil.
				toolbarModel method: nil ]
			ifFalse: [ | m |
				m := selection selectedItem. 
				textModel text: m sourceCode.
				textModel beForMethod: m.
				toolbarModel method: m ] ].
	self whenSubmitDo: [ :text | self listModel selectedItem inspect ].
	self wrapWith: [ :item | item methodClass name , '>>#' , item selector ]
]

{ #category : #api }
SpMethodBrowser >> displayBlock: aBlock [

	listModel displayBlock: aBlock
]

{ #category : #initialization }
SpMethodBrowser >> initializePresenters [
	listModel := self instantiate: SpListPresenter .
	textModel := self newCode.
	toolbarModel := self instantiate: SpMethodToolbar.
	self focusOrder
		add: listModel;
		add: toolbarModel;
		add: textModel
]

{ #category : #accessing }
SpMethodBrowser >> listModel [

	^ listModel
]

{ #category : #api }
SpMethodBrowser >> methods: aList [

	"Here I reroute my entry point to the list model's entry point"
	self listModel items: aList
]

{ #category : #api }
SpMethodBrowser >> sortingBlock: aBlock [ 

	listModel sortingBlock: aBlock 
]

{ #category : #focus }
SpMethodBrowser >> takeKeyboardFocus [

	^ self listModel takeKeyboardFocus
]

{ #category : #accessing }
SpMethodBrowser >> textModel [

	^ textModel
]

{ #category : #accessing }
SpMethodBrowser >> toolbarModel [

	^ toolbarModel
]

{ #category : #accessing }
SpMethodBrowser >> whenSubmitDo: aBlock [

	textModel whenSubmitDo: aBlock
]

{ #category : #api }
SpMethodBrowser >> wrapWith: aBlock [
	listModel display: aBlock
]
