Class {
	#name : #GLMPagerWidgetThemer,
	#superclass : #Object,
	#category : #'Glamour-Morphic-Pager-Theme'
}

{ #category : #accessing }
GLMPagerWidgetThemer >> defaultScrollButtonStyleFor: aButton [

	aButton checkedIcon: GLMUIThemeExtraIcons glamorousGrayCircleEmpty.
	aButton checkedFocusedIcon: GLMUIThemeExtraIcons glamorousGrayCircle.
	
	aButton normalImage: GLMUIThemeExtraIcons glamorousGrayCircleEmpty.
	aButton selectedImage: GLMUIThemeExtraIcons glamorousGrayCircle.
	aButton checkedImage: aButton checkedIcon.
]

{ #category : #accessing }
GLMPagerWidgetThemer >> previewPaneStyleFor: aMorph [

	aMorph borderColor: (Color lightGray)
]

{ #category : #accessing }
GLMPagerWidgetThemer >> selectedPaneStyleFor: aMorph [

	aMorph borderColor: (Color transparent)
]
