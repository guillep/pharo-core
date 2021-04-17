"
A builder to define presenters through method factory pattern. 
This allow users to compose presenters without needed to have hardcoded the name of them (which could or not change/be present/etc.)
"
Trait {
	#name : #SpTPresenterBuilder,
	#category : #'Spec2-Core-Base'
}

{ #category : #'instance creation' }
SpTPresenterBuilder >> instantiate: aPresenterClass [
	"Instantiate a SpPresenter subclass and set its instance owner"
	^ aPresenterClass owner: self
]

{ #category : #'instance creation' }
SpTPresenterBuilder >> instantiate: aPresenterClass on: aModel [
	"Instantiate a SpPresenter subclass and set its instance owner and model"
	^ aPresenterClass owner: self on: aModel
]

{ #category : #'scripting widgets' }
SpTPresenterBuilder >> newActionBar [

	^ self instantiate: SpActionBarPresenter
]

{ #category : #'scripting widgets' }
SpTPresenterBuilder >> newAthens [

	^ self instantiate: SpAthensPresenter
]

{ #category : #'scripting layouts' }
SpTPresenterBuilder >> newBoxLayoutLeftToRight [

	^ SpBoxLayout newLeftToRight
]

{ #category : #'scripting layouts' }
SpTPresenterBuilder >> newBoxLayoutTopToBottom [

	^ SpBoxLayout newTopToBottom
]

{ #category : #'scripting widgets' }
SpTPresenterBuilder >> newButton [
	^ self instantiate: SpButtonPresenter
]

{ #category : #'scripting widgets' }
SpTPresenterBuilder >> newButtonBar [

	^ self instantiate: SpButtonBarPresenter
]

{ #category : #'scripting widgets' }
SpTPresenterBuilder >> newCheckBox [
	^ self instantiate: SpCheckBoxPresenter
]

{ #category : #'scripting widgets' }
SpTPresenterBuilder >> newComponentList [
	^ self instantiate: SpComponentListPresenter
]

{ #category : #'scripting widgets' }
SpTPresenterBuilder >> newDiff [
	^ self instantiate: SpDiffPresenter
]

{ #category : #'scripting widgets' }
SpTPresenterBuilder >> newDropList [
	^ self instantiate: SpDropListPresenter
]

{ #category : #'scripting widgets' }
SpTPresenterBuilder >> newDynamicPresentersListIn: accessorSymbol usingBuilder: aDynamicPresentersListBuilder [
	|mutatorSymbol newDynamicPresenter |
	mutatorSymbol := (accessorSymbol , ':') asSymbol.
	(self perform: accessorSymbol)
		ifNotNil: [ :dynamicPresenter | dynamicPresenter owner: nil ].
	newDynamicPresenter := aDynamicPresentersListBuilder build.
	
	self perform: mutatorSymbol with: newDynamicPresenter.
	
	newDynamicPresenter owner: self.
	
	self needRebuild: false.
	self buildWithSpec
]

{ #category : #'scripting widgets' }
SpTPresenterBuilder >> newFilteringList [

	^ self instantiate: SpFilteringListPresenter
]

{ #category : #'scripting layouts' }
SpTPresenterBuilder >> newGridLayout [

	^ SpGridLayout new
]

{ #category : #'scripting widgets' }
SpTPresenterBuilder >> newLabel [
	^ self instantiate: SpLabelPresenter
]

{ #category : #'scripting widgets' }
SpTPresenterBuilder >> newList [
	^ self instantiate: SpListPresenter
]

{ #category : #'scripting widgets' }
SpTPresenterBuilder >> newMenu [
	^ self instantiate: SpMenuPresenter
]

{ #category : #'scripting widgets' }
SpTPresenterBuilder >> newMenuBar [
	^ self instantiate: SpMenuBarPresenter
]

{ #category : #'scripting widgets' }
SpTPresenterBuilder >> newMenuButton [

	^ self instantiate: SpMenuButtonPresenter
]

{ #category : #'scripting widgets' }
SpTPresenterBuilder >> newNotebook [

	^ self instantiate: SpNotebookPresenter
]

{ #category : #'scripting widgets' }
SpTPresenterBuilder >> newNotebookPage [

	self flag: #TODO. "NotebookPage needs to be a Presenter?"
	^ SpNotebookPage new
]

{ #category : #'scripting widgets' }
SpTPresenterBuilder >> newNullPresenter [
	^ self instantiate: SpNullPresenter
]

{ #category : #'scripting widgets' }
SpTPresenterBuilder >> newNumberInput [
	^ self instantiate: SpNumberInputFieldPresenter
]

{ #category : #'scripting layouts' }
SpTPresenterBuilder >> newOverlayLayout [

	^ SpOverlayLayout new
]

{ #category : #'scripting layouts' }
SpTPresenterBuilder >> newPanedLayoutLeftToRight [

	^ SpPanedLayout newLeftToRight
]

{ #category : #'scripting layouts' }
SpTPresenterBuilder >> newPanedLayoutTopToBottom [

	^ SpPanedLayout newTopToBottom
]

{ #category : #'scripting widgets' }
SpTPresenterBuilder >> newPopover [

	^ self instantiate: SpPopoverPresenter
]

{ #category : #'scripting widgets' }
SpTPresenterBuilder >> newPresenter [

	^ self instantiate: SpPresenter
]

{ #category : #'scripting widgets' }
SpTPresenterBuilder >> newPresenterSelector [

	^ self instantiate: SpPresenterSelectorPresenter
]

{ #category : #'scripting widgets' }
SpTPresenterBuilder >> newPresenterWith: aBlock [
	| presenter |

	presenter := self instantiate: SpPresenter.
	aBlock value: aBlock.

	^ presenter
]

{ #category : #'scripting widgets' }
SpTPresenterBuilder >> newProgressBar [
	^ self instantiate: SpProgressBarPresenter
]

{ #category : #'scripting widgets' }
SpTPresenterBuilder >> newRadioButton [
	^ self instantiate: SpRadioButtonPresenter
]

{ #category : #'scripting widgets' }
SpTPresenterBuilder >> newRichText [

	^ self instantiate: SpRichTextPresenter
]

{ #category : #'scripting layouts' }
SpTPresenterBuilder >> newScrollableLayout [

	^ SpScrollableLayout new
]

{ #category : #'scripting widgets' }
SpTPresenterBuilder >> newSearchInput [

	^ self instantiate: SpSearchInputFieldPresenter
]

{ #category : #'scripting widgets' }
SpTPresenterBuilder >> newSlider [
	^ self instantiate: SpSliderPresenter
]

{ #category : #'scripting widgets' }
SpTPresenterBuilder >> newSpinner [

	^ self instantiate: SpSpinnerPresenter
]

{ #category : #'scripting widgets' }
SpTPresenterBuilder >> newStatusBar [

	^ self instantiate: SpStatusBarPresenter
]

{ #category : #'scripting widgets' }
SpTPresenterBuilder >> newTable [

	^ self instantiate: SpTablePresenter
]

{ #category : #'scripting widgets' }
SpTPresenterBuilder >> newText [
	^ self instantiate: SpTextPresenter
]

{ #category : #'scripting widgets' }
SpTPresenterBuilder >> newTextInput [
	^ self instantiate: SpTextInputFieldPresenter
]

{ #category : #'scripting widgets' }
SpTPresenterBuilder >> newToggleButton [

	^ self instantiate: SpToggleButtonPresenter
]

{ #category : #'scripting widgets' }
SpTPresenterBuilder >> newToolbar [

	^ self instantiate: SpToolbarPresenter
]

{ #category : #'scripting widgets' }
SpTPresenterBuilder >> newToolbarButton [

	^ self instantiate: SpToolbarButtonPresenter
]

{ #category : #'scripting widgets' }
SpTPresenterBuilder >> newToolbarMenuButton [

	^ self instantiate: SpToolbarMenuButtonPresenter
]

{ #category : #'scripting widgets' }
SpTPresenterBuilder >> newToolbarPopoverButton [

	^ self instantiate: SpToolbarPopoverButtonPresenter
]

{ #category : #'scripting widgets' }
SpTPresenterBuilder >> newToolbarToggleButton [

	^ self instantiate: SpToolbarToggleButtonPresenter
]

{ #category : #'scripting widgets' }
SpTPresenterBuilder >> newTree [

	^ self instantiate: SpTreePresenter
]

{ #category : #'scripting widgets' }
SpTPresenterBuilder >> newTreeTable [

	^ self instantiate: SpTreeTablePresenter
]
