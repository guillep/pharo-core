Extension { #name : #MCPackage }

{ #category : #'*GT-SpotterExtensions-Core' }
MCPackage >> gtDisplayOn: aStream [
	aStream nextPutAll: self name
]
