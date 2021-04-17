Extension { #name : #StPackageEntry }

{ #category : #'*NewTools-Spotter' }
StPackageEntry >> headerCategoryForUnifiedProcessor: aLink on: aSpotterPresenter [

	^ aSpotterPresenter headerCategoryUnifiedFor: aLink
]

{ #category : #'*NewTools-Spotter' }
StPackageEntry class >> prepareUnifiedHeaderDescriptionFor: aHeaderPresenter [

	^ aHeaderPresenter prepareAsPackages
]
