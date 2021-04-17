"
I browse the item selected in middle list of DrTests.
"
Class {
	#name : #DTBrowseSelectedItemCommand,
	#superclass : #DTMiddleListCommand,
	#category : #'DrTests-Commands'
}

{ #category : #defaults }
DTBrowseSelectedItemCommand class >> defaultName [ 
	"Return the default name of the command"
	
	^ 'Browse'
]

{ #category : #testing }
DTBrowseSelectedItemCommand >> canBeExecuted [

	^ self selectedItems size = 1
]

{ #category : #executing }
DTBrowseSelectedItemCommand >> execute [

	self drTest browseSelectedItem
]
