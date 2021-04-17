Class {
	#name : #LegacyClassDefinitionPrinter,
	#superclass : #ClassDefinitionPrinter,
	#category : #'Kernel-ClassDefinitionPrinter'
}

{ #category : #'public API' }
LegacyClassDefinitionPrinter >> classDefinitionString [

	"Answer a String that defines the receiver in the old format using poolDictionaries and category.
	e.g,  
	'Object subclass: #Point
		instanceVariableNames: ''x y''
		classVariableNames: ''''
		poolDictionaries: ''''
		category: ''Kernel-BasicObjects'''
	"

	| aStream |
	aStream := (String new: 800) writeStream.
	forClass superclass
		ifNil: [aStream nextPutAll: 'ProtoObject']
		ifNotNil: [aStream nextPutAll: forClass superclass name].
	aStream nextPutAll: forClass kindOfSubclass;
			store: forClass name.
	(forClass hasTraitComposition) ifTrue: [
		aStream cr; tab; nextPutAll: 'uses: ';
			nextPutAll: forClass traitCompositionString].
	aStream cr; tab; nextPutAll: 'instanceVariableNames: ';
			store: forClass instanceVariablesString.
	aStream cr; tab; nextPutAll: 'classVariableNames: ';
			store: forClass classVariablesString.
	aStream cr; tab; nextPutAll: 'poolDictionaries: ';
			store: forClass sharedPoolsString.
	aStream cr; tab; nextPutAll: 'category: ';
			store: forClass category asString.

	forClass superclass ifNil: [ 
		aStream nextPutAll: '.'; cr.
		aStream nextPutAll: forClass name.
		aStream space; nextPutAll: 'superclass: nil'. ].

	^ aStream contents
]

{ #category : #template }
LegacyClassDefinitionPrinter >> classDefinitionTemplateInPackage: aString [

	^ String streamContents: [ :s |
			s nextPutAll: 'Object subclass: #MyClass' ; crtab.
			s nextPutAll: 'instanceVariableNames: '''' '; crtab. 
			s nextPutAll: 'classVariableNames: '''''; crtab.
			s nextPutAll: 'poolDictionaries: '''''; crtab.
			s nextPutAll: 'category ''', aString, '''' ]
]

{ #category : #delegating }
LegacyClassDefinitionPrinter >> expandedDefinitionString [
	"We do not support expansion on legacy syntax so we shortcut the double dispatch call."
	^ self definitionString
]

{ #category : #'public API' }
LegacyClassDefinitionPrinter >> metaclassDefinitionString [

	^ String streamContents: [:stream |
		stream print: forClass.
		stream
			crtab;
			nextPutAll: 'instanceVariableNames: ';
			store: forClass instanceVariablesString ]
]

{ #category : #template }
LegacyClassDefinitionPrinter >> testClassDefinitionTemplateInPackage: aString [

	^ String streamContents: [ :s |
			s nextPutAll: 'TestCase subclass: #MyTest' ; crtab.
			s nextPutAll: 'instanceVariableNames: '''' '; crtab. 
			s nextPutAll: 'classVariableNames: '''''; crtab.
			s nextPutAll: 'poolDictionaries: '''''; crtab.
			s nextPutAll: 'category ''', aString, '''' ]
]

{ #category : #'public API' }
LegacyClassDefinitionPrinter >> traitDefinitionString [

	^ String streamContents: [ :s | 
		s 
			nextPutAll: 'Trait named: ';
			nextPutAll:	forClass name printString;
			cr; tab; 
			nextPutAll: ' uses: ';
			nextPutAll: forClass traitComposition traitCompositionExpression; 
			cr;
			tab;
			nextPutAll: ' package: ';
			nextPutAll: forClass category asString printString
	]
]

{ #category : #'public API' }
LegacyClassDefinitionPrinter >> traitedMetaclassDefinitionString [

	^ self metaclassDefinitionString
]
