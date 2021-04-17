"
My instances describe the behavior of other objects. I provide the minimum state necessary for compiling methods, and creating and running instances. Most objects are created as instances of the more fully supported subclass, Class, but I am a good starting point for providing instance-specific behavior (as in Metaclass).
"
Class {
	#name : #Behavior,
	#superclass : #Object,
	#instVars : [
		'superclass',
		'methodDict',
		'format',
		'layout'
	],
	#classVars : [
		'ClassProperties',
		'ObsoleteSubclasses'
	],
	#category : #'Kernel-Classes'
}

{ #category : #cleanup }
Behavior class >> cleanUp [
	"Flush the obsolete subclasses."

	self flushObsoleteSubclasses
]

{ #category : #'class initialization' }
Behavior class >> flushObsoleteSubclasses [
	"Behavior flushObsoleteSubclasses"
	ObsoleteSubclasses finalizeValues.
]

{ #category : #'class initialization' }
Behavior class >> initialize [
	"Behavior initialize"
	"Never called for real"
	ObsoleteSubclasses
		ifNil: [ self initializeObsoleteSubclasses ]
		ifNotNil: [ | newDict | 
			newDict := WeakKeyToCollectionDictionary newFrom: ObsoleteSubclasses.
			newDict rehash.
			ObsoleteSubclasses := newDict ].
		
	ClassProperties
		ifNil: [ self initializeClassProperties ]
		ifNotNil: [ | newDict | 
			newDict := WeakIdentityKeyDictionary newFrom: ClassProperties.
			newDict rehash.
			ClassProperties := newDict ]
]

{ #category : #'class initialization' }
Behavior class >> initializeClassProperties [
	ClassProperties := WeakIdentityKeyDictionary new.
]

{ #category : #'class initialization' }
Behavior class >> initializeObsoleteSubclasses [
	ObsoleteSubclasses := WeakKeyToCollectionDictionary new.
]

{ #category : #'accessing method dictionary' }
Behavior >> >> selector [ 
	"Answer the compiled method associated with the argument, selector (a 
	Symbol), a message selector in the receiver's method dictionary. If the 
	selector is not in the dictionary, create an error notification."

	^self compiledMethodAt: selector

]

{ #category : #'obsolete subclasses' }
Behavior >> addObsoleteSubclass: aClass [
	"Weakly remember that aClass was a subclass of the receiver and is now obsolete"
	| obs |

	obs := self basicObsoleteSubclasses at: self ifAbsent:[WeakArray new].
	(obs includes: aClass) ifTrue:[^self].
	obs := obs copyWithout: nil.
	obs := obs copyWith: aClass.
	self basicObsoleteSubclasses at: self put: obs.
]

{ #category : #'adding/removing methods' }
Behavior >> addSelector: selector withMethod: compiledMethod [ 
	^ self addSelectorSilently: selector withMethod: compiledMethod
]

{ #category : #'adding/removing methods' }
Behavior >> addSelector: selector withRecompiledMethod: compiledMethod [ 
	^ self addSelectorSilently: selector withMethod: compiledMethod
]

{ #category : #'adding/removing methods' }
Behavior >> addSelectorSilently: selector withMethod: compiledMethod [
	"Add the message selector with the corresponding compiled method to the 
	receiver's method dictionary.
	Do this without sending system change notifications"

	self methodDict at: selector put: compiledMethod.
	compiledMethod methodClass: self.
	compiledMethod selector: selector
]

{ #category : #'adding/removing methods' }
Behavior >> adoptInstance: anInstance [
	"Change the class of anInstance to me.
	Primitive (found in Cog and new VMs)  follows the same rules as primitiveChangeClassTo:, but returns the 	class rather than the modified instance"
	<primitive: 160 error: ec>
	anInstance primitiveChangeClassTo: self basicNew.
	^self
]

{ #category : #'accessing instances and variables' }
Behavior >> allClassVarNames [
	"Answer the names of the receiver's and the receiver's ancestor's class variables."

	^ self superclass
		ifNil: [ self classVarNames ]
		ifNotNil: [ :sup | sup allClassVarNames , self classVarNames ]
]

{ #category : #'accessing instances and variables' }
Behavior >> allInstVarNames [
	"Answer an Array of the names of the receiver's instance variables. The 
	Array ordering is the order in which the variables are stored and 
	accessed by the interpreter."

	^ self superclass
		ifNil: [ self instVarNames ]
		ifNotNil: [ :sup | sup allInstVarNames , self instVarNames ]
]

{ #category : #'accessing instances and variables' }
Behavior >> allInstances [
	"Answer all instances of the receiver."
	<primitive: 177>
	"The primitive can fail because memory is low.  If so, fall back on the old
	 enumeration code, which gives the system a chance to GC and/or grow.
	 Because aBlock might change the class of inst (for example, using become:),
	 it is essential to compute next before aBlock value: inst."
	| inst insts next |
	insts := WriteStream on: (Array new: 64).
	inst := self someInstance.
	[inst == nil] whileFalse:
		[next := inst nextInstance.
		 (inst == insts or: [inst == insts originalContents]) ifFalse: [insts nextPut: inst].
		 inst := next].
	^insts contents
]

{ #category : #enumerating }
Behavior >> allInstancesDo: aBlock [
	"Evaluate aBlock with each of the current instances of the receiver."
	| instances inst next |
	instances := self allInstancesOrNil.
	instances ifNotNil:
		[instances do: aBlock.
		 ^self].
	"allInstancesOrNil can fail because memory is low.  If so, fall back on the old
	 enumeration code.  Because aBlock might change the class of inst (for example,
	 using become:), it is essential to compute next before aBlock value: inst."
	inst := self someInstance.
	[inst == nil] whileFalse:
		[next := inst nextInstance.
		 aBlock value: inst.
		 inst := next]
]

{ #category : #'accessing instances and variables' }
Behavior >> allInstancesOrNil [
	"Answer all instances of the receiver, or nil if the primitive
	 fails, which it may be due to being out of memory."
	<primitive: 177>
	^nil
]

{ #category : #'accessing method dictionary' }
Behavior >> allMethods [
	"Return the collection of compiled method I and my superclasses are defining"
	"asArray is used to not bump into a bug when comparing compiled methods."
	
	^ self allSelectors asArray collect: [ :s | self lookupSelector: s ]
]

{ #category : #queries }
Behavior >> allMethodsAccessingSlot: aSlot [
	"return all methods that access aSlot in this class and subclasses"
	^self withAllSubclasses flatCollect: [ :class | class methodsAccessingSlot: aSlot ]
]

{ #category : #queries }
Behavior >> allMethodsReadingSlot: aSlot [
	"return all methods that access aSlot in this class and subclasses"
	^self withAllSubclasses flatCollect: [ :class | class methodsReadingSlot: aSlot]
]

{ #category : #queries }
Behavior >> allMethodsWritingSlot: aSlot [
	"return all methods that access aSlot in this class and subclasses"
	^self withAllSubclasses flatCollect: [ :class | class methodsWritingSlot: aSlot ]
]

{ #category : #'accessing method dictionary' }
Behavior >> allSelectors [
	"Answer all selectors understood by instances of the receiver"

	^ self allSelectorsBelow: nil
]

{ #category : #'accessing method dictionary' }
Behavior >> allSelectorsAbove [

	^ self allSelectorsAboveUntil: ProtoObject 
	


]

{ #category : #'accessing method dictionary' }
Behavior >> allSelectorsAboveUntil: aRootClass [

	| coll |
	coll := IdentitySet new.
	(self allSuperclassesIncluding: aRootClass) 
		do: [:aClass | 
				aClass selectorsDo: [ :sel | coll add: sel ]].
	^ coll
	


]

{ #category : #'accessing method dictionary' }
Behavior >> allSelectorsBelow: topClass [ 
	| coll |
	coll := IdentitySet new.
	self withAllSuperclassesDo: 
			[:aClass | 
			aClass = topClass
				ifTrue: [^ coll ]
				ifFalse: [aClass selectorsDo: [ :sel | coll add: sel ]]].
	^ coll
	


]

{ #category : #'accessing method dictionary' }
Behavior >> allSelectorsWithout: behaviors [
	"Returns all the selectors of the receiver and its superclasses, except the ones define in behaviors"

	| selectors |
	selectors := IdentitySet new.
	self withAllSuperclassesDo: [ :class | 
			(behaviors includes: class)
				ifFalse: [ selectors addAll: class selectors ] ].
	^ selectors
]

{ #category : #'accessing instances and variables' }
Behavior >> allSharedPools [
	"Answer an ordered collection of the shared pools that the receiver and the receiver's ancestors share."

	^self superclass allSharedPools
]

{ #category : #accessing }
Behavior >> allSlots [
	^#()
]

{ #category : #'accessing instances and variables' }
Behavior >> allSubInstances [ 
	"Answer a list of all current instances of the receiver and all of its subclasses."
	| aCollection |
	aCollection := OrderedCollection new.
	self allSubInstancesDo:
		[:x | x == aCollection ifFalse: [aCollection add: x]].
	^ aCollection
]

{ #category : #enumerating }
Behavior >> allSubInstancesDo: aBlock [ 
	"Evaluate the argument, aBlock, for each of the current instances of the 
	receiver and all its subclasses."

	self allInstancesDo: aBlock.
	self allSubclassesDo: [:sub | sub allInstancesDo: aBlock]
]

{ #category : #'accessing class hierarchy' }
Behavior >> allSubclasses [
	"Answer an orderedCollection of the receiver's and the receiver's descendent's subclasses. "

	| scan scanTop |
	scan := OrderedCollection withAll: self subclasses.
	scanTop := 1.
	[scanTop > scan size]
		whileFalse: [scan addAll: (scan at: scanTop) subclasses.
			scanTop := scanTop + 1].
	^ scan
]

{ #category : #enumerating }
Behavior >> allSubclassesDo: aBlock [ 
	"Evaluate the argument, aBlock, for each of the receiver's subclasses."

	self subclassesDo: 
		[:cl | 
		aBlock value: cl.
		cl allSubclassesDo: aBlock]
]

{ #category : #'accessing class hierarchy' }
Behavior >> allSubclassesWithLevelDo: classAndLevelBlock startingLevel: level [ 
	"Walk the tree of subclasses, giving the class and its level"
	| subclassNames |
	classAndLevelBlock value: self value: level.
	self == Class ifTrue:  [^ self].  "Don't visit all the metaclasses"
	"Visit subclasses in alphabetical order"
	subclassNames := SortedCollection new.
	self subclassesDo: [:subC | subclassNames add: subC name].
	subclassNames do:
		[:name | (self environment at: name)
			allSubclassesWithLevelDo: classAndLevelBlock
			startingLevel: level+1]
]

{ #category : #'accessing class hierarchy' }
Behavior >> allSuperclasses [
	"Answer an OrderedCollection of the receiver's and the receiver's  
	ancestor's superclasses. The first element is the receiver's immediate  
	superclass, followed by its superclass; the last element is Object."
	| temp |
	^ self superclass == nil
		ifTrue: [ OrderedCollection new]
		ifFalse: [temp := self superclass allSuperclasses.
			temp addFirst: self superclass.
			temp]
]

{ #category : #enumerating }
Behavior >> allSuperclassesDo: aBlock [ 
	"Evaluate the argument, aBlock, for each of the receiver's superclasses."

	self superclass == nil
		ifFalse: [aBlock value: self superclass.
				self superclass allSuperclassesDo: aBlock]
]

{ #category : #'accessing class hierarchy' }
Behavior >> allSuperclassesIncluding: aClass [
	"Answer an OrderedCollection of the receiver's and the receiver's  ancestor's superclasses
	up to aClass included. If aClass is not part of the receiver's superclass, returns up to the root."
	| temp |
	self class == ProtoObject class ifTrue: [ ^ OrderedCollection new].
	^ self superclass == aClass
		ifTrue: [ OrderedCollection with: aClass]
		ifFalse: [temp := self superclass allSuperclassesIncluding: aClass.
			temp addFirst: self superclass.
			temp]
]

{ #category : #'reflective operations' }
Behavior >> basicIdentityHash [
	"Answer a 22 bits unsigned SmallInteger, whose value is related to the receiver's identity
	 and unique among the behaviors (i.e. 2 different Behaviors cannot have the same identityHash).
	
	 Behavior implements identityHash to allow the VM to use an object representation which
	 does not include a direct reference to an object's class in an object.  If the VM is using
	 this implementation then classes are held in a class table and instances contain the index
	 of their class in the table.  A class's class table index is its identityHash so that an instance
	 can be created without searching the table for a class's index.  The VM uses this primitive
	 to enter the class into the class table, assigning its identityHash with an as yet unused
	 class table index. If this primitive fails it means that the class table is full.  In Spur as of
	 2014 there are 22 bits of classTable index and 22 bits of identityHash per object.

	 Primitive. Essential. Do not override. See Object documentation whatIsAPrimitive."

	<primitive: 175>
	self primitiveFailed
]

{ #category : #'instance creation' }
Behavior >> basicNew [
	"Primitive. Answer an instance of the receiver (which is a class) with no 
	 indexable variables. Fail if the class is indexable. Essential. See Object 
	 documentation whatIsAPrimitive.
	
	 If the primitive fails because space is low then the scavenger will run
	 before the method is activated.  Check that space was low and retry
	 via handleFailingBasicNew if so."

	<primitive: 70 error: ec>
	ec == #'insufficient object memory' ifTrue:
		[^self handleFailingBasicNew].
	self isVariable ifTrue: [^self basicNew: 0].
	self primitiveFailed
]

{ #category : #'instance creation' }
Behavior >> basicNew: sizeRequested [
	"Primitive. Answer an instance of this class with the number of indexable
	 variables specified by the argument, sizeRequested.  Fail if this class is not
	 indexable or if the argument is not a positive Integer, or if there is not
	 enough memory available. Essential. See Object documentation whatIsAPrimitive.
	
	 If the primitive fails because space is low then the scavenger will run before the
	 method is activated.  Check args and retry via handleFailingBasicNew: if they're OK."

	<primitive: 71 error: ec>
	ec == #'insufficient object memory' ifTrue:
		[^self handleFailingBasicNew: sizeRequested].
	self isVariable ifFalse:
		[self error: self printString, ' cannot have variable sized instances'].
	self primitiveFailed
]

{ #category : #'obsolete subclasses' }
Behavior >> basicObsoleteSubclasses [
	^ObsoleteSubclasses.
]

{ #category : #'accessing class hierarchy' }
Behavior >> basicSuperclass: aClass [
	superclass := aClass
]

{ #category : #private }
Behavior >> becomeUncompact [
	"Backward compatibility with the Squeak V3 object format.
	 Spur does not have a distinction between compact and non-compact classes."
]

{ #category : #accessing }
Behavior >> binding [
	^ LiteralVariable key: nil value: self
]

{ #category : #'accessing instances and variables' }
Behavior >> bindingOf: varName [
	"Answer the binding of some variable resolved in the scope of the receiver"
	^self superclass bindingOf: varName
]

{ #category : #'accessing instances and variables' }
Behavior >> byteSizeOfInstance [
	"Answer the total memory size of an instance of the receiver."

	<primitive: 181 error: ec>
	self isVariable ifTrue:
		[^self byteSizeOfInstanceOfSize: 0].
	self primitiveFailed
]

{ #category : #'accessing instances and variables' }
Behavior >> byteSizeOfInstanceOfSize: basicSize [
	"Answer the total memory size of an instance of the receiver
	 with the given number of indexable instance variables."

	<primitive: 181 error: ec>
	self isVariable
		ifTrue: "If the primitive overflowed answer a close approximation"
			[(basicSize isInteger
			  and: [basicSize >= 16r1000000]) ifTrue:
				[^2 * (self byteSizeOfInstanceOfSize: basicSize + 1 // 2)
				   - (self byteSizeOfInstanceOfSize: 0)]]
		ifFalse:
			[basicSize = 0 ifTrue:
				[^self byteSizeOfInstance]].
	self primitiveFailed
]

{ #category : #'testing method dictionary' }
Behavior >> canPerform: selector [
	"Answer whether the receiver can safely perform to the message whose selector 
	is the argument: it is not an abstract or cancelled method"

	^ self classAndMethodFor: selector do: [:c :m | m isProvided] ifAbsent: [false].
]

{ #category : #'testing method dictionary' }
Behavior >> canUnderstand: selector [
	"Answer whether the receiver can respond to the message whose selector 
	is the argument."

	^ self
		classAndMethodFor: selector
		do: [ :c :m | true ]
		ifAbsent: [ false ].
]

{ #category : #'accessing method dictionary' }
Behavior >> classAndMethodFor: aSymbol do: binaryBlock ifAbsent: absentBlock [
	"Looks up the selector aSymbol in the class chain. If it is found, binaryBlock is evaluated
	with the class that defines the selector and the associated method. Otherwise
	absentBlock is evaluated."

	
	self withAllSuperclassesDo: [:class | | method |
		method := class compiledMethodAt: aSymbol ifAbsent: [nil].
		method ifNotNil: [^ binaryBlock value: class value: method].
	].
	^ absentBlock value.
]

{ #category : #'testing method dictionary' }
Behavior >> classBindingOf: varName [
	"Answer the binding of some variable resolved in the scope of the receiver's class"
	^self bindingOf: varName
]

{ #category : #accessing }
Behavior >> classDepth [

	self superclass ifNil: [^ 1].
	^ self superclass classDepth + 1
]

{ #category : #accessing }
Behavior >> classLayout [
	^ layout
		ifNil: [ 
			| superLayout scope |
			superLayout := superclass 
				ifNil: [ FixedLayout new slotScope: LayoutEmptyScope instance] "happened in the bootrap"
				ifNotNil: [:sl | sl classLayout].
			scope := superLayout slotScope extend.
			layout := superLayout class extending: superLayout scope: scope host: self ]
]

{ #category : #accessing }
Behavior >> classLayout: aClassLayout [
	layout := aClassLayout
]

{ #category : #'accessing instances and variables' }
Behavior >> classVarNames [
	"Answer a collection of the receiver's class variable names."

	^#()
]

{ #category : #cleanup }
Behavior >> cleanUp [
	"Clean out any caches and other state that should be flushed when trying to get an image into a pristine state. Subclasses may override #cleanUp: to provide different levels of cleanliness"

]

{ #category : #cleanup }
Behavior >> cleanUp: aggressive [
	"Clean out any caches and other state that should be flushed when trying to get an image into a pristine state. The argument should be used to indicate how aggressive the cleanup should be. Some subclasses may act differently depending on its value - for example, ChangeSet will only delete all unused and reinitialize the current change set if we're asking it to be aggressive."

	^self cleanUp
]

{ #category : #'accessing method dictionary' }
Behavior >> compiledMethodAt: selector [ 
	"Answer the compiled method associated with the argument, selector (a 
	Symbol), a message selector in the receiver's method dictionary. If the 
	selector is not in the dictionary, create an error notification."

	^ self methodDict at: selector
]

{ #category : #'accessing method dictionary' }
Behavior >> compiledMethodAt: selector ifAbsent: aBlock [
	"Answer the compiled method associated with the argument, selector (a Symbol), a message selector in the receiver's method dictionary. If the selector is not in the dictionary, return the value of aBlock"

	^ self methodDict at: selector ifAbsent: aBlock
]

{ #category : #'accessing method dictionary' }
Behavior >> compiledMethodAt: selector ifPresent: aBlock [
	"Answer the compiled method associated with the argument, selector (a Symbol),
	 a message selector in the receiver's method dictionary.
	 If the selector is in the dictionary, return the value of aBlock.
	"

	^ self methodDict at: selector ifPresent: aBlock
]

{ #category : #'accessing method dictionary' }
Behavior >> compiledMethodAt: selector ifPresent: aBlock ifAbsent: anotherBlock [
	"Answer the compiled method associated with the argument, selector (a Symbol),
	 a message selector in the receiver's method dictionary.
	 If the selector is in the dictionary, return the value of aBlock.
	 If the selector is not in the dictionary, return the value of anotherBlock.
	"

	^ self methodDict at: selector ifPresent: aBlock ifAbsent: anotherBlock
]

{ #category : #copying }
Behavior >> deepCopy [
	"Classes should only be shallowCopied or made anew."

	^ self shallowCopy
]

{ #category : #'accessing instances and variables' }
Behavior >> definedVariables [
	"return all the Variables defined"
	^ self slots
]

{ #category : #dependencies }
Behavior >> dependentClasses [
	"Return the list of classes used myself"
	
	"Morph dependentClasses"
	| cll | 
	cll := Set new.
	"A class depends on its superclass"
	self superclass ifNotNil: [ cll add: self superclass ].
	
	"We unify a class and its metaclass"
	(self methods, self classSide methods) 
		do: [ :m | m literalsDo: [ :l | 
					"We also check if the method is not an extension"
					(l isVariableBinding 
					and: [ l isGlobalClassNameBinding
					and: [ m category notEmpty 
					and: [ m category first ~= $* ]]])  ifTrue: [ cll add: l value ] ] ] .
	^ cll asArray
]

{ #category : #'accessing instances and variables' }
Behavior >> elementSize [
	"Answer the size in bytes of an element in the receiver.  The formats are
			0	= 0 sized objects (UndefinedObject True False et al)
			1	= non-indexable objects with inst vars (Point et al)
			2	= indexable objects with no inst vars (Array et al)
			3	= indexable objects with inst vars (MethodContext AdditionalMethodState et al)
			4	= weak indexable objects with inst vars (WeakArray et al)
			5	= weak non-indexable objects with inst vars (ephemerons) (Ephemeron)
			6	= unused
			7	= immediates (SmallInteger, Character)
			8	= unused
			9	= 64-bit indexable
		10-11	= 32-bit indexable (Bitmap)
		12-15	= 16-bit indexable
		16-23	= 8-bit indexable
		24-31	= compiled methods (CompiledMethod)"
	| instSpec |
	instSpec := self instSpec.
	instSpec < 9 ifTrue: [^Smalltalk wordSize].
	instSpec >= 16 ifTrue: [^1].
	instSpec >= 12 ifTrue: [^2].
	instSpec >= 10 ifTrue: [^4].
	^8
]

{ #category : #initialization }
Behavior >> emptyMethodDictionary [

	^ MethodDictionary new
]

{ #category : #'accessing-properties' }
Behavior >> ensureProperties [
	^ ClassProperties at: self ifAbsentPut: WeakKeyDictionary new
		
]

{ #category : #naming }
Behavior >> environment [
	"Return the environment in which the receiver is visible"
	^Smalltalk globals
]

{ #category : #testing }
Behavior >> findOriginClassOf: aMethod [

	"I return the origin of my given method. In a basic class is always self.
	Enhanced classes (eg. TraitedClasses) can do something else"
	^ self	

]

{ #category : #testing }
Behavior >> findOriginMethodOf: aMethod [
	"I return the original method for a aMethod.
	When in a normal class it is the same. Enhanced classes (eg. TraitedClasses)
	can do something difference"

	^ aMethod

]

{ #category : #private }
Behavior >> flushCache [
	"Tell the virtual machine to remove the contents of its method lookup caches, if it has any.  This must be done when the system 	modifies the class hierarchy so that message lookups reflect the revised organization.  c.f. Symbol>>flushCache & 	CompiledMethod>>flushCache.  Essential. See MethodDictionary class comment."

	<primitive: 89>
	self primitiveFailed
]

{ #category : #accessing }
Behavior >> format [
	"Answer an Integer that encodes the kinds and numbers of variables of 
	instances of the receiver."

	^format
]

{ #category : #private }
Behavior >> handleFailingBasicNew [
	"handleFailingBasicNew gets sent after basicNew has failed and allowed
	 a scavenging garbage collection to occur.  The scavenging collection
	 will have happened as the VM is activating the (failing) basicNew.  If
	 handleFailingBasicNew fails then the scavenge failed to reclaim sufficient
	 space and a global garbage collection is required.  Retry after garbage
	 collecting and growing memory if necessary.

	 Primitive. Answer an instance of this class with the number of indexable
	 variables specified by the argument, sizeRequested.  Fail if this class is not
	 indexable or if the argument is not a positive Integer, or if there is not
	 enough memory available. Essential. See Object documentation whatIsAPrimitive."

	<primitive: 70>
	Smalltalk garbageCollect < 1048576 ifTrue:
		[Smalltalk growMemoryByAtLeast: 1048576].
	^self handleFailingFailingBasicNew "retry after global garbage collect"
]

{ #category : #private }
Behavior >> handleFailingBasicNew: sizeRequested [
	"handleFailingBasicNew: gets sent after basicNew: has failed and allowed
	 a scavenging garbage collection to occur.  The scavenging collection
	 will have happened as the VM is activating the (failing) basicNew:.  If
	 handleFailingBasicNew: fails then the scavenge failed to reclaim sufficient
	 space and a global garbage collection is required.  Retry after garbage
	 collecting and growing memory if necessary.

	 Primitive. Answer an instance of this class with the number of indexable
	 variables specified by the argument, sizeRequested.  Fail if this class is not
	 indexable or if the argument is not a positive Integer, or if there is not
	 enough memory available. Essential. See Object documentation whatIsAPrimitive."

	<primitive: 71>
	| bytesRequested |
	bytesRequested := self byteSizeOfInstanceOfSize: sizeRequested.
	Smalltalk garbageCollect < bytesRequested ifTrue:
		[Smalltalk growMemoryByAtLeast: bytesRequested].
	"retry after global garbage collect and possible grow"
	^self handleFailingFailingBasicNew: sizeRequested
]

{ #category : #private }
Behavior >> handleFailingFailingBasicNew [
	"This basicNew gets sent after handleFailingBasicNew: has done a full
	 garbage collection and possibly grown memory.  If this basicNew fails
	 then the system really is low on space, so raise the OutOfMemory signal.

	 Primitive. Answer an instance of this class with the number of indexable
	 variables specified by the argument, sizeRequested.  Fail if this class is not
	 indexable or if the argument is not a positive Integer, or if there is not
	 enough memory available. Essential. See Object documentation whatIsAPrimitive."

	<primitive: 70>
	"space must be low"
	OutOfMemory signal.
	^self basicNew  "retry if user proceeds"
]

{ #category : #private }
Behavior >> handleFailingFailingBasicNew: sizeRequested [
	"This basicNew: gets sent after handleFailingBasicNew: has done a full
	 garbage collection and possibly grown memory.  If this basicNew: fails
	 then the system really is low on space, so raise the OutOfMemory signal.

	 Primitive. Answer an instance of this class with the number of indexable
	 variables specified by the argument, sizeRequested.  Fail if this class is not
	 indexable or if the argument is not a positive Integer, or if there is not
	 enough memory available. Essential. See Object documentation whatIsAPrimitive."

	<primitive: 71>
	"space must be low."
	OutOfMemory signal.
	^self basicNew: sizeRequested  "retry if user proceeds"
]

{ #category : #testing }
Behavior >> hasAbstractMethods [
	"Tells whether the receiver locally defines an abstract method, i.e., a method sending subclassResponsibility"
	"we do not use #anySatisfy: for speed"
	
	self methodsDo: [:each | each isAbstract ifTrue: [ ^true ]].
	^false
]

{ #category : #'testing method dictionary' }
Behavior >> hasMethodAccessingVariable: aVariable [
	"Answer true if any of my methods access the variable"

	^self methods anySatisfy: [ :method | aVariable isAccessedIn: method ]
]

{ #category : #'testing method dictionary' }
Behavior >> hasMethods [
	"Answer whether the receiver has any methods in its method dictionary."

	^ self methodDict notEmpty
]

{ #category : #'accessing-properties' }
Behavior >> hasProperty: aKey [
	self propertyAt: aKey ifAbsent: [ ^ false ].
	^ true
]

{ #category : #'testing method dictionary' }
Behavior >> hasSelectorReferringTo: literal [
	"Answer true if any of my methods access the argument as a literal"

	^self methods anySatisfy: [ :method | method hasLiteral: literal ]
]

{ #category : #'testing class hierarchy' }
Behavior >> includesBehavior: aClass [
	
	self isTrait ifTrue: [ ^false ].
	^self == aClass or:[self inheritsFrom: aClass]
]

{ #category : #'testing method dictionary' }
Behavior >> includesLocalSelector: aSymbol [
	^ self includesSelector: aSymbol
]

{ #category : #'testing method dictionary' }
Behavior >> includesMethod: aMethod [ 
	"Answer whether aMethod is in the method dictionary. Use identityIncludes
	as = of CompiledMethod is too weak (ignores the selector)"

	^ self methodDict identityIncludes: aMethod
]

{ #category : #'testing method dictionary' }
Behavior >> includesSelector: aSymbol [ 
	"Answer whether the message whose selector is the argument is in the 
	method dictionary of the receiver's class."

	^ self methodDict includesKey: aSymbol
]

{ #category : #'testing class hierarchy' }
Behavior >> inheritsFrom: aClass [ 
	"Answer whether the argument, aClass, is on the receiver's superclass 
	chain."

	| aSuperclass |
	aSuperclass := self superclass.
	[aSuperclass == nil]
		whileFalse: 
			[aSuperclass == aClass ifTrue: [^true].
			aSuperclass := aSuperclass superclass].
	^false
]

{ #category : #initialization }
Behavior >> initialize [
	"moved here from the class side's #new"
	super initialize.
	self basicSuperclass: Object.
	"no longer sending any messages, some of them crash the VM"
	self methodDict: self emptyMethodDictionary.
	self setFormat: Object format.

]

{ #category : #initialization }
Behavior >> initializeSlots: anObject [ 
	self classLayout initializeInstance: anObject
]

{ #category : #'accessing instances and variables' }
Behavior >> instSize [
	"Answer the number of named instance variables
	(as opposed to indexed variables) of the receiver.
	 Above Cog Spur the class format is
		<5 bits inst spec><16 bits inst size>"
	^format bitAnd: 16rFFFF
]

{ #category : #testing }
Behavior >> instSpec [
	"Answer the instance specification part of the format that defines what kind of object
	 an instance of the receiver is.  The formats are
			0	= 0 sized objects (UndefinedObject True False et al)
			1	= non-indexable objects with inst vars (Point et al)
			2	= indexable objects with no inst vars (Array et al)
			3	= indexable objects with inst vars (MethodContext AdditionalMethodState et al)
			4	= weak indexable objects with inst vars (WeakArray et al)
			5	= weak non-indexable objects with inst vars (ephemerons) (Ephemeron)
			6	= unused
			7	= immediates (SmallInteger, Character)
			8	= unused
			9	= 64-bit indexable
		10-11	= 32-bit indexable (Bitmap)
		12-15	= 16-bit indexable
		16-23	= 8-bit indexable
		24-31	= compiled methods (CompiledMethod)"
	^(self format bitShift: -16) bitAnd: 16r1F
]

{ #category : #'accessing instances and variables' }
Behavior >> instVarNames [
	"Answer an Array of the instance variable names. Behaviors must make 
	up fake local instance variable names because Behaviors have instance 
	variables for the purpose of compiling methods, but these are not named 
	instance variables."

	| mySize superSize |
	mySize := self instSize.
	superSize := self superclass
			ifNil: [0]
			ifNotNil: [self superclass instSize].
	mySize = superSize ifTrue: [^#()].	
	^(superSize + 1 to: mySize) collect: [:i | 'inst' , i printString]
]

{ #category : #'accessing instances and variables' }
Behavior >> instanceCount [
	"Answer the number of instances of the receiver that are currently in 
	use."

	| count |
	count := 0.
	self allInstancesDo: [:x | count := count + 1].
	^count
]

{ #category : #'accessing instances and variables' }
Behavior >> instanceVariables [
	"in older version, this method was returning names, not objects"
	^self slots
]

{ #category : #'memory usage' }
Behavior >> instancesSizeInMemory [
	"Answers the number of bytes consumed by all its instances including their object header"
	
	| bytes |
	bytes := 0.
	self allInstancesDo: [:each | bytes := bytes + each sizeInMemory  ].
	^ bytes
]

{ #category : #testing }
Behavior >> isAbstract [	
	"By default a class is not abstract.
	Hook to mark your own subclasses as abstract."
	
	^false
]

{ #category : #testing }
Behavior >> isAnonymous [
	^true
]

{ #category : #testing }
Behavior >> isBehavior [
	"Return true if the receiver is a behavior"
	^true
]

{ #category : #testing }
Behavior >> isBits [
	"Answer whether the receiver contains just bits (not pointers).
	 Above Cog Spur the class format is
		<5 bits inst spec><16 bits inst size>
	 where the 5-bit inst spec is
			0	= 0 sized objects (UndefinedObject True False et al)
			1	= non-indexable objects with inst vars (Point et al)
			2	= indexable objects with no inst vars (Array et al)
			3	= indexable objects with inst vars (MethodContext AdditionalMethodState et al)
			4	= weak indexable objects with inst vars (WeakArray et al)
			5	= weak non-indexable objects with inst vars (ephemerons) (Ephemeron)
			6	= unused
			7	= immediates (SmallInteger, Character)
			8	= unused
			9	= 64-bit indexable
		10-11	= 32-bit indexable (Bitmap)
		12-15	= 16-bit indexable
		16-23	= 8-bit indexable
		24-31	= compiled methods (CompiledMethod)"
	^self instSpec >= 7
]

{ #category : #testing }
Behavior >> isBytes [
	"Answer whether the receiver has 8-bit instance variables.
	 Above Cog Spur the class format is
		<5 bits inst spec><16 bits inst size>
	 where the 5-bit inst spec is
			0	= 0 sized objects (UndefinedObject True False et al)
			1	= non-indexable objects with inst vars (Point et al)
			2	= indexable objects with no inst vars (Array et al)
			3	= indexable objects with inst vars (MethodContext AdditionalMethodState et al)
			4	= weak indexable objects with inst vars (WeakArray et al)
			5	= weak non-indexable objects with inst vars (ephemerons) (Ephemeron)
			6	= unused
			7	= immediates (SmallInteger, Character)
			8	= unused
			9	= 64-bit indexable
		10-11	= 32-bit indexable (Bitmap)
		12-15	= 16-bit indexable
		16-23	= 8-bit indexable
		24-31	= compiled methods (CompiledMethod)"
	^self instSpec >= 16
]

{ #category : #testing }
Behavior >> isCompact [
	"Backward compatibility with the Squeak V3 object format.
	Spur does not have a distinction between compact and non-compact classes."
	^false
]

{ #category : #testing }
Behavior >> isCompiledMethodClass [
	"Answer whether the receiver has compiled method instances that mix pointers and bytes."
	^self instSpec >= 24
]

{ #category : #'testing method dictionary' }
Behavior >> isDisabledSelector: selector [
	^ self classAndMethodFor: selector do: [:c :m | m isDisabled] ifAbsent: [false]
]

{ #category : #testing }
Behavior >> isEphemeronClass [
	"Answer whether the receiver has ephemeral instance variables.  The garbage collector will
	 fire (queue for finalization) any ephemeron whose first instance variable is not referenced
	 other than from the transitive closure of references from ephemerons. Hence referring to
	 an object from the first inst var of an ephemeron will cause the ephemeron to fire when
	 the rest of the system does not refer to the object and that object is ready to be collected.
	 Since references from the remaining inst vars of an ephemeron will not prevent the ephemeron
	 from firing, ephemerons may act as the associations in weak dictionaries such that the value
	 (e.g. properties attached to the key) will not prevent firing when the key is no longer referenced
	 other than from ephemerons.  Ephemerons can therefore be used to implement instance-based
	 pre-mortem finalization."
	^self instSpec = 5
]

{ #category : #testing }
Behavior >> isFixed [
	"Answer whether the receiver does not have a variable (indexable) part."

	^self isVariable not
]

{ #category : #testing }
Behavior >> isImmediateClass [
	"Answer whether the receiver has immediate instances.  Immediate instances
	 store their value in their object pointer, not in an object body.  Hence immediates
	 take no space and are immutable.  The immediates are distinguished by tag bits
	 in the pointer. They include SmallIntegers and Characters.  Hence in the 32-bit
	 system SmallIntegers are 31-bit signed integers and Characters are 30-bit
	 unsigned character codes."
	^self instSpec = 7
]

{ #category : #testing }
Behavior >> isManifest [
	^ false
]

{ #category : #testing }
Behavior >> isMeta [
	^ false
]

{ #category : #testing }
Behavior >> isObsolete [
	"Return true if the receiver is obsolete."
	^self instanceCount = 0
]

{ #category : #testing }
Behavior >> isPointers [
	"Answer whether the receiver contains just pointers (not bits)."

	^self isBits not
]

{ #category : #testing }
Behavior >> isPool [
	^false
]

{ #category : #testing }
Behavior >> isReferenced [
	"Returns true if the class is referenced from a method."
	^ self binding isReferenced
]

{ #category : #'testing class hierarchy' }
Behavior >> isRootInEnvironment [
	^self superclass isNil
]

{ #category : #testing }
Behavior >> isUsed [
	"the class is used somehow. This is client specific, subclasses can override"

	^ self isReferenced
]

{ #category : #testing }
Behavior >> isVariable [
	"Answer whether the receiver has indexable variables.
	 Above Cog Spur the class format is
		<5 bits inst spec><16 bits inst size>
	 where the 5-bit inst spec is
			0	= 0 sized objects (UndefinedObject True False et al)
			1	= non-indexable objects with inst vars (Point et al)
			2	= indexable objects with no inst vars (Array et al)
			3	= indexable objects with inst vars (MethodContext AdditionalMethodState et al)
			4	= weak indexable objects with inst vars (WeakArray et al)
			5	= weak non-indexable objects with inst vars (ephemerons) (Ephemeron)
			6	= unused
			7	= immediates (SmallInteger, Character)
			8	= unused
			9	= 64-bit indexable
		10-11	= 32-bit indexable (Bitmap)
		12-15	= 16-bit indexable
		16-23	= 8-bit indexable
		24-31	= compiled methods (CompiledMethod)"
	| instSpec |
	instSpec := self instSpec.
	^instSpec >= 2 and: [instSpec <= 4 or: [instSpec >= 9]]
]

{ #category : #testing }
Behavior >> isWeak [
	"Answer whether the receiver has contains weak references."
	^ self instSpec = 4
]

{ #category : #testing }
Behavior >> isWords [
	"Answer true if the receiver is made of 32-bit instance variables."

	^self isBytes not
]

{ #category : #'testing class hierarchy' }
Behavior >> kindOfSubclass [
	"Answer a String that is the keyword that describes the receiver's kind of subclass"
	^ self classLayout kindOfSubclass
]

{ #category : #printing }
Behavior >> longPrintOn: aStream [
	"Append to the argument, aStream, the names and values of all of the receiver's instance variables.  But, not useful for a class with a method dictionary."

	aStream nextPutAll: '<<too complex to show>>'; cr.
]

{ #category : #'accessing method dictionary' }
Behavior >> lookupSelector: selector [
	"Look up the given selector in my methodDictionary.
	Return the corresponding method if found.
	Otherwise chase the superclass chain and try again.
	Return nil if no method is found."
	| lookupClass |
	lookupClass := self.
	[lookupClass == nil]
		whileFalse: [ 
			lookupClass methodDict 
				at: selector
				ifPresent: [ :method | ^ method ].
			lookupClass := lookupClass superclass].
	^ nil
]

{ #category : #accessing }
Behavior >> methodDict [
       "The method dictionary of a class can be nil when we want to use the #cannotInterpret: hook. Indeed when a class dictionary is nil, the VM sends the message cannotInterpret: to the receiver but starting the look up in the superclass of the class whose method dictionary was nil.
	 Now the system relies that when the message methodDict is sent to a class a method dictionary is returned. In order to prevent the complaints of tools and IDE unaware of this feature, we fool them by providing an empty MethodDictionary. This will hopefully work in most cases, but the tools will loose the ability to modify the behaviour of this behavior. The user of #cannotInterpret: should be aware of this."

       ^ methodDict ifNil: [ MethodDictionary new ]
]

{ #category : #'accessing method dictionary' }
Behavior >> methodDict: aDictionary [
	methodDict := aDictionary
]

{ #category : #'accessing method dictionary' }
Behavior >> methodDictionary [
	^self methodDict
]

{ #category : #'accessing method dictionary' }
Behavior >> methodDictionary: aDictionary [
	self methodDict: aDictionary
]

{ #category : #'accessing method dictionary' }
Behavior >> methods [
	
	^ self methodDict values
]

{ #category : #queries }
Behavior >> methodsAccessingSlot: aSlot [
	^self methods select: [ :method | method accessesSlot: aSlot ]
]

{ #category : #'accessing method dictionary' }
Behavior >> methodsDo: aBlock [
	"Evaluate aBlock for all the compiled methods in my method dictionary."

	^ self methodDict valuesDo: aBlock
]

{ #category : #queries }
Behavior >> methodsReadingSlot: aSlot [
	^self methods select: [ :method | method readsSlot: aSlot ]
]

{ #category : #navigation }
Behavior >> methodsReferencingClass: aClass [

	^self methodsReferencingClasses: { aClass }
]

{ #category : #navigation }
Behavior >> methodsReferencingClasses: aCollectionOfClasses [
	^ self methods select: [ :meth | meth referencedClasses includesAny: aCollectionOfClasses ]
]

{ #category : #queries }
Behavior >> methodsWritingSlot: aSlot [
	^self methods select: [ :method | method writesSlot: aSlot ]
]

{ #category : #accessing }
Behavior >> name [
	"Answer a String that is the name of the receiver."
	^'a subclass of ', self superclass name.
]

{ #category : #'instance creation' }
Behavior >> new [
	"Answer a new initialized instance of the receiver (which is a class) with no indexable variables. Fail if the class is indexable."

	^ self basicNew initialize

]

{ #category : #'instance creation' }
Behavior >> new: sizeRequested [ 
	"Answer an initialized instance of this class with the number of indexable
	variables specified by the argument, sizeRequested."

	^ (self basicNew: sizeRequested) initialize  
]

{ #category : #initialization }
Behavior >> nonObsoleteClass [
	"Attempt to find and return the current version of this obsolete class"

	| obsName |
	obsName := self name.
	[obsName beginsWith: 'AnObsolete']
		whileTrue: [obsName := obsName copyFrom: 'AnObsolete' size + 1 to: obsName size].
	^ self environment at: obsName asSymbol
]

{ #category : #initialization }
Behavior >> obsolete [
	"nothing to be done"
]

{ #category : #'obsolete subclasses' }
Behavior >> obsoleteSubclasses [
	"Return all the weakly remembered obsolete subclasses of the receiver"
	| obs |
	obs := self basicObsoleteSubclasses at: self ifAbsent: [^ #()].
	^ obs copyWithout: nil
]

{ #category : #copying }
Behavior >> postCopy [
	super postCopy.
	self methodDict: self methodDict copy
]

{ #category : #queries }
Behavior >> pragmas [
	^ self methods flatCollect: [ :method | method pragmas ]
]

{ #category : #queries }
Behavior >> pragmasDo: aBlock [
	self methodsDo: [ :method | method pragmasDo: aBlock ]
]

{ #category : #printing }
Behavior >> printOn: aStream [ 
	"Refer to the comment in Object|printOn:." 

	aStream nextPutAll: 'a descendent of '.
	self superclass printOn: aStream
]

{ #category : #'accessing-properties' }
Behavior >> properties [
	^ ClassProperties at: self ifAbsent: nil
		
]

{ #category : #'accessing-properties' }
Behavior >> propertyAt: propName [
	^ self
		propertyAt: propName
		ifAbsent: [ nil ]
]

{ #category : #'accessing-properties' }
Behavior >> propertyAt: propName ifAbsent: aBlock [
	self properties ifNil: [^aBlock value].
	^ self properties
		at: propName
		ifAbsent: aBlock
]

{ #category : #'accessing-properties' }
Behavior >> propertyAt: propName put: propValue [
	^ self ensureProperties
		at: propName
		ifAbsentPut: propValue
]

{ #category : #accessing }
Behavior >> realClass [

	^ self
]

{ #category : #'obsolete subclasses' }
Behavior >> removeAllObsoleteSubclasses [
	"Remove all the obsolete subclasses of the receiver"
	self basicObsoleteSubclasses removeKey: self ifAbsent: [].

]

{ #category : #'accessing-properties' }
Behavior >> removePropertiesIfEmpty [
	^ ClassProperties at: self ifPresent: [ :dict |
		dict ifEmpty: [ ClassProperties removeKey: self ] ]
		
]

{ #category : #'accessing-properties' }
Behavior >> removeProperty: propName [
	^ self
		removeProperty: propName
		ifAbsent: [ nil ]
]

{ #category : #'accessing-properties' }
Behavior >> removeProperty: propName ifAbsent: aBlock [
	| property |
	self properties ifNil: [^aBlock value].
	property := self properties
		removeKey: propName
		ifAbsent: aBlock.
	self removePropertiesIfEmpty.
	^ property
]

{ #category : #'accessing method dictionary' }
Behavior >> removeSelector: aSelector [
	"Assuming that the argument, selector (a Symbol), is a message selector in my method dictionary, remove it and its method."

	self methodDict removeKey: aSelector ifAbsent: []
]

{ #category : #'adding/removing methods' }
Behavior >> removeSelectorSilently: selector [ 
	"Remove selector without sending system change notifications"

	^ SystemAnnouncer uniqueInstance suspendAllWhile: [self removeSelector: selector].
]

{ #category : #cleanup }
Behavior >> restartMethods [
	"Clean up. Long running loops or stored closures can lead to methods that are out if sync with the recompiled code. Subclasses should override this method if they need to restart methods"

]

{ #category : #enumerating }
Behavior >> selectSubclasses: aBlock [ 
	"Evaluate the argument, aBlock, with each of the receiver's (next level) 
	subclasses as its argument. Collect into a Set only those subclasses for 
	which aBlock evaluates to true. In addition, evaluate aBlock for the 
	subclasses of each of these successful subclasses and collect into the set 
	those for which aBlock evaluates true. Answer the resulting set."

	| aSet |
	aSet := Set new.
	self allSubclasses do: 
		[:aSubclass | 
		(aBlock value: aSubclass) ifTrue: [aSet add: aSubclass]].
	^aSet
]

{ #category : #enumerating }
Behavior >> selectSuperclasses: aBlock [ 
	"Evaluate the argument, aBlock, with the receiver's superclasses as the 
	argument. Collect into an OrderedCollection only those superclasses for 
	which aBlock evaluates to true. In addition, evaluate aBlock for the 
	superclasses of each of these successful superclasses and collect into the 
	OrderedCollection ones for which aBlock evaluates to true. Answer the 
	resulting OrderedCollection."

	| aSet |
	aSet := Set new.
	self allSuperclasses do: 
		[:aSuperclass | 
		(aBlock value: aSuperclass) ifTrue: [aSet add: aSuperclass]].
	^aSet
]

{ #category : #'accessing method dictionary' }
Behavior >> selectors [
	"Answer a Set of all the message selectors specified in the receiver's 
	method dictionary."

	^ self methodDict keys
]

{ #category : #'accessing method dictionary' }
Behavior >> selectorsAndMethodsDo: selectorAndMethodBlock [
	"Evaluate selectorAndMethodBlock with two arguments for each selector/method pair in my method dictionary."

	^ self methodDict keysAndValuesDo: selectorAndMethodBlock
]

{ #category : #'accessing method dictionary' }
Behavior >> selectorsDo: selectorBlock [
	"Evaluate selectorBlock for all the message selectors in my method dictionary."

	^ self methodDict keysDo: selectorBlock
]

{ #category : #'accessing method dictionary' }
Behavior >> selectorsWithArgs: numberOfArgs [
	"Return all selectors defined in this class that take this number of arguments"

	^ self selectors select: [:selector | selector numArgs = numberOfArgs]
]

{ #category : #private }
Behavior >> setFormat: aFormatInstanceDescription [
	"only use this method with extreme care since it modifies the format of the class 
     ie a description of the number of instance variables and whether the class is
     compact, variable sized"

	format := aFormatInstanceDescription


]

{ #category : #testing }
Behavior >> shouldNotBeRedefined [
	"Answer if the receiver should not be redefined.
	 The assumption is that classes in Smalltalk specialObjects and 
	 instance-specific Behaviors should not be redefined"

	^(Smalltalk specialObjectsArray
		identityIndexOf: self
		ifAbsent: [(self isKindOf: self) ifTrue: [1] ifFalse: [0]]) ~= 0
]

{ #category : #'system startup' }
Behavior >> shutDown [
	"This message is sent on system shutdown to registered classes"

]

{ #category : #'system startup' }
Behavior >> shutDown: quitting [
	"This message is sent on system shutdown to registered classes"
	^self shutDown.
]

{ #category : #accessing }
Behavior >> slots [
	^#()
]

{ #category : #'accessing instances and variables' }
Behavior >> someInstance [
	"Primitive. Answer the first instance in the enumeration of all instances 
	of the receiver. Fails if there are none. Essential. See Object 
	documentation whatIsAPrimitive."

	<primitive: 77>
	^nil
]

{ #category : #'accessing method dictionary' }
Behavior >> sourceCodeAt: selector [

	^ (self compiledMethodAt: selector) sourceCode.
]

{ #category : #'accessing method dictionary' }
Behavior >> sourceCodeAt: selector ifAbsent: aBlock [

	^ (self compiledMethodAt: selector ifAbsent: [^ aBlock value]) sourceCode.
]

{ #category : #compiling }
Behavior >> sourceCodeTemplate [
	"Answer an expression to be edited and evaluated in order to define 
	methods in this class or trait."

	^ 'methodSelectorAndArgumentNames
	"comment stating purpose of instance-side method"
	"scope: class-variables  &  instance-variables"	
			
	| temporary variable names |
	statements'
]

{ #category : #testing }
Behavior >> sourceMatchesBytecodeAt: selector [
	"Answers true if the source code at the selector compiles to the bytecode at the selector, and false
	otherwise. Implemented to detect an error where Monticello did not recompile sources when the class
	shape changed"

	"This code was copied from #recompile:from:, with few changes. Several methods would benefit from a
	method which turned a selector and class into a CompiledMethod, without  installing it into the 
	methodDictionary"

	| method newMethod |

	method := self compiledMethodAt: selector.
	newMethod := self compiler
			source: (self sourceCodeAt: selector);
			class: self;
			failBlock: [^ false];
			compiledMethodTrailer: method trailer;
			compile.   "Assume OK after proceed from SyntaxError"
	selector == newMethod selector ifFalse: [self error: 'selector changed!!'].
	^ newMethod = method
]

{ #category : #private }
Behavior >> spaceUsed [
	"Answer a rough estimate of number of bytes used by this class and its metaclass. Does not include space used by class variables."

	| space |
	space := 0.
	self methodsDo: [:method  |
		space := space + 16.  "dict and org'n space"
		space := space + (method size + 6 "hdr + avg pad").
		method literalsDo: [:lit |
			(lit isMemberOf: Array) ifTrue: [space := space + ((lit size + 1) * 4)].
			(lit isMemberOf: Float) ifTrue: [space := space + 12].
			(lit isMemberOf: ByteString) ifTrue: [space := space + (lit size + 6)].
			(lit isMemberOf: LargeNegativeInteger) ifTrue: [space := space + ((lit size + 1) * 4)].
			(lit isMemberOf: LargePositiveInteger) ifTrue: [space := space + ((lit size + 1) * 4)]]].
		^ space
]

{ #category : #'system startup' }
Behavior >> startUp [
	"This message is sent to registered classes when the system is coming up."
 
]

{ #category : #'system startup' }
Behavior >> startUp: resuming [
	"This message is sent to registered classes when the system is coming up."
	^self startUp
]

{ #category : #accessing }
Behavior >> subclassDefinerClass [
	"Answer an evaluator class appropriate for evaluating definitions of new 
	subclasses of this class."

	^Smalltalk compilerClass
]

{ #category : #'accessing instances and variables' }
Behavior >> subclassInstVarNames [
	"Answer a Set of the names of the receiver's subclasses' instance variables."
	^self allSubclasses flatCollectAsSet: [:aSubclass | aSubclass instVarNames]
]

{ #category : #'accessing class hierarchy' }
Behavior >> superclass [
	"Answer the receiver's superclass, a Class."

	^superclass
]

{ #category : #'accessing class hierarchy' }
Behavior >> superclass: aClass [

	"Change the receiver's superclass to be aClass."

	"Note: Do not use 'aClass isKindOf: Behavior' here
		in case we recompile from Behavior itself."

	aClass
		ifNil: [ self basicSuperclass: aClass.
			Object flushCache.
			^ self
			].	"If the class is not nil it should update the class hierarchy correctly, using the classs builder"
	^ self classInstaller
		update: self
		to: [ :builder | 
			builder
				fillFor: self;
				superclass: aClass
			]
]

{ #category : #initialization }
Behavior >> superclass: aClass methodDictionary: mDict format: fmt [
	"Basic initialization of the receiver.
	Must only be sent to a new instance; else we would need Object flushCache."
	self basicSuperclass: aClass.
	self setFormat: fmt.
	self methodDict: mDict.

]

{ #category : #'testing method dictionary' }
Behavior >> thoroughHasSelectorReferringTo: literal [
	"Answer true if any of my methods access the argument as a 
	literal. Dives into the compact literal notation, making it slow but 
	thorough "
	
	| specialIndex |
	"for speed we check the special selectors here once per class"
	specialIndex := Smalltalk specialSelectorIndexOrNil: literal.
	^self methods anySatisfy: [ :method | 
		method hasSelector: literal specialSelectorIndex: specialIndex]
		
]

{ #category : #'testing method dictionary' }
Behavior >> thoroughWhichMethodsReferTo: literal [
	"Answer methods whose methods referes to the argument as a literal. 
	 Dives into the compact literal notation and embedded literal arrays, 
    making it slow but thorough "

	| specialIndex |
	"for speed we check the special selectors here once per class"
	specialIndex := Smalltalk specialSelectorIndexOrNil: literal.
	^ self methods select: [ :method | method hasSelector: literal specialSelectorIndex: specialIndex ]
]

{ #category : #'testing method dictionary' }
Behavior >> thoroughWhichSelectorsReferTo: literal [
	^ (self thoroughWhichMethodsReferTo: literal) collect: [ :method | method selector ]
]

{ #category : #accessing }
Behavior >> typeOfClass [
	"Answer a symbol uniquely describing the type of the receiver. c.f. kindOfSubclass"
	^self classLayout typeOfClass
]

{ #category : #'user interface' }
Behavior >> unreferencedInstanceVariables [
	"Return a list of the instance variables defined in the receiver which are not referenced in the receiver or any of its subclasses."

	^ self slots reject: [:slot | slot isReferenced]
]

{ #category : #queries }
Behavior >> usingMethods [
	"all methods that reference me"
	self isAnonymous ifTrue: [ ^#() ].
	^self binding usingMethods
]

{ #category : #queries }
Behavior >> whichClassDefinesClassVar: aString [ 
	Symbol hasInterned: aString ifTrue: [ :aSymbol |
		^self whichSuperclassSatisfies: 
			[:aClass | 
			aClass classVarNames anySatisfy: [:each | each = aSymbol]]].
	^#()
]

{ #category : #queries }
Behavior >> whichClassDefinesInstVar: aString [ 
	^self 
		whichSuperclassSatisfies: [:aClass | aClass instVarNames includes: aString]
]

{ #category : #'testing method dictionary' }
Behavior >> whichClassIncludesSelector: aSymbol [ 
	"Answer the class on the receiver's superclass chain where the 
	argument, aSymbol (a message selector), will be found. Answer nil if none found."
	"Rectangle whichClassIncludesSelector: #inspect."
	(self includesSelector: aSymbol)
		ifTrue: [^ self].
	self superclass == nil
		ifTrue: [^ nil].
	^ self superclass whichClassIncludesSelector: aSymbol
]

{ #category : #'testing method dictionary' }
Behavior >> whichMethodsReferTo: aLiteral [
	"Answer methods whose methods directly refers to the argument as a literal"

	^ self methods select: [ :method | method hasLiteral: aLiteral ]
]

{ #category : #'testing method dictionary' }
Behavior >> whichSelectorsReferTo: literal [
	^ (self whichMethodsReferTo: literal) collect: [ :method | method selector ]
]

{ #category : #queries }
Behavior >> whichSuperclassSatisfies: aBlock [ 
	(aBlock value: self) ifTrue: [^self].
	^self superclass ifNotNil: [self superclass whichSuperclassSatisfies: aBlock]
]

{ #category : #'user interface' }
Behavior >> withAllSubAndSuperclassesDo: aBlock [

	self withAllSubclassesDo: aBlock.
	self allSuperclassesDo: aBlock.

]

{ #category : #'accessing class hierarchy' }
Behavior >> withAllSubclasses [
	"Answer a Set of the receiver, the receiver's descendent's, and the  
	receiver's descendent's subclasses."

	^ self allSubclasses add: self;
		 yourself
]

{ #category : #'accessing class hierarchy' }
Behavior >> withAllSubclassesDo: aBlock [
	"Evaluate the argument, aBlock, for the receiver and each of its subclasses."
	
	self withAllSubclasses do: aBlock
]

{ #category : #'accessing class hierarchy' }
Behavior >> withAllSuperAndSubclasses [
	"Answer the receiver's class hierarchy"

	^self allSuperclasses, self withAllSubclasses
]

{ #category : #enumerating }
Behavior >> withAllSuperAndSubclassesDo: aBlock [
	self allSuperclassesDo: aBlock.
	aBlock value: self.
	self allSubclassesDo: aBlock
]

{ #category : #'accessing class hierarchy' }
Behavior >> withAllSuperclasses [
	"Answer an OrderedCollection of the receiver and the receiver's superclasses. 
	The first element is the receiver, followed by its superclass; 
	the last element is Object."

	^self allSuperclasses 
		addFirst: self; 
		yourself

]

{ #category : #enumerating }
Behavior >> withAllSuperclassesDo: aBlock [ 
	"Evaluate the argument, aBlock, for each of the receiver's superclasses."
	aBlock value: self.
	self superclass == nil
		ifFalse: [self superclass withAllSuperclassesDo: aBlock]
]
