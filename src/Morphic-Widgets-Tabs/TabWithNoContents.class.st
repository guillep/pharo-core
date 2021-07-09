"
Error raised when a tab is asked its contents but have no morph and no retrieving block, or the retrieving block is returning nil.
"
Class {
	#name : #TabWithNoContents,
	#superclass : #TabWithNoContentsMorph,
	#category : #'Morphic-Widgets-Tabs-Support'
}

{ #category : #testing }
TabWithNoContents class >> isDeprecated [ 
	^ true
]
