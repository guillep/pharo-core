Class {
	#name : #GTGenericStackDebuggerTest,
	#superclass : #TestCase,
	#category : #'GT-Tests-Debugger'
}

{ #category : #tests }
GTGenericStackDebuggerTest >> testBasic [
	| context process debugger printedString |
	context := [ 20 factorial ] asContext.
	process := Process
		forContext: context
		priority: Processor userInterruptPriority.
	debugger := GTGenericStackDebugger on: (process newDebugSessionNamed: 'test debugging' startedAt: context).
	self assert: debugger stackPresentation selection equals: context.
	printedString := '[ 20 factorial ] in GTGenericStackDebuggerTest>>testBasic'.
	self assert: debugger selectedContext printString equals: printedString.
	debugger send.
	debugger send.
	debugger update.
	self
		assert: debugger codePresentation entity sourceCode equals: (Integer >> #factorial) sourceCode.
	self
		assert:
			debugger stackPresentation selection printString
		equals: 'SmallInteger(Integer)>>factorial'.
	process terminate
]
