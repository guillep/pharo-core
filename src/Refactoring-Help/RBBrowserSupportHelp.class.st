"
This is the chapter of  the refactoring framework help about refactoring support in the System Browser.
"
Class {
	#name : #RBBrowserSupportHelp,
	#superclass : #RefactoringHelp,
	#category : #'Refactoring-Help'
}

{ #category : #accessing }
RBBrowserSupportHelp class >> bookName [
	^ 'System Browser Support'
]

{ #category : #pages }
RBBrowserSupportHelp class >> overview [
	^HelpTopic
		title: 'Overview'
		contents: 
'
Most refactoring operations fall into one of three categories:

Class Refactoring, Method Refactoring and Source Refactoring.

The following pages describe the refactorings available in the System Browser - Calypso.
Depending on the kind of Refactoring (Class/Method/Source) you can find and apply the refactoring from the "Refactoring" Menu on the class-, method- or code-pane.

Executing a refactoring will open a changes browser that lets you see and (depending on the current operation) select which change to apply.

If the refactoring can not be applied, because one of its preconditions aren''t met (for example you try to rename a class with a name that is already used), a warning message appears.

The refactoring changes will be applied to all classes and methods in the current "namespace". For the default system browser, this is the whole system.
If you want to restrict the operation to some set of classes or packages, you can open a system browser on a refactoring environmet - a kind of "scoped view".

Example:

(RBBrowserEnvironment default forPackageNames:{''Kernel''}) browse. 
will open a system browser with only the classes from package ''Kernel''. And all refactoring operations will only find and change classes in this "namespace".

See the chapter in "RB Refactoring Engine - RBBrowserEnvironment" for more examples on how to create scoped views.
'
]

{ #category : #accessing }
RBBrowserSupportHelp class >> pages [
	^#( overview #RBBrowserClassRefactoringHelp #RBBrowserMethodRefactoringHelp #RBBrowserSourceRefactoringHelp #RBBrowserPackageRefactoringHelp )
]
