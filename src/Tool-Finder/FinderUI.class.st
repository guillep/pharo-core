"
A FinderUI is a UI used to render a Finder instance.

This tool is used to look for selectors, class, source code or patterns through the system, or through a specified environment
"
Class {
	#name : #FinderUI,
	#superclass : #MorphTreeModel,
	#instVars : [
		'finder',
		'forceSearch',
		'searchingTextArea',
		'sourceTextArea',
		'useRegExCheckbox',
		'searchedTextList',
		'sourceTextModel'
	],
	#classInstVars : [
		'searchedTextListMaxSize'
	],
	#category : #'Tool-Finder-UI'
}

{ #category : #'event subscriptions' }
FinderUI class >> doAllSubscriptionsOn: aFinder to: anInstance [
	self subscribesUpdateSourceCodeOn: aFinder to: anInstance.
	self subscribesResetEnvironmentOn: aFinder to: anInstance.
	self subscribesEnableUseRegExOn: aFinder to: anInstance.
	self subscribesDisableUseRegExOn: aFinder to: anInstance.
	self subscribesUpdateSelectedMethodOn: aFinder to: anInstance.
	self subscribesUpdateSelectedClassOn: aFinder to: anInstance.
	self subscribesUpdateListOn: aFinder to: anInstance
]

{ #category : #icons }
FinderUI class >> icon [
	^ self iconNamed: #smallFindIcon
]

{ #category : #'class initialization' }
FinderUI class >> initialize [
	searchedTextListMaxSize := 15
]

{ #category : #explanations }
FinderUI class >> methodFinderExplanation [
	"The comment in the bottom pane"

	MethodFinder new findMethodsByExampleInput: #( 1 2 ) andExpectedResult: 3.
		"to keep the method methodFor: from being removed from the system"

	^ 'Use an example to find a method in the system.  
	
   ''a''. ''b''. ''ab''       will find the message #, for strings concatenation
   2. -2                will find the message #negated
   3. 6                 will find the message #factorial
   20. 10. 15. 15       will find the message #min:max:

It works on collections too:

   {2. 4. 5. 1}. 5. 3   will find the message #indexOf:
   {2. 5. 1}. 5. true   will find the message #includes:
	
An example is made up of the following two or more items separated by a period: 
	
	receiver. answer
	receiver. argument1. answer
	receiver. argument1. argument2. answer
	etc...
	
For example, type: 3. 4. 7. into the search box and click <Search>

Take care on separating spaces because of floating point numbers.

 	3.4.7      will find nothing, it is interpreted two numbers, 3.4 and. 7
	3. 4. 7    will find you the message #+
	
The examples array should contain one object for the receiver, one object per expected argument and then a final object with the expected result.	

In other words 
 - a unary method example expects an array of input objects #( receiver ) and an expected result
 - a binary method example expects an array with two input objects #( receiver argument ) and an expected result
 - a keyword method example expects an array with at least two elements  #( receiver argument1 argument2 ... ) and an expected results

The method finder will take the input objects (receiver and arguments) and perform their permutation to be able to find more results.
Then, it will lookup in the receiver''s hierarchy the approved and forbidden methods to run on the hierarchy and run them on the permutation of objects.

Receiver and arguments do not have to be in the right order.

Alternatively, in this bottom pane or in the Playground, use #findMethodsByExampleInput:andExpectedResult: directly to find a method in the system.  Select this line of code and choose "print it" or "inspect it.  

	MethodFinder new findMethodsByExampleInput: #( 1 2 ) andExpectedResult: 3.

It is useful when you want to look for computed objects:
	
	MethodFinder new 
		findMethodsByExampleInput: {''29 Apr 1999'' asDate} 
		andExpectedResult: ''30 Apr 1999'' asDate.

This will find the message #next.

	MethodFinder new 
		findMethodsByExampleInput: {''30 Apr 1999'' asDate} 
		andExpectedResult: ''Friday''. 

This will find the message #dayOfWeekName

The Method Finder is not trying all methods in the system so if it will find nothing, a method with requested behavior may still exist. '.

		

]

{ #category : #'instance creation' }
FinderUI class >> on: aFinder [

	| instance |
	instance := self new finder: aFinder.
	self doAllSubscriptionsOn: aFinder to: instance.
	^instance
]

{ #category : #accessing }
FinderUI class >> searchedTextListMaxSize: anInteger [

	self allInstancesDo: [:each | each searchedTextListMaxSize: anInteger].
	searchedTextListMaxSize := anInteger
]

{ #category : #'event subscriptions' }
FinderUI class >> subscribesDisableUseRegExOn: aFinder to: anInstance [

	aFinder
		when: #disableUseRegEx
		send: #disableUseRegEx
		to: anInstance
]

{ #category : #'event subscriptions' }
FinderUI class >> subscribesEnableUseRegExOn: aFinder to: anInstance [

	aFinder
		when: #enableUseRegEx
		send: #enableUseRegEx
		to: anInstance
]

{ #category : #'event subscriptions' }
FinderUI class >> subscribesResetEnvironmentOn: aFinder to: anInstance [

	aFinder
		when: #resetEnvironment
		send: #resetEnvironment
		to: anInstance
]

{ #category : #'event subscriptions' }
FinderUI class >> subscribesUpdateListOn: aFinder to: anInstance [

	aFinder
		when: #updateResultDictionary
		send: #updateList
		to: anInstance
]

{ #category : #'event subscriptions' }
FinderUI class >> subscribesUpdateSelectedClassOn: aFinder to: anInstance [

	aFinder
		when: #updateSelectedClass
		send: #updateSelectedClass
		to: anInstance
]

{ #category : #'event subscriptions' }
FinderUI class >> subscribesUpdateSelectedMethodOn: aFinder to: anInstance [

	aFinder
		when: #updateSelectedMethod
		send: #updateSelectedMethod
		to: anInstance
]

{ #category : #'event subscriptions' }
FinderUI class >> subscribesUpdateSourceCodeOn: aFinder to: anInstance [

	aFinder
		when: #updateSourceCode
		send: #updateSourceCode
		to: anInstance
]

{ #category : #icons }
FinderUI class >> taskbarIconName [
	^#smallFindIcon
]

{ #category : #'items creation' }
FinderUI >> addAllItems: aWindow [
	| toolbar height btnFont btnToolbar cst |
	toolbar := self buildSearchModeToolBar: aWindow.
	height := toolbar minExtent y.
	cst := 15.
	aWindow
		addMorph: toolbar
		fullFrame:
			(LayoutFrame identity
				bottomFraction: 0;
				bottomOffset: height).
	aWindow
		addMorph: self buildPackagesTree buildContents
		fullFrame:
			(LayoutFrame identity
				bottomFraction: 0.58;
				topOffset: height).
	btnFont := StandardFonts buttonFont.
	btnToolbar := self buildBrowseToolBar: aWindow.
	aWindow
		addMorph: btnToolbar
		fullFrame:
			(LayoutFrame identity
				topFraction: 0.58;
				bottomFraction: 0.58;
				bottomOffset: btnFont height + cst).
	aWindow
		addMorph: self sourceTextArea
		fullFrame:
			(LayoutFrame identity
				topFraction: 0.58;
				topOffset: btnFont height + cst)
]

{ #category : #accessing }
FinderUI >> addToSearchedTextList: aString [ 
	self searchedTextList: (self searchedTextList
			remove: aString
			ifAbsent: [];
			 yourself).
	self searchedTextList size = self searchedTextListMaxSize
		ifTrue: [self searchedTextList removeLast].
	self searchedTextList addFirst: aString 
]

{ #category : #'buttons behavior' }
FinderUI >> allClassesButtonAction [

	self finder packagesSelection: self environment
]

{ #category : #'buttons behavior' }
FinderUI >> allClassesButtonLabel [
	^ 'All Packages'
]

{ #category : #'buttons behavior' }
FinderUI >> allClassesButtonState [
	^ false
]

{ #category : #'buttons behavior' }
FinderUI >> browseButtonAction [

	self selectedNode browse
]

{ #category : #'buttons behavior' }
FinderUI >> browseButtonLabel [
	^'Browse'
]

{ #category : #'buttons behavior' }
FinderUI >> browseButtonState [
	^self selectedClass isNil or: [ self selectedMethod isNil ]
]

{ #category : #accessing }
FinderUI >> browsedEnvironment [
	^ self environment 
]

{ #category : #'items creation' }
FinderUI >> buildAllClassesButton [
	^ PluggableButtonMorph 
			on: self 
			getState: #allClassesButtonState 
			action: #allClassesButtonAction 
			label: #allClassesButtonLabel
]

{ #category : #'items creation' }
FinderUI >> buildBrowseButton [
	^ (PluggableButtonMorph 
			on: self 
			getState: #browseButtonState 
			action: #browseButtonAction 
			label: #browseButtonLabel)
			hResizing: #spaceFill
]

{ #category : #'items creation' }
FinderUI >> buildBrowseToolBar: aWindow [
	| toolbar |
	toolbar := aWindow newToolbar: {
		self buildBrowseButton.
		self buildSendersButton.
		self buildImplementorsButton.
		self buildVersionsButton.
		self buildInheritanceButton.
		self buildHierarchyButton}.
	^toolbar hResizing: #shrinkWrap
]

{ #category : #'text areas behavior' }
FinderUI >> buildDescriptionOf: aClass [

	^ String streamContents: [ :stream | 
		  stream nextPutAll: aClass definitionString.
		  aClass hasComment ifTrue: [ 
			  stream
				  cr;
				  cr;
				  cr;
				  nextPutAll: aClass comment ] ]
]

{ #category : #'items creation' }
FinderUI >> buildEnvironmentButton [
	^ (PluggableButtonMorph 
			on: self 
			getState: #environmentButtonState 
			action: #environmentButtonAction 
			label: #environmentButtonLabel)
			beSticky
]

{ #category : #'items creation' }
FinderUI >> buildHierarchyButton [
	^ (PluggableButtonMorph 
			on: self 
			getState: #hierarchyButtonState 
			action: #hierarchyButtonAction 
			label: #hierarchyButtonLabel)
			hResizing: #spaceFill
]

{ #category : #'items creation' }
FinderUI >> buildImplementorsButton [
	^ (PluggableButtonMorph 
			on: self 
			getState: #implementorsButtonState 
			action: #implementorsButtonAction 
			label: #implementorsButtonLabel)
			hResizing: #spaceFill
]

{ #category : #'items creation' }
FinderUI >> buildInheritanceButton [
	^ (PluggableButtonMorph 
			on: self 
			getState: #inheritanceButtonState 
			action: #inheritanceButtonAction 
			label: #inheritanceButtonLabel)
			hResizing: #spaceFill
]

{ #category : #'items creation' }
FinderUI >> buildPackagesTree [
	^ self defaultTreeMorph
]

{ #category : #'items creation' }
FinderUI >> buildRegExChooser [
	| string btnHeight btnWidth |
	string := 'Regexp'.
	btnHeight := StandardFonts buttonFont height + 8.
	btnWidth := 0.
	string do: [:c | btnWidth := btnWidth + (StandardFonts buttonFont widthOf: c)].
	^useRegExCheckbox := (CheckboxMorph 
									on: self finder
									selected: #useRegEx
									changeSelected: #useRegEx:)
									beCheckbox;
									vResizing: #rigid;
									height: btnHeight;
									width: btnWidth + 30;
									label: string
]

{ #category : #'items creation' }
FinderUI >> buildSearchButton [
	^ (PluggableButtonMorph 
			on: self 
			getState: #searchButtonState 
			action: #searchButtonAction 
			label: #searchButtonLabel)
			hResizing: #shrinkWrap
]

{ #category : #'items creation' }
FinderUI >> buildSearchModeDropListIn: aWindow [
	
	^ (self theme 
		newDropListIn: aWindow
		for:self				
		list: #searchModesList
		getSelected: #currentSearchMode
		setSelected: #currentSearchMode:
		getEnabled: nil
		useIndex: false 
		help: self searchModeHelpText) hResizing: #rigid; width: 120; yourself

]

{ #category : #'items creation' }
FinderUI >> buildSearchModeToolBar: aWindow [
	^aWindow newToolbar: {
		self buildSearchingTextArea.
		self buildSearchButton.
		self buildRegExChooser.
		self buildSearchModeDropListIn: aWindow.
		self buildEnvironmentButton.
		self buildAllClassesButton}
]

{ #category : #'items creation' }
FinderUI >> buildSearchingTextArea [
	^ searchingTextArea := 
		(EditableDropListMorph
				on: self
				list: #searchedTextList
				selected: #searchingString
				changeSelected: #searchingAccept:
				useIndex: false 
				addToList: #addToSearchedTextList:
				class: String
				getEnabled: nil) hResizing: #spaceFill; 
				ghostText: 'Hit return to accept' translated

	
]

{ #category : #'items creation' }
FinderUI >> buildSendersButton [
	^ (PluggableButtonMorph 
			on: self 
			getState: #sendersButtonState 
			action: #sendersButtonAction 
			label: #sendersButtonLabel)
			hResizing: #spaceFill
]

{ #category : #'items creation' }
FinderUI >> buildSourceTextArea [
	sourceTextArea := self sourceTextModel newScrolledText
		beForSmalltalkCode;
		beWrapped;
		yourself.
	sourceTextArea textArea announcer when: RubTextAcceptRequest send: #whenTextAcceptedInView: to: self.
	self updateSourceCode.
	^ sourceTextArea
]

{ #category : #'items creation' }
FinderUI >> buildVersionsButton [
	^ (PluggableButtonMorph 
			on: self 
			getState: #versionsButtonState 
			action: #versionsButtonAction 
			label: #versionsButtonLabel)
			hResizing: #spaceFill
]

{ #category : #'text areas behavior' }
FinderUI >> collectFromPackages: aCollection [
	self packagesSelection: (self environment forPackageNames: aCollection)
]

{ #category : #'text areas behavior' }
FinderUI >> compileSource: aString notifying: aController [

	| class method |
	(self selectedClass isNil or: [ self selectedMethod isNil ])
		ifTrue:[
			self changed: #clearUserEdits.
			^self].
	class := self selectedClass.
	method := class compiledMethodAt: self selectedMethod.
	(class compile: (aString asString) classified: method category notifying: aController)
			ifNil: [^ self ]
			ifNotNil: [:selector |
				self changed: #clearUserEdits ]
]

{ #category : #private }
FinderUI >> constructPackagesSet [
	| result |
	result := (self environment packages collect: [:each | each name])
		difference: (self packagesSelection packages collect: [:each | each name]).
	^ result asSet asSortedCollection: [ :a :b | a < b ]
]

{ #category : #private }
FinderUI >> constructPackagesSet: aPackageEnvironment [
	| result |
	result := aPackageEnvironment packages collect: [ :c | c name ].
	^ (result reject: [ :each | each isNil ]) asSet asSortedCollection: [ :a :b | a < b ]
]

{ #category : #accessing }
FinderUI >> currentSearchMode [
	^self finder currentSearchMode
]

{ #category : #accessing }
FinderUI >> currentSearchMode: aSymbol [
	self finder searchingStringSilently: self searchingTextArea contentMorph textMorph text asString.
	self searchingTextArea contentMorph hasUnacceptedEdits: false.
	self finder currentSearchMode: aSymbol
]

{ #category : #private }
FinderUI >> defaultExplanation [
^
'The Finder can be used in 4 different ways:
	- Selectors: your research is done among selectors
	- Classes : your research is done among classes names
	- Source : your research is done among all the source code
	- Pragmas: your research is done among pragmas
	- Examples : your research uses the Method Finder behavior 
			   (for further informations, print ''FinderUI methodFinderExplanation'')
	
			
In these four modes, you can also tick the ''Use RegEx'' checkbox.
If you pick this box, your search will be done using regular expressions instead of just matching.

The ''Select classes'' button opened a dialog window  to select which classes will be used for the search.
The ''All classes'' button is used to reset the classes selection.'
]

{ #category : #'items creation' }
FinderUI >> defaultTreeMorph [
	|  col |
	col := MorphTreeColumn new
		rowMorphGetSelector: [:node | node displayString asMorph ].
	
	self headerLabel
		ifNotNil: [	col headerButtonLabel: self headerLabel font: nil].
			
	^ (self treeMorphClass on: self) 
			columns:  (Array with: col);
			hResizing: #spaceFill;
			vResizing: #spaceFill;
			resizerWidth: 0;
			columnInset: 0;
			rowInset: 2; 
			keyDownActionSelector: #keyDown:;
			multiSelection: self multiSelection;
			autoMultiSelection: self autoMultiSelection;
			isCheckList: self isCheckList;
			doubleClickSelector: #doubleClick;
			getMenuSelector: #menu:shifted:
]

{ #category : #display }
FinderUI >> defaultWindowLabel [
	^ 'Finder'
]

{ #category : #checkbox }
FinderUI >> disableUseRegEx [
	useRegExCheckbox isSelected
		ifTrue: [ useRegExCheckbox toggleSelected ].
	useRegExCheckbox enabled: false
]

{ #category : #'do it requirements' }
FinderUI >> doItContext [

	^ nil
]

{ #category : #'do it requirements' }
FinderUI >> doItReceiver [

	^ self selectedClass ifNotNil: [ :selectedClass | selectedClass instanceSide ]
]

{ #category : #'events handling' }
FinderUI >> doubleClick [
	self selectedNode doubleClick
]

{ #category : #checkbox }
FinderUI >> enableUseRegEx [
	useRegExCheckbox 
		enabled: true;
		updateEnabled
]

{ #category : #accessing }
FinderUI >> environment [
	^ self finder environment
]

{ #category : #'buttons behavior' }
FinderUI >> environmentButtonAction [
	self openPackageChooser
]

{ #category : #'buttons behavior' }
FinderUI >> environmentButtonLabel [
	^ 'Packages...'
]

{ #category : #'buttons behavior' }
FinderUI >> environmentButtonState [
	^ false
]

{ #category : #accessing }
FinderUI >> finder [
	^finder
]

{ #category : #accessing }
FinderUI >> finder: aFinder [
	finder := aFinder
]

{ #category : #searching }
FinderUI >> forSelectorsDo: selectorBlock forClassNamesDo: classNamesBlock forSourceDo: sourceBlock forExamplesDo: exampleBlock forPragmasDo: pragmaBlock [

	self isSelectorsSymbol
		ifTrue: [^selectorBlock value].
	self isClassNamesSymbol
		ifTrue: [^classNamesBlock value].
	self isSourceSymbol
		ifTrue: [^sourceBlock value].
	self isExamplesSymbol
		ifTrue: [^exampleBlock value].
	self isPragmasSymbol
		ifTrue: [^pragmaBlock value]
]

{ #category : #accessing }
FinderUI >> forceSearch [
	^ forceSearch ifNil: [ forceSearch := false ]
]

{ #category : #private }
FinderUI >> hierarchy [
	self selectedClass
		ifNotNil: [ :class | 
			self selectedMethod
				ifNil: [ SystemNavigation new browseHierarchy: class ]
				ifNotNil: [ :selector | SystemNavigation new browseHierarchy: class selector: selector ] ]
]

{ #category : #'buttons behavior' }
FinderUI >> hierarchyButtonAction [
	self hierarchy
]

{ #category : #'buttons behavior' }
FinderUI >> hierarchyButtonLabel [
	^ 'Hierarchy'
]

{ #category : #'buttons behavior' }
FinderUI >> hierarchyButtonState [
	^ self selectedClass isNil
]

{ #category : #private }
FinderUI >> implementors [
	self selectedMethod ifNil: [ ^ self ].
	SystemNavigation new browseAllImplementorsOf: self selectedMethod
]

{ #category : #'buttons behavior' }
FinderUI >> implementorsButtonAction [
	self implementors
]

{ #category : #'buttons behavior' }
FinderUI >> implementorsButtonLabel [
	^'Implementors'
]

{ #category : #'buttons behavior' }
FinderUI >> implementorsButtonState [
	^ self selectedMethod isNil | self isClassNamesSymbol
]

{ #category : #private }
FinderUI >> inheritance [
	self selectedClass
		ifNotNil: [ :class | 
			self selectedMethod
				ifNotNil: [ :selector | SystemNavigation new methodHierarchyBrowserForClass: class selector: selector ] ]
]

{ #category : #'buttons behavior' }
FinderUI >> inheritanceButtonAction [
	self inheritance
]

{ #category : #'buttons behavior' }
FinderUI >> inheritanceButtonLabel [
	^ 'Inheritance'
]

{ #category : #'buttons behavior' }
FinderUI >> inheritanceButtonState [
	^ self selectedClass isNil | self isClassNamesSymbol
]

{ #category : #display }
FinderUI >> initialExtent [
	^ 700@500
]

{ #category : #initialization }
FinderUI >> initialize [
	super initialize.
	wrapBlockOrSelector := [ :i | i asString ]
]

{ #category : #'mode list' }
FinderUI >> isClassNamesSymbol [

	^self finder isClassNamesSymbol
]

{ #category : #'mode list' }
FinderUI >> isExamplesSymbol [
	^self finder isExamplesSymbol
]

{ #category : #'mode list' }
FinderUI >> isPragmasSymbol [
	^self finder isPragmasSymbol
]

{ #category : #'mode list' }
FinderUI >> isSelectorsSymbol [
	^self finder isSelectorsSymbol
]

{ #category : #'mode list' }
FinderUI >> isSourceSymbol [
	^self finder isSourceSymbol
]

{ #category : #private }
FinderUI >> keyDown: event [
	self selectedNode ifNotNil: [:node | node keyDown: event]
]

{ #category : #private }
FinderUI >> labelFont [
	^StandardFonts defaultFont
]

{ #category : #'t - accessing' }
FinderUI >> menu: menu shifted: b [ 
	self selectedNode ifNil: [ ^menu ].
	^ self selectedNode menu: menu shifted: b 
]

{ #category : #display }
FinderUI >> open [
	 
	| window |
	window := StandardWindow new model: self.
	self addAllItems: window.
	window setLabel: self defaultWindowLabel.
	window openInWorld.
	self searchingTextArea contentMorph takeKeyboardFocus
]

{ #category : #private }
FinderUI >> openPackageChooser [
	(DialogItemsChooser
		on: self
		unselectedItems: self constructPackagesSet
		selectedItems: (self constructPackagesSet: self packagesSelection)
		selectedItemsSetterSelector: #collectFromPackages: 
		title: 'Package Chooser'
		unselectedItemsLabel: 'Unselected Packages' translated
		selectedItemsLabel: 'Selected Packages' translated) open
]

{ #category : #private }
FinderUI >> packagesSelection [
	^self finder packagesSelection
]

{ #category : #private }
FinderUI >> packagesSelection: aCollection [

	self finder packagesSelection: aCollection
]

{ #category : #private }
FinderUI >> resetEnvironment [
	self triggerEvent: #resetEnvironment
]

{ #category : #'tree behavior' }
FinderUI >> resultDictionary [ 
	^self finder resultDictionary 
]

{ #category : #accessing }
FinderUI >> rootItems [
	^ self resultDictionary keys sort: [ :a :b | a asString < b asString ]
]

{ #category : #'t - accessing' }
FinderUI >> rootNodeClassFromItem: anItem [
	"To have the good class for my nodes, I ask my owner,
	because he is the only one who knows his state"

	^ self
		forSelectorsDo: [ (self resultDictionary at: anItem) size > 1
				ifTrue: [ FinderMethodNode ]
				ifFalse: [ FinderSingleMethodNode ] ]
		forClassNamesDo: [ FinderClassNode ]
		forSourceDo: [ FinderMethodNode ]
		forExamplesDo: [ FinderExampleMethodNode ]
		forPragmasDo: [ FinderPragmaNode ]
]

{ #category : #'buttons behavior' }
FinderUI >> searchButtonAction [
	forceSearch := true.
	self searchingTextArea contentMorph acceptTextInModel
]

{ #category : #'buttons behavior' }
FinderUI >> searchButtonLabel [
	^ 'Search'
]

{ #category : #'buttons behavior' }
FinderUI >> searchButtonState [
	^ false
]

{ #category : #private }
FinderUI >> searchModeHelpText [
	^'Choose the mode for the search'
]

{ #category : #'mode list' }
FinderUI >> searchModesList [
	^#(Selectors Classes Source Pragmas Examples)
]

{ #category : #accessing }
FinderUI >> searchedTextList [
	^ searchedTextList ifNil: [ searchedTextList := OrderedCollection new ]
]

{ #category : #accessing }
FinderUI >> searchedTextList: aCollection [

	searchedTextList := aCollection
]

{ #category : #accessing }
FinderUI >> searchedTextListMaxSize [
	^20
]

{ #category : #accessing }
FinderUI >> searchedTextListMaxSize: anInteger [
	[ self searchedTextList size > anInteger ] whileTrue: [ self searchedTextList removeLast ].
	self changed: #searchedTextList
]

{ #category : #'text areas behavior' }
FinderUI >> searchingAccept: aText [
	self forceSearch
		ifFalse: [ aText asString = self searchingString
				ifTrue: [ ^ self ] ].
	self searchingString: aText asString.
	forceSearch := false
]

{ #category : #accessing }
FinderUI >> searchingString [
	^self finder searchingString
]

{ #category : #accessing }
FinderUI >> searchingString: aString [

	^self finder searchingString: aString
]

{ #category : #accessing }
FinderUI >> searchingTextArea [
	^ searchingTextArea ifNil: [ self buildSearchingTextArea ]
]

{ #category : #accessing }
FinderUI >> selectedClass [
	^ self finder selectedClass
]

{ #category : #accessing }
FinderUI >> selectedClassOrMetaClass [

	^ self selectedClass
]

{ #category : #accessing }
FinderUI >> selectedMethod [
	^ self finder selectedMethod
]

{ #category : #accessing }
FinderUI >> selection: aSelection [
	
	super selection: aSelection.
	self finder selection: aSelection
]

{ #category : #private }
FinderUI >> senders [
	self selectedMethod
		ifNotNil: [ :selector | 
			SystemNavigation new
				browseSendersOf: selector
				name: 'Senders of ' , selector asString
				autoSelect: selector asString ]
]

{ #category : #'buttons behavior' }
FinderUI >> sendersButtonAction [
	self senders
]

{ #category : #'buttons behavior' }
FinderUI >> sendersButtonLabel [
	^ 'Senders'
]

{ #category : #'buttons behavior' }
FinderUI >> sendersButtonState [
	^ self selectedMethod isNil | self isClassNamesSymbol
]

{ #category : #'text areas behavior' }
FinderUI >> shoutAboutToStyle: aPluggableShoutMorphOrView [

	aPluggableShoutMorphOrView classOrMetaClass: self selectedClass.
	self selectedClass ifNil: [^ false].
	self selectedMethod ifNil: [^ false].
	^ true
]

{ #category : #'text areas behavior' }
FinderUI >> sourceCode [

	^ self selectedClass 
		ifNil: [
			self isExamplesSymbol
				ifTrue: [ self class methodFinderExplanation ]
				ifFalse: [ self defaultExplanation]]
		ifNotNil:[
			self selectedMethod 
				ifNil: [
					self buildDescriptionOf: self selectedClass]
				ifNotNil:[
					| selector |
					selector := self isExamplesSymbol
								ifTrue: [self selectedMethod selector]
								ifFalse: [self selectedMethod].
					(self selectedClass >> selector) sourceCode]]
]

{ #category : #accessing }
FinderUI >> sourceTextArea [
	^ sourceTextArea ifNil: [ self buildSourceTextArea ]
]

{ #category : #accessing }
FinderUI >> sourceTextModel [
	^ sourceTextModel ifNil: [ sourceTextModel := RubScrolledTextModel new interactionModel: self ]
]

{ #category : #private }
FinderUI >> updateSelectedClass [
	self changed: #selectedClass
]

{ #category : #private }
FinderUI >> updateSelectedMethod [
	self changed: #selectedMethod
]

{ #category : #'text areas behavior' }
FinderUI >> updateSourceCode [
	self sourceTextModel setText: self sourceCode 
]

{ #category : #private }
FinderUI >> useRegEx [
	^ self finder useRegEx
]

{ #category : #'buttons behavior' }
FinderUI >> versionsButtonAction [
	Smalltalk tools versionBrowser 
		browseVersionsForClass: self selectedClass 
		selector: self selectedMethod
]

{ #category : #'buttons behavior' }
FinderUI >> versionsButtonLabel [
	^'Versions'
]

{ #category : #'buttons behavior' }
FinderUI >> versionsButtonState [
	^self selectedClass isNil | self isClassNamesSymbol.
]

{ #category : #'events handling' }
FinderUI >> whenTextAcceptedInView: anAnnouncement [
	self compileSource: sourceTextArea text notifying: sourceTextArea
]
