Class {
	#name : #CoCompletionEngineTest,
	#superclass : #CompletionEngineTest,
	#category : #'HeuristicCompletion-Tests'
}

{ #category : #accessing }
CoCompletionEngineTest >> doItContext [
	
	^ nil
]

{ #category : #running }
CoCompletionEngineTest >> newCompletionEngine [
	
	^ CoCompletionEngine new
]

{ #category : #asserting }
CoCompletionEngineTest >> shouldInheritSelectors [

	^ true
]

{ #category : #'test-interaction' }
CoCompletionEngineTest >> testAdvanceWordDoesNotCloseCompletionContext [
	"Because it will still be at the end of the current word"
	| text |
	text := 'self mEthOdThatDoesNotExist toto'.
	self
		setEditorText: text;
		selectAt: text size - 10.
	
	editor textArea openInWorld.
	controller openMenu.
	
	"This is the current shortcut of the completion engine... Cmd+right for all platforms"
	editor keyDown: (self keyboardEventFor: Character arrowRight useCommand: true).
	
	self assert: controller hasCompletionContext.
]

{ #category : #'test-interaction' }
CoCompletionEngineTest >> testAdvanceWordGoesToNextWord [
	
	| text |
	text := 'self mEthOdThatDoesNotExist toto'.
	self
		setEditorText: text;
		selectAt: text size - 10.
	
	editor textArea openInWorld.
	controller openMenu.
	
	"This is the current shortcut of the completion engine... Cmd+right for all platforms"
	editor keyDown: (self keyboardEventFor: Character arrowRight useCommand: true).
	
	self assert: editor caret equals: text size - 'toto' size.
]

{ #category : #'test-interaction' }
CoCompletionEngineTest >> testAdvanceWordTwiceClosesCompletionContext [
	"Because it exists current word"
	| text |
	text := 'self mEthOdThatDoesNotExist toto'.
	self
		setEditorText: text;
		selectAt: text size - 10.
	
	editor textArea openInWorld.
	controller openMenu.
	
	"This is the current shortcut of the completion engine... Cmd+right for all platforms"
	2 timesRepeat: [
		editor keystroke: (self keyboardEventFor: Character arrowRight useCommand: true) ].
	
	self deny: controller hasCompletionContext.
]

{ #category : #'test-interaction' }
CoCompletionEngineTest >> testEndClosesCompletionContext [
	
	| text |
	text := 'self mEthOdThatDoesNotExist'.
	self
		setEditorText: text;
		selectAt: text size - 5.
	
	editor textArea openInWorld.
	controller openMenu.
	
	editor keystroke: (self keyboardEventFor: Character end).
	
	self deny: controller hasCompletionContext.
]

{ #category : #'test-interaction' }
CoCompletionEngineTest >> testEndGoesToEndOfLine [
	
	| text |
	text := 'self mEthOdThatDoesNotExist'.
	self
		setEditorText: text;
		selectAt: text size - 5.
	
	editor textArea openInWorld.
	controller openMenu.
	
	editor keyDown: (self keyboardEventFor: Character end).
	
	self assert: editor caret equals: text size + 1
]

{ #category : #'test-interaction' }
CoCompletionEngineTest >> testHomeClosesCompletionContext [
	
	| text |
	text := 'self mEthOdThatDoesNotExist'.
	self
		setEditorText: text;
		selectAt: text size - 5.
	
	editor textArea openInWorld.
	controller openMenu.
	
	editor keystroke: (self keyboardEventFor: Character home).
	
	self deny: controller hasCompletionContext.
]

{ #category : #'test-interaction' }
CoCompletionEngineTest >> testHomeGoesToStartOfLine [
	
	| text |
	text := 'self mEthOdThatDoesNotExist'.
	self
		setEditorText: text;
		selectAt: text size - 5.
	
	editor textArea openInWorld.
	controller openMenu.
	
	editor keyDown: (self keyboardEventFor: Character home).
	
	self assert: editor caret equals: 1
]

{ #category : #'test-interaction' }
CoCompletionEngineTest >> testInitialCompletionEngineHasNoContext [

	"If we did no interaction, no completion context should be initialized"
	
	| text |
	text := 'self mEthOdThatDoesNotExist'.
	self
		setEditorText: text;
		selectAt: text size + 1.
		
	self deny: controller hasCompletionContext.
]

{ #category : #'test-interaction' }
CoCompletionEngineTest >> testLeftWithoutResultsBroadensSelection [
	
	| text |
	text := 'self mEthOdThatDoesNotExist'.
	self
		setEditorText: text;
		selectAt: text size + 1.
	
	editor textArea openInWorld.
	controller openMenu.
	
	editor keyDown: (self keyboardEventFor: Character arrowLeft).
	
	self assert: controller context completionToken equals: 'mEthOdThatDoesNotExis'
]

{ #category : #'test-interaction' }
CoCompletionEngineTest >> testLeftWithoutResultsDoesNotCloseContext [
	
	| text firstContext |
	text := 'self mEthOdThatDoesNotExist'.
	self
		setEditorText: text;
		selectAt: text size + 1.
	
	editor textArea openInWorld.
	controller openMenu.
	firstContext := controller context.
	
	editor keyDown: (self keyboardEventFor: Character arrowLeft).
	
	self assert: controller context equals: firstContext
]

{ #category : #'test-interaction' }
CoCompletionEngineTest >> testOpenMenuCreatesCompletionContext [
	
	| text |
	text := 'self mEthOdThatDoesNotExist'.
	self
		setEditorText: text;
		selectAt: text size + 1.
	
	editor textArea openInWorld.
	controller openMenu.
	
	self assert: controller hasCompletionContext
]

{ #category : #'test-interaction' }
CoCompletionEngineTest >> testPreviousWordClosesCompletionContext [
	
	| text |
	text := 'self mEthOdThatDoesNotExist toto'.
	self
		setEditorText: text;
		selectAt: text size.
	
	editor textArea openInWorld.
	controller openMenu.
	
	"This is the current shortcut of the completion engine... Cmd+left for all platforms"
	editor keystroke: (self keyboardEventFor: Character arrowLeft useCommand: true).
	
	self deny: controller hasCompletionContext
]

{ #category : #'test-interaction' }
CoCompletionEngineTest >> testPreviousWordGoesToPreviousWord [
	
	| text |
	text := 'self mEthOdThatDoesNotExist toto'.
	self
		setEditorText: text;
		selectAt: text size.
	
	editor textArea openInWorld.
	controller openMenu.
	
	"This is the current shortcut of the completion engine... Cmd+left for all platforms"
	editor keyDown: (self keyboardEventFor: Character arrowLeft useCommand: true).
	
	self assert: editor caret equals: text size - 'toto' size + 1.
]

{ #category : #'test-interaction' }
CoCompletionEngineTest >> testTypeCharacterWithoutResultsDoesNotCloseContext [
	
	| text firstContext |
	text := 'self mEthOdThatDoesNotExist'.
	self
		setEditorText: text;
		selectAt: text size + 1.
	
	editor textArea openInWorld.
	controller openMenu.
	firstContext := controller context.
	
	editor keystroke: (self keyboardEventFor: $a).
	
	self assert: controller context equals: firstContext
]

{ #category : #'test-interaction' }
CoCompletionEngineTest >> testTypeCharacterWithoutResultsNarrowsSelection [
	
	| text |
	text := 'self mEthOdThatDoesNotExist'.
	self
		setEditorText: text;
		selectAt: text size + 1.
	
	editor textArea openInWorld.
	controller openMenu.
	
	editor keystroke: (self keyboardEventFor: $a).
	
	self assert: controller context completionToken equals: 'mEthOdThatDoesNotExist' , 'a'
]
