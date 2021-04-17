"
I represent a special dictionary used as global namespace for class names :

	Smalltalk globals classNames.

and for traits too:

	Smalltalk globals traitNames.
	
and a few other globals:

	(Smalltalk globals keys
		reject: [ :k | 
			| g |
			g := Smalltalk globals at: k.
			g isBehavior or: [ g isTrait ] ]) collect: [ :k | k -> (Smalltalk globals at: k) class ].

As the above example let you guess, the global namespace of Smalltalk system is accessed through:

	Smalltalk globals.
"
Class {
	#name : #SystemDictionary,
	#superclass : #IdentityDictionary,
	#instVars : [
		'cachedClassNames',
		'cachedNonClassNames',
		'cachedBehaviors',
		'reservedVariables'
	],
	#category : #'System-Support-Utilities'
}

{ #category : #'instance creation' }
SystemDictionary class >> withOrganizer: anOrganizer [
	| dictionary |
	dictionary := self new.
	dictionary organization: anOrganizer. "update too the back pointer"
	^dictionary.
	
]

{ #category : #'classes and traits' }
SystemDictionary >> allBehaviors [
	"Return all the classes and traits defined in the Smalltalk SystemDictionary"
	^cachedBehaviors ifNil: [cachedBehaviors := self allClassesAndTraits flatCollect: [:each | {each . each classSide} ]]
]

{ #category : #'classes and traits' }
SystemDictionary >> allBehaviorsDo: aBlock [
	"Execute a block on each class, metaclass, trait and trait class"

	self allBehaviors do: aBlock
]

{ #category : #'classes and traits' }
SystemDictionary >> allClasses [  
	"Return all the class defines in the Smalltalk SystemDictionary"

	^ self classNames collect: [:name | self at: name]
]

{ #category : #'classes and traits' }
SystemDictionary >> allClassesAndTraits [
	"Return all the classes and traits defined in the Smalltalk SystemDictionary"

	^ self classAndTraitNames collect: [:each | self at: each]
]

{ #category : #'classes and traits' }
SystemDictionary >> allClassesAndTraitsDo: aBlock [
	"Evaluate the argument, aBlock, for each class and trait in the system."
	
	^self classAndTraitNames do: [:each | aBlock value: (self at: each)]
	
	

]

{ #category : #'classes and traits' }
SystemDictionary >> allClassesDo: aBlock [
	"Evaluate the argument, aBlock, for each class in the system."

	^self classNames do: [:name | aBlock value: (self at: name)]
]

{ #category : #'classes and traits' }
SystemDictionary >> allMethods [
	^ self allBehaviors flatCollect: [ :behavior | behavior methods ]
]

{ #category : #'classes and traits' }
SystemDictionary >> allTraits [
	"Return all traits defined in the Smalltalk SystemDictionary"

	^ self traitNames collect: [:each | self at: each]
]

{ #category : #'classes and traits' }
SystemDictionary >> allTraitsDo: aBlock [
	"Evaluate the argument, aBlock, for each trait in the system."

	^self traitNames do: [:name | aBlock value: (self at: name)]
]

{ #category : #'dictionary access' }
SystemDictionary >> at: aKey put: anObject [ 
	"Override from Dictionary to check Undeclared and fix up
	references to undeclared variables."
	
	(self includesKey: aKey) ifFalse: 
		[self declare: aKey from: Undeclared.
		self flushClassNameCache].
	super at: aKey put: anObject.
	^ anObject
]

{ #category : #'variable lookup' }
SystemDictionary >> bindingOf: varName [
	"SystemDictionaries includes symbols only"
	
	^ super bindingOf: varName asSymbol
]

{ #category : #'class and trait names' }
SystemDictionary >> classAndTraitNames [
	"Answer a sorted collection of all class and trait (not including class-traits) names. 
	Now traits are normal classes. So they are in same class list.
	Do not bother to sort"

	
	^self classNames
	
]

{ #category : #'classes and traits' }
SystemDictionary >> classNamed: className [ 
	^self classOrTraitNamed: className.
]

{ #category : #'class and trait names' }
SystemDictionary >> classNames [
	"Answer a sorted collection of all class names. Use the return value of #fillCaches to avoid concurrency issues."
	
	^cachedClassNames ifNil: [ self fillCaches at: 1 ]
]

{ #category : #'classes and traits' }
SystemDictionary >> classOrTraitNamed: aString [
	"aString is either a class or trait name or a class or trait name followed by ' class' or 'classTrait' respectively.
	Answer the class or metaclass it names."

	| meta baseName |
	(aString endsWith: ' class')
		ifTrue: [ 
			meta := true.
			baseName := aString copyFrom: 1 to: aString size - 6 ]
		ifFalse: [ 
			(aString endsWith: ' classTrait')
				ifTrue: [ 
					meta := true.
					baseName := aString copyFrom: 1 to: aString size - 11 ]
				ifFalse: [ 
					meta := false.
					baseName := aString ] ].
	^self at: baseName asSymbol ifPresent:
            [ :global |
               (global isBehavior or: [global isTrait])ifTrue:
                       [ meta
                               ifFalse: [ global ]
                               ifTrue: [ global classSide ]]]
]

{ #category : #removing }
SystemDictionary >> defineClass: aDefinition withController: aController [

	^ self class compiler
		source: aDefinition;
		requestor: aController;
		logged: true;
		evaluate
]

{ #category : #accessing }
SystemDictionary >> environment [
	"for conversion from SmalltalkImage to SystemDictionary"
	
	^ self 
]

{ #category : #'class and trait names' }
SystemDictionary >> fillCaches [
	"Fill cachedClassNames and cachedNonClassNames. Return an array with the calculated values."

	| classNames nonClassNames |
	classNames := OrderedCollection new: self size.
	nonClassNames := OrderedCollection new.
	self keysAndValuesDo: [ :key :value |
		"The key == value name test below addresses two separate issues:
			1) Obsolete classes, where key = #Foo and value name = 'AnObsoleteFoo'
			2) Aliases, i.e., Smalltalk at: #OtherName put: aClass"
		((value isKindOf: (self class environment at: #Class)) and: [ key == value name ])
			ifTrue: [ classNames add: key ]
			ifFalse: [ nonClassNames add: key ] ].
		"The expression (self class environment at: #Class) deserves some explanation.
		For bootstrapping we need to have a different Class when executing value isKindOf: Class :
		In such expression Class represents a kind of fixed point: the class of the class of the system. 
		When bootstrapping we want the class Class of the current kernel defined in the current namespace.
		Since the current namespace should contains the class that describes itself as well as a new Class class.
		we are done :)."
	
	
	"The cached names are sorted to allow for a very efficient hasBindingThatBeginsWith: check"	
	cachedClassNames := classNames sort.
	cachedNonClassNames := nonClassNames sort.
	^{ classNames. nonClassNames }
]

{ #category : #'class and trait names' }
SystemDictionary >> flushClassNameCache [
	"Force recomputation of the cached list of class names and non-class names."

	<script: 'Smalltalk flushClassNameCache'>
	cachedClassNames := cachedNonClassNames := cachedBehaviors := nil
]

{ #category : #'classes and traits' }
SystemDictionary >> forgetClass: aClass logged: aBool [
	"Delete the class, aClass, from the system.
	Note that this doesn't do everything required to dispose of a class - to do that use Class>>removeFromSystem."

	self organization removeElement: aClass name.
	SessionManager default unregisterClassNamed: aClass name.
	self removeKey: aClass name ifAbsent: [  ]
]

{ #category : #testing }
SystemDictionary >> hasBindingThatBeginsWith: aString [

	"Use the cached class and non-class names for better performance."

	| name searchBlock |
	(self reservedVariables hasBindingThatBeginsWith: aString) ifTrue: [ ^true ].
	searchBlock := [ :element |
		(element beginsWith: aString)
			ifTrue: [ 0 ]
			ifFalse: [
				aString < element
					ifTrue: [ -1 ]
					ifFalse: [ 1 ] ] ].
	name := self classNames 
		findBinary: searchBlock
		ifNone: [nil].
	name ifNotNil: [ ^true ].
	name := self nonClassNames 
		findBinary: searchBlock
		ifNone: [nil].
	^name notNil
]

{ #category : #'classes and traits' }
SystemDictionary >> hasClassNamed: aString [
	"Answer whether there is a class of the given name, but don't intern aString if it's not alrady interned."

	Symbol 
		hasInterned: aString 
		ifTrue:  [:aSymbol | ^ (self at: aSymbol ifAbsent: [nil]) isClass].
	^ false
]

{ #category : #'classes and traits' }
SystemDictionary >> hasClassOrTraitNamed: aString [
	"Answer whether there is a class of the given name, but don't intern aString if it's not alrady interned."

	Symbol 
		hasInterned: aString 
		ifTrue:  [:aSymbol | ^ (self at: aSymbol ifAbsent: [nil]) isClassOrTrait].
	^ false
]

{ #category : #'variable lookup' }
SystemDictionary >> lookupVar: name [
	"Return a var with this name.  Return nil if none found"
	^self reservedVariables at: name ifAbsent: [self bindingOf: name]
]

{ #category : #'system attributes' }
SystemDictionary >> maxIdentityHash [
	"Answer the maximum identityHash value supported by the VM."
	<primitive: 176>
	^self primitiveFailed
]

{ #category : #'class and trait names' }
SystemDictionary >> nonClassNames [
	"Answer a sorted collection of all non-class names. Use the return value of #fillCaches to avoid concurrency issues."
	
	^cachedNonClassNames ifNil: [ self fillCaches at: 2 ]
]

{ #category : #accessing }
SystemDictionary >> organization [
	"Return the organizer for the receiver"
	
	^ self at: #SystemOrganization ifAbsent: nil
]

{ #category : #accessing }
SystemDictionary >> organization: anOrganization [
	"Return the organizer for the receiver"
	
	anOrganization environment: self.
	^self at: #SystemOrganization put: anOrganization
]

{ #category : #'variable lookup' }
SystemDictionary >> outerScope [
	^nil
]

{ #category : #accessing }
SystemDictionary >> poolUsers [
	"Answer a dictionary of pool name -> classes that refer to it.
	Also includes any globally know dictionaries (such as
	Smalltalk, Undeclared etc) which although not strictly
	accurate is potentially useful information"

	"Smalltalk globals poolUsers"

	| poolUsers |
	poolUsers := Dictionary new.
	self
		keysDo: [ :k | 
			| pool refs |
			"yes, using isKindOf: is tacky but for reflective code like
			this it is very useful. If you really object you can:-
			a) go boil your head.
			b) provide a better answer.
			your choice."
			(((pool := self at: k) isKindOf: Dictionary) or: [ pool isKindOf: SharedPool class ])
				ifTrue: [ 
					refs := self systemNavigation allClasses
						select: [ :c | c sharedPools identityIncludes: pool ]
						thenCollect: [ :c | c name ].
					refs add: (self systemNavigation allReferencesTo: (self associationAt: k)).
					poolUsers at: k put: refs ] ].
	^ poolUsers
]

{ #category : #printing }
SystemDictionary >> printElementsOn: aStream [
	aStream nextPutAll:'(lots of globals)'
]

{ #category : #'classes and traits' }
SystemDictionary >> removeClassNamed: aName [
	"Invoked from fileouts:  if there is currently a class in the system named aName, then remove it"

	self at: aName asSymbol ifPresent: [:oldClass | oldClass removeFromSystem]
]

{ #category : #removing }
SystemDictionary >> removeFromCaches: aKey [
	"In case we remove a key from the system dictionary, we do not need to flush all the caches. We can just remove it from the class name and non class name caches."

	cachedClassNames ifNotNil: [ :cache | cache remove: aKey ifAbsent: [  ] ].
	cachedNonClassNames ifNotNil: [ :cache | cache remove: aKey ifAbsent: [  ] ].
	cachedBehaviors := nil
]

{ #category : #'dictionary access' }
SystemDictionary >> removeKey: key ifAbsent: aBlock [
	self removeFromCaches: key.
	^ super removeKey: key ifAbsent: aBlock
]

{ #category : #renaming }
SystemDictionary >> renameClass: aClass as: newName [ 
	"Rename the class, aClass, to have the title newName."

	^self renameClass: aClass from: aClass name to: newName
]

{ #category : #renaming }
SystemDictionary >> renameClass: aClass from: oldName [ 
	"Rename the class, aClass, to have the title newName."

	^self renameClass: aClass from: oldName to: aClass name
]

{ #category : #renaming }
SystemDictionary >> renameClass: aClass from: oldName to: newName [
	"Rename the class, aClass, to have the title newName."

	| oldref category |
	category := self organization categoryOfElement: oldName.
	self organization classify: newName under: category.
	self organization removeElement: oldName.
	oldref := self associationAt: oldName.
	self removeKey: oldName.
	oldref key: newName.
	self add: oldref.  "Old association preserves old refs"
	SessionManager default renamedClass: aClass from: oldName to: newName.
	self flushClassNameCache.
	SystemAnnouncer uniqueInstance classRenamed: aClass from: oldName to: newName inCategory: category.
	aClass subclassesDo:[:subclass |
		SystemAnnouncer uniqueInstance classParentOf: subclass renamedFrom: oldName to: newName].
]

{ #category : #renaming }
SystemDictionary >> renameClassNamed: oldName as: newName [
	"Invoked from fileouts:  if there is currently a class in the system named oldName, then rename it to newName.  If anything untoward happens, report it in the Transcript.  "

	| oldClass |
	(oldClass := self at: oldName asSymbol ifAbsent: [ nil ]) 
		ifNil: [ 
			SystemNotification signal: 'Class-rename for ' , oldName , ' ignored because ' , oldName , ' does not exist.'.
			^ self ].
	oldClass rename: newName
]

{ #category : #'variable lookup' }
SystemDictionary >> reservedVariables [
	"we cache the variables for speed"
	^reservedVariables ifNil: [ reservedVariables := ReservedVariable lookupDictionary]
]

{ #category : #'variable lookup' }
SystemDictionary >> resetReservedVariables [
	"lazy init in the accessor, resetting it will take new subclasses on ReserverdVariable into account"
	^reservedVariables := nil
]

{ #category : #'class and trait names' }
SystemDictionary >> traitNames [
	"Answer a SortedCollection of all traits (not including class-traits) names."
	
	^self classNames select: [ :name |
			self
				at: name
				ifPresent: [ :global | (global isTrait) and: [global isObsolete not]]
				ifAbsent: [ false ] ]
]

{ #category : #copying }
SystemDictionary >> veryDeepCopyWith: deepCopier [
	"Return self.  I can't be copied.  Do not record me."
]
