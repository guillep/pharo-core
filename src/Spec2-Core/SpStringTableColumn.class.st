"
A column to display strings.
A `SpStringTableColumn` cell can be edited (see `SpStringTableColumn>>#beEditable` and `SpStringTableColumn>>#onAcceptEdition:`)

The user need to set the evaluation block (by sending `SpTableColumn>>#evaluated:`) to answer an image (an instance of `Form`).

## Example
```
SpStringTableColumn 
	title: 'My string' 
	evaluated: [ :anObject | anObject printString ]
```
"
Class {
	#name : #SpStringTableColumn,
	#superclass : #SpTableColumn,
	#instVars : [
		'editable',
		'acceptAction',
		'sortable',
		'colorAction',
		'backgroundColorAction',
		'italicAction',
		'boldAction',
		'underlineAction'
	],
	#category : #'Spec2-Core-Widgets-Table'
}

{ #category : #api }
SpStringTableColumn >> acceptAction [
	"Answer the action (set by `SpStringTablePresenter>>#onAcceptEdition:`) to execute when accepting an edition."
	
	^ acceptAction
]

{ #category : #visiting }
SpStringTableColumn >> acceptColumnVisitor: aBuilder [

	^ aBuilder visitStringColumn: self
]

{ #category : #api }
SpStringTableColumn >> beEditable [ 
	"Set the cell as editable."

	editable := true
]

{ #category : #api }
SpStringTableColumn >> beNotEditable [ 
	"Set the cell as not editable (this is the default)."

	editable := false
]

{ #category : #api }
SpStringTableColumn >> beNotSortable [

	self isSortable: false
]

{ #category : #api }
SpStringTableColumn >> beSortable [

	self isSortable: true
]

{ #category : #api }
SpStringTableColumn >> displayBackgroundColor [

	^ backgroundColorAction
]

{ #category : #api }
SpStringTableColumn >> displayBackgroundColor: aBlock [

	backgroundColorAction := aBlock
]

{ #category : #api }
SpStringTableColumn >> displayBold [

	^ boldAction
]

{ #category : #api }
SpStringTableColumn >> displayBold: aBlock [

	boldAction := aBlock
]

{ #category : #api }
SpStringTableColumn >> displayColor [

	^ colorAction
]

{ #category : #api }
SpStringTableColumn >> displayColor: aBlock [

	colorAction := aBlock
]

{ #category : #api }
SpStringTableColumn >> displayItalic [

	^ italicAction
]

{ #category : #api }
SpStringTableColumn >> displayItalic: aBlock [

	italicAction := aBlock
]

{ #category : #api }
SpStringTableColumn >> displayUnderline [

	^ underlineAction
]

{ #category : #api }
SpStringTableColumn >> displayUnderline: aBlock [

	underlineAction := aBlock
]

{ #category : #initialization }
SpStringTableColumn >> initialize [ 

	super initialize.
	editable := false.
	sortable := false
]

{ #category : #testing }
SpStringTableColumn >> isEditable [ 
	"Answer true if column has editable cells"
	
	^ editable
]

{ #category : #testing }
SpStringTableColumn >> isSortable [

	^ sortable
]

{ #category : #private }
SpStringTableColumn >> isSortable: aBoolean [ 

	sortable := aBoolean
]

{ #category : #api }
SpStringTableColumn >> onAcceptEdition: aBlock [
	"Set the block to execute when cell edition is accepted.
	 `aBlock` receives two arguments: 
		- the element of the table (See `SpAbstractListPresenter>>#items:`
		- the string entered while editing"

	acceptAction := aBlock
]

{ #category : #api }
SpStringTableColumn >> sortFunction [

	^ super sortFunction ifNil: [ self evaluation ascending ]
]

{ #category : #api }
SpStringTableColumn >> sortFunction: aBlockOrSortFunction [
	"Set the sort function to apply to the values of this column in order to sort elements.
	 `aBlockOrSortFunction` is a block that receives two arguments to compare or an instace of 
	 `SortFunction`. "

	super sortFunction: aBlockOrSortFunction.
	self isSortable: aBlockOrSortFunction notNil
]
