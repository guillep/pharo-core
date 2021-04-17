"
SUnit tests for key mapping shortcuts
"
Class {
	#name : #KMShortcutTest,
	#superclass : #AbstractKeymappingTest,
	#category : #'Keymapping-Tests'
}

{ #category : #tests }
KMShortcutTest >> testAsString [
	self assert: $a asShortcut asString equals: 'A'.
	self assert: $A asShortcut asString equals: 'Shift + A'.
	self assert: $a ctrl asString equals: 'Ctrl + A'.
	self assert: $A ctrl asString equals: 'Shift + Ctrl + A'.
	self assert: $A command asString equals: 'Shift + Cmd + A'.
	self assert: $A alt asString equals: 'Shift + Alt + A'.
	self assert: $b command asString equals: 'Cmd + B'.
	self assert: $c shift asString equals: 'Shift + C'.
	self assert: $d alt asString equals: 'Alt + D'.
	self assert: $e ctrl command asString equals: (KMCtrlModifier new asString ,' + ' , KMCommandModifier new asString,' + E')
	
	

]

{ #category : #tests }
KMShortcutTest >> testBadComposedCmdShortcutFails [
	^ self should: [ KMModifier ctrl ctrl ] raise: Error
]

{ #category : #tests }
KMShortcutTest >> testChainIntegerSucceds [
	^ self assert: ($e ctrl , 1) equals: ($e ctrl , 1)
]

{ #category : #tests }
KMShortcutTest >> testChainShortcutSucceds [
	^ self assert: ($e ctrl , $e ctrl) equals: ($e ctrl , $e ctrl)
]

{ #category : #tests }
KMShortcutTest >> testChainSimpleCharsSucceds [
	^ self assert: ($e ctrl , $e) equals: ($e ctrl , $e)
]

{ #category : #tests }
KMShortcutTest >> testCmdIntegerSucceds [
	^ self assert: 1 ctrl equals: 1 ctrl
]

{ #category : #tests }
KMShortcutTest >> testCmdKeySucceds [
	^ self assert: $e ctrl equals: $e ctrl
]

{ #category : #tests }
KMShortcutTest >> testCmdShiftSucceds [
	^ self assert: ($1 shift ctrl matches: {self eventKey: $1 alt: false ctrl: true command: false shift: true})
]

{ #category : #tests }
KMShortcutTest >> testComplexChainMatches [
	|eCtrl eShift f|
	
	f := self eventKey: $f.
	eCtrl := self eventKey: $e ctrl: true.
	eShift := self eventKey: $e shift: true.
		
	self assert: (($e ctrl, $e shift, $f) matches: {eCtrl}).
	self assert: (($e ctrl, $e shift, $f) matches: {eCtrl. eShift}).
	self assert: (($e ctrl, $e shift, $f) matches: {eCtrl. eShift. f}).

	self deny: (($e ctrl, $e shift, $f) matchesCompletely: {eCtrl}).
	self deny: (($e ctrl, $e shift, $f) matchesCompletely: {eCtrl. eShift}).
	self assert: (($e ctrl, $e shift, $f) matchesCompletely: {eCtrl. eShift. f})
]

{ #category : #tests }
KMShortcutTest >> testCreation [
	self assert: ($e asKeyCombination isKindOf: KMSingleKeyCombination).
	self assert: ($e ctrl isKindOf: KMModifiedKeyCombination).
	self assert: ($e ctrl alt shift command isKindOf: KMModifiedKeyCombination).
]

{ #category : #tests }
KMShortcutTest >> testEventCodes [
	self assert: $s meta modifier eventCode 
		  equals: OSPlatform current defaultModifier eventCode 
]

{ #category : #tests }
KMShortcutTest >> testModifiedShortcutsMatch [
	|a oneShift oneCommand oneCommandShift|
	
	a := self eventKey: $a ctrl: true.
	oneShift := self eventKey: $1 shift: true.
	oneCommand := self eventKey: $1 command: true.
	oneCommandShift := self eventKey: $1 alt: false ctrl: false command: true shift: true.
	
	self assert: ($a ctrl matches: {a}).
	self assert: ($1 shift matches: {oneShift}).
	self assert: ($1 command matches: {oneCommand}).
	self assert: ($1 command shift matches: {oneCommandShift}).
	
	self deny: ($a ctrl matches: {self eventKey: $a command: true}).
	
	self deny: ($i command shift matches: {self eventKey: $i command: true}).
	self assert: ($i ctrl shift matches: {self eventKey: $i alt: false ctrl: true command: false shift: true}).
	self deny: ($i ctrl matches: {self eventKey: $i alt: false ctrl: true command: false shift: true}).
	
	self assert: ($a ctrl matchesCompletely: {a}).
	self assert: ($1 shift matchesCompletely: {oneShift}).
	self assert: ($1 command matchesCompletely: {oneCommand}).
	self assert: ($1 command shift matchesCompletely: {oneCommandShift})
]

{ #category : #tests }
KMShortcutTest >> testShiftKeySucceds [
	^ self assert: $e shift equals: $e shift
]

{ #category : #tests }
KMShortcutTest >> testSimpleChainMatches [
	|e eCtrl |
	e := self eventKey: $e.
	eCtrl := self eventKey: $e ctrl: true.
	
	self assert: (($e ctrl, $e) matches: {eCtrl}).
	
	"A full shortcut should not match a bigger buffer ever"
	self deny: ($e ctrl matches: {eCtrl. e}).
	
	self deny: (($e ctrl, $e) matches: {eCtrl. self eventKey: $a}).
	self deny: ($e ctrl matches: {e})
]

{ #category : #tests }
KMShortcutTest >> testSingleShortcutsMatch [
	|a one home |
	a := self eventKey: $a.
	one := self eventKey: 1 asCharacter.
	home := self eventKey: Character home.
	
	self assert: ($a asKeyCombination matches: {a}).
	self assert: (1 asKeyCombination matches: {one}).
	self assert: (Character home asKeyCombination matches: {home}).
	
	self deny: ($b asKeyCombination matches: {a}).
	
	self assert: ($a asKeyCombination matchesCompletely: {a}).
	self assert: (1 asKeyCombination matchesCompletely: {one})
]

{ #category : #tests }
KMShortcutTest >> testTripleChainShortcutSucceds [
	^ self assert: ($e ctrl , $e ctrl , $d ctrl) equals: ($e ctrl , $e ctrl , $d ctrl)
]
