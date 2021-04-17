"
This is the chapter of the refactoring help book about the class / instance variable refactoring available in the System Browser.
"
Class {
	#name : #RBBrowserVariableRefactoringHelp,
	#superclass : #RBBrowserClassRefactoringHelp,
	#category : #'Refactoring-Help'
}

{ #category : #pages }
RBBrowserVariableRefactoringHelp class >> abstractVariableRefactoring [
	^HelpTopic
		title: 'Abstract'
		contents: 
'
Shows a list of variables from the class or instance side, creates an accessors for the variable and replaces all direct access to this variable by this accessors method.
(For this class and all of its subclasses.)
There is no special handling for already existing accessors methods, their direct access is replaced too. And if an accessors method with the name of this variable already exists, the newly created method will get the same name with a counter suffix.
'

]

{ #category : #pages }
RBBrowserVariableRefactoringHelp class >> accessorForLazyInitializationRefactoring [
	^HelpTopic
		title: 'Accessor with lazy initialization'
		contents: RBCreateAccessorsWithLazyInitializationForVariableRefactoring comment
]

{ #category : #pages }
RBBrowserVariableRefactoringHelp class >> accessorVariableRefactoring [
	^HelpTopic
		title: 'Accessor'
		contents: 
'
Accessor
Choose one instance / class variable to create accessors for. 
A getter and setter methods is generated, with the name of the chosen instance variable. If a method with this name already exists, it will create a new method with the same name and a counter suffix.
'

]

{ #category : #pages }
RBBrowserVariableRefactoringHelp class >> addVariableRefactoring [
	^HelpTopic
		title: 'Add Variable'
		contents: RBAddInstanceVariableRefactoring comment

]

{ #category : #accessing }
RBBrowserVariableRefactoringHelp class >> bookName [
	^ 'Class and Instance Variable Refactorings'
]

{ #category : #pages }
RBBrowserVariableRefactoringHelp class >> mergeVariableIntoAnotherRefactoring [
	^HelpTopic
		title: 'Merge variable'
		contents: RBMergeInstanceVariableIntoAnother comment

]

{ #category : #pages }
RBBrowserVariableRefactoringHelp class >> moveToVariableRefactoring [
	^HelpTopic
		title: 'Move to class'
		contents: 
'
Only for instance variables. A class search dialog lets you choose the target class to move the instance variable to.
Another dialog for choosing the instance variable to move. If there are any methods referring to this variable, a message list opens, showing all broken methods.
'

]

{ #category : #accessing }
RBBrowserVariableRefactoringHelp class >> pages [
	^ #(addVariableRefactoring renameVariableRefactoring removeVariableRefactoring abstractVariableRefactoring  accessorVariableRefactoring accessorForLazyInitializationRefactoring moveToVariableRefactoring pullUpVariableRefactoring pushDownVariableRefactoring #mergeVariableIntoAnotherRefactoring)
]

{ #category : #pages }
RBBrowserVariableRefactoringHelp class >> pullUpVariableRefactoring [
	^HelpTopic
		title: 'Pull up'
		contents: 
'
Moves an instance/class variable up to the superclass. The variable is added to the superclass and removed from this and all other sibling classes, defining this variable. A warning message appears if not all direct subclasses defined this variable.
'

]

{ #category : #pages }
RBBrowserVariableRefactoringHelp class >> pushDownVariableRefactoring [
	^HelpTopic
		title: 'Push down'
		contents: 
'
Moves an instance/class variable down to the subclasses. The variable is added to every direct subclass.
A warning dialog appears if there are methods referring to this class (accessors methods for example), and offers a choice to open a (scoped) browser for this messages.
No accessors method will be changed or generated.
'

]

{ #category : #pages }
RBBrowserVariableRefactoringHelp class >> removeVariableRefactoring [
	^HelpTopic
		title: 'Remove'
		contents: 
'
Shows a list of variables from the class or instance side. The selected variable is removed. If the variable is referred by a method, it asks for opening a browser window, showing only those classes and its methods accessing this variable (a scoped browser view).
'

]

{ #category : #pages }
RBBrowserVariableRefactoringHelp class >> renameVariableRefactoring [
	^HelpTopic
		title: 'Rename'
		contents: 
'
Shows a list of variables from the class or instance side. The selected variable is renamed in the class definition and in all methods referring to this var. The name of the accessor methods are unchanged.
'

]
