"
This class provides the support for the languages in 'Latin-2' category.  Although we could have different language environments for different languages in the category, so far nobody seriously needed it.

  I (Yoshiki) don't have good knowledge in these language, so when Pavel Krivanek volunteered to implement the detail, it was a good test to see how flexible my m17n framework was.  There are a few glitches, but with several email conversations over a few days, we managed to make it work relatively painlessly.  I thought this went well.

  There seem that some source of headache, as Windows doesn't exactly use Latin-2 encoded characters, but a little modified version called 'code page 1250'.  Similar to Japanese support, the encode interpreters are swapped based on the type of platform it is running on.


"
Class {
	#name : #Latin2Environment,
	#superclass : #LanguageEnvironment,
	#category : #'Multilingual-Languages-Environments'
}

{ #category : #'class initialization' }
Latin2Environment class >> initialize [


	EncodedCharSet declareEncodedCharSet: self atIndex: 14+1.
]

{ #category : #'subclass responsibilities' }
Latin2Environment class >> leadingChar [

	^0
]

{ #category : #'subclass responsibilities' }
Latin2Environment class >> supportedLanguages [
	"Return the languages that this class supports. 
	Any translations for those languages will use this class as their environment."
	
	^#('cs' 'hu' 'ro' 'hr' 'sk' 'sl')  "Sorbian languages don't have two char code?"

]

{ #category : #'subclass responsibilities' }
Latin2Environment class >> systemConverterClass [

	Smalltalk os isWindows 
		ifTrue: [^CP1250TextConverter ].

	^ ISO88592TextConverter.

]
