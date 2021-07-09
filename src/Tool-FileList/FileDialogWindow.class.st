"
Dialog based file chooser for selecting or saving files. Supports various types of answer (file stream, file name, directory path etc) with optional extension filters and image or text file preview.
"
Class {
	#name : #FileDialogWindow,
	#superclass : #DialogWindowMorph,
	#instVars : [
		'directoryTreeMorph',
		'fileListMorph',
		'directories',
		'selectedDirectory',
		'selectedFileIndex',
		'fileSelectionBlock',
		'showDirectoriesInFileList',
		'fileSortBlock',
		'fileNameText',
		'defaultExtension',
		'actionSelector',
		'answer',
		'entryCache',
		'entryCacheDirectory',
		'previewType',
		'previewMorph',
		'preferredFileSystem'
	],
	#category : #'Tool-FileList'
}

{ #category : #examples }
FileDialogWindow class >> example [
	<example>
	(self onFileSystem: FileSystem disk) open
]

{ #category : #'initialize - release' }
FileDialogWindow class >> onFileSystem: aFileSystem [
	^ self basicNew
		initializeOn: aFileSystem;
		yourself
]

{ #category : #icons }
FileDialogWindow class >> taskbarIconName [
	"Answer the icon for the receiver in a task bar."

	^#smallOpenIcon
]

{ #category : #accessing }
FileDialogWindow >> actionSelector [
	"Answer the value of actionSelector"

	^ actionSelector
]

{ #category : #accessing }
FileDialogWindow >> actionSelector: anObject [
	"Set the value of actionSelector"

	actionSelector := anObject
]

{ #category : #actions }
FileDialogWindow >> addInitialPanel [
	super addInitialPanel.
	self selectDirectory: self preferredFileSystem workingDirectory
]

{ #category : #accessing }
FileDialogWindow >> answer [
	"Answer the result of performing the action selector."
	
	self cancelled ifTrue: [^nil].
	^answer
]

{ #category : #accessing }
FileDialogWindow >> answer: anObject [
	"Set the answer."
	
	answer := anObject
]

{ #category : #accessing }
FileDialogWindow >> answerDirectory [
	"Set the receiver to answer a directory."
	
	self actionSelector: #selectedAnyFileDirectory.
	self fileSelectionBlock: self directoryFileSelectionBlock.
	self changed: #okEnabled
]

{ #category : #actions }
FileDialogWindow >> answerFileEntry [
	"Set the receiver to answer the selected file entry."
	
	self actionSelector: #selectedFileEntry.
	self changed: #okEnabled
]

{ #category : #actions }
FileDialogWindow >> answerFileName [
	"Set the receiver to answer the selected file name."
	
	self actionSelector: #selectedFileName.
	self changed: #okEnabled
]

{ #category : #actions }
FileDialogWindow >> answerOpenFile [
	"Set the receiver to answer a new file stream on an existing file."
	
	self actionSelector: #openSelectedFile.
	self changed: #okEnabled
]

{ #category : #actions }
FileDialogWindow >> answerPathName [
	"Set the receiver to answer the selected path name."
	
	self actionSelector: #selectedPathName.
	self changed: #okEnabled
]

{ #category : #actions }
FileDialogWindow >> answerSaveFile [
	"Set the receiver to answer a new file stream."
	
	self actionSelector: #saveSelectedFile.
	self changed: #okEnabled
]

{ #category : #accessing }
FileDialogWindow >> cache: dir [
	"Cache the contents of the given directory and answer them."

	self entryCacheDirectory = dir
		ifFalse: [Cursor wait showWhile: [
					self
						entryCache: (self dirEntriesOrEmptyListFor: dir);
						entryCacheDirectory: dir]].
	^self entryCache
]

{ #category : #actions }
FileDialogWindow >> clearEntryCache [
	"Clear the entry cache."

	self
		entryCache: nil;
		entryCacheDirectory: nil
]

{ #category : #actions }
FileDialogWindow >> confirmDeleteDirectoryEntry: entry [
	(self proceed: 'Are you sure you wish to delete the\selected directory along with its files?' withCRs translated
	      title: 'Delete Directory' translated)
		ifTrue: [ self deleteDirectoryEntry: entry ]
]

{ #category : #actions }
FileDialogWindow >> confirmDeleteFileEntry: entry [
	(self
		 proceed: 'Are you sure you wish to delete the\file' withCRs translated , ' "' , entry name , '"?'
		 title: 'Delete File' translated) 
		ifTrue: [ self deleteFileEntry: entry ]
]

{ #category : #accessing }
FileDialogWindow >> defaultExtension [
	"Answer the value of defaultExtension"

	^ defaultExtension
]

{ #category : #accessing }
FileDialogWindow >> defaultExtension: anObject [
	"Set the value of defaultExtension"

	defaultExtension := anObject
]

{ #category : #accessing }
FileDialogWindow >> defaultFileSelectionBlock [
	"Answer the default file selection block."

	^[:entry |
		entry isDirectory
			ifTrue: [self showDirectoriesInFileList]
			ifFalse: [self fileNamePattern match: entry basename]]
]

{ #category : #accessing }
FileDialogWindow >> defaultFileSortBlock [
	"Answer the default file stor block"

	^[:entry1 :entry2 |
		entry1 isDirectory = entry2 isDirectory
			ifTrue: [entry1 basename caseInsensitiveLessOrEqual: entry2 basename]
			ifFalse: [entry1 isDirectory
						ifTrue: [true]
						ifFalse: [entry2 isDirectory
									ifTrue: [false]
									ifFalse: [entry1 basename caseInsensitiveLessOrEqual: entry2 basename]]]]
]

{ #category : #actions }
FileDialogWindow >> defaultLabel [
	"Answer the default label for the receiver."

	^'File' translated
]

{ #category : #actions }
FileDialogWindow >> deleteDirectoryEntry: entry [
	entry asFileReference deleteAll.
	self
		clearEntryCache;
		updateDirectories
]

{ #category : #actions }
FileDialogWindow >> deleteFileEntry: entry [
	entry asFileReference delete.
	self
		selectedFileIndex: 0;
		clearEntryCache;
		updateFiles 
]

{ #category : #actions }
FileDialogWindow >> deleteFileOrDirectory [

	"Delete the selected file or directory."

	| entry |
	self hasSelectedFileOrDirectory ifFalse: [ ^ self ].
	entry := self selectedFileEntry.
	entry isDirectory
		ifTrue: [ self confirmDeleteDirectoryEntry: entry	 ]
		ifFalse: [ self confirmDeleteFileEntry: entry ]
]

{ #category : #private }
FileDialogWindow >> dirEntriesOrEmptyListFor: aDirectory [
|entries|
	aDirectory isReadable ifFalse:[ ^ #()].
	entries := [aDirectory entries] on: DirectoryDoesNotExist do:[#()].
	^ entries
]

{ #category : #accessing }
FileDialogWindow >> directories [
	^ directories
]

{ #category : #accessing }
FileDialogWindow >> directories: anObject [
	"Set the value of directories"

	directories := anObject
]

{ #category : #private }
FileDialogWindow >> directoriesFor: item [
	"Answer the filtered entries."
	
	^item directories
]

{ #category : #accessing }
FileDialogWindow >> directoryFileSelectionBlock [
	"Answer the directory file selection block."

	^[:de |
		de isDirectory
			ifTrue: [self showDirectoriesInFileList]
			ifFalse: [false]] 
]

{ #category : #accessing }
FileDialogWindow >> directoryTreeMorph [
	"Answer the value of directoryTreeMorph"

	^ directoryTreeMorph
]

{ #category : #accessing }
FileDialogWindow >> directoryTreeMorph: anObject [
	"Set the value of directoryTreeMorph"

	directoryTreeMorph := anObject
]

{ #category : #actions }
FileDialogWindow >> doubleClickFile [
	"If the selected entry is a directory then navigate it
	otherwise ok the dialog."
	
	|fe de sm|
	fe := self selectedFileEntry.
	fe ifNil: [^self].
	fe isDirectory
		ifTrue: [de := self selectedFileDirectory.
				sm := self directoryTreeMorph selectedMorph.
				self changed: #(openPath), de pathSegments.
				sm := self directoryTreeMorph selectedMorph.
				self selectedDirectory: (sm children detect: [:w |
					w complexContents item basename  = fe basename ]) complexContents]
		ifFalse: [self ok]
]

{ #category : #accessing }
FileDialogWindow >> entryCache [
	"Answer the value of entryCache"

	^ entryCache
]

{ #category : #accessing }
FileDialogWindow >> entryCache: anObject [
	"Set the value of entryCache"

	entryCache := anObject
]

{ #category : #accessing }
FileDialogWindow >> entryCacheDirectory [
	"Answer the value of entryCacheDirectory"

	^ entryCacheDirectory
]

{ #category : #accessing }
FileDialogWindow >> entryCacheDirectory: anObject [
	"Set the value of entryCacheDirectory"

	entryCacheDirectory := anObject
]

{ #category : #accessing }
FileDialogWindow >> fileListMorph [
	"Answer the value of fileListMorph"

	^ fileListMorph
]

{ #category : #accessing }
FileDialogWindow >> fileListMorph: anObject [
	"Set the value of fileListMorph"

	fileListMorph := anObject
]

{ #category : #accessing }
FileDialogWindow >> fileNamePattern [
	"Answer the file name pattern to filter on."
	
	^self fileNameText trimBoth, '*'
]

{ #category : #accessing }
FileDialogWindow >> fileNameText [
	"Answer the typed file name."

	^fileNameText
]

{ #category : #accessing }
FileDialogWindow >> fileNameText: aString [
	"The typed file name has changed."

	fileNameText = aString asString ifTrue: [^self].
	fileNameText := aString asString.
	self updateFiles.
	self
		changed: #fileNameText;
		changed: #okEnabled.
	self selectFileFromPattern
]

{ #category : #accessing }
FileDialogWindow >> fileSelectionBlock [
	"Answer the value of fileSelectionBlock"

	^ fileSelectionBlock
]

{ #category : #accessing }
FileDialogWindow >> fileSelectionBlock: anObject [
	"Set the value of fileSelectionBlock"

	fileSelectionBlock := anObject.
	self updateFiles
]

{ #category : #accessing }
FileDialogWindow >> fileSortBlock [
	"Answer the value of fileSortBlock"

	^ fileSortBlock
]

{ #category : #accessing }
FileDialogWindow >> fileSortBlock: anObject [
	"Set the value of fileSortBlock"

	fileSortBlock := anObject
]

{ #category : #enumerating }
FileDialogWindow >> files [
	"Answer the contents of the selected directory."

	self selectedFileDirectory ifNil: [ ^#() ].
	
	^Cursor wait showWhile: [ | cache filteredCache |
		cache := self cache: self selectedFileDirectory.
		filteredCache := cache select: self fileSelectionBlock.
		filteredCache asSortedCollection: self fileSortBlock ].
]

{ #category : #testing }
FileDialogWindow >> hasParentDirectory [
	"Answer whether the selected directory in the tree part has a parent."

	^ self selectedFileDirectory ifNotNil: [ :dir | dir isRoot not ] ifNil: [ false ].
]

{ #category : #testing }
FileDialogWindow >> hasSelectedFileOrDirectory [
	"Answer whether a file or directopry is selected in the file list."

	^ self selectedFileIndex ~= 0
]

{ #category : #'widget API' }
FileDialogWindow >> iconFor: anEntry [
	"Answer the icon to use for the directory entry."

	^ anEntry isDirectory
		ifTrue: [ self iconNamed: #smallOpenIcon ]
		ifFalse: [ (self isImageFile: anEntry basename)
				ifTrue: [ self iconNamed: #smallPaintIcon ]
				ifFalse: [ self iconNamed: #smallLeftFlushIcon ] ]
]

{ #category : #actions }
FileDialogWindow >> initialDirectories [
	"Answer the initial directories."

	| dirList |
	dirList := self preferredFileSystem root directories collect: [ :each | FileDirectoryWrapper with: each name: each basename model: self ] as: OrderedCollection.
	dirList add: (FileDirectoryWrapper with: self preferredFileSystem root name: self preferredFileSystem root basename model: self).
	dirList isEmpty
		ifTrue: [ | workingDirectory wrapper |
			workingDirectory := self preferredFileSystem workingDirectory.
			wrapper := FileDirectoryWrapper with: workingDirectory name: workingDirectory basename model: self.
			dirList := Array with: wrapper ].
	^ dirList
]

{ #category : #initialization }
FileDialogWindow >> initialExtent [
	^ 750@550
]

{ #category : #initialization }
FileDialogWindow >> initialize [
	selectedFileIndex := 0.
	fileNameText := ''.
	self
		answerPathName;
		directories: self initialDirectories;
		showDirectoriesInFileList: true;
		fileSelectionBlock: self defaultFileSelectionBlock;
		fileSortBlock: self defaultFileSortBlock.
	super initialize	"Must be at end or signals error. No idea why - SeanDeNigris"
]

{ #category : #initialization }
FileDialogWindow >> initializeOn: aFileSystem [
	self preferredFileSystem: aFileSystem.
	self initialize
]

{ #category : #testing }
FileDialogWindow >> isImageFile: aString [
	"Answer whether the file name indicates an image file."

	aString ifNil: [^false].
	^#('pcx' 'bmp' 'jpeg' 'xbm' 'pnm' 'ppm' 'gif' 'pam' 'jpg' 'png' 'pbm')
		includes: aString asFileReference extension asLowercase
]

{ #category : #accessing }
FileDialogWindow >> isResizeable [
	"Answer whether we are not we can be resized."

	^true
]

{ #category : #'instance creation' }
FileDialogWindow >> newActionButtonRow [
	"Answer a new row with the action buttons."
	
	^(self newRow: {
		self newUpButton.
		self newNewDirectoryButton.
		self newDeleteButton})
		listCentering: #bottomRight
]

{ #category : #actions }
FileDialogWindow >> newContentMorph [
	"Answer a new content morph."

	self
		directoryTreeMorph: self newDirectoryTree;
		fileListMorph: self newFileList;
		previewMorph: self newPreviewMorph.
	^(self newRow: {
		self newColumn: {
			self newGroupbox: 'Directory' translated for: self directoryTreeMorph.
			(self newLabelGroup: {
				'File name' translated->self newFileNameTextEntry})
				vResizing: #shrinkWrap}.
		self newGroupbox: 'File' translated forAll: {
			self fileListMorph.
			self newActionButtonRow}},
		(self previewMorph notNil
			ifTrue: [{self newGroupbox: 'Preview' translated for: self previewMorph}]
			ifFalse: [#()]))
		vResizing: #spaceFill
]

{ #category : #'instance creation' }
FileDialogWindow >> newDeleteButton [
	"Answer a new delete button."

	^ self
		newButtonFor: self
		getState: nil
		action: #deleteFileOrDirectory
		arguments: nil
		getEnabled: #hasSelectedFileOrDirectory
		labelForm: (self iconNamed: #smallDeleteIcon)
		help: 'Press to delete the selected file or directory' translated
]

{ #category : #'instance creation' }
FileDialogWindow >> newDirectory [
	"Create a new directory within the selected directory."

	|dir dirName title|
	dir := self selectedFileDirectory ifNil: [^self].
	title := 'Create Directory' translated.
	dirName := self
		textEntry: 'Enter directory name' translated
		title: title.
	dirName ifNil: [^self].
	
	[
		(dir / dirName) exists
			ifTrue: [
				^self
					alert: 'A file or directory already exists\with the name' withCRs translated, ' "', dirName, '"'
					title: title
		].
		(dir / dirName) ensureCreateDirectory
	]
	on: Error
	do: [:ex |
		^self
			alert: 'Invalid directory name' translated, ' "', dirName, '"'
			title: title
	].

	self
		clearEntryCache;
		updateDirectories
]

{ #category : #'instance creation' }
FileDialogWindow >> newDirectoryTree [
	"Answer a new directory tree."
	
	^(self newTreeFor: self
		list: #directories
		selected: #selectedDirectory
		changeSelected: #selectedDirectory:)
		minHeight: 200;
		minWidth: 180
]

{ #category : #'instance creation' }
FileDialogWindow >> newFileList [
	"Answer a new file list."
	
	^(self
			newListFor: self
			list: #files
			selected: #selectedFileIndex
			changeSelected: #selectedFileIndex:
			icon: #iconFor:
			getEnabled: nil
			help: nil)
		wrapSelector: #basename;
		doubleClickSelector: #doubleClickFile;
		minWidth: 200
]

{ #category : #'instance creation' }
FileDialogWindow >> newFileNameTextEntry [
	"Answer a new file name text entry morph."

	^self
		newAutoAcceptTextEntryFor: self
		getText: #fileNameText
		setText: #fileNameText:
		getEnabled: nil
		help: 'File name filter pattern' translated
]

{ #category : #'instance creation' }
FileDialogWindow >> newImagePreviewMorph [
	"Answer a new image preview morph."

	^ImagePreviewMorph new
		cornerStyle: self preferredCornerStyle;
		image: nil
		size: self previewSize
]

{ #category : #'instance creation' }
FileDialogWindow >> newNewDirectoryButton [
	"Answer a new 'new directory' button."

	^ self
		newButtonFor: self
		getState: nil
		action: #newDirectory
		arguments: nil
		getEnabled: nil
		labelForm: (self iconNamed: #smallOpenIcon)
		help:
			'Press to create a new directory within the current directory'
				translated
]

{ #category : #controls }
FileDialogWindow >> newOKButton [
	"Answer a new OK button."

	^self
		newOKButtonFor: self
		getEnabled: #okEnabled
]

{ #category : #'instance creation' }
FileDialogWindow >> newPreviewMorph [
	"Answer a new preview morph."

	self previewType == #image ifTrue: [^self newImagePreviewMorph].
	self previewType == #text ifTrue: [^self newTextPreviewMorph].
	^nil
]

{ #category : #'instance creation' }
FileDialogWindow >> newTextPreviewMorph [
	"Answer a new text preview morph."

	^(self newTextEditorFor: self getText: nil setText: nil getEnabled: nil)
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		extent: self previewSize;
		minWidth: self previewSize x;
		minHeight: self previewSize y;
		enabled: false
]

{ #category : #'instance creation' }
FileDialogWindow >> newUpButton [
	"Answer a new up one directory level button."

	^ self
		newButtonFor: self
		getState: nil
		action: #selectParentDirectory
		arguments: nil
		getEnabled: #hasParentDirectory
		labelForm: (self iconNamed: #smallUndoIcon)
		help: 'Press to switch to the parent of the current directory' translated
]

{ #category : #actions }
FileDialogWindow >> ok [
	"Apply the changes and close."

	self cancelled: false.
	self applyChanges.
	self answer: (self perform: self actionSelector).
	answer ifNil: [
		self cancelled: true.
		^self delete].
	super ok
]

{ #category : #testing }
FileDialogWindow >> okEnabled [
	"Answer wether the ok button should be enabled."

	(#(selectedAnyFileDirectory selectedPathName)
			includes: self actionSelector) ifTrue: [^true].
	((#(saveSelectedFile saveForcedSelectedFile)
			includes: self actionSelector) and: [self fileNameText notEmpty]) ifTrue: [^true].
	(self actionSelector = #selectedFileName and: [
		self selectedFileName notNil]) ifTrue: [^true].
	^self selectedFileName notNil and: [self selectedFileEntry isDirectory not]
]

{ #category : #'open/close' }
FileDialogWindow >> openSelectedFile [
	"Open a stream on the selected file if available and return it."

	|d f fileRef |
	d := self selectedFileDirectory ifNil: [^nil].
	f := self selectedFileName ifNil: [^nil].
	self selectedFileEntry isDirectory ifTrue: [^nil].
	fileRef := d/f.
	^ fileRef exists ifTrue: [ fileRef readStream ] ifFalse: nil  
]

{ #category : #accessing }
FileDialogWindow >> preferredFileSystem [
	^ preferredFileSystem ifNil: [ FileSystem disk ]
]

{ #category : #accessing }
FileDialogWindow >> preferredFileSystem: aFileSystem [
	preferredFileSystem := aFileSystem
]

{ #category : #accessing }
FileDialogWindow >> previewMorph [
	"Answer the value of previewMorph"

	^ previewMorph
]

{ #category : #accessing }
FileDialogWindow >> previewMorph: anObject [
	"Set the value of previewMorph"

	previewMorph := anObject
]

{ #category : #accessing }
FileDialogWindow >> previewSize [
	"Answer the size of preview to use."

	self previewType == #text ifTrue: [^256@256].
	^128@128
]

{ #category : #accessing }
FileDialogWindow >> previewType [
	"Answer the value of previewType"

	^ previewType
]

{ #category : #accessing }
FileDialogWindow >> previewType: anObject [
	"Set the value of previewType.
	See #updatePreview for supported types."

	previewType := anObject
]

{ #category : #actions }
FileDialogWindow >> saveForcedSelectedFile [
	"Open a stream on the selected file if available and return it."

	|d f|
	d := self selectedFileDirectory ifNil: [^nil].
	f := self selectedFileName ifNil: [self fileNameText trimBoth].
	f ifEmpty: [^nil].
	^d forceNewFileNamed: f
]

{ #category : #actions }
FileDialogWindow >> saveSelectedFile [
	"Open a stream on the selected file if available and return it."

	|d f|
	
	d := self selectedFileDirectory ifNil: [^nil].
	f := self selectedFileName ifNil: [self fileNameText trimBoth].
	f ifEmpty: [ ^ nil ].
	
	f := d asFileReference / f.
	(f extension isEmpty and: [self defaultExtension notNil])
		 ifTrue: [ f := f, self defaultExtension].
	f exists 
		ifFalse: [ ^ f ].
		
	^(self
		proceed: ('The file {1} already exists.
Overwrite the file?' translated format: {f printString})
		title: 'Save File' translated)
			ifTrue: [ f delete ]
]

{ #category : #actions }
FileDialogWindow >> selectDirectory: aFileReference [
	"Expand and select the given directory."

	| pathSegments |
	pathSegments := aFileReference isRoot
		ifTrue: [ Array with: aFileReference pathString ]
		ifFalse: [ aFileReference pathSegments ].
	self changed: #(openPath) , pathSegments
]

{ #category : #actions }
FileDialogWindow >> selectFileFromPattern [
	"If there is a single file matching the pattern then select it.
	If none then try for a directory."

	| f matches subMatches |
	f := self files.
	matches := f select: [ :de | self fileNamePattern match: de name ].
	subMatches := matches reject: [ :de | de isDirectory ].
	subMatches size = 1
		ifTrue: [ ^ self selectedFileIndex: (f indexOf: subMatches first) ].
	subMatches := matches select: [ :de | de isDirectory ].
	subMatches size = 1
		ifTrue: [ ^ self selectedFileIndex: (f indexOf: subMatches first) ].
	self selectedFileIndex: 0
]

{ #category : #actions }
FileDialogWindow >> selectParentDirectory [
	"Switch to the parent directory."

	self hasParentDirectory ifFalse: [^self].
	self selectDirectory: self selectedFileDirectory asFileReference parent
]

{ #category : #actions }
FileDialogWindow >> selectPath: aPathOrFileReference [
	"Select the directory and set the file name text from the given path."

	| reference |
	reference := (self preferredFileSystem
		referenceTo: (self preferredFileSystem resolve: aPathOrFileReference)) asAbsolute.
	reference exists
		ifFalse: [ ^ self selectPath: reference parent ].
	reference isDirectory
		ifTrue: [ ^ self selectDirectory: reference ].

	"must be a file then"
	self selectDirectory: reference parent.
	self fileNameText: reference basename
]

{ #category : #actions }
FileDialogWindow >> selectedAnyFileDirectory [
	"If a directory is selected in the 'File' pane, return that. Otherwise, return the directory selected in 'Directory pane (i.e. the tree)"

	| selectedFile isDirectorySelected |
	selectedFile := self selectedFileEntry.
	isDirectorySelected := selectedFile isNil not and: [ selectedFile isDirectory ].
	^ isDirectorySelected
			ifTrue: [ selectedFile asFileReference ]
			ifFalse: [ self selectedFileDirectory ].
]

{ #category : #accessing }
FileDialogWindow >> selectedDirectory [
	"Answer the value of selectedDirectory"

	^ selectedDirectory
]

{ #category : #accessing }
FileDialogWindow >> selectedDirectory: anObject [
	selectedDirectory := anObject.
	self
		selectedFileIndex: 0;
		updateSelectedDirectory;
		updateFiles
]

{ #category : #actions }
FileDialogWindow >> selectedFileDirectory [
	"Answer the selected file directory in the tree part."

	^ (self selectedDirectory ifNil: [^nil]) item
]

{ #category : #actions }
FileDialogWindow >> selectedFileEntry [
	"Answer the selected file."

	self selectedFileIndex = 0 ifTrue: [^nil].
	^self files at: self selectedFileIndex ifAbsent: [nil]
]

{ #category : #accessing }
FileDialogWindow >> selectedFileIndex [
	"Answer the value of selectedFileIndex"

	^ selectedFileIndex
]

{ #category : #accessing }
FileDialogWindow >> selectedFileIndex: anObject [
	"Set the value of selectedFileIndex"

	selectedFileIndex := anObject.
	self updateSelectedFile
]

{ #category : #actions }
FileDialogWindow >> selectedFileName [

	^ self selectedFileEntry ifNotNil: [ :dir | dir basename ]
]

{ #category : #actions }
FileDialogWindow >> selectedPathName [
	"Answer the name of the selected path."

	selectedDirectory := self selectedFileDirectory ifNil: [^nil].
	^ self selectedFileName 
		ifNil: [ selectedDirectory fullName ]
		ifNotNil: [ :filename | (selectedDirectory / filename) fullName ].
]

{ #category : #accessing }
FileDialogWindow >> showDirectoriesInFileList [
	"Answer the value of showDirectoriesInFileList"

	^ showDirectoriesInFileList
]

{ #category : #accessing }
FileDialogWindow >> showDirectoriesInFileList: anObject [
	"Set the value of showDirectoriesInFileList"

	showDirectoriesInFileList := anObject.
	self updateFiles
]

{ #category : #actions }
FileDialogWindow >> updateDirectories [
	"Update the directory tree and reselect the current."

	|dir|
	dir := self selectedFileDirectory.
	self changed: #directories.
	self selectDirectory: dir.
	self updateFiles
]

{ #category : #update }
FileDialogWindow >> updateFiles [
	"Notify that the files have changed."

	self changed: #files
]

{ #category : #update }
FileDialogWindow >> updateImagePreview [
	"Update the image preview."

	|str form|
	(self isImageFile: self selectedFileName)
		ifFalse: [^self previewMorph
					image: nil
					size: self previewSize].
	str := self openSelectedFile.
	str ifNil: [^self].
	[[str binary.
	form := ImageReadWriter formFromStream: str]
		on: Error do: []]
		ensure: [str close].
	self previewMorph
		image: form
		size: self previewSize
]

{ #category : #actions }
FileDialogWindow >> updatePreview [
	"Update the preview."

	self previewType == #image ifTrue: [self updateImagePreview].
	self previewType == #text ifTrue: [self updateTextPreview]
]

{ #category : #update }
FileDialogWindow >> updateSelectedDirectory [
	"Notify that the selected directory has changed."

	self
		changed: #selectedDirectory;
		changed: #selectedFileDirectory;
		changed: #selectedPathName;
		changed: #hasParentDirectory
]

{ #category : #update }
FileDialogWindow >> updateSelectedFile [
	"Notify that the selected file has changed."

	self
		changed: #selectedFileIndex;
		changed: #selectedFileEntry;
		changed: #selectedFileName;
		changed: #selectedPathName;
		changed: #okEnabled;
		changed: #hasSelectedFileOrDirectory.
	self updatePreview
]

{ #category : #update }
FileDialogWindow >> updateTextPreview [
	"Update the text preview."

	|str text|
	str := self openSelectedFile.
	str ifNil: [^self].
	[[text := str next: 5000]
		on: Error do: []]
		ensure: [str close].
	text ifNil: [text := ''].
	self previewMorph
		setText: text
]

{ #category : #actions }
FileDialogWindow >> validExtensions: aList [
	"Set the filter for the files to be those with the given extensions."
	
	aList notEmpty
		ifTrue: [self defaultExtension: aList first].
	self fileSelectionBlock: [:de |
		de isDirectory
			ifTrue: [self showDirectoriesInFileList]
			ifFalse: [
				(self fileNamePattern match: de name) and: [
						aList includes: de extension asLowercase]]] 
]
