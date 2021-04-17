"
I wrap a CatalogProject entry, to modify its behavior if required for the spotter
"
Class {
	#name : #StCatalogProjectEntry,
	#superclass : #StEntry,
	#category : #'NewTools-Spotter-Processors-Entries'
}

{ #category : #converting }
StCatalogProjectEntry >> asString [ 

	^ content name
]

{ #category : #evaluating }
StCatalogProjectEntry >> doEvaluate [
	(UIManager default
		confirm: 'Would you like to install ' , content name , '?')
		ifFalse: [ ^ self ].

	content installStableVersion.
	UIManager inform: content name , ' installed'
]

{ #category : #accessing }
StCatalogProjectEntry >> icon [

	^ self iconNamed: #catalog
]
