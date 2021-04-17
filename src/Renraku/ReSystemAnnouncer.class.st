"
I announnce events related to Renraku and it's users.

To see the possible announcements check ReCriticEvent hierarchy.

To subscribe use:

```Smalltalk
ReSystemAnnouncer uniqueInstance weak ...
``` 
"
Class {
	#name : #ReSystemAnnouncer,
	#superclass : #Announcer,
	#classInstVars : [
		'uniqueInstance'
	],
	#category : #'Renraku-Announcements'
}

{ #category : #'instance creation' }
ReSystemAnnouncer class >> uniqueInstance [
	"I'm a singleton…"
	
	^ uniqueInstance ifNil: [ uniqueInstance := self new ]
]

{ #category : #announce }
ReSystemAnnouncer >> notifyCritique: aCritique descriptionViewedFor: anEntity [

	self announce: (
		ReCritiqueDescriptionViewed new 
			critique: aCritique;
			entity: anEntity;
			yourself)
  
]

{ #category : #announce }
ReSystemAnnouncer >> notifyCritique: aCritique of: anEntity bannedOn: anEntityBanLevel [

	self announce: (
		ReCritiqueBanned new
			critique: aCritique;
			entity: anEntity;
			entityBanLevel: anEntityBanLevel;
			yourself)

]

{ #category : #announce }
ReSystemAnnouncer >> notifyEntity: anEntity criticizedWith: critiques [

	self announce: (
		ReEntityCriticized new 
			critiques: critiques;
			entity: anEntity;
			yourself)

]
