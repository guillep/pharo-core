"
I am an abstract critique class.

A critique links a quality rule to a source code target. It is the main unit that should be used to provide information to the user.

I specialize the ReProperty class by extracting information from the rule that reported the violation. 
The #title is extracted from the rule's #name, the #icon based on the rule's #severity and a #description is provided based on the rule's #rationale.

A critique has the #providesChange method which returns a boolean value specifying whether the critique can provide a change which will resolve the issue. The #change method can be used to obtain an object of RBRefactoryChange kind.

The reference to the critized entity is established through ReSourceAnchor.
A critique has a reference to the criticized entity.

This link is established through ReSourceAnchor. A source anchor has a reference to the actual class, method, or other entity that is criticized. An anchor also has a #providesInterval method that returns a boolean indicating if the anchor provides a selection interval to the actual source of the critique. The interval can be accessed through the #interval method.

There are two subclasses of ReSourceAnchor.
ReIntervalSourceAnchor stores the actual interval object which is set during initialization.
ReSearchStringSourceAnchor stores a searchString which will be searched for in the entities source code on demand to find an interval of substring
"
Class {
	#name : #ReAbstractCritique,
	#superclass : #ReProperty,
	#instVars : [
		'rule',
		'tinyHint'
	],
	#category : #'Renraku-Critiques'
}

{ #category : #'instance creation' }
ReAbstractCritique class >> for: anEntity by: aRule [

	^ self basicNew
		initializeRule: aRule
		target: anEntity;
		yourself
]

{ #category : #testing }
ReAbstractCritique class >> isAbstract [ 

	^self == ReAbstractCritique
]

{ #category : #'instance creation' }
ReAbstractCritique class >> withAnchor: anAnchor by: aRule [

	^ self basicNew
		initializeRule: aRule
		sourceAnchor: anAnchor;
		yourself
]

{ #category : #'special instance creation' }
ReAbstractCritique class >> withAnchor: anAnchor by: aRule hint: aString [

	^ (self
		withAnchor: anAnchor
		by: aRule)
		tinyHint: aString;
		yourself
]

{ #category : #actions }
ReAbstractCritique >> actions [ 

	| actions |
	
	actions := OrderedCollection new: 3.

	actions add: (RePropertyAction new
			icon: (self iconNamed: #smallQuestionIcon);
			description: 'View rationale behind the rule';
			action: [ :crit |
				crit popDescriptionUp.
				ReSystemAnnouncer uniqueInstance
					notifyCritique: crit
					descriptionViewedFor: crit sourceAnchor entity ];
			yourself).
	
	self providesChange ifTrue: [ 
		actions add: (RePropertyAction new
			icon: (self iconNamed: #repairIcon);
			description: 'Automatically resolve the issue';
			action: [ :crit |
				| changesBrowser |
				
				changesBrowser := (ChangesBrowser changes: { crit change })
					extent: 500@400;
					setModal: SystemWindow topWindow;
					yourself.
					
				changesBrowser openDialogWithSpec
					okAction: [ changesBrowser accept ];
					centered ];
			yourself) ].
	
	actions add: (RePropertyAction new
			icon: (self iconNamed: #smallCancelIcon);
			description: 'Ban this rule';
			action: [ :crit | crit guidedBan ];
			yourself).

	^ actions
]

{ #category : #actions }
ReAbstractCritique >> ban [
	self entity ban: self
]

{ #category : #accessing }
ReAbstractCritique >> change [
	
	^ self subclassResponsibility 
]

{ #category : #accessing }
ReAbstractCritique >> color [

	^ ({
	#error -> Color red .
	#warning -> Color yellow .
	#information -> Color blue
	 } asDictionary at: rule severity ifAbsent: [ super color ]) alpha: 0.1

]

{ #category : #accessing }
ReAbstractCritique >> description [
	^ rule rationale
]

{ #category : #actions }
ReAbstractCritique >> guidedBan [

	ReCriticEngine guidedBy: self entity  ban: self
]

{ #category : #accessing }
ReAbstractCritique >> icon [

	^ self iconNamed: ('small', rule severity capitalized, 'Icon') asSymbol
]

{ #category : #initialization }
ReAbstractCritique >> initializeRule: aRule sourceAnchor: anAnchor [

	self initializeSourceAnchor: anAnchor.
	rule := aRule.
]

{ #category : #initialization }
ReAbstractCritique >> initializeRule: aRule target: anEntity [

	self
		initializeRule: aRule
		sourceAnchor: (ReSourceAnchor entity: anEntity)
]

{ #category : #testing }
ReAbstractCritique >> isCritique [
	^ true
]

{ #category : #actions }
ReAbstractCritique >> popDescriptionUp [
	UIManager default longMessage: self description title: self title
]

{ #category : #printing }
ReAbstractCritique >> printOn: aStream [

	super printOn: aStream.
	aStream nextPutAll: ' (', self title, ')'
]

{ #category : #actions }
ReAbstractCritique >> provideNegativeFeedback: aComment [
	ReFeedbacker negativeFeedback: aComment about: self
]

{ #category : #actions }
ReAbstractCritique >> providePositiveFeedback: aComment [
	ReFeedbacker positiveFeedback: aComment about: self
]

{ #category : #testing }
ReAbstractCritique >> providesChange [

	^ self subclassResponsibility 
]

{ #category : #accessing }
ReAbstractCritique >> rule [
	^ rule
]

{ #category : #accessing }
ReAbstractCritique >> tinyHint [

	^ tinyHint
]

{ #category : #accessing }
ReAbstractCritique >> tinyHint: anObject [
	tinyHint := anObject
]

{ #category : #accessing }
ReAbstractCritique >> title [
	^ (self tinyHint isNil or: [ self tinyHint isEmpty ])
		ifTrue: [ rule name ]
		ifFalse: [
			String streamContents: [ :s |
				s
					nextPut: $[;
					nextPutAll: self tinyHint;
					nextPutAll: '] ';
					nextPutAll: rule name ] ]
]
