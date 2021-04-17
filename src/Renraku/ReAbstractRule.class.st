"
I am the root of all quality rules rules.

Each rule should provide a short name string returned from the #name method. You also have to override the #rationale method to return a detailed description about the rule. You may also put the rationale in the class comment, as by default #rationale method returns the comment of the rule's class.

The class-side methods #checksMethod, #checksClass, #checksPackage and #checksNode return true if the rule checks methods, classes or traits, packages and AST nodes respectively. Tools will pass entities of the specified type to the rule for checking. 

To check the rule, while there is a default implementation which relies on #basicCheck: and creates an instance of ReTrivialCritique, it is advised to override the #check:forCritiquesDo: method. 

It's a good idea to assign your rule to a specific group. For this override the #group method and return string with the name of the group. While you can use any name you want, maybe you would like to put your rule into one of the existing groups: API Change, API Hints, Architectural, Bugs, Coding Idiom Violation, Design Flaws, Optimization, Potential Bugs, Rubric, SUnit, Style, Unclassified rules.

You can also specify the severity of your rue by returning one of: #information, #warning, or #error symbols from the #severity method.



It is fairly easy to run your rule and obtain the results. Just create an instance of it an send it the #check: message with the entity you want to check. The result is a collection of critiques. For example inspecting

	RBExcessiveMethodsRule new check: Object

should give you a collection with one critique (because the Object class always has many methods ;) ). Go on click on the critique item and inspect it. You will see that there is a special ""description"" tab. This is the power of critique objects, they can present themselves in a different way. Guess what: you can even visualize the critique if needed.


To have quality assistant (and maybe other tools) pick up your changes you have to reset the cache. Do this by going to System > Settings > Code Browsing > QualityAssistant > Renraku > Rule Cache
and pressing the reset button. Or simply executing  ReRuleManager reset


When you load complete rules into the system, the cache will be reset automatically. But as you are creating a new rule and it is in the incomplete state you have to reset the cache once you are ready.

If you want to learn more about the features of rules or how to create your own, please read:

RenrakuRuleHelp readInHelpBrowser
"
Class {
	#name : #ReAbstractRule,
	#superclass : #Object,
	#classInstVars : [
		'enabled'
	],
	#category : #'Renraku-Rules'
}

