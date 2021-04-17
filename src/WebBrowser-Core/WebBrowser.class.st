"
General access to a webbrowser
"
Class {
	#name : #WebBrowser,
	#superclass : #Object,
	#category : #'WebBrowser-Core-Base'
}

{ #category : #examples }
WebBrowser class >> example [

	self openOn: 'http://pharo.org'
]

{ #category : #testing }
WebBrowser class >> isForCurrentSystem [

	^self subclassResponsibility 
]

{ #category : #testing }
WebBrowser class >> isUsed [
	"all my subclasses are used by me"
	
	^self name = #WebBrowser
		ifTrue: [ super isUsed ]
		ifFalse: [ true ]
]

{ #category : #private }
WebBrowser class >> openNativeWebBrowserOn: aURLString [

	self subclassResponsibility
]

{ #category : #'instance creation' }
WebBrowser class >> openOn: anURLOrString [
	"Open the webbrowser on the given URL or String"
	
	^self webbrowserClassForPlatform 
				openNativeWebBrowserOn: anURLOrString asString

]

{ #category : #'private - accessing' }
WebBrowser class >> webbrowserClassForPlatform [

  ^ self allSubclasses 
				detect: #isForCurrentSystem 
				ifNone: [ self error: 'No web browser subclass for platform provided' ]
]
