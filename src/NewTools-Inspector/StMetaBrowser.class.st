Class {
	#name : #StMetaBrowser,
	#superclass : #StInspection,
	#instVars : [
		'classes',
		'methods',
		'source'
	],
	#category : #'NewTools-Inspector-View'
}

{ #category : #commands }
StMetaBrowser class >> buildCommandsGroupWith: presenter forRoot: aCmCommandsGroup [

	aCmCommandsGroup
		register: ((CmCommandGroup named: 'classes') asSpecGroup
			beDisplayedAsGroup;
			register: (StInspectorBrowseSelectedCommand forSpecContext: presenter);
			yourself);
		register: ((CmCommandGroup named: 'methods') asSpecGroup
			beDisplayedAsGroup;
			register: (StInspectorInspectSelectedCommand forSpecContext: presenter);
			register: (StInspectorBrowseSelectedCommand forSpecContext: presenter);
			yourself)
]

{ #category : #specs }
StMetaBrowser class >> defaultSpec [
	
	^ SpPanedLayout newVertical
		add: (SpPanedLayout newHorizontal
			add: #classes;
			add: #methods;
			yourself);
		add: #source;
		yourself
]

{ #category : #initialization }
StMetaBrowser >> classListMenu [
	
	^ (self rootCommandsGroup / 'classes') asMenuPresenter 
]

{ #category : #'private actions' }
StMetaBrowser >> compile: aString [
	| compiledSelector cursorPosition |

	cursorPosition := source cursorPositionIndex.

	compiledSelector := self selectedMethod methodClass
		compile: aString
		classified: 	self selectedMethod protocol.
	
	self updateMethods: self selectedClass.
	methods items 
		detect: [ :each | each selector = compiledSelector ]
		ifFound: [ :aMethod | 
			methods selectItem: aMethod.
			source cursorPositionIndex: cursorPosition ]
]

{ #category : #initialization }
StMetaBrowser >> initializePresenters [
	| classHierarchy |
	
	classHierarchy := self model class withAllSuperclasses reversed.

	classes := self newTreeTable
		addColumn: (SpStringTableColumn title: 'Class hierarchy' evaluated: #name);
		roots: { classHierarchy first };
		children: [ :aClass | classHierarchy select: [ :subclass | subclass superclass == aClass ] ];
		contextMenu: [ self classListMenu ];
		yourself.
	methods := (self instantiate: SpFilteringListPresenter)
		display: [ :each | each selector ];	
		contextMenu: [ self methodListMenu ];
		yourself.

	source := self newCode
		lineNumbers: StPharoSettings codeShowLineNumbers;
		beForMethod: self selectedMethod;
		whenSubmitDo: [ :aString | self compile: aString ];
		whenResetDo: [ self updateSourceWith: self selectedMethod  ];
		yourself.
		
	classes 
		transmitTo: methods 
		transform: [ :aClass | self methodsOf: aClass ].
	methods 
		transmitDo: [ :aMethod | self updateSourceWith: aMethod ].

	classes selectPath: (Array new: classHierarchy size withAll: 1)
]

{ #category : #initialization }
StMetaBrowser >> methodListMenu [
	
	^ (self rootCommandsGroup / 'methods') asMenuPresenter
]

{ #category : #private }
StMetaBrowser >> methodsOf: aClass [

	aClass ifNil: [ ^ #() ].
	^ aClass methods sorted: #selector ascending

]

{ #category : #accessing }
StMetaBrowser >> selectedClass [

	^ classes selection selectedItem
]

{ #category : #accessing }
StMetaBrowser >> selectedMethod [

	^ methods selectedItem
]

{ #category : #accessing }
StMetaBrowser >> selectedObject [

	^ self selectedMethod
]

{ #category : #'private updating' }
StMetaBrowser >> updateMethods: aClass [
	
	methods items: (aClass
		ifNotNil: [ aClass methods sorted: #selector ascending ]
		ifNil: [ #() ])
	
]

{ #category : #'private updating' }
StMetaBrowser >> updateSourceWith: method [

	source userActionDuring: [
		method
			ifNotNil: [ 
				source text: method sourceCode; beForMethod: method  ]
			ifNil: [ 
				source text: ''; clearInteractionModel ] ]
]
