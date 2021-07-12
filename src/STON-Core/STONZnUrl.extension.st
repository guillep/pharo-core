Extension { #name : #STONZnUrl }

{ #category : #'*ston-core' }
STONZnUrl class >> fromSton: stonReader [
	^ ZnUrl fromString: stonReader parseListSingleton 
]

{ #category : #'*ston-core' }
STONZnUrl class >> stonName [
	^ #URL
]
