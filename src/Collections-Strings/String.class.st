"
A String is an indexed collection of Characters. Class String provides the abstract super class for ByteString (that represents an array of 8-bit Characters) and WideString (that represents an array of  32-bit characters).  In the similar manner of LargeInteger and SmallInteger, those subclasses are chosen accordingly for a string; namely as long as the system can figure out so, the String is used to represent the given string.

Strings support a vast array of useful methods, which can best be learned by browsing and trying out examples as you find them in the code.

Here are a few useful methods to look at...
	String match:
	String contractTo:

String also inherits many useful methods from its hierarchy, such as
	SequenceableCollection ,
	SequenceableCollection copyReplaceAll:with:

"
Class {
	#name : #String,
	#superclass : #ArrayedCollection,
	#classVars : [
		'AsciiOrder',
		'CSLineEnders',
		'CSNonSeparators',
		'CSSeparators',
		'CaseInsensitiveOrder',
		'CaseSensitiveOrder',
		'LowercasingTable',
		'Tokenish',
		'TypeTable',
		'UppercasingTable'
	],
	#category : #'Collections-Strings-Base'
}

{ #category : #primitives }
String class >> compare: string1 with: string2 collated: order [
	"Return 1, 2 or 3, if string1 is <, =, or > string2, with the collating order of characters given by the order array."

	| len1 len2 c1 c2 |
	order
		ifNil: [ len1 := string1 size.
			len2 := string2 size.
			1 to: (len1 min: len2) do: [ :i | 
				c1 := string1 basicAt: i.
				c2 := string2 basicAt: i.
				c1 = c2
					ifFalse: [ ^ c1 < c2
							ifTrue: [ 1 ]
							ifFalse: [ 3 ] ] ].
			len1 = len2 ifTrue: [ ^ 2 ].
			^ len1 < len2
				ifTrue: [ 1 ]
				ifFalse: [ 3 ] ].
	len1 := string1 size.
	len2 := string2 size.
	1 to: (len1 min: len2) do: [ :i | 
		c1 := string1 basicAt: i.
		c2 := string2 basicAt: i.
		c1 < 256 ifTrue: [ c1 := order at: c1 + 1 ].
		c2 < 256 ifTrue: [ c2 := order at: c2 + 1 ].
		c1 = c2
			ifFalse: [ ^ c1 < c2
					ifTrue: [ 1 ]
					ifFalse: [ 3 ] ] ].
	len1 = len2 ifTrue: [ ^ 2 ].
	^ len1 < len2
		ifTrue: [ 1 ]
		ifFalse: [ 3 ]
]

{ #category : #'instance creation' }
String class >> cr [
	"Answer a string containing a single carriage return character."

	^ self with: Character cr

]

{ #category : #'instance creation' }
String class >> crlf [
	"Answer a string containing a carriage return and a linefeed."

	^ self with: Character cr with: Character lf

]

{ #category : #'instance creation' }
String class >> crlfcrlf [
	^self crlf , self crlf.

]

{ #category : #'instance creation' }
String class >> empty [
	"A canonicalized empty String instance."
	^ ''
]

{ #category : #formatting }
String class >> expandMacro: macroType argument: argument withExpansions: expansions [ 
	macroType = $s ifTrue: [^expansions at: argument].
	macroType = $p ifTrue: [^(expansions at: argument) printString].
	macroType = $n ifTrue: [^String cr].
	macroType = $t ifTrue: [^String tab].
	self error: 'unknown expansion type'
]

{ #category : #primitives }
String class >> findFirstInString: aString inCharacterSet: aCharacterSet startingAt: start [ 
	"Trivial, non-primitive version"
	
	start
		to: aString size
		do: [:i | (aCharacterSet
					includes: (aString at: i))
				ifTrue: [^ i]].
	^ 0
]

{ #category : #primitives }
String class >> findFirstInString: aString inSet: inclusionMap startingAt: start [
	"Trivial, non-primitive version"
	
	| i stringSize ascii more |
	inclusionMap size ~= 256 ifTrue: [^ 0].
	stringSize := aString size.
	more := true.
	i := start - 1.
	[more and: [(i := i + 1) <= stringSize]] whileTrue: [
		ascii := (aString basicAt: i).
		more := ascii < 256 ifTrue: [(inclusionMap at: ascii + 1) = 0] ifFalse: [true].
	].

	i > stringSize ifTrue: [^ 0].
	^ i
]

{ #category : #'instance creation' }
String class >> fromByteArray: aByteArray [

	^ aByteArray asString

]

{ #category : #'instance creation' }
String class >> fromString: aString [ 
	"Answer an instance of me that is a copy of the argument, aString."
	
	^ aString copyFrom: 1 to: aString size
]

{ #category : #primitives }
String class >> indexOfAscii: anInteger inString: aString startingAt: start [	
	start to: aString size do: [ :index |
		(aString basicAt: index) = anInteger ifTrue: [ ^index ] ].
	^0


]

{ #category : #initialization }
String class >> initialize [   
	
	self initializeTypeTable.
	
	AsciiOrder := self newAsciiOrder.
	CaseInsensitiveOrder := self newCaseInsensitiveOrder.
	CaseSensitiveOrder := self newCaseSensitiveOrder.
	LowercasingTable := self newLowercasingTable.
	UppercasingTable := self newUppercasingTable.
	Tokenish := self newTokenish.
	CSLineEnders := self newCSLineEnders.

 	"separators and non-separators"
	CSSeparators := CharacterSet separators.
	CSNonSeparators := CSSeparators complement.
]

{ #category : #initialization }
String class >> initializeTypeTable [

	| newTable |
	newTable := Array new: 256 withAll: #xBinary. "default"
	newTable atAll: #(9 10 12 13 32 ) put: #xDelimiter. "tab lf ff cr space"
	newTable atAll: ($0 asciiValue to: $9 asciiValue) put: #xDigit.

	1 to: 255
		do: [:index |
			(Character value: index) isLetter
				ifTrue: [newTable at: index put: #xLetter]].

	newTable at: 30 put: #doIt.
	newTable at: $" asciiValue put: #xDoubleQuote.
	newTable at: $# asciiValue put: #xLitQuote.
	newTable at: $$ asciiValue put: #xDollar.
	newTable at: $' asciiValue put: #xSingleQuote.
	newTable at: $: asciiValue put: #xColon.
	newTable at: $( asciiValue put: #leftParenthesis.
	newTable at: $) asciiValue put: #rightParenthesis.
	newTable at: $. asciiValue put: #period.
	newTable at: $; asciiValue put: #semicolon.
	newTable at: $[ asciiValue put: #leftBracket.
	newTable at: $] asciiValue put: #rightBracket.
	newTable at: ${ asciiValue put: #leftBrace.
	newTable at: $} asciiValue put: #rightBrace.
	newTable at: $^ asciiValue put: #upArrow.
	newTable at: $_ asciiValue put: #xLetter. "by default, do not accept _ as assignement"
	newTable at: $| asciiValue put: #verticalBar.
	TypeTable := newTable

]

{ #category : #'instance creation' }
String class >> lf [
	"Answer a string containing a single carriage return character."

	^ self with: Character lf
]

{ #category : #'instance creation' }
String class >> loremIpsum [
	"Return a constant string with one paragraph of text, the famous Lorem ipsum filler text.
	The result is pure ASCII (Latin words) and contains no newlines."
	
	^ 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'
]

{ #category : #'instance creation' }
String class >> loremIpsum: size [
	"Return a mostly random multi-paragraph filler string of the specified size.
	The result is pure ASCII, uses CR for newlines and ends with a dot and newline."
	
	"self loremIpsum: 2048"
	
	| words out |
	words := (self loremIpsum findTokens: ' ,.') collect: [:each | each asLowercase].
	(out := LimitedWriteStream on: (self new: size))
		limit: size - 2;
		limitBlock: [
			^ out originalContents 
				at: size - 1 put: $.; 
				at: size put: Character cr; 
				yourself ].
	[ 
		out << self loremIpsum; cr; cr.
		5 atRandom timesRepeat: [
			15 atRandom timesRepeat: [
	 			out << words atRandom capitalized.
				20 atRandom timesRepeat: [ out space; << words atRandom ].
				out nextPut: $.; space ].
			out cr; cr ] ] repeat
]

{ #category : #'instance creation' }
String class >> new: sizeRequested [
	"Return a new instance with the number of indexable variables specified by the argument."

	^ self == String
		ifTrue: [ ByteString new: sizeRequested ]
		ifFalse: [ self basicNew: sizeRequested ]
]

{ #category : #initialization }
String class >> newAsciiOrder [
	^ (0 to: 255) as: ByteArray
]

{ #category : #initialization }
String class >> newCSLineEnders [
	"CR and LF--characters that terminate a line"
	^ CharacterSet crlf
]

{ #category : #initialization }
String class >> newCaseInsensitiveOrder [
	"map char and char asLower (Lowercase Latin1 stays in the Latin1 range, uppercase not.)"
	| newCollection |
	newCollection := AsciiOrder copy.
    (0 to: 255) do:[ :v |
            | char lower |
            char := v asCharacter.
            lower := char asLowercase.
            newCollection at: lower asciiValue + 1 put: (newCollection at: char asciiValue + 1) ].
	^ newCollection 
]

{ #category : #initialization }
String class >> newCaseSensitiveOrder [
	"Case-sensitive compare sorts space, digits, letters, all the rest..."
	
	| newTab order |
	newTab := ByteArray new: 256 withAll: 255.
	order := -1.
	' 0123456789' do:  "0..10"
		[:c | newTab at: c asciiValue + 1 put: (order := order+1)].
	($a to: $z) do:     "11-64"
		[:c | newTab  at: c asUppercase asciiValue + 1 put: (order := order+1).
		newTab  at: c asciiValue + 1 put: (order := order+1)].
	1 to: newTab  size do:
		[:i | (newTab  at: i) = 255 ifTrue:
			[newTab  at: i put: (order := order+1)]].
	order = 255 ifFalse: [self error: 'order problem'].
	^ newTab 
]

{ #category : #initialization }
String class >> newLowercasingTable [
	"a table for translating to lower case"
	^ String withAll: (Character allByteCharacters collect: [:c | c asLowercase])
]

{ #category : #initialization }
String class >> newTokenish [
	"a table for testing tokenish (for fast numArgs)"
	^ String withAll: (Character allByteCharacters 
		collect: [:c | c tokenish ifTrue: [ c ] ifFalse: [ $~ ]])
]

{ #category : #initialization }
String class >> newUppercasingTable [
	"a table for translating to upper case"
	^ String withAll: (Character allByteCharacters collect: [:c | c asUppercase])
]

{ #category : #'instance creation' }
String class >> readFrom: inStream [
	"Answer an instance of me that is determined by reading the stream, 
	inStream. Embedded double quotes become the quote Character."

	| char done |
	^ self streamContents: [ :outStream | 
		"go to first quote"
		inStream skipTo: $'.
		done := false.
		[ done or: [ inStream atEnd ] ]
			whileFalse: [ 
				char := inStream next.
				char = $'
					ifTrue: [ 
						char := inStream next.
						char = $'
							ifTrue: [ outStream nextPut: char ]
							ifFalse: [ done := true ] ]
					ifFalse: [ outStream nextPut: char ] ] ]
]

{ #category : #'instance creation' }
String class >> space [
	"Answer a string containing a single space character."

	^ self with: Character space

]

{ #category : #primitives }
String class >> stringHash: aString initialHash: speciesHash [
	| stringSize hash low |
	stringSize := aString size.
	hash := speciesHash bitAnd: 16rFFFFFFF.
	1 to: stringSize do: [:pos |
		hash := hash + (aString basicAt: pos).
		"Begin hashMultiply"
		low := hash bitAnd: 16383.
		hash := (16r260D * low + ((16r260D * (hash // 16384) + (16r0065 * low) bitAnd: 16383) * 16384)) bitAnd: 16r0FFFFFFF.
	].
	^ hash

]

{ #category : #'instance creation' }
String class >> tab [
	"Answer a string containing a single tab character."

	^ self with: Character tab

]

{ #category : #primitives }
String class >> translate: aString from: start  to: stop  table: table [
	"Trivial, non-primitive version"
	| char |
	start to: stop do: [:i |
		(char := aString basicAt: i) < 256 ifTrue: [
			aString at: i put: (table at: char+1)].
	]

]

{ #category : #accessing }
String class >> typeTable [
	TypeTable ifNil: [self initializeTypeTable].
	^ TypeTable
]

{ #category : #'instance creation' }
String class >> value: anInteger [

	^ self with: (Character value: anInteger)

]

{ #category : #'instance creation' }
String class >> with: aCharacter [
	| newCollection |
	newCollection := aCharacter asInteger < 256
		ifTrue:[ ByteString new: 1]
		ifFalse:[ WideString new: 1].
	newCollection at: 1 put: aCharacter.
	^newCollection
]

{ #category : #comparing }
String >> < aString [ 
	"Answer whether the receiver sorts before aString.
	The collation order is simple ascii (with case differences)."
	" 'abc' < 'def' >>> true"
	" 'abc' < 'abc' >>> false"
	" 'def' < 'abc' >>> false"
	
	
	^ (self compare: self with: aString collated: AsciiOrder) = 1
]

{ #category : #comparing }
String >> <= aString [ 
	"Answer whether the receiver sorts before or equal to aString.
	The collation order is simple ascii (with case differences)."
	" 'abc' <= 'def' >>> true"
	" 'abc' <= 'abc' >>> true"
	" 'def' <= 'abc' >>> false"
	
	^ (self compare: self with: aString collated: AsciiOrder) <= 2
]

{ #category : #comparing }
String >> = aString [ 
	"Answer whether the receiver sorts equally as aString.
	The collation order is simple ascii (with case differences)."
	" 'abc' = 'def' >>> false"
	" 'abc' = 'abc' >>> true"
	" 'def' = 'abc' >>> false"
	
	(aString isString and: [self size = aString size]) ifFalse: [^false].
	^ (self compare: self with: aString collated: AsciiOrder) = 2
]

{ #category : #comparing }
String >> > aString [ 
	"Answer whether the receiver sorts after aString.
	The collation order is simple ascii (with case differences)."
	" 'def' > 'abc' >>> true"
	" 'def' > 'def' >>> false"
	" 'abc' > 'def' >>> false"


	^ (self compare: self with: aString collated: AsciiOrder) = 3
]

{ #category : #comparing }
String >> >= aString [ 
	"Answer whether the receiver sorts after or equal to aString.
	The collation order is simple ascii (with case differences)."
	" 'def' >= 'abc' >>> true"
	" 'def' >= 'def' >>> true"
	" 'abc' >= 'def' >>> false"

	^ (self compare: self with: aString collated: AsciiOrder) >= 2
]

{ #category : #comparing }
String >> alike: aString [ 
	"Answer some indication of how alike the receiver is to the argument,  0 is no match, twice aString size is best score (but see example with 7).  Case is ignored. This method is used to help find mistyped variable names in methods."
	"('abc' alike: 'abc') >>> 7."
	"('action' alike: 'actions') >>> 7."
	"('action' alike: 'caption') >>> 5."
	"('action' alike: 'name') >>> 0."	

	| i j k minSize bonus |
	minSize := (j := self size) min: (k := aString size).
	bonus := (j - k) abs < 2 ifTrue: [ 1 ] ifFalse: [ 0 ].
	i := 1.
	[(i <= minSize) and: [((self at: i) asInteger bitAnd: 16rDF)  = ((aString at: i) asciiValue bitAnd: 16rDF)]]
		whileTrue: [ i := i + 1 ].
	[(j > 0) and: [(k > 0) and:
		[((self at: j) asInteger bitAnd: 16rDF) = ((aString at: k) asciiValue bitAnd: 16rDF)]]]
			whileTrue: [ j := j - 1.  k := k - 1. ].
	^ i - 1 + self size - j + bonus
]

{ #category : #'finding/searching' }
String >> allRangesOfSubstring: aSubstring [
	"('Ab cd ef Ab cd' allRangesOfSubstring: 'cd') >>> {(4 to: 5). (13 to: 14)}"
	"('Ab cd ef Ab cd' allRangesOfSubstring: 'zz') >>> #()"
	
	^ Array streamContents: [:s | | start subSize |
		start := 1.
		subSize := aSubstring size.
		[start isZero]
			whileFalse: [ start := self findString: aSubstring startingAt: start.
				start > 0 
					ifTrue: [s nextPut: (start to: start + subSize - 1).
						start := start + subSize]]]
]

{ #category : #converting }
String >> asByteArray [
	"Convert to a ByteArray with the ascii values of the string."
	"'a' asByteArray >>> #[97]"
	"'A' asByteArray >>> #[65]"
	"'ABA' asByteArray >>> #[65 66 65]"
	self subclassResponsibility 
]

{ #category : #converting }
String >> asByteString [
	"Convert the receiver into a ByteString, if possible"
	"Do not raise an error if it's not possible, since my use case is usually one in which WideStrings may or may not have been mutated to something representable in a ByteString, and we mostly do this to save space if possible. If the percentage of such cases are small, it may be better to use isOctetString check first to avoid creating String instances"	
	^self asOctetString
]

{ #category : #converting }
String >> asCamelCase [
	"Convert to CamelCase, i.e, remove spaces, and convert starting lowercase to uppercase."
   "'A man, a plan, a canal, panama' asCamelCase >>> 'AMan,APlan,ACanal,Panama'"
 	"'Here 123should % be 6 the name6 of the method' asCamelCase  >>> 'Here123should%Be6TheName6OfTheMethod'"
		^ self species streamContents: [:stream |
               self substrings do: [:sub |
                       stream nextPutAll: sub capitalized]]
]

{ #category : #converting }
String >> asComment [
	"return this string, munged so that it can be treated as a comment in Smalltalk code.  Quote marks are added to the beginning and end of the string, and whenever a solitary quote mark appears within the string, it is doubled"

	^String streamContents:  [ :str |
		| quoteCount first |

		str nextPut: $".
	
		quoteCount := 0.
		first := true.
		self do: [ :char |
			char = $"
				ifTrue: [
					first ifFalse: [
						str nextPut: char.
						quoteCount := quoteCount + 1 ] ]
				ifFalse: [
					quoteCount odd ifTrue: [
						"add a quote to even the number of quotes in a row"
						str nextPut: $" ].
					quoteCount := 0.
					str nextPut: char ].
			first := false ]. 

		quoteCount odd ifTrue: [
			"check at the end"
			str nextPut: $". ].

		str nextPut: $".
	]
	
]

{ #category : #converting }
String >> asDate [
	"Many allowed forms, see Date>>#readFrom:"

	^ Date fromString: self
]

{ #category : #converting }
String >> asDateAndTime [
 	"Convert from UTC format" 	
	
	^ DateAndTime fromString: self
]

{ #category : #converting }
String >> asDuration [
 	"Convert from [-]D:HH:MM:SS[.S] format. What is between [] implies optional elements"
 
 	^ Duration fromString: self
 
]

{ #category : #converting }
String >> asFourCode [
	"'abcd' asFourCode >>> -513645724"
	"'1111' asFourCode >>> 825307441"
	"'1234' asFourCode >>> 825373492"
	| result |
	self size = 4 
		ifFalse: [^self error: 'must be exactly four characters'].
		
	result := self inject: 0 into: [:val :each | 256 * val + each asciiValue ].
	(result bitAnd: 16r80000000) = 0 
		ifFalse: [ Error signal: 'cannot resolve fourcode' ].
		
	(result bitAnd: 16r40000000) = 0 
		ifFalse: [ ^ result - 16r80000000 ].
	^ result

]

{ #category : #converting }
String >> asHTMLString [
	"substitute the < & > into HTML compliant elements"
	"'<a>' asHTMLString"
	^ self species new: self size streamContents: [ :s| 
		self do: [:c | s nextPutAll: c asHTMLString ]]

]

{ #category : #converting }
String >> asHex [
	"'A' asHex >>> '16r41'"
	"'AA' asHex >>> '16r4116r41'"
	^ self species new: self size * 4 streamContents: [ :stream |
		self do: [ :ch | stream nextPutAll: ch hex ]]
]

{ #category : #converting }
String >> asInteger [ 
	"Return the integer present in the receiver, or nil. In case of float, returns the integer part."
	"'1' asInteger >>> 1"
	"'-1' asInteger >>> -1"
	"'10' asInteger >>> 10"
	"'a' asInteger >>> nil"
	"'1.234' asInteger >>> 1"
	^self asSignedInteger

]

{ #category : #converting }
String >> asLowercase [
	"Answer a String made up from the receiver whose characters are all lowercase."
	"'PhaRo' asLowercase >>> 'pharo'"
	"'' asLowercase >>> ''"
	"' ' asLowercase >>> ' '"	
	^ self copy asString translateToLowercase
]

{ #category : #converting }
String >> asOctetString [
	"Convert the receiver into an octet string, if possible"
	"(IE, I am a WideString containing only character with codePoints < 255, so all of them fit in a latin1-string)."
	| string |
	string := String new: self size.
	1 to: self size do: [:i | string at: i put: (self at: i)].
	^string
]

{ #category : #converting }
String >> asPluralBasedOn: aNumberOrCollection [
	"Append an 's' to this string based on whether aNumberOrCollection is 1 or of size 1."

	^ (aNumberOrCollection = 1 or:
		[aNumberOrCollection isCollection and: [aNumberOrCollection size = 1]])
			ifTrue: [self]
			ifFalse: [self, 's']

]

{ #category : #converting }
String >> asSignedInteger [ 
	"Returns the first signed integer it can find or nil."

	| start stream |
	start := self findFirst: [:char | char isDigit].
	start isZero ifTrue: [^ nil].
	stream := self readStream position: start - 1.
	((stream position ~= 0) and: [stream peekBack = $-])
		ifTrue: [stream back].
	^ Integer readFrom: stream
]

{ #category : #converting }
String >> asString [
	"Answer this string."

	^ self

]

{ #category : #converting }
String >> asSymbol [
	"Answer the unique Symbol whose characters are the characters of the 
	string."
	^Symbol intern: self
]

{ #category : #converting }
String >> asTime [
	"Many allowed forms, see Time>>readFrom:"

	^ Time fromString: self.
]

{ #category : #converting }
String >> asUncommentedCode [
	"this string reprensent a commented code, let's uncomment it"
	
	^String streamContents:  [ :str |
		
		|doubleQuoteAlreadyFound|
		doubleQuoteAlreadyFound := false.
		
		self withoutQuoting do: [ :char |
			char = $"
				ifTrue: [ 
					doubleQuoteAlreadyFound 	ifTrue: [ 
							str nextPut: $" ].
					doubleQuoteAlreadyFound := doubleQuoteAlreadyFound not.
				]
				ifFalse: [ 
					str nextPut: char
				]
		 ]
	]


]

{ #category : #converting }
String >> asUnsignedInteger [
	"Returns the first integer it can find or nil."
	| start stream |
	start := self findFirst: [ :char | char isDigit ].
	start isZero ifTrue: [ ^ nil ].
	stream := self readStream position: start - 1.
	^ Integer readFrom: stream
]

{ #category : #converting }
String >> asUppercase [
	"Answer a String made up from the receiver whose characters are all uppercase."

	^self copy asString translateToUppercase
]

{ #category : #converting }
String >> asValidSelector [
	"Returns a symbol that is a valid selector by removing any space or forbidden characters"
	"'234znak ::x43 ''åå) _ : 2' asValidSelector >>> #'v234znak:x43:v2'"
	"'234znak ::x43 åå) :2' asValidSelector >>> #v234znak:x43:v2"
	
^(((
	$: join: (	
		(
			$: split: (
				self select: [ :char |
					(char charCode < 128) and: [ 
						char isAlphaNumeric or: [ 
							char = $:	
						]	
					]	
				]
			)
		)  
		select: [ :split | split isNotEmpty ]
		thenCollect: [ :nonEmptyString |
			nonEmptyString first isLetter
				ifTrue: [ nonEmptyString uncapitalized ]
				ifFalse: [ 'v' , nonEmptyString ]
		]
	)
) ifEmpty: [ 'v' ]), ((self isNotEmpty and: [ self last = $: ]) ifTrue: [ ':' ] ifFalse: [ #() ]) )asSymbol

]

{ #category : #converting }
String >> asWideString [ 

	^ WideString from: self
]

{ #category : #testing }
String >> beginsWithEmpty: prefix caseSensitive: aBoolean [ 
	"Answer whether the receiver begins with the given prefix string. 
	The comparison is case-sensitive." 
	| matchTable |
	prefix isEmpty ifTrue: [ ^ true ].
	self size < prefix size ifTrue: [ ^ false ].
	matchTable := aBoolean 
		ifTrue: [ CaseSensitiveOrder ]
		ifFalse: [ CaseInsensitiveOrder ].
	^ (self 
		findSubstring: prefix
		in: self
		startingAt: 1
		matchTable: matchTable) = 1
]

{ #category : #accessing }
String >> byteAt: index [
	^self subclassResponsibility
]

{ #category : #accessing }
String >> byteAt: index put: value [
	^self subclassResponsibility
]

{ #category : #accessing }
String >> byteSize [
	^self subclassResponsibility
]

{ #category : #converting }
String >> capitalized [
	"Return a copy with the first letter capitalized"
	| cap |
	self isEmpty ifTrue: [ ^self copy ].
	cap := self copy.
	cap at: 1 put: (cap at: 1) asUppercase.
	^ cap
]

{ #category : #comparing }
String >> caseInsensitiveLessOrEqual: aString [ 
	"Answer whether the receiver sorts before or equal to aString.
	The collation order is case insensitive."
	^(self compare: aString caseSensitive: false) <= 2
]

{ #category : #comparing }
String >> caseSensitiveLessOrEqual: aString [ 
	"Answer whether the receiver sorts before or equal to aString.
	The collation order is case sensitive."
	^(self compare: aString caseSensitive: true) <= 2
]

{ #category : #comparing }
String >> charactersExactlyMatching: aString [
	"Do a character-by-character comparison between the receiver and aString.  Return the index of the final character that matched exactly."
	"('s' charactersExactlyMatching: 'abc') >>> 0"
	"('fear is the little death that the.' charactersExactlyMatching: 'the') >>> 0"
	"('fear is the little death that the.' charactersExactlyMatching: 'fear is') >>> 7"
	
	| count |
	count := self size min: aString size.
	1 to: count do: [:i | 
		(self at: i) = (aString at: i) ifFalse: [
			^ i - 1]].
	^ count
]

{ #category : #comparing }
String >> compare: aString [ 
	"Answer a comparison code telling how the receiver sorts relative to aString:
		1 - before
		2 - equal
		3 - after.
	The collation sequence is ascii with case differences ignored.
	To get the effect of a <= b, but ignoring case, use (a compare: b) <= 2."
	"('aa' compare: 'ab') >>> 1"
	"('aa' compare: 'aa') >>> 2"
	"('ab' compare: 'aa') >>> 3"
	
	^self compare: aString caseSensitive: false
]

{ #category : #comparing }
String >> compare: aString caseSensitive: aBool [
	"Answer a comparison code telling how the receiver sorts relative to aString:
		1 - before
		2 - equal
		3 - after.
	"
	| map |
	map := aBool ifTrue:[CaseSensitiveOrder] ifFalse:[CaseInsensitiveOrder].
	^self compare: self with: aString collated: map
]

{ #category : #comparing }
String >> compare: string1 with: string2 collated: order [
	
	"'abc' = 'abc' asWideString >>> true"
	"'abc' asWideString = 'abc' >>> true"
	"(ByteArray with: 97 with: 0 with: 0 with: 0) asString ~= 'a000' asWideString >>> true"
	"('abc' sameAs: 'aBc' asWideString) >>> true"
	"('aBc' asWideString sameAs: 'abc') >>> true"
	"('a000' asWideString ~= (ByteArray with: 97 with: 0 with: 0 with: 0) asString) >>> true"
	"((ByteArray with: 97 with: 0 with: 0 with: 0) asString sameAs: 'Abcd' asWideString) >>> false"
	"('a000' asWideString sameAs: (ByteArray with: 97 with: 0 with: 0 with: 0) asString) >>> false"
	
	(string1 isByteString and: [string2 isByteString]) ifTrue: [
		^ ByteString compare: string1 with: string2 collated: order].
     "Primitive does not fail properly right now"
	^ String compare: string1 with: string2 collated: order
]

{ #category : #converting }
String >> contractTo: smallSize [
	"return myself or a copy shortened by ellipsis to smallSize"
	"('abcd' contractTo: 10) >>> 'abcd'"
	"('Pharo is really super cool' contractTo: 10) >>> 'Phar...ool'"
	"('A clear but rather long-winded summary' contractTo: 18) >>> 'A clear ...summary'"
	
	| leftSize |
	self size <= smallSize
		ifTrue: [^ self].  "short enough"
	smallSize < 5
		ifTrue: [^ self copyFrom: 1 to: smallSize].    "First N characters"
	leftSize := smallSize-2//2.
	^ self copyReplaceFrom: leftSize+1		"First N/2 ... last N/2"
		to: self size - (smallSize - leftSize - 3)
		with: '...'

]

{ #category : #copying }
String >> copyReplaceAll: oldSubstring with: newSubstring [
	"Answer a copy of the receiver in which all occurrences of oldSubstring have been replaced by newSubstring"
	"('ab cd ab ef ab' copyReplaceAll: 'ab' with: 'zk') >>> 'zk cd zk ef zk'"
    | idx |        
    self = oldSubstring ifTrue: [ ^ newSubstring copy ].
    oldSubstring isEmpty ifTrue: [ ^ self copy ].
    idx := 1.
    ^ self species new: self size streamContents: [ :stream | | foundIdx |
        [ (foundIdx := self findString: oldSubstring startingAt: idx) isZero ] whileFalse: [ 
            stream 
                next: (foundIdx - idx) putAll: self startingAt: idx;
                nextPutAll: newSubstring.
            idx := foundIdx + oldSubstring size ].
        idx <= self size ifTrue: [ 
            stream next: (self size - idx + 1) putAll: self startingAt: idx ] ]
]

{ #category : #copying }
String >> copyReplaceAll: oldSubstring with: newSubstring asTokens: ifTokens [
	"Answer a copy of the receiver in which all occurrences of oldSubstring have been replaced by newSubstring. ifTokens (valid for Strings only) specifies that the characters surrounding the replacement must not be alphanumeric (space). When ifTokens is set, it means that the replacement will not occur inside word."

	"('test te string' copyReplaceAll: 'te' with: 'longone' asTokens: true) >>> 'test longone string'"
	"('test te string' copyReplaceAll: 'te' with: 'longone' asTokens: false) >>> 'longonest longone string'"

	| aString startSearch currentIndex endIndex |

	aString := self.
	startSearch := 1.
	[(currentIndex := aString indexOfSubCollection: oldSubstring startingAt: startSearch)
			 > 0]
		whileTrue: 
		[endIndex := currentIndex + oldSubstring size - 1.
		(ifTokens not
			or: [(currentIndex = 1
					or: [(aString at: currentIndex-1) isAlphaNumeric not])
				and: [endIndex = aString size
					or: [(aString at: endIndex+1) isAlphaNumeric not]]])
			ifTrue: [aString := aString
					copyReplaceFrom: currentIndex
					to: endIndex
					with: newSubstring.
				startSearch := currentIndex + newSubstring size]
			ifFalse: [
				ifTokens 
					ifTrue: [startSearch := currentIndex + 1]
					ifFalse: [startSearch := currentIndex + newSubstring size]]].
	^ aString


]

{ #category : #copying }
String >> copyReplaceTokens: oldSubstring with: newSubstring [ 
	"Replace all occurrences of oldSubstring that are surrounded by non-alphanumeric characters"
	"('File asFile Files File''s File' copyReplaceTokens: 'File' with: 'Snick') >>> 'Snick asFile Files Snick''s Snick'"
	
	^ self copyReplaceAll: oldSubstring with: newSubstring asTokens: true
	
]

{ #category : #copying }
String >> copyUpToSubstring: aSubstring [

	aSubstring ifEmpty: [ 
		"preserve compatiblity with `readStream upToAll:`"
		^ String new ].
	
	^ (self findString: aSubstring)
		in: [ :index | index > 0 ifTrue: [ self copyFrom: 1 to: index-1 ] ifFalse: [ self ] ]
]

{ #category : #converting }
String >> correctAgainst: wordList [
	"Correct the receiver: assume it is a misspelled word and return the (maximum of five) nearest words in the wordList.  Depends on the scoring scheme of alike:"
	| results |
	results := self correctAgainst: wordList continuedFrom: nil.
	results := self correctAgainst: nil continuedFrom: results.
	^ results
]

{ #category : #converting }
String >> correctAgainst: wordList continuedFrom: oldCollection [
	"Like correctAgainst:.  Use when you want to correct against several lists, give nil as the first oldCollection, and nil as the last wordList."

	^ wordList 
		ifNil: [ self correctAgainstEnumerator: nil
					continuedFrom: oldCollection ]
		ifNotNil: [ self correctAgainstEnumerator: [ :action | wordList do: action without: nil]
					continuedFrom: oldCollection ]
]

{ #category : #converting }
String >> correctAgainstDictionary: wordDict continuedFrom: oldCollection [
	"Like correctAgainst:continuedFrom:.  Use when you want to correct against a dictionary."

	^ wordDict 
		ifNil: [ self correctAgainstEnumerator: nil
					continuedFrom: oldCollection ]
		ifNotNil: [ self correctAgainstEnumerator: [ :action | wordDict keysDo: action ]
					continuedFrom: oldCollection ]
]

{ #category : #private }
String >> correctAgainstEnumerator: wordBlock continuedFrom: oldCollection [

	"The guts of correction, instead of a wordList, there is a block that should take another block and enumerate over some list with it."

	| choices results maxChoices scoreMin |

	scoreMin := self size // 2 min: 3.
	maxChoices := 10.
	oldCollection
		ifNil: [ choices := SortedCollection sortBlock: [ :x :y | x value > y value ] ]
		ifNotNil: [ choices := oldCollection ].
	wordBlock
		ifNil: [ results := OrderedCollection new.
			1 to: ( maxChoices min: choices size ) do: [ :i | results add: ( choices at: i ) key ]
			]
		ifNotNil: [ wordBlock
				value: [ :word | 
					| score |

					( score := self alike: word ) >= scoreMin
						ifTrue: [ choices add: ( Association key: word value: score ).
							choices size >= maxChoices
								ifTrue: [ scoreMin := ( choices at: maxChoices ) value ]
							]
					].
			results := choices
			].
	^ results
]

{ #category : #copying }
String >> deepCopy [
	"DeepCopy would otherwise mean make a copy of the character;  since 
	characters are unique, just return a shallowCopy."

	^self shallowCopy
]

{ #category : #printing }
String >> displayStringOn: aStream [
	"Make sure that this is not printOn: because we do not want to have multiple quotes."
	aStream nextPutAll: self
]

{ #category : #printing }
String >> encodeDoublingQuoteOn: aStream [
	self deprecated: 'Use #storeOn: instead' transformWith: '`@receiver encodeDoublingQuoteOn: `@argument' -> '`@receiver storeOn: `@argument'.
	self storeOn: aStream
]

{ #category : #testing }
String >> endsWith: suffix [
	"Answer whether the tail end of the receiver is the same as suffix.
	The comparison is case-sensitive."
 
	"('Elvis' endsWith: 'vis') >>> true"
	
	| extra |
	extra := self size - suffix size.
	^extra < 0 
		ifTrue: [ false]
	   ifFalse: [ (self findString: suffix startingAt: extra + 1) > 0 ]
]

{ #category : #testing }
String >> endsWithAColon [ 
	"Answer whether the final character of the receiver is a colon"
	"'displayStringOn:' endsWithAColon >>> true"
	"'displayStringOn:foo' endsWithAColon >>> false"
	
	^ self notEmpty and: [ self last == $: ]

]

{ #category : #testing }
String >> endsWithDigit [
	"Answer whether the receiver's final character represents a digit."
	"'foo10' endsWithDigit >>> true"
	"'foo10foo' endsWithDigit >>> false"
	"'foo1' endsWithDigit >>> true"
	
	^ self notEmpty and: [self last isDigit]
]

{ #category : #formatting }
String >> expandMacros [
	"'<t>' expandMacros >>> String tab"
	"'<r>' expandMacros >>> String cr"
	"'<n>' expandMacros >>> OSPlatform current lineEnding"
	
	^self expandMacrosWithArguments: #()
]

{ #category : #formatting }
String >> expandMacrosWith: anObject [ 
	"('Pharo is <1s>' expandMacrosWith: 'cool') >>> 'Pharo is cool'"
	"('Pharo is <1p>' expandMacrosWith: 'cool') >>> 'Pharo is ''cool'''"

	^self expandMacrosWithArguments: (Array with: anObject)
]

{ #category : #formatting }
String >> expandMacrosWith: anObject with: anotherObject [ 
	^self 
		expandMacrosWithArguments: (Array with: anObject with: anotherObject)
]

{ #category : #formatting }
String >> expandMacrosWith: anObject with: anotherObject with: thirdObject [ 
	^self expandMacrosWithArguments: (Array 
				with: anObject
				with: anotherObject
				with: thirdObject)
]

{ #category : #formatting }
String >> expandMacrosWith: anObject with: anotherObject with: thirdObject with: fourthObject [ 
	^self expandMacrosWithArguments: (Array 
				with: anObject
				with: anotherObject
				with: thirdObject
				with: fourthObject)
]

{ #category : #formatting }
String >> expandMacrosWithArguments: anArray [
	"Interpret the receiver pattern (<1p>, <1s>, <t>...) with argument passed in anArray."
	
	"<Np> writes the N-th argument using #printString, but without trancating it."
	"('<1p>: <2p>' expandMacrosWith: 'Number' with: 5 with: nil) >>> '''Number'': 5'"
	
	"<Ns> writes the N-th argument, which should be a String, or a collection of printable objects.
	Note also important distinction for single-quotes inside the argument; with <p> they will be doubled."
	"('<1s> vs <1p>' expandMacrosWith: 'it''em') >>> 'it''em vs ''it''''em'''"
	
	"Whitespace characters:"
	"'<t>' expandMacros >>> String tab"
	"'<r>' expandMacros >>> String cr"
	"'<n>' expandMacros >>> OSPlatform current lineEnding"
	"'<l>' expandMacros >>> String lf"
	
	"Writing '<' character:
	To write '<', prepend it with a percent sign."
	"'%<n>' expandMacros >>> '<n>'"
	
	"Ternary operator:
	An if-else string can be written with <N?yes-string:no-string>.
	The N-th argument must be a Boolean.
	Yes-string cannot contain colon ':', as it terminates the yes-string.
	No-string cannot contain closing angle bracket '>', as it terminates the no-string."
	"('<1?success:error>' expandMacrosWith: true) >>> 'success'"
	"('<1?success:is error>' expandMacrosWith: false) >>> 'is error'"
	
	| readStream char index |
	^ self species
		new: self size
		streamContents:
			[ :newStream | 
			readStream := self readStream.
			[ readStream atEnd ]
				whileFalse:
					[ char := readStream next.
					char == $<
						ifTrue:
							[ | nextChar |
							nextChar := readStream next asUppercase.
							nextChar == $R
								ifTrue: [ newStream cr ].
							nextChar == $L
								ifTrue: [ newStream lf ].
							nextChar == $T
								ifTrue: [ newStream tab ].
							nextChar == $N
								ifTrue: [ newStream nextPutAll: OSPlatform current lineEnding ].
							nextChar isDigit
								ifTrue:
									[ index := nextChar digitValue.
									[ readStream atEnd or: [ (nextChar := readStream next asUppercase) isDigit not ] ]
										whileFalse: [ index := index * 10 + nextChar digitValue ] ].
							nextChar == $?
								ifTrue:
									[ | trueString falseString |
									trueString := readStream upTo: $:.
									falseString := readStream upTo: $>.
									readStream position: readStream position - 1.
									newStream
										nextPutAll:
											((anArray at: index)
												ifTrue: [ trueString ]
												ifFalse: [ falseString ]) ].
							nextChar == $P
								ifTrue: [ (anArray at: index) printOn: newStream  ].
							nextChar == $S
								ifTrue: [ newStream nextPutAll: (anArray at: index) ].
							readStream skipTo: $> ]
						ifFalse: [ newStream
								nextPut:
									(char == $%
										ifTrue: [ readStream next ]
										ifFalse: [ char ]) ] ] ]
]

{ #category : #'finding/searching' }
String >> findAnySubstring: aCollection startingAt: start [ 
	"Answer the index where an element of aCollection begins. If none are found, answer size + 1. aCollection is an Array of Strings or Characters."

	^aCollection inject: 1 + self size into: [:min :searchTerm |
		| ind |
		ind := searchTerm isCharacter 
			ifTrue: [self indexOf: searchTerm startingAt: start ifAbsent: [min]]
			ifFalse: [self indexOfSubCollection: searchTerm startingAt: start ifAbsent: [min]].
		min min: ind]
]

{ #category : #'finding/searching' }
String >> findBetweenSubstrings: delimiters [
	"Answer the collection of String tokens that result from parsing self.  Tokens are separated by 'delimiters', which can be a collection of Strings, or a collection of Characters.  Several delimiters in a row are considered as just one separation."

	| tokens keyStart keyStop |
	tokens := OrderedCollection new.
	keyStop := 1.
	[keyStop <= self size] whileTrue:
		[keyStart := self skipAnySubstring: delimiters startingAt: keyStop.
		keyStop := self findAnySubstring: delimiters startingAt: keyStart.
		keyStart < keyStop
			ifTrue: [tokens add: (self copyFrom: keyStart to: (keyStop - 1))]].
	^tokens
]

{ #category : #'finding/searching' }
String >> findCloseParenthesisFor: startIndex [
	"assume (self at: startIndex) is $(.  Find the matching $), allowing parentheses to nest."
	" '(1+(2-3))-3.14159' findCloseParenthesisFor: 1 "
	" '(1+(2-3))-3.14159' findCloseParenthesisFor: 4 "
	| pos nestLevel |
	pos := startIndex+1.
	nestLevel := 1.
	[ pos <= self size ] whileTrue: [
		(self at: pos) = $( ifTrue: [ nestLevel := nestLevel + 1 ].
		(self at: pos) = $) ifTrue: [ nestLevel := nestLevel - 1 ].
		nestLevel = 0 ifTrue: [ ^pos ].
		pos := pos + 1.
	].
	^self size + 1
]

{ #category : #'finding/searching' }
String >> findDelimiters: delimiters startingAt: start [ 
	"Answer the index of the character within the receiver, starting at start, that matches one of the delimiters. If the receiver does not contain any of the delimiters, answer size + 1."

	start to: self size do: [:i |
		delimiters do: [:delim | 
			delim = (self at: i) 
				ifTrue: [^ i]]].
	^ self size + 1
]

{ #category : #comparing }
String >> findIn: body startingAt: start matchTable: matchTable [
	
	^ self findSubstringViaPrimitive: self in: body startingAt: start matchTable: matchTable
]

{ #category : #'finding/searching' }
String >> findLastOccurrenceOfString: substring startingAt: start [ 
	"Answer the index of the last occurrence of substring within the receiver, starting at start. If 
	the receiver does not contain substring, answer 0.  Case-sensitive match used."

	| last now |
	last := self findString: substring startingAt: start.
	last = 0 ifTrue: [^ 0].
	[last > 0] whileTrue:
		[now := last.
		last := self findString: substring startingAt: last + 1].

	^ now

]

{ #category : #converting }
String >> findSelector [
	"Extract a selector with keyword parts from the receiver. While this doesn't give a true parse, in most cases it does what we want, in where it doesn't, we're none the worse for it."
	
	"'isSymbol' findSelector >>> #isSymbol"
	"'x isSymbol' findSelector >>> nil"
	"'x isSymbol: 33' findSelector >>> #isSymbol:"
	"'between:and:' findSelector >>> #'between:and:'"
	"'2 between: 0 and: 4' findSelector >>> #'between:and:'"
	"'2 between: ( 1 and: 4)' findSelector >>> #between:"
	"'( 1 and: 4)' findSelector >>> nil"
	
	| sel possibleParens |
	sel := self trimBoth.
	sel := sel copyReplaceAll: '#' with: ''.
	sel := sel copyReplaceAll: '[' with: ' [ '.
	(sel includes: $:) ifTrue:
		[sel := sel copyReplaceAll: ':' with: ': '.	"for the style (aa max:bb) with no space"
		possibleParens := sel findTokens: Character separators.
		sel := self species streamContents:
			[:s | | level | level := 0.
			possibleParens do:
				[:token | | n |
				(level = 0 and: [token endsWith: ':'])
					ifTrue: [s nextPutAll: token]
					ifFalse: [(n := token occurrencesOf: $( ) > 0 ifTrue: [level := level + n].
							(n := token occurrencesOf: $[ ) > 0 ifTrue: [level := level + n].
							(n := token occurrencesOf: $] ) > 0 ifTrue: [level := level - n].
							(n := token occurrencesOf: $) ) > 0 ifTrue: [level := level - n]]]]].

	sel isEmpty ifTrue: [^ nil].
	sel isOctetString ifTrue: [sel := sel asOctetString].
	Symbol hasInterned: sel ifTrue:
		[:aSymbol | ^ aSymbol].
	^ nil
]

{ #category : #'finding/searching' }
String >> findString: substring [
	"Answer the index of the first substring within the receiver. If the receiver does not contain substring, answer 0."
	"('salkjsdlkgfee' findString: 'al') >>> 2"
	"('salkjsdlkgfeesd' findString: 'sd') >>> 6"
	
	^self findString: substring startingAt: 1.
]

{ #category : #'finding/searching' }
String >> findString: substring startingAt: start [ 
	"Answer the index of the first substring within the receiver, starting at start. If the receiver does not contain substring, answer 0."
	"('salkjsdlkgfee' findString: 'ee'startingAt: 3) >>> 12"
	"('salkjsdlkgfee' findString: 'al'startingAt: 3) >>> 0"
	"('salkjsdlkgfeeal' findString: 'al' startingAt: 1) >>> 2"
	
	^self findString: substring startingAt: start caseSensitive: true
]

{ #category : #'finding/searching' }
String >> findString: key startingAt: start caseSensitive: caseSensitive [ 
	"Answer the index in this String at which the substring key first occurs,
	at or beyond start. The match can be case-sensitive or not. If no match
	is found, zero will be returned."
	
	"IMPLEMENTATION NOTE: do not use CaseSensitiveOrder because it is broken for WideString
	This is a temporary work around until Wide CaseSensitiveOrder search is fixed
	Code should revert to:
	caseSensitive
		ifTrue: [^ self findSubstring: key in: self startingAt: start matchTable: CaseSensitiveOrder]
		ifFalse: [^ self findSubstring: key in: self startingAt: start matchTable: CaseInsensitiveOrder]"
		
	^caseSensitive
		ifTrue: [
			(self class isBytes and: [key class isBytes])
				ifTrue: [self
						findSubstring: key
						in: self
						startingAt: start
						matchTable: CaseSensitiveOrder]
				ifFalse: [WideString new
						findSubstring: key
						in: self
						startingAt: start
						matchTable: nil]]
		ifFalse: [
			(self class isBytes and: [key class isBytes])
				ifTrue: [self
						findSubstring: key
						in: self
						startingAt: start
						matchTable: CaseInsensitiveOrder]
				ifFalse: [WideString new
						findSubstring: key
						in: self
						startingAt: start
						matchTable: CaseInsensitiveOrder]]
]

{ #category : #comparing }
String >> findSubstring: key in: body startingAt: start matchTable: matchTable [
	"Answer the index in the string body at which the substring key first occurs, at or beyond start.  The match is determined using matchTable, which can be used to effect, eg, case-insensitive matches.  If no match is found, zero will be returned."
	| index c1 c2 |
	matchTable == nil ifTrue: [
		key size = 0 ifTrue: [^ 0].
		start to: body size - key size + 1 do:
			[:startIndex |
			index := 1.
				[(body at: startIndex+index-1)
					= (key at: index)]
					whileTrue:
					[index = key size ifTrue: [^ startIndex].
					index := index+1]].
		^ 0
	].

	key size = 0 ifTrue: [^ 0].
	start to: body size - key size + 1 do:
		[:startIndex |
		index := 1.
		[c1 := body at: startIndex+index-1.
		c2 := key at: index.
		((c1 leadingChar = 0 and: [ c1 asciiValue < matchTable size ]) 
			ifTrue: [ matchTable at: c1 asciiValue + 1 ]
			ifFalse: [ c1 asciiValue + 1 ]) = 
			((c2 leadingChar = 0 and: [ c2 asciiValue < matchTable size ])
				ifTrue: [ matchTable at: c2 asciiValue + 1 ]
				ifFalse: [c2 asciiValue + 1 ]) ]
			whileTrue:
				[index = key size ifTrue: [^ startIndex].
				index := index+1]].
	^ 0
]

{ #category : #comparing }
String >> findSubstringViaPrimitive: key in: body startingAt: start matchTable: matchTable [
	"Answer the index in the string body at which the substring key first occurs, at or beyond start.  The match is determined using matchTable, which can be used to effect, eg, case-insensitive matches.  If no match is found, zero will be returned.

	The algorithm below is not optimum -- it is intended to be translated to C which will go so fast that it wont matter."
	| index |
	<primitive: 'primitiveFindSubstring' module: 'MiscPrimitivePlugin'>
	<var: #key declareC: 'unsigned char *key'>
	<var: #body declareC: 'unsigned char *body'>
	<var: #matchTable declareC: 'unsigned char *matchTable'>

	key size = 0 ifTrue: [^ 0].
	(start max: 1) to: body size - key size + 1 do:
		[:startIndex |
		index := 1.
			[(matchTable at: (body basicAt: startIndex+index-1) + 1)
				= (matchTable at: (key basicAt: index) + 1)]
				whileTrue:
				[index = key size ifTrue: [^ startIndex].
				index := index+1]].
	^ 0
"
' ' findSubstring: 'abc' in: 'abcdefabcd' startingAt: 1 matchTable: CaseSensitiveOrder 1
' ' findSubstring: 'abc' in: 'abcdefabcd' startingAt: 2 matchTable: CaseSensitiveOrder 7
' ' findSubstring: 'abc' in: 'abcdefabcd' startingAt: 8 matchTable: CaseSensitiveOrder 0
' ' findSubstring: 'abc' in: 'abcdefABcd' startingAt: 2 matchTable: CaseSensitiveOrder 0
' ' findSubstring: 'abc' in: 'abcdefABcd' startingAt: 2 matchTable: CaseInsensitiveOrder 7
"
]

{ #category : #'finding/searching' }
String >> findTokens: delimiters [
	"Answer the collection of tokens that result from parsing self.  Return strings between the delimiters.  Any character in the Collection delimiters marks a border.  Several delimiters in a row are considered as just one separation.  Also, allow delimiters to be a single character."

	| tokens keyStart keyStop separators |

	tokens := OrderedCollection new.
	separators := delimiters isCharacter 
		ifTrue: [Array with: delimiters]
		ifFalse: [delimiters].
	keyStop := 1.
	[keyStop <= self size] whileTrue:
		[keyStart := self skipDelimiters: separators startingAt: keyStop.
		keyStop := self findDelimiters: separators startingAt: keyStart.
		keyStart < keyStop
			ifTrue: [tokens add: (self copyFrom: keyStart to: (keyStop - 1))]].
	^tokens
]

{ #category : #'finding/searching' }
String >> findTokens: delimiters escapedBy: quoteDelimiters [ 
	"Answer a collection of Strings separated by the delimiters, where  
	delimiters is a Character or collection of characters. Two delimiters in a  
	row produce an empty string (compare this to #findTokens, which  
	treats sequential delimiters as one).  
	 
	The characters in quoteDelimiters are treated as quote characters, such  
	that any delimiter within a pair of matching quoteDelimiter characters  
	is treated literally, rather than as a delimiter.  
	 
	The quoteDelimiter characters may be escaped within a quoted string.  
	Two sequential quote characters within a quoted string are treated as  
	a single character.  
	 
	This method is useful for parsing comma separated variable strings for  
	spreadsheet import and export."
	| tokens rs activeEscapeCharacter ts char token delimiterChars quoteChars |
	delimiterChars := (delimiters 
		ifNil: [ '' ]
		ifNotNil: [ delimiters ]) asString.
	quoteChars := (quoteDelimiters 
		ifNil: [ '' ]
		ifNotNil: [ quoteDelimiters ]) asString.
	tokens := OrderedCollection new.
	rs := self readStream.
	activeEscapeCharacter := nil.
	ts := String new writeStream.
	[ rs atEnd ] whileFalse: 
		[ char := rs next.
		activeEscapeCharacter 
			ifNil: 
				[ (quoteChars includes: char) 
					ifTrue: [ activeEscapeCharacter := char ]
					ifFalse: 
						[ (delimiterChars includes: char) 
							ifTrue: 
								[ token := ts contents.
								tokens add: token.
								ts := String new writeStream ]
							ifFalse: [ ts nextPut: char ] ] ]
			ifNotNil: 
				[ char == activeEscapeCharacter 
					ifTrue: 
						[ rs peek == activeEscapeCharacter 
							ifTrue: [ ts nextPut: rs next ]
							ifFalse: [ activeEscapeCharacter := nil ] ]
					ifFalse: [ ts nextPut: char ] ] ].
	token := ts contents.
	(tokens isEmpty and: [ token isEmpty ]) ifFalse: [ tokens add: token ].
	^ tokens
]

{ #category : #'finding/searching' }
String >> findTokens: delimiters includes: substring [
	"Divide self into pieces using delimiters.  Return the piece that includes substring anywhere in it.  Is case sensitive (say asLowercase to everything beforehand to make insensitive)."

^ (self findTokens: delimiters) 
	detect: [:str | (str includesSubstring: substring)] 
	ifNone: [nil]
]

{ #category : #'finding/searching' }
String >> findTokens: delimiters keep: keepers [
	"Answer the collection of tokens that result from parsing self.  The tokens are seperated by delimiters, any of a string of characters.  If a delimiter is also in keepers, make a token for it.  (Very useful for carriage return.  A sole return ends a line, but is also saved as a token so you can see where the line breaks were.)"

	| tokens keyStart keyStop |
	tokens := OrderedCollection new.
	keyStop := 1.
	[keyStop <= self size] whileTrue:
		[keyStart := self skipDelimiters: delimiters startingAt: keyStop.
		keyStop to: keyStart-1 do: [:ii | 
			(keepers includes: (self at: ii)) ifTrue: [
				tokens add: (self copyFrom: ii to: ii)]].	"Make this keeper be a token"
		keyStop := self findDelimiters: delimiters startingAt: keyStart.
		keyStart < keyStop
			ifTrue: [tokens add: (self copyFrom: keyStart to: (keyStop - 1))]].
	^tokens
]

{ #category : #'finding/searching' }
String >> findWordStart: key startingAt: start [
	| ind |
	"HyperCard style searching.  Answer the index in self of the substring key, when that key is preceeded by a separator character.  Must occur at or beyond start.  The match is case-insensitive.  If no match is found, zero will be returned."

	ind := start.
	[ind := self findString: key startingAt: ind caseSensitive: false.
	ind = 0 ifTrue: [^ 0].	"not found"
	ind = 1 ifTrue: [^ 1].	"First char is the start of a word"
	(self at: ind-1) isSeparator] whileFalse: [ind := ind + 1].
	^ ind	"is a word start"
]

{ #category : #enumerating }
String >> flattenOn: aStream [
		aStream nextPut: self
]

{ #category : #formatting }
String >> format: collection [
	"Format the receiver by interpolating elements from collection, as in the following examples:" 
	"('Five is {1}.' format: { 1 + 4}) >>> 'Five is 5.'"
	"('Five is {five}.' format: (Dictionary with: #five -> 5)) >>>  'Five is 5.'"
	"('In {1} you can escape \{ by prefixing it with \\' format: {'strings'}) >>> 'In strings you can escape { by prefixing it with \' "
	"('In \{1\} you can escape \{ by prefixing it with \\' format: {'strings'}) >>> 'In {1} you can escape { by prefixing it with \' "

	^ self species
		new: self size
		streamContents: [ :result | 
			| stream |
			stream := self readStream.
			[ stream atEnd ]
				whileFalse: [ | currentChar |
					(currentChar := stream next) == ${
						ifTrue: [ | expression index |
							expression := stream upTo: $}.
							index := Integer readFrom: expression ifFail: [ expression ].
							result nextPutAll: (collection at: index) asString ]
						ifFalse: [ currentChar == $\
								ifTrue: [ stream atEnd
										ifFalse: [ result nextPut: stream next ] ]
								ifFalse: [ result nextPut: currentChar ] ] ] ]
]

{ #category : #testing }
String >> hasWideCharacterFrom: start to: stop [
	"Return true if one of my character in the range does not fit in a single byte"
	
	"Implementation note: inline #anySatisfy: here for efficiency reasons"
	^(self indexOfWideCharacterFrom: start to: stop) ~= 0
]

{ #category : #comparing }
String >> hash [
	"#hash is implemented, because #= is implemented"
	"ar 4/10/2005: I had to change this to use ByteString hash as initial 
	hash in order to avoid having to rehash everything and yet compute
	the same hash for ByteString and WideString."
	^ self class stringHash: self initialHash: ByteString hash
]

{ #category : #comparing }
String >> howManyMatch: string [ 
	"Count the number of characters in a substring that matches up in self and aString."
	"('ab ab ac de' howManyMatch: 'ab') >>> 2"
	"('abab ac de' howManyMatch: 'abab') >>> 4"
	"('ab ab ac de' howManyMatch: 'a') >>> 1"
	"('ab ab ac de' howManyMatch: 'z') >>> 0"
	
	| count shorterLength |
	count := 0.
	shorterLength := self size min: string size.
	1 to: shorterLength do: [:index |
		(self at: index) = (string at: index )
			ifTrue: [ count := count + 1 ]].
	^  count 
	
	
]

{ #category : #testing }
String >> includesSubstring: substring [
	"Returns whether the receiver contains the argument."
	"('abcdefgh' includesSubstring: 'de') >>> true"
	
	^ substring isEmpty or: [ (self findString: substring startingAt: 1) > 0 ]
]

{ #category : #'finding/searching' }
String >> includesSubstring: substring at: index [

	"Answer true if the receiver contains the substring str exactly at index, false otherwise."

	"('abcdefgh' includesSubstring: 'de' at: 1) >>> false"
	"('abcdefgh' includesSubstring: 'de' at: 4) >>> true"

	| pos |
	pos := index - 1.

	^ index > 0 & (self size - pos >= substring size) and: [ 
		  substring allSatisfy: [ :char | 
			  pos := pos + 1.
			  (self at: pos) = char ] ]
]

{ #category : #testing }
String >> includesSubstring: aString caseSensitive: caseSensitive [
	"Returns whether the receiver contains the argument."
	"('abcdefgh' includesSubstring: 'de' caseSensitive: false) >>> true"
	"('abcdefgh' includesSubstring: 'DE' caseSensitive: false) >>> true"
	"('abcDefgh' includesSubstring: 'De' caseSensitive: true) >>> true"
	"('abcDefgh' includesSubstring: 'DE' caseSensitive: true) >>> false"
	
	^ (self findString: aString startingAt: 1 caseSensitive: caseSensitive) > 0
]

{ #category : #testing }
String >> includesUnifiedCharacter [
	^false
]

{ #category : #accessing }
String >> indexOf: aCharacter [
	"Return the index starting at 1 of the argument in the receiver, zero if not present."
	"('abcdf' indexOf: $a) >>> 1"
	"('abddf' indexOf: $k) >>> 0"
	
	aCharacter isCharacter ifFalse: [^ 0].
	^ self class
		indexOfAscii: aCharacter asciiValue
		inString: self
		startingAt: 1.

]

{ #category : #accessing }
String >> indexOf: aCharacter startingAt: start [
	"Return the index of the argument in the receiver, only elements after the start of the element are considered zero if not present."
	
	"('abcdf abcedf' indexOf: $a startingAt: 4) >>> 7"
	"('abddf bcdef' indexOf: $a startingAt: 100 ) >>> 0"
	
	(aCharacter isCharacter) ifFalse: [^ 0].
	^ self class indexOfAscii: aCharacter asciiValue inString: self startingAt: start
]

{ #category : #accessing }
String >> indexOf: aCharacter startingAt: start ifAbsent: aBlock [
	| ans |
	aCharacter isCharacter ifFalse: [ ^ aBlock value ].
	ans := self class indexOfAscii: aCharacter asciiValue inString: self startingAt: start.
	^ ans = 0
		ifTrue: [ aBlock value ]
		ifFalse: [ ans ]
]

{ #category : #accessing }
String >> indexOfFirstUppercaseCharacter [
	"Returns the index of the first Uppercase character.
	'uouFauhZ ' indexOfFirstUppercaseCharacter2 -> 4
	New implementation much faster than older one.
	"
	| size |
	size := self size.
	1 to: size do: [:i| 
		(self at: i) isUppercase 
			ifTrue: [^ i ]].
	^ 0
]

{ #category : #accessing }
String >> indexOfSubCollection: sub [ 
	""

	^ self
		indexOfSubCollection: sub
		startingAt: 1
		ifAbsent: [0]
]

{ #category : #accessing }
String >> indexOfSubCollection: sub startingAt: start ifAbsent: exceptionBlock [
	| index |
	index := self findString: sub startingAt: start.
	index = 0 ifTrue: [^ exceptionBlock value].
	^ index
]

{ #category : #testing }
String >> indexOfWideCharacterFrom: start to: end [
	"Return the index of the first wide character following anIndex"
	"Implementation note: inline #anySatisfy: here for efficiency reasons"
	
	start to: end do: [:ix | 
		(self basicAt: ix) > 255 ifTrue: [ ^ix ]].
	^ 0
]

{ #category : #converting }
String >> initialIntegerOrNil [
	"Answer the integer represented by the leading digits of the receiver, or nil if the receiver does not begin with a digit"
	"'234Whoopie' initialIntegerOrNil >>> 234"
	"'wimpy' initialIntegerOrNil >>> nil"
	"'234' initialIntegerOrNil >>> 234"
	"'2N' initialIntegerOrNil >>> 2"
	"'2' initialIntegerOrNil >>> 2"
	"'  89Ten ' initialIntegerOrNil >>> nil"
	"'78 92' initialIntegerOrNil >>> 78"
	"'3.1415' initialIntegerOrNil >>> 3"
	
	| firstNonDigit |
	(self size = 0 or: [ self first isDigit not ]) 
		ifTrue: [ ^ nil ].
	firstNonDigit := (self findFirst: [ :m | m isDigit not ]).
	firstNonDigit = 0 ifTrue: [ firstNonDigit := self size + 1 ].
	^ (self copyFrom: 1  to: (firstNonDigit - 1)) asNumber
]

{ #category : #testing }
String >> isAllAlphaNumerics [
	"Returns whether the receiver is composed entirely of alphanumerics (i.e., letters or digits)."
	"'3.123' isAllAlphaNumerics >>> false"
	"'a3123abc' isAllAlphaNumerics >>> true"
	"'3123' isAllAlphaNumerics >>> true"
	"'3,123' isAllAlphaNumerics >>> false"
	"'a''b' isAllAlphaNumerics >>> false"
	
	self do: [:c | c isAlphaNumeric ifFalse: [^ false]].
	^ true
]

{ #category : #testing }
String >> isAllDigits [
	"Return whether the receiver is composed entirely of digits and has at least one digit"
	"'2345' isAllDigits >>> true"
	"'0002345' isAllDigits >>> true"
	"'2345.88' isAllDigits >>> false"
	
	self do: [:c | c isDigit ifFalse: [^ false]].
	self ifEmpty: [^false].
	^ true
]

{ #category : #testing }
String >> isAllSeparators [
	"Returns whether the receiver is composed entirely of separators i.e., a space, tab, lf, cr, and newPage"
	"(Character space asString, Character space asString) isAllSeparators >>> true"
	"(Character space asString, 'a') isAllSeparators >>> false"
	self do: [ :c | c isSeparator ifFalse: [ ^false ] ].
	^true
]

{ #category : #testing }
String >> isAsciiString [

	^ self allSatisfy: [ :each | each asciiValue <= 127 ]

]

{ #category : #testing }
String >> isByteString [
	"Answer whether the receiver is a ByteString"
	^false
]

{ #category : #testing }
String >> isLiteral [

	^true
]

{ #category : #testing }
String >> isLiteralSymbol [
	"Test whether a symbol can be stored as # followed by its characters.  
	Symbols created internally with asSymbol may not have this property, 
	e.g. '3' asSymbol."

	| i ascii type next last |
	self flag: 'reuse a parser for this'.
	
	i := self size.
	i = 0 ifTrue: [^ false].

	"TypeTable should have been origined at 0 rather than 1 ..."
	ascii := (self at: 1) asciiValue.
	type := self typeTable at: ascii ifAbsent: [^false].
	type == #xLetter ifTrue: [
		next := last := nil.
		[i > 1]
				whileTrue: 
					[ascii := (self at: i) asciiValue.
					type := self typeTable at: ascii ifAbsent: [^false].
					(type == #xLetter or: [type == #xDigit or: [type == #xColon
							and: [
								next == nil
									ifTrue: [last := #xColon. true] 
									ifFalse: [last == #xColon and: [next ~~ #xDigit and: [next ~~ #xColon]]]]]])
						ifFalse: [^ false].
					next := type.
					i := i - 1].
			^ true].	
	type == #xBinary ifTrue: [^i = 1]. "Here we could extend to
		^(2 to: i) allSatisfy: [:j |
			ascii := (self at: j) asciiValue.
			(self typeTable at: ascii ifAbsent: []) == #xBinary]"
	type == #verticalBar ifTrue: [^i = 1].
	^false
]

{ #category : #testing }
String >> isOctetString [
	"Answer whether the receiver can be represented as a byte string. 
	This is different from asking whether the receiver *is* a ByteString 
	(i.e., #isByteString)"
	1 to: self size do: [:pos |
		(self at: pos) asInteger >= 256 ifTrue: [^ false].
	].
	^ true.

]

{ #category : #testing }
String >> isPatternVariable [

	 ^self keywords anySatisfy: [:each | each first = $`]
]

{ #category : #testing }
String >> isString [
	^ true
]

{ #category : #testing }
String >> isValidGlobalName [

	self ifEmpty: [ ^ false ].
	
	"reserverd default names"
	self = 'NameOfSubclass' ifTrue: [ ^ false ].
	self = 'TNameOfTrait' ifTrue: [ ^ false ].
	
	^ (self first isLetter 
				and: [self first isUppercase]) 
				and: [ self allSatisfy: [:character | 
						character isAlphaNumeric or: [ character = $_ ]]]
]

{ #category : #testing }
String >> isWideString [
	"Answer whether the receiver is a WideString"
	^false
]

{ #category : #splitjoin }
String >> join: aCollection [
	"Append the elements of the argument, aSequenceableCollection, separating them by the receiver."
	"('*' join: #('WWWWW' 'W  EW' 'zzzz')) >>> 'WWWWW*W  EW*zzzz'"
	
	^ self species new: (aCollection size * self size) streamContents: [:stream | 
			aCollection
				do: [:each | stream nextPutAll: each asString] 
				separatedBy: [stream nextPutAll: self]]
]

{ #category : #converting }
String >> keywords [
	"Answer an array of the keywords that compose the receiver."
	| keywords |
	keywords := Array streamContents:
		[:kwds | | char kwd | kwd := (String new: 16) writeStream.
		1 to: self size do:
			[:i |
			kwd nextPut: (char := self at: i).
			char = $: ifTrue: 
					[kwds nextPut: kwd contents.
					kwd reset]].
		(kwd position = 0) ifFalse: [kwds nextPut: kwd contents]].
	(keywords size >= 1 and: [(keywords at: 1) = ':']) ifTrue:
		["Has an initial keyword, as in #:if:then:else:"
		keywords := keywords allButFirst].
	(keywords size >= 2 and: [(keywords at: keywords size - 1) = ':']) ifTrue:
		["Has a final keyword, as in #nextPut::andCR"
		keywords := keywords copyReplaceFrom: keywords size - 1
								to: keywords size with: {':' , keywords last}].
	^ keywords
]

{ #category : #testing }
String >> lastSpacePosition [
	"Answer the character position of the final space or other separator character in the receiver, and 0 if none"
	"'fred the bear' lastSpacePosition >>> 9"
	"'ziggie' lastSpacePosition >>> 0"
	"'elvis ' lastSpacePosition >>> 6"
	"'elvis  ' lastSpacePosition >>> 7"
	"'' lastSpacePosition >>> 0"

	self size to: 1 by: -1 do:
		[:i | ((self at: i) isSeparator) ifTrue: [^ i]].
	^ 0

]

{ #category : #accessing }
String >> lineCorrespondingToIndex: anIndex [
	"Answer a string containing the line at the given character position."

	self lineIndicesDo: [:start :endWithoutDelimiters :end |
		anIndex <= end ifTrue: [^self copyFrom: start to: endWithoutDelimiters]].
	^''
]

{ #category : #accessing }
String >> lineCount [
	"Answer the number of lines represented by the receiver, where every line delimiter CR, LF or CRLF pair adds one line."

	| lineCount |
	lineCount := 0.
	self lineIndicesDo: [:start :endWithoutDelimiters :end |
		lineCount := lineCount + 1].
	^lineCount
]

{ #category : #accessing }
String >> lineIndicesDo: aBlock [
	"execute aBlock with 3 arguments for each line:
	- start index of line
	- end index of line without line delimiter
	- end index of line including line delimiter(s) CR, LF or CRLF"
	
	| cr lf start sz nextLF nextCR |
	start := 1.
	sz := self size.
	cr := Character cr.
	nextCR := self indexOf: cr startingAt: 1.
	lf := Character lf.
	nextLF := self indexOf: lf startingAt: 1.
	[ start <= sz ] whileTrue: [
		(nextLF = 0 and: [ nextCR = 0 ])
			ifTrue: [ "No more CR, nor LF, the string is over"
					aBlock value: start value: sz value: sz.
					^self ].
		(nextCR = 0 or: [ 0 < nextLF and: [ nextLF < nextCR ] ])
			ifTrue: [ "Found a LF"
					aBlock value: start value: nextLF - 1 value: nextLF.
					start := 1 + nextLF.
					nextLF := self indexOf: lf startingAt: start ]
			ifFalse: [ 1 + nextCR = nextLF
				ifTrue: [ "Found a CR-LF pair"
					aBlock value: start value: nextCR - 1 value: nextLF.
					start := 1 + nextLF.
					nextCR := self indexOf: cr startingAt: start.
					nextLF := self indexOf: lf startingAt: start ]
				ifFalse: [ "Found a CR"
					aBlock value: start value: nextCR - 1 value: nextCR.
					start := 1 + nextCR.
					nextCR := self indexOf: cr startingAt: start ]]]
]

{ #category : #accessing }
String >> lineNumber: anIndex [
	"Answer a string containing the characters in the given line number."

	| lineCount |
	lineCount := 0.
	self lineIndicesDo: [:start :endWithoutDelimiters :end |
		(lineCount := lineCount + 1) = anIndex ifTrue: [^self copyFrom: start to: endWithoutDelimiters]].
	^nil
]

{ #category : #accessing }
String >> lineNumberCorrespondingToIndex: anIndex [
	"Answer a lineNumber for the line at the given character position."
	|lineNumber|
	
	lineNumber := 0.
	
	self lineIndicesDo: [:start :endWithoutDelimiters :end |
		lineNumber := lineNumber + 1.
		anIndex <= end ifTrue: [^lineNumber]].
	^lineNumber
]

{ #category : #accessing }
String >> lines [
    "Answer an array of lines composing this receiver without the line ending delimiters"
    ^Array new: (self size // 60 max: 16)
            streamContents: [:lines | self linesDo: [:aLine | lines nextPut: aLine]]
]

{ #category : #accessing }
String >> linesDo: aBlock [
	"Execute aBlock with each line in this string. The terminating line delimiters CR, LF or CRLF pairs are not included in what is passed to aBlock"

	self lineIndicesDo: [:start :endWithoutDelimiters :end |
		aBlock value: (self copyFrom: start to: endWithoutDelimiters)]
]

{ #category : #comparing }
String >> match: text [
	"Answer whether text matches the pattern in this string.
	Matching ignores upper/lower case differences.
	Where this string contains #, text may contain any character.
	Where this string contains *, text may contain any sequence of characters."
	
	"('*' match: 'zort') >>> true"
	"('*baz' match: 'mobaz') >>> true"
	"('*baz' match: 'mobazo') >>>false"
	"('*baz*' match: 'mobazo') >>> true"
	"('*baz*' match: 'mozo') >>> false"
	"('foo*' match: 'foozo') >>> true"
	"('foo*' match: 'bozo') >>> false"
	"('foo*baz' match: 'foo23baz') >>> true"
	"('foo*baz' match: 'foobaz') >>> true"
	"('foo*baz' match: 'foo23bazo') >>> false"
	"('foo' match: 'Foo') >>> true"
	"('foo*baz*zort' match: 'foobazort') >>> false"
	"('foo*baz*zort' match: 'foobazzort') >>> true"
	"('*foo#zort' match: 'afoo3zortthenfoo3zort') >>> true"
	"('*foo*zort' match: 'afoodezortorfoo3zort') >>> true"

	^ self startingAt: 1 match: text startingAt: 1
]

{ #category : #'system primitives' }
String >> numArgs [
	"Answer either the number of arguments that the receiver would take if considered a selector.  Answer -1 if it couldn't be a selector. It is intended mostly for the assistance of spelling correction."

	| firstChar numColons start ix |
	self size = 0 ifTrue: [ ^ -1 ].
	firstChar := self at: 1.
	(firstChar isLetter or: [ firstChar = $_ ])
		ifTrue: [ "Fast reject if any chars are non-alphanumeric
		NOTE: fast only for Byte things - Broken for Wide"
			self class isBytes
				ifTrue: [ (self
						findSubstring: '~'
						in: self
						startingAt: 1
						matchTable: Tokenish) > 0 ifTrue: [ ^ -1 ] ]
				ifFalse: [ 2 to: self size do: [ :i | (self at: i) tokenish ifFalse: [ ^ -1 ] ] ].
			"Fast colon count"
			numColons := 0.
			start := 1.
			[ (ix := self indexOf: $: startingAt: start) > 0 ]
				whileTrue: [ (ix = start or: [ (self at: start) isDigit ]) ifTrue: [ ^ -1 ].
					numColons := numColons + 1.
					start := ix + 1 ].
			numColons = 0 ifTrue: [ ^ 0 ].
			^ self last = $:
				ifTrue: [ numColons ]
				ifFalse: [ -1 ] ].
	"Test case of binary selector, if self allSatisfy: #isSpecial (inlined for speed)"
	1 to: self size do: [ :i | (self at: i) isSpecial ifFalse: [ ^ -1 ] ].
	^ 1
]

{ #category : #converting }
String >> numericSuffix [
	"'abc98' numericSuffix >>> 98"
	"'98abc' numericSuffix >>> 0"
	^ self stemAndNumericSuffix last
]

{ #category : #testing }
String >> occursInWithEmpty: prefix caseSensitive: aBoolean [ 
	"Answer whether the receiver begins with the given prefix string. 
	The comparison is case-sensitive." 
	| matchTable |
	prefix isEmpty ifTrue: [ ^ true ].
	self size < prefix size ifTrue: [ ^ false ].
	matchTable := aBoolean 
		ifTrue: [ CaseSensitiveOrder ]
		ifFalse: [ CaseInsensitiveOrder ].
	^ (self 
		findSubstring: prefix
		in: self
		startingAt: 1
		matchTable: matchTable) > 0
]

{ #category : #converting }
String >> onlyLetters [
	"answer the receiver with only letters"
	^ self select:[:each | each isLetter]
]

{ #category : #copying }
String >> padLeftTo: length [
	^ self padLeftTo: length with: Character space
]

{ #category : #copying }
String >> padLeftTo: length with: char [
	^ (String new: (length - self size max: 0) withAll: char) , self.
]

{ #category : #copying }
String >> padRightTo: length [
	^ self padRightTo: length with: Character space
]

{ #category : #copying }
String >> padRightTo: length with: char [
	^ self, (String new: (length - self size max: 0) withAll: char)
]

{ #category : #printing }
String >> printOn: aStream [ 
	"Print inside string quotes, doubling inbedded quotes."
 
	self storeOn: aStream
]

{ #category : #streaming }
String >> putOn: aStream [
	"Write the receiver onto aStream by iterating over its elements.
	In general we assume aStream accepts the receiver's elements as element type.
	This is an optimisation.
	Return self."

	aStream nextPutAll: self
]

{ #category : #converting }
String >> repeat: aNumber [
	"Returns a new string concatenated by itself repeated n times"
	"('abc' repeat: 3) >>> 'abcabcabc'"

	aNumber < 0 ifTrue: [ self error: 'aNumber cannot be negative' ].	
	^ self species 
		new: self size * aNumber 
		streamContents: [ :stringStream |
			1 to: aNumber do: [ :idx | stringStream nextPutAll: self ] ]
]

{ #category : #private }
String >> replaceFrom: start to: stop with: replacement startingAt: repStart [ 
	"Primitive. This destructively replaces elements from start to stop in the receiver starting at index, repStart, in the collection, replacement. Answer the receiver. Range checks are performed in the primitive only. Optional. See Object documentation whatIsAPrimitive."
	<primitive: 105>
	super replaceFrom: start to: stop with: replacement startingAt: repStart
]

{ #category : #converting }
String >> romanNumber [
	| value v1 v2 |
	value := v1 := v2 := 0.
	self
		reverseDo: [ :each | 
			each = $-
				ifTrue: [ ^ value negated ].
			v1 := #(1 5 10 50 100 500 1000) at: ('IVXLCDM' indexOf: each).
			value := v1 >= v2
				ifTrue: [ value + v1 ]
				ifFalse: [ value - v1 ].
			v2 := v1 ].
	^ value
]

{ #category : #comparing }
String >> sameAs: aString [ 
	"Answer whether the receiver sorts equal to aString. The 
	collation sequence is ascii with case differences ignored."
	^(self compare: aString caseSensitive: false) = 2
]

{ #category : #accessing }
String >> skipAnySubstring: delimiters startingAt: start [

	"Skip any of the delimiters found in receiver, from start onwards, until no delimiter substring matches; answer the position reached. delimiters is an array of strings (characters are accepted, but skipDelimiters:startingAt: handles them better). A string coming earlier in the array is skipped with higher priority. If the end of the receiver is reached, answer size + 1."

	| pos |
	delimiters isString ifTrue: [ 
		^ self skipDelimiters: delimiters startingAt: start ].

	pos := start.
	[ pos <= self size ] whileTrue: [ 
		pos := delimiters
			       detect: [ :delim | 
				       delim isCharacter
					       ifTrue: [ (self at: pos) = delim ]
					       ifFalse: [ self includesSubstring: delim at: pos ] ]
			       ifFound: [ :match | pos + match asString size ]
			       ifNone: [ ^ pos ] ].
	^ self size + 1
]

{ #category : #accessing }
String >> skipDelimiters: delimiters startingAt: start [

	"Answer the index of the first character within the receiver, starting at start, that does NOT match any element of delimiters (a collection of characters). If the end of the receiver is reached, answer size + 1."

	start to: self size do: [ :i | 
		(delimiters anySatisfy: [ :delim | delim = (self at: i) ]) 
			ifFalse: [ ^ i ] ].
	^ self size + 1
]

{ #category : #converting }
String >> squeezeOutNumber [
	"Try to find a number somewhere in this string, as explained in Number>readFrom:
	
	this method returns the first number found"
	
	"'th is is29 a stRI4' squeezeOutNumber >>> 29"
	"'th is is2 9 a stRI4' squeezeOutNumber >>> 2"
	
	^ Number squeezeNumberOutOfString: self
]

{ #category : #comparing }
String >> startingAt: keyStart match: text startingAt: textStart [
	"Answer whether text matches the pattern in this string.
	Matching ignores upper/lower case differences.
	Where this string contains #, text may contain any character.
	Where this string contains *, text may contain any sequence of characters."
	
	| anyMatch matchStart matchEnd i matchStr j ii jj |
	i := keyStart.
	j := textStart.
	
	"Process consecutive *s and #s at the beginning."
	anyMatch := false.
	[ i <= self size and: [
		(self at: i)
			caseOf: {
				[ $* ] -> [ 
					anyMatch := true.
					i := i + 1.
					true ].
				[ $# ] -> [
					i := i + 1.
					j := j + 1.
					true ] }
			otherwise: [ false ] ] ] whileTrue.
	i > self size ifTrue: [
		^j - 1 = text size or: [ "We reached the end by matching the character with a #."
			anyMatch and: [ j <= text size ] "Or there was a * before the end." ] ].
	matchStart := i.

	"Now determine the match string"
	matchEnd := self size.
	(ii := self indexOf: $* startingAt: matchStart) > 0 ifTrue: [ matchEnd := ii-1 ].
	(ii := self indexOf: $# startingAt: matchStart) > 0 ifTrue: [ matchEnd := matchEnd min: ii-1 ].
	matchStr := self copyFrom: matchStart to: matchEnd.

	"Now look for the match string"
	[jj := text findString: matchStr startingAt: j caseSensitive: false.
	anyMatch ifTrue: [jj > 0] ifFalse: [jj = j]]
		whileTrue:
		["Found matchStr at jj.  See if the rest matches..."
		(self startingAt: matchEnd+1 match: text startingAt: jj + matchStr size) ifTrue:
			[^ true "the rest matches -- success"].
		"The rest did not match."
		anyMatch ifFalse: [^ false].
		"Preceded by * -- try for a later match"
		j := j+1].
	^ false "Failed to find the match string"
]

{ #category : #accessing }
String >> startsWithDigit [
	"Answer whether the receiver's first character represents a digit"
	"'abc' startsWithDigit >>> false"
	"'0abc' startsWithDigit >>> true"
	"'1abc' startsWithDigit >>> true"
	"'11abc' startsWithDigit >>> true"
	
	^ self size > 0 and: [self first isDigit]
]

{ #category : #converting }
String >> stemAndNumericSuffix [
	"Parse the receiver into a string-valued stem and a numeric-valued suffix."
	"'Fred2305' stemAndNumericSuffix"

	| stem suffix position |

	stem := self.
	suffix := 0.
	position := 1.
	[stem endsWithDigit and: [stem size > 1]] whileTrue:
		[suffix :=  stem last digitValue * position + suffix.
		position := position * 10.
		stem := stem copyFrom: 1 to: stem size - 1].
	^ Array with: stem with: suffix

]

{ #category : #printing }
String >> storeOn: aStream [
	"Print inside string quotes, doubling inbedded quotes."

	"(String streamContents: [ :s | 'Foo''Bar' storeOn: s ]) >>> '''Foo''''Bar'''"

	| x |
	aStream nextPut: $'.
	1 to: self size do: [ :i | 
		aStream nextPut: (x := self at: i).
		x = $' ifTrue: [ aStream nextPut: x ] ].
	aStream nextPut: $'
]

{ #category : #accessing }
String >> string [
	^self
]

{ #category : #private }
String >> stringhash [

	^ self hash.

]

{ #category : #converting }
String >> substrings [
	"Answer an array of non-empty substrings from the receiver separated by
	one or more whitespace characters."
	
	"'let us make seperate strings' substrings >>>  #('let' 'us' 'make' 'seperate' 'strings')"

	^ self substrings: CSSeparators
]

{ #category : #converting }
String >> substrings: separators [
	"Answer an array of non-empty substrings from the receiver separated by
	one or more characters from the 'separators' argument collection."

	| substrings substringStart |
	substrings := (Array new: 10) writeStream.
	1 to: self size do: [ :i | 
		| nextChar |
		nextChar := self at: i.
		(separators includes: nextChar)
			ifTrue: [
				substringStart
					ifNotNil: [
						substrings nextPut: (self copyFrom: substringStart to: i - 1).
						substringStart := nil ] ]
			ifFalse: [ substringStart ifNil: [ substringStart := i ] ] ].
	substringStart
		ifNotNil: [ substrings nextPut: (self copyFrom: substringStart to: self size) ].
	^ substrings contents
]

{ #category : #converting }
String >> surroundedBy: aString [
	"Answer the receiver with leading and trailing aString."
	"('hello' surroundedBy: 'abd') >>> 'abdhelloabd'"
	"('hello' surroundedBy: ' abd ') >>> ' abd hello abd '"
	
	^ self species streamContents: [ :s|
		s nextPutAll: aString.
		s nextPutAll: self.
		s nextPutAll: aString ].
]

{ #category : #converting }
String >> surroundedBySingleQuotes [
	"Answer the receiver with leading and trailing quotes."
	"'hello' surroundedBySingleQuotes >>>  '''hello'''"
	"'he''llo' surroundedBySingleQuotes >>> '''he''llo'''"
	"'  hello  ' surroundedBySingleQuotes >>>  '''  hello  '''"
	
	^ self surroundedBy: ($' asString)
]

{ #category : #converting }
String >> translateFrom: start  to: stop  table: table [
	"translate the characters in the string by the given table, in place"
	self class translate: self from: start to: stop table: table
]

{ #category : #converting }
String >> translateToLowercase [
	"Translate all characters to lowercase, in place"

	self translateWith: LowercasingTable
]

{ #category : #converting }
String >> translateToUppercase [
	"Translate all characters to lowercase, in place"

	self translateWith: UppercasingTable
]

{ #category : #converting }
String >> translateWith: table [
	"translate the characters in the string by the given table, in place"
	^ self translateFrom: 1 to: self size table: table
]

{ #category : #copying }
String >> trim [
	"Trim separators from both sides of the receiving string."
	"' this string will be trimmed   ' trim >>> 'this string will be trimmed'"
	
	^ self trimBoth
]

{ #category : #copying }
String >> trimBoth [
	"Trim separators from both sides of the receiving string."
	
	^ self trimBoth: [ :char | char isSeparator ]
]

{ #category : #copying }
String >> trimBoth: aBlock [
	"Trim characters satisfying the condition given in aBlock from both sides of the receiving string."

	^ self trimLeft: aBlock right: aBlock
]

{ #category : #copying }
String >> trimLeft [
	"Trim separators from the left side of the receiving string."
	
	^ self trimLeft: [ :char | char isSeparator ] 
]

{ #category : #copying }
String >> trimLeft: aBlock [
	"Trim characters satisfying the condition given in aBlock from the left side of the receiving string."
	
	^ self trimLeft: aBlock right: [ :char | false ]
]

{ #category : #copying }
String >> trimLeft: aLeftBlock right: aRightBlock [
	"Trim characters satisfying the condition given in aLeftBlock from the left side and aRightBlock from the right sides of the receiving string."

	| left right |
	left := 1.
	right := self size.
	
	[ left <= right and: [ aLeftBlock value: (self at: left) ] ]
		whileTrue: [ left := left + 1 ].
		
	[ left <= right and: [ aRightBlock value: (self at: right) ] ]
		whileTrue: [ right := right - 1 ].
		
	^ self copyFrom: left to: right
]

{ #category : #copying }
String >> trimLineSpaces [
	"Trim the spaces from the right side of each line. Useful for code"
	
	^ self species streamContents: [ :str |
		self lines 
			do: [ :line | str nextPutAll: line trimRight]
			separatedBy: [str cr]]
		

]

{ #category : #copying }
String >> trimRight [
	"Trim separators from the right side of the receiving string."
	
	^ self trimRight: [ :char | char isSeparator ]
]

{ #category : #copying }
String >> trimRight: aBlock [
	"Trim characters satisfying the condition given in aBlock from the right side of the receiving string."

	^ self trimLeft: [ :char | false ] right: aBlock
]

{ #category : #copying }
String >> trimmed [
	^ self trimBoth
]

{ #category : #converting }
String >> truncateTo: smallSize [
	"return myself or a copy shortened to smallSize."

	^ self size <= smallSize
		ifTrue: [ self ]
		ifFalse: [ self copyFrom: 1 to: smallSize ]
]

{ #category : #converting }
String >> truncateWithElipsisTo: maxLength [
	"Return myself or a copy suitably shortened but with elipsis added"

	^ self size <= maxLength
		ifTrue:
			[self]
		ifFalse:
			[(self copyFrom: 1 to: (maxLength - 3)), '...']


	"'truncateWithElipsisTo:' truncateWithElipsisTo: 20"
]

{ #category : #accessing }
String >> typeTable [
	^ self class typeTable
]

{ #category : #converting }
String >> uncapitalized [
	"Return a copy with the first letter downShifted (in lower case)"
	
	| answer |
	self ifEmpty: [ ^ self copy ].
	answer := self copy.
	answer at: 1 put: answer first asLowercase.
	^ answer
]

{ #category : #converting }
String >> unescapeCharacter: aCharacter [
	"Unescape an escaped string. Assume the string has all occurrences of aCharacter are escaped. That is, they are in pairs.
	This method returns a copy of the string replacing all pairs of aCharacter by a single appearance of it."
	
	"('''''' unescapeCharacter: $') >>> ''''"
	"('''' unescapeCharacter: $') >>> ''"
	
	| result stream |
	result := WriteStream with: ''.
	stream := ReadStream on: self.
	[ stream atEnd ] whileFalse: 
			[ result nextPutAll: (stream upTo: aCharacter).
			  stream peek ifNotNil: [result nextPut: stream next]].
	^result contents
]

{ #category : #converting }
String >> withBlanksCondensed [
	"Return a copy of the receiver with leading/trailing blanks (separators) removed
	 and consecutive white spaces (separators) condensed to the first one."

	| trimmed lastBlank |
	trimmed := self trimBoth.
	^ String streamContents: [ :stream | 
			lastBlank := false.
			trimmed
				do: [ :eachChar | 
					(eachChar isSeparator and: [ lastBlank ])
						ifFalse: [ stream nextPut: eachChar ].
					lastBlank := eachChar isSeparator ] ]

	" ' abc  d   ' withBlanksCondensed"
]

{ #category : #formatting }
String >> withCRs [
	"Return a copy of the receiver in which backslash (\) characters have been replaced with carriage returns. For example '-hello\-hi' will be
	'-hello
	 -hi'"

	^ self collect: [ :c | c = $\ ifTrue: [ Character cr ] ifFalse: [ c ]].
]

{ #category : #'platform conventions' }
String >> withInternalLineEndings [
	"Answer a new instance where all occurrences of CRLF and LF are substituted with CR. Pharo internally uses CR for carriage return."

	^ self withLineEndings: String cr
]

{ #category : #'platform conventions' }
String >> withInternetLineEndings [
	"change line endings from CR's and LF's to CRLF's.  This is probably in prepration for sending a string over the Internet"
	
	^self withLineEndings: String crlf
]

{ #category : #'platform conventions' }
String >> withLineEndings: lineEndingString [
	"Answer a new instance where all occurrences of CRLF, CR, and LF are substituted with the specified line ending string."
	
	^ self species streamContents: [ :out |
		| in c |
		in := self readStream.
		[ in atEnd ] whileFalse: [
			c := in next.
			"CR"
			c == Character cr ifTrue: [
				c := in peek.
				"CR LF"
				c == Character lf ifTrue: [
					in next.
				].
				out nextPutAll: lineEndingString
			] ifFalse: [
				"LF"
				c == Character lf ifTrue: [
					out nextPutAll: lineEndingString
				] ifFalse: [
					out nextPut: c
				]
			]
		]
	]

]

{ #category : #converting }
String >> withNoLineLongerThan: aNumber [
	"Answer a string with the same content as receiver, but rewrapped so that no line has more characters than the given number"
	(aNumber isNumber not or: [ aNumber < 1 ]) ifTrue: [self error: 'too narrow'].
	^self species
		new: self size * (aNumber + 1) // aNumber "provision for supplementary line breaks"
		streamContents: [ :stream |
			self lineIndicesDo: [ :start :endWithoutDelimiters :end |
				| pastEnd lineStart |
				pastEnd := endWithoutDelimiters + 1.
				"eliminate spaces at beginning of line"
				lineStart := (self indexOfAnyOf: CSNonSeparators startingAt: start ifAbsent: [pastEnd]) min: pastEnd.
				[| lineStop lineEnd spacePosition |
				lineEnd := lineStop  := lineStart + aNumber min: pastEnd.
				spacePosition := lineStart.
				[spacePosition < lineStop] whileTrue: [
					spacePosition := self indexOfAnyOf: CSSeparators startingAt: spacePosition + 1 ifAbsent: [pastEnd].
					spacePosition <= lineStop ifTrue: [lineEnd := spacePosition].
				].
				"split before space or before lineStop if no space"
				stream nextPutAll: (self copyFrom: lineStart to: lineEnd - 1).
				"eliminate spaces at beginning of next line"
				lineStart := self indexOfAnyOf: CSNonSeparators startingAt: lineEnd ifAbsent: [pastEnd].
				lineStart <= endWithoutDelimiters ]
					whileTrue: [stream cr].
				stream nextPutAll: (self copyFrom: pastEnd to: end) ] ]
]

{ #category : #converting }
String >> withSeparatorsCompacted [
    "Returns a copy of the receiver with each sequence of whitespace (separator) 
    characters replaced by a single space character"
    "' test ' withSeparatorsCompacted >>> ' test '"
    "' test  test' withSeparatorsCompacted >>> ' test test'"
    "'test  test      ' withSeparatorsCompacted >>> 'test test '"

    self isEmpty ifTrue: [ ^ self ].
    ^ self species new: self size streamContents: [:stream | 
        | lastBlank |
        lastBlank := false.
        self do: [ :eachChar | 
            lastBlank 
                ifTrue: [
                    (lastBlank := eachChar isSeparator)
                        ifFalse: [ stream nextPut: eachChar ] ] 
                ifFalse: [
                    (lastBlank := eachChar isSeparator)
                        ifTrue: [ stream nextPut: $  ]
                        ifFalse: [ stream nextPut: eachChar ] ] ] ]
]

{ #category : #'platform conventions' }
String >> withUnixLineEndings [
	"Answer a new instance where all occurrences of CRLF and LF are substituted with LF."
	"(('asa' , String cr , 'asa') withUnixLineEndings at: 4) >>> Character lf"

	^ self withLineEndings: String lf
]

{ #category : #converting }
String >> withoutLeadingDigits [
	"Answer the portion of the receiver that follows any leading series of digits and separators.
	If the receiver consists entirely of digits and separators, return an empty string"

	^ self trimLeft: [ :char | char isDigit or: [ char isSeparator ] ]
]

{ #category : #converting }
String >> withoutPeriodSuffix [
	"Return a copy of the receiver up to, but not including, the first period.  If the receiver's *first* character is a period, then just return the entire receiver. "

	| likely |
	likely := self copyUpTo: $..
	^ likely size = 0
		ifTrue: [ self ]
		ifFalse: [ likely ]
]

{ #category : #converting }
String >> withoutPrefix: prefix [
	"Remove the given prefix, if present."

	^(self beginsWith: prefix) ifTrue: [ self copyFrom: 1 + prefix size to: self size ] ifFalse: [ self ]
]

{ #category : #'platform conventions' }
String >> withoutQuoting [
	"remove the initial and final quote marks (single quote for string, or double quotes for comments), if present (and if matches nesting quotes). Have a look at testWithoutQuoting. If you want to remove single/double quotes not in first and last positions of the strings, have a look at copyWithout: $' "

	"'''h''' withoutQuoting >>> 'h'"

	"' ''h'' ' withoutQuoting >>>  ' ''h'' '"

	| quote |
	self size < 2 ifTrue: [ ^ self ].
	quote := self first.
	^ (quote = self last and: [ quote = $' or: [ quote = $" ] ])
		ifTrue: [ self copyFrom: 2 to: self size - 1 ]
		ifFalse: [ self ]
]

{ #category : #converting }
String >> withoutSuffix: suffix [
	"Remove the given suffix, if present."

	^(self endsWith: suffix) ifTrue: [ self copyFrom: 1 to: self size - suffix size ] ifFalse: [ self ]
]

{ #category : #converting }
String >> withoutTrailingDigits [
	"Answer the portion of the receiver that precedes any leading series of digits and separators.
	If the receiver consists entirely of digits and separators, return an empty string"

	^ self trimRight: [ :char | char isDigit or: [ char isSeparator ] ]
]

{ #category : #converting }
String >> withoutTrailingNewlines [
	"Return a copy of the receiver with any combination of cr/lf characters at the end removed"

	^ self trimRight: [ :char | char = Character cr or: [ char = Character lf ] ]
]

{ #category : #accessing }
String >> wordBefore: anIndex [ 
	"('word before index' wordBefore: 4) >>> 'word'"
	"('word before index' wordBefore: 16) >>> 'inde'"
	
	| sep tok |
	tok := false.
	sep := anIndex.
	[ sep > 0 and: [ (self at: sep) tokenish ] ] whileTrue: 
		[ tok := true.
		sep := sep - 1 ]. 
	^ tok 
		ifTrue: 
			[ self 
				copyFrom: sep + 1
				to: anIndex ]
		ifFalse: [ String new ]
]
