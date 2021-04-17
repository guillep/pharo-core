"
A layout for ephemeron objects
"
Class {
	#name : #EphemeronLayout,
	#superclass : #PointerLayout,
	#category : #'Kernel-Layout'
}

{ #category : #'instance creation' }
EphemeronLayout class >> extending: superLayout scope: aScope host: aClass [ 
	
	^ (superLayout extendEphemeron: aScope)
		host: aClass;
		yourself
]

{ #category : #description }
EphemeronLayout class >> kind [ 
	^ #ephemeron
]

{ #category : #format }
EphemeronLayout >> instanceSpecification [
	^ 5
]

{ #category : #accessing }
EphemeronLayout >> kindOfSubclass [
	^' ephemeronSubclass: '
]

{ #category : #accessing }
EphemeronLayout >> typeOfClass [
	^#ephemeron
]
