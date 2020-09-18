Class {
	#name : #PBBootstrap,
	#superclass : #Object,
	#instVars : [
		'architecture',
		'imageReference',
		'buildNumber',
		'originRepository',
		'ringEnvironment',
		'versionInfo'
	],
	#category : 'Pharo30Bootstrap'
}

{ #category : #'instance creation' }
PBBootstrap class >> for32Bits [

	^ self forArchitecture: '32'
]

{ #category : #'instance creation' }
PBBootstrap class >> for64Bits [

	^ self forArchitecture: '64'
]

{ #category : #'instance creation' }
PBBootstrap class >> forArchitecture: architecture [

	^ super new
		architecture: architecture;
		yourself
]

{ #category : #'instance creation' }
PBBootstrap class >> fromCommandLine [
	| options architecture buildNumber versionInfo |
	options := CommandLineArguments new.
	architecture := options optionAt: 'ARCH' ifAbsent: [ '32' ].
	buildNumber := options optionAt: 'BUILD_NUMBER'
		ifPresent: [ :read | Number readFrom: read ifFail: [ -1 ] ]
		ifAbsent: [ -1 ].
	versionInfo := options optionAt: 'VERSION_INFO' ifAbsent: [ self error: 'Must provide VERSION_INFO in the form of a git describe --long' ].

        Transcript show: '    [+] Bootstrapping for a ' , architecture , '-bit architecture'; cr.
        Transcript show: '    [+] Build number: ' , buildNumber; cr.
        Transcript show: '    [+] VersionInfo: ' , versionInfo; cr.

	versionInfo := (PBVersionInfo fromLongGitDescribe: versionInfo)
		buildNumber: buildNumber;
		yourself.

	^ super new
		architecture: architecture;
		versionInfo: versionInfo;
		imageName: 'bootstrap.image';
		yourself
]

{ #category : #'instance creation' }
PBBootstrap class >> new [

	self error: 'Please use one of the factory methods #for32Bits or #for64Bits'
]

{ #category : #'instance creation' }
PBBootstrap class >> repositoryLocation [
	"Returns the location of the repository that we want to bootstrap, which is usually the working directory. Can be overridden if BOOTSTRAP_REPOSITORY is specified"
	^ (Smalltalk os environment
		at: 'BOOTSTRAP_REPOSITORY'
		ifAbsent: [ '.' ]) asFileReference
]

{ #category : #'package-names' }
PBBootstrap >> allPackagesForHermes [

	^ #BaselineOfPharoBootstrap asClass allPackageNames , #BaselineOfTraits asClass allPackageNames
]

{ #category : #accessing }
PBBootstrap >> architecture: aString [

	architecture := aString
]

{ #category : #bootstrapping }
PBBootstrap >> bootstrap [

	PBStepStartedSignal log: 'Starting Process.'.

        Transcript show: '    [+] Preparing bootstrap'; cr.
	self prepareBootstrap.

        Transcript show: '    [+] Creating image on which bootstrapping will take place'; cr.
	[ self createImage ] on: AssertionFailure do: [ :e | e resume ].

        Transcript show: '    [+] Initializing image for bootstrapping'; cr.
	self initializeImage.

	PBStepFinishedSignal log: 'Process ended.'

]

{ #category : #accessing }
PBBootstrap >> bootstrapCacheDirectory [

	^ (Smalltalk os environment at: 'BOOTSTRAP_CACHE' ifAbsent: ['bootstrap-cache']) asFileReference ensureCreateDirectory
]

{ #category : #accessing }
PBBootstrap >> buildNumber [

	^ buildNumber
]

{ #category : #accessing }
PBBootstrap >> buildNumber: aBuildNumber [

	buildNumber := aBuildNumber
]

{ #category : #bootstrapping }
PBBootstrap >> createImage [

	| builder |

	builder := PBImageBuilderSpur50 forArchitecture: architecture.
	builder versionInfo: versionInfo.
	builder imageFileReference: imageReference.
	builder systemDefinition: ringEnvironment.
	builder espellBackend instanceVariableMapping: (PBInstanceVariableMapping onEnvironment: ringEnvironment ).
		
	builder bootstrap
]

{ #category : #'pre-requisites' }
PBBootstrap >> ensureBaselineOfPharoBootstrap [
	(self originRepository versionWithInfo: (self originRepository versionInfoFromVersionNamed: 'Metacello-PharoExtensions')) load.
	(self originRepository versionWithInfo: (self originRepository versionInfoFromVersionNamed: 'BaselineOfPharoBootstrap')) load.
	(self originRepository versionWithInfo: (self originRepository versionInfoFromVersionNamed: 'BaselineOfTraits')) load.
	(self originRepository versionWithInfo: (self originRepository versionInfoFromVersionNamed: 'BaselineOfMetacello')) load.	
]

{ #category : #preparation }
PBBootstrap >> exportAllPackagesIntoMcz [

	self mczCache directory ensureDeleteAll; ensureCreateDirectory.
	self packagesToExportAsMCZ do: [ :packageName |
		self exportIntoMcz: packageName ].
]

{ #category : #preparation }
PBBootstrap >> exportIntoMcz: aPackageName [

	self mczCache storeVersion: (self originRepository loadVersionFromFileNamed: aPackageName).
]

{ #category : #preparation }
PBBootstrap >> exportKernelPackageNames [
	"Export list of kernel package names for RPackage initialization to a file"
		
	self exportPackageNamesFor: self kernelPackageNames to: self bootstrapCacheDirectory / 'packagesKernel.txt'.
	
	
]

{ #category : #preparation }
PBBootstrap >> exportKernelProtocols [
	"This method exports all protocols of the methots in the kernel in a single text file to be easily readed and imported from the 'in-midst of initialization' image."
		
	self exportProtocolsFor: self kernelPackageNames to: self bootstrapCacheDirectory / 'protocolsKernel.txt'.
	
	
]

{ #category : #preparation }
PBBootstrap >> exportMonticelloInStFile [

	self
		exportPackages: self monticelloPackageNames
		usingInitializeScript: '
		ChangeSet initialize.
		
		ZipConstants initialize.
		ZipFileConstants initialize.
		ZipWriteStream initialize.
		GZipConstants initialize.
		InflateStream initialize.
		FastInflateStream initialize.
		
		MCCacheRepository initialize.
		MCPackageManager initialize.
		MCLazyVersionInfo initialize.
		MCMethodDefinition initialize.
		MCDataStream initialize.
		MCWorkingCopy initialize.'
		intoFile: 'Monticello.st'

]

{ #category : #exporting }
PBBootstrap >> exportPackageNamesFor: packageNames to: aTextFile [

	"export list of packages for the RPackage initialization. Eech package on standalone line"
		
	aTextFile ensureDelete.
	aTextFile writeStreamDo: [:stream | 
		packageNames do: [ :each | stream nextPutAll: each; cr ]].
]

{ #category : #exporting }
PBBootstrap >> exportPackages: packageList intoFile: aFileName [

	self
		exportPackages: packageList
		usingInitializeScript: ''
		intoFile: aFileName
]

{ #category : #exporting }
PBBootstrap >> exportPackages: packageList usingInitializeScript: aScriptString intoFile: aFileName [

	self
		exportPackages: packageList
		withBlacklistedClasses: #()
		withBlacklistedMethods: #() 
		usingInitializeScript: aScriptString
		intoFile: aFileName
]

{ #category : #exporting }
PBBootstrap >> exportPackages: packageList withBlacklistedClasses: blacklistedClasses withBlacklistedMethods: methods usingInitializeScript: aString intoFile: aFileName [

	| mcst | 	
	mcst := (self bootstrapCacheDirectory / 'st-cache' / aFileName) asFileReference.
	mcst ensureDelete.
	mcst parent ensureCreateDirectory.
	mcst writeStreamDo: [ :stream | | writer version |
		writer := MCStWriter on: stream.
		writer writeInitializers: false.
		
		packageList do: [ :packageName |
			| definitions |
			version := (self originRepository loadVersionFromFileNamed: packageName).
			definitions := version snapshot definitions.
			definitions := definitions reject: [:def | blacklistedClasses includes: def className ].
			definitions := definitions reject: [:def | def isMethodDefinition and: [methods includes: def selector] ].
			writer writeDefinitions: definitions ].
		"Write initialization instructions"
		stream nextPutAll: aString.
	].
]

{ #category : #preparation }
PBBootstrap >> exportProtocolsFor: packageNames to: protocolsFile [

	"This methods takes the packages from the (filetree) origin repository, reads all methods in these packages and export the their protocols in a single text file with the following format:
		[className]\tab[class is meta?]\tab[selector]\tab[protocol]."
		
	| originRepository |
	originRepository := self originRepository.
	protocolsFile ensureDelete.
	protocolsFile writeStreamDo: [:stream | | versions |
		versions := originRepository directory directories sorted.
		versions
			select: [ :file | packageNames includes: file basenameWithoutExtension ]
			thenDo: [:file | | version |
		    version := originRepository versionWithInfo: (originRepository versionInfoFromVersionNamed: file basenameWithoutExtension).
		    (version snapshot definitions select: #isMethodDefinition) do: [:def |
		      stream nextPutAll: def className asString; tab.
		      stream nextPutAll: def classIsMeta asString; tab.
		      stream nextPutAll: def selector asString; tab.
		      stream nextPutAll: def category asString; cr ]]]
]

{ #category : #preparation }
PBBootstrap >> generateHermesFiles [
	| oldPackage hePackage writer |
	self hermesPackageNames
		do: [ :packageName | 
			oldPackage := ringEnvironment ask packageNamed: packageName.
			hePackage := HERing2ToHermesBuilder new visitPackage: oldPackage.
			writer := HEBinaryReaderWriter new
				stream: (File openForWriteFileNamed: (self bootstrapCacheDirectory / packageName , 'hermes') fullName);
				yourself.
			hePackage writeInto: writer.
			writer flush.
			writer close]
]

{ #category : #'package-names' }
PBBootstrap >> hermesPackageNames [
	^ #BaselineOfPharoBootstrap asClass packagesToExportWithHermes , #BaselineOfTraits asClass allPackageNames
]

{ #category : #accessing }
PBBootstrap >> imageName: aString [ 
	
	imageReference := (self bootstrapCacheDirectory / aString) asFileReference
]

{ #category : #initialization }
PBBootstrap >> initialize [
	"Initialize the logging"

	(CustomStringStreamBeacon with: FileStream stdout)
		startFor: PBStepStartedSignal , PBStepFinishedSignal
]

{ #category : #initialization }
PBBootstrap >> initializeImage [
	
]

{ #category : #'package-names' }
PBBootstrap >> kernelPackageNames [

	self ensureBaselineOfPharoBootstrap.
	^ #BaselineOfPharoBootstrap asClass kernelPackageNames
]

{ #category : #accessing }
PBBootstrap >> mczCache [
	
	^ MCDirectoryRepository new directory: (self bootstrapCacheDirectory / 'pharo-local' / 'package-cache') ensureCreateDirectory
]

{ #category : #'package-names' }
PBBootstrap >> monticelloNetworkPackageNames [

	^ #('Network-Kernel'
		 'Network-MIME'
		 'Network-Protocols'

		 'MonticelloRemoteRepositories'

		 'Zinc-HTTP'
		 'Zinc-FileSystem'
		 'Zodiac-Core')
]

{ #category : #'package-names' }
PBBootstrap >> monticelloPackageNames [

	^ #('System-Model' 'Ring-OldChunkImporter' 'Zinc-Resource-Meta-Core' 'System-Changes' 'Ring-Definitions-Core' 'Ring-Definitions-Containers' 'Compression' 'Monticello' 'Ring-Definitions-Monticello' )
]

{ #category : #accessing }
PBBootstrap >> originRepository [
	| repositoryReference |
	repositoryReference := self repositoryLocation / 'src'.

	^ originRepository
		ifNil: [ originRepository := TonelRepository new
				directory: repositoryReference;
				yourself]
]

{ #category : #'package-names' }
PBBootstrap >> packagesToExportAsMCZ [

	^ #(BaselineOfMetacello) , (#BaselineOfMetacello asClass allPackageNames)  , self monticelloPackageNames , self hermesPackageNames, self kernelPackageNames , self monticelloNetworkPackageNames
]

{ #category : #preparation }
PBBootstrap >> prepareBootstrap [
	
	self
		exportKernelProtocols;
		exportKernelPackageNames;
		exportAllPackagesIntoMcz;
		exportMonticelloInStFile;
		
		prepareEnvironmentForHermes;
		generateHermesFiles;
		prepareEnvironmentForExport.
]

{ #category : #preparation }
PBBootstrap >> prepareEnvironmentForExport [
	| allPackages |

	allPackages := ringEnvironment packages collect: #name.

	(allPackages reject: [ :x | #BaselineOfPharoBootstrap asClass kernelPackageNames includes: x ])
		do: [ :x | 
			| p |
			p := ringEnvironment ask packageNamed: x.
			p extensionMethods do: [ :e | e methodClass removeLocalMethod: e ].
			p definedBehaviors
				do: [ :e | 
					ringEnvironment removeBehavior: e.
					ringEnvironment removeBehavior: e classSide
					].
			ringEnvironment removePackage: p].

	ringEnvironment cleanGlobalVariables.
	ringEnvironment addGlobalsNamed: #(#Smalltalk #SourceFiles #Transcript #Undeclared #Display #TextConstants  #Sensor #Processor #SystemOrganization).
	ringEnvironment clean

]

{ #category : #preparation }
PBBootstrap >> prepareEnvironmentForHermes [
	ringEnvironment := self originRepository asRing2EnvironmentWith: self allPackagesForHermes.
	ringEnvironment fixProtoObjectClassSuperclass.
	ringEnvironment addGlobalsNamed: #(Smalltalk Transcript FileStream MacRomanTextConverter ChangeSet Character SourceFiles Processor Display Sensor UTF8TextConverter SystemOrganization Undeclared TextConstants).
	ringEnvironment clean
]

{ #category : #accessing }
PBBootstrap >> repositoryLocation [

	^ self class repositoryLocation
]

{ #category : #'package-names' }
PBBootstrap >> sUnitPackageNames [

	self ensureBaselineOfPharoBootstrap.
	^ #BaselineOfPharoBootstrap asClass sUnitPackageNames

]

{ #category : #accessing }
PBBootstrap >> versionInfo [
	^ versionInfo
]

{ #category : #accessing }
PBBootstrap >> versionInfo: anObject [
	versionInfo := anObject
]
