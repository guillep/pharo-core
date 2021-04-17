"
I'm a fake commit that serves as model for Hiedra examples.

The example methods in class-side captured the commits in real git tags.
To capture each one, the following code was inserted into IceTipCommitsDataSource>>elements:

~~~~
[	| commits commitsAsString sourceCode selector |
	commits := elements collect: [:each | 
		HiExampleCommit new
			id: each entity id;
			comment: each entity comment;
			parentIds: each entity ancestorIds;
			yourself ].
	commitsAsString := STON toStringPretty: commits.
	selector := tool model repositoryModel name, '_', ((tool model name copyReplaceAll: '.' with: '_') copyReplaceAll: '-' with: '_').
	sourceCode := selector, '
	^ STON fromString: (', commitsAsString storeString, ')'.
	HiExampleCommit classSide compile: sourceCode classified: #examples. 
] value.

~~~~


"
Class {
	#name : #HiExampleCommit,
	#superclass : #Object,
	#instVars : [
		'id',
		'comment',
		'parentIds'
	],
	#category : #'Hiedra-Examples-Model'
}

{ #category : #examples }
HiExampleCommit class >> randomlyGenerated [

	| values random |
	values := 60 to: 1 by: -1.
	random := Random new.
	^ (values collect: [ :value | 
		self new
			id: value;
			comment: 'Randomly Connected Element #', value asString;
			parentIds: ((values copyWithout: value) intersection: { random nextInteger: values max });
			yourself
		]) reversed
]

{ #category : #accessing }
HiExampleCommit >> comment [
	^ comment
]

{ #category : #accessing }
HiExampleCommit >> comment: anObject [
	comment := anObject
]

{ #category : #accessing }
HiExampleCommit >> id [
	^ id
]

{ #category : #accessing }
HiExampleCommit >> id: anObject [
	id := anObject
]

{ #category : #accessing }
HiExampleCommit >> parentIds [
	^ parentIds
]

{ #category : #accessing }
HiExampleCommit >> parentIds: aCollection [
	parentIds := aCollection
]

{ #category : #printing }
HiExampleCommit >> printOn: aStream [
	"Append a sequence of characters to aStream that identify the receiver."

	super printOn: aStream.

	aStream
		nextPut: $(;
		print: id;
		nextPutAll: ' -> ';
		print: parentIds asArray;
		nextPut: $).

]
