Class {
	#name : #RGTraitDescriptionStrategy,
	#superclass : #RGBehaviorStrategy,
	#category : #'Ring-Core-Kernel'
}

{ #category : #variables }
RGTraitDescriptionStrategy >> allSharedPoolNames [

	^#()
]

{ #category : #variables }
RGTraitDescriptionStrategy >> initialize [

	super initialize.
	
	self owner environment backend createUnresolvedTraitGroupFor: self owner.
	
]

{ #category : #variables }
RGTraitDescriptionStrategy >> isTrait [

	^true
]

{ #category : #variables }
RGTraitDescriptionStrategy >> methods [

	| allMethods |
	allMethods := IdentitySet new.
	self localMethodsDo: [ :each | allMethods add: each].
	^ allMethods asArray

]

{ #category : #variables }
RGTraitDescriptionStrategy >> name: aString [

	| usersWithOldDefinition |

	usersWithOldDefinition := self users collect: [ :each | 
		each -> each copyForBehaviorDefinition ].

	super name: aString.
	
	usersWithOldDefinition do: [ :assoc |
		self trait announcer behaviorDefinitionChangedFrom: assoc value to: assoc key.
		self trait announcer behaviorModificationAppliedTo: assoc key. ].		
]

{ #category : #variables }
RGTraitDescriptionStrategy >> trait [

	^ self owner
]

{ #category : #variables }
RGTraitDescriptionStrategy >> users [
	
	"return collection of user of the trait"

	| result |
	
	result := IdentitySet new.

	self environment ask behaviorsDo: [ :each |
		(each usedTraits includes: self) ifTrue: [ result add: each ] ].
	
	^ result.
]
