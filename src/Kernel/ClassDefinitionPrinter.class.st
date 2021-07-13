"
The idea is that we want to have a printer


ClassDefinitionPrinter 
	should be able to return either a specific printer
	or the default one shared globally.
	By default this ithe one we want to use. 

```	
ClassDefinitionPrinter showFluidClassDefinition.

(ClassDefinitionPrinter for: Array) definitionString
```
should return

```
ArrayedCollection < #Array
	layout: VariableLayout;
	tag: ''Base'';
	package: ''Collections-Sequenceable'''
```
	

```
ClassDefinitionPrinter new 
	oldPharo;
	for: Array;
	definitionString
	
ClassDefinitionPrinter new 
	fluid;
	for: Array;
	definitionString
	
ClassDefinitionPrinter new 
	legacy;
	for: Array;
	definitionString
```	

In addition the printer should support 
	- templateDefinitionString
	
	- expandedDefinitionString is the same as definitionString on OldPharo and Legacy.








"
Class {
	#name : #ClassDefinitionPrinter,
	#superclass : #Object,
	#instVars : [
		'forClass'
	],
	#classVars : [
		'DisplayEmptySlots',
		'ShowFluidClassDefinition'
	],
	#category : #'Kernel-ClassDefinitionPrinter'
}

{ #category : #configure }
ClassDefinitionPrinter class >> displayEmptySlots [

	^ DisplayEmptySlots ifNil: [ DisplayEmptySlots := true ]
]

{ #category : #configure }
ClassDefinitionPrinter class >> displayEmptySlots: aBoolean [

	DisplayEmptySlots := aBoolean
]

{ #category : #'instance creation' }
ClassDefinitionPrinter class >> fluid [ 
	^  FluidClassDefinitionPrinter basicNew initialize 
]

{ #category : #'instance creation' }
ClassDefinitionPrinter class >> for: aClass [ 
	"Given the current class definition syntax and the need for the class, 
	return the correct printer. 
	We only print slots with the fluid class definition."
	
	| instance |
	instance := 
		(aClass needsSlotClassDefinition 
			or: [ self showFluidClassDefinition ])
				ifTrue: [ self fluid ]
				ifFalse: [ self oldPharo ].
	^ instance
		for: aClass; 
		yourself

]

{ #category : #'instance creation' }
ClassDefinitionPrinter class >> legacy [
	^ LegacyClassDefinitionPrinter basicNew initialize
]

{ #category : #'instance creation' }
ClassDefinitionPrinter class >> new [

	^ self showFluidClassDefinition
			ifTrue: [ self fluid ]
			ifFalse: [ self oldPharo ]
	
]

{ #category : #'instance creation' }
ClassDefinitionPrinter class >> oldPharo [ 
	^ OldPharoClassDefinitionPrinter basicNew initialize 
]

{ #category : #settings }
ClassDefinitionPrinter class >> settingsOn: aBuilder [
	"This method could be packaged in a setting kernel related package.
	For now when the Settings system is not available it will just be deadcode."
	
	<systemsettings>
	(aBuilder setting: #showFluidClassDefinition)
		parent: #codeBrowsing;
		default: false;
		label: 'Use fluid class definition';
		description: 'If true, the system will display the class definition using a fluid interface e.g., 

Object << #Point
	slots: { #x . #y };
	tag: ''BasicObjects'';
	package: ''Kernel''
	
We suggest to use it because it will become the default syntax for Pharo. This new class definition has been designed to control the parameter explosion of the old one. 
In addition, as soon as you will use slots such as ObservableSlot and more this fluid class definition will be used because the old one is not handling well the slots.';
		target: self.
		
	(aBuilder setting: #displayEmptySlots)
		parent: #codeBrowsing;
		default: false;
		label: 'Display empty slots';
		description: 'If true, the system will display the slots even if they are empty e.g., 

Object << #Faked
	slots: { };
	tag: ''BasicObjects'';
	package: ''Kernel''
	';
		target: self.
]

{ #category : #configure }
ClassDefinitionPrinter class >> showFluidClassDefinition [

	^ ShowFluidClassDefinition ifNil: [ ShowFluidClassDefinition := false ]
]

{ #category : #configure }
ClassDefinitionPrinter class >> showFluidClassDefinition: aBoolean [
 
	ShowFluidClassDefinition := aBoolean
	
]

{ #category : #configure }
ClassDefinitionPrinter class >> toggleShowFluidClassDefinition [

	self showFluidClassDefinition: self showFluidClassDefinition not
]

{ #category : #printing }
ClassDefinitionPrinter >> definitionString [
	"The method is part of the double dispatch. It is an extra starting point. 
	Each entity will select the right definition and call me back.
	Normally this method is not used because the main point is the class...."
	
	^ forClass definitionStringFor: self
]

{ #category : #printing }
ClassDefinitionPrinter >> expandedDefinitionString [
	"The method is part of the double dispatch. It is an extra starting point. 
	Each entity will select the right definition and call me back.
	Normally this method is not used because the main point is the class...."
	
	^ forClass expandedDefinitionStringFor: self
]

{ #category : #accessing }
ClassDefinitionPrinter >> for: aClass [ 
	forClass := aClass
]
