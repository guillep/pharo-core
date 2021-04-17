Extension { #name : #AbstractFileReference }

{ #category : #'*NewTools-Spotter-Extensions' }
AbstractFileReference >> spotterForDirectoriesFor: aStep [
	<stSpotterOrder: 10>
	^ self isDirectory ifTrue: [
		aStep listProcessor
			allCandidates: [ self directories ];
			title: 'Directories';
			candidatesLimit: Float infinity;
			itemName: #basename;
			itemIcon: [ GLMUIThemeExtraIcons glamorousFolder ];
			filter: GTFilterSubstring ]
]

{ #category : #'*NewTools-Spotter-Extensions' }
AbstractFileReference >> spotterForFilesFor: aStep [
	<stSpotterOrder: 20>
	^ self isDirectory ifTrue: [
		aStep listProcessor
			allCandidates: [ self files ];
			title: 'Files';
			candidatesLimit: Float infinity;
			itemName: #basename;
			itemIcon: [ GLMUIThemeExtraIcons glamorousBrowse ];
			filter: GTFilterSubstring ]
]

{ #category : #'*NewTools-Spotter-Extensions' }
AbstractFileReference >> spotterForZipDirectoriesFor: aStep [
	<stSpotterOrder: 10>
	| zipFileSystem |
	self isZipFile ifFalse: [ ^ self ].
	aStep listProcessor
			allCandidates: [ 
				zipFileSystem := (FileSystem zip: self) open.
				zipFileSystem workingDirectory directories ];
			title: 'Directories';
			candidatesLimit: Float infinity;
			itemName: #basename;
			itemIcon: [ GLMUIThemeExtraIcons glamorousFolder ];
			filter: GTFilterSubstring
]

{ #category : #'*NewTools-Spotter-Extensions' }
AbstractFileReference >> spotterForZipFilesFor: aStep [
	<stSpotterOrder: 10>
	| zipFileSystem |
	self isZipFile ifFalse: [ ^ self ].
	aStep listProcessor
			allCandidates: [ 
				zipFileSystem := (FileSystem zip: self) open.
				zipFileSystem workingDirectory files ];
			title: 'Files';
			candidatesLimit: Float infinity;
			itemName: #basename;
			itemIcon: [ GLMUIThemeExtraIcons glamorousBrowse ];
			filter: GTFilterSubstring
	
]
