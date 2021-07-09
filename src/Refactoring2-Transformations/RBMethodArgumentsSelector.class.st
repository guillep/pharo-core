"
I am an editor to select values in a method that should be passed as arguments.

Usage:
RBMethodArgumentsSelector
	openOn: { 'argumentList' }
	and: { '#argumentList' }
	in: (RBParser parseMethod: 'update: argumentList
		self changed: #argumentList;
			changed: #argumentIndex.
		self changed: #isUpEnabled;
			changed: #isDownEnabled;
			changed: #isOkEnabled.
		labelMorph contents: self methodName printString')
"
Class {
	#name : #RBMethodArgumentsSelector,
	#superclass : #DialogWindowMorph,
	#instVars : [
		'arguments',
		'values',
		'argsAndValues',
		'argumentsList',
		'selectedArgumentIndex',
		'valuesList',
		'selectedValueIndex',
		'selectedAssociationIndex',
		'sourceCodeMorph',
		'tree'
	],
	#category : #'Refactoring2-Transformations-Utilities'
}

{ #category : #'instance creation' }
RBMethodArgumentsSelector class >> on: arguments and: values in: sourceCode [

	^ self basicNew
		initializeWith: arguments
		and: values
		in: sourceCode
]

{ #category : #'instance creation' }
RBMethodArgumentsSelector class >> openOn: arguments and: values in: sourceCode [

	^ (self 
		on: arguments
		and: values
		in: sourceCode) openModal
]

{ #category : #actions }
RBMethodArgumentsSelector >> addAssociation [

	[  | argument value |
		argument := argumentsList at: self argumentIndex.
		value := valuesList at: self valueIndex.
			
		"replace occurrences in code"
		tree := RBParseTreeRewriter 
			replace: value
			with: argument in: tree.
		
		"add new entry"
		argsAndValues at: argument put: value.
		"remove from lists"
		argumentsList removeAt: self argumentIndex.
		valuesList removeAt: self valueIndex.
		
		sourceCodeMorph contents: self sourceCode.
		self changed: #associations; changed: #arguments; 
				changed: #values; changed: #isOkEnabled ]
	on: Error do: [ self inform: 'Please select one argument and one value.' ]
	
]

{ #category : #accessing }
RBMethodArgumentsSelector >> argumentIndex [

	^ selectedArgumentIndex ifNil: [ selectedArgumentIndex := 0 ]
]

{ #category : #accessing }
RBMethodArgumentsSelector >> argumentIndex: anInteger [

	selectedArgumentIndex := anInteger.
	self changed: #argumentIndex
]

{ #category : #accessing }
RBMethodArgumentsSelector >> arguments [

	^ argumentsList ifNil: [ argumentsList := arguments asOrderedCollection ]
]

{ #category : #accessing }
RBMethodArgumentsSelector >> argumentsAndValues [

	^ argsAndValues
]

{ #category : #accessing }
RBMethodArgumentsSelector >> associationIndex [

	^ selectedAssociationIndex ifNil: [ selectedAssociationIndex := 0 ]
]

{ #category : #accessing }
RBMethodArgumentsSelector >> associationIndex: anInteger [

	selectedAssociationIndex := anInteger.
	self changed: #associationIndex
]

{ #category : #accessing }
RBMethodArgumentsSelector >> associations [

	^ argsAndValues associations collect: [:each | each asString ]
]

{ #category : #initialization }
RBMethodArgumentsSelector >> initializeWith: aCollection and: anotherCollection in: aTree [

	arguments := aCollection.
	values := anotherCollection.
	tree := aTree.
	
	argsAndValues := Dictionary new.
	
	self initialize.
	self title: 'There are extra arguments in this method. Please map a value to each extra argument.' translated
]

{ #category : #testing }
RBMethodArgumentsSelector >> isOkEnabled [

	^ argumentsList isEmpty
]

{ #category : #actions }
RBMethodArgumentsSelector >> newContentMorph [

	^ (self newColumn: { 
		(self newRow: {
			"the arguments"
			self newGroupbox: 'Arguments' for: (self newColumn: {
				(self newListFor: self
					list: #arguments
					selected: #argumentIndex
					changeSelected: #argumentIndex:
					help: nil)
					hResizing: #spaceFill;
					yourself }).
					
			"the values"
			self newGroupbox: 'Values' for: (self newColumn: {
				(self newListFor: self
					list: #values
					selected: #valueIndex
					changeSelected: #valueIndex:
					help: nil)
					hResizing: #spaceFill;
					yourself }).
					
			"add an association"
			(self newRow: {
				self newButtonFor: self action: #addAssociation 
					label: 'v' help: 'Map'.})
				hResizing: #shrinkWrap}).
				
		"source code preview"
		(self newRow: {
			self newGroupbox: 'Preview' for: (self newColumn: {
				sourceCodeMorph := (self newText: tree formattedCode)
					extent: 400@400;
					hResizing: #rigid }) }).
				
		"associations"
		(self newRow: {
			self newGroupbox: 'Associations' for: (self newColumn: {
				(self newListFor: self
					list: #associations
					selected: #associationIndex
					changeSelected: #associationIndex:
					help: nil)
					hResizing: #spaceFill;
					yourself. }).
					
		"remove association"
		(self newRow: {
			self newButtonFor: self action: #removeAssociation
				label: '^' help: 'Unmap'.})
			hResizing: #shrinkWrap }).		
		
	 }) vResizing: #shrinkWrap

]

{ #category : #controls }
RBMethodArgumentsSelector >> newOKButton [

	^ self newOKButtonFor: self getEnabled: #isOkEnabled
]

{ #category : #accessing }
RBMethodArgumentsSelector >> newTree [

	^ tree
]

{ #category : #actions }
RBMethodArgumentsSelector >> removeAssociation [

	[  | association argument value |
		association := argsAndValues associations at: self associationIndex.
		argument := association key.
		value := association value.
		
		"replace occurrences in code"
		tree := RBParseTreeRewriter 
			replace: argument
			with: value in: tree.

		"remove entry"
		argsAndValues removeKey: argument.
		argumentsList add: argument.
		valuesList add: value.
		
		sourceCodeMorph contents: self sourceCode.
		self changed: #associations; changed: #arguments;
				changed: #values; changed: #isOkEnabled ]
	on: Error do: [ self inform: 'Please select one association to remove.' ]
	
]

{ #category : #accessing }
RBMethodArgumentsSelector >> sourceCode [

	^ tree formattedCode
]

{ #category : #accessing }
RBMethodArgumentsSelector >> valueIndex [

	^ selectedValueIndex ifNil: [ selectedValueIndex := 0 ]
]

{ #category : #accessing }
RBMethodArgumentsSelector >> valueIndex: anInteger [

	selectedValueIndex := anInteger.
	self changed: #valueIndex
]

{ #category : #accessing }
RBMethodArgumentsSelector >> values [

	^ valuesList ifNil: [ valuesList := values asOrderedCollection ]
]
