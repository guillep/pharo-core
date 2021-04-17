"
I'm a refactoring to move a method to class side.

My preconditions verify that the method exists and belongs to instance side.

I catch broken references (method senders and direct access to instVar) and fix them.

Example
-----------

Script
```
	(RBMoveMethodToClassSideRefactoring 
		method: (RBTransformationRuleTestData >> #rewriteUsing:) 
		class: RBTransformationRuleTestData) execute.
```
Before refactoring:
```
RBTransformationRuleTestData >> rewriteUsing: searchReplacer 
     rewriteRule := searchReplacer.
     self resetResult.
```
After refactoring:
```
RBTransformationRuleTestData >> rewriteUsing: searchReplacer
     ^ self class rewriteUsing: searchReplace.

RBTransformationRuleTestData class >> rewriteUsing: searchReplacer
    | aRBTransformationRuleTestData |
    aRBTransformationRuleTestData := self new.
    aRBTransformationRuleTestData rewriteRule: searchReplacer.
    aRBTransformationRuleTestData resetResult.
```
"
Class {
	#name : #RBMoveMethodToClassSideRefactoring,
	#superclass : #RBMoveMethodToClassRefactoring,
	#instVars : [
		'parseTree'
	],
	#category : #'Refactoring-Core-Refactorings'
}

{ #category : #refactoring }
RBMoveMethodToClassSideRefactoring >> accessorsFor: variableName [

	^ RBCreateAccessorsForVariableRefactoring
				model: self model
				variable: variableName
				class: class
				classVariable: false
]

{ #category : #transforming }
RBMoveMethodToClassSideRefactoring >> addMethod: rbMethod to: aClass toProtocol: protocol [
	aClass addMethod: rbMethod.
	aClass compile: rbMethod source classified: {protocol}.
]

{ #category : #checking }
RBMoveMethodToClassSideRefactoring >> checkVariableNamed: aString [
	(class whoDefinesInstanceVariable: aString) ifNotNil: 
			[^ true].
	(class whoDefinesClassVariable: aString) ifNotNil: 
			[^ true].
	^ (self parseTree allDefinedVariables includes: aString) 
]

{ #category : #transforming }
RBMoveMethodToClassSideRefactoring >> getNewInstSideSource [
	| sender |
	sender := ''.
	(method argumentNames size > 0) ifTrue: [ 
		(method selector keywords) with: (method argumentNames )do: [:a :b |
		sender := sender, a, ' ', b, ' ']]
	ifFalse: [ sender := method selector ].
	^ sender, '
	^ self class ', sender
]

{ #category : #transforming }
RBMoveMethodToClassSideRefactoring >> getNewSource [

	| rewriter node temp |
	temp := self getTempName.
	node := RBParser parseMethod: method source.
	rewriter := RBParseTreeRewriter new replace: 'self' with: temp.
	(rewriter executeTree: node)
		ifTrue: [ 
			node := RBParser parseMethod: rewriter tree formattedCode.
			node body addNodeFirst:
				(RBParser parseExpression: temp , ' := self new').
			node body addTemporaryNamed: temp.
			^ node newSource ]
		ifFalse: [ ^ node sourceCode ] 
]

{ #category : #transforming }
RBMoveMethodToClassSideRefactoring >> getTempName [
	| aString counter tempName |
	counter := 0.
	aString := class canonicalArgumentName.
	tempName := aString.
	[self checkVariableNamed: tempName]
	whileTrue: [ counter := counter + 1.
		tempName := aString , counter asString ].
	^ tempName
]

{ #category : #initialization }
RBMoveMethodToClassSideRefactoring >> method: aMethod class: aClass [
	method := aMethod.
	class := self classObjectFor: aClass.
]

{ #category : #accessing }
RBMoveMethodToClassSideRefactoring >> parseTree [

	parseTree
		ifNil: [ parseTree := class parseTreeFor: method selector.
			parseTree ifNil: [ self refactoringFailure: 'Could not parse method' ]
			].
	^ parseTree
]

{ #category : #preconditions }
RBMoveMethodToClassSideRefactoring >> preconditions [
	^(RBCondition 
		definesSelector: method selector 
		in: class classSide) not
		& (RBCondition withBlock: [ class isMeta not ])
]

{ #category : #transforming }
RBMoveMethodToClassSideRefactoring >> removeInstVariableReferences [
	| rbMethod references |
	rbMethod := (class methodFor: method selector).
	references := class instanceVariableNames select: [:e | rbMethod refersToVariable: e].
	references do: [ :e | |replacer accessorsRefactoring|
		accessorsRefactoring := self accessorsFor: e.
		self performCompositeRefactoring: accessorsRefactoring.
		replacer := self parseTreeRewriterClass 
				variable: e
				getter: accessorsRefactoring getterMethod
				setter: accessorsRefactoring setterMethod.
	   self convertMethod: method selector for: class using: replacer ].
]

{ #category : #printing }
RBMoveMethodToClassSideRefactoring >> storeOn: aStream [ 
	aStream nextPut: $(.
	self class storeOn: aStream.
	aStream
		nextPutAll: ' method: '.
	method storeOn: aStream.
	aStream 
		nextPutAll: ' class: ';
		nextPutAll: class name.
	aStream
		nextPutAll: ')'
]

{ #category : #transforming }
RBMoveMethodToClassSideRefactoring >> transform [
	| oldClass newClass rbMethod rbMethod2 newSource originalProtocol newSource2 |
	newSource := self getNewInstSideSource.
	originalProtocol := method protocol.
	oldClass := class.
	self removeInstVariableReferences.
	method := class methodFor: method selector.
	newClass := self model classNamed: class name, ' class'.
	newSource2 := self getNewSource.
	rbMethod := RBClassModelFactory rbMethod for: newClass source: newSource2 selector: method selector.
	rbMethod2 := RBClassModelFactory rbMethod for: oldClass source: newSource selector: method selector.
	oldClass removeMethod: method selector.
	self addMethod: rbMethod to: newClass toProtocol: originalProtocol.
	self addMethod: rbMethod2 to: oldClass toProtocol: originalProtocol.
]
