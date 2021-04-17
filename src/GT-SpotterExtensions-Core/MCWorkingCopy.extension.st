Extension { #name : #MCWorkingCopy }

{ #category : #'*GT-SpotterExtensions-Core' }
MCWorkingCopy >> gtDisplayOn: stream [
	ancestry ancestors isEmpty 
		ifTrue: [ 
			super displayStringOn: stream. stream nextPutAll: ' (unsaved)' ]
		ifFalse: [ 
			ancestry ancestors first displayStringOn: stream.
			self needsSaving ifTrue: [ stream nextPutAll: ' (modified)' ] ]
		
]

{ #category : #'*GT-SpotterExtensions-Core' }
MCWorkingCopy >> spotterCommit: workingCopy in: aRepository [
	| newVersion |

	newVersion := workingCopy newVersionIn: aRepository.
	newVersion ifNil: [ ^ self ].
	Cursor wait showWhile: [
		[ 	aRepository storeVersion: newVersion.
			aRepository storeDependencies: newVersion ] 
		ensure: [ (MCVersionInspector new version: newVersion) show ]]
]
