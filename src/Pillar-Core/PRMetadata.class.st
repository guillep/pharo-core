"
This class is directly used by Microdown and not by the Pillar parser. 
It will mainly used for migrating documents from Pillar to Microdown because strangely enough meta data in Pillar was not a first class component. It means that when parsing a pillar document probably the pillar parser is not handle metadata. So metadata in Pillar files looks like a hack.
"
Class {
	#name : #PRMetadata,
	#superclass : #PRDocumentItem,
	#instVars : [
		'metadata'
	],
	#category : #'Pillar-Core-Model'
}

{ #category : #testing }
PRMetadata class >> isAbstract [
	^ false
]

{ #category : #initialization }
PRMetadata >> accept: aVisitor [

	^ aVisitor visitMetadata: self
]

{ #category : #initialization }
PRMetadata >> initialize [ 
	super initialize.
	metadata := Dictionary new
]

{ #category : #accessing }
PRMetadata >> metaData [
	^ metadata
]

{ #category : #initialization }
PRMetadata >> metadata: aDictionary [

	metadata := aDictionary
]
