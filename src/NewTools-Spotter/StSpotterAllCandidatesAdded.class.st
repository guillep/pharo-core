Class {
	#name : #StSpotterAllCandidatesAdded,
	#superclass : #StSpotterAnnouncement,
	#instVars : [
		'candidateLinks'
	],
	#category : #'NewTools-Spotter-Announcements'
}

{ #category : #accessing }
StSpotterAllCandidatesAdded >> candidateLinks [
	^ candidateLinks
]

{ #category : #accessing }
StSpotterAllCandidatesAdded >> candidateLinks: anObject [
	candidateLinks := anObject
]
