"
I wrap the return elements from the spotter processor. 
As the processor returns different elements I add the behaviour required to show the element. 

Also, I redirect the messages that should be answer by my content
"
Class {
	#name : #SptEntry,
	#superclass : #DisplayableObject,
	#instVars : [
		'content'
	],
	#category : #'GT-Spotter-Processors-Entries'
}

{ #category : #wrapping }
SptEntry class >> on: aValue [
	
	^ self new
		content: aValue;
		yourself
]

{ #category : #comparing }
SptEntry >> = anEntry [

	^ self species = anEntry species
		and: [ anEntry content = self content ]
]

{ #category : #converting }
SptEntry >> asString [ 

	^ self subclassResponsibility 
]

{ #category : #accessing }
SptEntry >> content [
	^ content
]

{ #category : #accessing }
SptEntry >> content: anObject [
	content := anObject
]

{ #category : #'spotter-extensions' }
SptEntry >> displayString [

	^ self asString
]

{ #category : #evaluating }
SptEntry >> doEvaluate [ 

	self subclassResponsibility 
]

{ #category : #evaluating }
SptEntry >> evaluateFor: aGTSpotterStep [ 

	self doEvaluate.
	aGTSpotterStep exit.
]

{ #category : #comparing }
SptEntry >> hash [

	^ content hash
]

{ #category : #accessing }
SptEntry >> icon [
	
	^ self subclassResponsibility
]

{ #category : #printing }
SptEntry >> printOn: aStream [
	aStream
		<< self class name;
		<< '( ';
		print: content;
		<< ' )'
]

{ #category : #showing }
SptEntry >> render [ 

	^ GTSpotterItemBrick new
		icon: self icon;
		text: self asString
]

{ #category : #'spotter-extensions' }
SptEntry >> spotterActDefault [
	^ content spotterActDefault 
]

{ #category : #'spotter-extensions' }
SptEntry >> spotterPreviewIn: aComposite [

	^ content spotterPreviewIn: aComposite
]

{ #category : #'spotter-extensions' }
SptEntry >> spotterPreviewIn: aComposite inContext: aSpotter [

	^ self spotterPreviewIn: aComposite
]

{ #category : #'spotter-extensions' }
SptEntry >> spotterProcessorsFor: aSpotterStep [

	^ content spotterProcessorsFor: aSpotterStep
]

{ #category : #'spotter-extensions' }
SptEntry >> spotterProcessorsFor: aSpotterStep pragma: aPragma [

	^ content spotterProcessorsFor: aSpotterStep pragma: aPragma
]