{ #category : #'testing - interest' }
ReAbstractRule class >> checksClass [
	"Not checking a class by default - but subclasses should return true when the receiver rule checks on class level."
	
	^ false
]

{ #category : #'testing - interest' }
ReAbstractRule class >> checksMethod [
	"Not checking a method by default - but subclasses should return true when the receiver rule checks on method level."
	
	^ false
]

{ #category : #'testing - interest' }
ReAbstractRule class >> checksNode [
	"Not checking a node by default - but subclasses should return true when the receiver rule checks on AST node level."
	
	^ false
]

{ #category : #'testing - interest' }
ReAbstractRule class >> checksPackage [
	"Not checking a package by default - but subclasses should return true when the receiver rule checks on package level."
	
	^ false
]

{ #category : #accessing }
ReAbstractRule class >> enabled [

	^ enabled ifNil: [ enabled := true ]
]

{ #category : #accessing }
ReAbstractRule class >> enabled: aBoolean [

	enabled := aBoolean.
	ReRuleManager reset
]

{ #category : #accessing }
ReAbstractRule class >> enabledSettingID [

	^ (self name, '_enabled') asSymbol
]

{ #category : #manifest }
ReAbstractRule class >> identifierMinorVersionNumber [
	"This number identifies the version of the rule definition. Each time the rule is updated and its changes invalidates previous false positives identification (and as such should be reassessed by developers) the number should be increased."

	^ 1
]

{ #category : #testing }
ReAbstractRule class >> isAbstract [

	^ self = ReAbstractRule
]

{ #category : #manifest }
ReAbstractRule class >> isBeginnerRule [

	^ false
]

{ #category : #manifest }
ReAbstractRule class >> isDefaultRule [

	^ true
]

{ #category : #testing }
ReAbstractRule class >> isUsed [
	"all my sublasses are used"
	
	^self name = 'ReAbstractRule'
		ifTrue: [ super isUsed ]
		ifFalse: [ true ]
]

{ #category : #testing }
ReAbstractRule class >> isVisible [
	
	^ self methodOfInteresetSelectors anySatisfy: [ :selector |
		self perform: selector ]
]

{ #category : #properties }
ReAbstractRule class >> methodOfInteresetSelectors [

	^ #(checksMethod checksClass checksPackage checksNode)
]

{ #category : #manifest }
ReAbstractRule class >> uniqueIdentifierName [
	"This number should be unique and should change only when the rule completely change semantics"
	
	^ self name
]

{ #category : #manifest }
ReAbstractRule class >> uniqueIdentifierNumber [
	"This number should be unique and should change only when the rule completely change semantics"
	^ 0
]

{ #category : #helpers }
ReAbstractRule >> anchorFor: anEntity [

	^ ReSourceAnchor entity: anEntity
]

{ #category : #running }
ReAbstractRule >> basicCheck: anEntity [
	"If you end here, you should most likely implement this in a subclass"
	
	^ self shouldBeImplemented  
]

{ #category : #running }
ReAbstractRule >> check: anEntity [

	| critiques |
	critiques := OrderedCollection new.
	self
		check: anEntity
		forCritiquesDo: [ :critique | critiques add: critique ].
	^ critiques
]

{ #category : #running }
ReAbstractRule >> check: anEntity forCritiquesDo: aCriticBlock [
	"Accepts an entity and a block which could be evaluated for each detected critique
	aCriticBlock may accept one argument: the critique object"
	
	(self basicCheck: anEntity)
		ifTrue: [ aCriticBlock cull: (self critiqueFor: anEntity) ]
]

{ #category : #running }
ReAbstractRule >> check: anEntity forCritiquesDo: aCriticBlock ifNone: alternativeBlock [

	| encounteredCritique |
	encounteredCritique := false.

	self check: anEntity forCritiquesDo: [ :crit | 
		encounteredCritique := true.
		aCriticBlock cull: crit ].

	encounteredCritique ifFalse: alternativeBlock
]

{ #category : #running }
ReAbstractRule >> check: anEntity ifNoCritiques: alternativeBlock [

	| critiques |
	critiques := OrderedCollection new.
	self
		check: anEntity
		forCritiquesDo: [ :critique | critiques add: critique ]
		ifNone: alternativeBlock.
	^ critiques
]

{ #category : #utilities }
ReAbstractRule >> createTrivialCritiqueOn: method intervalOf: node hint: hint [

	^ ReTrivialCritique
		  withAnchor:
		  (ReIntervalSourceAnchor
			   entity: method
			   interval: node sourceInterval)
		  by: self
		  hint: hint
]

{ #category : #helpers }
ReAbstractRule >> critiqueFor: anEntity [

	^ ReTrivialCritique
		withAnchor: (self anchorFor: anEntity)
		by: self
]

{ #category : #'running-helpers' }
ReAbstractRule >> critiqueFor: aClass about: aVarName [

	| crit |
	crit := ReTrivialCritique
		withAnchor: (ReVarSearchSourceAnchor
			entity: aClass
			string: aVarName)
		by: self.
	crit tinyHint: aVarName.	
	^ crit
]

{ #category : #accessing }
ReAbstractRule >> group [

	^ 'Unclassified rules'
]

{ #category : #testing }
ReAbstractRule >> isComposite [

	^ false
]

{ #category : #testing }
ReAbstractRule >> isRewriteRule [

	^ false
]

{ #category : #accessing }
ReAbstractRule >> name [
	"Answer a human readable name of the rule."

	^ self subclassResponsibility
]

{ #category : #accessing }
ReAbstractRule >> rationale [
	"Answer an explanation of the rule, usually in one line. Long description can be obtained using longDescription."

	^ self class comment
]

{ #category : #compatibility }
ReAbstractRule >> resetResult [
]

{ #category : #accessing }
ReAbstractRule >> severity [
	"Answer the severity of issues reported by this rule. This method should return one of #error, #warning, or #information."

	^ #warning
]
