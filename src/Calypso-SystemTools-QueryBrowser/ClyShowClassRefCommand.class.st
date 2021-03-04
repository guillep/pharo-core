"
I am a command to show all class references

To show references I ask the browser to spawn new query browser.

Internal Representation and Key Implementation Points.

    Instance Variables
	browser:		<ClyBrowser>
"
Class {
	#name : #ClyShowClassRefCommand,
	#superclass : #SycClassCommand,
	#instVars : [
		'browser'
	],
	#category : #'Calypso-SystemTools-QueryBrowser-Commands-Queries'
}

{ #category : #'instance creation' }
ClyShowClassRefCommand class >> forClasses: classes by: aBrowser [ 
	^(self for: classes) 
		browser: aBrowser
]

{ #category : #activation }
ClyShowClassRefCommand class >> fullBrowserMenuActivation [
	<classAnnotation>
	
	^CmdContextMenuActivation byItemOf: ClyQueryMenuGroup for: ClyFullBrowserClassContext
]

{ #category : #activation }
ClyShowClassRefCommand class >> fullBrowserShortcutActivation [
	<classAnnotation>
	
	^CmdShortcutActivation by: $n meta for: ClyFullBrowserClassContext
]

{ #category : #activation }
ClyShowClassRefCommand class >> fullBrowserToolbarActivation [
	<classAnnotation>
	
	^ClyToolbarActivation byItemOf: ClyButtonToolbarGroup for: ClyFullBrowserClassContext 
]

{ #category : #activation }
ClyShowClassRefCommand class >> queryBrowserMenuActivation [
	<classAnnotation>
	
	^CmdContextMenuActivation byItemOf: ClyQueryMenuGroup for: ClyQueryBrowserContext 
]

{ #category : #activation }
ClyShowClassRefCommand class >> queryBrowserShortcutActivation [
	<classAnnotation>
	
	^CmdShortcutActivation by: $c meta, $n meta for: ClyQueryBrowserContext
]

{ #category : #activation }
ClyShowClassRefCommand class >> queryBrowserToolbarActivation [
	<classAnnotation>
	
	^ClyToolbarActivation byItemOf: ClyButtonToolbarGroup for: ClyQueryBrowserContext 
]

{ #category : #activation }
ClyShowClassRefCommand class >> sourceCodeMenuActivation [
	<classAnnotation>
	
	^SycSourceCodeMenuActivation byItemOf: ClyQueryMenuGroup for: ClySourceCodeContext
]

{ #category : #accessing }
ClyShowClassRefCommand >> browser [

	^ browser
]

{ #category : #accessing }
ClyShowClassRefCommand >> browser: anObject [

	browser := anObject
]

{ #category : #accessing }
ClyShowClassRefCommand >> defaultMenuItemName [
	^'Class refs.'
]

{ #category : #execution }
ClyShowClassRefCommand >> execute [

	browser spawnQueryBrowserOn: (ClyClassReferencesQuery toAny: classes)
]

{ #category : #execution }
ClyShowClassRefCommand >> prepareFullExecutionInContext: aToolContext [
	super prepareFullExecutionInContext: aToolContext.
	
	browser := aToolContext browser
]
