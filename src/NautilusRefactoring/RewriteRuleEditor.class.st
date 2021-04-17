"
An editor for rewrite rules. 
"
Class {
	#name : #RewriteRuleEditor,
	#superclass : #SpPresenter,
	#instVars : [
		'#searchLabel => SpObservableSlot',
		'#searchPattern => SpObservableSlot',
		'#replaceLabel => SpObservableSlot',
		'#replacePattern => SpObservableSlot',
		'#helpText => SpObservableSlot',
		'#replaceButton => SpObservableSlot'
	],
	#category : #'NautilusRefactoring-Utilities'
}

{ #category : #specs }
RewriteRuleEditor class >> defaultSpec [

	^ SpBoxLayout newHorizontal
		add: (SpBoxLayout newVertical
			add: #searchLabel expand: false;
			add: #searchPattern expand: true fill: true padding: 0;
			add: #replaceLabel expand: false;
			add: #replacePattern expand: true fill: true padding: 0) 
			expand: true fill: true padding: 5;
		add: (SpBoxLayout newVertical 
			add: #helpText expand: true fill: true padding: 18;
			addLast: #replaceButton)
			expand: false fill: false padding: 0;
		yourself	
]

{ #category : #'world menu' }
RewriteRuleEditor class >> menuCommandOn: aBuilder [
    <worldMenu>
    (aBuilder item: #'Rewrite Rule Editor')
                action: [self open];
                parent: #Refactoring;
                help: 'Editor for custom refactoring rewrites';
                order: 10
]

{ #category : #examples }
RewriteRuleEditor class >> open [
	<example>
	^self new openWithSpec
]

{ #category : #initialization }
RewriteRuleEditor >> connectPresenters [
	replaceButton action: [ self runReplace ].

]

{ #category : #initialization }
RewriteRuleEditor >> initializePresenters [
	searchLabel := self newLabel.
	searchLabel label: 'Search for:'.
	searchPattern := self newText 
		autoAccept: true;
		yourself.
	replaceLabel := self newLabel.
	replaceLabel label: 'Replace with:'.
	replacePattern := self newText 
		autoAccept: true;
		yourself.
	helpText := self newText
		text: '` = meta var
@ = list
` = recurse into
. = statement
# = literal';
		enabled: false;
		yourself.
	replaceButton := self newButton label: 'Replace...'.
	self focusOrder
		add: searchPattern;
		add: replacePattern;
		add: replaceButton
]

{ #category : #initialization }
RewriteRuleEditor >> initializeWindow: aWindowPresenter [
	| fontWidth rowHeight |	
	fontWidth := (StandardFonts defaultFont widthOfString: 'M').
	rowHeight := self class inputTextHeight.
	aWindowPresenter
		title: self windowTitle;
		initialExtent: (50@18) * (fontWidth @ rowHeight);
		whenOpenedDo: [ helpText color: self theme baseColor]

]

{ #category : #actions }
RewriteRuleEditor >> runReplace [
	| env rewriter changes |
	env := RBBrowserEnvironment default forPackages: (RPackageOrganizer default packages ).

	rewriter := RBParseTreeRewriter new.
	rewriter  
		replace: searchPattern text with: replacePattern text.

	changes := Array with: (RBSmalllintChecker runRule: (RBTransformationRule new
		rewriteRule: rewriter;
		yourself)
		onEnvironment:  env  ) builder.

 (RewriteRuleChangesBrowser changes: changes) open.
]

{ #category : #initialization }
RewriteRuleEditor >> windowTitle [
	
	^ 'Rewrite rule editor'.
]
