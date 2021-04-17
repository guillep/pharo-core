Extension { #name : #StClassEntry }

{ #category : #'*NewTools-Spotter' }
StClassEntry >> headerCategoryForUnifiedProcessor: aLink on: aSpotterPresenter [

	^ aSpotterPresenter headerCategoryUnifiedFor: aLink
]

{ #category : #'*NewTools-Spotter' }
StClassEntry class >> prepareUnifiedHeaderDescriptionFor: aHeaderPresenter [

	^ aHeaderPresenter prepareAsClasses
]
