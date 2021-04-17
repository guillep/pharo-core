"
I am a mock version of the CatalogProvider. 
As the catalog provider goes to the network it produces flaky tests!!
So I will return the projects required for the tests
"
Class {
	#name : #StMockCatalogProvider,
	#superclass : #CatalogProvider,
	#category : #'NewTools-Spotter-Processors-Tests'
}

{ #category : #accessing }
StMockCatalogProvider class >> forTest [

	Default := self new
]

{ #category : #accessing }
StMockCatalogProvider class >> reset [

	Default := nil
]

{ #category : #private }
StMockCatalogProvider >> loadProjects [
	"I am a mock version I do not go to the network"

	^ { self projectNamed: 'JSON'.
	    self projectNamed: 'Artefact'.
		 self projectNamed: 'ThirdProject'}
]

{ #category : #private }
StMockCatalogProvider >> projectNamed: aName [

	^ CatalogProject fromDictionary: { #name -> aName. #packageName -> aName.
	#repositoryUrl -> ('http://github.com/lala/' , aName) } asDictionary 
]
