"
A minified version of the DrTest tool.
"
Class {
	#name : #MiniDrTests,
	#superclass : #AbstractDrTestsPresenter,
	#category : #'DrTests-Spec'
}

{ #category : #specs }
MiniDrTests class >> defaultSpec [
	^ SpBoxLayout newVertical
		add: (SpBoxLayout newHorizontal
				add: #switchButton;
				yourself)
		expand: false
		fill: true
		padding: 1;
		add: #startButton;
		yourself
]

{ #category : #accessing }
MiniDrTests >> currentPlugin: anObject [

	currentPlugin := anObject
]

{ #category : #accessing }
MiniDrTests >> evaluateBackgroundColor [

	^ pluginResult backgroundColor
]

{ #category : #'private - initialization' }
MiniDrTests >> initializeButtons [
	super initializeButtons.
	startButton
		label: 'run';
		icon: (self iconNamed: #smallUpdate);
		color: (Color gray).
	switchButton
		label: 'Maximize'
]

{ #category : #initialization }
MiniDrTests >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	aWindowPresenter
		title: self title;
		initialExtent: 200 @ 200
]

{ #category : #'private - actions' }
MiniDrTests >> switchToDrTest [

	DrTests
		reloadConfiguration: testsConfiguration
		withResults: pluginResult
		andPlugin: currentPlugin
]

{ #category : #actions }
MiniDrTests >> switchUI [

	super switchUI.
	self switchToDrTest
]

{ #category : #accessing }
MiniDrTests >> title [

	^ 'MiniDrTests - ' , currentPlugin pluginName
]

{ #category : #updating }
MiniDrTests >> updateUI [

	super updateUI.
	startButton color: self evaluateBackgroundColor.
	startButton label: pluginResult summarizeInfo.
	"The next line doesn't work because Spec2 does not handle button label's styles.
	Should be changed at some point"
	startButton label makeAllColor: pluginResult textColor.
]

{ #category : #initialization }
MiniDrTests >> updateWithPluginResult: aPluginResult [
	aPluginResult ifNotNil: [ self updateWithResults: aPluginResult ]
]

{ #category : #initialization }
MiniDrTests >> updateWithResults: results [
	self pluginResult: results.
	self updateUI
]
