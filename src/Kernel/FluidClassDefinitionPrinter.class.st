"
```
Object < #MyClass
	layout: FixedLayout;
	uses: {};
	slots: {};
	sharedVariables: {};
	sharedPools: {};
	tag: '' ;
	package: 'FluidClassDefinition-Printer-UnderDev'
```

is the template definition for the fluid syntax


This is the fluid definition of the current class :).

```
ClassDefinitionPrinter < #FluidClassDefinitionPrinter
	tag: 'Printer-UnderDev';
	package: 'FluidClassDefinition'
```

You can also configure it to display empty slots.

``` 
ClassDefinitionPrinter displayEmptySlots: true
```


"
Class {
	#name : #FluidClassDefinitionPrinter,
	#superclass : #ClassDefinitionPrinter,
	#category : #'Kernel-ClassDefinitionPrinter'
}

{ #category : #'definition double dispatch API' }
FluidClassDefinitionPrinter >> classDefinitionString [

	"Next step
		- some of the methods defined on classe will have to be moved in this class.
		- refactor to remove duplication with metaclass,...."

	^ String streamContents: [ :s | 
		  forClass superclass
			  ifNotNil: [ s nextPutAll: forClass superclass name ]
			  ifNil: [ s nextPutAll: 'nil' ].
			
		  self msgAndClassNameOn: s.
		  forClass classLayout isFixedLayout 
				ifFalse: [ self layoutOn: s ].

			self traitsOn: s.
			self class displayEmptySlots 
				ifTrue: [ self slotsOn: s ]
		  		ifFalse: [forClass slots ifNotEmpty: [ self slotsOn: s ]].
		  forClass classVariables ifNotEmpty: [ self sharedVariablesOn: s ].
		  forClass sharedPools ifNotEmpty: [ self sharedPoolsOn: s ].

		  self tagOn: s.
		  self packageOn: s ]
]

{ #category : #printing }
FluidClassDefinitionPrinter >> classDefinitionTemplateInPackage: aPackageName [

		^ String streamContents: [ :s |
						s nextPutAll: 'Object << #MyClass'; crtab.
						s nextPutAll: 'layout: FixedLayout;'; crtab.
						s nextPutAll: 'uses: {};'; crtab.
						s nextPutAll: 'slots: {};'; crtab. 
						s nextPutAll: 'sharedVariables: {};'; crtab.
						s nextPutAll: 'sharedPools: {};'; crtab.
						s nextPutAll: 'tag: '''' ;';crtab.
						s nextPutAll: 'package: ''', aPackageName, '''' ] 
]

{ #category : #'elementary operations' }
FluidClassDefinitionPrinter >> classVariableDefinitionsOn: aStream [ 
	"Answer a string that evaluates to the definition of the class Variables"
	
		| fullDef |
		forClass classVariables 
			ifEmpty: [ aStream nextPutAll: '{}' ]
			ifNotEmpty:[  :clsVars|
		aStream nextPutAll: '{'.
		clsVars do: [:global |
				aStream space. 
				aStream nextPutAll: global definitionString.
				fullDef := global needsFullDefinition.
				aStream space.]				
			separatedBy: [ 
				aStream nextPutAll: '.'.  
				fullDef ifTrue: [ aStream cr;tab;tab;tab;tab ]].
		aStream nextPutAll: '}'. ]
]

{ #category : #template }
FluidClassDefinitionPrinter >> compactClassDefinitionTemplateInPackage: aPackageName [ 
	^ String streamContents: [ :s |
			s nextPutAll: 'Object << #MyClass'; crtab.
			s nextPutAll: 'slots: {};'; crtab. 
			s nextPutAll: 'sharedVariables: {};'; crtab.
			s nextPutAll: 'package: ''', aPackageName, '''' ] 
]

{ #category : #template }
FluidClassDefinitionPrinter >> compactTraitDefinitionTemplateInPackage: aPackageName [
	
	^ String streamContents: [ :s | 
		  s
			  nextPutAll: 'Trait << #TMyTrait';  crtab;
			  nextPutAll: 'uses: {};'; crtab ;
			  nextPutAll: 'slots: {};'; crtab ;
			  nextPutAll: 'package: ''';
			  nextPutAll: aPackageName;
			  nextPutAll: '''' ]
]

{ #category : #'expanded double dispatch API' }
FluidClassDefinitionPrinter >> expandedClassDefinitionString [

	^ String streamContents: [ :s | 
		s nextPutAll: forClass superclass name.
		self msgAndClassNameOn: s.
		self layoutOn: s.
		s crtab.
		s nextPutAll: 'uses: '.
		forClass hasTraitComposition
			ifTrue: [ s nextPutAll: forClass traitCompositionString ]
			ifFalse: [ s nextPutAll: '{};' ].
		self slotsOn: s.
		self sharedVariablesOn: s.
		self sharedPoolsOn: s.
		
		(forClass package classTagForClass: forClass) ifNotNil: [ :t |
			| tag | 
			tag := t name.
			tag = forClass package name 
				ifTrue: [ s crtab; nextPutAll: 'tag: '''';' ]
				ifFalse: [ self tagOn: s]].
			self packageOn: s ]
]

