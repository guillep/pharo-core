"
I return all senders of a collection of selectors, excluding those senders in the input collection itself.
"
Class {
	#name : #ClyMessageExternalSendersQuery,
	#superclass : #ClyMessageSendersQuery,
	#category : #'Calypso-SystemQueries-Queries'
}

{ #category : #execution }
ClyMessageExternalSendersQuery >> buildResult: aQueryResult [

	super buildResult: aQueryResult.
	aQueryResult items removeAllSuchThat: [ :each | selectors includes: each selector ]
]
