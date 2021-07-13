"
I do not test the factory logic of ClassDefinitionPrinter because it is done in a companion test class.
Here I'm just a way to share code between all the tests.
"
Class {
	#name : #CommonClassDefinitionPrinterTest,
	#superclass : #TestCase,
	#instVars : [
		'slotDisplay',
		'slotUse'
	],
	#category : #'Kernel-Tests-Fluid'
}

{ #category : #running }
CommonClassDefinitionPrinterTest >> setUp [ 
	super setUp.
	slotUse := ClassDefinitionPrinter showFluidClassDefinition.
	slotDisplay := ClassDefinitionPrinter displayEmptySlots.
	ClassDefinitionPrinter displayEmptySlots: false
]

{ #category : #running }
CommonClassDefinitionPrinterTest >> tearDown [

	ClassDefinitionPrinter showFluidClassDefinition: slotUse.
	ClassDefinitionPrinter displayEmptySlots: slotDisplay.
	super tearDown
]
