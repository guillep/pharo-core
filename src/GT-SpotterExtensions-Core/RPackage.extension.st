Extension { #name : #RPackage }

{ #category : #'*GT-SpotterExtensions-Core' }
RPackage >> spotterActDefault [
	^ Smalltalk tools browser openOnPackage: self
]

{ #category : #'*GT-SpotterExtensions-Core' }
RPackage >> spotterPreviewIn: aComposite [
	<spotterPreview: 10>
	aComposite list
		title: 'Preview';
		display: [ :x | x ];
		format: [ :class | GTSpotterItemBrick new text: class displayString; icon: class systemIcon; disable; yourself ];
		entity: self classes asArray.
		
	self flag: 'move "entity: self" somewhere else, maybe'
]
