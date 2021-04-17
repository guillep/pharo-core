Extension { #name : #TestCase }

{ #category : #'*SUnit-MockObjects' }
TestCase >> verify: aMockObject [

	^ aMockObject verifyIn: self
]
