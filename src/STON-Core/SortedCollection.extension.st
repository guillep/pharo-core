Extension { #name : #SortedCollection }

{ #category : #'*STON-Core' }
SortedCollection >> fromSton: stonReader [
	"Overwritten to get back the standard object behavior"
	
	stonReader parseNamedInstVarsFor: self
]

{ #category : #'*STON-Core' }
SortedCollection class >> fromSton: stonReader [
	"Overwritten to get back the standard object behavior"
	
	^ self new
		fromSton: stonReader;
		yourself
]

{ #category : #'*STON-Core' }
SortedCollection >> stonOn: stonWriter [
	"Overwritten to get back the standard object behavior"

	stonWriter writeObject: self
]
