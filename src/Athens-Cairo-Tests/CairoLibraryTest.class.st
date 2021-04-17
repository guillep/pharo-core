"
A CairoLibraryTest is a test class for testing the behavior of CairoLibrary
"
Class {
	#name : #CairoLibraryTest,
	#superclass : #TestCase,
	#category : #'Athens-Cairo-Tests-Library'
}

{ #category : #test }
CairoLibraryTest >> testVersionString [

	self assert:
		(CairoLibrary uniqueInstance versionString beginsWith: '1.')
]
