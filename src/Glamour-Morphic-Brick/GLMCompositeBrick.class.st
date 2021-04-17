"
I'm a composite brick that provides an api of creating different kind of scriptabe presentations like: 
 - list
 - pharoMethod
 - table
 - tree
"
Class {
	#name : #GLMCompositeBrick,
	#superclass : #GLMBrick,
	#category : #'Glamour-Morphic-Brick-Widgets-Phlow'
}

{ #category : #examples }
GLMCompositeBrick class >> exampleListClassMethodsOpen [

	self gtExampleListClassMethods openInBrickWindow
]

{ #category : #examples }
GLMCompositeBrick class >> exampleListOpen [

	self gtExampleList openInBrickWindow
]

{ #category : #examples }
GLMCompositeBrick class >> exampleListWithCustomItemsOpen [

	self gtExampleListWithCustomItems openInBrickWindowLabeled: 'Phlow list with custom item'
]

{ #category : #examples }
GLMCompositeBrick class >> examplePharoMethodOpen [

	self gtExamplePharoMethod openInBrickWindowLabeled: 'Phlow Pharo method'
]

{ #category : #examples }
GLMCompositeBrick class >> exampleTableOpen [

	self gtExampleTable openInBrickWindowLabeled: 'Phlowr table'
]

{ #category : #examples }
GLMCompositeBrick class >> gtExampleList [
	<gtExample>
	<label: 'Phlow simple list'>

	^ self new
		hSpaceFill;
		vSpaceFill;
		with: [ :b |
			b list
				title: 'Example';
				display: [ :x | x + 3 ];
				format: [ :anInteger | anInteger asString, ')' ];
				entity: (1 to: 100) ]
]

{ #category : #examples }
GLMCompositeBrick class >> gtExampleListClassMethods [
	<gtExample>
	<label: 'Phlow list displaying all methods of an object '>

	^ self new
		hSpaceFill;
		vSpaceFill;
		with: [ :b |
			b list
			title: 'Methods of Object';
			display: #yourself;
			format: [ :compiledMethod | compiledMethod displayString ];
			styled: [ :brick | brick height: 30 ];
			entity: Object methods ]
]

{ #category : #examples }
GLMCompositeBrick class >> gtExampleListWithCustomItems [
	<gtExample>
	<label: 'Phlow list with custom items'>

	^ self new
		hSpaceFill;
		vSpaceFill;
		with: [ :b |
			b list
				title: 'Example with custom items';
				display: [ :x | x + 3 ];
				format: [ :anInteger | anInteger asString ];
				styled: [ :aBrick | aBrick textPosition: #center; textColor: Color random ];
				entity: (1 to: 100) ]
]

{ #category : #examples }
GLMCompositeBrick class >> gtExamplePharoMethod [
	<gtExample>
	<label: 'Phlow Pharo method'>

	^ self new
		hSpaceFill;
		vSpaceFill;
		with: [ :b |
			b pharoMethod
				title: #printString;
				display: #sourceCode;
				smalltalkClass: #methodClass;
				entity: Morph>>#bounds ]
]

{ #category : #examples }
GLMCompositeBrick class >> gtExampleTable [
	<gtExample>
	<label: 'Phlowr table'>
	
	^ self new
		hSpaceFill;
		vSpaceFill;
		with: [ :b |
			b table
				title: #asString;
				display: [ :anObject | (anObject gtInspectorVariableValuePairs asSortedCollection asOrderedCollection yourself) addFirst: 'self' -> anObject; yourself ];
				column: 'Variable'
					evaluated: [:assoc |	GTObjectPrinter asNonTruncatedTextFrom: assoc key ]
					styled: [ :aBrick | aBrick textPosition: #rightCenter; margin: #(0 15 0 0); textColor: Color lightGray ];
				column: 'Variable'
					evaluated: [:assoc | GTObjectPrinter asTruncatedTextFrom: assoc value ]
					styled: [ :aBrick | aBrick margin: #(0 0 0 15) ];
				entity: Morph new ]
]

{ #category : #phlow }
GLMCompositeBrick >> custom: aBrick [
	self flag: 'for now we only allow one subbrick in the composite.
	We have to revisit this implementation after the composite will allow for multiple subbricks'.
	self hasSubbricks ifFalse: [ self addBrickBack: aBrick ].
	^ aBrick
]

{ #category : #phlow }
GLMCompositeBrick >> list [

	^ self custom: GLMPhlowListBrick new
]

{ #category : #phlow }
GLMCompositeBrick >> pharoMethod [

	^ self custom: GLMPhlowPharoMethodBrick new
]

{ #category : #phlow }
GLMCompositeBrick >> table [

	^ self custom: GLMPhlowTableBrick new
]

{ #category : #phlow }
GLMCompositeBrick >> text [

	^ self custom: GLMPhlowTextBrick new
]

{ #category : #phlow }
GLMCompositeBrick >> tree [
]
