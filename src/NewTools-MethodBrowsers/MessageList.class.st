"
I am a presenter listing messages. 

I am used by more complexe browsers such as MessageBrowser or VersionBrowser.
	
 
Internal Representation and Key Implementation Points.
--------------------

    Instance Variables
	cachedHierarchy:		<aDictionary>	 	A cache keeping info about the level of a class in the list.
	listModel:				<aListPresenter>	A list presenter to show all the messages.
	model:						<aTool>				A model grouping generic methods for managing packages/classes/groups/methods from a browser
	topologySort:			<aBoolean>		 	A boolean to know if we should use a topology sort or not.

"
Class {
	#name : #MessageList,
	#superclass : #SpPresenter,
	#instVars : [
		'cachedHierarchy',
		'topologySort',
		'model',
		'method',
		'listPresenter'
	],
	#category : #'NewTools-MethodBrowsers-Base'
}

{ #category : #specs }
MessageList class >> defaultSpec [

	^ SpBoxLayout newVertical
		add: #listPresenter;
		yourself
]

{ #category : #actions }
MessageList >> browseClassRefs [

	self currentMethod ifNotNil: [ :aMethod | 
		model browseClassRefsOf: aMethod methodClass ]
]

{ #category : #actions }
MessageList >> browseMessages [
	self currentMethod ifNotNil: [ :aMethod |
		 model browseMessagesFrom: aMethod selector ]
]

{ #category : #actions }
MessageList >> browseMethod [

	self currentMethod ifNotNil: [ :aMethod | aMethod browse ]
]

{ #category : #actions }
MessageList >> browseSendersOfMessage [

	self currentMethod ifNotNil: [ :aMethod |
		model browseSendersOfMessagesFrom: aMethod selector ]
]

{ #category : #actions }
MessageList >> browseVersions [

	self currentMethod ifNotNil: [ :aMethod |
		model browseVersionsFrom: aMethod compiledMethod ]
]

{ #category : #testing }
MessageList >> buildHierarchyForMessages: messages [
	| result classes |
	self topologicSort ifFalse: [ 
		result := IdentityDictionary new.
		messages do: [:m | result at: m put: {} ].
		^ result ].
	
	result := Dictionary new.	
	classes := (messages collect: [ :each | each methodClass ]) asSet.
	messages do: [:message || level class |
		class := message methodClass.
		level := OrderedCollection new.
		class allSuperclassesDo: [:superClass |
			(classes includes: superClass)
				ifTrue: [ level addFirst: superClass ]].
		level addLast: class.
		level addLast: message selector.
		result at: message put: level ].
	^ result
]

{ #category : #testing }
MessageList >> cacheHierarchyForClasses: aCollection [
	cachedHierarchy := self buildHierarchyForMessages: aCollection.
]

{ #category : #api }
MessageList >> contextMenu: aMenuPresenter [
	listPresenter contextMenu: aMenuPresenter
]

{ #category : #private }
MessageList >> currentMethod [

	^ method
]

{ #category : #'private-focus' }
MessageList >> ensureKeyBindingsFor: aWidget [
	aWidget bindKeyCombination: PharoShortcuts current browseShortcut toAction: [ self browseMethod ].
	aWidget bindKeyCombination: PharoShortcuts current inspectItShortcut toAction: [ self inspectMethod ].
	aWidget bindKeyCombination: PharoShortcuts current browseImplementorsShortcut toAction: [ self browseMessages ].
	aWidget bindKeyCombination: PharoShortcuts current browseSendersShortcut toAction: [ self browseSendersOfMessage ].
	aWidget bindKeyCombination: PharoShortcuts current browseReferencesShortcut toAction: [ self browseClassRefs ].
	aWidget bindKeyCombination: PharoShortcuts current browseVersionsShortcut toAction: [ self browseVersions ].
	aWidget bindKeyCombination: PharoShortcuts current removeShortcut toAction: [ self removeMethods ]
]

{ #category : #initialization }
MessageList >> initialize [
	topologySort := true.
	model := AbstractTool new.
	super initialize
]

{ #category : #initialization }
MessageList >> initializePresenters [
	listPresenter := self newTable.

	listPresenter
		sortingBlock: [ :a :b | self sortClassesInCachedHierarchy: a b: b ];
		addColumn: (SpStringTableColumn title: 'Location' evaluated: [ :item | self locationOf: item ]);
		addColumn: (SpStringTableColumn title: 'Selector' evaluated: [ :item | self selectorOf: item ]);
		addColumn: (SpStringTableColumn title: 'Package' evaluated: [ :item | self packageOf: item ]);
		beResizable.
		
	self contextMenu: self messageListMenu
]

{ #category : #actions }
MessageList >> inspectMethod [

	self currentMethod ifNotNil: [ :aMethod | aMethod inspect ]
]

{ #category : #accessing }
MessageList >> listPresenter [

	^ listPresenter
]

{ #category : #accessing }
MessageList >> locationOf: anItem [
	^ String
		streamContents: [ :aStream | 
			3 to: (cachedHierarchy at: anItem) size do: [ :i | aStream << '    ' ].
			aStream << (self methodClassNameForItem: anItem) << ' ('.
			anItem isFromTrait
				ifTrue: [ aStream
						<< anItem compiledMethod origin name;
						space ].
			aStream << (self protocolNameForItem: anItem) << ')' ]
]

{ #category : #accessing }
MessageList >> messageListMenu [
	^ self newMenu
		addGroup: [ :aGroup | 
			aGroup
				addItem: [ :anItem | 
					anItem
						name: 'Browse full...';
						shortcut: $b meta;
						action: [ self selectedMethod browse ] ];
				addItem: [ :anItem | 
					anItem
						name: 'Inspect method...';
						shortcut: $i meta;
						action: [ self selectedMethod inspect ] ] ];
		addGroup: [ :aGroup | 
			aGroup
				addItem: [ :anItem | 
					anItem
						name: 'Remove method...';
						shortcut: $x meta;
						action: [ self selectedMethod removeFromSystem ] ];
				addItem: [ :anItem | 
					anItem
						name: 'Senders of...';
						shortcut: $n meta;
						action: [ model browseSendersOfMessagesFrom: self selectedMethod selector ] ];
				addItem: [ :anItem | 
					anItem
						name: 'Implementors of...';
						shortcut: $m meta;
						action: [ model browseMessagesFrom: self selectedMethod selector ] ] ];
		addItem: [ :anItem | 
			anItem
				name: 'Users of...';
				shortcut: $N meta;
				action: [ model browseClassRefsOf: self selectedMethod methodClass ] ];
		addItem:
			[ :anItem | 
			anItem
				name: 'Versions...';
				shortcut: $v meta;
				action: [ model browseVersionsFrom: self selectedMethod ] ] yourself
]

{ #category : #accessing }
MessageList >> messages [
	^ listPresenter items
]

{ #category : #accessing }
MessageList >> messages: aCollection [
	self cacheHierarchyForClasses: aCollection.
	listPresenter items: cachedHierarchy keys asOrderedCollection.
	listPresenter listSize > 0 ifTrue: [ listPresenter selectIndex: 1 ]
]

{ #category : #private }
MessageList >> methodClassNameForItem: anItem [
	^ anItem methodClass ifNotNil: [ :class | class name ] ifNil: [ '' ]
]

{ #category : #accessing }
MessageList >> model [ 
	^model
]

{ #category : #accessing }
MessageList >> numberOfElements [
	^ listPresenter listSize
]

{ #category : #private }
MessageList >> packageNameForItem: anItem [
	^ anItem package ifNil: [ '' ] ifNotNil: [ :package | package name ]
]

{ #category : #private }
MessageList >> packageOf: anItem [
	^ '[' , (self packageNameForItem: anItem) , ']'
]

{ #category : #private }
MessageList >> protocolNameForItem: anItem [
	^ anItem category ifNil: [ '' ]
]

{ #category : #actions }
MessageList >> removeMethods [

	self currentMethod ifNotNil: [ :aMethod |
		model removeMethod: aMethod inClass: aMethod methodClass ]
]

{ #category : #selecting }
MessageList >> selectIndex: anInteger [

	listPresenter selectIndex: anInteger
]

{ #category : #accessing }
MessageList >> selectMessage: aMessage [
	listPresenter selectItem: aMessage
]

{ #category : #selecting }
MessageList >> selectedIndex [
	^ listPresenter selection selectedIndex
]

{ #category : #accessing }
MessageList >> selectedMessage [
	^ listPresenter selection selectedItem
]

{ #category : #accessing }
MessageList >> selectedMethod [
	self selectedMessage ifNil: [ ^ nil ].

	^ self selectedMessage compiledMethod
]

{ #category : #accessing }
MessageList >> selectorOf: anItem [
	^ anItem selector
]

{ #category : #initialization }
MessageList >> setModelBeforeInitialization: aMethod [ 

	method := aMethod
]

{ #category : #sorting }
MessageList >> sortClassesInCachedHierarchy: aMethodDefinition b: otherMethodDefinition [
	"This method checks wether the cached inheritance hierarchy of a method should be before than the one of another method.
	It compares alphabetically the hierarchy using #compare:
	If both are alphabetically equals, it uses the size the hierarchy.
	We do not know why this is done like this."
	| aMethodHierarchy otherMethodHierarchy minSize|
	aMethodHierarchy := cachedHierarchy at: aMethodDefinition.
	otherMethodHierarchy := cachedHierarchy at: otherMethodDefinition.
	
	minSize := aMethodHierarchy size min: otherMethodHierarchy size.
	
	1 to: minSize do: [ :i | |compare|
		compare := (aMethodHierarchy at: i) printString compare: (otherMethodHierarchy at: i) printString.
		compare ~~ 2
			ifTrue: [  ^ compare == 1 ]].
	^  aMethodHierarchy size < otherMethodHierarchy size
]

{ #category : #api }
MessageList >> sortingBlock: aBlock [
	listPresenter sortingBlock: aBlock
]

{ #category : #accessing }
MessageList >> topologicSort [
	^ topologySort
]

{ #category : #accessing }
MessageList >> topologicSort: anObject [
	topologySort := anObject
]

{ #category : #'api-events' }
MessageList >> whenModelChangedDo: aBlock [
	listPresenter whenModelChangedDo: aBlock
]

{ #category : #'api-events' }
MessageList >> whenSelectedDo: aBlock [

	listPresenter whenSelectedDo: aBlock
]

{ #category : #'api-events' }
MessageList >> whenSelectionChangedDo: aBlock [

	listPresenter whenSelectionChangedDo: aBlock
]
