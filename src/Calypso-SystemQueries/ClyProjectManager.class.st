"
My subclasses represent concrete package management system like Cargo or Metacello.
They implement behaviour which is needed to query project and package information from concrete management system: version, comment, metadata.
Project and package are represented by classes ClyManagedProject and ClyManagedPackage
"
Class {
	#name : #ClyProjectManager,
	#superclass : #Object,
	#category : #'Calypso-SystemQueries-Domain'
}

{ #category : #'api - queries' }
ClyProjectManager >> projectQueryFor: aClySystemEnvironmentScope [ 
	
	^ ClyUnknownQuery instance
]

{ #category : #'api - queries' }
ClyProjectManager >> queryClass [
	^ self subclassResponsibility 
]
