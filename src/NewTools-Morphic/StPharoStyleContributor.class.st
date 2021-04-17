"
This class presents an entry point to extend the stylesheet used by the Pharo application.
Subclasses of it should implement #styleSheetContribution returning a StyleSheet that is composed with the default one. 

Also subclasses are able to extend the #isApplicable method in the class side and decide to apply or not in different scenarios (e.g., different Operating Systems)
"
Class {
	#name : #StPharoStyleContributor,
	#superclass : #Object,
	#category : #'NewTools-Morphic'
}

{ #category : #'as yet unclassified' }
StPharoStyleContributor class >> availableContributors [

	^ self allSubclasses
		select: [ :each | each isApplicable ]
		thenCollect: [ :each | each new ]
]

{ #category : #testing }
StPharoStyleContributor class >> isApplicable [ 

	^ true
]

{ #category : #styles }
StPharoStyleContributor >> styleSheetContribution [
	
	^ self subclassResponsibility

]
