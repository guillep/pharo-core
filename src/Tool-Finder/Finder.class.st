"
I'm the finderUI model in the MVC pattern.

I'm compute the search string and I construct a resultDictionary.
Then I throw events everywhere and my views are redrawn.
"
Class {
	#name : #Finder,
	#superclass : #Object,
	#instVars : [
		'searchingString',
		'selectedMethod',
		'selectedClass',
		'packagesSelection',
		'currentSearchMode',
		'environment',
		'resultDictionary',
		'useRegEx'
	],
	#category : #'Tool-Finder-Base'
}

{ #category : #menu }
Finder class >> finderMenuOn: aBuilder [ 
	<worldMenu>

	(aBuilder item: #Finder)
		action: [self open];
		order: 2;
		parent: #Searching;
		help: 'Looking for something ?';
		icon: self icon.
]

{ #category : #menu }
Finder class >> icon [

	^ FinderUI icon
]

{ #category : #menu }
Finder class >> open [
	<script>
	
	^ self new open
]

{ #category : #'tools registry' }
Finder class >> registerToolsOn: registry [
	"Add ourselves to registry. See [Smalltalk tools]" 

	registry register: self as: #finder

	
]

{ #category : #private }
Finder >> classSearch: aSelectBlock [
	| result |
	result := OrderedCollection new.
	self packagesSelection classesAndTraitsDo:[ :class | 
			(aSelectBlock value: class)
				ifTrue: [ result add: class ] ].
	^ result
]

{ #category : #'private-class' }
Finder >> computeListOfClasses: aString [
	"Compute in the case I'm searching class names"
		
	^ self useRegEx
		ifTrue: [ | regex |
			regex := aString asRegex.
			self classSearch: [ :class | regex search: class name ]]
		ifFalse: [ 
			self classSearch: [ :class |
				class name includesSubstring: aString caseSensitive: false ]]
]

{ #category : #'private-example' }
Finder >> computeWithMethodFinder: aString [
	"Compute the selectors for the single example of receiver and args, in the very top pane"

	| data result dataObjects |
	(aString includes: $.)
		ifFalse: [ ^ #() ].	"delete trailing period. This should be fixed in the Parser!"
	data := aString trimRight: [ :char | char isSeparator or: [ char = $. ] ].

	[ dataObjects := Smalltalk compiler evaluate: '{' , data , '}' ]
		on: SyntaxErrorNotification, RuntimeSyntaxError
		do: [ :e | 
			self inform: 'Syntax Error: ' , e errorMessage.
			^ #() ].	"#( data1 data2 result )"
	
	dataObjects size < 2
		ifTrue: [ 
			self
				inform:
					'If you are giving an example of receiver, \args, and result, please put periods between the parts.\Otherwise just type one selector fragment'
						withCRs.
			^ #() ].
		
	result := MethodFinder new findMethodsByExampleInput: dataObjects allButLast andExpectedResult: dataObjects last.
	result isEmpty ifTrue: [ self inform: 'no single method'. ^ #()].
	^ result.
]

{ #category : #'private-class' }
Finder >> constructClassNamesDictionary [
	"Construct the dictionary in the case I'm searching in class names"
	
	| result listOfClasses |
	listOfClasses := self computeListOfClasses: self searchingString.
	result := Dictionary new.
	listOfClasses do: [:each | 
		result at: each put: (each selectors sort: [:a :b | a < b])].
	self resultDictionary: result
]

{ #category : #private }
Finder >> constructDictionary [
	"I construct the adequate dictionary regarding the search mode"

	self searchingString isEmpty ifTrue: [ ^self resultDictionary: Dictionary new ].
	[ :job|
		job title: 'Searching...' translated.
		self isSelectorsSymbol
			ifTrue: [ self constructDictionaryWithMessagesNameSearch: self searchingString ].
		self isClassNamesSymbol
			ifTrue: [ self constructClassNamesDictionary ].
		self isSourceSymbol
			ifTrue: [ self constructSourceDictionary ].
		self isExamplesSymbol
			ifTrue: [ self constructDictionaryWithMethodFinder: self searchingString].
		self isPragmasSymbol
			ifTrue: [ self constructDictionaryWithPragmaSearch: self searchingString ].
	] asJob run
]

{ #category : #'private-selector' }
Finder >> constructDictionaryWithMessagesNameSearch: aString [
	"Construct dictionary when searching for selector"
	
	| result listOfMethods |
	result := Dictionary new.
	listOfMethods := self messagesNameSearch: aString.
	listOfMethods do: [:method || key value |
			key := method selector.
			value := method methodClass.
			(result includesKey: key)
				ifTrue: [ (result at: key) add: value]
				ifFalse: [ result at: key put: (OrderedCollection new add: value; yourself)]].
	self resultDictionary: result
]

{ #category : #'private-example' }
Finder >> constructDictionaryWithMethodFinder: aString [
	"construct dictionary when searching patterns"

	| result listOfResults listOfSelectors |
	result := Dictionary new.
	listOfResults := self computeWithMethodFinder: aString.
	listOfSelectors := listOfResults collect: [ :each | each selector ].
	self packagesSelection classesDo:[ :class | 
			class methodsDo:  [ :method | 
					| index |
					(index := listOfSelectors indexOf: method selector) = 0
						ifFalse: [ 
							| key value |
							key := listOfResults at: index.
							value := method methodClass.
							(result includesKey: key)
								ifTrue: [ (result at: key) add: value ]
								ifFalse: [ 
									result
										at: key
										put:
											(OrderedCollection new
												add: value;
												yourself) ] ] ] ].
	self resultDictionary: result
]

{ #category : #'private-pragma' }
Finder >> constructDictionaryWithPragmaSearch: aString [ 
	"construct dictionary when searching for pragmas"
	
	| dictionary |
	dictionary := self pragmaSearch: aString.
	dictionary keysDo:[ :k || result |
		result := Dictionary new.
		(dictionary at: k) do: [:method || key value |
				key := method selector.
				value := method methodClass.
				(result 
					at: key
					ifAbsentPut: OrderedCollection new ) add: value].
		dictionary at: k put: result ].
	self resultDictionary: dictionary
]

{ #category : #private }
Finder >> constructSourceDictionary [
"construct dictionary when searching source"
	| result listOfMethods |
	result := Dictionary new.
	listOfMethods := self sourceSearch: self searchingString.
	listOfMethods do: [:method || key value |
		key := method selector.
		value := method methodClass.
		(result includesKey: key)
			ifTrue: [ (result at: key) add: value]
			ifFalse: [ result at: key put: (OrderedCollection new add: value; yourself)]].
	self resultDictionary: result
]

{ #category : #accessing }
Finder >> currentSearchMode [
	"Getter"
	"I shoud answer a Symbol in :
		- #Selectors
		- #Classes
		- #Source
		- #Examples"
	
	 ^ currentSearchMode
]

{ #category : #accessing }
Finder >> currentSearchMode: aSymbol [
	"Setter"
	"If #Examples is selected, I disable the RegEx checkbo. Then I rebuild the resultDictionary"

	currentSearchMode := aSymbol.
	self isExamplesSymbol
		ifTrue: [ self disableUseRegEx]
		ifFalse:[ self enableUseRegEx].
		
	self update: #sourceCode.
	self constructDictionary
]

{ #category : #default }
Finder >> defaultEnvironment [
	 ^ RBBrowserEnvironment new
]

{ #category : #default }
Finder >> defaultPackagesSelection [
	 ^ self environment
]

{ #category : #default }
Finder >> defaultString [
	^ ''
]

{ #category : #private }
Finder >> disableUseRegEx [
	"send a disable useRegEx dropbox event"
	^ self triggerEvent: #disableUseRegEx
]

{ #category : #private }
Finder >> enableUseRegEx [
	"send an 'enableUseRegEx' dropbox event"
	^ self triggerEvent: #enableUseRegEx
]

{ #category : #accessing }
Finder >> environment [

	 ^ environment 
]

{ #category : #accessing }
Finder >> environment: aCollection [

	 environment := aCollection
]

{ #category : #initialization }
Finder >> initialize [
	super initialize.
	searchingString := self defaultString.
	environment := self defaultEnvironment.
	packagesSelection := self defaultPackagesSelection.
	resultDictionary := Dictionary new.
	currentSearchMode := #Selectors.
	useRegEx := false
	
]

{ #category : #checkbox }
Finder >> isClassNamesSymbol [
	"answer if the current mode is Classes"
	^self currentSearchMode = #Classes
]

{ #category : #checkbox }
Finder >> isExamplesSymbol [
	"Answer if the current mode is Examples"
	^self currentSearchMode = #Examples
]

{ #category : #checkbox }
Finder >> isPragmasSymbol [
	"Answer if the current mode is Pragmas"
	^self currentSearchMode = #Pragmas
]

{ #category : #checkbox }
Finder >> isSelectorsSymbol [
	"Answer if the current mode is Selectors"
	^self currentSearchMode = #Selectors
]

{ #category : #checkbox }
Finder >> isSourceSymbol [
	"Answer if the current mode is Source"
	^self currentSearchMode = #Source
]

{ #category : #'private-selector' }
Finder >> messageSearchBlockFrom: aString [
	| exactMatch |
	exactMatch := aString first = $" and: [ aString last = $" ].

	exactMatch ifFalse: [ ^ [ :method | method selector includesSubstring: aString caseSensitive: false ] ].

	^ (Symbol findInterned: (aString copyFrom: 2 to: aString size - 1)) ifNotNil: [ :aSymbol | [ :method | method selector = aSymbol ] ]
]

{ #category : #'private-selector' }
Finder >> messagesNameSearch: aString [
	"I'm searching for selectors"
	^ self useRegEx
		ifTrue: [ | regex |
			regex := aString asRegex.
			self methodSearch: [ :method| 	regex search: method selector asString ]]
		ifFalse: [
			self methodSearch: (self messageSearchBlockFrom: aString)]
]

{ #category : #private }
Finder >> methodSearch: aSelectBlock [ 
	| result | 
	result := OrderedCollection new.
	aSelectBlock ifNil: [ ^result ].
	self packagesSelection classesAndTraits do:[ :class |
			class methodsDo: [ :method | 
				(aSelectBlock value: method) ifTrue: [ result add: method ]].
			class classSide methodsDo: [ :method | 
				(aSelectBlock value: method) ifTrue: [ result add: method ]]
			]
			displayingProgress: [ :aClass | aClass name ].
	^ result
]

{ #category : #display }
Finder >> open [
	<script: 'self new open'>
	
	^ (FinderUI on: self) open
]

{ #category : #accessing }
Finder >> packagesSelection [
	"I should be a selection of classes"
	^packagesSelection
]

{ #category : #accessing }
Finder >> packagesSelection: aCollection [
	"I change the classes selection, then I rebuild the result dictionary"

	packagesSelection :=  aCollection.
	self constructDictionary
]

{ #category : #'private-pragma' }
Finder >> pragmaSearch: aString [ 
	| result byCondition |
	"I choose a dictionary here because the next step is to group result by pragmas."
	result := Dictionary new.
	
	byCondition :=  self useRegEx 
		ifTrue: [[ :pragma | pragma selector matchesRegexIgnoringCase: aString ]]
		ifFalse: [[ :pragma | pragma selector includesSubstring: aString caseSensitive: false ]].
	
	(Pragma all select: byCondition)
		do: [ :pragma |
			(result at: (pragma selector) ifAbsentPut: OrderedCollection new)				
				add: pragma method ].
	^ result
]

{ #category : #private }
Finder >> resetEnvironment [
	"I send an event when I reset the environment"
	self environment: self defaultEnvironment.
	self triggerEvent: #resetEnvironment
]

{ #category : #accessing }
Finder >> resultDictionary [
	"I should answer a dictionary"
	^resultDictionary
]

{ #category : #accessing }
Finder >> resultDictionary: aDictionary [
	"When the result dictionary is update, I send an event through the whole universe"

	resultDictionary := aDictionary.
	self triggerEvent: #updateResultDictionary.
	self selectedMethod: nil.
	self selectedClass: nil.
	self triggerEvent: #updateSourceCode
]

{ #category : #accessing }
Finder >> searchingString [

	^searchingString
]

{ #category : #accessing }
Finder >> searchingString: aString [
	"When the search string is modified (in fact, when I make a search) I rebuild the result dictionary"

	searchingString := aString.
	self constructDictionary
]

{ #category : #accessing }
Finder >> searchingStringSilently: aString [

	searchingString := aString

]

{ #category : #accessing }
Finder >> selectedClass [

	^selectedClass
]

{ #category : #accessing }
Finder >> selectedClass: aClass [
	"When the class seletion is changed, I send an event to UI"
	selectedClass := aClass.
	self triggerEvent: #updateSelectedClass
	
]

{ #category : #accessing }
Finder >> selectedMethod [
	"I should answer a CompiledMethod"
	^selectedMethod
]

{ #category : #accessing }
Finder >> selectedMethod: aMethod [
	"When the method seletion is changed, I send an event to UI"
	selectedMethod := aMethod.
	self triggerEvent: #updateSelectedMethod
]

{ #category : #accessing }
Finder >> selection: aSelectionHolder [
	"anObject is a selection holder"
	"Depending of the value of currentSearchMode, I fill selectedMethod and SelectedClass with the good items."
	"Then, I update the source code text area"

	| path methodNode method classNode class |
	(aSelectionHolder isNil or: [aSelectionHolder selectedNodePath isNil]) ifTrue: [
		self selectedClass: nil.
		self selectedMethod: nil.
		^self].
	path := aSelectionHolder selectedNodePath.
	self isSelectorsSymbol
		ifTrue: [
			path first isSingle
				ifTrue: [
					method := path first itemMethod selector.
					class := path first itemMethod methodClass ]
				ifFalse: [
					methodNode := path first.
					classNode := path at: 2 ifAbsent: [ nil ]]].
	self isClassNamesSymbol
		ifTrue: [
			classNode := path first.
			methodNode := path at: 2 ifAbsent:[nil]].
	self isSourceSymbol
		ifTrue: [
			methodNode := path first.
			classNode := path at: 2 ifAbsent:[nil]].
	self isExamplesSymbol
		ifTrue: [
			methodNode := path first.
			classNode := path at: 2 ifAbsent:[nil]].
	self isPragmasSymbol
		ifTrue: [
			methodNode := path at:2 ifAbsent: [ nil ].
			classNode := path at: 3 ifAbsent:[nil]].		

	classNode ifNotNil: [ class := classNode item ].
	self selectedClass: class.
	
	methodNode ifNotNil: [ method := methodNode item ].
	self selectedMethod: method.
	
	self triggerEvent: #updateSourceCode
]

{ #category : #private }
Finder >> sourceRegexSearch: aSearchString [
	| regex |
	regex := aSearchString asRegex.
	^ self methodSearch: [ :method | regex search: method sourceCode ]
]

{ #category : #private }
Finder >> sourceSearch: aSearchString [
	"I'm searching in sources"
	^ self useRegEx
		ifTrue: [ self sourceRegexSearch: aSearchString ]
		ifFalse:[ self sourceStringSearch: aSearchString ]
]

{ #category : #private }
Finder >> sourceStringSearch: aSearchString [ 
	^ self 
		methodSearch: [ :method |
			method sourceCode includesSubstring: aSearchString caseSensitive: false ]
]

{ #category : #accessing }
Finder >> useRegEx [
	"I should answer a boolean that tells whether regExpression should be taken into account"
	 ^ useRegEx
]

{ #category : #accessing }
Finder >> useRegEx: aBoolean [

	useRegEx := aBoolean
]
