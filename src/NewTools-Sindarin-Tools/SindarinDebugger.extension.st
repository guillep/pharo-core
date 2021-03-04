Extension { #name : #SindarinDebugger }

{ #category : #'*NewTools-Sindarin-Tools' }
SindarinDebugger class >> debuggerExtensionKey [
	^ #sindarin
]

{ #category : #'*NewTools-Sindarin-Tools' }
SindarinDebugger >> debuggerExtensionKey [
	^self class debuggerExtensionKey
]

{ #category : #'*NewTools-Sindarin-Tools' }
SindarinDebugger >> inspectionSindarinDebugger [
	<inspectorPresentationOrder: -10 title: 'Sindarin'>

	^ StSindarinDebuggerPresenter on: self
]

{ #category : #'*NewTools-Sindarin-Tools' }
SindarinDebugger >> open [
	"Open this debugger and the execution it is debugging in a graphical window"
	"<inspectorPresentationOrder: -10 title: 'Sindarin'>"

	| a |
	a := (StSindarinDebuggerPresenter on: self) openWithSpec.
	a window extent: 550@350.
]
