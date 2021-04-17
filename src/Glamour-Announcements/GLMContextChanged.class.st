"
A GLMContextChanged is announced by a presentation when an outer port event raises.
"
Class {
	#name : #GLMContextChanged,
	#superclass : #Announcement,
	#instVars : [
		'presentation',
		'property',
		'value',
		'oldValue'
	],
	#category : #'Glamour-Announcements'
}

{ #category : #testing }
GLMContextChanged >> announcesNewSelection [ 
	"ContextChanged announces a new selection if 
	the updated port is #selection and the new value is different from the current selection. 
	This method is useful when updating the selection in UI widgets, because 
	we only want to affect the widget when there actually is a new selection" 
	 
	^self property = #selection 
		and: [self presentation selection ~~ self value]
]

{ #category : #accessing }
GLMContextChanged >> oldValue [ 
	 
	^oldValue
]

{ #category : #accessing }
GLMContextChanged >> oldValue: anObject [ 
	 
	oldValue := anObject
]

{ #category : #accessing }
GLMContextChanged >> presentation [ 
	 
	^presentation
]

{ #category : #accessing }
GLMContextChanged >> presentation: aPresentation [ 
	 
	presentation := aPresentation
]

{ #category : #printing }
GLMContextChanged >> printOn: aStream [
	super printOn: aStream.
	aStream 
		nextPutAll: ' (presentation = ';
		print: self presentation ;
		nextPutAll: ', property = #';
		nextPutAll: self property;
		nextPutAll: ', oldValue = ';
		nextPutAll: self oldValue displayString;
		nextPutAll: ', value = ';
		nextPutAll: self value displayString;
		nextPutAll: ')'
]

{ #category : #accessing }
GLMContextChanged >> property [ 
	 
	^property
]

{ #category : #accessing }
GLMContextChanged >> property: aSymbol [ 
	 
	property := aSymbol
]

{ #category : #accessing }
GLMContextChanged >> value [ 
	 
	^value
]

{ #category : #accessing }
GLMContextChanged >> value: anObject [ 
	 
	value := anObject
]
