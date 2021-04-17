Extension { #name : #CompiledMethod }

{ #category : #'*GT-SpotterExtensions-Core' }
CompiledMethod >> spotterActDefault [
	^ self browse
]

{ #category : #'*GT-SpotterExtensions-Core' }
CompiledMethod >> spotterPreviewIn: aComposite [
	<spotterPreview: 10>
	aComposite pharoMethod
		title: [ self displayString ];
		display: [:compiledMethod | 
			' ', compiledMethod sourceCode];
		smalltalkClass: [self methodClass];
		entity: self.
		
	self flag: 'move "entity: self" somewhere else, maybe'
]

{ #category : #'*GT-SpotterExtensions-Core' }
CompiledMethod >> spotterSelectFor: aStep [
	" ignore :) "
]
