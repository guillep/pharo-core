"
A ClyClassDefinitionEditorToolMorphTest is a test class for testing the behavior of ClyClassDefinitionEditorToolMorph
"
Class {
	#name : #ClyClassDefinitionEditorToolMorphTest,
	#superclass : #TestCase,
	#instVars : [
		'classDefinitionEditor',
		'editor',
		'className',
		'context',
		'oldString'
	],
	#category : #'Calypso-SystemTools-Core-Tests-Editors-Classes'
}

{ #category : #asserting }
ClyClassDefinitionEditorToolMorphTest >> assertResultCompilationDidntChange [
	"if the string changed, then there is a syntax error
	It may be because it was treated as a method"
	self assert: oldString equals: editor textMorph text string
]

{ #category : #asserting }
ClyClassDefinitionEditorToolMorphTest >> assertResultCompilationEquals: aString [
	self assert: editor textMorph text string equals: aString
]

{ #category : #helper }
ClyClassDefinitionEditorToolMorphTest >> checkClassDoesntExists [
	(self class environment classNamed: className) ifNotNil: [ self error: 'Need to rename test class to not override existing class' ].
]

{ #category : #helper }
ClyClassDefinitionEditorToolMorphTest >> classExists [
	^ self getMyClass isNotNil

]

{ #category : #helper }
ClyClassDefinitionEditorToolMorphTest >> compileString: aString [
	oldString := aString.
	editor textMorph setTextWith: aString.
	editor applyChanges.
]

{ #category : #helper }
ClyClassDefinitionEditorToolMorphTest >> deleteClassIfExists [
	| instaledClass |
	instaledClass := self getMyClass.
	instaledClass ifNil:[ ^ self ].
	instaledClass removeFromSystem
]

{ #category : #helper }
ClyClassDefinitionEditorToolMorphTest >> getMyClass [
	^ (self class environment classNamed: className)

]

{ #category : #running }
ClyClassDefinitionEditorToolMorphTest >> setUp [
	| browser containerTab methodGroupQuery |
	super setUp.

	className := #MyClass.
	
	context := MockClyFullBrowserClassContext new.
	methodGroupQuery := MockMethodGroupQuery new.
	browser := (ClyFullBrowserBlockingUI on: ClyNavigationEnvironment currentImage)
				methodGroupQuery: methodGroupQuery;
				yourself.
	containerTab := MockClyContainerTab new.
	editor := ClyClassDefinitionEditorToolMorph new
		browser: nil;
		context: context;
		containerTab: containerTab;
		browser: browser;
		setUpModelFromContext;
		build;
		yourself.
]

{ #category : #test }
ClyClassDefinitionEditorToolMorphTest >> testAcceptASyntaxErroredClassDefinitionFailsWithoutTryingToCompileAsMethod [
	"Not sure what a syntax error look like for a shift class builder definition.
	Open to ideas"
	<expectedFailure>
	self error.
	
	self compileString: 
'Object subclass: #' , className , '
	instanceVariableNames: ''#'' 
	classVariableNames: ''''
  package: ''Calypso-SystemQueries-Tests'''.

	self assertResultCompilationEquals:
'Object subclass: #MyClass
	instanceVariableNames: '''' 
	classVariableNames: ''''
  package: ''Calypso-SystemQueries-Tests'''
]

{ #category : #test }
ClyClassDefinitionEditorToolMorphTest >> testAcceptASyntaxErroredFluidClassDefinitionFailsWithoutTryingToCompileAsMethod [
	self compileString:
'Object << #', className , '
	slots: { #s #s };
	package: ''Calypso-SystemTools-Core-Tests'''.
	
	self assertResultCompilationEquals:
'Object << #MyClass
	slots: { #s # End of statement expected ->s };
	package: ''Calypso-SystemTools-Core-Tests'''
]

{ #category : #test }
ClyClassDefinitionEditorToolMorphTest >> testAcceptASyntaxErroredMethodShouldFailCompilationAsMethod [
	"failing compilation of a method definition & a fluid class definition should treat their own syntax errors"
	self compileString: 'banana^'.
	self assertResultCompilationEquals:
		'banana^ Variable or expression expected ->'
]

{ #category : #test }
ClyClassDefinitionEditorToolMorphTest >> testAcceptASyntaxErroredTraitDefinitionFailsWithoutTryingToCompileAsMethod [
	"Not sure what a syntax error look like for a shift class builder definition.
	Open to ideas"
	<expectedFailure>.
	self error.
	
	self compileString: 
'Trait subclass: #' , className , '
	instanceVariableNames: ''#'' 
	classVariableNames: ''''
  package: ''Calypso-SystemQueries-Tests'''.

	self assertResultCompilationEquals:
'Trait subclass: #MyClass
	instanceVariableNames: '''' 
	classVariableNames: ''''
  package: ''Calypso-SystemQueries-Tests'''
]

{ #category : #test }
ClyClassDefinitionEditorToolMorphTest >> testAcceptAWellWrittenClassDefinitionRegistersIt [
	self checkClassDoesntExists.
	[
	self compileString:
'Object subclass: #' , className , '
	instanceVariableNames: ''''
	classVariableNames: ''''
	package: ''Calypso-SystemTools-Core-Tests'''.
	self assert: self classExists.
	self assertResultCompilationDidntChange.
	
	] ensure: [ self deleteClassIfExists ].
]

{ #category : #test }
ClyClassDefinitionEditorToolMorphTest >> testAcceptAWellWrittenFluidClassDefinitionRegistersIt [
	self checkClassDoesntExists.
	[
	self compileString:
'Object << #', className , '
	package: ''Calypso-SystemTools-Core-Tests'''.
	self assert: self classExists.
	self assertResultCompilationDidntChange.
	
	] ensure: [ self deleteClassIfExists ].
]

{ #category : #test }
ClyClassDefinitionEditorToolMorphTest >> testAcceptAWellWrittenFluidTraitDefinitionRegistersIt [
	self checkClassDoesntExists.
	[
	self compileString:
'Trait << #' , className , '
	package: ''Calypso-SystemQueries-Tests'''.
	self assert: self classExists.
	self assertResultCompilationDidntChange.

	
	] ensure: [ self deleteClassIfExists ].
]

{ #category : #test }
ClyClassDefinitionEditorToolMorphTest >> testAcceptAWellWrittenMethodRegistersIt [
	| selector |
	selector := #banana.
	(context class class lookupSelector: selector) ifNotNil: [ self error: 'I might overide an important behavior' ].
	[
	self compileString:
selector , '
	^ 1'.
	self assert: (context class class methodDict includes: selector) isNotNil.
	self assertResultCompilationDidntChange.
	
	] ensure: [ context class class removeSelector: selector ].

]

{ #category : #test }
ClyClassDefinitionEditorToolMorphTest >> testAcceptAWellWrittenTraitDefinitionRegistersIt [
	self checkClassDoesntExists.
	[
	self compileString:
'Trait subclass: #' , className , '
	instanceVariableNames: ''''
	classVariableNames: ''''
	package: ''Calypso-SystemTools-Core-Tests'''.
	self assert: self classExists.
	self assertResultCompilationDidntChange.
	
	] ensure: [ self deleteClassIfExists ].
]

{ #category : #test }
ClyClassDefinitionEditorToolMorphTest >> testRedefineAClassShouldRedefineIt [
	|  newClass |
	"This method of removing the GUI confirmation is not my favourite.
	However, this was less dangerous than the initial solution.
	See pull request #8884 on pharo repository for details"
	self checkClassDoesntExists.
	(ClySystemEnvironment methodDictionary includes: #confirm:) ifTrue: [ self error: 'I might override some important behavior, test needs to be updated.' ].

	[ "start of ensure block"
	self compileString: 
'Object << #' , className , '
	package: ''Calypso-SystemQueries-Tests'''.
	
	"remove graphical coinfirm component"
	ClySystemEnvironment compile: 'confirm: aString "noOpFor ClyClassDefinitionEditorToolMorphTest>> testRedefineAClassShouldRedefineIt" ^ true' asString classified: 'toDelete'.
	
	self compileString: 
'Object << #' , className , '
	slots: {#s};
	package: ''Calypso-SystemQueries-Tests'''.	

	newClass := self class environment classNamed: #MyClass.
	self assert: newClass allSlots size equals: 1 ] 
		ensure: [ 
			self deleteClassIfExists.
			"remove the removal of graphical confirm component" 
			ClySystemEnvironment removeSelector: #confirm:
			]
]
