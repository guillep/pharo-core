Extension { #name : #StUnifiedProcessor }

{ #category : #'*NewTools-Spotter' }
StUnifiedProcessor >> headerCategoryFor: aLink on: aSpotterPresenter [

	^ aLink value 
		headerCategoryForUnifiedProcessor: aLink 
		on: aSpotterPresenter
]

{ #category : #'*NewTools-Spotter' }
StUnifiedProcessor >> keyBindingForClasses [

	^ $b meta
]

{ #category : #'*NewTools-Spotter' }
StUnifiedProcessor >> keyBindingForImplementors [

	^ $m meta
]

{ #category : #'*NewTools-Spotter' }
StUnifiedProcessor >> keyBindingForPackages [

	^ $p meta
]
