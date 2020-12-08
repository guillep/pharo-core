"
This class provides the support for the languages in 'Latin-9' category.
"
Class {
	#name : #Latin9Environment,
	#superclass : #LanguageEnvironment,
	#category : #'Multilingual-Languages-Environments'
}

{ #category : #'class initialization' }
Latin9Environment class >> initialize [

	EncodedCharSet declareEncodedCharSet: self atIndex: 17+1.
]

{ #category : #'subclass responsibilities' }
Latin9Environment class >> leadingChar [

	^0
]

{ #category : #'subclass responsibilities' }
Latin9Environment class >> supportedLanguages [
	"Return the languages that this class supports. 
	Any translations for those languages will use this class as their environment."
	
	^#('hu' 'sl' 'hr' 'ro' 'cs' 'sk')
]

{ #category : #'subclass responsibilities' }
Latin9Environment class >> systemConverterClass [

	Smalltalk os isWindows 
		ifTrue: [^CP1252TextConverter ].

	^ ISO885915TextConverter.

]
