"
A presenter used to display a link. 
It will display me as a link the user should be able to click and it will open a web page in the user browser.
If there is no `label` set, the `url` will be taken as label aswell. 

"
Class {
	#name : #SpLinkPresenter,
	#superclass : #SpAbstractWidgetPresenter,
	#instVars : [
		'#label => SpObservableSlot',
		'#action => SpObservableSlot'
	],
	#category : #'Spec2-Morphic-Widgets'
}

{ #category : #specs }
SpLinkPresenter class >> adapterName [
	^ #LinkAdapter
]

{ #category : #documentation }
SpLinkPresenter class >> documentExamplesProtocol [
	
	^ #'*Spec2-Morphic-Examples'
]

{ #category : #api }
SpLinkPresenter >> action [
	"Answer the action to execute when link is pressed."

	^ action
]

{ #category : #api }
SpLinkPresenter >> action: aBlock [
	"Set the action to execute when link is pressed.
	 See also `SpLinkPresenter>>#url:`."

	action := aBlock
]

{ #category : #TOREMOVE }
SpLinkPresenter >> defaultColor [
	^ nil
]

{ #category : #initialization }
SpLinkPresenter >> initialize [

	super initialize.
	self whenLabelChangedDo: [ self changed: #getText ]
]

{ #category : #api }
SpLinkPresenter >> label [
	"Answer the label to display as the link"
	
	^ label
]

{ #category : #api }
SpLinkPresenter >> label: aString [
	"Set the label to display as the link."

	^ label := aString
]

{ #category : #localization }
SpLinkPresenter >> localeChanged [

	super localeChanged.
	self forceUpdateSlot: #label
		
]

{ #category : #private }
SpLinkPresenter >> performAction [

	self action value
]

{ #category : #api }
SpLinkPresenter >> url: aString [
	"Set the url to open when link is pressed. Also, it sets action (See `SpLinkPresenter>>#action:` 
	 to open an external browser to the url.
	 If there is no label selected (See `SpLinkPresenter>>#label:`, it sets it to the value 
	 of `aString`."

	self action: [ WebBrowser openOn: aString ].
	self label ifNil: [ self label: aString ]
]

{ #category : #'api-events' }
SpLinkPresenter >> whenActionChangedDo: aBlock [
	"Inform when action has changed. 
	 `aBlock` has three optional arguments: 
	 - new value
	 - old value
	 - the announcement triggering this action"

	self property: #action whenChangedDo: aBlock
]

{ #category : #'api-events' }
SpLinkPresenter >> whenLabelChangedDo: aBlock [
	"Inform when label state has changed. 
	 `aBlock` has three optional arguments: 
	 - new value
	 - old value
	 - the announcement triggering this action"

	self property: #label whenChangedDo: aBlock
]

{ #category : #'api-events' }
SpLinkPresenter >> whenUrlChangedDo: aBlock [
	"Inform when label state has changed. 
	 `aBlock` has three optional arguments: 
	 - new value
	 - old value
	 - the announcement triggering this action"

	self property: #url whenChangedDo: aBlock
]
