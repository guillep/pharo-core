Extension { #name : #MessageTally }

{ #category : #'*GT-InspectorExtensions-Core' }
MessageTally >> children [
	^ self sonsOver: 0
]

{ #category : #'*GT-InspectorExtensions-Core' }
MessageTally >> displayIdentifierOn: aStream [
	class displayStringOn: aStream.
	self method methodClass ~~ class 
		ifTrue: [ aStream nextPut: $(; print: self method methodClass; nextPut: $) ].
	aStream 
		nextPutAll: '>>';
		store: self method selector
]

{ #category : #'*GT-InspectorExtensions-Core' }
MessageTally >> gtDisplayIdentifierOn: aStream [
	class displayStringOn: aStream.
	self method methodClass ~~ class 
		ifTrue: [ aStream nextPut: $(; print: self method methodClass; nextPut: $) ].
	aStream 
		nextPutAll: '>>';
		store: self method selector
]

{ #category : #'*GT-InspectorExtensions-Core' }
MessageTally >> gtDisplayOn: aStream [
	self gtDisplayIdentifierOn: aStream.
	aStream 
		nextPutAll: ' (';
		nextPutAll: self tally printString;
		nextPutAll: ')'
]

{ #category : #'*GT-InspectorExtensions-Core' }
MessageTally >> gtInspectorReportIn: composite [
	<gtInspectorPresentationOrder: 60>
	^ composite text
		title: 'Report';
		display: [ String streamContents: [:s | self report: s ] ]
]

{ #category : #'*GT-InspectorExtensions-Core' }
MessageTally >> gtInspectorSourceIn: composite [
	<gtInspectorPresentationOrder: 50>
	^ self method ifNotNil: [
		self method gtInspectorSourceIn: composite]
]

{ #category : #'*GT-InspectorExtensions-Core' }
MessageTally >> localTally [
	^ self children 
		inject: self tally
		into: [ :diff :each | diff - each tally ]
]

{ #category : #'*GT-InspectorExtensions-Core' }
MessageTally >> localTime [
	^ self children
		inject: self time 
		into: [ :diff :each | diff - each time ]
]

{ #category : #'*GT-InspectorExtensions-Core' }
MessageTally class >> on: aBlock [
	"This utility method constructs a tally object and returns it without
	triggering the construction of the default report"
	^ MessageTally new
		spyEvery: 1
		on: aBlock;
		yourself 
]
