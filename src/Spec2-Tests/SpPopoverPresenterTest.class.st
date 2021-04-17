Class {
	#name : #SpPopoverPresenterTest,
	#superclass : #SpSmokeTest,
	#category : #'Spec2-Tests-Core-Widgets'
}

{ #category : #running }
SpPopoverPresenterTest >> classToTest [
	
	
	^ SpPopoverPresenter
]

{ #category : #running }
SpPopoverPresenterTest >> initializeTestedInstance [

	presenter presenter: (SpPresenter new 
		layout: (SpBoxLayout newTopToBottom
			add: 'Test Popover';
			add: (presenter newButton label: 'Button');
			yourself);
		yourself)
]

{ #category : #tests }
SpPopoverPresenterTest >> testPopoverPopupTakesExtentFromPresenter [

	[
		window := SpLabelPresenter new openWithSpec.
		presenter 
			relativeTo: window;
			popup.
		MorphicRenderLoop new doOneCycle.	
		self 
			assert: presenter adapter widget width >= presenter presenter adapter widget width;
			assert: presenter adapter widget height >= presenter presenter adapter widget height. ]
	ensure: [ 
		presenter dismiss ]
]

{ #category : #tests }
SpPopoverPresenterTest >> testPopoverPopupTextTakesExtentFromPresenter [

	[
		window := SpLabelPresenter new openWithSpec.
		presenter 
			bePositionRight;
			presenter: (presenter newText 
				beNotWrapWord;
				propagateNaturalWidth: true;
				propagateNaturalHeight: true;
				editable: false;
				text: (String loremIpsum withNoLineLongerThan: 80);
				yourself);
			relativeTo: window;
			popup.
		MorphicRenderLoop new doOneCycle.	

		self 
			assert: presenter adapter widget width >= presenter presenter adapter widget width;
			assert: presenter adapter widget height >= presenter presenter adapter widget height. ]
	ensure: [ 
		presenter dismiss ]
]

{ #category : #tests }
SpPopoverPresenterTest >> testPopoverTakesExtentFromPresenter [

	self openInstance.
	
	self 
		assert: presenter adapter widget width >= presenter presenter adapter widget width;
		assert: presenter adapter widget height >= presenter presenter adapter widget height.
]
