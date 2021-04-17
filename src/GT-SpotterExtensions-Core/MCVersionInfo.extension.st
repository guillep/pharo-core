Extension { #name : #MCVersionInfo }

{ #category : #'*GT-SpotterExtensions-Core-private' }
MCVersionInfo >> allAncestors [
	^ (self allAncestorsTo: OrderedCollection new)
		sort: [ :a :b | a timeStamp >= b timeStamp ]
]

{ #category : #'*GT-SpotterExtensions-Core-private' }
MCVersionInfo >> allAncestorsTo: aCollection [
	self ancestors do: [ :versionInfo | 
		" do not add/process ancestry-branches which have already been added/processed "
		(aCollection includes: versionInfo) ifFalse: [ 
			aCollection add: versionInfo.
			versionInfo allAncestorsTo: aCollection ] ].
	^ aCollection
]

{ #category : #'*GT-SpotterExtensions-Core' }
MCVersionInfo >> gtDisplayOn: stream [
	stream nextPutAll: self name
]
