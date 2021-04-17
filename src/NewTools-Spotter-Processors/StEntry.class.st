"
I wrap the return elements from the spotter processor. 
As the processor returns different elements I add the behaviour required to show the element. 

Also, I redirect the messages that should be answer by my content
"
Class {
	#name : #StEntry,
	#superclass : #DisplayableObject,
	#instVars : [
		'content'
	],
	#category : #'NewTools-Spotter-Processors-Entries'
}

{ #category : #wrapping }
StEntry class >> on: aValue [
	
	^ self new
		content: aValue;
		yourself
]

{ #category : #comparing }
StEntry >> = anEntry [

	^ self species = anEntry species
		and: [ anEntry content = self content ]
]

{ #category : #converting }
StEntry >> asString [ 

	^ self subclassResponsibility 
]

{ #category : #accessing }
StEntry >> content [
	^ content
]

{ #category : #accessing }
StEntry >> content: anObject [
	content := anObject
]

{ #category : #'spotter-extensions' }
StEntry >> displayString [

	^ self asString
]

{ #category : #evaluating }
StEntry >> doEvaluate [ 

	self subclassResponsibility 
]

{ #category : #evaluating }
StEntry >> evaluateFor: aGTSpotterStep [ 

	self doEvaluate.
	aGTSpotterStep exit.
]

{ #category : #comparing }
StEntry >> hash [

	^ content hash
]

{ #category : #accessing }
StEntry >> icon [
	
	^ self subclassResponsibility
]

{ #category : #accessing }
StEntry >> label [

	^ self asString
]

{ #category : #printing }
StEntry >> printOn: aStream [

	super printOn: aStream.	
	aStream
		<< '( ';
		print: content;
		<< ' )'
]

{ #category : #'spotter-extensions' }
StEntry >> spotterActDefault [
	^ content spotterActDefault 
]

{ #category : #accessing }
StEntry >> spotterPreview [

	^ (content spotterPreview: SpPresenterBuilder new)
		addStyle: 'stSpotterPreview';
		yourself
]

{ #category : #'spotter-extensions' }
StEntry >> stSpotterProcessorsFor: aSpotterStep [

	^ content stSpotterProcessorsFor: aSpotterStep
]
