"
I am the component of DynamycSpecExample used for String.

self example 

I show also how to dynamically redrawn a widget.
"
Class {
	#name : #OpenOnStringExample,
	#superclass : #ComposablePresenter,
	#instVars : [
		'label',
		'check',
		'input',
		'button',
		'textToReset'
	],
	#category : #'Spec-Examples-Wrapper'
}

{ #category : #specs }
OpenOnStringExample class >> bottomLayout [
	<spec>
	^ SpecLayout composed
		newColumn: [ :column | 
			column
				newRow: [ :row | 
					row
						add: #input;
						add: #button ]
					height: 25;
				newRow: [ :row | 
					row
						add: #label;
						add: #check width: 100 ]
					height: 25 ];
		yourself
]

{ #category : #specs }
OpenOnStringExample class >> defaultSpec [
	<spec: #default>
	^ SpecLayout composed
		newColumn: [ :column | 
			column
				newRow: [ :row | 
					row
						add: #label;
						add: #check width: 100 ]
					height: 25;
				newRow: [ :row | 
					row
						add: #input;
						add: #button ]
					height: 25 ];
		yourself
]

{ #category : #examples }
OpenOnStringExample class >> example [
	<sampleInstance>
	| example |
	example := self new: 'Hello world'.
	example
		extent: 300 @ 200;
		openWithSpec.
	^ example
]

{ #category : #instantiation }
OpenOnStringExample class >> new: aString [
	^ self new initialize: aString
]

{ #category : #accessing }
OpenOnStringExample >> button [
	^ button
]

{ #category : #accessing }
OpenOnStringExample >> check [
	^ check
]

{ #category : #initialization }
OpenOnStringExample >> initialize: aString [
	label label: aString.
	input text: aString.
	textToReset := aString
]

{ #category : #initialization }
OpenOnStringExample >> initializePresenter [
	button action: [ input text: textToReset ].
	input whenTextChanged: [:text | label label: text].
	check
		whenActivatedDo: [ self needRebuild: false.
			self buildWithSpecLayout: self class defaultSpec ];
		whenDeactivatedDo: [ self needRebuild: false.
			self buildWithSpecLayout: self class bottomLayout ]
]

{ #category : #initialization }
OpenOnStringExample >> initializeWidgets [
	label := self instantiate: LabelPresenter.
	check := self instantiate: CheckBoxPresenter.
	input := self instantiate: TextInputFieldPresenter.
	button := self instantiate: ButtonPresenter.
	button
		label: 'reset';
		action: [ input text: textToReset ].
	check
		label: 'Label on top';
		state: true
]

{ #category : #accessing }
OpenOnStringExample >> input [
	^ input
]

{ #category : #accessing }
OpenOnStringExample >> label [
	^ label
]

{ #category : #accessing }
OpenOnStringExample >> openOnString [
	| ui temp object |
	object whenChangedDo: [ :o | ui label label: o asString ].
	temp := object value.

]

{ #category : #accessing }
OpenOnStringExample >> textToReset [
	^ textToReset
]

{ #category : #accessing }
OpenOnStringExample >> title [
	^ 'OpenOnStringExample'
]
