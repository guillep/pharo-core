"
A column that display a boolean value in the form of a checkbox.

The user need to set the evaluation block (by sending `SpTableColumn>>#evaluated:`) to answer a boolean value that will define if the checkbox is selected or unselected.

## Example
```
SpCheckBoxTableColumn 
	title: 'My CheckBox' 
	evaluated: [ :anObject | anObject = someValue ]
```
"
Class {
	#name : #SpCheckBoxTableColumn,
	#superclass : #SpTableColumn,
	#instVars : [
		'onActivation',
		'onDeactivation'
	],
	#category : #'Spec2-Core-Widgets-Table'
}

{ #category : #visiting }
SpCheckBoxTableColumn >> acceptColumnVisitor: aBuilder [

	^ aBuilder visitCheckboxColumn: self
]

{ #category : #api }
SpCheckBoxTableColumn >> onActivation [
	"Answer the block to be executed when a checkbox is activated (marked)"

	^ onActivation
]

{ #category : #api }
SpCheckBoxTableColumn >> onActivation: aBlock [
	"Set the block to be executed when a checkbox is activated (marked). 
	 `aBlock` receives one argument, the element in which the checkbox acts."

	onActivation := aBlock
]

{ #category : #api }
SpCheckBoxTableColumn >> onDeactivation [
	"Answer the block to be executed when a checkbox is deactivated (unmarked)"

	^ onDeactivation
]

{ #category : #api }
SpCheckBoxTableColumn >> onDeactivation: aBlock [
	"Set the block to be executed when a checkbox is deactivated (unmarked). 
	 `aBlock` receives one argument, the element in which the checkbox acts."

	onDeactivation := aBlock
]
