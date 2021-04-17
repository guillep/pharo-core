"
Copy me to create a new configuration or edit and evaluate the following doits.

        ""Create configuration class and initial baseline method""

        MetacelloToolBox 
                createBaseline: '1.0-baseline'
                for: 'MyProject'
                repository: 'http://www.example.com/MyProjectRepository'
                requiredProjects: #('Gofer')
                packages: #('MyProject-Core' 'MyProject-Tests')
                dependencies:
                        {('MyProject-Core' -> #('Gofer')).
                         ('MyProject-Tests' -> #('MyProject-Core'))}
                groups:
                        {('default' -> #('Core')).
                        ('Core' -> #('MyProject-Core')).
                        ('Tests' -> #('MyProject-Tests'))}.

	   ""create initial development method from the baseline""

         MetacelloToolBox
               createDevelopment: '1.0'
               for: 'MyProject'
                importFromBaseline: '1.0-baseline'
                description: 'initial version'.

"
Class {
	#name : #MetacelloConfigTemplateExample,
	#superclass : #Object,
	#instVars : [
		'project'
	],
	#category : #'Metacello-MC-Model'
}

{ #category : #'development support' }
MetacelloConfigTemplateExample class >> DevelopmentSupport [

"See the methods in the 'development support' category on the class-side of MetacelloBaseConfiguration. Decide what development support methods you would like to use and copy them the the class-side of your configuration."
	<apiDocumentation>
]

{ #category : #private }
MetacelloConfigTemplateExample class >> baseConfigurationClassIfAbsent: aBlock [

	^self environment 
		at: #MetacelloBaseConfiguration
		ifAbsent: [ 
			self ensureMetacelloBaseConfiguration.
			self environment at: #MetacelloBaseConfiguration ifAbsent: aBlock ].
]

{ #category : #private }
MetacelloConfigTemplateExample class >> ensureMetacello [

	(self baseConfigurationClassIfAbsent: []) ensureMetacello
]

{ #category : #private }
MetacelloConfigTemplateExample class >> ensureMetacelloBaseConfiguration [

	self environment 
		at: #MetacelloBaseConfiguration
		ifAbsent: [ 
			| repository version |
			repository := MCHttpRepository location: 'http://seaside.gemstone.com/ss/metacello' user: '' password: ''.
			repository
				versionReaderForFileNamed: 'Metacello-Base-DaleHenrichs.2.mcz'
				do: [ :reader | 
					version := reader version.
					version load.
					version workingCopy repositoryGroup addRepository: repository ] ]
]

{ #category : #'metacello tool support' }
MetacelloConfigTemplateExample class >> isMetacelloConfig [
	"Answer true and the Metacello tools will operate on you"
	
	^true
]

{ #category : #loading }
MetacelloConfigTemplateExample class >> load [
	"Load the #stable version defined for this platform. The #stable version is the version that is recommended to be used on this platform."

	"self load"

	<apiDocumentation>
	^(self project version: #stable) load
]

{ #category : #loading }
MetacelloConfigTemplateExample class >> loadBleedingEdge [
	"Load the latest versions of the mcz files defined for this project. It is not likely that the #bleedingEdge has been tested."

	"self loadBleedingEdge"

	<apiDocumentation>
	^(self project version: #bleedingEdge) load
]

{ #category : #loading }
MetacelloConfigTemplateExample class >> loadDevelopment [
	"Load the #development version defined for this platform. The #development version will change over time and is not expected to be stable."

	"self loadDevelopment"

	<apiDocumentation>
	^(self project version: #development) load
]

{ #category : #accessing }
MetacelloConfigTemplateExample class >> project [

	^self new project
]

{ #category : #'development support' }
MetacelloConfigTemplateExample class >> validate [
	"Check the configuration for Errors, Critical Warnings, and Warnings (see class comment for MetacelloMCVersionValidator for more information). 
	Errors identify specification issues that will result in unexpected behaviour when you load the configuration. 
	Critical Warnings identify specification issues that may result in unexpected behavior when you load the configuration.
	Warnings identify specification issues that are technically correct, but are worth take a look at."

	"self validate"

	<apiDocumentation>
	self ensureMetacello.
	^ ((self environment at: #MetacelloToolBox) validateConfiguration: self debug: #() recurse: false) inspect
]

{ #category : #baselines }
MetacelloConfigTemplateExample >> baseline10: spec [
	"Baselines are used by convention in Metacello and essentially are nothing else than normal versions.
	Name the baseline after the first version it was introduced.
	In this case 1.0-baseline was introduced the first time with the 1.0 version defined in the #version10 method.
	Metacello only uses the following tag to figure out the name of this baseline:"
	<version: '1.0-baseline'>

	"Using #common makes this dependency declaration available for all Smalltalks.
	If you need more fine-grained control you can add several #for:do: sections for other releases."
	spec for: #common do: [	
		spec blessing: #baseline.
		"specify the default repository for your project's packages"
		spec repository: 'http://smalltalkhub.com/mc/JohnDoe/MyProject/main'.
	
		"use separate methods for external projects"
		self 
			fuelMetalevel: spec;
			fileSystemLegacy: spec.
		
		"specify the dependencies between packages and projects"
		spec
			"a package without dependencies:"
			package: 'MyProject-Core';
			package: 'MyProject-Tests' with: [ 
				"Specfiy dependencies using the #requires: directive, you can refer to any name here, in this case to an external project"
				spec requires: #('MyProject-Core' 'FuelMetalevel' 'FileSystemLegacy')].
			
		"using groups certain packages and projects can be loaded conditionally"
		spec 
			"load the tests by default"
			group: 'default' with: #('core' 'test');
			group: 'test'    with: #('MyProject-Tests');
			group: 'core'    with: #('MyProject-Core')]
]

{ #category : #accessing }
MetacelloConfigTemplateExample >> customProjectAttributes [
	 "Edit to return a collection of any custom attributes e.g. for conditional loading: Array with: #'Condition1' with: #'Condition2.
	For more information see: http://code.google.com/p/metacello/wiki/CustomProjectAttrributes"

	^ #().
]

{ #category : #tags }
MetacelloConfigTemplateExample >> development: spec [
	"By convention the development branch should point to a fixed version that is regularly updated and might contain unstable code.
	The name used by Metacello is only defined by the following pragma:"
	<symbolicVersion: #development >
	
	"For the development tag refer to a fixed version which you update if you commit new code.
	Note that you can refer here to any other version name from this configuration"
	spec for: #'common' version: 'dev'.
]

{ #category : #'external projects' }
MetacelloConfigTemplateExample >> fileSystemLegacy: spec [
	"This is an example of an external project which does not have a configuration yet.
	Note that the package name is only used in the Metacello configuration and does not have be exactly the same as the Monticello project/version name."
	spec package: 'FileSystemLegacy' with: [
		spec 
			repository: 'http://smalltalkhub.com/mc/PharoExtras/FileSystemLegacy/main';
			"if you do not specify a version, automatically the newest version is chose."
			file:  'FileSystem-Legacy-JohanBrichau.2' ]
]

{ #category : #'external projects' }
MetacelloConfigTemplateExample >> fuelMetalevel: spec [

	"Specify a dependency on an external project which has it's own configuration.
	The given project name can be chosen freely, for simplicity use the same name as the configuration or the conditional group you load."
	spec project: 'FuelMetalevel' with: [
		spec 
			repository: 'http://ss3.gemstone.com/ss/Fuel';
			className: 'ConfigurationOfFuel';
			"if you want to load by default a special group usse the #loads: message plus a group name of the external configuration"
			loads: #FuelMetalevel ].
]

{ #category : #accessing }
MetacelloConfigTemplateExample >> project [

	^ project ifNil: [ 
		"Bootstrap Metacello if it is not already loaded"
		(self class baseConfigurationClassIfAbsent: []) ensureMetacello.
		"Construct Metacello project"
		project := MetacelloMCProject new projectAttributes: self customProjectAttributes. 
		(Smalltalk at: #MetacelloVersionConstructor) on: self project: project.
		project loadType: #linear. "change to #atomic if desired"
		project ]
]

{ #category : #tags }
MetacelloConfigTemplateExample >> stable: spec [
	"Symbolic versions can be used to introduce an indirection to a version number.
	The real name used by Metacello is only defined by the following pragma:"
	<symbolicVersion: #stable >
	
	"If another version is stable for a differen Smalltalk use a specific name"
	"spec for: #'pharo1.4.x' version: '0.9'"
	
	"Specfiy which exact version you want to load"
	spec for: #'common' version: '1.0'.
]

{ #category : #versions }
MetacelloConfigTemplateExample >> version10: spec [
	"The name for this version is solely defined by the following pragma:"
	<version: '1.0' imports: #('1.0-baseline') >
	"Baselines are used to define more complex setups for your project.
	If you want to use external projects and have fine-graind control of the dependencies between packages use the #imports: part.
	See the #baseline10: for more details."
	
	"Using #for:do: with the #common release specifier the following version declaration is valid for all platforms."
	spec for: #common do: [
		spec 
			description: 'Version 1.0 the current stable release';
			blessing: #release;
			author: 'John Doe';
			timestamp: '2013-05-01'.
		
		"Specify the versions for each package and external project defined in the baseline, here the 1.0-baseline defined in the baseline10 method."
		spec
			"For standard Monticello packages simply refere to the full version name without the extension:"
			package: 'MyProject-Core'  with: 'MyProject-Core-JohnDoe.52';
			package: 'MyProject-Tests' with: 'MyProject-Tests-JohnDoe.73';
			
			"External projects versions are specified using #project:with:.
			Note the project name referes to the name used in the Metacello declaration.
			FuelMetalevel is defined in the #fuelMetalevel: method."
			project: 'FuelMetalevel' with: #stable ].
		
	"If you want to specify different version on other platforms add another #for:do: block with a different version identifier."
]

{ #category : #versions }
MetacelloConfigTemplateExample >> versionDevelopment: spec [
	"version specification for the current development branch, see #version10 for a complete explanation of a version declaration.
	In this case the 'dev' version uses the same baselin as version '1.0':"
	<version: 'dev' imports: #('1.0-baseline') >
	
	"Update this configuration regulrarly with intermediate releases.
	If a version is more stable or should stay accessible copy this 'dev' definition and give it a proper version name on its own.
	For example, in this case you might want to split a new version '1.1' by copying over this definition."
	spec for: #common do: [
		spec 
			description: 'Development Version';
			blessing: #development;
			author: 'John Doe';
			timestamp: '2013-05-09'.
		
		spec
			package: 'MyProject-Core'  with: 'MyProject-Core-JohnDoe.152';
			package: 'MyProject-Tests' with: 'MyProject-Tests-JohnDoe.173';
			"note that for the 'dev' version we rely on the #development version of the external FuleMetalevel project"
			project: 'FuelMetalevel'   with: #development ].
]
