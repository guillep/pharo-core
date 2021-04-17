Extension { #name : #StEntry }

{ #category : #'*NewTools-Spotter' }
StEntry >> headerCategoryForUnifiedProcessor: aLink on: aSpotterPresenter [

	^ aSpotterPresenter headerCategoryFor: aLink 			

]

{ #category : #'*NewTools-Spotter' }
StEntry class >> prepareUnifiedHeaderDescriptionFor: aHeaderPresenter [
	"do nothing"
]
