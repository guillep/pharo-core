"
This is a private class for handling clipboard text. There's no direct use of it.
For setting/retrieving clipboard text, use clipboardText/clipboardText: accessors of OSWindow instances.
"
Class {
	#name : #OSWindowClipboard,
	#superclass : #Clipboard,
	#category : #'OSWindow-Core-Base'
}

{ #category : #accessing }
OSWindowClipboard >> beDefault [

	Default := self
]

{ #category : #accessing }
OSWindowClipboard >> chooseRecentClipping [
	^ nil
]

{ #category : #accessing }
OSWindowClipboard >> clipboardText [
	^ self worldRenderer clipboardText withInternalLineEndings
]

{ #category : #accessing }
OSWindowClipboard >> clipboardText: aString [
	self worldRenderer clipboardText: aString asString
]

{ #category : #private }
OSWindowClipboard >> noteRecentClipping: text [
]

{ #category : #accessing }
OSWindowClipboard >> worldRenderer [ 

	^ self currentWorld worldState worldRenderer
	
]
