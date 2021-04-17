"
I'm a code (Pharo code) presenter. 
I will style and provide completion according to the behaviour being edited.

"
Class {
	#name : #SpCodePresenter,
	#superclass : #SpTextPresenter,
	#instVars : [
		'#syntaxHighlight => SpObservableSlot',
		'#lineNumbers => SpObservableSlot',
		'#interactionModel => SpObservableSlot',
		'#overrideContextMenu',
		'#submitBlock',
		'#resetBlock',
		'#environment'
	],
	#category : #'Spec2-Code'
}

{ #category : #specs }
SpCodePresenter class >> adapterName [

	^ #CodeAdapter
]

{ #category : #commands }
SpCodePresenter class >> buildCommandsGroupWith: presenter forRoot: aCmCommandsGroup [

	aCmCommandsGroup beDisplayedAsGroup.
	aCmCommandsGroup register: (self codeSelectionActionCommandsGroupWith: presenter).
	aCmCommandsGroup register: (self codeNavigationCommandsGroupWith: presenter)
]

{ #category : #commands }
SpCodePresenter class >> buildEditionCommandsGroupWith: presenter forRoot: aCmCommandsGroup [

	super buildEditionCommandsGroupWith: presenter forRoot: aCmCommandsGroup.	
	aCmCommandsGroup register: (self codeAcceptCommandsGroupWith: presenter)
]

{ #category : #commands }
SpCodePresenter class >> codeAcceptCommandsGroupWith: aPresenter [
	| commandGroup |

	commandGroup := (CmCommandGroup named: 'Accept commands') asSpecGroup
		description: 'Accept or cancel changes.';
		beDisplayedAsGroup;
		yourself.
	
	aPresenter hasSubmitAction ifTrue: [ 
		commandGroup register: (SpAcceptChangesCommand forSpecContext: aPresenter) ].
	aPresenter hasResetAction ifTrue: [ 
		commandGroup register: (SpCancelChangesCommand forSpecContext: aPresenter) ].

	^ commandGroup
]

{ #category : #commands }
SpCodePresenter class >> codeNavigationCommandsGroupWith: aPresenter [
	| group |
	
	group := (CmCommandGroup named: 'Selection search commands') asSpecGroup
		description: 'Search the system from code selection.';
		beDisplayedAsGroup;
		yourself.
		
	self flag: #TODO. "This looks like a very bad way to do this :P"	
	{ 
		SpBrowseClassCommand.		
		SpBrowseImplementorsCommand.
		SpBrowseSendersCommand.
		SpBrowseMethodReferencesCommand.	
		SpBrowseMethodsContainingStringCommand.
	 } 
	do:[ :commandClass | 
		group register: commandClass forSpec ].
	
	^ group
]

{ #category : #commands }
SpCodePresenter class >> codeSelectionActionCommandsGroupWith: presenter [
	| group |
	
	group := (CmCommandGroup named: 'Selection action commands') asSpecGroup.
	group
		description: 'Actions on code selection.';
		beDisplayedAsGroup.
	
	SpCodeSelectionCommand allOrdered 
		do: [ :cmdClass | group register: (cmdClass forSpecContext: presenter) ].
	
	^ group
]

{ #category : #documentation }
SpCodePresenter class >> documentFactoryMethodSelector [

	^ #newCode
]

{ #category : #examples }
SpCodePresenter class >> example [

	^ self new
		text: 'some method: 42';
		openWithSpec

]

{ #category : #examples }
SpCodePresenter class >> exampleOverridingContextMenu [
	"This example will show a code presenter, but context menu will be overriden and 
	 it will show just what is defined in #contextMenu: send"
	
	^ self new
		overridingContextMenu;
		contextMenu: (SpMenuPresenter new
			addGroup: [ :group | group addItem: [ :item | 
				item name: 'Testing' ] ]);
		text: 'some method: 42';
		openWithSpec
]

{ #category : #specs }
SpCodePresenter class >> title [

	^ 'Code'
]

{ #category : #api }
SpCodePresenter >> allowingContextMenu [
	"Indicates the default context menu should be shown (this is the default behaviour). 
	 When allowing the code context menu, visible operations will be collected from  `SpPresenter>>#rootCommandsGroup` and `SpTextPresenter>>#editionCommandsGroup`, and what user 
	 define on `SpAbstractTextPresenter>>contextMenu:` will be appended between those groups."
	
	self overrideContextMenu: false
]

{ #category : #private }
SpCodePresenter >> basicInteractionModel: anObject [

	interactionModel := anObject
]

{ #category : #'api-model' }
SpCodePresenter >> beForBehavior: aBehavior [
	"used when browsing classes or alike"

	self interactionModel: (SpCodeBehaviorInteractionModel on: aBehavior)
]

{ #category : #'api-model' }
SpCodePresenter >> beForMethod: aMethod [
	"used when browsing methods"

	self interactionModel: (SpCodeMethodInteractionModel on: aMethod)
]

{ #category : #'api-model' }
SpCodePresenter >> beForObject: anObject [
	"Used when inspecting objects"

	self interactionModel: (SpCodeObjectInteractionModel on: anObject)
]

{ #category : #'api-model' }
SpCodePresenter >> beForScripting [
	"Use in playgrounds"

	self interactionModel: SpCodeScriptingInteractionModel new
]

{ #category : #'private bindings' }
SpCodePresenter >> behavior [
	"Return the class corresponding to the method class of the source code you are editing"
	
	^ self interactionModel ifNotNil: [ :im | im behavior ]
]

{ #category : #'private bindings' }
SpCodePresenter >> behavior: aClass [
	"Set the class corresponding to the method class of the source code you are editing"
	
]

{ #category : #'private bindings' }
SpCodePresenter >> bindingOf: aString [

	self interactionModel ifNotNil:  [ :im | ^ im bindingOf: aString  ].
	^ nil
]

{ #category : #'private commands' }
SpCodePresenter >> browseSelectedSelectorIfGlobal: globalBlock ifNotGlobal: nonGlobalBlock [
	| variableOrClassName env |

	variableOrClassName := self selectedSelector.

	env := self environment.
	
	self flag: #bug.
	"If we are looking for implementors of a class variable, this does not work right..."
	env isBehavior ifTrue: [
		(env hasSlotNamed: variableOrClassName) ifTrue: [
		 ^ self systemNavigation browseAllAccessesTo: variableOrClassName from: env ] ].

	(env bindingOf: variableOrClassName) 
		ifNotNil: [ :ref | ^ globalBlock value: ref ].
	
	nonGlobalBlock value: variableOrClassName
]

{ #category : #private }
SpCodePresenter >> buildContextKeyBindingsWith: aCategory [
	| category |
	
	category := self newContextMenuKeyBindings.
	aCategory ifNotNil: [ 
		aCategory allEntries keymaps do: [ :each |
			category addKeymapEntry: each ] ].
	
	^ category
]

{ #category : #private }
SpCodePresenter >> buildContextMenuWith: aValuable [
	| menuPresenter |
	
	overrideContextMenu ifTrue: [ ^ aValuable ].

	menuPresenter := self newContextMenu.
	aValuable ifNotNil: [ 
		aValuable value ifNotNil: [ :menu |
			menu menuGroups do: [ :aGroup |
				menuPresenter addMenuGroup: aGroup ] ] ].

	^ menuPresenter
]

{ #category : #api }
SpCodePresenter >> clearInteractionModel [

	self interactionModel: SpCodeNullInteractionModel new
]

{ #category : #'api-shortcuts' }
SpCodePresenter >> contextKeyBindings [

	^ self buildContextKeyBindingsWith: super contextKeyBindings
]

{ #category : #api }
SpCodePresenter >> contextMenu [
	"The code presenter context menu is a compound of two menus: 
		1) the basic interoperation menu (that includes operations like cut&paste but also do it, 
		print it, etc.
		2) the user defined context menu.
    If you want to override completely this menu you need to set the 'overrideMenu' property 
	 to true"

	^ [ self buildContextMenuWith: super contextMenu ]
]

{ #category : #commands }
SpCodePresenter >> doBrowseClass [
	| result |

	result := self 
		evaluate: self selectedTextOrLine
		onCompileError: [ ^ self ]
		onError: [ :e | ^ self ].
	self systemNavigation browse: result
]

{ #category : #commands }
SpCodePresenter >> doBrowseClassReferences [
	| result class |

	result := self 
		evaluate: self selectedTextOrLine
		onCompileError: [ ^ self ]
		onError: [ :e | ^ self ].
		
	(result isClass or: [ result isTrait ])
		ifFalse: [ result := result class ].

	class := result instanceSide.
	class isTrait
		ifTrue: [ self systemNavigation browseAllUsersOfTrait: class ]
		ifFalse: [ self systemNavigation browseAllCallsOnClass: class ]
]

{ #category : #commands }
SpCodePresenter >> doBrowseHierarchy [
	| result |

	result := self 
		evaluate: self selectedTextOrLine
		onCompileError: [ ^ self ]
		onError: [ :e | ^ self ].
	(result isClass or: [ result isTrait ])
		ifFalse: [ result := result class ].
	self systemNavigation browseHierarchy: result
]

{ #category : #commands }
SpCodePresenter >> doBrowseImplementors [
	
	self
		browseSelectedSelectorIfGlobal: [ :global | global browse ]
		ifNotGlobal:  [ :selector |
			self systemNavigation browseAllImplementorsOf: selector ].
]

{ #category : #commands }
SpCodePresenter >> doBrowseMethodReferences [

	self doBrowseSenders
]

{ #category : #commands }
SpCodePresenter >> doBrowseMethodsContainingString [
	
	self systemNavigation 
		browseMethodsWithSourceString: self selectedTextOrLine 
		matchCase: false
]

{ #category : #commands }
SpCodePresenter >> doBrowseSenders [

	self
		browseSelectedSelectorIfGlobal: [ :global | 
			self systemNavigation browseAllSendersOf: global ]
		ifNotGlobal:  [ :selector |
			self systemNavigation browseAllReferencesTo: selector ]
]

{ #category : #'private bindings' }
SpCodePresenter >> doItContext [

	^ self interactionModel ifNotNil: [ :im | im doItContext ]
]

{ #category : #'private bindings' }
SpCodePresenter >> doItContext: anObject [

]

{ #category : #'private bindings' }
SpCodePresenter >> doItReceiver [
	
	^ self interactionModel ifNotNil: [ :im | im doItReceiver ]
]

{ #category : #'private bindings' }
SpCodePresenter >> doItReceiver: anObject [

]

{ #category : #'command support' }
SpCodePresenter >> environment [

	^ environment ifNil: [ self class environment ]
]

{ #category : #'command support' }
SpCodePresenter >> environment: anEnvironment [
	"Set system environment to be used in commands"
	
	environment := anEnvironment
]

{ #category : #'command support' }
SpCodePresenter >> evaluate: aString onCompileError: compileErrorBlock onError: errorBlock [ 
	"evaluate aString. 
	 evaluate compileErrorBlock if there are compilation errors. 
	 evaluate errorBlock is anything happens *during* evaluation (code compiled, but it does not 
	 executes.). 
	 NOTE for future me. This is how I understand the evaluation works and why we need to catch 
	 differently the error: If there is a syntax error (avoiding compilation), it will evaluate 
	 requestor>>#notify:at:in: to notify the error and then it will call failBlock: *which is not 
	 intended to be used to throw an error*, since that should be handled (and it is) in the 
	 notification. Instead, most users of failBlock: use it to return execution without doing 
	 anything. 
	 Instread, the on:do: will catch all errors happening while executing the code once it is 
	 compiled. "
	| receiver |
	
	^ [
		receiver := self interactionModel doItReceiver.
		receiver class compiler
			source: aString readStream;
			context: self interactionModel doItContext;
			receiver: self interactionModel doItReceiver;
			requestor: self interactionModel;
			failBlock:  [ ^ compileErrorBlock value ];
			evaluate ]
	on: Error 
	do: errorBlock
]

{ #category : #accessing }
SpCodePresenter >> findClassFrom: aString [
	| ast |
	
	self flag: #TODO. "Does this really has to be part of the code api?"

	ast := RBParser parseExpression: aString onError: [ ^ nil ].
	ast nodesDo: [ :node | 
		(node isVariable and: [ node name first isUppercase ])
			ifTrue: [ 
				(self class environment classNamed: node name)
					ifNotNil: [ :aClass | ^ aClass ] ] ].

	^ nil
]

{ #category : #accessing }
SpCodePresenter >> findClassFromSelection [
	self flag: #TODO. "Does this really has to be part of the text api?"

	^ self findClassFrom: self selectedTextOrLine trimmed
]

{ #category : #'private bindings' }
SpCodePresenter >> hasBindingOf: aString [

	self interactionModel ifNotNil: [ :im | ^ im hasBindingOf: aString ].
	^ false
]

{ #category : #'private bindings' }
SpCodePresenter >> hasBindingThatBeginsWith: aString [ 
	
	^ self interactionModel
		ifNotNil: [ :im | im hasBindingThatBeginsWith: aString ] 
		ifNil: [ false ]
]

{ #category : #'private testing' }
SpCodePresenter >> hasEditionContextMenu [
	"Answer if edition context menu is active. 
	 Edition context menu is available by default, but it can be disabled by calling `SpTextPresenter>>#withoutEditionContextMenu` or `SpCodePresenter>>#overridingContextMenu`"

	^ super hasEditionContextMenu and: [ overrideContextMenu not ]
]

{ #category : #testing }
SpCodePresenter >> hasLineNumbers [

	^ lineNumbers
]

{ #category : #testing }
SpCodePresenter >> hasResetAction [

	^ resetBlock notNil
]

{ #category : #testing }
SpCodePresenter >> hasSubmitAction [

	^ submitBlock notNil
]

{ #category : #testing }
SpCodePresenter >> hasSyntaxHighlight [

	^ syntaxHighlight
]

{ #category : #initialization }
SpCodePresenter >> initialize [ 

	super initialize.

	"Use the default menu"
	overrideContextMenu := false.
	
	self withSyntaxHighlight.
	self withLineNumbers.
	
	self registerEventsForStyling.
	self clearInteractionModel
]

{ #category : #api }
SpCodePresenter >> insertErrorPopover: aPresenter atIndex: location [

	self selectionInterval: ((location + 1) to: location).
	self insertPopoverAfterCurrentSelection: aPresenter style: 'error'.  
]

{ #category : #api }
SpCodePresenter >> insertPopover: aPresenter atIndex: location [

	self selectionInterval: ((location + 1) to: location).
	self insertPopoverAfterCurrentSelection: aPresenter
]

{ #category : #api }
SpCodePresenter >> insertPopoverAfterCurrentSelection: aPresenter [

	self 
		insertPopoverAfterCurrentSelection: aPresenter
		style: nil
]

{ #category : #api }
SpCodePresenter >> insertPopoverAfterCurrentSelection: aPresenter style: styleName [
	"Popups a popover with contents `aPresenter` after current text selection. 
	 It adds `styleName` to the popover style."

	self withAdapterDo: [ :anAdapter |
		anAdapter insertPopoverAfterCurrentSelection: aPresenter style: styleName ]
]

{ #category : #api }
SpCodePresenter >> insertPrintPopoverAfterCurrentSelection: anObject [
	"Inserts a print-it result popover. 
	 This is for use of SpCodePrintItCommand"

	self 
		insertPopoverAfterCurrentSelection: (SpCodePopoverPrintPresenter 
			newCode: self
			object: anObject)
		style: 'print'
]

{ #category : #api }
SpCodePresenter >> interactionModel [

	^ interactionModel
]

{ #category : #api }
SpCodePresenter >> interactionModel: anInteractionModel [

	anInteractionModel owner: self.
	self basicInteractionModel: anInteractionModel
]

{ #category : #'private bindings' }
SpCodePresenter >> isForScripting [

	^ self interactionModel 
		ifNotNil: [ :im | im isForScripting ]
		ifNil: [ false ]
]

{ #category : #accessing }
SpCodePresenter >> lineNumbers: aBoolean [

	lineNumbers := aBoolean
]

{ #category : #private }
SpCodePresenter >> newContextMenu [
	
	^ self rootCommandsGroup asMenuPresenter
]

{ #category : #private }
SpCodePresenter >> newContextMenuKeyBindings [
	
	^ self rootCommandsGroup asKMCategory
]

{ #category : #private }
SpCodePresenter >> overrideContextMenu: aBoolean [
	"This property set the type of menu to use: if #overrideContextMenu is false (the default), 
	 the contextMenu will include code presenter default entries. If #overrideContextMenu is true, 
	 just what is defined in #contextMenu will be displayed"

	overrideContextMenu := aBoolean
]

{ #category : #api }
SpCodePresenter >> overridingContextMenu [
	"Indicates the context menu should will be overriden. This disabled the default context menu 
	 which includes all operations that can be executed in the context of code.
	 When overriding the code context menu, the only visible operations will be the ones you define 
	 on `SpAbstractTextPresenter>>contextMenu:`"
	
	self overrideContextMenu: true
]

{ #category : #initialization }
SpCodePresenter >> registerEventsForStyling [

	self whenInteractionModelChangedDo: [ :im |
		self withAdapterDo: [ :anAdapter |
			anAdapter interactionModel: im ] ]
]

{ #category : #api }
SpCodePresenter >> selectedBehavior [

	^ self behavior
]

{ #category : #'private bindings' }
SpCodePresenter >> selectedClassOrMetaClass [

	^ self interactionModel ifNotNil: [ :im | im selectedClassOrMetaClass ]
]

{ #category : #'command support' }
SpCodePresenter >> selectedSelector [
	
    ^ CNSelectorExtractor new extractSelectorFromSelection: self selectedTextOrLine
]

{ #category : #api }
SpCodePresenter >> selectedTextOrLine [

	self selectedText ifNotEmpty: [ :aString | ^ aString ].
	
	^ self
		selectLine;
		selectedText
]

{ #category : #private }
SpCodePresenter >> syntaxHighlight: aBoolean [
	syntaxHighlight := aBoolean 
]

{ #category : #'command support' }
SpCodePresenter >> systemNavigation [

	^ super systemNavigation
		environment: self environment;
		yourself
]

{ #category : #'api-events' }
SpCodePresenter >> triggerResetAction [

	resetBlock ifNil: [ ^ self ].
	resetBlock value
]

{ #category : #'api-events' }
SpCodePresenter >> triggerSubmitAction [

	submitBlock ifNil: [ ^ self ].
	submitBlock value: self text
]

{ #category : #api }
SpCodePresenter >> userActionDuring: aBlock [
	"There are a buch of operations that will all trigger a backend update. A tipical case, 
	 changing text and interactionModel will trigger the text-changed event 3 times and that 
	 may cause an excesive compute that we want to avoid. 
	 We use #userActionDuring: to avoid that. 
	[[[language=Smalltalk
	aCodePresenter userActionDuring: [ 
		aCodePresenter
			beForScription;
			text: '42 factorial' ]
	]]]."
	
	self withAdapterDo: [ :anAdapter | 
		anAdapter userActionDuring: aBlock.
		^ self ].
	
	aBlock value
]

{ #category : #'api-events' }
SpCodePresenter >> whenInteractionModelChangedDo: aBlock [
	"Set a block to perform when the behavior class changed"
	
	self 
		property: #interactionModel
		whenChangedDo: aBlock
]

{ #category : #'api-events' }
SpCodePresenter >> whenLineNumbersChangedDo: aBlock [
	"Set a block to perform when the syntax highlight is enabled/disabled"

	self property: #lineNumbers whenChangedDo: aBlock
]

{ #category : #'api-events' }
SpCodePresenter >> whenResetDo: aBlock [

	resetBlock := aBlock.
	super whenResetDo: aBlock
]

{ #category : #'api-events' }
SpCodePresenter >> whenSubmitDo: aBlock [

	submitBlock := aBlock.
	super whenSubmitDo: aBlock
]

{ #category : #'api-events' }
SpCodePresenter >> whenSyntaxHighlightChangedDo: aBlock [
	"Set a block to perform when the syntax highlight is enabled/disabled"

	self property: #syntaxHighlight whenChangedDo: aBlock
]

{ #category : #api }
SpCodePresenter >> withLineNumbers [

	self lineNumbers: true
]

{ #category : #api }
SpCodePresenter >> withSyntaxHighlight [

	self syntaxHighlight: true
]

{ #category : #api }
SpCodePresenter >> withoutLineNumbers [

	self lineNumbers: false
]

{ #category : #api }
SpCodePresenter >> withoutSyntaxHighlight [

	self syntaxHighlight: false
]
