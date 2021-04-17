"
I am class holding state for compiled methods. All my instance variables should be actually part of the CompiledMethod itself, but the current implementation of the VM doesn't allow this.  Currently I hold the selector and any pragmas or properties the compiled method has.  Pragmas and properties are stored in indexable fields; pragmas as instances of Pragma, properties as instances of Association.
I am a reimplementation of much of MethodProperties, but eliminating the explicit properties and pragmas dictionaries.  Hence I answer true to isMethodProperties.
"
Class {
	#name : #AdditionalMethodState,
	#superclass : #Object,
	#type : #variable,
	#instVars : [
		'method',
		'selector'
	],
	#category : #'Kernel-Methods'
}

{ #category : #'instance creation' }
AdditionalMethodState class >> forMethod: aMethod selector: aSelector [
	^(self new: 0)
		selector: aSelector;
		setMethod: aMethod;
		yourself
]

{ #category : #'instance creation' }
AdditionalMethodState class >> forSelector: aSelector [
	^(self new: 0)
		selector: aSelector;
		yourself
]

{ #category : #'instance creation' }
AdditionalMethodState class >> new [
	^ self new: 0
]

{ #category : #'instance creation' }
AdditionalMethodState class >> selector: aSelector with: aPropertyOrPragma [
	^(self new: 1)
		selector: aSelector;
		basicAt: 1 put: aPropertyOrPragma;
		yourself
]

{ #category : #testing }
AdditionalMethodState >> analogousCodeTo: aMethodProperties [
	| bs |
	self class == aMethodProperties class ifFalse:
		[^false].
	(bs := self basicSize) = aMethodProperties basicSize ifFalse:
		[^false].
	1 to: bs do:
		[:i|
		((self basicAt: i) analogousCodeTo: (aMethodProperties basicAt: i)) ifFalse:
			[^false]].
	^true
]

{ #category : #accessing }
AdditionalMethodState >> at: aKey [
	"Answer the property value or pragma associated with aKey."
	
	^self at: aKey ifAbsent: [self error: 'not found']
]

{ #category : #accessing }
AdditionalMethodState >> at: aKey ifAbsent: aBlock [
	"Answer the property value or pragma associated with aKey or,
	 if aKey isn't found, answer the result of evaluating aBlock."

	1 to: self basicSize do:
		[:i |
		| propertyOrPragma "<Association|Pragma>" |
		(propertyOrPragma := self basicAt: i) key == aKey ifTrue:
			[^propertyOrPragma isAssociation
				ifTrue: [propertyOrPragma value]
				ifFalse: [propertyOrPragma]]].
	^aBlock value
]

{ #category : #accessing }
AdditionalMethodState >> at: aKey ifAbsentPut: aBlock [
	"Answer the property value or pragma associated with aKey or,
	 if aKey isn't found, answer the result of evaluating aBlock."

	1 to: self basicSize do:
		[:i |
		| propertyOrPragma "<Association|Pragma>" |
		(propertyOrPragma := self basicAt: i) key == aKey ifTrue:
			[^propertyOrPragma isAssociation
				ifTrue: [propertyOrPragma value]
				ifFalse: [propertyOrPragma]]].
	^method propertyAt: aKey put: aBlock value
]

{ #category : #accessing }
AdditionalMethodState >> at: aKey ifPresent: aBlock [
	"Lookup the given key in the receiver. If it is present, answer the value of evaluating the given block with the value associated with the key. Otherwise, answer self."
	^ aBlock value: (self at: aKey ifAbsent: [ ^ self ])
]

{ #category : #accessing }
AdditionalMethodState >> at: aKey put: aValue [
       "Replace the property value or pragma associated with aKey."
       | keyAlreadyExists |
       keyAlreadyExists := false.

       1 to: self basicSize do:
               [:i |
               | propertyOrPragma "<Association|Pragma>" |
               (propertyOrPragma := self basicAt: i) key == aKey ifTrue: [
                       keyAlreadyExists := true.
                       propertyOrPragma isAssociation
                               ifTrue: [propertyOrPragma value: aValue]
                               ifFalse: [self basicAt: i put: aValue]]].

       keyAlreadyExists ifFalse: [
               method propertyAt: aKey put: aValue ].

       ^ aValue

]

{ #category : #copying }
AdditionalMethodState >> copyWith: aPropertyOrPragma [ "<Association|Pragma>"
	"Answer a copy of the receiver which includes aPropertyOrPragma"
	| bs copy |
	(Association == aPropertyOrPragma class
	 or: [Pragma == aPropertyOrPragma class]) ifFalse:
		[self error: self class name, ' instances should hold only Associations or Pragmas.'].
	"no need to initialize here; we're copying all inst vars"
	copy := self class basicNew: (bs := self basicSize) + 1.
	1 to: bs do:
		[:i|
		copy basicAt: i put: (self basicAt: i) shallowCopy].
	copy basicAt: bs + 1 put: aPropertyOrPragma.
	1 to: self class instSize do:
		[:i| copy instVarAt: i put: (self instVarAt: i)].
	^copy
]

{ #category : #copying }
AdditionalMethodState >> copyWithout: aPropertyOrPragma [ "<Association|Pragma>"
	"Answer a copy of the receiver which no longer includes aPropertyOrPragma"
	| bs copy offset |
	"no need to initialize here; we're copying all inst vars"
	copy := self class basicNew: (bs := self basicSize) - ((self includes: aPropertyOrPragma)
															ifTrue: [1]
															ifFalse: [0]).
	offset := 0.
	1 to: bs do:
		[:i|
		(self basicAt: i) = aPropertyOrPragma
			ifTrue: [offset := 1]
			ifFalse: [copy basicAt: i - offset put: (self basicAt: i) shallowCopy]].
	1 to: self class instSize do:
		[:i| copy instVarAt: i put: (self instVarAt: i)].
	^copy
]

{ #category : #generated }
AdditionalMethodState >> hasLiteralThorough: literal [

	"Answer true if any literal in these properties is literal,
	 even if embedded in array structure."

	self
		deprecated: 'Use #refersToLiteral: instead'
		transformWith:
		'`@rec hasLiteralThorough: `@arg' -> '`@rec refersToLiteral: `@arg'.
	^ self refersToLiteral: literal
]

{ #category : #testing }
AdditionalMethodState >> includes: aPropertyOrPragma [ "<Association|Pragma>"
	"Test if the property or pragma is present."

	1 to: self basicSize do:
		[:i |
		(self basicAt: i) = aPropertyOrPragma ifTrue:
			[^true]].
	^false
]

{ #category : #testing }
AdditionalMethodState >> includesKey: aKey [
	"Test if the property aKey or pragma with selector aKey is present."

	1 to: self basicSize do:
		[:i |
		(self basicAt: i) key == aKey ifTrue:
			[^true]].
	^false
]

{ #category : #properties }
AdditionalMethodState >> includesProperty: aKey [
	"Test if the property aKey is present."

	1 to: self basicSize do: [:i |
		| propertyOrPragma "<Association|Pragma>" |
		propertyOrPragma := self basicAt: i.
		(propertyOrPragma isAssociation
		 and: [propertyOrPragma key == aKey]) ifTrue:
			[^true]].
	^false
]

{ #category : #testing }
AdditionalMethodState >> isEmpty [
	^self basicSize = 0
]

{ #category : #testing }
AdditionalMethodState >> isMethodProperties [
	^true
]

{ #category : #accessing }
AdditionalMethodState >> keysAndValuesDo: aBlock [
	"Enumerate the receiver with all the keys and values."

	1 to: self basicSize do: [:i |
		| propertyOrPragma "<Association|Pragma>" |
		(propertyOrPragma := self basicAt: i) isAssociation
			ifTrue: [aBlock value: propertyOrPragma key value: propertyOrPragma value]
			ifFalse: [aBlock value: propertyOrPragma selector value: propertyOrPragma]]
]

{ #category : #accessing }
AdditionalMethodState >> method [

	^method.
]

{ #category : #decompiling }
AdditionalMethodState >> method: aMethodNodeOrNil [
	"For decompilation"
	method := aMethodNodeOrNil
]

{ #category : #testing }
AdditionalMethodState >> notEmpty [
	^self basicSize > 0
]

{ #category : #copying }
AdditionalMethodState >> postCopy [
	"After copying we must duplicate any associations and pragmas so they don't end up being shared."
	1 to: self basicSize do:
		[:i| self basicAt: i put: (self basicAt: i) shallowCopy]
]

{ #category : #accessing }
AdditionalMethodState >> pragmas [
	"Return the Pragma objects. Properties are stored as Associations"
	^ Array new: self basicSize streamContents: [ :pragmaStream | 
		  1 to: self basicSize do: [ :i | 
			  | propertyOrPragma "<Association|Pragma>" |
			  (propertyOrPragma := self basicAt: i) isAssociation ifFalse: [ 
				  pragmaStream nextPut: propertyOrPragma ] ] ]
]

{ #category : #enumerating }
AdditionalMethodState >> pragmasDo: aBlock [
	
	1 to: self basicSize do: [ :i | 
		| propertyOrPragma	"<Association|Pragma>" |
		propertyOrPragma := self basicAt: i.
		propertyOrPragma isAssociation
			ifFalse: [ aBlock value: propertyOrPragma ] ]
]

{ #category : #printing }
AdditionalMethodState >> printOn: aStream [
	super printOn: aStream.
	aStream space; nextPut: $(; print: self identityHash; nextPut: $)
]

{ #category : #accessing }
AdditionalMethodState >> properties [

	| propertyStream |
	propertyStream := WriteStream on: (Array new: self basicSize * 2).
	1 to: self basicSize do: [:i |
		| propertyOrPragma "<Association|Pragma>" |
		(propertyOrPragma := self basicAt: i) isAssociation ifTrue:
			[propertyStream nextPut: propertyOrPragma key; nextPut: propertyOrPragma value]].
	^IdentityDictionary newFromPairs: propertyStream contents
]

{ #category : #properties }
AdditionalMethodState >> propertyAt: aKey [
	"Answer the property value associated with aKey."
	
	^ self propertyAt: aKey ifAbsent: [ self error: 'Property not found' ].
]

{ #category : #properties }
AdditionalMethodState >> propertyAt: aKey ifAbsent: aBlock [
	"Answer the property value associated with aKey or, if aKey isn't found, answer the result of evaluating aBlock."

	1 to: self basicSize do: [:i |
		| propertyOrPragma "<Association|Pragma>" |
		propertyOrPragma := self basicAt: i.
		(propertyOrPragma isAssociation
		 and: [propertyOrPragma key == aKey]) ifTrue:
			[^propertyOrPragma value]].
	^aBlock value
]

{ #category : #properties }
AdditionalMethodState >> propertyKeysAndValuesDo: aBlock [
	"Enumerate the receiver with all the keys and values."

	1 to: self basicSize do: [:i |
		| propertyOrPragma "<Association|Pragma>" |
		(propertyOrPragma := self basicAt: i) isAssociation ifTrue:
			[aBlock value: propertyOrPragma key value: propertyOrPragma value]]
]

{ #category : #'properties-compatibility' }
AdditionalMethodState >> propertyValueAt: aKey [
	"use the version without ..Value, this methid is retained for compatibility"
	
	^ self propertyAt: aKey
]

{ #category : #'properties-compatibility' }
AdditionalMethodState >> propertyValueAt: aKey ifAbsent: aBlock [
	"use the version without ..Value, this methid is retained for compatibility"
	^self propertyAt: aKey ifAbsent: aBlock
]

{ #category : #properties }
AdditionalMethodState >> removeKey: aKey [
	"Remove the property with aKey. Answer the property or raise an error if aKey isn't found."
	
	^ self removeKey: aKey ifAbsent: [ self error: 'Property not found' ].
]

{ #category : #accessing }
AdditionalMethodState >> removeKey: aKey ifAbsent: aBlock [
	"Remove the property with aKey. Answer the value or, if aKey isn't found, answer the result of evaluating aBlock."
	
	1 to: self basicSize do: [:i |
		| propertyOrPragma "<Association|Pragma>" |
		propertyOrPragma := self basicAt: i.
		(propertyOrPragma isAssociation
				ifTrue: [propertyOrPragma key]
				ifFalse: [propertyOrPragma selector])
			== aKey ifTrue:
			[^method removeProperty: aKey]].
	^aBlock value
]

{ #category : #accessing }
AdditionalMethodState >> selector [
	^selector
]

{ #category : #accessing }
AdditionalMethodState >> selector: aSymbol [
	selector := aSymbol
]

{ #category : #accessing }
AdditionalMethodState >> setMethod: aMethod [
	method := aMethod.
	1 to: self basicSize do: [ :i | 
		| propertyOrPragma	"<Association|Pragma>" |
		(propertyOrPragma := self basicAt: i) isAssociation
			ifFalse: [ propertyOrPragma method: aMethod ] ]
]
