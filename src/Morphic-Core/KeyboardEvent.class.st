"
I am a keyboard event. I contain the char code of the event pressed, the modifiers pressed, and the keycode of the key pressed.
"
Class {
	#name : #KeyboardEvent,
	#superclass : #UserInputEvent,
	#instVars : [
		'keyValue',
		'charCode',
		'scanCode',
		'key',
		'supressNextKeyPress'
	],
	#category : #'Morphic-Core-Events'
}

{ #category : #comparing }
KeyboardEvent >> = aMorphicEvent [
	super = aMorphicEvent ifFalse:[^false].
	buttons = aMorphicEvent buttons ifFalse: [^ false].
	keyValue = aMorphicEvent keyValue ifFalse: [^ false].
	^ true

]

{ #category : #keymapping }
KeyboardEvent >> asKeyCombination [
	^ KMKeyCombination fromKeyboardEvent: self
]

{ #category : #keymapping }
KeyboardEvent >> asShortcut [
	^ self asKeyCombination
]

{ #category : #testing }
KeyboardEvent >> hasSpecialCTRLKeyValue [
"
	4 - Character end
	1 - Character home
"

	^ self controlKeyPressed and: [ keyValue <= 26 & (keyValue ~= 4) & (keyValue ~= 1) ]
]

{ #category : #comparing }
KeyboardEvent >> hash [
	^buttons hash + keyValue hash

]

{ #category : #initialization }
KeyboardEvent >> initialize [

	super initialize.
	supressNextKeyPress := false.
]

{ #category : #testing }
KeyboardEvent >> isKeyDown [
	^self type == #keyDown
]

{ #category : #testing }
KeyboardEvent >> isKeyUp [
	^self type == #keyUp
]

{ #category : #testing }
KeyboardEvent >> isKeyboard [
	^true
]

{ #category : #testing }
KeyboardEvent >> isKeystroke [
	^self type == #keystroke
]

{ #category : #testing }
KeyboardEvent >> isMouseMove [
	^false
]

{ #category : #testing }
KeyboardEvent >> isUserInterrupt [

	^ UserInterruptHandler cmdDotEnabled and: [ self keyCharacter = $. and: [ self commandKeyPressed ] ].
	
]

{ #category : #keyboard }
KeyboardEvent >> key [
	^ key ifNil: [key := Smalltalk os keyForValue: keyValue]
]

{ #category : #keyboard }
KeyboardEvent >> key: aKeyboardKey [
	key := aKeyboardKey
]

{ #category : #keyboard }
KeyboardEvent >> keyCharacter [
	"Answer the character corresponding this keystroke. This is defined only for keystroke events."

	^Unicode value: charCode
]

{ #category : #keyboard }
KeyboardEvent >> keyString [
	"Answer the string value for this keystroke. This is defined only for keystroke events."

	^ String streamContents: [ :s | self printKeyStringOn: s ]
]

{ #category : #keyboard }
KeyboardEvent >> keyValue [
	"Answer the ascii value for this keystroke. This is defined only for keystroke events."

	^ keyValue
]

{ #category : #keymapping }
KeyboardEvent >> modifiedCharacter [
	self flag: #hack.
	"Hack me.  When Ctrl is pressed, the key ascii value is not right and we have to do something ugly"
	^(self hasSpecialCTRLKeyValue and: [ (#(MacOSX Windows) includes: Smalltalk os platformFamily) ])
    	ifTrue: [ (self keyValue + $a asciiValue - 1) asCharacter ]    
		ifFalse: [ 
			Smalltalk os isWindows 
				ifTrue: [ self keyCharacter asLowercase ]
				ifFalse: [ self keyCharacter ] ]
]

{ #category : #printing }
KeyboardEvent >> printKeyStringOn: aStream [
	"Print a readable string representing the receiver on a given stream"

	| kc inBrackets firstBracket keyString |
	kc := self keyCharacter.
	inBrackets := false.
	firstBracket := [ inBrackets ifFalse: [ aStream nextPut: $<. inBrackets := true ]].
	self controlKeyPressed ifTrue: [ 	firstBracket value. aStream nextPutAll: 'Ctrl-' ].
	self commandKeyPressed ifTrue: [ firstBracket value. aStream nextPutAll: 'Cmd-' ].
	(buttons anyMask: 32) ifTrue: [ firstBracket value. aStream nextPutAll: 'Opt-' ].
	(self shiftPressed and: [ keyValue between: 1 and: 31 ])
		ifTrue: [ firstBracket value. aStream nextPutAll: 'Shift-' ].

	self hasSpecialCTRLKeyValue
			ifTrue:
				[aStream nextPut: (keyValue + $a asciiValue - 1) asCharacter]
			ifFalse: 
				[keyString := (kc caseOf: {
					[ Character space ] -> [ ' ' ].
					[ Character tab ] -> [ 'tab' ].
					[ Character cr ] -> [ 'cr' ].
					[ Character lf ] -> [ 'lf' ].
					[ Character enter ] -> [ 'enter' ].

					[ Character backspace ] -> [ 'backspace' ].
					[ Character delete ] -> [ 'delete' ].

					[ Character escape ] -> [ 'escape' ].

					[ Character arrowDown ] -> [ 'down' ].
					[ Character arrowUp ] -> [ 'up' ].
					[ Character arrowLeft ] -> [ 'left' ].
					[ Character arrowRight ] -> [ 'right' ].

					[ Character end ] -> [ 'end' ].
					[ Character home ] -> [ 'home' ].
					[ Character pageDown ] -> [ 'pageDown' ].
					[ Character pageUp ] -> [ 'pageUp' ].

					[ Character euro ] -> [ 'euro' ].
					[ Character insert ] -> [ 'insert' ].

				} otherwise: [ String with: kc ]).
				keyString size > 1 ifTrue: [ firstBracket value ].
				aStream nextPutAll: keyString].

	inBrackets ifTrue: [aStream nextPut: $> ]
]

{ #category : #printing }
KeyboardEvent >> printOn: aStream [
	"Print the receiver on a stream"

	aStream nextPut: $[.
	aStream nextPutAll: type; nextPutAll: ' '''.
	self printKeyStringOn: aStream.
	aStream nextPut: $'.
	aStream nextPut: $]
]

{ #category : #keyboard }
KeyboardEvent >> scanCode [
	^scanCode
]

{ #category : #initialize }
KeyboardEvent >> scanCode: anInt [
	scanCode := anInt
]

{ #category : #dispatching }
KeyboardEvent >> sentTo: anObject [
	"Dispatch the receiver into anObject"
	type == #keystroke ifTrue:[^anObject handleKeystroke: self].
	type == #keyDown ifTrue:[^anObject handleKeyDown: self].
	type == #keyUp ifTrue:[^anObject handleKeyUp: self].
	^super sentTo: anObject.
]

{ #category : #private }
KeyboardEvent >> setType: aSymbol buttons: anInteger position: pos keyValue: aValue charCode: anInt hand: aHand stamp: stamp [
	type := aSymbol.
	buttons := anInteger.
	position := pos.
	keyValue := aValue.
	charCode := anInt.
	source := aHand.
	wasHandled := false.
	timeStamp := stamp.
]

{ #category : #private }
KeyboardEvent >> setType: aSymbol buttons: anInteger position: pos keyValue: aValue hand: aHand stamp: stamp [
	type := aSymbol.
	buttons := anInteger.
	position := pos.
	keyValue := aValue.
	source := aHand.
	wasHandled := false.
	timeStamp := stamp.
]

{ #category : #printing }
KeyboardEvent >> storeOn: aStream [

	aStream nextPutAll: type.
	aStream space.
	self timeStamp storeOn: aStream.
	aStream space.
	position x asInteger storeOn: aStream.
	aStream space.
	position y asInteger storeOn: aStream.
	aStream space.
	buttons storeOn: aStream.
	aStream space.
	keyValue storeOn: aStream.
	aStream space.
	charCode storeOn: aStream.
	aStream space.
	scanCode storeOn: aStream.
]

{ #category : #accessing }
KeyboardEvent >> supressNextKeyPress [

	^ supressNextKeyPress
]

{ #category : #accessing }
KeyboardEvent >> supressNextKeyPress: anObject [

	supressNextKeyPress := anObject
]

{ #category : #accessing }
KeyboardEvent >> wasHandled [

	^ super wasHandled or: [ supressNextKeyPress ]
]
