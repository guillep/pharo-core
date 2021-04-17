Class {
	#name : #DoItVariableTest,
	#superclass : #TestCase,
	#instVars : [
		'instVarForTest'
	],
	#category : #'Slot-Tests-VariablesAndSlots'
}

{ #category : #helpers }
DoItVariableTest >> readVarInDifferentContext: aVar [
	| temp | 
	self assert: aVar name equals: #temp.
	
	temp := #thisTemp.
	^aVar readInContext: thisContext 
]

{ #category : #tests }
DoItVariableTest >> testConvertingToDoItVariable [

	| temp var |
	temp := 100.
	var := DoItVariable named: #temp fromContext: thisContext.
	
	self assert: (var asDoItVariableFrom: #anyContext) identicalTo: var
]

{ #category : #tests }
DoItVariableTest >> testCreationFromAnotherVariable [
	| temp var targetTemp |
	temp := 100.
	targetTemp := thisContext lookupVar: #temp.
	var := targetTemp asDoItVariableFrom: thisContext.
	
	self assert: var class equals: DoItVariable.
	self assert: var doItContext identicalTo: thisContext.
	self assert: var actualVariable identicalTo: targetTemp
]

{ #category : #tests }
DoItVariableTest >> testFromInstVarVariable [

	| var |
	instVarForTest := 100.
	var := DoItVariable named: #instVarForTest fromContext: thisContext.
	
	self assert: var name equals: #instVarForTest.
	self assert: var read equals: 100.
	var write: 200.
	self assert: var read equals: 200.
	self assert: instVarForTest equals: 200
]

{ #category : #tests }
DoItVariableTest >> testFromTempVariable [

	| temp var |
	temp := 100.
	var := DoItVariable named: #temp fromContext: thisContext.
	
	self assert: var name equals: #temp.
	self assert: var read equals: 100.
	var write: 200.
	self assert: var read equals: 200.
	self assert: temp equals: 200
]

{ #category : #tests }
DoItVariableTest >> testReadCompilation [
	| temp var ast doIt |
	temp := 100.
	var := DoItVariable named: #temp fromContext: thisContext.
	[ast := [ temp + 2 ] sourceNode body asDoit doSemanticAnalysis]
		on: OCUndeclaredVariableWarning 
		do: [ :ex |  ex resume: ex declareUndefined].
	ast variableNodes first variable: var.
	doIt := ast generateWithSource.
	
	self assert: (doIt valueWithReceiver: self arguments: #()) equals: 102
]

{ #category : #tests }
DoItVariableTest >> testReadInGivenContextShouldIgnoreIt [
	| temp var actual |
	temp := 100.
	var := DoItVariable named: #temp fromContext: thisContext.

	actual := self readVarInDifferentContext: var.
	self assert: actual equals: 100
]

{ #category : #tests }
DoItVariableTest >> testUsingMethods [

	| temp var |
	temp := 100.
	var := DoItVariable named: #temp fromContext: thisContext.
	
	self assert: var usingMethods equals: { thisContext method }
]

{ #category : #tests }
DoItVariableTest >> testWriteCompilation [
	| temp var ast doIt |
	temp := 100.
	var := DoItVariable named: #temp fromContext: thisContext.
	[ast := [ temp := 500 ] sourceNode body asDoit doSemanticAnalysis] 
		on: OCUndeclaredVariableWarning 
		do: [ :ex |  ex resume: ex declareUndefined].
	ast variableNodes first variable: var.
	doIt := ast generateWithSource.
	doIt valueWithReceiver: self arguments: #().
	
	self assert: temp equals: 500
]

{ #category : #tests }
DoItVariableTest >> testWriteInGivenContextShouldIgnoreIt [
	| temp var |
	temp := 100.
	var := DoItVariable named: #temp fromContext: thisContext.

	self writeVarInDifferentContext: var value: 200.
	self assert: temp equals: 200
]

{ #category : #helpers }
DoItVariableTest >> writeVarInDifferentContext: aVar value: aValue [
	| temp | 
	self assert: aVar name equals: #temp.
	
	temp := #thisTemp.
	aVar write: aValue inContext: thisContext.
	self assert: temp equals: #thisTemp
]
