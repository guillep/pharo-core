Extension { #name : #Class }

{ #category : #'*GT-SpotterExtensions-Core' }
Class >> definitionForSpotter [
	| str |
	str := WriteStream on: String new.
	str nextPutAll: self definitionString.
	str cr; cr.
	str nextPut: $".
	str nextPutAll: 'Hierarchy: '.
	str nextPutAll: ($> join: self allSuperclasses reversed).
	str cr; cr.
	self hasComment ifTrue: [ 
		str nextPutAll: self comment.
	].	
	str nextPut: $".
	^ str contents
]

{ #category : #'*GT-SpotterExtensions-Core' }
Class >> spotterActDefault [
	^ self browse
]

{ #category : #'*GT-SpotterExtensions-Core' }
Class >> spotterPreviewIn: aComposite [
	<spotterPreview: 10>
	aComposite pharoMethod
		title: [self name];
		display: [:each | each definitionString];
		smalltalkClass: [ nil ];
		entity: self.
		
	self flag: 'move "entity: self" somewhere else, maybe'
]
