Class {
	#name : #OCDoitTest,
	#superclass : #TestCase,
	#instVars : [
		'ivarForTesting'
	],
	#category : #'OpalCompiler-Tests-Misc'
}

{ #category : #binding }
OCDoitTest >> bindingOf: aSelector [
	^(aSelector == #requestorVarForTesting) 
		ifTrue: [WorkspaceVariable key: aSelector value: 5 ]
		ifFalse:  [nil]
]

{ #category : #binding }
OCDoitTest >> hasBindingOf: aSelector [
	^aSelector == #requestorVarForTesting
]

{ #category : #'interactive error protocol' }
OCDoitTest >> notify: aString at: anInteger in: aString3 [ 
	"we ignore"
]

{ #category : #tests }
OCDoitTest >> testDoItContextReadGlobal [
	"we can read a global from a doit when executing against a context"

	|  value |	
	value := OpalCompiler new
		source: 'Object';
		context: thisContext;
		evaluate.
		
	self assert: value equals: Object
]

{ #category : #tests }
OCDoitTest >> testDoItContextReadIvar [

	| value method |
	"we can read this ivar from a doit when executing against thisContext"
	ivarForTesting := #someValue.

	method := OpalCompiler new
		          source: 'ivarForTesting';
		          noPattern: true;
		          context: thisContext;
		          compileDoit.

	value := method valueWithReceiver: self arguments: { thisContext }.
	self assert: value equals: #someValue
]

{ #category : #tests }
OCDoitTest >> testDoItContextReadTemp [
	| tempForTesting value |
	"we can read this temp from a doit when executing against thisContext"
	tempForTesting := #someValue.
	
	value := OpalCompiler new
		source: 'tempForTesting';
		context: thisContext;
		evaluate.
		
	self assert: value equals: #someValue
]

{ #category : #tests }
OCDoitTest >> testDoItRequestorEvalError [
	| value |
	value  := OpalCompiler new 
	requestor: self;
	evaluate: '1('.

	self assert: value isNil.
]

{ #category : #tests }
OCDoitTest >> testDoItRequestorReadRequestorVar [

	| value  |
	"we can read a variable from a requestor"
	value := OpalCompiler new
		          source: 'requestorVarForTesting';
		          noPattern: true;
		          requestor: self;
		          evaluate.
		
	self assert: value equals: 5
]

{ #category : #tests }
OCDoitTest >> testDoitContextCheckClass [
	"if we create a parse tree for a doit in a context, the class should be correctly set"
	
	| ast |
	ast := OpalCompiler new
		source: 'tempForTesting';
		noPattern: true;
		context: thisContext;
		parseDoIt.
	"we expect that the class is set to the class of the context, which is self class"		
	self assert: ast methodClass equals: self class
]
