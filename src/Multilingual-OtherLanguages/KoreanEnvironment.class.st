"
This class provides the Korean support.  Unfortunately, we haven't tested this yet.  We did have a working version in previous implementations, but not this new implementation. But as soon as we find somebody who understand the language, probably we can make it work in two days or so, as we have done for Czech support.
"
Class {
	#name : #KoreanEnvironment,
	#superclass : #LanguageEnvironment,
	#category : #'Multilingual-OtherLanguages-Environments'
}

{ #category : #'class initialization' }
KoreanEnvironment class >> initialize [

	EncodedCharSet declareEncodedCharSet: self atIndex: 7+1.
]

{ #category : #'subclass responsibilities' }
KoreanEnvironment class >> leadingChar [
	
	^ 7
]

{ #category : #'subclass responsibilities' }
KoreanEnvironment class >> supportedLanguages [
	"Return the languages that this class supports. 
	Any translations for those languages will use this class as their environment."
	^#('ko' )
]

{ #category : #'subclass responsibilities' }
KoreanEnvironment class >> systemConverterClass [
	| encoding |
	Smalltalk os isWindows 
		ifTrue: [^EUCKRTextConverter].
	Smalltalk os isMacOS
		ifTrue: [^UTF8TextConverter].
	Smalltalk os isUnix 
		ifTrue: [encoding := X11Encoding encoding.
			encoding ifNil: [^EUCKRTextConverter].
			(encoding = 'utf-8') 
				ifTrue: [^UTF8TextConverter].							
			^EUCKRTextConverter].
	^UTF8TextConverter
]

{ #category : #'language methods' }
KoreanEnvironment class >> traditionalCharsetClass [

	^ KSX1001.

]
