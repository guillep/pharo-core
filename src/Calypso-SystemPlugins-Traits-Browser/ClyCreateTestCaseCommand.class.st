Class {
	#name : #ClyCreateTestCaseCommand,
	#superclass : #ClyBrowserCommand,
	#instVars : [
		'package',
		'classTag'
	],
	#category : #'Calypso-SystemPlugins-Traits-Browser'
}

{ #category : #testing }
ClyCreateTestCaseCommand class >> canBeExecutedInContext: aBrowserContext [
	(super canBeExecutedInContext: aBrowserContext) ifFalse: [ ^false ].
	
	^aBrowserContext isPackageSelected 
]

{ #category : #activation }
ClyCreateTestCaseCommand class >> fullBrowserMenuActivation [
	<classAnnotation>
	
	^CmdContextMenuActivation byRootGroupItemOrder: 5 for: ClyFullBrowserClassContext 
]

{ #category : #accessing }
ClyCreateTestCaseCommand >> defaultMenuIconName [
	^#testGreen
]

{ #category : #accessing }
ClyCreateTestCaseCommand >> defaultMenuItemName [
	^'New test class'
]

{ #category : #'command execution' }
ClyCreateTestCaseCommand >> execute [
	| classDefinition p resultClass |
	p := package name.
	classTag ifNotNil: [ p := p , '-' , classTag ].
	classDefinition := ClassDefinitionPrinter new testClassDefinitionTemplateInPackage: p.
	classDefinition := UIManager default
		                   multiLineRequest: 'Define test class:'
		                   initialAnswer: classDefinition
		                   answerHeight: 250.
	classDefinition isEmptyOrNil ifTrue: [ ^ self ].
	resultClass := browser
		               compileANewClassFrom: classDefinition
		               notifying: nil
		               startingFrom: nil.
	resultClass ifNotNil: [ browser selectClass: resultClass ]
]

{ #category : #execution }
ClyCreateTestCaseCommand >> prepareFullExecutionInContext: aBrowserContext [
	super prepareFullExecutionInContext: aBrowserContext.
	
	package := aBrowserContext lastSelectedPackage.
	aBrowserContext isClassTagSelected ifTrue: [ 
		classTag := aBrowserContext lastSelectedClassTag]
]
