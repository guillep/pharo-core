Extension { #name : #StMethodEntry }

{ #category : #'*NewTools-Spotter' }
StMethodEntry >> headerCategoryForUnifiedProcessor: aLink on: aSpotterPresenter [

	^ aSpotterPresenter headerCategoryUnifiedFor: aLink
]

{ #category : #'*NewTools-Spotter' }
StMethodEntry class >> prepareUnifiedHeaderDescriptionFor: aHeaderPresenter [

	^ aHeaderPresenter prepareAsImplementors
]
