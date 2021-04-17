Class {
	#name : #SpCodePopoverPrintPresenterTest,
	#superclass : #TestCase,
	#instVars : [
		'presenter'
	],
	#category : #'Spec2-Code-Tests'
}

{ #category : #'as yet unclassified' }
SpCodePopoverPrintPresenterTest >> naturalSizeOf: string [
	| stringMorph width height |

	"This is an incredible ugly hack because what should be the correct way of doing it: 
	 Font>>widthOfString: does not works (because it fails to take into account kerning).
	 Why it works on the Editing area is a mystery. 
	 BUT! It does not work for monospaced fonts! (again, no idea why)"
	stringMorph := RubEditingArea new 
		font: StandardFonts defaultFont;
		updateTextWith: string asString.

	width := stringMorph width + 12" min: self currentWorld width / 3".
	height := ((stringMorph
		beWrapped;
		width: width;
		yourself) height + 2).
		
	^ width @ height
]

{ #category : #running }
SpCodePopoverPrintPresenterTest >> setUp [

	super setUp.
	presenter := SpCodePopoverPrintPresenter new
]

{ #category : #tests }
SpCodePopoverPrintPresenterTest >> testObjectAsString [
	| string |

	presenter setModelBeforeInitialization: 10 factorial. 
	self 
		assert: presenter objectAsString 
		equals: '3628800'.

	presenter setModelBeforeInitialization: 42 factorial. 
	self 
		assert: presenter objectAsString 
		equals: '1405006117752879898543142606244511569936384000000000'.

	presenter setModelBeforeInitialization: 150 factorial.
	self 
		assert: presenter objectAsString 
		equals: (String streamContents: [ :stream | 
			(150 factorial asString 
				groupsOf: presenter class maxLengthShownInPopover)
				do: [ :each | stream << each ]
				separatedBy: [ stream cr ] ]).	
		
	string := String loremIpsum withNoLineLongerThan: presenter class maxLengthShownInPopover.
	presenter setModelBeforeInitialization: string.
	self 
		assert: presenter objectAsString 
		equals: string printString.
		
	string := String loremIpsum withNoLineLongerThan: 10.
	presenter setModelBeforeInitialization: string.
	self 
		assert: presenter objectAsString 
		equals: string printString
]

{ #category : #tests }
SpCodePopoverPrintPresenterTest >> testPopoverPopupTextTakesExtentFromPresenter [
	| window popover string naturalSize |

	[
		window := SpLabelPresenter new openWithSpec.
		string := String loremIpsum withNoLineLongerThan: 80.
		presenter := SpCodePopoverPrintPresenter on: string.
		popover := window presenter newPopover
			bePositionRight;
			presenter: presenter;
			popup.
		MorphicRenderLoop new doOneCycle.	

		naturalSize := self naturalSizeOf: string.
		self 
			assert: popover adapter widget width >= naturalSize x;
			assert: popover adapter widget height >= naturalSize y ]
	ensure: [ 
		popover dismiss.
		window close ]
]
