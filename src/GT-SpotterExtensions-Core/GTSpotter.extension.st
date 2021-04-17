Extension { #name : #GTSpotter }

{ #category : #'*GT-SpotterExtensions-Core-private' }
GTSpotter >> concreteMethodsInContext: aContext usingFilter: aFilter [
	" return the concrete methods described by the expression (Class >> #Selector) - evaluate it savely "
	| classAndSelectorStrings class selector |
	classAndSelectorStrings := (aContext textTrimmed splitOn: '>>') collect: [ :each | each trimBoth ].
	
	" check preconditions "
	classAndSelectorStrings size = 2 ifFalse: [ ^ self ].
	classAndSelectorStrings second size < 2 ifTrue: [ ^ self ].

	" retrieve concrete class and selector - or saerch all behaviors "
	selector := classAndSelectorStrings second first = $# 
		ifTrue: [ classAndSelectorStrings second allButFirst asSymbol ]
		ifFalse: [ classAndSelectorStrings second asSymbol ].
	
	(class := Smalltalk classNamed: classAndSelectorStrings first) ifNil: [ 
		SystemNavigation default allBehaviorsDo: [ :aClass |
			aClass methodsDo: [ :method |
				method selector = selector ifTrue: [ aFilter value: method ] ] ].
		^ self ].
	
	
	" retrieve the compiled method in the class and class hierarchy "
	class withAllSuperclassesDo: [ :aClass |
		aFilter value: ([ aClass compiledMethodAt: selector ] on: Error do: [ ^ self ]) ]
]

{ #category : #'*GT-SpotterExtensions-Core-private' }
GTSpotter >> evaluateExpressionInContext: aSpotterContext usingFilter: filter [
	" only allow arithmethic selectors to be evaluated - otherwise this may have some severe side-effects "
	| result |
	" filter allowed selectors "
	(Number withAllSubclasses anySatisfy: [ :class |
		class selectors anySatisfy: [ :selector | 
			aSpotterContext textTrimmed includesSubstring: selector caseSensitive: true ] ]) ifFalse: [ ^ self ].
	" perform the selector "
	Smalltalk compiler 
		silentlyDo: [ result := Smalltalk compiler evaluate: aSpotterContext textTrimmed ] 
		exceptionDo: [ ^ self ].
	result isNumber ifFalse: [ ^ self ].
	filter value: result. 
	" if the result is not readable as float, append the float as well "
	(result isFraction and: [ result isInteger not ]) ifTrue: [
		filter value: result asFloat ]
]

{ #category : #'*GT-SpotterExtensions-Core-private' }
GTSpotter >> fileReferencesBy: aSelector inContext: aSpotterContext usingFilter: aBlock [
	| split rootDirectory query |
	split := aSpotterContext textLowercase piecesCutWhere: [ :a :b | a = FileSystem disk delimiter ].
	rootDirectory := split size < 1
		ifTrue: [ query := aSpotterContext textLowercase.
			FileSystem workingDirectory ]
		ifFalse: [ (split last last = FileSystem disk delimiter
				ifTrue: [ query := ''.
					aSpotterContext textLowercase ]
				ifFalse: [ query := split last.
					'' join: split allButLast ]) asFileReference ].
	rootDirectory ifAbsent: [ ^ self ].
	self flag: 'this is an ugly hack for #queryForFileReference. This iterator has to manipulate the query in order for the filter to work properly'.
	aSpotterContext cacheAt: #queryForFileReference put: query.
	(rootDirectory perform: aSelector) do: aBlock
]
