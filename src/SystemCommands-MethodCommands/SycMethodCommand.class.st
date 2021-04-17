"
I am a base class for commands which perform operations with collection of methods.

Internal Representation and Key Implementation Points.

    Instance Variables
	methods:		<Colletion of<CompiledMethod>>
"
Class {
	#name : #SycMethodCommand,
	#superclass : #CmdCommand,
	#traits : 'TRefactoringCommandSupport',
	#classTraits : 'TRefactoringCommandSupport classTrait',
	#instVars : [
		'methods'
	],
	#category : #'SystemCommands-MethodCommands'
}

{ #category : #testing }
SycMethodCommand class >> canBeExecutedInContext: aToolContext [
	^aToolContext isMethodSelected
]

{ #category : #'instance creation' }
SycMethodCommand class >> for: methods [
	^self new 
		methods: methods
]

{ #category : #testing }
SycMethodCommand class >> isAbstract [
	^self = SycMethodCommand 
]

{ #category : #accessing }
SycMethodCommand >> methods [
	^ methods
]

{ #category : #accessing }
SycMethodCommand >> methods: anObject [
	methods := anObject
]

{ #category : #'activation-drag and drop' }
SycMethodCommand >> prepareExecutionInDragContext: aToolContext [
	super prepareExecutionInDragContext: aToolContext.
	
	methods := aToolContext selectedMethods
]

{ #category : #execution }
SycMethodCommand >> prepareFullExecutionInContext: aToolContext [
	super prepareFullExecutionInContext: aToolContext.
	methods := aToolContext selectedMethods
]
