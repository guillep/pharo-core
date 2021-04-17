Class {
	#name : #StSpotterAnnouncement,
	#superclass : #Announcement,
	#instVars : [
		'category'
	],
	#category : #'NewTools-Spotter-Announcements'
}

{ #category : #accessing }
StSpotterAnnouncement >> category [
	"Return the category (ie the kind of group of elements). This has nothing to do with class category."
	^ category
]

{ #category : #accessing }
StSpotterAnnouncement >> category: anObject [
	"Set the category (ie the kind of group of elements). This has nothing to do with class category."
	category := anObject
]
