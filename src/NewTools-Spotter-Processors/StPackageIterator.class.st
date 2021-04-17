"
I implement an iterator over all the packages in the system
"
Class {
	#name : #StPackageIterator,
	#superclass : #StGenericGenerator,
	#category : #'NewTools-Spotter-Processors-Iterators'
}

{ #category : #enumerating }
StPackageIterator >> elementsDo: aValuable [

	RPackageOrganizer default packagesDo: aValuable
]
