"
Look at the `OCASTCompilerPlugin` class comment for information about compiler plugins.

I allow the dynamic creation of compiler plugins.

Instantiate me using either
 - `newFromTransformBlock: aBlock andPriority: aPriority` - _to get a compiler plugin with custom transformation block and priority_ or
 - `newFromTransformBlock: aBlock` - _to get a compiler plugin with custom transformation block and default high priority_

You can then add the new plugin to an OpalCompiler instance with OpalCompiler>>addPlugin:

- aBlock must be a block of the form [ :ast | do something to ast ] that returns the modified ast.
- aPriority is the priority the created plugin should have

Check out my test class (`OCASTDynamicCompilerPluginTest`) for a usage example.
"
Class {
	#name : #OCDynamicASTCompilerPlugin,
	#superclass : #OCASTCompilerPlugin,
	#instVars : [
		'priority',
		'transformBlock'
	],
	#category : #'OpalCompiler-Core-Plugins'
}

{ #category : #'instance creation' }
OCDynamicASTCompilerPlugin class >> newFromTransformBlock: aBlock [
	"Return a new instance of the receiver using the given AST transformation block and default priority."

	^ self new
		transformBlock: aBlock;
		yourself
]

{ #category : #'instance creation' }
OCDynamicASTCompilerPlugin class >> newFromTransformBlock: aBlock andPriority: aPriority [
	"Return a new instance of the receiver using the given AST transformation block and the given priority."

	^ (self newFromTransformBlock: aBlock)
			priority: aPriority;
			yourself
]

{ #category : #initialization }
OCDynamicASTCompilerPlugin >> initialize [

	super initialize.
	self priority: self class defaultPriority 
]

{ #category : #accessing }
OCDynamicASTCompilerPlugin >> priority [
	^ priority
]

{ #category : #accessing }
OCDynamicASTCompilerPlugin >> priority: anObject [
	priority := anObject
]

{ #category : #transforming }
OCDynamicASTCompilerPlugin >> transform: ast [
	^ transformBlock value: ast copy
]

{ #category : #accessing }
OCDynamicASTCompilerPlugin >> transformBlock [
	^ transformBlock
]

{ #category : #accessing }
OCDynamicASTCompilerPlugin >> transformBlock: anObject [
	transformBlock := anObject
]
