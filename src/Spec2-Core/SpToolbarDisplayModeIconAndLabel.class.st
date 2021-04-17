"
Display the toolbar with icons and label only
"
Class {
	#name : #SpToolbarDisplayModeIconAndLabel,
	#superclass : #SpToolbarDisplayMode,
	#category : #'Spec2-Core-Widgets'
}

{ #category : #configuring }
SpToolbarDisplayModeIconAndLabel >> configureButton: aButton item: aToolbarItem [
	"ask for icon and label"
	aButton getLabelSelector: #label.
	aButton getIconSelector: #icon.
	aButton badgeSelector: #badge.
]

{ #category : #accessing }
SpToolbarDisplayModeIconAndLabel >> extent [
	^ 45@45
]

{ #category : #accessing }
SpToolbarDisplayModeIconAndLabel >> styleName [ 

	^ 'toolBar.iconsAndLabel'
]
