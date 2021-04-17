"
A Metacello repository
"
Class {
	#name : #MCRepository,
	#superclass : #Object,
	#instVars : [
		'creationTemplate'
	],
	#classVars : [
		'Settings'
	],
	#category : #'Monticello-Repositories'
}

{ #category : #accessing }
MCRepository class >> allConcreteSubclasses [
	^ self withAllSubclasses reject: [:ea | ea isAbstract]
]

{ #category : #accessing }
MCRepository class >> creationTemplate [
	self subclassResponsibility.
]

{ #category : #accessing }
MCRepository class >> description [
	^ nil
]

{ #category : #'request handling' }
MCRepository class >> fillInTheBlankRequest [
	self subclassResponsibility.
]

{ #category : #'instance creation' }
MCRepository class >> fromUrl: aUrlOrString [ 
	| url |
	url := aUrlOrString asUrl.

	^ self allSubclasses 
		detect: [ :each | 
			(each class includesSelector: #urlSchemes)
			and: [ each urlSchemes includes: url scheme ] ]
		ifFound: [ :repositoryClass | repositoryClass basicFromUrl: url ]
		ifNone: [ MCRepositoryError signal: 'Cannot instantiate a repository from the url: ', url asString ]
]

{ #category : #testing }
MCRepository class >> isAbstract [
	^ self description isNil
]

{ #category : #'instance creation' }
MCRepository class >> morphicConfigure [
	^ self new
]

{ #category : #accessing }
MCRepository class >> urlSchemes [
	"Returns the URL schemes used to describe this repository"
	^ #()
]

{ #category : #comparing }
MCRepository >> = other [
	^ other species = self species and: [other description = self description]
]

{ #category : #adding }
MCRepository >> addTo: aRepository [
	^ aRepository addBasicRepository: self
]

{ #category : #converting }
MCRepository >> asCreationTemplate [
	^ self creationTemplate
]

{ #category : #storing }
MCRepository >> basicStoreVersion: aVersion [
	self subclassResponsibility
]

{ #category : #accessing }
MCRepository >> closestAncestorVersionFor: anAncestry ifNone: errorBlock [
	anAncestry breadthFirstAncestorsDo:
		[:ancestorInfo |
		(self versionWithInfo: ancestorInfo) ifNotNil: [:v | ^ v]].
	^ errorBlock value
]

{ #category : #accessing }
MCRepository >> creationTemplate [
	^ creationTemplate
]

{ #category : #accessing }
MCRepository >> creationTemplate: aString [
	self creationTemplate ifNotNil: [ self error: 'Creation template already set for this MCRepository instance.' ].
	
	creationTemplate := aString.
]

{ #category : #accessing }
MCRepository >> description [
	^ self class name
]

{ #category : #printing }
MCRepository >> displayStringOn: aStream [
	aStream nextPutAll: self description
]

{ #category : #'error handling' }
MCRepository >> error: aString [ 
	^ MCRepositoryError new signal: aString
]

{ #category : #comparing }
MCRepository >> hash [
	^ self description hash
]

{ #category : #interface }
MCRepository >> includesVersionNamed: aString [
	self subclassResponsibility
]

{ #category : #testing }
MCRepository >> isValid [
	^true
]

{ #category : #accessing }
MCRepository >> possiblyNewerVersionsOfAnyOf: someVersions [
	^#()
]

{ #category : #printing }
MCRepository >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPut: $(;
		nextPutAll: self description;
		nextPut: $).
]

{ #category : #storing }
MCRepository >> storeDependencies: aVersion [
	MCCacheRepository uniqueInstance cacheAllFileNamesDuring: 
		[self cacheAllFileNamesDuring: 
			[aVersion allAvailableDependenciesDo:
				[:dep |
					(self includesVersionNamed: dep info name)
						ifFalse: [self storeVersion: dep]]]]
]

{ #category : #storing }
MCRepository >> storeVersion: aVersion [
	self basicStoreVersion: aVersion.
	SystemAnnouncer uniqueInstance
		announce: (MCVersionSaved version: aVersion repository: self)
]

{ #category : #accessing }
MCRepository >> versionFrom: aVersionReferenceString [
	self error: 'Unable to load from ' , self printString
]

{ #category : #interface }
MCRepository >> versionWithInfo: aVersionInfo [
	^ self versionWithInfo: aVersionInfo ifAbsent: [nil]
]

{ #category : #interface }
MCRepository >> versionWithInfo: aVersionInfo ifAbsent: aBlock [
	self subclassResponsibility 
]
