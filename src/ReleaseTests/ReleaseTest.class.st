"
I contain tests that validate the integrity of the system.
"
Class {
	#name : #ReleaseTest,
	#superclass : #AbstractEnvironmentTestCase,
	#category : #'ReleaseTests-Release'
}

{ #category : #accessing }
ReleaseTest class >> actualProcesses [
	^ Process allSubInstances reject: [ :each | each isTerminated ]
]

{ #category : #accessing }
ReleaseTest class >> defaultTimeLimit [

	^ 1 minute
]

{ #category : #accessing }
ReleaseTest >> actualProcesses [
	^ self class actualProcesses
]

{ #category : #helpers }
ReleaseTest >> assertValidLintRule: aLintRule [
	self assertValidLintRule: aLintRule withExceptions: {}
]

{ #category : #helpers }
ReleaseTest >> assertValidLintRule: aLintRule withExceptions: someNames [
	| runner results |
	runner := ReSmalllintChecker new.
	runner
		rule: {aLintRule};
		environment: RBBrowserEnvironment default;
		run.

	results := (runner criticsOf: aLintRule) reject: [ :critique | someNames includes: critique entity name ].

	self
		assert: results isEmpty
		description: [ String
				streamContents: [ :s | 
					s
						<< aLintRule rationale;
						lf;
						<< 'Violations: ';
						lf.
					results
						do: [ :e | 
							s
								<< '- ';
								print: e entity ]
						separatedBy: [ s lf ] ] ]
]

{ #category : #helpers }
ReleaseTest >> hasStartUpOrShutDownMethod: aClass [
	| keySelectors |
	keySelectors := #(#startUp #startUp: #shutDown #shutDown:).
	^ (aClass selectors includesAny: keySelectors)
		or: [ aClass class selectors includesAny: keySelectors ]
]

{ #category : #accessing }
ReleaseTest >> knownProcesses [
	"Return a dynamic list of know processes"
	
	"(self actualProcesses difference: self knownProcesses) do: [ :each | each suspend; terminate ]."
	
	^ {
		Processor activeProcess.	
		Processor backgroundProcess.
		InputEventFetcher default fetcherProcess.
		WeakArray runningFinalizationProcess.
		SmalltalkImage current lowSpaceWatcherProcess.
		MorphicUIManager uiProcess.
		CurrentExecutionEnvironment value watchDogProcess.
		Delay schedulingProcess.
		TKTWatchDog onDuty pharoProcess.
		TFCallbackQueue uniqueInstance callbackProcess } asSet
]

{ #category : #'tests - variables' }
ReleaseTest >> testAllClassPoolBindingAreClassVariables [
	| wrong |
	wrong := OrderedCollection new.
	testingEnvironment allClasses do: [ :class | wrong addAll: (class classVariables reject: [ :each | each isKindOf: ClassVariable ]) ].
	self assertEmpty: wrong
]

{ #category : #'tests - variables' }
ReleaseTest >> testAllClassPoolBindingHaveDefiningClass [
	| wrong |
	wrong := OrderedCollection new.
	testingEnvironment allClasses do: [ :class | wrong addAll: (class classVariables reject: [ :each | each definingClass == class ]) ].
	self assertEmpty: wrong
]

{ #category : #'tests - variables' }
ReleaseTest >> testAllGlobalBindingAreGlobalVariables [
	| wrong |
	wrong := testingEnvironment associations reject: [ :each | each isKindOf: GlobalVariable ].
	self assertEmpty: wrong
]

{ #category : #'tests - variables' }
ReleaseTest >> testAllInstanceVariablesStartLowercase [
	"Make sure that all class instance variable names start with a lowercase letter"
	| violating |

	violating := Smalltalk globals allBehaviors select: [ :class | 
		class slots anySatisfy: [:var | var name first isUppercase]].

	self 
		assert: violating isEmpty 
		description: 'Instance variable names must start with a lowercase letter: ', violating asArray asString
]

{ #category : #'tests - variables' }
ReleaseTest >> testClassesShadow [

	| classes |
	classes := Smalltalk globals allBehaviors select: [ :class | 
		           class definedVariables anySatisfy: [ :var | 
			           var isShadowing ] ].

	self assert: classes isEmpty description: classes asArray asString
]

{ #category : #tests }
ReleaseTest >> testExplicitRequirementMethodsShouldBeImplementedInTheirUsers [
	"If a class is using a trait with an explicit requirement method, this class should implement the method"
	
	self assertValidLintRule: ReExplicitRequirementMethodsRule new
	
]

{ #category : #tests }
ReleaseTest >> testInstalledMethodsWithIncorrectTrailerKind [
	| incorrectMethods |
	
	incorrectMethods := SystemNavigation new installedMethodsWithIncorrectTrailerKind.
	
	self 
		assert: incorrectMethods isEmpty
		description: [ String streamContents: [ :s|
			s 
				nextPutAll: 'Found methods with incorrect trailer kind: ';
				print: incorrectMethods ]].
	
]

{ #category : #tests }
ReleaseTest >> testInstanceSideMethodsWithNilKeyInLastLiteral [
	| instanceSideMethodsWithNilKeyInLastLiteral |
	
	instanceSideMethodsWithNilKeyInLastLiteral := SystemNavigation new instanceSideMethodsWithNilKeyInLastLiteral.
	
	self 
		assert: instanceSideMethodsWithNilKeyInLastLiteral isEmpty
		description: [ String streamContents: [ :s|
			s 
				nextPutAll: 'Found methods with nil as last literal: ';
				print: instanceSideMethodsWithNilKeyInLastLiteral ]].
	
]

{ #category : #tests }
ReleaseTest >> testKeyClassesArePresentInStartupList [
	| keyClasses registeredHandlers |
	keyClasses := #(#Delay #ProcessorScheduler #Stdio #OSPlatform #UUIDGenerator #DiskStore #WeakArray #BasicCommandLineHandler).
	registeredHandlers := SessionManager default startupList
		collect: [:each | each handledId].
	
	keyClasses do:	[ :className |
		self assert: (registeredHandlers includes: className).
		self assert: (self hasStartUpOrShutDownMethod: (testingEnvironment at: className)) ].
	
	self assert: (registeredHandlers includes: #UIManagerSessionHandler).
]

{ #category : #tests }
ReleaseTest >> testLayoutIntegrity [
	SystemNavigation default allClassesDo: [ :class |
		class instanceSide classLayout checkIntegrity.
		class classSide classLayout checkIntegrity ]
]

{ #category : #tests }
ReleaseTest >> testLocalMethodsOfTheClassShouldNotBeRepeatedInItsTraits [
	"If a class is using a trait with an explicit requirement method, this class should implement the method"
	
	self assertValidLintRule: ReLocalMethodsSameThanTraitRule new withExceptions: #(RBSmalllintTestLocalMethodsSameThanTraitObject).
]

{ #category : #tests }
ReleaseTest >> testManifestNamesAccordingToPackageNames [
	"Make sure package name and manifest name are in synch"
	
	|manifestClasses actualManifestNames expectedManifestNames |
	manifestClasses := self class environment allClasses select: [:each | each isManifest ].
	actualManifestNames := (manifestClasses collect: [:each | each name ]) sorted.
	expectedManifestNames := (manifestClasses collect: [:each | TheManifestBuilder manifestClassNameFor: each package name ]) sorted.
	
	self 
		assert: actualManifestNames size 
		equals: expectedManifestNames size.
	
	actualManifestNames do: [:each |
		 self assert: (expectedManifestNames includes: each)] 
]

{ #category : #tests }
ReleaseTest >> testMethodsContainNoHalt [

	| methods |
	methods := SystemNavigation new allMethods select: [ :method | method containsHalt ].
	"these methods are using halt for testing something"
	methods := methods reject: [ :method | 
		           method hasPragmaNamed: #haltOrBreakpointForTesting ].
	"these methods are implementing halt, we are not interested"
	methods := methods reject: [ :method | 
		           method hasPragmaNamed: #debuggerCompleteToSender ].

	"there should be no method left"
	self assert: methods isEmpty description: [ 
		String streamContents: [ :stream | 
			stream
				nextPutAll: 'Found methods with halt';
				print: methods ] ]
]

{ #category : #'tests - variables' }
ReleaseTest >> testMethodsWithUnboundGlobals [
	| methodsWithUnboundGlobals |
	"Ensure the environment is clean"
	3 timesRepeat: [ Smalltalk garbageCollect ].
	
	Smalltalk cleanOutUndeclared. 
	methodsWithUnboundGlobals := SystemNavigation new methodsWithUnboundGlobals.
	
	self 
		assert: methodsWithUnboundGlobals isEmpty
		description: [ String streamContents: [ :s |
			s 
				nextPutAll: 'Found methods with unbound globals: '; 
				print: methodsWithUnboundGlobals ]]
]

{ #category : #tests }
ReleaseTest >> testNoEmptyPackages [
	"Test that we have no empty packages left"

	| violating |
	violating := RPackageOrganizer default packages select: #isEmpty.
	self assertEmpty: violating
]

{ #category : #tests }
ReleaseTest >> testNoNilAssignmentInInitializeMethod [
	
	self assertValidLintRule: ReNoNilAssignationInInitializeRule new
	
]

{ #category : #'tests - variables' }
ReleaseTest >> testNoShadowedVariablesInMethods [
	"Fail if there are methods who define shadowed temps or args"
	| found validExceptions remaining |
	found := SystemNavigation default allMethodsSelect: [ :m | 
		m ast variableDefinitionNodes anySatisfy: [ :node | node variable isShadowing ] ].
	"Make sure to not waste memory with all the ASTs"
	ASTCache reset.
	"No other exceptions beside the ones mentioned here should be allowed"	
	validExceptions := { 
		RBDummyRefactoryTestDataApp>>#tempVarOverridesInstVar.
		RBRefactoryTestDataApp>>#tempVarOverridesInstVar.
		RBSmalllintTestObject>>#tempVarOverridesInstVar.
		ReTempVarOverridesInstVarRuleTest>>#sampleMethod:}.	
	
	remaining := found asOrderedCollection 
								removeAll: validExceptions;
								yourself.
								
	self 
		assert: remaining isEmpty 
		description: ('the following methods have shadowing variable definitions and should be cleaned: ', remaining asString)
]

{ #category : #tests }
ReleaseTest >> testObsoleteClasses [
	| obsoleteClasses |
	
	Smalltalk fixObsoleteReferences.
	Smalltalk garbageCollect.
	obsoleteClasses := SystemNavigation new obsoleteClasses
		select: [ :each | each isAnonymous not ].
	
	self 
		assert: obsoleteClasses isEmpty
		description: [
			String streamContents: [ :s|
				s 
					nextPutAll: 'Obsolete classes remaining: ';
					print: obsoleteClasses ]]
]

{ #category : #tests }
ReleaseTest >> testPharoVersionFileExists [

	"Test there is a pharo.version file next to this image containing the short version of this pharo image.
	This file is required by the Pharo launcher to correctly detect the Pharo version we are running on."
	
	| pharoVersionFile |
	pharoVersionFile := FileLocator imageDirectory / 'pharo.version'.
	self assert: pharoVersionFile exists.
	self
		assert: pharoVersionFile readStream contents trimBoth
		equals: SystemVersion current major asString,  SystemVersion current minor asString
]

{ #category : #'tests - packages - manifests' }
ReleaseTest >> testProperManifestClasses [

	|manifests|
	manifests := self class environment allClasses select: [:each | each isManifest ].
	self assert: (manifests allSatisfy: [:each | each inheritsFrom: PackageManifest ]).
	self assert: (manifests allSatisfy: [:each | each name beginsWith: 'Manifest' ]).


 
]

{ #category : #'tests - rpackage' }
ReleaseTest >> testRPackageOrganizer [
	"Ensure other tests temporary created organizers are collected"
	3 timesRepeat: [ Smalltalk garbageCollect ].

	"Now check :)"
	self 
		assert: RPackageOrganizer allInstances size = 1
		description: 'There are multiple (', RPackageOrganizer allInstances size asString, ') instances of RPackageOrganizer'.
		  
	self 
		assert: RPackageOrganizer allInstances first == RPackageOrganizer default 
		description: 'The default package organizer is the not the only instance of RPackageOrganizer'.
]

{ #category : #tests }
ReleaseTest >> testShouldFileLocatorBeBeforeSystemSettingsPersistenceInStartupList [
	"This test documents issue https://pharo.manuscript.com/f/cases/17721"
	
	| startupList settingsIndex |
	startupList := (SessionManager default startupList collect: [:each | each handledId]).
	settingsIndex := startupList indexOf: #SystemSettingsPersistence.
	settingsIndex > 0
		ifTrue: [ self should: [ (startupList indexOf: #FileLocator) < (startupList indexOf: #SystemSettingsPersistence) ] ]
]

{ #category : #tests }
ReleaseTest >> testShouldWorldMorphBeAfterFontClassesInStartupList [
	"This test documents issue https://pharo.manuscript.com/f/cases/17834"
	"The Startup of he WorldMorph is now done in the UIManagerHandler"
	| startupList |
	startupList := (SessionManager default startupList collect: [:each | each handledId]).
	#(StrikeFont LogicalFont FreeTypeSettings FreeTypeCache FT2Handle) 
		do: [ :fontClass |
			self should: [ (startupList indexOf: #UIManagerSessionHandler) > (startupList indexOf: #SystemSettingsPersistence) ] ]
]

{ #category : #tests }
ReleaseTest >> testTestCasesEndsWithTestOrTestCase [
	self assertValidLintRule: ReTestClassNameShouldEndWithTestRule new
	
]

{ #category : #'tests - rpackage' }
ReleaseTest >> testThatAllMethodsArePackaged [
	| classes instanceMethods classMethods allMethods methodsWithoutPackageInfo |
	classes := Smalltalk allClassesAndTraits.
	instanceMethods := classes flatCollect: #methods.
	classMethods := classes flatCollect: [ :class | class classSide methods ].
	allMethods := instanceMethods , classMethods.
	methodsWithoutPackageInfo := allMethods select: [ :method | method package isNil ].
	self assertEmpty: methodsWithoutPackageInfo
]

{ #category : #'tests - variables' }
ReleaseTest >> testUndeclared [
	| undeclaredVariables validExceptions remaining description |
	
	Smalltalk cleanOutUndeclared. 
	undeclaredVariables := Undeclared associations select: [:each |
			each isUndeclaredVariable].
	
	validExceptions := { #undeclaredStubInstVar1 . #undeclaredStubInstVar2 }.
	
	"for now we filter by name, maybe filtering by variable would be better"
	remaining := undeclaredVariables reject: [ :each | validExceptions includes: each name  ].
	
	"we look for one of the using methods of the undeclared var and report that, 
	this should be enough to fix it quickly"							
	description := String streamContents: [ :stream |
			stream nextPutAll: 'Found undeclared Variables: '.
			remaining do: [ :variable  |
				| method |
				method := variable usingMethods first.
				stream 
					cr
					nextPutAll: variable name;
					nextPutAll: ' in: ';
					print: method methodClass;
					nextPutAll: '>>';
					print: method selector]].

	self assert: remaining isEmpty description: description
]

{ #category : #tests }
ReleaseTest >> testUnknownProcesses [
	"Make sure that there are no other processes running except the known processes"
	
	| unknownProcesses |
	unknownProcesses := self actualProcesses difference: self knownProcesses.
	self 
		assert: unknownProcesses isEmpty
		description: (String streamContents: [ :out |
			out << 'Found unknown processes: '.
			unknownProcesses 
				do: [ :each | 
					out 
						print: each name;
						print: ':';
						print: each ] 
				separatedBy: [ out << String crlf ] ])
]

{ #category : #'tests - rpackage' }
ReleaseTest >> testUnpackagedClasses [
	| unpackagedClasses |
	unpackagedClasses := Smalltalk allClassesAndTraits select: [:each | 
		(RPackageOrganizer default packageOf: each) packageName = RPackage defaultPackageName ].
	self 
		assert: unpackagedClasses isEmpty 
		description: (String streamContents: [ :s|
			s nextPutAll: 'Found the following unpackaged classes: '.
			unpackagedClasses
				do: [ :cls| s tab print: cls ]
				separatedBy: [ s cr ]])

]

{ #category : #'tests - rpackage' }
ReleaseTest >> testUnpackagedPackageShouldBeEmpty [
	| unpackagePackage |
	unpackagePackage := RPackageOrganizer default packageNamed: RPackage defaultPackageName.
	"The unpackage package should not have any defined class or extended classes"
	self assertEmpty: unpackagePackage classes
]

{ #category : #tests }
ReleaseTest >> testWorldMenuHasHelpForAllEntries [
	"In this test we check that at least every terminal menu entry of the world menu has an help."

	| menuElements |
	menuElements := WorldState new menuBuilder itemList.

	"Here we have the roots of the menu. We want the terminal menu entries."
	[ menuElements allSatisfy: [ :each | each itemList isNil ] ]
		whileFalse: [ menuElements := menuElements inject: OrderedCollection new into: [ :coll :each | each itemList ifNil: [ coll add: each ] ifNotNil: [ :items | coll addAll: items ]. coll ] ].
			
	menuElements collect: #spec thenDo: [ :item | self assert: item help isNotNil description: item label , ' menu entry in world menu should have an help.' ]
]
