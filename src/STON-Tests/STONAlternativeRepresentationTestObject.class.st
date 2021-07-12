"
I am STONAlternativeRepresentationTestObject.

My properties are
 - id <Integer>
 - time <DateAndTime> in the local time zone
 - gridReference <Point <Float>@<Float>> in kilometer

My STON representation has the properties
 - id <Integer>
 - time <DateAndTime> in UTC
 - grid_reference <Point <Float>@<Float>> in miles

Note the different key, gridReference vs. grid_reference

Upon serialization, the conversions local time to UTC and kilometer to mile is performed.
Upon materialization, the convertions UTC to local tie and miles to kilometers are performed.
 
"
Class {
	#name : #STONAlternativeRepresentationTestObject,
	#superclass : #Object,
	#instVars : [
		'id',
		'time',
		'gridReference'
	],
	#classVars : [
		'KnownObjects'
	],
	#category : #'STON-Tests-Support'
}

{ #category : #example }
STONAlternativeRepresentationTestObject class >> example [
	^ self new
		id: 1e9 atRandom; 
		time: DateAndTime now; 
		gridReference: 150.75@250.25; 
		yourself
]

{ #category : #'ston persistence' }
STONAlternativeRepresentationTestObject >> fromSton: stonReader [
	stonReader parseMapDo: [ :key :value |
		key = #id ifTrue: [ self id: value ].
		key = #time ifTrue: [ self timeUTC: value ].
		key = #grid_reference ifTrue: [ self gridReferenceImperial: value ] ]
]

{ #category : #accessing }
STONAlternativeRepresentationTestObject >> gridReference [
	^ gridReference
]

{ #category : #accessing }
STONAlternativeRepresentationTestObject >> gridReference: value [
	gridReference := value
]

{ #category : #accessing }
STONAlternativeRepresentationTestObject >> gridReferenceImperial [
	^ gridReference / 1.609344
]

{ #category : #accessing }
STONAlternativeRepresentationTestObject >> gridReferenceImperial: value [
	gridReference := value * 1.609344
]

{ #category : #accessing }
STONAlternativeRepresentationTestObject >> id [
	^ id
]

{ #category : #accessing }
STONAlternativeRepresentationTestObject >> id: anObject [
	id := anObject
]

{ #category : #'ston persistence' }
STONAlternativeRepresentationTestObject >> stonOn: stonWriter [	
	stonWriter writeObject: self streamMap: [ :dictionary |
		dictionary
			at: #id put: self id;
			at: #time put: self timeUTC;
			at: #grid_reference put: self gridReferenceImperial ]
]

{ #category : #accessing }
STONAlternativeRepresentationTestObject >> time [
	^ time
]

{ #category : #accessing }
STONAlternativeRepresentationTestObject >> time: anObject [
	time := anObject
]

{ #category : #accessing }
STONAlternativeRepresentationTestObject >> timeUTC [
	^ time asUTC
]

{ #category : #accessing }
STONAlternativeRepresentationTestObject >> timeUTC: value [
	time := value offset: TimeZone local offset 
]
