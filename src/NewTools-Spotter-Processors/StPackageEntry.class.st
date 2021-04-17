"
I wrap a RPackage entry, to modify its behavior if required for the class
"
Class {
	#name : #StPackageEntry,
	#superclass : #StEntry,
	#category : #'NewTools-Spotter-Processors-Entries'
}

{ #category : #converting }
StPackageEntry >> asString [

	^ content name
]

{ #category : #evaluating }
StPackageEntry >> doEvaluate [

	content browse
]

{ #category : #accessing }
StPackageEntry >> icon [
	^ self iconNamed: #package
]
