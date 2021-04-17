Extension { #name : #SystemWindow }

{ #category : #'*GT-SpotterExtensions-Core' }
SystemWindow >> spotterActDefault [
	^ self isTopWindow
		ifTrue: [self comeToFront] "rise above non-window morphs"
		ifFalse:[	self activate].

]