{ #category : #'expanded double dispatch API' }
FluidClassDefinitionPrinter >> expandedMetaclassDefinitionString [
	
	^ String streamContents: [ :s | 
		forClass  
			ifNotNil: [ s nextPutAll: forClass name ]
			ifNil: [ s nextPutAll: 'ProtoObject ' ].
		s crtab. 
		forClass hasTraitComposition 
			ifTrue: [
				s 
					nextPutAll: 'uses: ';
					nextPutAll: forClass traitCompositionString;
					nextPutAll: ';']
			ifFalse: [ s nextPutAll: 'uses: {};'].
		s crtab.
		s nextPutAll: 'slots: '.
		self slotDefinitionsOn: s. 
		]
]

{ #category : #'expanded double dispatch API' }
FluidClassDefinitionPrinter >> expandedTraitDefinitionString [
	
	^ String streamContents: [ :s |		
		| tag |
		s nextPutAll: 'Trait'.
		self msgAndClassNameOn: forClass name.
		
		s crtab.
		s nextPutAll: 'uses: '.
		forClass hasTraitComposition
			ifTrue: [ s nextPutAll: forClass traitCompositionString ]
			ifFalse: [ s nextPutAll: '{};' ].
		self slotsOn: s.

		s 	
			nextPutAll: 'sharedVariables: ';
			nextPutAll: forClass classVariableDefinitionString;
			nextPutAll: ';'; crtab.
							
		s nextPutAll: 'sharedPools: {'.
		self sharedPoolsOn: s.
		s nextPutAll: '};' ; crtab.
						
		(forClass package classTagForClass: forClass) ifNotNil: [:t | 
							tag := t name.
							tag = forClass package name
								ifFalse:  [
									s nextPutAll: 'tag: '; 
					nextPut: $'; 
					nextPutAll: tag asString ; 
					nextPutAll: ''';'.
					s crtab
				]].
				
				s 
					nextPutAll: 'package: ''';
					nextPutAll: forClass package packageName;
					nextPutAll: '''' ]
]

{ #category : #'elementary operations' }
FluidClassDefinitionPrinter >> lastSlotsOn: s [

	s crtab.
	s nextPutAll: 'slots: '.
	self slotDefinitionsOn: s.
]

{ #category : #'elementary operations' }
FluidClassDefinitionPrinter >> lastTraitsOn: strm [
	"uses: can the last part of a definition so watch out for terminating ;"
	
	forClass hasTraitComposition ifTrue: [
		strm 
			crtab; 
			nextPutAll: 'uses: ';
			nextPutAll: forClass traitCompositionString.
	forClass slots	ifNotEmpty: [ strm nextPutAll: ';' ] ].
]

{ #category : #'elementary operations' }
FluidClassDefinitionPrinter >> layoutOn: s [
	"Layout is always followed by other message ultimately package: so it terminates with ;"
	s
		crtab;
		nextPutAll: 'layout: ';
		nextPutAll: forClass classLayout class name;
		nextPutAll: ';'
]

{ #category : #'definition double dispatch API' }
FluidClassDefinitionPrinter >> metaclassDefinitionString [ 

	^ String streamContents: [ :strm |
		forClass superclass 
			ifNotNil: [ strm nextPutAll: forClass name ]
			ifNil: [ strm nextPutAll: 'ProtoObject ' ].
		self lastTraitsOn: strm.
		forClass slots ifNotEmpty: [ self lastSlotsOn: strm ] ]
]

{ #category : #'elementary operations' }
FluidClassDefinitionPrinter >> msgAndClassNameOn: s [

	s
		nextPutAll: ' << #';
		nextPutAll: forClass name
]

{ #category : #'elementary operations' }
FluidClassDefinitionPrinter >> packageOn: s [

	s
		crtab;
	 	nextPutAll: 'package: ';
		nextPut: $';
		nextPutAll: forClass package packageName;
		nextPut: $'
]

{ #category : #'elementary operations' }
FluidClassDefinitionPrinter >> sharedPoolsOn: s [
	"shared pool message is always followed by other message ultimately package: so it terminates with ;"
	s
		crtab;
		nextPutAll: 'sharedPools: {'.
	forClass sharedPools
		do: [ :p | 
			s space.
			s nextPutAll: p name.
			s space ]
		separatedBy: [ s nextPutAll: '.' ].
	s
		nextPutAll: '};'
]

{ #category : #'elementary operations' }
FluidClassDefinitionPrinter >> sharedVariablesOn: s [
	"shared variable is always followed by other message ultimately package: so it terminates with ;"
	s
		crtab;
		nextPutAll: 'sharedVariables: '.
	self classVariableDefinitionsOn: s.
	s  
		nextPutAll: ';'
]

{ #category : #'elementary operations' }
FluidClassDefinitionPrinter >> slotDefinitionString [
	"Answer a string that represents an executable description of my Slots"
	
	^String streamContents: [ :str | self slotDefinitionsOn: str]
]

{ #category : #'elementary operations' }
FluidClassDefinitionPrinter >> slotDefinitionsOn: aStream [
	"If the class has many instance variable print one slot per line, do the same for complex slots."

	| oneSlotPerLine localSlots |
	"We could have the heuristics based on the sum of the slot name character length."
	oneSlotPerLine := false.
	localSlots := forClass localSlots.
	( localSlots size > 8 or: [ localSlots anySatisfy: [ :s | s needsFullDefinition ]]) 
		ifTrue: [ localSlots size = 1 ifFalse: [ oneSlotPerLine := true ] ].
	aStream nextPutAll: '{'.
	"To start aligned really nice when we have two complex slots"
	oneSlotPerLine ifTrue: [ 
		self slotShiftOn: aStream ].
	localSlots
		do: [ :slot | 
			aStream space.
			aStream nextPutAll: slot definitionString.
			oneSlotPerLine := slot needsFullDefinition | oneSlotPerLine.
			aStream space ]
		separatedBy: [ 
			aStream nextPutAll: '.'.
			oneSlotPerLine ifTrue: [ self slotShiftOn: aStream ] ].
	aStream nextPutAll: '}'
]

{ #category : #'elementary operations' }
FluidClassDefinitionPrinter >> slotShiftOn: aStream [

	aStream
		cr;
		tab;
		tab;
		tab
]

{ #category : #'elementary operations' }
FluidClassDefinitionPrinter >> slotsOn: s [
	"uses: can the last part of a definition so watch out for terminating ;"
	
	s crtab.
	s nextPutAll: 'slots: '.
	self slotDefinitionsOn: s.
	s nextPutAll: ';'.

]

{ #category : #'expanded double dispatch API' }
FluidClassDefinitionPrinter >> tagOn: s [

	| tag |
	(forClass package classTagForClass: forClass) ifNotNil: [ :t | 
		tag := t name.
		tag = forClass package name ifFalse: [ 
			s crtab.
			s
				nextPutAll: 'tag: ';
				nextPut: $';
				nextPutAll: tag asString;
				nextPutAll: ''';' ] ]
]

{ #category : #printing }
FluidClassDefinitionPrinter >> testClassDefinitionTemplateInPackage: aPackageName [

		^ String streamContents: [ :s |
						s nextPutAll: 'TestCase << #MyTest'; crtab.
						s nextPutAll: 'slots: {};'; crtab. 
						s nextPutAll: 'tag: '''' ;';crtab.
						s nextPutAll: 'package: ''', aPackageName, '''' ] 
]

{ #category : #'definition double dispatch API' }
FluidClassDefinitionPrinter >> traitDefinitionString [

	^ String streamContents: [ :strm | 
			strm nextPutAll: 'Trait'.
			self msgAndClassNameOn: strm.
			self traitsOn: strm.

		   forClass slots ifNotEmpty: [ self slotsOn: strm ].
			self tagOn: strm.
			self packageOn: strm ]
]

{ #category : #printing }
FluidClassDefinitionPrinter >> traitDefinitionTemplateInPackage: aPackageName [
	
	^ String streamContents: [ :s | 
		  s
			  nextPutAll: 'Trait << #TMyTrait';
			  crtab.
		  s
			  nextPutAll: 'trait: TEmpty;';
			  crtab.
		  s
			  nextPutAll: 'slots: {};';
			  crtab.
		  s
			  nextPutAll: 'tag: '''' ;';
			  crtab.
		  s
			  nextPutAll: 'package: ''';
			  nextPutAll: aPackageName;
			  nextPutAll: '''' ]
]

{ #category : #'definition double dispatch API' }
FluidClassDefinitionPrinter >> traitedMetaclassDefinitionString [

	^ String streamContents: 
		[:strm |
		strm nextPutAll: forClass name.
		self lastTraitsOn: strm.
		forClass slots ifNotEmpty: [ self lastSlotsOn: strm ]]
]

{ #category : #'elementary operations' }
FluidClassDefinitionPrinter >> traitsOn: strm [
	"uses: can the last part of a definition so watch out for terminating ;"
	
	forClass hasTraitComposition ifTrue: [
		"forClass traitComposition innerClass = TEmpty ifTrue: [ ^ self ]."
		"isEmpty traitComposition should probably moved to Trait."
		strm 
			crtab; 
			nextPutAll: 'trait: ';
			nextPutAll: forClass traitCompositionString;
			nextPutAll: ';' ]
]
