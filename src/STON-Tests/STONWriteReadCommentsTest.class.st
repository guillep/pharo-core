Class {
	#name : #STONWriteReadCommentsTest,
	#superclass : #STONWriteReadTest,
	#category : #'STON-Tests-Write-Read'
}

{ #category : #private }
STONWriteReadCommentsTest >> materialize: string [
	^ STON reader
		on: (STONCStyleCommentsSkipStream on: string readStream);
		optimizeForLargeStructures;
		next
]

{ #category : #private }
STONWriteReadCommentsTest >> reader: string [
	^ STON reader
		on: (STONCStyleCommentsSkipStream on: string readStream);
		yourself
]

{ #category : #private }
STONWriteReadCommentsTest >> serialize: anObject [
	^ String streamContents: [ :stream |
		stream << '/* initial comment */'.
		STON writer 
			on: stream;
			nextPut: anObject.
		stream << '/* final comment */' ]
]
