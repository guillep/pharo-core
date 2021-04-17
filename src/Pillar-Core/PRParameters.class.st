Class {
	#name : #PRParameters,
	#superclass : #PRDocumentGroup,
	#category : #'Pillar-Core-Model'
}

{ #category : #'instance creation' }
PRParameters class >> with: aPRParameter withAll: aCollection [ 
	| anInstance |
	anInstance := self new.
	aPRParameter ifNotNil: [ anInstance add: aPRParameter ].
	aCollection ifNotNil: [ anInstance addAll: aCollection ].
	^ anInstance
]

{ #category : #visitor }
PRParameters >> accept: aVisitor [
	^ aVisitor visitParameters: self
]

{ #category : #converting }
PRParameters >> asDictionary [
	| dict |
	dict := OrderedDictionary new.
	self children do: [ :each | dict at: each key put: each value ].
	^ dict
]

{ #category : #accessing }
PRParameters >> parameters [ 
	^ children
]
