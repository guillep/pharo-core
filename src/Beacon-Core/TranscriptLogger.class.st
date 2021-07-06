"
This logger forwards to the Transcript all signals that it receives.

### Example:

```
TranscriptLogger new 
    runDuring: [ StringSignal emit: 'This is a message' ]
```
"
Class {
	#name : #TranscriptLogger,
	#superclass : #SignalLogger,
	#category : #'Beacon-Core-Loggers'
}

{ #category : #registering }
TranscriptLogger >> nextPut: anAnnouncement [
	self crTrace: anAnnouncement .
]
