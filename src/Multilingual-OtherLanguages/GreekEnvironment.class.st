"
This class provides the support for Greek.  It is here, but most of the methods are not implemented yet.

"
Class {
	#name : #GreekEnvironment,
	#superclass : #LanguageEnvironment,
	#category : #'Multilingual-OtherLanguages-Environments'
}

{ #category : #'class initialization' }
GreekEnvironment class >> initialize [

	EncodedCharSet declareEncodedCharSet: self atIndex: 13+1.
]

{ #category : #'subclass responsibilities' }
GreekEnvironment class >> leadingChar [

	^0
]

{ #category : #'subclass responsibilities' }
GreekEnvironment class >> supportedLanguages [
	"Return the languages that this class supports. 
	Any translations for those languages will use this class as their environment."
	
	^#('el' )
]

{ #category : #'subclass responsibilities' }
GreekEnvironment class >> systemConverterClass [

	Smalltalk os isWindows
		ifTrue: [^CP1253TextConverter ].
	^ ISO88597TextConverter.

]
