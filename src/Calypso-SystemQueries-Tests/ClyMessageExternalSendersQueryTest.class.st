Class {
	#name : #ClyMessageExternalSendersQueryTest,
	#superclass : #ClyMethodQueryTestCase,
	#category : #'Calypso-SystemQueries-Tests-Queries'
}

{ #category : #running }
ClyMessageExternalSendersQueryTest >> createQuery [
	^ ClyMessageExternalSendersQuery
		of: self referencedSelector
		from: (ClyClassScope of: Object in: environment)
]

{ #category : #running }
ClyMessageExternalSendersQueryTest >> referencedSelector [
	^#selfReferencingSelector
]

{ #category : #running }
ClyMessageExternalSendersQueryTest >> selfReferencingSelector [
	^#selfReferencingSelector
]

{ #category : #tests }
ClyMessageExternalSendersQueryTest >> testFromSystemScope [
	
	self queryFromScope: ClySystemEnvironmentScope of: ClySystemEnvironment currentImage.	
	
	self deny: (foundSelectors includes: 'selfReferencingSelector' asSymbol)
]
