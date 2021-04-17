Extension { #name : #RGMethodDefinition }

{ #category : #'*GT-SpotterExtensions-Core' }
RGMethodDefinition >> spotterPreviewIn: aComposite [
	<spotterPreview: 10>
	aComposite pharoMethod
		title: [ self displayString ];
		display: [ :methodDefinition | 
			' ', methodDefinition sourceCode];
		smalltalkClass: [self methodClass];
		entity: self.
		
	self flag: 'move "entity: self" somewhere else, maybe'
]
