"
MCPackage represents a package. It is merely a wrapper on top of a package set or packageInfo.

Strangely enough it does not inherit from MCDefinition.

Its most important method is snapshot which returns a snapshot with all the entities that should be saved. 
"
Class {
	#name : #MCPackage,
	#superclass : #Object,
	#instVars : [
		'name'
	],
	#category : #'Monticello-Base'
}

{ #category : #'instance creation' }
MCPackage class >> named: aString [
	^ self new name: aString
]

{ #category : #comparing }
MCPackage >> = other [
	^ other species = self species and: [other name = name]
]

{ #category : #accessing }
MCPackage >> correspondingRPackage [

	^ RPackageOrganizer default packageNamed: self name asSymbol ifAbsent: [ nil ]
]

{ #category : #printing }
MCPackage >> displayStringOn: aStream [
	aStream nextPutAll: self name
]

{ #category : #'working copies' }
MCPackage >> hasWorkingCopy [
	^ MCWorkingCopy registry includesKey: self
]

{ #category : #comparing }
MCPackage >> hash [
	^ name asLowercase hash
]

{ #category : #testing }
MCPackage >> isDirty [
	
	^ self workingCopy
		ifNil: [ false ]
		ifNotNil: [ :wc | wc modified ]
]

{ #category : #accessing }
MCPackage >> name [
	^ name
]

{ #category : #accessing }
MCPackage >> name: aString [
	name := aString
]

{ #category : #accessing }
MCPackage >> packageSet [
	^ RPackageSet named: name
]

{ #category : #printing }
MCPackage >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPut: $(;
		nextPutAll: name;
		nextPut: $)
]

{ #category : #accessing }
MCPackage >> snapshot [
	| rPackageSet definitions categories |
	rPackageSet := self packageSet.
	definitions := OrderedCollection new.
	categories := rPackageSet categoryNames asArray.
	categories isEmpty 
		ifFalse: [ definitions add: (MCOrganizationDefinition categories: categories) ].
		
	rPackageSet methods 
		do: [:ea | definitions add: ea asMCMethodDefinition] 
		displayingProgress: [ :ea| 'Snapshotting methods...' ].
				
	rPackageSet definedClasses 
		do: [:ea | definitions addAll: ea classDefinitions] 
		displayingProgress: [ :ea| 'Snapshotting class ', ea asString ].
		
	^ MCSnapshot fromDefinitions: definitions

]

{ #category : #printing }
MCPackage >> storeOn: aStream [
	aStream
		nextPutAll: 'MCPackage';
		space; nextPutAll: 'named: '; store: name.
]

{ #category : #'working copies' }
MCPackage >> unload [
	^ self workingCopy unload
]

{ #category : #'working copies' }
MCPackage >> workingCopy [
	^ MCWorkingCopy forPackage: self.
]
