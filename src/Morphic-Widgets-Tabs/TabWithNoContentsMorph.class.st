"
Error raised when a tab is asked its contents but have no morph and no retrieving block, or the retrieving block is returning nil.
"
Class {
	#name : #TabWithNoContentsMorph,
	#superclass : #Error,
	#instVars : [
		'tab'
	],
	#category : #'Morphic-Widgets-Tabs-Support'
}

{ #category : #'instance creation' }
TabWithNoContentsMorph class >> signalTab: aTab [ 
	
	^ self new
		tab: aTab;
		signal
]

{ #category : #accessing }
TabWithNoContentsMorph >> tab [
	^tab
]

{ #category : #accessing }
TabWithNoContentsMorph >> tab: aTab [ 

	tab := aTab
]
