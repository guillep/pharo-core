"
I represent a trait composition.
All the trait compositions are represented by operations. 
My subclasses are the possible operations. 

I know how to resolve the methods and slots included in a trait or traited class.

Also I and my subclasses control how the new methods are compiled.
"
Class {
	#name : #TaAbstractComposition,
	#superclass : #Object,
	#category : #'TraitsV2-Compositions'
}

{ #category : #testing }
TaAbstractComposition class >> isAbstract [

	^self == TaAbstractComposition
]

{ #category : #operations }
TaAbstractComposition >> + anotherTrait [
	"I create another TaSequence with me and then I concatenate anotherTrait to it. The new sequence includes both elements, me and the anotherTrait.
	This operation creates a new sequence with copies. Does not affect the existing one."
	^ (TaSequence with: self) + anotherTrait asTraitComposition
]

{ #category : #operations }
TaAbstractComposition >> , anotherTrait [
	"I create another TaSequence with me and then I concatenate anotherTrait to it. The new sequence includes both elements, me and the anotherTrait.
	This operation creates a new sequence with copies. Does not affect the existing one."
	^ (TaSequence with: self) , anotherTrait asTraitComposition
]

{ #category : #operations }
TaAbstractComposition >> - anArrayOrASymbol [
	| anArray |
	
	"I create a remove method on me. Removing the symbol or array of symbols"
	
	anArray := anArrayOrASymbol isArray
		ifTrue: [ anArrayOrASymbol ]
		ifFalse: [ {anArrayOrASymbol} ].
		
	^ TaRemoveMethod remove: anArray to: self
]

{ #category : #operations }
TaAbstractComposition >> -- anArrayOfSlotNames [
	
	"I create a new trait composition element, from me but without the slot named as the parameter"

	^ TaRemoveSlot remove: anArrayOfSlotNames from: self.
]

{ #category : #comparing }
TaAbstractComposition >> = anotherTrait [
	^ self shouldBeImplemented
]

{ #category : #operations }
TaAbstractComposition >> @ anArrayOfAssociations [
	"I return a new trait composition with the aliases passed as parameters. It is an array of associations, the keys are the new selectors and the values are the original selectors"
	^ TaAliasMethod alias: anArrayOfAssociations to: self.
]

{ #category : #operations }
TaAbstractComposition >> @= anAssociation [
	"This performs a deep alias, rewriting all the sendings of this message. The association has its key as the new alias selector and the value as the original selector."
	^ TaDeepAliasMethod alias:anAssociation to: self.
]

{ #category : #operations }
TaAbstractComposition >> @@ anArrayOfAssociations [

	"This operation creates a new trait composition element with a slot renamed.
	The parameter is an array of association, where the key is the old name and the value the new name."
	
	^ TaRenameSlot rename: anArrayOfAssociations on: self
]

{ #category : #operations }
TaAbstractComposition >> addToSequence: sequence [
	
	"I basically add myself to the sequence passed as parameter. For sure you want to use #+ or #,"
	sequence addMember: self.
	^ sequence
]

{ #category : #'transforming selectors' }
TaAbstractComposition >> aliasSelector: anOldSelector [
	"I return the new selector for the old selector passed as parameter"
	^ self shouldBeImplemented
]

{ #category : #accessing }
TaAbstractComposition >> allSelectors [
	"I return all the selectors exported by the trait composition"
	^ self selectors
]

{ #category : #querying }
TaAbstractComposition >> allTraits [
	"I should return all the traits in the trait composition and the traits refered by the traits in the trait composition. It is recursive! #traits is the non recursive version"

	^ self subclassResponsibility
]

{ #category : #converting }
TaAbstractComposition >> asTraitComposition [
	^ self
]

{ #category : #accessing }
TaAbstractComposition >> categoryOfMethod: method withSelector: selector [
	"I return the category of the method with the selector. 
	This is useful when the method is aliased or the method came from different traits or it is a conflicting category. 
	The basic implementation returns the category of the method"
	^ method category
]

{ #category : #testing }
TaAbstractComposition >> changesSourceCode: aSelector [
	"Checks if a selector should be compiled because its code has been rewritten."
	self subclassResponsibility.
]

{ #category : #accessing }
TaAbstractComposition >> classComposition [
	"This is used to access to the classSide of the traitComposition. Used when creating a traited class without class side traitComposition"
	^ self subclassResponsibility 
]

{ #category : #compiling }
TaAbstractComposition >> compile: selector into: aClass [
	"Compile the method associated with selector in aClass's method dictionary.
	This version classify the method in the class passed as parameter"

	| method newMethod sourceCode trailer traitDefining |
	
	traitDefining := self traitDefining: selector.

	method := self compiledMethodAt: selector.
	sourceCode := self sourceCodeAt: selector.
	trailer := method trailer.
	
	newMethod := aClass compiler
				source: sourceCode;
				class: aClass ;
				failBlock: [^ false];
				compiledMethodTrailer: trailer;
				compile.   "Assume OK after proceed from SyntaxError"

	selector == newMethod selector ifFalse: [self error: 'selector changed!'].

	(selector ~= method selector or: [self changesSourceCode: selector]) 
		ifTrue: [ self saveSourceCode: sourceCode ofMethod: newMethod ]
		ifFalse: [ newMethod setSourcePointer: method sourcePointer ].
		
	aClass addSelectorSilently: selector withMethod: newMethod.

	aClass organization protocolOrganizer
		classify: selector
		inProtocolNamed: (self categoryOfMethod: method withSelector: method selector).
	
	aClass >> selector propertyAt: #traitSource put: traitDefining.
	^ true
]

{ #category : #accessing }
TaAbstractComposition >> compiledMethodAt: aSelector [
	"Access the compiledMethod to use for a given selector. It should handle aliases, sequences and removals.
	It signals NotFound"
	self subclassResponsibility 
]

{ #category : #accessing }
TaAbstractComposition >> compiledMethodAt: aSelector ifAbsent: aValuable [

	"It handles the NotFound in a graceful way"

	^ [ self compiledMethodAt: aSelector ]
		on: NotFound
		do: [ ^ aValuable value ]
]

{ #category : #operations }
TaAbstractComposition >> copyMethod: aSelector into: aClass replacing: replacing [

	"When the included method does not need to be source rewritten or recompiled, 
	it is query by using #changesSourceCode:, the method is inserted in aClass' method dictionary.
	The compiled method is just copied and the source is stored in the change file
	
	I check that the method is not already in the class
	The method is only replaced if replacing is true. 
	"

	| aCompiledMethod source newMethod traitDefining sourceHasChanged |
	
	traitDefining := self traitDefining: aSelector.
	aCompiledMethod := self compiledMethodAt: aSelector.
	source := self getSourceCodeOf: aCompiledMethod usingSelector: aSelector.
	
	"If the selectors are not the same I have to save the new source code"
	sourceHasChanged := aSelector ~= aCompiledMethod selector.
	
	"Check if the method should be replaced. It is replaced if:
	 - replacing is true.
	 - The trait defining the method is not the same.
	 - If both methods have source code and if the source codes are not the same.
	"
	aClass methodDict at: aSelector ifPresent:[ :originalMethod | 
		((replacing not and: [(originalMethod traitSource = traitDefining) and: [originalMethod hasSourceCode]]) and: [ source isNotNil and: [ source = originalMethod sourceCode ] ]) ifTrue: [ ^ false ]].
	
	newMethod := aCompiledMethod copy.
	newMethod selector: aSelector.
	newMethod methodClass: aClass.
			
	newMethod setSourcePointer: aCompiledMethod sourcePointer.	

	aClass addSelectorSilently: aSelector withMethod: newMethod.

	aClass organization protocolOrganizer
		classify: aSelector
		inProtocolNamed: aCompiledMethod category asSymbol.		
	
	aClass organization removeEmptyCategories.
	
	aClass >> aSelector propertyAt: #traitSource put: traitDefining.
		
	^ true
]

{ #category : #copying }
TaAbstractComposition >> copySlot: aSlot [
	"This is a utitlity method to handle the copy of a slot. It is used for instance side and class side slots."
	| newOne |
	newOne := aSlot copy.
	newOne isVirtual ifFalse: [ newOne index: nil ].
	newOne definingClass: aSlot definingClass.
	^ newOne
]

{ #category : #copying }
TaAbstractComposition >> copyTraitExpression [
	"I should copy all the elements in the traitComposition"
	^ self subclassResponsibility 
]

{ #category : #copying }
TaAbstractComposition >> copyWithoutTrait: aTrait [ 
	"Returns a copy without the aTrait"
	self subclassResponsibility 
]

{ #category : #operations }
TaAbstractComposition >> getSourceCodeOf: aCompiledMethod usingSelector: aSelector [ 
	
	^ aCompiledMethod getSourceReplacingSelectorWith: aSelector
]

{ #category : #accessing }
TaAbstractComposition >> hasMethod: aSelector [
	^ [ self compiledMethodAt: aSelector.
	true ]
		on: NotFound
		do: [ ^ false ]
]

{ #category : #comparing }
TaAbstractComposition >> hash [
	^ self subclassResponsibility 
]

{ #category : #querying }
TaAbstractComposition >> includesTrait: aTrait [
	"Checks if the trait is used in the trait composition"
	^ self allTraits includes: aTrait
]

{ #category : #operations }
TaAbstractComposition >> initializeObject: anObject [
	
	"Handles the custom initialization of a class using stateful talents. 
	When using stateful traits the initialize method in the resulting class 
	includes the initializaton of the included traits."

	| selector |
	selector := self initializeSelectorForMe.

	(anObject class allSelectors includes: selector)
		ifTrue: [ selector value: anObject ]
]

{ #category : #'transforming selectors' }
TaAbstractComposition >> initializeSelectorForMe [
	"Calculates the name of the artificial selector added when a stateful trait includes a initialize method"

	^ self shouldBeImplemented
]

{ #category : #operations }
TaAbstractComposition >> installSelector: aSelector into: aClass [
	"
	This method tryies to install a selector in a given class. 
	If the method is already installed it does not perform nothing.
	This may fail because this is used when recalculating the method dictionary. 
	It is probable the aliased method does not exists any more in the trait composition. This situation is checked when creating the trait composition."

	^ self installSelector: aSelector into: aClass replacing: true
]

{ #category : #operations }
TaAbstractComposition >> installSelector: aSelector into: aClass replacing: replacing [
	"
	This method tryies to install a selector in a given class. 
	If the method is already installed it does not perform nothing.
	This may fail because this is used when recalculating the method dictionary. 
	It is probable the aliased method does not exists any more in the trait composition. This situation is checked when creating the trait composition."


	[ 	
		^ (self needsRecompilation: aSelector) 
			ifTrue:[ self compile: aSelector into: aClass	]
			ifFalse:[ self copyMethod: aSelector into: aClass replacing: replacing ].	
	 ] on: NotFound
		do: [ ^ true ].
		
	^ true
]

{ #category : #testing }
TaAbstractComposition >> isAliasSelector: aSelector [

	"Tests if aSelector is alias to another selector"
	self subclassResponsibility  
	
]

{ #category : #testing }
TaAbstractComposition >> isEmpty [
	^ false
]

{ #category : #testing }
TaAbstractComposition >> isLocalAliasSelector: aSymbol [
	"Return true if the selector aSymbol is an alias I define."
	^ false
]

{ #category : #testing }
TaAbstractComposition >> isNotEmpty [
	^ self isEmpty not
]

{ #category : #operations }
TaAbstractComposition >> isSourcesPresentInSystem [

	^ ((Smalltalk globals includesKey: #SourceFiles) and: [ (Smalltalk globals at: #SourceFiles) notNil])
]

{ #category : #accessing }
TaAbstractComposition >> name [
	self subclassResponsibility 
]

{ #category : #testing }
TaAbstractComposition >> needsRecompilation: aSelector [
	"Checks if a selector should be compiled because it uses new slots or if its code has been rewritten."

	^ self slots isNotEmpty or: [ self changesSourceCode: aSelector ]
]

{ #category : #querying }
TaAbstractComposition >> originSelectorOf: aSelector [ 
	"The original selector for a given selector. It is overriden by the alias."
	^ aSelector
]

{ #category : #printing }
TaAbstractComposition >> printOn: aStream [

	aStream nextPutAll: self traitCompositionExpression
]

{ #category : #querying }
TaAbstractComposition >> reverseAlias: aSelector [
	"Returns all the aliases that point to this old selector"
	self subclassResponsibility
]

{ #category : #compiling }
TaAbstractComposition >> saveSourceCode: sourceCode ofMethod: newMethod [

	"I have to check because during bootstrap there is no SouceFiles"
	(sourceCode isNotNil and: [((Smalltalk globals includesKey: #SourceFiles) 
		and: [ (Smalltalk globals at: #SourceFiles) notNil])]) ifTrue: [ 
			newMethod putSource: sourceCode
					withPreamble: [:f | f cr; nextPut: $!; nextChunkPut: 'Trait method'; cr]].	

]

{ #category : #accessing }
TaAbstractComposition >> selectors [
	self subclassResponsibility 
]

{ #category : #comparing }
TaAbstractComposition >> semanticallyEquals: another [
	"Checks if I have the same effect that another traitComposition. 
	I have the same effect if I expose the same selectors and the methods have the same source code.
	The comparison is done using the source code to handle the aliasing and the rewriting of methods"
	^ self selectors = another selectors
		and: [ self methods = another methods
				and: [ self selectors
						allSatisfy: [ :e | (self sourceCodeAt: e) = (another sourceCodeAt: e) ] ] ]
]

{ #category : #accessing }
TaAbstractComposition >> slots [
	self subclassResponsibility 
]

{ #category : #copying }
TaAbstractComposition >> slotsCopy [

	^ self slots collect: [ :each | self copySlot: each ]
]

{ #category : #accessing }
TaAbstractComposition >> sourceCodeAt: selector [
	| method |
	"Returns the source code for a given selector. Handling the rewriting if it is an alias"
	method := self compiledMethodAt: selector.
	^ method selector = selector
		ifTrue: [ method sourceCode ]
		ifFalse: [ method getSourceReplacingSelectorWith: selector ]
]

{ #category : #comparing }
TaAbstractComposition >> syntacticallyEquals: another [
	"This is not 100% true, but it is kept for compatibility with the old implementation.
	If two trait composition are syntaticallyEquals they should be semanticallyEquals, however the inverse may not be true."
	^ self semanticallyEquals: another
]

{ #category : #printing }
TaAbstractComposition >> traitCompositionExpression [
	"I give my expression, having parens if they are needed"
	^ self subclassResponsibility
]

{ #category : #printing }
TaAbstractComposition >> traitCompositionExpressionWithParens [
	"I give my expression, having always parens "

	^ '(' , self traitCompositionExpression , ')'
]

{ #category : #querying }
TaAbstractComposition >> traitDefining: selector [
	"I return the trait that is used to find the definition of this selector
	It signals NotFound if it is not found"
	^ self shouldBeImplemented.
]

{ #category : #querying }
TaAbstractComposition >> traitDefining: aSelector ifNone: aBlockClosure [ 
	"I return the trait that is used to find the definition of this selector. If none the block is evaluated"
	
	[ ^ self traitDefining: aSelector ] on: NotFound do: [ ^ aBlockClosure value ]
]

{ #category : #querying }
TaAbstractComposition >> traits [
	"Returns the traits directly used in the trait composition. #allTraits returns all the traits used and the ones referenced recursively."

	^ self subclassResponsibility
]

{ #category : #operations }
TaAbstractComposition >> without: anotherTrait [
	"Creates a copy of it self without the given trait"

	^ self shouldBeImplemented
]
