"
This class provides examples on how different widgets can be made.
See the methods starting with ""example"" in my class side.

Examples for different widgets:

WidgetExamples exampleBasicControls.
WidgetExamples exampleOtherControls.
WidgetExamples exampleColorControls.
WidgetExamples exampleDialogs.
WidgetExamples exampleGroups.
WidgetExamples exampleTextEntryWithCompletionDialog.
WidgetExamples exampleWindowWithToolbars.
"
Class {
	#name : #WidgetExample,
	#superclass : #Model,
	#category : #'Morphic-Examples-Widgets'
}

{ #category : #'private - accessing' }
WidgetExample class >> builder [
	"Answer a morph that implements TEasilyThemed but without honouring modality
	for the example dialogs."
	"self exampleBuilder"
	<sampleInstance>
	^ExampleBuilderMorph new
]

{ #category : #'examples - cleanup' }
WidgetExample class >> closeExampleDialogs [
	"Close the example dialogs."
	"self closeExampleDialogs"
	<script>
	DialogWindowMorph allSubInstances do: [:d | d cancel]
]

{ #category : #examples }
WidgetExample class >> colorControls [
	"Open a window with examples of each of the color controls."
	"self exampleColorControls"
	<script>
	|dialog builder|
	builder := self builder.
	dialog := (builder newPluggableDialogWindow: 'Example color controls') useDefaultOKButton.
	dialog contentMorph: (dialog newRow: {
		dialog newLabelGroup: {
			'Alpha Selector'->(dialog newAlphaSelector: (NewValueHolder new value: 0)
							getAlpha: #value setAlpha: #value: help: 'This is an alpha channel selector').
			'Hue Selector'->(dialog newHueSelector: (NewValueHolder new value: 0)
							getHue: #value setHue: #value: help: 'This is a hue selector').
			'SV Color Selector'->((dialog newSVSelector: Color yellow
									help: 'This is a saturation-volume selector') minHeight: 80).
			'HSV Color Selector'->((dialog newHSVSelector: Color green
									help: 'This is a hue-saturation-volume selector') minHeight: 80; minWidth: 120)}.
		dialog newVerticalSeparator.
		dialog newTitle: 'HSVA Color Selector' for:
			((dialog newHSVASelector: Color cyan
					help: 'This is a hue-saturation-volume-alpha selector')
					minHeight: 184; minWidth: 184)});
		model: nil.
	dialog openModal
]

{ #category : #examples }
WidgetExample class >> exampleBasicControls [
	"Open a window with examples of each of the basic controls."
	"self exampleBasicControls"
	<script>
	|dialog builder radioModel treeModel|
	builder := self builder.
	dialog := (builder newPluggableDialogWindow: 'Example basic controls') useDefaultOKButton.
	radioModel := ExampleRadioButtonModel new.
	treeModel := Array with:(MorphWithSubmorphsWrapper with: self currentWorld).
	dialog contentMorph: ((dialog newRow: {
		dialog newLabelGroup: {
			'Normal Label'->(dialog newLabel: 'A Label').
			'Disabled Label'->(dialog newLabel: 'A Disabled Label') disable.
			'Normal Button'->(dialog newButtonFor: nil action: nil label: 'A Button' help: 'This is a button').
			'Default Button'->((dialog newButtonFor: nil action: nil label: 'Default Button' help: 'This is a default button') isDefault: true).
			'Disabled Button'->(dialog newButtonFor: nil action: nil label: 'Disabled Button'
							help: 'This is a disabled button') disable.
			'Selected Button'->(dialog newButtonFor: (NewValueHolder new value: true) getState: #value
							action: nil arguments: #() getEnabled: nil label: 'A Button' help: 'This is a selected button').
			'Selected Disabled Button'->(dialog newButtonFor: (NewValueHolder new value: true) getState: #value
							action: nil arguments: #() getEnabled: nil label: 'Disabled Button'
							help: 'This is a selected disabled button') disable.
			'Checkbox'->(dialog newCheckboxFor: (NewValueHolder new value: true)
							getSelected: #value setSelected: #value: label: 'A Checkbox' help: 'This is a checkbox').
			'Disabled Checkbox'->(dialog newCheckboxFor: (NewValueHolder new value: true)
							getSelected: #value setSelected: #value:
							label: 'A Disabled Checkbox' help: 'This is a disabled checkbox') disable.
			'Radio Buttons'->((dialog newColumn: {
								(dialog newRadioButtonFor: radioModel
									getSelected: #isLeft setSelected: #beLeft label: 'Left' help: 'This is a radio buton').
								(dialog newRadioButtonFor: radioModel
									getSelected: #isCenter setSelected: #beCenter label: 'Center' help: 'This is a radio buton').
								(dialog newRadioButtonFor: radioModel
									getSelected: #isRight setSelected: #beRight label: 'Right' help: 'This is a radio buton')})
								vResizing: #shrinkWrap).
			'Disabled Radio Button'->(dialog newRadioButtonFor: radioModel
									getSelected: #isRight setSelected: #beRight label: 'Right'
									help: 'This is a disabled radio buton') disable.
			'Text Entry'->(dialog newTextEntryFor: (NewValueHolder new value: 'Hello')
							getText: #value setText: #value: help: 'This is a text entry').
			'Disabled Text Entry'->(dialog newTextEntryFor: (NewValueHolder new value: 'Hello')
							getText: #value setText: #value: help: 'This is a disabled text entry') disable.
			'Slider'->(dialog newSliderFor: (NewValueHolder new value: 0.5)
							getValue: #value setValue: #value: help: 'This is a slider').
			'Disabled Slider'->(dialog newSliderFor: (NewValueHolder new value: 0.75)
							getValue: #value setValue: #value: help: 'This is a disabled slider') disable}.
			dialog newVerticalSeparator.
			dialog newLabelGroup: {
			'Drop List'->(dialog newDropListFor: (ListPresenter new items: #('One' 'Two' 'Three' 'Four'))
							list: #getList getSelected: #selectedIndex setSelected: #setSelectedIndex: help: 'This is a drop list').
			'Disabled Drop List'->(dialog newDropListFor: (ListPresenter new items: #('One' 'Two' 'Three' 'Four'); setSelectedIndex: 3)
							list: #getList getSelected: #selectedIndex setSelected: #setSelectedIndex:
							help: 'This is a disabled drop list') disable.
			'Editable Drop List'->(dialog newEditableDropListFor: (ListPresenter new items: SortedCollection new)
							list: #getList getSelected: #selectedIndex setSelected: #setSelectedIndex:
							addToList: #add: ghostText: 'Enter new items' getEnabled: nil help: 'This is an editable drop list').
			'Morph Drop List'->(dialog newMorphDropListFor: (ListPresenter new items: ((Color red wheel: 20)
									collect: [:c | Morph new extent: 120@12; color: c]))
							list: #getList getSelected: #selectedIndex setSelected: #setSelectedIndex:
							help: 'This is a morph drop list').
			'Normal List'->((dialog newListFor: (ListPresenter new items: #('One' 'Two' 'Three' 'Four'); setSelectedIndex: 3)
							list: #getList selected: #selectedIndex changeSelected: #setSelectedIndex:
							help: 'This is a list') minWidth: 120).
			'Disabled List'->(dialog newListFor: (ListPresenter new items: #('One' 'Two' 'Three' 'Four'); setSelectedIndex: 3)
							list: #getList selected: #selectedIndex changeSelected: #setSelectedIndex:
							help: 'This is a disabled list') disable.
			'Morph List'->(dialog newMorphListFor: (ListPresenter new items: ((Color red wheel: 20)
									collect: [:c | Morph new extent: 80@12; color: c]))
							list: #getList getSelected: #selectedIndex setSelected: #setSelectedIndex:
							help: 'This is a morph list').
			'Tree'->((dialog newTreeFor: treeModel list: #value selected: nil changeSelected: nil) minHeight: 100)}.
			dialog newVerticalSeparator.
			dialog newColumn: {
				dialog newTitle: 'Text Editor' for: (
					(dialog newTextEditorFor: (NewValueHolder new value: 'Hello')
						getText: #value setText: #value:) minWidth: 100).
				dialog newTitle: 'Disabled Text Editor' for: (
					(dialog newTextEditorFor: (NewValueHolder new value: 'Hello')
						getText: #value setText: #value:) disable)}})
			vResizing: #spaceFill);
		model: nil.
	dialog openModal
]

{ #category : #examples }
WidgetExample class >> exampleColorControls [
	"Open a window with examples of each of the color controls."
	"self exampleColorControls"
	<script>
	| dialog builder|
	builder := self builder.
	dialog := (builder newPluggableDialogWindow: 'Example color controls') useDefaultOKButton.
	dialog contentMorph: (dialog newRow: {
		dialog newLabelGroup: {
			'Alpha Selector'->(dialog newAlphaSelector: (NewValueHolder new value: 0)
							getAlpha: #value setAlpha: #value: help: 'This is an alpha channel selector').
			'Hue Selector'->(dialog newHueSelector: (NewValueHolder new value: 0)
							getHue: #value setHue: #value: help: 'This is a hue selector').
			'SV Color Selector'->((dialog newSVSelector: Color yellow
									help: 'This is a saturation-volume selector') minHeight: 80).
			'HSV Color Selector'->((dialog newHSVSelector: Color green
									help: 'This is a hue-saturation-volume selector') minHeight: 80; minWidth: 120)}.
		dialog newVerticalSeparator.
		dialog newTitle: 'HSVA Color Selector' for:
			((dialog newHSVASelector: Color cyan
					help: 'This is a hue-saturation-volume-alpha selector')
					minHeight: 184; minWidth: 184)});
		model: nil.
	dialog openModal
]

{ #category : #examples }
WidgetExample class >> exampleDialogs [
	"Open an example of each services dialog"
	"self exampleDialogs"
	<script>
	
	self builder
		chooseFont: TextStyle default defaultFont;
		chooseColor: (Color r: 0.529 g: 0.611 b: 0.004);
		chooseDirectory: 'Choose folder';
		chooseFileName: 'Pick a file name' extensions: nil path: nil preview: nil;
		textEntry: 'Choose a name for the project' title: 'Save project' entryText: 'My Project';
		chooseDropList: 'Pick one!' list: #('One' 'Two' 'Three' 'Four');
		deny: 'Opening the safe is not possible!';
		message: 'Hello!';
		proceed: 'Save image?';
		alert: 'Danger!';
		abort: 'Something has gone wrong...';
		question: 'Save the file?' title: 'Exiting application';
		questionWithoutCancel: 'Save image as well?' title: 'Exiting application'
]

{ #category : #examples }
WidgetExample class >> exampleGroups [
	"Open a window with examples of each of the group type morphs."
	"self exampleGroups"
	<script>
	| dialog builder |
	builder := self builder.
	dialog := (builder newPluggableDialogWindow: 'Example groups')
		useDefaultOKButton.
	dialog
		contentMorph:
			((dialog
				newRow:
					{(dialog
						newLabelGroup:
							{('Plain Groupbox'
								->
									(dialog
										newGroupboxForAll:
											{(dialog
												newButtonFor: nil
												action: nil
												label: 'A Button'
												help: 'This is a button').
											(dialog
												newButtonFor: nil
												action: nil
												label: 'A Button'
												help: 'This is a button')})).
							('Groupbox'
								->
									(dialog
										newGroupbox: 'A groupbox'
										forAll:
											{(dialog
												newButtonFor: nil
												action: nil
												label: 'A Button'
												help: 'This is a button').
											(dialog
												newButtonFor: nil
												action: nil
												label: 'A Button'
												help: 'This is a button')}))}).
					(dialog
						newLabelGroup:
							{('Tab Group'
								->
									(dialog
										newTabGroup:
											{((dialog
												newRow:
													{(dialog newImage: (self iconNamed: #smallLeftFlushIcon)).
													(dialog newLabel: 'Page 1')})
												->
													(dialog
														newGroupbox: 'A groupbox'
														forAll:
															{(dialog
																newButtonFor: nil
																action: nil
																label: 'A Button'
																help: 'This is a button').
															(dialog
																newButtonFor: nil
																action: nil
																label: 'A Button'
																help: 'This is a button')})).
											('Page 2'
												->
													(dialog
														newCheckboxFor: (NewValueHolder new value: true)
														getSelected: #value
														setSelected: #value:
														label: 'A Checkbox'
														help: 'This is a checkbox'))}))})})
				vResizing: #spaceFill);
		model: nil.
	dialog openModal
]

{ #category : #examples }
WidgetExample class >> exampleOtherControls [
	"Open a window with examples of each of the other controls."
	"self exampleOtherControls"
	<script>
	| dialog builder image emboss fuzzy |
	builder := self builder.
	dialog := (builder newPluggableDialogWindow: 'Example other controls') useDefaultOKButton.
	emboss := (dialog newString: 'Hello there') trackPaneColor: false.
	fuzzy := (dialog newFuzzyLabel: 'A Fuzzy Label') minHeight: 40; minWidth: 160.
	dialog contentMorph: (dialog newRow: {
		dialog newTitle: 'Alpha Image' for: (
			dialog newColumn: {
				((image := dialog newAlphaImage: nil help: 'This is an alpha image')
					borderWidth: 1;
					extent: 160@160).
				dialog newLabelGroup: {
				'Scale'->(dialog newSliderFor: image getValue: #scale setValue: #scale:
					min: 0 max: 4 quantum: nil
					getEnabled: nil help: 'The image scale 0..1').
				'Alpha'->((dialog newAlphaSelector: image getAlpha: #alpha setAlpha: #alpha: help: 'The image alpha')
					vResizing: #shrinkWrap;
					minHeight: 16).
				'Layout'->(dialog newDropListFor: image list: #layoutSymbols
					getSelected: #layout setSelected: #layout:
					getEnabled: nil useIndex: false help: 'The image layout')}}).
		dialog newVerticalSeparator.
		dialog newLabelGroup: {
			'Color presenter'->((dialog newColorPresenterFor: (NewValueHolder new value: (Color blue alpha: 0.6))
					getColor: #value help: 'This is a color presenter')
					vResizing: #shrinkWrap).
			'Color chooser'->(dialog newColorChooserFor: emboss
					getColor: #color setColor: #color: help: 'This is a color chooser').
			'Row with dashed border'->((dialog newRow: {dialog newLabel: 'I have a dashed border!'})
					borderStyle: (DashedBorderStyle width: 3
							dashColors: {Color red. Color green. Color blue} dashLengths: #(1 2 3))).
			'Embossed string'->emboss.
			'Style'->(dialog newDropListFor: emboss list: #styleSymbols
					getSelected: #style setSelected: #style:
					getEnabled: nil useIndex: false help: 'The embossed string style').
			'Fuzzy label'->fuzzy.
			'Offset'->(dialog newSliderFor: fuzzy getValue: #offset setValue: #offset:
					min: 0 max: 5 quantum: 1
					getEnabled: nil help: 'The fuzzy label offset').
			'Alpha'->((dialog newAlphaSelector: fuzzy getAlpha: #alpha setAlpha: #alpha:
					help: 'The fuzzy label alpha')
					vResizing: #shrinkWrap;
					minHeight: 16)}.
		dialog newVerticalSeparator.
		dialog newTitle: 'Expanders' for: (
			(dialog newColumn: {
				(dialog newExpander: 'An Expander' forAll: {
					dialog newLabel: 'Expanded!'.
					builder newMorphListFor: (ListPresenter new items: ((Color red wheel: 15)
									collect: [:c | Morph new extent: 80@12; color: c]))
							list: #getList getSelected: #selectedIndex setSelected: #setSelectedIndex:
							help: 'This is a morph drop list'}) minWidth: 100.
				dialog newExpander: 'Another' forAll: {
					dialog newLabel: 'Expanded!'.
					builder newMorphDropListFor: (ListPresenter new items: ((Color red wheel: 8)
									collect: [:c | Morph new extent: 80@12; color: c]))
							list: #getList getSelected: #selectedIndex setSelected: #setSelectedIndex:
							help: 'This is a morph drop list'}})
				cellInset: 0;
				borderStyle: (BorderStyle inset baseColor: dialog paneColor; width: 1))});
		model: nil.
	dialog openModal
]

{ #category : #examples }
WidgetExample class >> exampleTextEntryWithCompletionDialog [
	"self exampleTextEntryWithCompletionDialog"
	<script>
	| applicants entryCompletion |
	applicants := (Array
				streamContents: [:strm | Symbol
						allSymbolTablesDo: [:each | (each notEmpty
									and: [each first canBeGlobalVarInitial
											and: [Smalltalk globals includesKey: each]])
								ifTrue: [strm nextPut: each]]]) sort.
	entryCompletion := EntryCompletion new
				dataSourceBlock: [:currText | applicants];		
				filterBlock: [:currApplicant :currText | currText size > 3
						and: [currApplicant asUppercase includesSubstring: currText asString asUppercase]].
	UIManager default
		request: 'Enter a class name fragment (at least 4 characters)'
		initialAnswer: ''
		title: 'Text entry with completion example: simple find a class'
		entryCompletion: entryCompletion
]

{ #category : #examples }
WidgetExample class >> exampleWindowWithToolbars [
	"Open an example window with toolbars."
	"self exampleWindowWithToolbars"
	<script>
	
	| win fileMenu tools dock text holder |
	win := StandardWindow new.
	fileMenu := win newMenu.
	fileMenu addToggle: 'Open' translated target: nil selector: #openFile.	"would be model"
	fileMenu lastItem
		font: win theme menuFont;
		icon: (self iconNamed: #smallOpenIcon);
		keyText: 'Ctrl+O'.
	fileMenu
		addToggle: 'Save' translated
		target: nil
		selector: #saveFile
		getStateSelector: nil
		enablementSelector: nil.
	fileMenu lastItem
		font: win theme menuFont;
		icon: (self iconNamed: #smallSaveIcon);
		keyText: 'Ctrl+S'.
	fileMenu
		addToggle: 'Print...' translated
		target: nil
		selector: #print.
	fileMenu lastItem
		font: win theme menuFont;
		icon: (self iconNamed: #smallPrintIcon);
		keyText: 'Ctrl+P'.
	tools := win
		newToolbar:
			{(win
				newButtonFor: nil
				getState: nil
				action: #openFile
				arguments: nil
				getEnabled: nil
				labelForm: (self iconNamed: #smallOpenIcon)
				help: 'Open file' translated).	"if we had a model it would go here"
			(win
				newButtonFor: nil
				getState: nil
				action: #saveFile
				arguments: nil
				getEnabled: nil
				labelForm: (self iconNamed: #smallSaveIcon)
				help: 'Save file' translated).
			(win
				newButtonFor: nil
				getState: nil
				action: #print
				arguments: nil
				getEnabled: nil
				labelForm: (self iconNamed: #smallPrintIcon)
				help: 'Print' translated)}.
	holder := NewValueHolder new.
	text := win
		newTextEditorFor: holder
		getText: #value
		setText: #value:.
	dock := win newToolDockingBar.
	dock
		add: 'File' translated
			font: win theme menuBarFont
			icon: (self iconNamed: #smallOpenIcon)
			help: 'File operations' translated
			subMenu: fileMenu;
		addMorphBack: tools.
	win
		addMorph: dock
			fullFrame: (LayoutFrame identity bottomFraction: 0;  bottomOffset: dock minExtent y);
		addMorph: text
			fullFrame: (LayoutFrame identity topOffset: dock minExtent y).
	win
		themeChanged;
		openInWorld
]
