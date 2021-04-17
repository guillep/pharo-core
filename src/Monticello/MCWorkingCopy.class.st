"
MCWorkingCopy represents one version of a package in memory. It provides support for ancestry access, required packages and the repositories in which the package is managed.

Instance Variables:
	versionInfo	<MCAncestry>
	ancestry	<MCWorkingAncestry>
	counter	<Number>
	repositoryGroup	<MCRepositoryGroup>
	requiredPackages	<Collection>
"
Class {
	#name : #MCWorkingCopy,
	#superclass : #MCPackageManager,
	#instVars : [
		'ancestry',
		'counter',
		'repositoryGroup',
		'requiredPackages'
	],
	#category : #'Monticello-Versioning'
}

{ #category : #private }
MCWorkingCopy class >> ancestorsFromArray: anArray cache: cacheDictionary [
	"While using recursion is simpler, it runs a risk of stack overflow for packages with many ancestors,
	 so we use a local stack to pre-load the cache in reverse order. 
	 The original code remains on the last line, so the intermediate code 
	 does not change the external behavior. "

	| index stack |
	anArray ifNil: [^nil].
	stack := OrderedCollection withAll: anArray.
	index := 1.
	[ index <= stack size ] whileTrue: [
		| dict id |
		dict := stack at: index.
		id := (dict at: #id) asString.
		(cacheDictionary includesKey: id) ifFalse: [
			stack addAll: (dict at: #ancestors ifAbsent: [#()]).
		].
		index := index + 1.
	].
	stack reverseDo: [:each | 
		self infoFromDictionary: each cache: cacheDictionary.
	].
	^ anArray collect: [:dict | self infoFromDictionary: dict cache: cacheDictionary]
]

{ #category : #querying }
MCWorkingCopy class >> hasPackageNamed: aName [
	" self hasPackageNamed: 'ConfigurationOfFuel' "

	^ MCWorkingCopy allManagers
		anySatisfy: [ :each | each packageName = aName ]
]

{ #category : #private }
MCWorkingCopy class >> infoFromDictionary: aDictionary cache: cache [
	| id |
	id := (aDictionary at: #id) asString.
	^ cache at: id ifAbsentPut:
		[MCVersionInfo
			name: (aDictionary at: #name ifAbsent: [''])
			id: (UUID fromString: id)
			message: (aDictionary at: #message ifAbsent: [''])
			date: ([Date fromString: (aDictionary at: #date)] onErrorDo: [nil])
			time: ([Time fromString: (aDictionary at: #time)] onErrorDo: [nil])
			author: (aDictionary at: #author ifAbsent: [''])
			ancestors: (self ancestorsFromArray: (aDictionary at: #ancestors ifAbsent: []) cache: cache)
			stepChildren: (self ancestorsFromArray: (aDictionary at: #stepChildren ifAbsent: []) cache: cache)]
]

{ #category : #initialize }
MCWorkingCopy class >> initialize [
	"self initialize"
	registry ifNotNil: [ registry rehash ].
	self registerForNotifications.
]

{ #category : #'event registration' }
MCWorkingCopy class >> registerForNotifications [
	"self registerForNotifications"
	<systemEventRegistration>
	
	MCPackageManager announcer: nil.
	SystemAnnouncer uniqueInstance unsubscribe: self.
	self registerInterestOnSystemChangesOnAnnouncer: SystemAnnouncer uniqueInstance.
]

{ #category : #operations }
MCWorkingCopy >> adopt: aVersion [
	ancestry addAncestor: aVersion info.
	self changed.
]

{ #category : #accessing }
MCWorkingCopy >> allAncestors [
	^ self versionInfo 
		ifNotNil: [ :versionInfo | versionInfo allAncestors ]
		ifNil: [ #() ]
]

{ #category : #accessing }
MCWorkingCopy >> ancestors [
	^ ancestry ancestors
]

{ #category : #accessing }
MCWorkingCopy >> ancestry [
	^ ancestry
]

{ #category : #operations }
MCWorkingCopy >> backportChangesTo: aVersionInfo [
	| baseVersion fullPatch currentVersionInfo currentVersion newSnapshot newAncestry |
	currentVersionInfo := self currentVersionInfo.
	baseVersion := self repositoryGroup versionWithInfo: aVersionInfo.
	currentVersion := self repositoryGroup versionWithInfo: currentVersionInfo.
	fullPatch := currentVersion snapshot patchRelativeToBase: baseVersion snapshot.
	(MCChangeSelectionRequest new
		patch: fullPatch;
		label: 'Changes to Backport';
		signal ) ifNotNil:
		[:partialPatch |
		newSnapshot := MCPatcher apply: partialPatch to: baseVersion snapshot.
		newAncestry := MCWorkingAncestry new
							addAncestor: aVersionInfo;
							addStepChild: currentVersionInfo;
							yourself.
		MCPackageLoader updatePackage: package withSnapshot: newSnapshot.
		ancestry := newAncestry.
		self modified: false; modified: true]
]

{ #category : #operations }
MCWorkingCopy >> changesRelativeToRepository: aRepository [
	^ self completeSnapshot patchRelativeToBase: (self closestAncestorSnapshotIn: aRepository).
]

{ #category : #operations }
MCWorkingCopy >> clearRequiredPackages [
	requiredPackages := nil
]

{ #category : #accessing }
MCWorkingCopy >> closestAncestorSnapshotIn: aRepository [
	
	"Returns a complete Snapshot including all required packages by recurisveliy walking all required package and trying to find the closes ancestor in the given repository"
	
	| definitions ancestorVersion|
	
	ancestorVersion := aRepository closestAncestorVersionFor: ancestry ifNone: [].
	
	definitions := ancestorVersion 
						ifNil: [ OrderedCollection new ] 
						ifNotNil: [ ancestorVersion snapshot definitions ].
	
	definitions addAll: (self loadRemoteDependenciesIn: aRepository).
	
	^ MCSnapshot fromDefinitions: definitions
]

{ #category : #operations }
MCWorkingCopy >> collectDependenciesWithMessage: messageString in: aRepository [
	
	^ self requiredPackages collect: [:aPackage | 
			MCVersionDependency
				package: aPackage
				info:  (aPackage workingCopy 
					currentVersionInfoWithMessage: messageString 
					in: aRepository) ]
	
]

{ #category : #accessing }
MCWorkingCopy >> completeSnapshot [
	"return a complete snapshot of the loaded sources in this working copy. 
	unlike snapshot this includes also the snapshots of all packages"
	
	| definitions |
	
	definitions := OrderedCollection withAll: package snapshot definitions.
	
	self requiredPackages 
		do: [ :aPackage| definitions addAll: aPackage workingCopy completeSnapshot definitions ]
		displayingProgress: [ :item| 'Loading dependencies from: ', item name ].
	
	^ MCSnapshot fromDefinitions: definitions
]

{ #category : #accessing }
MCWorkingCopy >> currentVersionInfo [
	^ (self needsSaving or: [ancestry ancestors isEmpty])
		ifTrue: [ (self newVersionIn: self repositoryGroup) 
						ifNotNil: [ :version | version info ] ]
		ifFalse: [ancestry ancestors first]
]

{ #category : #accessing }
MCWorkingCopy >> currentVersionInfoWithMessage: aMessageString in: aRepository [
	^ (self needsSaving or: [ancestry ancestors isEmpty])
		ifTrue: [ (self newVersionWithMessage: aMessageString in: aRepository) info ]
		ifFalse: [ancestry ancestors first]
]

{ #category : #accessing }
MCWorkingCopy >> description [
	^ self packageNameWithStar, ' (', (ancestry ancestorStringWithout: self packageName), ')'
]

{ #category : #printing }
MCWorkingCopy >> displayStringOn: stream [
	ancestry ancestors isEmpty 
		ifTrue: [ 
			super displayStringOn: stream. stream nextPutAll: ' (unsaved)' ]
		ifFalse: [ 
			ancestry ancestors first displayStringOn: stream.
			self needsSaving ifTrue: [ stream nextPutAll: ' (modified)' ] ]
		
]

{ #category : #private }
MCWorkingCopy >> findSnapshotWithVersionInfo: aVersionInfo [
    "when an ancestor inside the ancestor chain is not found, does not pass nil instead.
    With this change we can now browse history and delta between them without having to 
    have the complete history"
    "instead of asking for the user to add a new repository, or copy the the missing package we simply
    return an empty Snapshot by returning nil"

    ^ aVersionInfo
        ifNil: [MCSnapshot empty]
        ifNotNil: [(self repositoryGroup versionWithInfo: aVersionInfo ifNone: [nil])
            ifNil: [MCSnapshot empty]
            ifNotNil: [:aVersion | aVersion snapshot]]
]

{ #category : #initialization }
MCWorkingCopy >> initialize [
	super initialize.
	ancestry := MCWorkingAncestry new
]

{ #category : #accessing }
MCWorkingCopy >> loadRemoteDependenciesIn: aRepository [
	"load the remote dependencies of all packages in parallel"
	| dependencies |
	dependencies := self 
		requiredPackagesParallelCollect: [ :aPackage|
			(aPackage workingCopy closestAncestorSnapshotIn: aRepository) definitions.] 
		withMessage: 'Loading remote dependencies...'.
	^ dependencies flattened

]

{ #category : #operations }
MCWorkingCopy >> loaded: aVersion [
	ancestry := MCWorkingAncestry new addAncestor: aVersion info.
	requiredPackages := OrderedCollection withAll: (aVersion dependencies collect: [:ea | ea package]).
	self modified: false.
	self changed
]

{ #category : #operations }
MCWorkingCopy >> merge: targetVersion [
	| ancestorInfo merger ancestorSnapshot packageSnapshot |
	targetVersion dependencies do: [:ea | ea resolve merge].
	ancestorInfo := targetVersion info commonAncestorWith: ancestry.
	
	ancestorInfo = targetVersion info ifTrue: [^ MCNoChangesException signal].
	
	packageSnapshot := package snapshot.
	ancestorSnapshot := ancestorInfo
							ifNotNil: [(self findSnapshotWithVersionInfo: ancestorInfo)]
							ifNil: [self notifyNoCommonAncestorWith: targetVersion.  MCSnapshot empty].
	
	(ancestry ancestors size = 1
		and: [ancestry ancestors first = ancestorInfo
				and: [(packageSnapshot patchRelativeToBase: ancestorSnapshot) isEmpty]])
				ifTrue: [^ targetVersion load].
	
	merger := MCThreeWayMerger 
				base: packageSnapshot
				target: targetVersion snapshot
				ancestor: ancestorSnapshot.
	((MCMergeResolutionRequest new merger: merger)
		signal: 'Merging ', targetVersion info name) = true 
			ifTrue:[
				merger loadWithNameLike: targetVersion info name.
				ancestry addAncestor: targetVersion info ].
	self changed
]

{ #category : #operations }
MCWorkingCopy >> merged: aVersion [
	ancestry addAncestor: aVersion info.
	aVersion dependencies do: [:ea | self requirePackage: ea package].
	self changed
]

{ #category : #accessing }
MCWorkingCopy >> needsSaving [
	^ self modified or: [self requiredPackages anySatisfy: [:ea | ea workingCopy needsSaving]]
]

{ #category : #operations }
MCWorkingCopy >> newVersionIn: aRepository [
	^ (self requestVersionNameAndMessageWithSuggestion: (self uniqueVersionNameIn: aRepository)) 
		ifNotNil: [:pair |
			self 
				newVersionWithName: pair first trimBoth 
				message: pair last 
				in: aRepository ].

]

{ #category : #operations }
MCWorkingCopy >> newVersionWithMessage: aMessageString in: aRepository [
	^ self 
		newVersionWithName: (self uniqueVersionNameIn: aRepository)  
		message: aMessageString
		in: aRepository.

	"^ (self requestVersionNameAndMessageWithSuggestion: self uniqueVersionName) ifNotNil:
		[:pair |
		self newVersionWithName: pair first message: aMessageString].
	"
]

{ #category : #operations }
MCWorkingCopy >> newVersionWithName: nameString message: messageString in: aRepository [
	
	| info deps |
	info := ancestry infoWithName: nameString message: messageString.
	ancestry := MCWorkingAncestry new addAncestor: info.
	self modified: true; modified: false.
	
	deps := self collectDependenciesWithMessage: messageString in: aRepository.
	
	(self repositoryGroup includes: aRepository) 
		ifFalse: [ self repositoryGroup addRepository: aRepository ].

	^ MCVersion
		package: package
		info: info
		snapshot: package snapshot
		dependencies: deps
]

{ #category : #accessing }
MCWorkingCopy >> nextAncestors [
	^ self versionInfo 
		ifNotNil: [ :versionInfo | versionInfo ancestors ]
		ifNil: [ #() ]
]

{ #category : #private }
MCWorkingCopy >> nextVersionName [
	| branch oldName base author |
	branch := ''.
	ancestry ancestors isEmpty
		ifTrue: [counter ifNil: [counter := 0]. base := package name]
		ifFalse:
			[oldName := ancestry ancestors first name.
			oldName last isDigit
				ifFalse: [base := oldName]
				ifTrue: [
					base := oldName copyUpToLast: $-.
					branch := ((oldName copyAfterLast: $-) copyUpToLast: $.) copyAfter: $. ].
			counter ifNil: [
				counter := (ancestry ancestors collect: [:each |
					each name last isDigit
						ifFalse: [0]
						ifTrue: [(each name copyAfterLast: $.) extractNumber]]) max]].

	branch isEmpty ifFalse: [branch := '.',branch].
	counter := counter + 1.
	author := Author fullName collect: [ :each | each isAlphaNumeric ifTrue: [ each ] ifFalse: [ $_ ] ].
	^ base , '-' , author , branch , '.' , counter asString
]

{ #category : #operations }
MCWorkingCopy >> notifyNoCommonAncestorWith: aVersion [
	self notify:
'Could not find a common ancestor between (',
aVersion info name,
') and (',
ancestry ancestorString, ').
Proceeding with this merge may cause spurious conflicts.'
]

{ #category : #private }
MCWorkingCopy >> possiblyNewerVersions [

	^Array streamContents: [:strm |
		self repositoryGroup repositories do: [:repo |
			strm nextPutAll: (self possiblyNewerVersionsIn: repo)]]
]

{ #category : #private }
MCWorkingCopy >> possiblyNewerVersionsIn: aRepository [

	^aRepository possiblyNewerVersionsOfAnyOf: self ancestors
]

{ #category : #printing }
MCWorkingCopy >> printOn: aStream [

	super printOn: aStream.
	package name ifNotNil: [ aStream 
										nextPutAll: '(' ; 
										print: package name ;
 										nextPut: $)]
]

{ #category : #accessing }
MCWorkingCopy >> removeRequiredPackage: aPackage [

	requiredPackages remove: aPackage ifAbsent: []

]

{ #category : #repositories }
MCWorkingCopy >> repositoryGroup [
	^ repositoryGroup ifNil: [repositoryGroup := MCRepositoryGroup new]
]

{ #category : #repositories }
MCWorkingCopy >> repositoryGroup: aRepositoryGroup [
	repositoryGroup := aRepositoryGroup
]

{ #category : #private }
MCWorkingCopy >> requestVersionNameAndMessageWithSuggestion: aString [
	^ (MCVersionNameAndMessageRequest new suggestedName: aString) signal
]

{ #category : #accessing }
MCWorkingCopy >> requirePackage: aPackage [
	(self requiredPackages includes: aPackage) ifFalse: [requiredPackages add: aPackage]
]

{ #category : #accessing }
MCWorkingCopy >> requiredPackages [
	^ requiredPackages ifNil: [requiredPackages := OrderedCollection new]
]

{ #category : #accessing }
MCWorkingCopy >> requiredPackagesParallelCollect: aBlock withMessage: aMessage [
	"load the remote dependencies of all packages in parallel"

	| packages progress results maxConcurrentConnections connectionThrottle addSemaphore |
	
	results := OrderedCollection new.
	addSemaphore := Semaphore forMutualExclusion.
	connectionThrottle := Semaphore new.
	progress := 0.
	maxConcurrentConnections := 5.
	maxConcurrentConnections timesRepeat: [ connectionThrottle signal ]. "make room for maxConcurrentConnections"
	packages := self requiredPackages.
	
	aMessage displayProgressFrom: 0 to: packages size during: [ :bar|
		packages do: [ :aPackage| 
			connectionThrottle wait. "no more than maxConcurrentConnections"
			[|result|
				[
					result := aBlock value: aPackage.
					addSemaphore critical: [ "update the non-threadsafe collection"
						results add: result.
						bar current: (progress := progress + 1)]
				] ensure: [ connectionThrottle signal. "free a connection" ].
			] fork ]].
	
	maxConcurrentConnections timesRepeat: [ connectionThrottle wait ]. "wait for the last connection to finish"
	
	^ results
]

{ #category : #accessing }
MCWorkingCopy >> snapshot [
	^ self package snapshot
]

{ #category : #accessing }
MCWorkingCopy >> theCachedRepository [

	^ MCCacheRepository uniqueInstance.
]

{ #category : #private }
MCWorkingCopy >> uniqueVersionName [
	|versionName|
	counter := nil.
	'Creating unique version number' 
		displayProgressFrom: 0 
		to: 1 
		during: [ :arg|
			[versionName := self nextVersionName.
			self repositoryGroup includesVersionNamed: versionName] whileTrue ].
	^ versionName
]

{ #category : #private }
MCWorkingCopy >> uniqueVersionNameIn: aRepository [
	|versionName|
	counter := nil.
	'Creating unique version number' 
		displayProgressFrom: 0 
		to: 1 
		during: [ :arg|
			[versionName := self nextVersionName.
			aRepository includesVersionNamed: versionName] whileTrue ].
	^ versionName
]

{ #category : #operations }
MCWorkingCopy >> unload [
	"Unloads mcpackage, rpackage, classes and method extensions from this working copy"
	| postUnloadAction |
	
	postUnloadAction := [].
	self package correspondingRPackage ifNotNil: [ :anRPackage |
		anRPackage packageManifestOrNil ifNotNil: [ :manifest |
			postUnloadAction := manifest postUnloadAction.
			manifest preUnload ]].
	MCPackageLoader unloadPackage: self package.		
	package packageSet unregister.
	self unregister.
	postUnloadAction value.
	

]

{ #category : #accessing }
MCWorkingCopy >> versionInfo [
	^ self ancestors 
		ifNotEmpty: [ :list | list first ] 
		ifEmpty: [ nil ]
]

{ #category : #accessing }
MCWorkingCopy >> versionInfo: aVersionInfo [
	ancestry := MCWorkingAncestry new addAncestor: aVersionInfo
]

{ #category : #private }
MCWorkingCopy >> versionSeparator [
	^ $_
]
