"
This class is an extension so we can mix command of Commander2 with Commander.
"
Class {
	#name : #SycCmCommand,
	#superclass : #CmCommand,
	#traits : 'TRefactoringCommandSupport',
	#classTraits : 'TRefactoringCommandSupport classTrait',
	#instVars : [
		'parentGroup'
	],
	#category : #'SystemCommands-RefactoringSupport'
}

{ #category : #adding }
SycCmCommand class >> activationStrategy [
	self subclassResponsibility
]

{ #category : #adding }
SycCmCommand class >> addItemsToSubmenu: aCmdMenu forContext: aClyMethodContext [

	| commands |

	aCmdMenu activationStrategyClass = self activationStrategy ifFalse: [ ^ self ].

	commands := self subclasses
		            collect: [ :e | 
			            e new
				            context: aClyMethodContext;
				            yourself ]
		            thenSelect: [ :e | e isApplicable ].

	commands do: [ :e | aCmdMenu rootGroup addItem: e ]
]

{ #category : #adding }
SycCmCommand class >> addMenuItemsTo: menuMorph onContext: context [ 

	| commands |
	
	commands := self allSubclasses collect: [:aClass | 
		aClass new 
			context: context;
			yourself] thenSelect: [:aCommand | aCommand isApplicable ].

	commands do: [ :aCommand | | anItem |
		anItem := menuMorph add: aCommand name target: aCommand selector: #execute.
		anItem enabled: aCommand isEnabled.
		anItem setBalloonText: aCommand description.
		aCommand icon ifNotNil: [ anItem icon: aCommand icon ].
	].

	^ menuMorph

]

{ #category : #execution }
SycCmCommand >> applyCommandResult [
]

{ #category : #executing }
SycCmCommand >> execute [ 
	[self prepareFullExecution.
	self executeRefactoring.
	self applyCommandResult] 
		on: Exception do: [ :exc | self processCommandFailure: exc ]
]

{ #category : #executing }
SycCmCommand >> executeRefactoring [
]

{ #category : #accessing }
SycCmCommand >> icon [

	^ nil
]

{ #category : #testing }
SycCmCommand >> isApplicable [
	
	^ true
]

{ #category : #testing }
SycCmCommand >> isEnabled [

	^ true
]

{ #category : #accessing }
SycCmCommand >> order [
	
	^ 10100
]

{ #category : #accessing }
SycCmCommand >> parentGroup [

	^ parentGroup
]

{ #category : #accessing }
SycCmCommand >> parentGroup: aCmdRootMenuGroup [ 
	
	parentGroup := aCmdRootMenuGroup
]

{ #category : #preparation }
SycCmCommand >> prepareFullExecution [
	
]

{ #category : #execution }
SycCmCommand >> processCommandFailure: anException [
	
	context processFailure: anException of: self
]

{ #category : #'context menu' }
SycCmCommand >> registerContextMenuItemsWithBuilder: aBuilder [ 

	(aBuilder item: self name)
		parent: self parentGroup name;
		order: self parentGroup order + (self order / 100);
		help: self description;
		action: [self execute];
		icon: self icon.
]
