"
This is a font provider for true type fonts. You can use it to add TTF files to your image:

FreeTypeFontProvider current 
	updateFontsFromSystem;
	updateAvailableFontFamilies. 

You can add TTF fonts from a spetial dirrectory:
FreeTypeFontProvider current 
	updateFromDirectory: './fonts/' asFileReference done: Set new.

Then you can use font dialog:
	FreeTypeFontSelectorDialogWindow new open.

Or set for example set ballon or default font as following:
	StandardFonts balloonFont: 
	        (LogicalFont familyName: 'Arial'  pointSize: 10). 
	StandardFonts defaultFont: 
	        (LogicalFont familyName: 'Arial'  pointSize: 10).
"
Class {
	#name : #FreeTypeFontProvider,
	#superclass : #AbstractFontProvider,
	#instVars : [
		'fileInfos',
		'fileInfoCache',
		'tempFileInfos',
		'families',
		'tempFamilies',
		'fontInstallers'
	],
	#classInstVars : [
		'current'
	],
	#category : #'FreeType-FontManager'
}

{ #category : #accessing }
FreeTypeFontProvider class >> current [
	"
	current := nil.
	TimeProfileBrowser onBlock: [FreeTypeFontProvider current]
	"
	^current 
		ifNil:[
			current := self new.
			current updateFromSystem]
]

{ #category : #'class initialization' }
FreeTypeFontProvider class >> initialize [	 
	"Ensure that other classes have also been initialized by forcefully initializing them now.
	 It then does not matter which order they are initialized in during the package load"
	FT2Constants initialize.
	FreeTypeCache initialize.
	FreeTypeCacheConstants initialize.
	FreeTypeSettings initialize.
	
	current := nil.
	self current "this creates an instance of me, and updates from the system"
]

{ #category : #'extra fonts registration' }
FreeTypeFontProvider class >> registerFont: aClassWithFont [

	"Do nothing if freetype is disabled currently"
	
	FreeTypeSystemSettings loadFt2Library ifTrue: [ 
		aClassWithFont installFontsIn: self current
		 ]
]

{ #category : #accessing }
FreeTypeFontProvider class >> resetCurrent [
	"I reset all provider contents.
	 I do not free current because I do not want an update (see #current) each time I reset."
	current ifNil: [ ^ self ].
	self current initialize. "Reexecute initialization is dirty, but it makes the trick"
]

{ #category : #accessing }
FreeTypeFontProvider >> addFileInfo: aFreeTypeFileInfo [
	fileInfos add: aFreeTypeFileInfo
	
	
		
	
	
	
			
	
	
]

{ #category : #accessing }
FreeTypeFontProvider >> addFileInfo: aFreeTypeFileInfo index: i [
	fileInfos add: aFreeTypeFileInfo
	
	
		
	
	
	
			
	
	
]

{ #category : #accessing }
FreeTypeFontProvider >> addFirstFileInfo: aFreeTypeFileInfo index: i [
	fileInfos addFirst: aFreeTypeFileInfo
	
	
		
	
	
	
			
	
	
]

{ #category : #accessing }
FreeTypeFontProvider >> addFontInstaller: aFontInstaller [
	(fontInstallers includes: aFontInstaller) ifTrue: [ ^ self ].
	fontInstallers add: aFontInstaller
]

{ #category : #'font families' }
FreeTypeFontProvider >> buildFamilies [
	| familyNames |
	families := Dictionary new.
	familyNames := (fileInfos collect: [:each | each familyGroupName]) asSet asSortedCollection asArray.
	familyNames do:[:familyName | | family |
		family := self buildFamilyNamed: familyName.
		families at: familyName put: family ].
]

{ #category : #'font families' }
FreeTypeFontProvider >> buildFamilyNamed: aFamilyGroupName [
	| infos family|
	family := FreeTypeFontFamily new
		familyName: aFamilyGroupName;
		yourself. 
	infos := fileInfos select:[:each | each familyGroupName = aFamilyGroupName].
	family addMembersFromFileInfos: infos.
	family addSimulatedMembers.
	^family
		
			
			
		
]

{ #category : #accessing }
FreeTypeFontProvider >> cacheFileInfo: aFreeTypeFileInfo index: i [

	(fileInfoCache  at:  {aFreeTypeFileInfo fileSize. i} ifAbsentPut:[Set new])
		add:  aFreeTypeFileInfo
	
	
		
	
	
	
			
	
	
]

{ #category : #'error handling' }
FreeTypeFontProvider >> failedToOpen: face from: path index: i [
	"Transcript cr; show: 'Failed : ', path asString, '[', i asString,']'."
	"remove all cache entries for path with index >= i"
	
	
	
			
	
	
]

{ #category : #'error handling' }
FreeTypeFontProvider >> failedToOpen: face index: i [
	"Transcript cr; show: 'Failed : ', path asString, '[', i asString,']'."
	"remove all cache entries for path with index >= i"
	
	
	
			
	
	
]

{ #category : #'font families' }
FreeTypeFontProvider >> families [
	
	^tempFamilies ifNil:[families]
]

{ #category : #accessing }
FreeTypeFontProvider >> fileInfosByFamilyAndGroup [
	"Answer a Dictionary of Dictionaries of Sets.
	familyName->familyGroupName->Set(FreeTypeFileInfo)
	
	self current fileInfosByFamilyAndGroup
	"
	| answer |
	answer := Dictionary new.
	"file could be in fileInfos twice?
	need to only process once, need directory precedence?"
	fileInfos do:[:info | | group family |
		family := answer at: info familyName ifAbsentPut:[Dictionary new].
		group := family at: info familyGroupName ifAbsentPut: [OrderedCollection new].
		group 
			detect:[:each| 
				each bold = info bold
				and:[ each italic = info italic
				and:[ each fixedWidth = info fixedWidth
				and:[ each postscriptName = info postscriptName
				and:[ each styleName = info styleName ]]]]]
			ifNone:[ group add: info]].
	^ answer	
]

{ #category : #'font lookup' }
FreeTypeFontProvider >> fontFor: aLogicalFont familyName: familyName [
	| info answer simulatedSqueakEmphasis needsSimulatedBold needsSimulatedSlant
	squeakBoldEmphasis squeakItalicEmphasis |
	
	FT2Library current isAvailable ifFalse:[^nil].
	info:= self fontInfoFor: aLogicalFont familyName: familyName.
	info ifNil:[^nil].
	answer := FreeTypeFont forLogicalFont: aLogicalFont fileInfo: info.
	needsSimulatedBold := aLogicalFont isBoldOrBolder and:[(info isBolderThan: 500) not].
	needsSimulatedSlant := aLogicalFont isItalicOrOblique and: [info isItalicOrOblique not].
	(needsSimulatedBold or:[needsSimulatedSlant])
		ifTrue:[
			squeakBoldEmphasis := 1.
			squeakItalicEmphasis := 2.
			simulatedSqueakEmphasis := 0.
			needsSimulatedBold 
				ifTrue:[
					simulatedSqueakEmphasis := simulatedSqueakEmphasis + squeakBoldEmphasis].
			needsSimulatedSlant 
				ifTrue:[
					simulatedSqueakEmphasis := simulatedSqueakEmphasis + squeakItalicEmphasis].
			answer simulatedEmphasis: simulatedSqueakEmphasis].
	answer face validate.
	answer face isValid ifFalse:[^nil].  "we may get this if startup causes text display BEFORE receiver has been updated from the system"
	^answer
]

{ #category : #'font lookup' }
FreeTypeFontProvider >> fontInfoFor: aLogicalFont familyName: familyName [
	| family member |
	
	"use tempFileInfos if not nil, i.e. during an update" 
	"^self fontInfoFor: aLogicalFont in: (tempFileInfos ifNil:[fileInfos]) "
	family := self families at: familyName ifAbsent:[].
	family ifNil:[^nil].
	member := family 
		closestMemberWithStretchValue: aLogicalFont stretchValue 
		weightValue: aLogicalFont weightValue 
		slantValue: aLogicalFont slantValue.
	member ifNil:[^nil].
	^member fileInfo
]

{ #category : #'file paths' }
FreeTypeFontProvider >> getWindowsFontFolderPath [
	"Answer the windows font folder path.
	This is obtained through the Windows API if FFI is present,
	otherwise it is a guess !"

	| externalLibraryClass externalTypeClass fun buff |
	externalLibraryClass := Smalltalk globals at: #ExternalLibraryFunction ifAbsent: [  ].
	externalTypeClass := Smalltalk globals at: #ExternalType ifAbsent: [  ].
	(externalLibraryClass isNil or: [ externalTypeClass isNil ]) ifTrue: [ ^ self guessWindowsFontFolderPath ].
	fun := externalLibraryClass
		       name: 'SHGetFolderPathA'
		       module: 'shfolder.dll'
		       callType: 1
		       returnType: externalTypeClass long
		       argumentTypes: { 
				       externalTypeClass long.
				       externalTypeClass long.
				       externalTypeClass long.
				       externalTypeClass long.
				       externalTypeClass char asPointerType }.
	buff := ByteArray new: 1024.
	[ 
	fun
		invokeWith: 0
		with: 16r0014
		with: 0
		with: 0
		with: buff "CSIDL_FONTS" ]
		on: Error
		do: [ :e | "will get error if ffiplugin is missing" ^ self guessWindowsFontFolderPath ].
	^ (buff copyFrom: 1 to: (buff indexOf: 0) - 1) asString
]

{ #category : #'file paths' }
FreeTypeFontProvider >> getWindowsLocalPaths [
	
	"This values should be read from the repository in the key 
	HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\Fonts
	However, things happened and we don't have support of the registry in the base image.
	So this is the best alternative... or not...??  "

	^ {(FileLocator home / 'AppData' / 'Local' / 'Microsoft' / 'Windows' / 'Fonts').
	(FileLocator home / 'AppData' / 'Roaming' / 'Microsoft' / 'Windows' / 'Fonts')}
]

{ #category : #'file paths' }
FreeTypeFontProvider >> guessWindowsFontFolderPath [
	"Guess the location of the Windows font folder"
	| possibilities |

	possibilities := Set new.
	'cdefghijklmnopqrstuvwxyz' do:[:drive |
		#('windows\fonts' 'winnt\fonts') do:[:path | | d |
			(d := (FileLocator driveNamed: drive asSymbol) resolve: path) exists
				ifTrue:[possibilities add: d]]].
	possibilities := possibilities asSortedCollection: [:a :b | a entry creationTime >= b  entry creationTime].
	possibilities ifNotEmpty:[ ^ possibilities first fullName ].
	^nil
	
		 	
			
]

{ #category : #'file paths' }
FreeTypeFontProvider >> imageRelativeFontFolder [
  ^SmalltalkImage current imageDirectory asFileReference / 'Fonts'
]

{ #category : #initialization }
FreeTypeFontProvider >> initialize [
	super initialize.
	fileInfos := OrderedCollection  new: 100.
	fileInfoCache := Dictionary new: 100. "keyed by file size" 
	families := Dictionary new.
	fontInstallers := OrderedCollection new.
	
]

{ #category : #'loading and updating' }
FreeTypeFontProvider >> loadFromSystem [
	self updateFromSystem.
	
]

{ #category : #'file paths' }
FreeTypeFontProvider >> macOSXFolderDirectories [
	| localUserFonts |
	"Answer the Mac OS X font folder paths.
	This needs some FFI code, but for the time being, we guess these and omit the user fonts folder"
	
	"Adding some directories following the guidelines in https://support.apple.com/en-us/HT201722"
	
	localUserFonts := FileLocator home / 'Library' / 'Fonts'.
	
	^{localUserFonts} , #('/System/Library/Fonts' '/Network/Library/Fonts/' '/Library/Fonts')
		collect: [ :each| each asFileReference ]
		thenSelect: [ :each| each exists ].
]

{ #category : #'file paths' }
FreeTypeFontProvider >> platformAbsoluteDirectories [
	Smalltalk os isWindows
		ifTrue: [ ^ self winFontDirectories ].
	Smalltalk os isUnix
		ifTrue: [ ^ self unixFontDirectories ].
	Smalltalk os isMacOSX
		ifTrue: [ ^ self macOSXFolderDirectories ].
	^ {}
]

{ #category : #'font families' }
FreeTypeFontProvider >> platformImageRelativeDirectories [
	
	| directory |
	directory := self imageRelativeFontFolder.
	directory exists
		ifTrue: [ ^ { directory } ].
	^ #()
]

{ #category : #'file paths' }
FreeTypeFontProvider >> platformVMRelativeDirectories [
  | directory |
  directory := Smalltalk vm directory asFileReference / 'Fonts'.
  directory exists ifTrue: [ ^{directory} ].
  ^#()
]

{ #category : #'loading and updating' }
FreeTypeFontProvider >> prepareForRelease [

	"When releasing an image, we should only include the embedded fonts"

	self initialize.
	self updateEmbeddedFreeTypeFonts


]

{ #category : #'loading and updating' }
FreeTypeFontProvider >> prepareForUpdating [
	
	tempFileInfos := fileInfos. "tempFileInfos will be used during update"
	tempFamilies := families.   "tempFamilies will be used during update"
	fileInfos := OrderedCollection  new: 100.
]

{ #category : #removing }
FreeTypeFontProvider >> removeFontInstaller: anEmbeddedFreeTypeFontInstaller [ 
	fontInstallers remove: anEmbeddedFreeTypeFontInstaller ifAbsent: [ ]
]

{ #category : #'file paths' }
FreeTypeFontProvider >> unixFontDirectories [
	"Trying with some common directories in unix. The prefered version is to read the /etc/fonts/fonts.conf"

	| localUserFonts |
	localUserFonts := FileLocator home / '.fonts'.
	^ {localUserFonts} , #('/usr/share/fonts' '/usr/local/share/fonts') collect: [ :each | each asFileReference ] thenSelect: [ :each | each exists ]
]

{ #category : #'file paths' }
FreeTypeFontProvider >> unixUsualDirectories [
	"Trying with some common directories in unix. The prefered version is to read the /etc/fonts/fonts.conf"
	
	| localUserFonts |
	localUserFonts := FileLocator home / 'Library' / 'Fonts'.
	
	^ {localUserFonts} , #('/usr/share/fonts' '/usr/local/share/fonts') collect: [ :each | each asFileReference ] thenSelect: [ :each | each exists ]
]

{ #category : #'loading and updating' }
FreeTypeFontProvider >> updateAvailableFontFamilies [
	'Calculating available font families' displayProgressFrom: 0 to: 1 during:[ :bar |
		"self removeUnavailableTextStyles."
		"self addTextStylesWithPointSizes: #(8 10 12 15 24)."
		tempFileInfos := nil.
		self buildFamilies.
		tempFamilies := nil ].
]

{ #category : #'loading and updating' }
FreeTypeFontProvider >> updateEmbeddedFreeTypeFonts [
	"Ensure the provider is installed"	
	self addFontInstaller: EmbeddedFreeTypeFontInstaller current.
	"Now install embeded fonts"
	fontInstallers do: [ :each | each installAllFontsIn: self ].
	self buildFamilies
]

{ #category : #'loading and updating' }
FreeTypeFontProvider >> updateFileCacheInfo [
	fileInfoCache values
		do: [ :col | col copy do: [ :each | each absolutePath asFileReference ifAbsent: [ col remove: each ] ] ]
		displayingProgress: [ 'Updating cached file info' ]
]

{ #category : #'loading and updating' }
FreeTypeFontProvider >> updateFontsFromSystem [
	| done |
	"Add all the embedded file infos"
	FT2Library current isAvailable ifFalse: [ ^ self ].
	self updateEmbeddedFreeTypeFonts.
	done := Set new.	"visited directories are tracked in done, so that they are not processed twice"
	self platformImageRelativeDirectories
		do: [ :each | self updateFromDirectory: each done: done ]
		displayingProgress: 'Loading image relative font files'.
	self platformVMRelativeDirectories
		do: [ :each | self updateFromDirectory: each done: done ]
		displayingProgress: 'Loading vm relative font files'.
	self platformAbsoluteDirectories
		do: [ :each | self updateFromDirectory: each done: done ]
		displayingProgress: 'Loading platform font files'
]

{ #category : #'loading and updating' }
FreeTypeFontProvider >> updateFromDirectory: aDirectory done: aSet [
	"get info from fonts in aDirectory"
	
	(aSet includes: aDirectory) ifTrue: [ ^ self ].
	aSet add: aDirectory.
	aDirectory files 
		do: [ :each |
			"SUSE 10.2 has lots of files ending .gz that aren't fonts.
			We skip them to save time'"
			((each basename beginsWith: '.' ) or: [ each basename asLowercase endsWith:' .gz' ])
				ifFalse: [ self updateFromFile: each ]]
		displayingProgress: 'Loading fonts in ', aDirectory fullName.
		
	aDirectory directories do: [ :each |
		self updateFromDirectory: each done: aSet ].
]

{ #category : #'loading and updating' }
FreeTypeFontProvider >> updateFromFile: aFile [
	| i face numFaces cachedInfo info cachedNumFaces path |
	
	i:= 0.
	[(cachedInfo := self validCachedInfoFor: aFile index: i) notNil]
		whileTrue:[
			i = 0 ifTrue: [ cachedNumFaces := cachedInfo numFaces ].
			self addFileInfo: cachedInfo index: i.
			i := i + 1.].
		
	(cachedNumFaces notNil and:[ i >= cachedNumFaces ]) ifTrue:[ ^ self ].
	
	path := aFile fullName convertToWithConverter: UTF8TextConverter new .
	[face := FreeTypeFace basicNew filename: path; index:  i.
	["we use the primNewFaceFromFile:index: method because we want to do this as fast as possible and we don't need the face registered because it will be explicitly destroyed later"
	face newFaceFromFile: path index: i.
	face loadFields]
		on: FT2Error, PrimitiveFailed
		do: [:e | ^self failedToOpen: face from: path index: i ].
	(face height notNil  and:[face hasFamilyName and:[face hasStyleName and:[face isValid]]])
		ifFalse: [ ^self failedToOpen:face from: path index: i ]
		ifTrue: [
			numFaces ifNil: [numFaces := face numFaces].
			info :=FreeTypeFileInfo new
				absoluteOrRelativePath: aFile path isAbsolute;
				absolutePath: path; "used for quick lookup on same platform"
				locationType: #default;
				index: i;
				fileSize: aFile size;
				modificationTime: aFile modificationTime;
				familyName: face familyName;
				styleName: face styleName;
				postscriptName: face postscriptName;
				bold: face isBold;
				italic: face isItalic;
				fixedWidth: face isFixedWidth;
				numFaces: numFaces;
				extractAttributesFromNames;
				yourself.
			self addFileInfo: info index: i.
			self cacheFileInfo: info index: i.
			"Transcript show: 'from file : ', info asString."].
	i := i + 1.
	i < numFaces "note, we use < rather than <= , because i is zero based"] whileTrue:[].
	
	
		
	
	
	
			
	
	
]

{ #category : #'loading and updating' }
FreeTypeFontProvider >> updateFromSystem [
	self prepareForUpdating.
	'FreeType' displayProgressFrom: 0 to: 3 during: [ :mainBar | 
		self updateFileCacheInfo.
		mainBar current: 1.
		self updateFontsFromSystem.
		mainBar current: 2.
		self updateAvailableFontFamilies.
		mainBar current: 3 ].
	LogicalFont allInstances do: [ :each | "in case they have a bad one" each clearRealFont ]
]

{ #category : #'loading and updating' }
FreeTypeFontProvider >> validCachedInfoFor: aFile index: i [
	"answer info from cache if the file on the disk has the same size/timestamp as the cached info, otherwise answer nil"
	| cacheEntry fileSize modificationTime path |

	fileSize := aFile size.
	modificationTime :=  aFile modificationTime.
	path := aFile fullName.
	cacheEntry := (fileInfoCache at: {fileSize. i} ifAbsentPut: [ Set new ])
		detect: [ :each | 
			each modificationTime = modificationTime
			and: [ each absolutePath = path ]]
		ifNone:[].
	"cacheEntry ifNotNil:[Transcript cr; show: 'from cache : ', cacheEntry asString]."
	^ cacheEntry
]

{ #category : #'file paths' }
FreeTypeFontProvider >> winFontDirectories [
	| results |
	
	results := OrderedCollection new.
	
	self getWindowsFontFolderPath
		ifNotNil: [ :aString | | directory |
				directory := aString asFileReference.
				directory exists 
					ifTrue: [ results add: directory ]].
	
	self getWindowsLocalPaths
		do: [ :directory | 
				directory exists 
					ifTrue: [ results add: directory ]].
		
	^ results
]
