Class {
	#name : #RBExtractMethodTest,
	#superclass : #RBRefactoringTest,
	#category : #'Refactoring-Tests-Core-Refactorings'
}

{ #category : #'failure tests' }
RBExtractMethodTest >> testBadInterval [
	self
		shouldFail:
			(RBExtractMethodRefactoring
				extract: (24 to: 30)
				from: #testMethod
				in: RBRefactoryTestDataApp);
		shouldFail:
			(RBExtractMethodRefactoring
				extract: (80 to: 147)
				from: #subclassOf:overrides:
				in: RBBasicLintRuleTestData class)
]

{ #category : #'failure tests' }
RBExtractMethodTest >> testExtractFailure [
	self
		shouldFail:
			(RBExtractMethodRefactoring
				extract: (80 to: 269)
				from: #subclassOf:overrides:
				in: RBBasicLintRuleTestData class);
		shouldFail:
			(RBExtractMethodRefactoring
				extract: (53 to: 56)
				from: #subclassOf:overrides:
				in: RBBasicLintRuleTestData class);
		shouldFail:
			(RBExtractMethodRefactoring
				extract: (77 to: 222)
				from: #subclassResponsibilityNotDefined
				in: RBBasicLintRuleTestData class)
]

{ #category : #tests }
RBExtractMethodTest >> testExtractMethodAtEndOfMethodThatNeedsReturn [
	| refactoring class |
	refactoring := RBExtractMethodRefactoring
		extract: (52 to: 133)
		from: #openEditor
		in: RBLintRuleTestData.
	self setupMethodNameFor: refactoring toReturn: #foo:.
	self executeRefactoring: refactoring.
	class := refactoring model classNamed: #RBLintRuleTestData.

	self assert: (class parseTreeFor: #openEditor) equals: (self parseMethod: 'openEditor
	| rules |
	rules := self failedRules.
	^self foo: rules').
	self assert: (class parseTreeFor: #foo:) equals: (self parseMethod: 'foo: rules
	rules isEmpty ifTrue: [^self].
	rules size == 1 ifTrue: [^rules first viewResults]')
]

{ #category : #tests }
RBExtractMethodTest >> testExtractMethodThatMovesTemporaryVariable [
	| refactoring class |
	refactoring := RBExtractMethodRefactoring
		extract: (22 to: 280)
		from: #superSends
		in: RBTransformationRuleTestData.
	self setupMethodNameFor: refactoring toReturn: #foo1.
	self executeRefactoring: refactoring.
	class := refactoring model classNamed: #RBTransformationRuleTestData.

	self assert: (class parseTreeFor: #superSends) equals: (self parseMethod: 'superSends
	| rule |
	rule := self foo1.
	self rewriteUsing: rule').
	self assert: (class parseTreeFor: #foo1) equals: (self parseMethod: 'foo1 | rule | 	rule := RBParseTreeRewriter new.
	rule addSearch: ''super `@message: ``@args''
				-> (
					[:aNode | 
					(class withAllSubclasses
						detect: [:each | each includesSelector: aNode selector]
						ifNone: [nil]) isNil]
							-> ''self `@message: ``@args'').
		^rule')
]

{ #category : #tests }
RBExtractMethodTest >> testExtractMethodThatNeedsArgument [
	| refactoring class |
	refactoring := RBExtractMethodRefactoring
		extract: (145 to: 343)
		from: #checkMethod:
		in: RBTransformationRuleTestData.
	self setupMethodNameFor: refactoring toReturn: #foo:.
	self executeRefactoring: refactoring.
	class := refactoring model classNamed: #RBTransformationRuleTestData.

	self assert: (class parseTreeFor: #checkMethod:) equals: (self parseMethod: 'checkMethod: aSmalllintContext 
	class := aSmalllintContext selectedClass.
	(rewriteRule executeTree: aSmalllintContext parseTree) ifTrue: 
			[self foo: aSmalllintContext]').
	self assert: (class parseTreeFor: #foo:) equals: (self parseMethod: 'foo: aSmalllintContext (RecursiveSelfRule executeTree: rewriteRule tree initialAnswer: false)
				ifFalse: 
					[builder compile: rewriteRule tree printString
						in: class
						classified: aSmalllintContext protocols]')
]

{ #category : #tests }
RBExtractMethodTest >> testExtractMethodThatNeedsTemporaryVariable [
	| refactoring class |
	refactoring := RBExtractMethodRefactoring
		extract: (78 to: 197)
		from: #displayName
		in: RBLintRuleTestData.
	self setupMethodNameFor: refactoring toReturn: #foo:.
	self executeRefactoring: refactoring.
	class := refactoring model classNamed: #RBLintRuleTestData.

	self assert: (class parseTreeFor: #displayName) equals: (self parseMethod: 'displayName
	| nameStream |
	nameStream := WriteStream on: (String new: 64).
	self foo: nameStream.
	^nameStream contents').

	self assert: (class parseTreeFor: #foo:) equals: (self parseMethod: 'foo: nameStream 	nameStream nextPutAll: self name;
		nextPutAll: '' (''.
	self problemCount printOn: nameStream.
	nameStream nextPut: $).')
]

{ #category : #tests }
RBExtractMethodTest >> testExtractMethodToSuperclass [
	| refactoring class |
	refactoring := RBExtractMethodRefactoring
		extract: (145 to: 343)
		from: #checkMethod:
		in: RBTransformationRuleTestData.
	self setupMethodNameFor: refactoring toReturn: #foo:.
	self setupExtractionClassFor: refactoring toReturn: RBFooLintRuleTestData. 
	self executeRefactoring: refactoring.
	class := refactoring model classNamed: #RBTransformationRuleTestData.

	self assert: (class parseTreeFor: #checkMethod:) equals: (self parseMethod: 'checkMethod: aSmalllintContext 
	class := aSmalllintContext selectedClass.
	(rewriteRule executeTree: aSmalllintContext parseTree) ifTrue: 
			[self foo: aSmalllintContext]').
	
	class := refactoring model classNamed: #RBFooLintRuleTestData.
	self assert: (class parseTreeFor: #foo:) equals: (self parseMethod: 'foo: aSmalllintContext (RecursiveSelfRule executeTree: rewriteRule tree initialAnswer: false)
				ifFalse: 
					[builder compile: rewriteRule tree printString
						in: class
						classified: aSmalllintContext protocols]')
]

{ #category : #tests }
RBExtractMethodTest >> testExtractWithRenamingOfParameters [
	| refactoring class |
	refactoring := RBExtractMethodRefactoring extract: (78 to: 197) from: #displayName in: RBLintRuleTestData.
	self setupMethodNameFor: refactoring toReturn: #foo:.
	refactoring
		parameterMap:
			(Dictionary new
				at: #nameStream put: #newParameter;
				yourself).
	self executeRefactoring: refactoring.
	class := refactoring model classNamed: #RBLintRuleTestData.

	self
		assert: (class parseTreeFor: #displayName)
		equals:
			(self
				parseMethod:
					'displayName
	| nameStream |
	nameStream := WriteStream on: (String new: 64).
	self foo: nameStream.
	^nameStream contents').
	"Extracted method with renamed parameters"
	self
		assert: (class parseTreeFor: #foo:)
		equals:
			(self
				parseMethod:
					'foo: newParameter 	newParameter nextPutAll: self name;
		nextPutAll: '' (''.
	self problemCount printOn: newParameter.
	newParameter nextPut: $).')
]

{ #category : #tests }
RBExtractMethodTest >> testModelExtractMethodWithTemporariesSelected [
	| class refactoring |
	model := RBClassModelFactory rbNamespace new.
	class := model classNamed: self class name.
	class compile: 'foo [| temp | temp := 5. temp * temp] value'
		classified: #(#accessing).
	refactoring := RBExtractMethodRefactoring 
				model: model
				extract: (6 to: 36)
				from: #foo
				in: class.
	self setupMethodNameFor: refactoring toReturn: #foobar.
	self executeRefactoring: refactoring.
	self assert: (class parseTreeFor: #foo) 
			equals: (self parseMethod: 'foo [self foobar] value').
	self assert: (class parseTreeFor: #foobar) 
			equals: (self parseMethod: 'foobar |temp | temp := 5. ^temp * temp')
]

{ #category : #tests }
RBExtractMethodTest >> testModelExtractMethodWithTemporaryAssigned [
	| class refactoring |
	model := RBClassModelFactory rbNamespace new.
	class := model classNamed: self class name.
	class 
		compile: 'foo 				| temp bar | 				bar := 5. 				temp := bar * bar. 				Transcript show: temp printString; cr. 				^temp * temp'
		classified: #(#accessing).
	refactoring := RBExtractMethodRefactoring 
				model: model
				extract: (26 to: 102)
				from: #foo
				in: class.
	self setupMethodNameFor: refactoring toReturn: #foobar.
	self executeRefactoring: refactoring.
	self assert: (class parseTreeFor: #foo) 
			equals: (self parseMethod: 'foo | temp | temp := self foobar. ^temp * temp').
	self 
		assert: ((class parseTreeFor: #foobar) = (self 
						parseMethod: 'foobar | bar temp | bar := 5. temp := bar * bar. Transcript show: temp printString; cr. ^temp.')) |
				((class parseTreeFor: #foobar) = (self 
						parseMethod: 'foobar | temp bar | bar := 5. temp := bar * bar. Transcript show: temp printString; cr. ^temp.'))
]

{ #category : #'failure tests' }
RBExtractMethodTest >> testNonExistantSelector [
	self shouldFail: (RBExtractMethodRefactoring 
			extract: (10 to: 20)
			from: #checkClass1:
			in: RBBasicLintRuleTestData)
]

{ #category : #tests }
RBExtractMethodTest >> testValidateRenameParameters [
	| refactoring |
	refactoring := RBExtractMethodRefactoring
		extract: (78 to: 197)
		from: #displayName
		in: RBLintRuleTestData.
	self setupMethodNameFor: refactoring toReturn: #foo:.
	refactoring parameterMap: (Dictionary new at: #nameStream put: #nameStream; yourself ).
	"Fail when use instance variables as new parameters"
	self should: [ refactoring validateRenameOf: #nameStream to: #name ] raise: RBRefactoringError.	
	self should: [refactoring validateRenameOf: #nameStream to: #foo1] raise: RBRefactoringError.
	"Fail when use class variables as new parameters"
	self should: [refactoring validateRenameOf: #nameStream to: #Foo1] raise: RBRefactoringError.
	"Fail when use temporary variables as new parameters"
]
