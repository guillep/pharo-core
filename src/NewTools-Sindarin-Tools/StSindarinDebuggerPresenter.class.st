Class {
	#name : #StSindarinDebuggerPresenter,
	#superclass : #StInspection,
	#instVars : [
		'currentNodeSource',
		'stack',
		'inspector',
		'toolbar'
	],
	#category : #'NewTools-Sindarin-Tools'
}

{ #category : #specs }
StSindarinDebuggerPresenter class >> defaultSpec [
	^ SpBoxLayout newVertical
		add: #toolbar
			withConstraints: [ :constraints | constraints height: self toolbarHeight + 5 ];
		add:
			(SpPanedLayout newVertical
				add: #stack;
				add:
					(SpPanedLayout newHorizontal
						add: #inspector;
						add: #currentNodeSource;
						yourself);
				yourself);
		yourself
]

{ #category : #specs }
StSindarinDebuggerPresenter class >> title [
	^'Sindarin Debugger'
]

{ #category : #initialization }
StSindarinDebuggerPresenter >> buildToolbar [
	| group |
	group := CmCommandGroup forSpec.
	SindarinCommand allSubclasses
		do: [ :cmd | group register: (cmd forSpecContext: self) ].
	^ group asToolbarPresenterWith: [ :presenter |
		presenter 
			displayMode: self application toolbarDisplayMode;
			addStyle: 'stToolbar' ]
]

{ #category : #initialization }
StSindarinDebuggerPresenter >> initializePresenter [
	stack := self newList.
	stack
		whenSelectionChangedDo: [ :selection | 
			selection selectedItem
				ifNil: [ inspector model: nil.
					currentNodeSource text: '' ]
				ifNotNil: [ | node |
					node := selection selectedItem node.
					inspector model: node.
					inspector setAttributeTable.
					currentNodeSource text: node source.
					currentNodeSource beForBehavior: node methodNode methodClass.
					currentNodeSource selectionInterval: (node start to: node stop).
					currentNodeSource
						doItReceiver: selection selectedItem home receiver;
						doItContext: selection selectedItem ].
			currentNodeSource accept ].
	stack items: self model stack.
	inspector := StRawInspection on: self model stack first.
	currentNodeSource := self newCode.
	currentNodeSource
		whenBuiltDo: [ :ann | ann widget font: StandardFonts codeFont ].
	currentNodeSource withSyntaxHighlight.
	currentNodeSource text: self model node source.
	currentNodeSource beForBehavior: self model method methodClass.
	stack selectIndex: 1.
	toolbar := self buildToolbar
]

{ #category : #stepping }
StSindarinDebuggerPresenter >> refresh [ 
	stack items: self model stack.
	stack selectIndex: 1
]

{ #category : #stepping }
StSindarinDebuggerPresenter >> stepIn [ 
	self model step.
	self refresh
]

{ #category : #stepping }
StSindarinDebuggerPresenter >> stepOver [ 
	self model stepOver.
	self refresh
]
