"
I'm a tool to build manifest that handles small lint false positive and other information.

My name is strange but this is to avoid to match with a Manifest class which is recognized because it starts with Manifest*.

"
Class {
	#name : #TheManifestBuilder,
	#superclass : #AbstractTool,
	#instVars : [
		'manifestClass'
	],
	#category : #'Manifest-Core-Base'
}

{ #category : #accessing }
TheManifestBuilder class >> allManifestClasses [

	^ PackageManifest subclasses
]

{ #category : #'accessing - tags' }
TheManifestBuilder class >> falsePositiveBeginningTag [
	"the string that identifies uniquely the beginning of a selector who give  the set of false positive for a rule"
	
	^ 'rule'
]

{ #category : #'accessing - tags' }
TheManifestBuilder class >> falsePositiveEndTag [
	"the string that identifies uniquely the end of a selector who give  the set of false positive for a rule"
	
	^ 'FalsePositive'
]

{ #category : #'accessing - tags' }
TheManifestBuilder class >> falsePositiveMiddleTag [
	"the string that identifies uniquely the middle of a selector who give  the set of false positive for a rule"
	
	^ 'V'
]

{ #category : #'instance creation' }
TheManifestBuilder class >> hasManifestFor: aItem [

	^  (self new manifestOf: aItem) isNil not
		
]

{ #category : #'instance creation' }
TheManifestBuilder class >> hasPackageNamed: aPackageName [

	^ self allManifestClasses 
		anySatisfy: [:each | each category = aPackageName  ]
	
]

{ #category : #'accessing - manifest' }
TheManifestBuilder class >> manifestClassComment [
	
	^ 'Please describe the package using the class comment of the included manifest class. The manifest class also includes other additional metadata for the package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser'
]

{ #category : #'accessing - manifest' }
TheManifestBuilder class >> manifestClassNameFor: aPackageName [
	"Returns a symbol representing a suitable name for a Manifest class for the given package"
	
	^(self manifestTag, (aPackageName select: [:each | each isAlphaNumeric ])) asSymbol
]

{ #category : #'accessing - manifest' }
TheManifestBuilder class >> manifestClassPrefix [
	"Return a string that serves as a prefix for Manifest classes (identifies uniquely the beginning of a Manifest class name)"
	
	^ 'Manifest'
]

{ #category : #'accessing - manifest' }
TheManifestBuilder class >> manifestTag [
	"Return a string that serves as a tag within a package for Manifest classes"
	
	^ 'Manifest'
]

{ #category : #'instance creation' }
TheManifestBuilder class >> of: aItem [
	| mb  |

	mb := self new. 
	(mb manifestOf: aItem) 
			ifNil: [mb createManifestOf: aItem].	
	^ mb	

]

{ #category : #'instance creation' }
TheManifestBuilder class >> ofPackageNamed: aPackageName [
	| builder |
	builder := self new.
	self allManifestClasses
		detect: [ :each | each category = aPackageName ]
		ifFound: [ :manifestClass | builder manifestClass: manifestClass ]
		ifNone: [ builder createManifestNamed: aPackageName ].
	^ builder
]

{ #category : #'accessing - tags' }
TheManifestBuilder class >> rejectClassesTag [
	"the string that identifies uniquely the beginning of a selector who give  the set of rejected classes"
	
	^ 'rejectClasses'
]

{ #category : #'accessing - tags' }
TheManifestBuilder class >> rejectRulesTag [
	"the string that identifies uniquely the beginning of a selector who give  the set of rejected rules"
	
	^ 'rejectRules'
]

{ #category : #'accessing - tags' }
TheManifestBuilder class >> toDoBeginningTag [
	"the string that identifies uniquely the beginning of a selector who give  the set of TODO for a rule"
	
	^ 'rule'
]

{ #category : #'accessing - tags' }
TheManifestBuilder class >> toDoEndTag [
	"the string that identifies uniquely the end of a selector who give  the set of TODO for a rule"
	
	^ 'TODO'
]

{ #category : #'accessing - tags' }
TheManifestBuilder class >> toDoMiddleTag [
	"the string that identifies uniquely the middle of a selector who give  the set of TODO for a rule"
	
	^ 'V'
]

{ #category : #'accessing - tags' }
TheManifestBuilder class >> truePositiveEndTag [
	"the string that identifies uniquely the end of a selector who give  the set of false positive for a rule"
	
	^ 'TruePositive'
]

{ #category : #comparing }
TheManifestBuilder >> = aObject [

	^ aObject class = self class and: [ self manifest = aObject manifest ]
]

{ #category : #'adding/removing' }
TheManifestBuilder >> addAllFalsePositive: fp of: ruleId version: versionId [

	| selector  |	
	selector := self selectorFalsePositiveOf: ruleId version: versionId. 
	self addAllItem: fp selector: selector.
	fp do: [:each |
		 (self containsToDo: each onRule: ruleId version: versionId)
		ifTrue: [ self removeToDo: each of:  ruleId version: versionId ]]
	
]

{ #category : #private }
TheManifestBuilder >> addAllItem: aSet selector: selector [
	| set newSet arrayString |
	set := (self manifest perform: selector) asOrderedCollection.
	newSet := aSet \ (self unwrap: set).
	newSet isEmpty
		ifTrue: [ ^ self ].
	set addAll:
			(newSet
				collect: [ :fp | 
					{(fp asRingDefinition arrayStringForManifest).
					(DateAndTime current asString)} ]).
	arrayString := self buildArrayString: set.
	self compileSelector: selector returnValue: arrayString
]

{ #category : #'adding/removing' }
TheManifestBuilder >> addAllToDo: aSet of: ruleId version: versionId [

	| selector |
	selector := self selectorToDoOf: ruleId version: versionId. 
	self addAllItem: aSet selector: selector. 
]

{ #category : #'adding/removing' }
TheManifestBuilder >> addFalsePositive: fp of: ruleId version: versionId [

	| selector |
	selector := self selectorFalsePositiveOf: ruleId version: versionId. 
	self addItem: fp selector: selector.	
	(self containsToDo: fp onRule: ruleId version: versionId)
		ifTrue: [self removeToDo: fp of:  ruleId version: versionId]. 
]

{ #category : #private }
TheManifestBuilder >> addItem: fp selector: selector [
	self addAllItem: {fp} selector: selector
]

{ #category : #'adding/removing' }
TheManifestBuilder >> addRejectClass: aClass [

	|  falsePositives |
	falsePositives := self manifest rejectClasses asOrderedCollection .
	((self unwrap: falsePositives) anySatisfy: [:each | each = aClass])
		ifTrue: [ ^ self ].
	falsePositives add: {aClass asRingDefinition arrayStringForManifest. DateAndTime current asString}.
	self compileSelector:  (self class rejectClassesTag) returnValue: (self buildArrayString: falsePositives)
	
	
]

{ #category : #'adding/removing' }
TheManifestBuilder >> addRejectRule: ruleId [ 

	|  nfp |	
	nfp := self manifest rejectRules asSet.
	nfp add: ruleId.
	nfp := nfp asArray.
	self compileSelector: (self class rejectRulesTag) returnValue: nfp asString

]

{ #category : #'adding/removing' }
TheManifestBuilder >> addToDo: fp of: ruleId version: versionId [

	| selector |	
	selector := self selectorToDoOf: ruleId version: versionId. 
	self addItem: fp selector: selector.
	(self containsFalsePositive: fp onRule: ruleId version: versionId)
		ifTrue: [ self removeFalsePositive: fp of:  ruleId version: versionId ]
]

{ #category : #'adding/removing' }
TheManifestBuilder >> addTruePositive: fp of: ruleId version: versionId [

	| selector  |	
	selector := self selectorTruePositiveOf: ruleId version: versionId. 
	self addItem: fp selector: selector.
	(self containsToDo: fp onRule: ruleId version: versionId)
		ifTrue: [ self removeToDo: fp of:  ruleId version: versionId ]. 
	(self containsFalsePositive: fp onRule: ruleId version: versionId)
		ifTrue: [ self removeFalsePositive: fp of:  ruleId version: versionId ]

	
	
]

{ #category : #accessing }
TheManifestBuilder >> browsedEnvironment [
	^manifestClass environment 
]

{ #category : #private }
TheManifestBuilder >> buildArrayString: aCollection [
	
	^ String streamContents: [:stream | 
		stream << '#('.
		aCollection do: [:each |  
			stream  nextPutAll: '#('.
			stream nextPutAll: each first printString.
			stream  nextPutAll: ' '.
			stream nextPutAll: (each at: 2) asSymbol  printString.
			stream  nextPutAll: ') '.].
		stream << ')']
]

{ #category : #'adding/removing' }
TheManifestBuilder >> cleanUp [

	| tagfp |
	tagfp := self class falsePositiveBeginningTag.
	self manifest class methodsDo: [ :method |
		(method selector asString beginsWith: tagfp)
				ifTrue: [self removeObsoleteFalsePositiveOf: method] ]
	
	



]

{ #category : #private }
TheManifestBuilder >> compileSelector: selector returnValue: aLiteral [
	self 
		compileSelector: selector
		returnValue: aLiteral
		classified: 'code-critics'
]

{ #category : #private }
TheManifestBuilder >> compileSelector: selector returnValue: aLiteral classified: aProtocolName [
	| source |
	source := String streamContents: [ :stream | 
		stream 
			nextPutAll: selector asString;
			nextPut: Character cr;
			nextPut: Character tab;
			nextPutAll: '^ ';
			nextPutAll: aLiteral ].
	manifestClass class
		compile: source
		classified: aProtocolName
]

{ #category : #manifest }
TheManifestBuilder >> containsFalsePositive: aItem onRule: ruleId version: versionId [

	^  (self hasFalsePositiveOf: ruleId version: versionId) 
			and: [ (self falsePositiveOf: ruleId version: versionId) anySatisfy: [ :fp | fp = aItem ]] 
]

{ #category : #manifest }
TheManifestBuilder >> containsRejectedClass: aClass [
	
	^ self rejectClasses anySatisfy: [ :cl | cl = aClass ]
]

{ #category : #manifest }
TheManifestBuilder >> containsRejectedRule: aRuleId [
	
	^ self rejectRules anySatisfy: [ :fp | fp = aRuleId ]
]

{ #category : #manifest }
TheManifestBuilder >> containsToDo: aItem onRule: ruleId version: versionId [

	^  (self hasToDoOf: ruleId version: versionId) 
		and: [(self toDoOf: ruleId version: versionId) 
			anySatisfy: [ :fp| fp = aItem ]] 
]

{ #category : #manifest }
TheManifestBuilder >> containsTruePositive: aItem onRule: ruleId version: versionId [

	^  (self hasTruePositiveOf: ruleId version: versionId) 
		and: [(self truePositiveOf: ruleId version: versionId) anySatisfy: [ :fp| fp = aItem ]] 
]

{ #category : #manifest }
TheManifestBuilder >> createManifestNamed: packageName [

	manifestClass := self class classInstaller make: [ :aBuilder |
		aBuilder name: (self class manifestClassNameFor: packageName);
			superclass: PackageManifest;
			package: packageName ].
	 
	manifestClass 
		tagWith: self class manifestTag;
		comment: self class manifestClassComment.
	^ manifestClass
]

{ #category : #manifest }
TheManifestBuilder >> createManifestOf: elem [

	self createManifestNamed: (self packageNameOf: elem).
]

{ #category : #private }
TheManifestBuilder >> dateOf: ringobject forSelector: aSelector [

	| critics |

	critics := self manifest perform: aSelector.
	^ ((critics detect: [:each | ((self definitionClassFor: each first first) manifestReadOn: (each first at: 2)) = ringobject ]) at: 2) asDateAndTime
		
		
]

{ #category : #manifest }
TheManifestBuilder >> dateOfFalsePositive: aItem onRule: ruleId version: versionId [

	(self hasFalsePositiveOf: ruleId version: versionId)
		ifFalse: [^ self].
		
	^ self dateOf: ( aItem asRingDefinition) forSelector:  (self selectorFalsePositiveOf: ruleId version: versionId)
		
		
]

{ #category : #manifest }
TheManifestBuilder >> dateOfToDo: aItem onRule: ruleId version: versionId [
	
	 (self hasToDoOf: ruleId version: versionId)
		ifFalse: [^ self].
	^ self dateOf: ( aItem asRingDefinition) forSelector:  (self selectorToDoOf: ruleId version: versionId)
		
		
]

{ #category : #manifest }
TheManifestBuilder >> dateOfTruePositive: aItem onRule: ruleId version: versionId [

	(self hasTruePositiveOf: ruleId version: versionId)
		ifFalse: [^ self].
	^ self dateOf: ( aItem asRingDefinition) forSelector:  (self selectorTruePositiveOf: ruleId version: versionId)
		
		
]

{ #category : #private }
TheManifestBuilder >> definitionClassFor: aName [

	"find Ring definition for a given name. Handle classes renamings"
	
	| finalName |
	
	finalName := (aName = #RGPackage)
		ifTrue: [ #RGPackageDefinition ]
		ifFalse: [ aName ].

	^ self browsedEnvironment at: finalName
]

{ #category : #manifest }
TheManifestBuilder >> falsePositiveOf: ruleId version: versionId [ 

	^ self unwrap: (self manifest perform: (self selectorFalsePositiveOf: ruleId version: versionId))
]

{ #category : #manifest }
TheManifestBuilder >> hasFalsePositiveOf: ruleId version: versionId [
	^ self manifest respondsTo: (self selectorFalsePositiveOf: ruleId version: versionId)
]

{ #category : #manifest }
TheManifestBuilder >> hasToDoOf: ruleId version: versionId [
	^ self manifest respondsTo: (self selectorToDoOf: ruleId version: versionId)  
	
]

{ #category : #manifest }
TheManifestBuilder >> hasTruePositiveOf: ruleId version: versionId [
	^ self manifest respondsTo: (self selectorTruePositiveOf: ruleId version: versionId)  
	
]

{ #category : #comparing }
TheManifestBuilder >> hash [
	^ manifestClass hash bitXor: self class hash
]

{ #category : #manifest }
TheManifestBuilder >> installFalsePositiveOf: ruleId version: versionId [

	self compileSelector: (self selectorFalsePositiveOf: ruleId version: versionId) returnValue: '#()'

]

{ #category : #manifest }
TheManifestBuilder >> installToDoOf: ruleId version: versionId [

	self compileSelector: (self selectorToDoOf: ruleId version: versionId) returnValue: '#()'

]

{ #category : #manifest }
TheManifestBuilder >> installTruePositiveOf: ruleId version: versionId [
	
	self compileSelector: (self selectorTruePositiveOf: ruleId version: versionId) returnValue: '#()'

]

{ #category : #manifest }
TheManifestBuilder >> isFalsePositive: anItem onRule: ruleId version: versionId [
	
	^ ((self containsFalsePositive: anItem onRule: ruleId version: versionId) or:
			[(self containsRejectedRule: ruleId) or:
				[(anItem class = RPackage) not and: [self containsRejectedClass: anItem criticClass]]])
]

{ #category : #accessing }
TheManifestBuilder >> manifest [
	^ manifestClass
]

{ #category : #accessing }
TheManifestBuilder >> manifestClass: aClass [
	 manifestClass := aClass
		

]

{ #category : #accessing }
TheManifestBuilder >> manifestOf: elem [
	^ manifestClass := elem package ifNotNil: [ :package | package packageManifestOrNil ]
]

{ #category : #private }
TheManifestBuilder >> packageNameOf: elem [
	^ elem package name
]

{ #category : #printing }
TheManifestBuilder >> printOn: aStream [

	aStream
		nextPutAll: 'ManifestBuilder of ';
		print: manifestClass .
]

{ #category : #manifest }
TheManifestBuilder >> rejectClasses [
	^ self unwrap: (self manifest rejectClasses)

]

{ #category : #manifest }
TheManifestBuilder >> rejectRules [
	^ self manifest rejectRules
	

]

{ #category : #'adding/removing' }
TheManifestBuilder >> removeAllFalsePositive: aSet of: ruleId version: versionId [

	| selector |
	selector := self selectorFalsePositiveOf:ruleId version: versionId. 
	self removeAllItem: aSet selector: selector.
	
]

{ #category : #private }
TheManifestBuilder >> removeAllItem: aSet selector: selector [
	| set arrayString |
	set := (self manifest perform: selector) asOrderedCollection.
	set := set
		reject: [ :each | 
			| tmp |
			tmp := (self definitionClassFor: each first first) manifestReadOn: (each first at: 2).
			aSet anySatisfy: [ :fp | tmp = fp asRingDefinition ] ].
	arrayString := self buildArrayString: set.
	self compileSelector: selector returnValue: arrayString
]

{ #category : #'adding/removing' }
TheManifestBuilder >> removeAllManifest [
 
	self removeClasses: (self class allManifestClasses)
]

{ #category : #'adding/removing' }
TheManifestBuilder >> removeAllToDo: fp of: ruleId version: versionId [
	
	| selector |
	selector := self selectorToDoOf: ruleId version: versionId. 
	self removeAllItem: fp selector: selector.
	
]

{ #category : #'adding/removing' }
TheManifestBuilder >> removeFalsePositive: fp of: ruleId version: versionId [
	
	| selector |
	selector := self selectorFalsePositiveOf: ruleId version: versionId. 
	self removeItem: fp selector: selector.
	
	
]

{ #category : #private }
TheManifestBuilder >> removeItem: fp selector: selector [
	self removeAllItem: {fp} selector: selector
]

{ #category : #'adding/removing' }
TheManifestBuilder >> removeManifestOf: aItem [
	
	(self manifestOf: aItem) ifNotNil: [ :myManifest | 
			self removeClass: myManifest  ]
]

{ #category : #private }
TheManifestBuilder >> removeObsoleteFalsePositiveOf: aMethod [

	| set arrayString  |
	set := (self manifest perform: aMethod selector) asOrderedCollection.
	set := set select: [ :each | ((self definitionClassFor: each first first) manifestReadOn:  (each first at: 2)) isDefined ].
	arrayString := self buildArrayString: set.
	self compileSelector: aMethod selector returnValue: arrayString
	
]

{ #category : #'adding/removing' }
TheManifestBuilder >> removeRejectClass: aClass [

	|  classes |
	classes :=  self manifest rejectClasses asOrderedCollection.
	classes := classes reject: [ :each | 
			((self definitionClassFor: each first first) manifestReadOn:  (each first at: 2)) =  aClass asRingDefinition ].	
	self compileSelector: (self class rejectClassesTag) returnValue:  (self buildArrayString: classes)
	
]

{ #category : #'adding/removing' }
TheManifestBuilder >> removeRejectRule: ruleId [ 

	|  nfp |	
	nfp := self manifest rejectRules asOrderedCollection.
	nfp remove: ruleId ifAbsent: [^ self].
	nfp := nfp asArray.
	self compileSelector: (self class rejectRulesTag) returnValue:   nfp asString

	
]

{ #category : #'adding/removing' }
TheManifestBuilder >> removeToDo: fp of: ruleId version: versionId [
	
	| selector |
	selector := self selectorToDoOf:ruleId version: versionId. 
	self removeItem: fp selector: selector.
	
]

{ #category : #'adding/removing' }
TheManifestBuilder >> resetFalsePositiveOf: ruleId version: versionId [
 
	self  installFalsePositiveOf: ruleId version: versionId. 
]

{ #category : #'adding/removing' }
TheManifestBuilder >> resetToDoOf: ruleId version: versionId [
 	
	self installToDoOf: ruleId version: versionId. 
]

{ #category : #private }
TheManifestBuilder >> selectorFalsePositiveOf: ruleId version: versionId [

	^ (self class falsePositiveBeginningTag, ruleId,
		self class falsePositiveMiddleTag, versionId asString,
		self class falsePositiveEndTag) 
			asSymbol.
]

{ #category : #private }
TheManifestBuilder >> selectorToDoOf: ruleId version: versionId [

	^ (self class toDoBeginningTag, ruleId ,
		self class toDoMiddleTag, versionId asString,
		self class toDoEndTag) asSymbol.
]

{ #category : #private }
TheManifestBuilder >> selectorTruePositiveOf: ruleId version: versionId [

	^ (self class falsePositiveBeginningTag, ruleId ,
		self class falsePositiveMiddleTag, versionId asString,
		self class truePositiveEndTag) 
		asSymbol.
]

{ #category : #manifest }
TheManifestBuilder >> toDoOf: ruleId version: versionId [ 

	^ self unwrap: (self manifest perform: (self selectorToDoOf: ruleId version: versionId))
]

{ #category : #manifest }
TheManifestBuilder >> truePositiveOf: ruleId version: versionId [ 

	^ self unwrap: (self manifest perform: (self selectorTruePositiveOf: ruleId version: versionId))
]

{ #category : #private }
TheManifestBuilder >> unwrap: aCollection [

	| unwrapCollection rgobject |
	
	unwrapCollection := OrderedCollection new.
	aCollection
		do: [ :each | 
			rgobject := (self definitionClassFor: each first first) manifestReadOn:  (each first at: 2).
			(rgobject isClass and: [ rgobject  realClass notNil ])
				ifTrue: [ unwrapCollection add: rgobject realClass ].
			(rgobject isMethod and: [ rgobject method notNil ])
				ifTrue: [ unwrapCollection add: rgobject method ].
			(rgobject isPackage and: [ rgobject realPackage notNil ])
				ifTrue: [ unwrapCollection add: rgobject realPackage ] ].
	^ unwrapCollection
]
