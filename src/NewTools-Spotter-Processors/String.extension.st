Extension { #name : #String }

{ #category : #'*NewTools-Spotter-Processors' }
String >> splitCamelCase [
	
	| results accum previousIsLower |
	
	results := OrderedCollection new.
	accum := 	self first asString.
	previousIsLower := self first isLowercase.
	
	2 to: self size do: [ :index | | currentCharacter |
		currentCharacter := self at: index.
		(currentCharacter isUppercase and: [ previousIsLower ])
			ifTrue: [ results add: accum. accum := '' ].
			
		accum := accum copyWith: currentCharacter.
		previousIsLower := currentCharacter isLowercase.
	].	
	
	results add: accum.
	
	^ results.
]
