"
Main comment stating the purpose of this class and relevant relationship to other classes.



	http://www.w3.org/WAI/ER/IG/ert/iso639.htm
	http://www.oasis-open.org/cover/iso639a.html
	See also
	http://oss.software.ibm.com/cvs/icu/~checkout~/icuhtml/design/language_code_issues.html
	http://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html#sec3.10
	
ISO 3166
http://mitglied.lycos.de/buran/knowhow/codes/locales/

"
Class {
	#name : #Locale,
	#superclass : #Object,
	#instVars : [
		'id'
	],
	#classVars : [
		'Activated',
		'Current',
		'CurrentPlatform',
		'KnownLocales',
		'LanguageSymbols',
		'PlatformEncodings'
	],
	#classInstVars : [
		'localeAnnouncer'
	],
	#category : #'System-Localization-Locales'
}

{ #category : #settings }
Locale class >> activated [
	^ Activated ifNil: [Activated := false]
]

{ #category : #settings }
Locale class >> activated: aBoolean [
	Activated := aBoolean
]

{ #category : #accessing }
Locale class >> current [
	"Current := nil"
	Current ifNil: [
		Current := self determineCurrentLocale.
		"Transcript show: 'Current locale: ' , Current localeID asString; cr"].
	^Current
]

{ #category : #accessing }
Locale class >> currentPlatform [
	"CurrentPlatform := nil"
	CurrentPlatform ifNil: [CurrentPlatform := self determineCurrentLocale].
	^CurrentPlatform
]

{ #category : #accessing }
Locale class >> currentPlatform: locale [

	CurrentPlatform := locale

]

{ #category : #accessing }
Locale class >> currentPlatform: locale during: aBlock [ 
	"Alter current language platform during a block"
	| backupPlatform |
	backupPlatform := self currentPlatform.
	[self currentPlatform: locale.
	aBlock value]
		ensure: [self currentPlatform: backupPlatform]
]

{ #category : #'platform specific' }
Locale class >> defaultEncodingName: languageSymbol [ 
	| encodings platformName osVersion |
	platformName := Smalltalk os platformName.
	osVersion := Smalltalk os version.
	encodings := self platformEncodings at: languageSymbol
				ifAbsent: [self platformEncodings at: #default].
	encodings at: platformName ifPresent: [:encoding | ^encoding].
	encodings at: platformName , ' ' , osVersion
		ifPresent: [:encoding | ^encoding].
	^encodings at: #default
]

{ #category : #private }
Locale class >> defaultLocales [
	
	"return IDs of default locales"
	
	^ #(de en ja 'ja-kids' nl no sv)
]

{ #category : #private }
Locale class >> determineCurrentLocale [
	"For now just return the default locale.
	A smarter way would be to determine the current platforms default locale."
	"Locale determineCurrentLocale"

	^self new determineLocale
]

{ #category : #private }
Locale class >> initKnownLocales [
	| locales |
	locales := Dictionary new.

	"Init the locales for which we have translations"
	self defaultLocales do: [:id |
		locales at: id put: (self new localeID: id)].
	^locales
]

{ #category : #initialization }
Locale class >> initialize [
	SessionManager default 
		registerSystemClassNamed: self name
]

{ #category : #initialization }
Locale class >> initializePlatformEncodings [
	"Locale initializePlatformEncodings"

	| platform |
	PlatformEncodings ifNil: [ PlatformEncodings := Dictionary new ].

	platform := PlatformEncodings at: 'default' ifAbsentPut: Dictionary new.
	platform
		at: 'default' put: 'iso8859-1';
		at: 'Win32 CE' put: 'utf-8'.

	platform := PlatformEncodings at: 'ja' ifAbsentPut: Dictionary new.
	platform
		at: 'default' put: 'shift-jis';
		at: 'unix' put: 'euc-jp';
		at: 'Win32 CE' put: 'utf-8'.
		
	platform := PlatformEncodings at: 'ko' ifAbsentPut: Dictionary new.
	platform
		at: 'default' put: 'euc-kr';
		at: 'Win32 CE' put: 'utf-8'.

	platform := PlatformEncodings at: 'zh' ifAbsentPut: Dictionary new.
	platform
		at: 'default' put: 'gb2312';
		at: 'unix' put: 'euc-cn';
		at: 'Win32 CE' put: 'utf-8'.

]

{ #category : #accessing }
Locale class >> isoLanguage: isoLanguage [
	^self isoLanguage: isoLanguage isoCountry: nil
]

{ #category : #accessing }
Locale class >> isoLanguage: isoLanguage isoCountry: isoCountry [
	^self localeID: (LocaleID  isoLanguage: isoLanguage isoCountry: isoCountry)
]

{ #category : #private }
Locale class >> knownLocales [
	"KnownLocales := nil"
	^KnownLocales ifNil: [KnownLocales := self initKnownLocales]
]

{ #category : #accessing }
Locale class >> languageSymbol: languageSymbol [
	"Locale languageSymbol: #Deutsch"

	^self isoLanguage: (LanguageSymbols at: languageSymbol)
]

{ #category : #'system startup' }
Locale class >> localTimeZone [
	^ LocalTimeZone new
]

{ #category : #announcing }
Locale class >> localeAnnouncer [
	^localeAnnouncer ifNil: [ localeAnnouncer := Announcer new ]
]

{ #category : #accessing }
Locale class >> localeID: id [
	^self knownLocales at: id ifAbsentPut: [Locale new localeID: id]
]

{ #category : #accessing }
Locale class >> platformEncodings [
	PlatformEncodings isEmptyOrNil ifTrue: [ self initializePlatformEncodings ].
	^PlatformEncodings

]

{ #category : #'system startup' }
Locale class >> startUp: resuming [
	| newID |
	resuming ifFalse: [^self].
	DateAndTime localTimeZone: self localTimeZone.
	(self activated)
		ifTrue: [
			newID := self current determineLocaleID.
			newID ~= LocaleID current
				ifTrue: [self switchToID: newID]]
]

{ #category : #accessing }
Locale class >> stringForLanguageNameIs: localeID [ 
	"Answer a string for a menu determining whether the given  
	symbol is the project's natural language"
	^ (self current localeID = localeID
		ifTrue: ['<yes>']
		ifFalse: ['<no>'])
		, localeID displayLanguage
]

{ #category : #accessing }
Locale class >> switchTo: locale [ 
	"Locale switchTo: Locale isoLanguage: 'de'"
	Current localeID = locale localeID
		ifFalse: [
			|announcement|
			announcement := LocaleChanged from: Current to: locale.
			Current := locale.
			CurrentPlatform := locale.
			self localeAnnouncer announce: announcement ]
]

{ #category : #accessing }
Locale class >> switchToID: localeID [
	"Locale switchToID: (LocaleID isoLanguage: 'de') "

	self switchTo: (Locale localeID: localeID)
]

{ #category : #accessing }
Locale >> determineLocale [
	self localeID: self determineLocaleID
]

{ #category : #accessing }
Locale >> determineLocaleID [
	"Locale current determineLocaleID"
	| langCode isoLang countryCode isoCountry |
	langCode := self fetchISO2Language.
	isoLang := langCode
		ifNil: [^self localeID]
		ifNotNil: [langCode].
	countryCode := self primCountry copyUpTo: 0 asCharacter.
	isoCountry := countryCode
		ifNil: [^LocaleID isoLanguage: isoLang]
		ifNotNil: [countryCode].
	^LocaleID isoLanguage: isoLang isoCountry: isoCountry
]

{ #category : #private }
Locale >> fetchISO2Language [
	"Locale current fetchISO2Language"

	| lang isoLang |
	lang := self primLanguage.
	lang ifNil: [ ^ nil ].
	lang := lang copyUpTo: 0 asCharacter.
	lang size = 2 ifTrue: [ ^ lang ].
	isoLang := ISOLanguageDefinition iso3LanguageDefinition: lang.
	^ isoLang ifNotNil: [ isoLang iso2 ]
]

{ #category : #accessing }
Locale >> isoCountry [
	^self localeID isoCountry
]

{ #category : #accessing }
Locale >> isoLanguage [
	^self localeID isoLanguage
]

{ #category : #accessing }
Locale >> isoLocale [
	"<language>-<country>"
	^self isoCountry
		ifNil: [self isoLanguage]
		ifNotNil: [self isoLanguage , '-' , self isoCountry]
]

{ #category : #accessing }
Locale >> localeID [
	^id
]

{ #category : #accessing }
Locale >> localeID: anID [
	id := anID
]

{ #category : #'system primitives' }
Locale >> primCountry [
	"Returns string with country tag according to ISO 639"
	<primitive: 'primitiveCountry' module: 'LocalePlugin'>
	^'FR'
]

{ #category : #'system primitives' }
Locale >> primCurrencyNotation [
	"Returns boolean if symbol is pre- (true) or post-fix (false)"
	<primitive: 'primitiveCurrencyNotation' module: 'LocalePlugin'>
	^true
]

{ #category : #'system primitives' }
Locale >> primCurrencySymbol [
	"Returns string with currency symbol"
	<primitive: 'primitiveCurrencySymbol' module:'LocalePlugin'>
	^'$'
]

{ #category : #'system primitives' }
Locale >> primDST [
	"Returns boolean if DST  (daylight saving time) is active or not"
	<primitive:'primitiveDaylightSavings' module: 'LocalePlugin'>
	^false
]

{ #category : #'system primitives' }
Locale >> primDecimalSymbol [
	"Returns string with e.g. '.' or ','"
	<primitive:'primitiveDecimalSymbol' module: 'LocalePlugin'>
	^'.'
]

{ #category : #'system primitives' }
Locale >> primDigitGrouping [
	"Returns string with e.g. '.' or ',' (thousands etc)"
	<primitive:'primitiveDigitGroupingSymbol' module: 'LocalePlugin'>
	^','
]

{ #category : #'system primitives' }
Locale >> primLanguage [
	"returns string with language tag according to ISO 639"
	<primitive:'primitiveLanguage' module: 'LocalePlugin'>
	^'en'
]

{ #category : #'system primitives' }
Locale >> primLongDateFormat [
	"Returns the long date format
	d day, m month, y year,
	double symbol is null padded, single not padded (m=6, mm=06)
	dddd weekday
	mmmm month name"
	<primitive:'primitiveLongDateFormat' module: 'LocalePlugin'>
	^'dddd, mmmm d, yyyy'

]

{ #category : #'system primitives' }
Locale >> primMeasurement [
	"Returns boolean denoting metric(true) or imperial(false)."
	<primitive:'primitiveMeasurementMetric' module: 'LocalePlugin'>
	^true

]

{ #category : #'system primitives' }
Locale >> primShortDateFormat [
	"Returns the short date format
	d day, m month, y year,
	double symbol is null padded, single not padded (m=6, mm=06)
	dddd weekday
	mmmm month name"
	<primitive:'primitiveShortDateFormat' module: 'LocalePlugin'>
	^'m/d/yy'

]

{ #category : #'system primitives' }
Locale >> primTimeFormat [
	"Returns string time format
	Format is made up of 
	h hour (h 12, H 24), m minute, s seconds, x (am/pm String)
	double symbol is null padded, single not padded (h=6, hh=06)"
	<primitive:'primitiveTimeFormat' module: 'LocalePlugin'>
	^'h:mmx'

]

{ #category : #'system primitives' }
Locale >> primTimezone [
	"The offset from UTC in minutes, with positive offsets being towards the east.
	(San Francisco is in UTC -07*60 and Paris is in UTC +02*60 (daylight savings is not in effect)."
	<primitive:'primitiveTimezoneOffset' module: 'LocalePlugin'>
	^0
]

{ #category : #'system primitives' }
Locale >> primVMOffsetToUTC [
	"Returns the offset in minutes between the VM and UTC.
	If the VM does not support UTC times, this is 0.
	Also gives us backward compatibility with old VMs as the primitive will fail and we then can return 0."
	<primitive:'primitiveVMOffsetToUTC' module: 'LocalePlugin'>
	^0
]

{ #category : #printing }
Locale >> printOn: aStream [ 
	super printOn: aStream.
	aStream nextPutAll:  '(' ; print: id ; nextPutAll:  ')'
]
