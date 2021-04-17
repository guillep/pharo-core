"
I am simple processor that iterates on the packages in the system
"
Class {
	#name : #StPackageProcessor,
	#superclass : #StSpotterProcessor,
	#category : #'NewTools-Spotter-Processors-Processors'
}

{ #category : #'default-settings' }
StPackageProcessor class >> defaultEnabled [

	^ false
]

{ #category : #settings }
StPackageProcessor class >> hideInSettings [

	"I am hidden because the implementation in the unified processor is richer"
	^ true
]

{ #category : #accessing }
StPackageProcessor class >> order [
	
	^ 100
]

{ #category : #accessing }
StPackageProcessor class >> title [
	^ 'Packages'
]

{ #category : #filtering }
StPackageProcessor >> newTextFilteringSource [

	^ (StPackageIterator new collect: [ :e | StClassEntry on: e ]) asSubstringFilter
]
