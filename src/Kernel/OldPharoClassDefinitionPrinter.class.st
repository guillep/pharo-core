Class {
	#name : #OldPharoClassDefinitionPrinter,
	#superclass : #ClassDefinitionPrinter,
	#category : #'Kernel-ClassDefinitionPrinter'
}

{ #category : #internal }
OldPharoClassDefinitionPrinter >> basicClassDefinitionString [

	"Pay attention this definition is fragile in presence of complex slots. Use the public API i.e., classDefinitionString"

	| stream |
	stream := (String new: 800) writeStream.
	forClass superclass
		ifNotNil: [ stream nextPutAll: forClass superclass name ]
		ifNil: [ stream nextPutAll: 'ProtoObject' ].
	stream
		nextPutAll: forClass kindOfSubclass;
		store: forClass name.
	self traitCompositionOn: stream.
	self instanceVariablesOn: stream.
	self classVariablesOn: stream.
	self poolOn: stream.
	self packageOn: stream.
	forClass superclass ifNil: [ 
		stream
			nextPutAll: '.';
			cr.
		stream nextPutAll: forClass name.
		stream
			space;
			nextPutAll: 'superclass: nil' ].
	^ stream contents
]

{ #category : #internal }
OldPharoClassDefinitionPrinter >> basicMetaclassDefinitionString [

	"Pay attention this definition is fragile in presence of complex slots. Use the public API i.e., classDefinitionString"

	^ String streamContents: [ :stream | 
		  stream print: forClass.
		  self instanceVariablesOn: stream ]
]

{ #category : #internal }
OldPharoClassDefinitionPrinter >> basicTraitDefinitionString [

	"Pay attention this definition is fragile in presence of complex slots. Use the public API i.e., classDefinitionString"

	forClass instanceSide name == #Trait ifTrue: [ 
		^ self classDefinitionString ].

	^ String streamContents: [ :s | 
		  s
			  nextPutAll: 'Trait named: ';
			  nextPutAll: forClass name printString.
		  self traitCompositionOn: s.
		  self instanceVariablesOn: s.
		  self packageOn: s ]
]

{ #category : #internal }
OldPharoClassDefinitionPrinter >> basicTraitedMetaclassDefinitionString [ 

	^ String streamContents: [:strm |
			strm print: forClass.
			self traitCompositionOn: strm.
			self instanceVariablesOn: strm ]
]

{ #category : #'public API' }
OldPharoClassDefinitionPrinter >> classDefinitionString [

	^ forClass needsSlotClassDefinition 
		ifTrue: [ (ClassDefinitionPrinter fluid for: forClass) classDefinitionString ]
		ifFalse: [ self basicClassDefinitionString ]
]

{ #category : #template }
OldPharoClassDefinitionPrinter >> classDefinitionTemplateInPackage: aString [

	^ String streamContents: [ :s |
			s nextPutAll: 'Object subclass: #MyClass' ; crtab.
			s nextPutAll: 'instanceVariableNames: '''' '; crtab. 
			s nextPutAll: 'classVariableNames: '''''; crtab.
			s nextPutAll: 'package: ''', aString, '''' ]
]

{ #category : #'low-level elements' }
OldPharoClassDefinitionPrinter >> classVariablesOn: stream [

	stream
		crtab;
		nextPutAll: 'classVariableNames: '''.
	forClass classVariablesOn: stream.
	stream nextPut: $'
]

{ #category : #template }
OldPharoClassDefinitionPrinter >> compactClassDefinitionTemplateInPackage: aString [
	"there is not compact version..."

	^ self classDefinitionTemplateInPackage: aString
]

{ #category : #template }
OldPharoClassDefinitionPrinter >> compactTraitDefinitionTemplateInPackage: aString [

	^ self traitDefinitionTemplateInPackage: aString
]

{ #category : #'public API' }
OldPharoClassDefinitionPrinter >> expandedDefinitionString [
	"We do not support expanded on old Pharo syntax so we shortcut the double dispatch call."
	^ self definitionString 
]

{ #category : #'low-level elements' }
OldPharoClassDefinitionPrinter >> instanceVariablesOn: stream [

	stream
		crtab;
		nextPutAll: 'instanceVariableNames: '''.
	forClass instanceVariablesOn: stream.
	stream nextPut: $'
]

{ #category : #'public API' }
OldPharoClassDefinitionPrinter >> metaclassDefinitionString [ 

	^ forClass needsSlotClassDefinition 
		ifTrue: [ (ClassDefinitionPrinter fluid for: forClass) metaclassDefinitionString ]
		ifFalse: [ self basicMetaclassDefinitionString ]
]

{ #category : #'low-level elements' }
OldPharoClassDefinitionPrinter >> packageOn: stream [

	stream
		crtab;
		nextPutAll: 'package: ';
		store: forClass category asString
]

{ #category : #'low-level elements' }
OldPharoClassDefinitionPrinter >> poolOn: stream [

	| poolString |
	poolString := forClass sharedPoolsString.
	poolString = '' ifFalse: [ 
		stream
			crtab;
			nextPutAll: 'poolDictionaries: ';
			store: poolString ]
]

{ #category : #template }
OldPharoClassDefinitionPrinter >> testClassDefinitionTemplateInPackage: aString [

	^ String streamContents: [ :s |
			s nextPutAll: 'TestCase subclass: #MyTest' ; crtab.
			s nextPutAll: 'instanceVariableNames: '''' '; crtab. 
			s nextPutAll: 'classVariableNames: '''''; crtab.
			s nextPutAll: 'package: ''', aString, '''' ]
]

{ #category : #'low-level elements' }
OldPharoClassDefinitionPrinter >> traitCompositionOn: stream [

	forClass hasTraitComposition ifTrue: [ 
		stream
			crtab;
			nextPutAll: 'uses: ';
			nextPutAll: forClass traitCompositionString ]
]

{ #category : #'public API' }
OldPharoClassDefinitionPrinter >> traitDefinitionString [ 

	^ forClass needsSlotClassDefinition 
		ifTrue: [ (ClassDefinitionPrinter fluid for: forClass) traitDefinitionString ]
		ifFalse: [ self basicTraitDefinitionString ]
]

{ #category : #template }
OldPharoClassDefinitionPrinter >> traitDefinitionTemplateInPackage: aString [

	^ String streamContents: [ :s |
			s nextPutAll: 'Trait named: #TMyTraits
	 uses: {}
	 package: '''.
			s nextPutAll: aString; nextPut: $' ]
 
]

{ #category : #'public API' }
OldPharoClassDefinitionPrinter >> traitedMetaclassDefinitionString [ 

	^ forClass needsSlotClassDefinition 
		ifTrue: [ (ClassDefinitionPrinter fluid for: forClass) traitedMetaclassDefinitionString ]
		ifFalse: [ self basicTraitedMetaclassDefinitionString ]
]
