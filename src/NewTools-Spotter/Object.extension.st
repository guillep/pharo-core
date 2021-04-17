Extension { #name : #Object }

{ #category : #'*NewTools-Spotter' }
Object >> asStSpotterCandidateLink [

	^ StSpotterCandidateLink value: self
]

{ #category : #'*NewTools-Spotter' }
Object >> asStSpotterProcessorLink [

	^ StSpotterProcessorLink value: self
]

{ #category : #'*NewTools-Spotter' }
Object >> spotterPreview: aBuilder [

	^ self asString spotterPreview: aBuilder
]

{ #category : #'*NewTools-Spotter' }
Object >> stFilter [

	^ StFilterBlock stFilter
		
]

{ #category : #'*NewTools-Spotter' }
Object >> stListFilter [

	^ StFilterSubstring new
]

{ #category : #'*NewTools-Spotter' }
Object >> stSpotterProcessorsFor: aSpotterStep [
	"This is a utility method that collects all extensions (processors) for the current object.
	By default, it simply looks for the #spotterOrder: pragma.
	The step can decice whether or not an extension should be enabled.
	The step can also configure each extension (e.g. override any property)"
	
	(Pragma allNamed: #stSpotterOrder: from: self class to: Object) 
		do: [ :aPragma |  
			self perform: aPragma methodSelector with: aSpotterStep.
			aSpotterStep processors 
				ifNotEmpty: [ :list | list last order: (aPragma argumentAt: 1) ] ]
]
