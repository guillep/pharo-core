"
I am processor that gets all the projects from the Catalog.
However, this operation is quite expensive so this is not enabled by default.
"
Class {
	#name : #StCatalogProjectsProcessor,
	#superclass : #StCollectionBasedProcessor,
	#category : #'NewTools-Spotter-Processors-Processors'
}

{ #category : #'default-settings' }
StCatalogProjectsProcessor class >> defaultEnabled [

	^ false
]

{ #category : #accessing }
StCatalogProjectsProcessor class >> order [
	
	^ 900
]

{ #category : #accessing }
StCatalogProjectsProcessor class >> title [

	^ 'Catalog Projects'
]

{ #category : #filtering }
StCatalogProjectsProcessor >> collection [

	^ CatalogProvider default projects
]

{ #category : #filtering }
StCatalogProjectsProcessor >> newEntryOn: anElement [

	^ StCatalogProjectEntry on: anElement
]
