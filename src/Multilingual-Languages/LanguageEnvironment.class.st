"
The name multilingualized suggests that you can use multiple language at one time.  This is true, of course, but the system still how to manage the primary language; that provides the interpretation of data going out or coming in from outside world. It also provides how to render strings, as there rendering rule could be different in one language to another, even if the code points in a string is the same.

  Originally, LanguageEnvironment and its subclasses only has class side methods.  After merged with Diego's Babel work, it now has instance side methods.  Since this historical reason, the class side and instance side are not related well.

  When we talk about the interface with the outside of the Squeak world, there are three different ""channels""; the keyboard input, clipboard output and input, and filename.  On a not-to-uncommon system such as a Unix system localized to Japan, all of these three can have (and does have) different encodings.  So we need to manage them separately.  Note that the encoding in a file can be anything.  While it is nice to provide a suggested guess for this 'default system file content encoding', it is not critical.

  Rendering support is limited basic L-to-R rendering so far.  But you can provide different line-wrap rule, at least.

"
Class {
	#name : #LanguageEnvironment,
	#superclass : #Object,
	#instVars : [
		'id'
	],
	#classVars : [
		'ClipboardInterpreterClass',
		'Current',
		'FileNameConverter',
		'InputInterpreterClass',
		'KnownEnvironments',
		'SystemConverter'
	],
	#category : #'Multilingual-Languages-Environments'
}

{ #category : #accessing }
LanguageEnvironment class >> canBeGlobalVarInitial: char [

	^ Unicode canBeGlobalVarInitial: char.

]

{ #category : #accessing }
LanguageEnvironment class >> canBeNonGlobalVarInitial: char [

	^ Unicode canBeNonGlobalVarInitial: char.

]

{ #category : #initialization }
LanguageEnvironment class >> clearDefault [
	SystemConverter := nil.
	FileNameConverter := nil.

]

{ #category : #accessing }
LanguageEnvironment class >> currentPlatform [

	| localeClass |
	"A minimal (headless) image has LanguageEnvironment but not Locale!"
	localeClass := self environment 
		at: #Locale 
		ifAbsent: [self error: 'Locale is missing from the environment!'].
	^ localeClass currentPlatform languageEnvironment.

]

{ #category : #'public query' }
LanguageEnvironment class >> defaultFileNameConverter [
	FileNameConverter
		ifNil: [FileNameConverter := self currentPlatform class fileNameConverterClass new].
	^ FileNameConverter
]

{ #category : #'public query' }
LanguageEnvironment class >> defaultSystemConverter [
	SystemConverter
		ifNil: [ SystemConverter := self currentPlatform class systemConverterClass new ].
	^ SystemConverter
]

{ #category : #accessing }
LanguageEnvironment class >> digitValueOf: char [
	"Answer 0-9 if the receiver is $0-$9, 10-35 if it is $A-$Z, and < 0
	otherwise. This is used to parse literal numbers of radix 2-36."

	^ Unicode digitValueOf: char.
]

{ #category : #'subclass responsibilities' }
LanguageEnvironment class >> fileNameConverterClass [

	^UTF8TextConverter
]

{ #category : #private }
LanguageEnvironment class >> initKnownEnvironments [
	"LanguageEnvironment initKnownEnvironments"

	| known localeIdClass |
	localeIdClass := self localeIdClass.
	known := Dictionary new.
	self allSubclassesDo: [:subClass | 
		subClass supportedLanguages do: [:language | | env id | 
			env := subClass new.
			id := localeIdClass isoString: language.
			env localeID: id.
			known at: id put: env]].
	^known
]

{ #category : #initialization }
LanguageEnvironment class >> initialize [
	"LanguageEnvironment initialize"

	SessionManager default 
		registerSystemClassNamed: #LanguageEnvironment "prevent subclasses from registering themselves"
]

{ #category : #'rendering support' }
LanguageEnvironment class >> isBreakableAt: index in: text [

	| char |
	char := text at: index.
	char = Character space ifTrue: [^ true].
	char = Character cr ifTrue: [^ true].
	^ false.

]

{ #category : #accessing }
LanguageEnvironment class >> isCharset [

	^ false.

]

{ #category : #accessing }
LanguageEnvironment class >> isDigit: char [

	^ Unicode isDigit: char.

]

{ #category : #accessing }
LanguageEnvironment class >> isLetter: char [

	^ Unicode isLetter: char.

]

{ #category : #accessing }
LanguageEnvironment class >> isLowercase: char [

	^ Unicode isLowercase: char.

]

{ #category : #accessing }
LanguageEnvironment class >> isUppercase: char [

	^ Unicode isUppercase: char.

]

{ #category : #private }
LanguageEnvironment class >> knownEnvironments [
	"LanguageEnvironment knownEnvironments"
	"KnownEnvironments := nil"

	^KnownEnvironments ifNil: [KnownEnvironments := self initKnownEnvironments]
]

{ #category : #'subclass responsibilities' }
LanguageEnvironment class >> leadingChar [

	self subclassResponsibility.
	^ 0.

]

{ #category : #'system startup' }
LanguageEnvironment class >> localeChanged [
	self startUp
]

{ #category : #accessing }
LanguageEnvironment class >> localeID: localeID [

	self knownEnvironments
		at: localeID ifPresent: [:value | ^ value ];
		at: self localeIdClass default ifPresent: [ :value | ^ value ].
	
	"Something is wrong"
	self resetKnownEnvironments.
	"Try again with freshly initialized cache"
	^ self localeID: localeID
]

{ #category : #accessing }
LanguageEnvironment class >> localeIdClass [
	"A minimal (headless) image has LanguageEnvironment but not LocaleID!
	 See https://github.com/pharo-project/pharo/issues/3844"

	^self environment 
		at: #LocaleID 
		ifAbsent: [self error: 'LocaleID is not present in this image!'].
]

{ #category : #initialization }
LanguageEnvironment class >> resetKnownEnvironments [
	"LanguageEnvironment resetKnownEnvironments"

	KnownEnvironments := nil
]

{ #category : #'language methods' }
LanguageEnvironment class >> scanSelector [

	^ #scanMultiCharactersFrom:to:in:rightX:stopConditions:kern:

]

{ #category : #'system startup' }
LanguageEnvironment class >> startUp [
	self clearDefault.
]

{ #category : #'subclass responsibilities' }
LanguageEnvironment class >> supportedLanguages [
	"Return the languages that this class supports. 
	Any translations for those languages will use this class as their environment."
	self subclassResponsibility
]

{ #category : #'subclass responsibilities' }
LanguageEnvironment class >> systemConverterClass [

	self subclassResponsibility.
	^ Latin1TextConverter.

]

{ #category : #accessing }
LanguageEnvironment >> isoCountry [
	^self localeID isoCountry
]

{ #category : #accessing }
LanguageEnvironment >> isoLanguage [
	^self localeID isoLanguage
]

{ #category : #accessing }
LanguageEnvironment >> leadingChar [
	^self class leadingChar
]

{ #category : #accessing }
LanguageEnvironment >> localeID [
	^id
]

{ #category : #initialization }
LanguageEnvironment >> localeID: anID [
	id := anID
]
