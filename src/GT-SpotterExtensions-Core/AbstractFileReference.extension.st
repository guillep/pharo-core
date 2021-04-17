Extension { #name : #AbstractFileReference }

{ #category : #'*GT-SpotterExtensions-Core' }
AbstractFileReference >> isZipFile [
	^ self isFile and: [ #('zip' 'jar' 'ear' 'war') includes: self extension ]
]

{ #category : #'*GT-SpotterExtensions-Core' }
AbstractFileReference >> spotterPreviewContentsIn: aComposite [
	<spotterPreview: 20>
	
	self isFile ifFalse: [ ^ self ].
	aComposite text
		title: [ self displayString ]; 
		display: #yourself;
		entity: (self readStreamDo: [ :stream | 
					| result |
					result := [(stream next: 10000) asString]
						on: Error 
						do: [ (stream binary next: 10000) asString ].
					stream size > 10000
						ifTrue: [ result, '  ... truncated ...' ]
						ifFalse: [ result ] ])
]

{ #category : #'*GT-SpotterExtensions-Core' }
AbstractFileReference >> spotterPreviewItemsIn: aComposite [
	<spotterPreview: 10>
	
	self isDirectory ifFalse: [ ^ self ].
	aComposite list
		title: [ self displayString ];
		display: #yourself;
		format: [ :folder | 
			|iconName |			
			iconName := folder isDirectory 
				ifTrue: [ #glamorousFolder ]
				ifFalse: [ #glamorousBrowse ].
			
			GTSpotterItemBrick new 
				text: folder basename; 
				icon: (self iconNamed: iconName); 
				disable; 
				yourself ];
		styled: [ :brick | brick ];
		entity: self directories, self files.
		
	self flag: 'move "entity: self" somewhere else, maybe'
]

{ #category : #'*GT-SpotterExtensions-Core' }
AbstractFileReference >> spotterPreviewPngIn: aComposite [
	<spotterPreview: 10>
	
	(self mimeTypes notNil and: [ 
		self mimeTypes first matches: ZnMimeType imagePng ]) 
		ifFalse: [ ^ self ].
	aComposite custom: 
		((self binaryReadStreamDo: [ :stream | PNGReadWriter formFromStream: stream ])
			asAlphaImageMorph asBrick margin: 20)
]

{ #category : #'*GT-SpotterExtensions-Core' }
AbstractFileReference >> spotterPreviewStScriptIn: aComposite [
	<spotterPreview: 10>
	
	(self extension = 'st' or: [self extension = 'ph']) 
		ifFalse: [ ^ self ].
	aComposite pharoMethod 
		title: [self displayString];
		display: #yourself;
		smalltalkClass: [ nil ];
		entity: (self readStreamDo: #contents)
]

{ #category : #'*GT-SpotterExtensions-Core' }
AbstractFileReference >> spotterPreviewZipItemsIn: aComposite [
	<spotterPreview: 10>

	| zip |
	self isZipFile ifFalse: [ ^ self ].
	zip:= (FileSystem zip: self) open workingDirectory.
	aComposite list
		title: [ self displayString ];
		display: #yourself;
		format: [ :folder | 
			|iconName |			
			iconName := folder isDirectory 
				ifTrue: [ #glamorousFolder ]
				ifFalse: [ #glamorousBrowse ].
				
			GTSpotterItemBrick new 
				text: folder basename; 
				icon: (self iconNamed: iconName); 
				disable; 
				yourself ];
		styled: [ :brick | brick ];
		entity: (zip directories, zip files)
]
