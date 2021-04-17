Extension { #name : #ClyTextEditor }

{ #category : #'*Calypso-SystemTools-QueryBrowser' }
ClyTextEditor >> classCommentsContainingIt [
	"Open a browser class comments which contain the current selection somewhere in them."

	| query |
	self lineSelectAndEmptyCheck: [^ self].

	query := ClyClassCommentsQuery withString: self selection string.
	self browser spawnQueryBrowserOn: query
]

{ #category : #'*Calypso-SystemTools-QueryBrowser' }
ClyTextEditor >> classNamesContainingIt [
	"Open a browser on classes whose names contain the selected string"

	| query |
	self lineSelectAndEmptyCheck: [^self].

	query := ClyAllClassesQuery new filteredBy: (ClyItemNameFilter substringPattern: self selection string).
	self browser spawnQueryBrowserOn: query
]

{ #category : #'*Calypso-SystemTools-QueryBrowser' }
ClyTextEditor >> implementorsOf: selectedSelector [
	
	self browser browseImplementorsOf: selectedSelector
]

{ #category : #'*Calypso-SystemTools-QueryBrowser' }
ClyTextEditor >> implementorsOfIt [

	| selector |
	(selector := self selectedSelector) ifNil: [ ^ textArea flash ].
	selector isCharacter ifTrue: [ ^ textArea flash ].
	self browser browseImplementorsOf: selector
]

{ #category : #'*Calypso-SystemTools-QueryBrowser' }
ClyTextEditor >> methodSourceContainingIt [
	"Open a browser class comments which contain the current selection somewhere in them."

	| query pattern |
	self lineSelectAndEmptyCheck: [^ self].
	pattern := self selection string.
	query := (ClyMethodSourcesQuery withString: pattern), (ClyClassCommentsQuery withString: pattern).
	self browser spawnQueryBrowserOn: query
]

{ #category : #'*Calypso-SystemTools-QueryBrowser' }
ClyTextEditor >> referencesTo: aVariableName [
	"Open a references browser on the given symbol"
	| class var |
	" ugly dispatch, but current Browser protocol names aren't really cool "
	class := self modelCurrentSelectedClass.

	class isBehavior ifTrue: [ 
		class slotNamed: aVariableName ifFound: [:slot | 
			var := ClyInstanceVariable on: slot visibleFrom: class.
			^self browser spawnQueryBrowserOn: (ClyVariableReferencesQuery of: var)]].
	
	self browser browseReferencesTo: aVariableName asSymbol from: class
]

{ #category : #'*Calypso-SystemTools-QueryBrowser' }
ClyTextEditor >> referencesToIt [
	| selector |
	"self lineSelectAndEmptyCheck: [^ self]."
	(selector := self selectedSelector) == nil ifTrue: [^ textArea flash].
	
	self referencesTo: selector
]

{ #category : #'*Calypso-SystemTools-QueryBrowser' }
ClyTextEditor >> sendersOf: selectedSelector [

	self browser browseReferencesTo: selectedSelector
]

{ #category : #'*Calypso-SystemTools-QueryBrowser' }
ClyTextEditor >> sendersOfIt [

	| selector |
	(selector := self selectedSelector) ifNil: [ ^ textArea flash ].
	self sendersOf: selector
]
