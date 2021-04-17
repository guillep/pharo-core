"
A raw inspection is the basic inspection over any object of the system. 
It will show the variables the object is composed of and it will allow dive into and editing of them.
"
Class {
	#name : #StRawInspection,
	#superclass : #StInspection,
	#instVars : [
		'attributeTable',
		'mementoNodes'
	],
	#category : #'NewTools-Inspector-View'
}

{ #category : #commands }
StRawInspection class >> buildCommandsGroupWith: presenter forRoot: aCmCommandsGroup [
	aCmCommandsGroup
		beDisplayedAsGroup;
		register: (StInspectorInspectSelectedCommand forSpecContext: presenter);
		register: (StInspectorBrowseSelectedCommand forSpecContext: presenter);
		register:
			(SpBrowsePointersToCommand
				forSpecContext: [ presenter selectedItem value ])
]

{ #category : #specs }
StRawInspection class >> defaultSpec [

	^ SpBoxLayout newVertical 
		add: #attributeTable;
		yourself
]

{ #category : #accessing }
StRawInspection class >> label [

	^ 'Raw'
]

{ #category : #api }
StRawInspection >> activateOnDoubleClick [

	attributeTable activateOnDoubleClick
]

{ #category : #api }
StRawInspection >> activateOnSingleClick [

	attributeTable activateOnSingleClick
]

{ #category : #building }
StRawInspection >> addValuesColumn [

	attributeTable addColumn: self valuesColumn
]

{ #category : #building }
StRawInspection >> addVariablesColumn [

	attributeTable addColumn: self variablesColumn
]

{ #category : #ports }
StRawInspection >> defaultOutputPort [

	^ self outputSelectionPort
]

{ #category : #testing }
StRawInspection >> hasOutputActivationPort [

	^ true
]

{ #category : #initialization }
StRawInspection >> initializePresenters [

	attributeTable := self newTreeTable
		beResizable;
		contextMenu: [ self rootCommandsGroup asMenuPresenter ];
		yourself.
	self addVariablesColumn.
	self addValuesColumn.
	self setAttributeTable
]

{ #category : #accessing }
StRawInspection >> inspectorNodes [

	^ self model allInspectorNodes
]

{ #category : #'model access' }
StRawInspection >> model: aModel [

	super model: aModel.
	self setAttributeTable
]

{ #category : #ports }
StRawInspection >> outputActivationPort [
	
	^ (SpActivationPort newPresenter: self) 
		delegateTo: [ attributeTable ];
		yourself
]

{ #category : #ports }
StRawInspection >> outputSelectionPort [
	
	^ (SpSelectionPort newPresenter: self)
		delegateTo: [ attributeTable ];
		yourself
]

{ #category : #accessing }
StRawInspection >> selectFirst [

	self selectPath: #(1)
]

{ #category : #accessing }
StRawInspection >> selectPath: aPath [

	attributeTable selectPath: aPath
]

{ #category : #accessing }
StRawInspection >> selectedItem [

	^ attributeTable selectedItem
]

{ #category : #accessing }
StRawInspection >> selectedObject [

	^ attributeTable selectedItem value
]

{ #category : #accessing }
StRawInspection >> selectedPath [

	^ attributeTable selection selectedPath
]

{ #category : #building }
StRawInspection >> setAttributeTable [

	attributeTable
		roots: self inspectorNodes;
		children: [ :node | node children ]
]

{ #category : #stepping }
StRawInspection >> step [
	| rootNodes |

	rootNodes := self model allInspectorNodes.
	mementoNodes ifNil: [ 
		mementoNodes := rootNodes collect: #mementoValue.
		^ self ].
	(rootNodes collect: #value) = mementoNodes ifTrue: [ ^ self ].

	mementoNodes := rootNodes collect: #mementoValue.
	attributeTable updateRootsKeepingSelection: rootNodes
]

{ #category : #building }
StRawInspection >> valuesColumn [

	^ SpStringTableColumn new
		title: 'Value';
		evaluated: #stringValue;
		"beEditable;"
		onAcceptEdition: [ :node :value | 
			self inform: node label , '=' , value asString	"node value: value" ];
		sortFunction: #stringValue ascending;
		yourself
]

{ #category : #building }
StRawInspection >> variablesColumn [

	^ SpCompositeTableColumn new
		title: 'Variable';
		width: 170;
		addColumn: (SpImageTableColumn new
			beNotExpandable;
			evaluated: #icon;
			yourself);
		addColumn: (SpStringTableColumn new
			evaluated: #label;
			yourself);
		sortFunction: #label ascending;
		yourself
]
