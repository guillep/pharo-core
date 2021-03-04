Extension { #name : #ClyBrowserMorph }

{ #category : #'*Calypso-SystemTools-Core' }
ClyBrowserMorph >> confirmEmptySystemQuery: aQuery [
	
	| showResult result |
	
	result := aQuery execute.
	result isEmpty ifTrue: [ ^true ].
	
	showResult := UIManager default confirm: 'There are '
		, result size asString, ' ', aQuery description, '. Show them?'.
	showResult ifTrue: [self spawnQueryBrowserOn: aQuery].
	^false
]

{ #category : #'*Calypso-SystemTools-Core' }
ClyBrowserMorph >> confirmEmptySystemQuery: aQuery excluding: classes [
	
	| showResult result |
	
	result := aQuery execute.
	(result isEmpty or: [ ((result items collect: [:each | each origin]) difference: classes ) isEmpty]) ifTrue: [ ^true ].
	
	showResult := UIManager default confirm: 'There are '
		, result size asString, ' ', aQuery description, '. Show them?'.
	showResult ifTrue: [self spawnQueryBrowserOn: aQuery].
	^false
]

{ #category : #'*Calypso-SystemTools-Core' }
ClyBrowserMorph >> confirmUnusedClasses: classes [
	
	| refQuery noUsers answer subclasses users |
	
	refQuery := ClyClassReferencesQuery toAny: classes from: self systemScope.	
	"we need to exclude both the class and instance side of the class"
	noUsers := self confirmEmptySystemQuery: refQuery excluding: (classes flatCollect: [ :each | { each . each classSide } ]).
	
	subclasses := (classes flatCollect: [:each | each subclasses]) copyWithoutAll: classes.
	subclasses ifNotEmpty: [ 
		noUsers := false.
		answer := UIManager default confirm: 'There are subclasses. Show them?'.
		answer ifTrue: [ self spawnQueryBrowserOn: (ClyConstantQuery returning: subclasses) ] ].
	
	users := (classes flatCollect: [:each | each users]) copyWithoutAll: classes.
	users ifNotEmpty: [ 
		noUsers := false.
		answer := UIManager default confirm: 'There are users of trait. Show them?'. 
		answer ifTrue: [ self spawnQueryBrowserOn: (ClyConstantQuery returning: users) ]].
	
	^noUsers
]

{ #category : #'*Calypso-SystemTools-Core' }
ClyBrowserMorph >> confirmUnusedVariables: variables [
	
	| refQuery |
	refQuery := ClyVariableReferencesQuery ofAny: variables from: self systemScope.
	
	^self confirmEmptySystemQuery: refQuery
]

{ #category : #'*Calypso-SystemTools-Core' }
ClyBrowserMorph >> confirmUnusedVariablesInDefiningClass: variables [
	
	| refQuery classScope |
	classScope := ClyBothMetaLevelClassScope ofAll: (variables collect: [:each | each definingClass]) in: navigationEnvironment. 
	refQuery := ClyVariableReferencesQuery ofAny: variables from: classScope.
	
	^self confirmEmptySystemQuery: refQuery
]

{ #category : #'*Calypso-SystemTools-Core' }
ClyBrowserMorph >> decorateMethodEditor: aMethodEditor [
]

{ #category : #'*Calypso-SystemTools-Core' }
ClyBrowserMorph >> isMethodSelected: aMethod [

	^self methodSelection includesActualObject: aMethod
]

{ #category : #'*Calypso-SystemTools-Core' }
ClyBrowserMorph >> requestRemoveClassStrategyFor: classes [

	| result strategies title |
	strategies := SycRemoveClassStrategy
		              createAllForClasses: classes
		              browser: self.

	strategies size = 1 ifTrue: [ ^ strategies anyOne ].

	title := classes size = 1
		         ifTrue: [ 'Class has references, subclasses, or users' ]
		         ifFalse: [ 'Classes have references, subclasses, or users' ].

	result := UIManager default
		          chooseFrom:
		          (strategies collect: [ :each | each userRequestString ])
		          values: strategies
		          title: title.

	^ result ifNil: [ SycNotRemoveClassStrategy new ]
]

{ #category : #'*Calypso-SystemTools-Core' }
ClyBrowserMorph >> requestRemoveMethodStrategyFor: methods [

	| selectors result strategies title |
	selectors := (methods
		              collect: [ :each | each selector ]
		              as: IdentitySet) asArray.

	strategies := SycRemoveMethodStrategy
		              createAllForMethods: methods
		              browser: self.
	strategies size = 1 ifTrue: [ ^ strategies anyOne ].

	title := selectors size > 1
		         ifTrue: [ 'Methods have senders' ]
		         ifFalse: [ 
		         'Method #{1} has sender{s' format: { selectors anyOne } ].

	result := UIManager default
		          chooseFrom:
		          (strategies collect: [ :each | each userRequestString ])
		          values: strategies
		          title: title.

	^ result ifNil: [ SycNotRemoveMethodStrategy new ]
]
