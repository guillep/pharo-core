"
This class provides the support for the languages in 'Latin-1' category.  Although we could have different language environments for different languages in the category, so far nobody seriously needed it.

"
Class {
	#name : #Latin1Environment,
	#superclass : #LanguageEnvironment,
	#category : #'Multilingual-Languages-Environments'
}

{ #category : #'subclass responsibilities' }
Latin1Environment class >> leadingChar [

	^ 0.

]

{ #category : #'language methods' }
Latin1Environment class >> nextPutRightHalfValue: ascii toStream: aStream withShiftSequenceIfNeededForTextConverterState: state [

	^ self traditionalCharsetClass nextPutRightHalfValue: ascii toStream: aStream withShiftSequenceIfNeededForTextConverterState: state.

]

{ #category : #'language methods' }
Latin1Environment class >> nextPutValue: ascii toStream: aStream withShiftSequenceIfNeededForTextConverterState: state [

	^ self traditionalCharsetClass nextPutValue: ascii toStream: aStream withShiftSequenceIfNeededForTextConverterState: state.
]

{ #category : #'subclass responsibilities' }
Latin1Environment class >> supportedLanguages [
	"Return the languages that this class supports. 
	Any translations for those languages will use this class as their environment."
	
	^#('fr' 'es' 'ca' 'eu' 'pt' 'it' 'sq' 'rm' 'nl' 'de' 'da' 'sv' 'no' 'fi' 'fo' 'is' 'ga' 'gd' 'en' 'af' 'sw')
]

{ #category : #'subclass responsibilities' }
Latin1Environment class >> systemConverterClass [
	Smalltalk os isWindows
		ifTrue: [^ UTF8TextConverter].
 	Smalltalk os isMacOSX
		ifTrue: [ ^ UTF8TextConverter ].
	Smalltalk os isMacOS
		ifTrue: [^MacRomanTextConverter].
       Smalltalk os isUnix
              ifTrue: [^ UTF8TextConverter].
       ^ Latin1TextConverter 
]

{ #category : #'language methods' }
Latin1Environment class >> traditionalCharsetClass [

	^ Latin1.

]
