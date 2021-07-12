Extension { #name : #ZnUrl }

{ #category : #'*ston-core' }
ZnUrl >> stonContainSubObjects [
	^ false
]

{ #category : #'*ston-core' }
ZnUrl >> stonOn: stonWriter [
	stonWriter 
		writeObject: self 
		named: STONZnUrl stonName 
		listSingleton: self asString 
]
