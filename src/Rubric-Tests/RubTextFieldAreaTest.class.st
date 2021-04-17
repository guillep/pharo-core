Class {
	#name : #RubTextFieldAreaTest,
	#superclass : #TestCase,
	#category : #'Rubric-Tests-Editing-Core'
}

{ #category : #utilities }
RubTextFieldAreaTest >> simulatedKeyDownFromChar: aCharacter [

	^ self simulatedKeyDownFromChar: aCharacter alt: false ctrl: false command: false shift: false
]

{ #category : #utilities }
RubTextFieldAreaTest >> simulatedKeyDownFromChar: aCharacter alt: useAlt ctrl: useCtrl command: useCommand shift: useShift [
	| event modifier code |
	event := KeyboardEvent new.
	modifier := 0.
	useShift
		ifTrue: [ modifier := modifier + 8 ].
	useCtrl
		ifTrue: [ modifier := modifier + 16 ].
	useAlt
		ifTrue: [ modifier := modifier + 32 ].
	useCommand
		ifTrue: [ modifier := modifier + 64 ].
	code := aCharacter asInteger.
	event
		setType: #keyDown
		buttons: modifier
		position: 0 @ 0
		keyValue: code
		charCode: code
		hand: self currentWorld currentHand 
		stamp: Time now.
	event key: (KeyboardKey fromCharacter: aCharacter).
	^ event
]

{ #category : #utilities }
RubTextFieldAreaTest >> simulatedKeyStrokeFromChar: aCharacter [

	^ self simulatedKeyStrokeFromChar: aCharacter alt: false ctrl: false command: false shift: false
]

{ #category : #utilities }
RubTextFieldAreaTest >> simulatedKeyStrokeFromChar: aCharacter alt: useAlt ctrl: useCtrl command: useCommand shift: useShift [
	| event modifier code |
	event := KeyboardEvent new.
	modifier := 0.
	useShift
		ifTrue: [ modifier := modifier + 8 ].
	useCtrl
		ifTrue: [ modifier := modifier + 16 ].
	useAlt
		ifTrue: [ modifier := modifier + 32 ].
	useCommand
		ifTrue: [ modifier := modifier + 64 ].
	code := aCharacter asInteger.
	event
		setType: #keystroke
		buttons: modifier
		position: 0 @ 0
		keyValue: code
		charCode: code
		hand: self currentWorld currentHand 
		stamp: Time now.
	^ event
]

{ #category : #tests }
RubTextFieldAreaTest >> testInsertionWithMaxLength [
	| m |
	m := RubTextFieldArea new
		width: 300;
		maxLength: 3;
		yourself.
	self assert: m string isEmpty.
	m privateReplaceFrom: 1 to: 0 with: 'AAA'.
	self assert: m string equals: 'AAA'.
	m privateReplaceFrom: 1 to: 3 with: 'BBB'.
	self assert: m string equals: 'BBB'.
	m privateReplaceFrom: 3 to: 3 with: 'CCC'.
	self assert: m string equals: 'BBC'.
	m privateReplaceFrom: 3 to: 2 with: 'DDD'.
	self assert: m string equals: 'BBD'
]

{ #category : #tests }
RubTextFieldAreaTest >> testKeyStrokeBackSpaceWithMaxLength [
	| m |
	m := RubTextFieldArea new
		width: 300;
		maxLength: 2;
		yourself.
	self assert: m string size equals: 0.
	m handleEvent: (self simulatedKeyStrokeFromChar: $a).
	self assert: m string equals: 'a'.
	m handleEvent: (self simulatedKeyStrokeFromChar: $b).
	self assert: m string equals: 'ab'.
	m handleEvent: (self simulatedKeyDownFromChar: Character backspace).
	self assert: m string equals: 'a'.
	m handleEvent: (self simulatedKeyStrokeFromChar: $c).
	self assert: m string equals: 'ac'.
	m handleEvent: (self simulatedKeyStrokeFromChar: $d).
	self assert: m string equals: 'ac'
]

{ #category : #tests }
RubTextFieldAreaTest >> testKeyStrokeWithMaxLength [
	| m |
	m := RubTextFieldArea new
		width: 300;
		maxLength: 0;
		yourself.
	self assert: m string isEmpty.
	m handleEvent: (self simulatedKeyStrokeFromChar: $a).
	self assert: m string isEmpty.
	m maxLength: 2.
	m keyStroke: (self simulatedKeyStrokeFromChar: $a).
	self assert: m string equals: 'a'.
	m keyStroke: (self simulatedKeyStrokeFromChar: $b).
	self assert: m string equals: 'ab'.
	m keyStroke: (self simulatedKeyStrokeFromChar: $c).
	self assert: m string equals: 'ab'.
]

{ #category : #tests }
RubTextFieldAreaTest >> testMaxLengthIsNegative [
	| m |
	m := RubTextFieldArea new
		width: 300;
		maxLength: -10;
		yourself.
	m setTextWith: '01234567890123456'.
	self assert: m text size equals: 0.

]

{ #category : #tests }
RubTextFieldAreaTest >> testMaxLengthIsSet [
	| m |
	m := RubTextFieldArea new
		width: 300;
		maxLength: 15;
		yourself.
	self assert: m maxLength equals: 15
]

{ #category : #tests }
RubTextFieldAreaTest >> testMaxLengthTruncatesText [
	| m |
	m := RubTextFieldArea new
		width: 300;
		maxLength: 15;
		yourself.
	m setTextWith: '01234567890123456'.
	" the text should be truncated "
	self assert: m text size equals: 15.
	
	" the text is different to ensure that the input is validate and update is sent instead of set "
	m updateTextWith: '7890123456789012345'.
	self assert: m text size equals: 15.
	
	" with a text of size less than maxlength  to check that maxLength has no effect "
	m setTextWith: ''.
	self assert: m text size equals: 0.	
	m setTextWith: 'A'.
	self assert: m text size equals: 1.
	m updateTextWith: ''.
	self assert: m text size equals: 0
]

{ #category : #tests }
RubTextFieldAreaTest >> testPrivateReplaceFromTo [
	| m |
	m := RubTextFieldArea new
		width: 300;
		yourself.
	self assert: m string isEmpty.
	m privateReplaceFrom: 1 to: 0 with: 'AAA'.
	self assert: m string equals: 'AAA'.
	m privateReplaceFrom: 1 to: 3 with: 'BBB'.
	self assert: m string equals: 'BBB'.
	m privateReplaceFrom: 3 to: 3 with: 'CCC'.
	self assert: m string equals: 'BBCCC'.
	m privateReplaceFrom: 3 to: 2 with: 'DDD'.
	self assert: m string equals: 'BBDDDCCC'
]

{ #category : #tests }
RubTextFieldAreaTest >> testReplacementWithMaxLength [
	| m |
	m := RubTextFieldArea new
		width: 300;
		maxLength: 3;
		yourself.
	m setTextWith: 'AAAA'.
	self assert: m string equals: 'AAA'.
	m privateReplaceFrom: 1 to: 3 with: 'BBB'.
	self assert: m string equals: 'BBB'.
	m privateReplaceFrom: 3 to: 3 with: 'CCC'.
	self assert: m string equals: 'BBC'.
	m privateReplaceFrom: 1 to: 3 with: 'XXXXXXXXXXXXXXXXXX'.
	self assert: m string equals: 'XXX'
]

{ #category : #tests }
RubTextFieldAreaTest >> testWhenWeHaveTheRubTextFieldAreaInsideOtherMorphHasToHonorTheExtentAssignedToIt [

	| dropList widthOfButton |

	"The drop list has two morphs inside, one RubTextFieldArea and a Button.
	The button has a fixed side. 
	The text field takes all the remaining size."	
	dropList := DropListMorph new
		     list: { (String loremIpsum: 100) };
		     enabled: true;
		     listSelectionIndex: 1;
		     yourself.

	dropList extent: 100 @ 18.
	dropList computeBounds. 
	
	self assert: dropList extent x equals: 100.

	widthOfButton := (dropList submorphs at: 2) extent x.
	
	"The text area should take the remaining size without overlapping in the button"	
	self assert: (dropList submorphs at: 1) extent x equals: 74.
]

{ #category : #tests }
RubTextFieldAreaTest >> testnewSizeAfterUpdate [
	| m |
	" "
	m := RubTextFieldArea new
		width: 300;
		yourself.
	m setTextWith: ''.
	self assert: m text isEmpty.
	"the  receiver text  size after inserting 'BBB' would be 3"
	self
		assert: (m newSizeAfterUpdateFrom: 1 to: 0 with: 'BBB')
		equals: 3.
	m setTextWith: 'AAAA'.
	self assert: m string equals: 'AAAA'.
	"the receiver text  size after the replacement 'BBB' would be 4 "
	self 
		assert: (m newSizeAfterUpdateFrom: 1 to: 3 with: 'BBB')
		equals: 4.
	self
		assert: (m newSizeAfterUpdateFrom: 1 to: 4 with: 'BBB')
		equals: 3.
	"the receiver text  size after inserting 'BBB' at start  would be 7 "
	self
		assert: (m newSizeAfterUpdateFrom: 1 to: 0 with: 'BBB')
		equals: 7
]
