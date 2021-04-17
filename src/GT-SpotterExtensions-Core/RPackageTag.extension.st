Extension { #name : #RPackageTag }

{ #category : #'*GT-SpotterExtensions-Core' }
RPackageTag class >> gtExamplePackageTag [
	<gtExample>
	<label: 'Tag'>
	
	^ (RPackageOrganizer default packageOf: GTSpotter) classTags anyOne
]
