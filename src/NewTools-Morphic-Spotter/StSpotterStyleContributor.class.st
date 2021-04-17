Class {
	#name : #StSpotterStyleContributor,
	#superclass : #StPharoStyleContributor,
	#category : #'NewTools-Morphic-Spotter'
}

{ #category : #styles }
StSpotterStyleContributor >> styleSheetContribution [
	
	^ SpStyle newApplication 
		"addClass: 'presenter' with: [ :class | class "
			addClass: 'stSpotter' with: [ :spotterClass | spotterClass 
				addPropertyContainerWith: [ :c | c borderColor: Smalltalk ui theme backgroundColor ];
				addPropertyDrawWith: [ :draw | draw backgroundColor: Smalltalk ui theme backgroundColor ] "]";
			addClass: 'stSpotterLink' with: [ :spotterLinkClass | spotterLinkClass 
				addPropertyGeometryWith: [ :geometry | geometry height: 22; vResizing: false ] ] ]; 
		addClass: 'componentList' with: [ :componentList | componentList 
			addClass: 'stSpotterList' with: [ :spotter | spotter 
				addPropertyDrawWith: [ :draw | draw color: Color transparent ] ] ];
		addClass: 'searchInputField' with: [ :class | class 
			addClass: 'stSpotterSearch' with: [ :spotterClass | spotterClass
				addPropertyDrawWith: [ :draw | draw color: Color transparent ];
				addPropertyTextWith: [ :text | text drawKeyboardFocus: false ];
				addPropertyGeometryWith: [ :geometry | geometry minHeight: 35; vResizing: false ];
				addPropertyFontWith: [ :font | font size: 12 ] ] ];
		addClass: 'text' with: [ :class | class 
			addClass: 'stSpotterPreview' with: [ :spotter | spotter
				addPropertyDrawWith: [ :draw | draw color: Color transparent ] ] ];
		addClass: 'code' with: [ :class | class 
			addClass: 'stSpotterPreview' with: [ :spotterClass | spotterClass
				addPropertyDrawWith: [ :draw | draw color: Color transparent ] ] ];
		yourself
]
