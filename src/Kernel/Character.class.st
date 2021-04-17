"
I represent a character by storing its associated Unicode. The first 256 characters are created uniquely, so that all instances of latin1 characters ($R, for example) are identical.

The code point is based on Unicode. Since Unicode is 21-bit wide character set, we have several bits available for other information.  As the Unicode Standard  states, a Unicode code point doesn't carry the language information.  This is going to be a problem with the languages so called CJK (Chinese, Japanese, Korean.  Or often CJKV including Vietnamese).  Since the characters of those languages are unified and given the same code point, it is impossible to display a bare Unicode code point in an inspector or such tools.  To utilize the extra available bits, we use them for identifying the languages.  Since the old implementation uses the bits to identify the character encoding, the bits are sometimes called ""encoding tag"" or neutrally ""leading char"", but the bits rigidly denotes the concept of languages.

The other languages can have the language tag if you like.  This will help to break the large default font (font set) into separately loadable chunk of fonts.  However, it is open to the each native speakers and writers to decide how to define the character equality, since the same Unicode code point may have different language tag thus simple #= comparison may return false.

I represent a character by storing its associated ASCII code (extended to 256 codes). My instances are created uniquely, so that all instances of a character ($R, for example) are identical.
"
Class {
	#name : #Character,
	#superclass : #Magnitude,
	#type : #immediate,
	#classVars : [
		'CharSet',
		'CharacterTable',
		'DigitValues'
	],
	#category : #'Kernel-BasicObjects'
}

{ #category : #'instance creation' }
Character class >> allByteCharacters [
	"Answer all the characters that can be encoded in a byte"
	
	^ (0 to: 255) collect: [:v | Character value: v] as: String

]

{ #category : #'instance creation' }
Character class >> allCharacters [
	"This name is obsolete since only the characters that will fit in a byte can be queried"
	
	^self allByteCharacters
	

]

{ #category : #constants }
Character class >> alphabet [
	"($a to: $z) as: String"

	^ 'abcdefghijklmnopqrstuvwxyz' copy
]

{ #category : #'accessing untypeable characters' }
Character class >> arrowDown [
	^ self value: 31
]

{ #category : #'accessing untypeable characters' }
Character class >> arrowLeft [
	^ self value: 28
]

{ #category : #'accessing untypeable characters' }
Character class >> arrowRight [
	^ self value: 29
]

{ #category : #'accessing untypeable characters' }
Character class >> arrowUp [
	^ self value: 30
]

{ #category : #'accessing untypeable characters' }
Character class >> backspace [
	"Answer the Character representing a backspace."

	^self value: 8
]

{ #category : #'special characters' }
Character class >> centeredDot [
	^self codePoint: 183
]

{ #category : #initialization }
Character class >> characterSet [
	^ CharSet ifNil: [ AsciiCharset ]
]

{ #category : #initialization }
Character class >> characterSet: aCharSet [
	^ CharSet := aCharSet
]

{ #category : #'instance creation' }
Character class >> codePoint: anInteger [ 
	"Just for ANSI Compliance"	
		
	^self value: anInteger
	
]

{ #category : #private }
Character class >> constantNameFor: aCharacter [
	^ self constantNames
		detect: [ :each | (self perform: each) = aCharacter ]
		ifNone: [ nil ].
]

{ #category : #private }
Character class >> constantNames [
	"Added the rest of them!"
	
	^#(backspace cr delete escape lf newPage space tab
		arrowDown arrowLeft arrowRight arrowUp
		enter end home insert nbsp pageDown pageUp null)
]

{ #category : #'accessing untypeable characters' }
Character class >> cr [
	"Answer the Character representing a carriage return."

	^self value: 13
]

{ #category : #'accessing untypeable characters' }
Character class >> delete [
	^ self value: 127
]

{ #category : #'instance creation' }
Character class >> digitValue: x [ 
	"Answer the Character whose digit value is x. For example,
	 answer $9 for x=9, $0 for x=0, $A for x=10, $Z for x=35."

	| n |
	n := x asInteger.
	^self value: (n < 10 ifTrue: [n + 48] ifFalse: [n + 55])
]

{ #category : #'special characters' }
Character class >> divide [
	^self codePoint: 247
]

{ #category : #'accessing untypeable characters' }
Character class >> end [
	^ self value: 4
]

{ #category : #'accessing untypeable characters' }
Character class >> enter [
	"Answer the Character representing enter."

	^self value: 3
]

{ #category : #'accessing untypeable characters' }
Character class >> escape [
	"Answer the ASCII ESC character"

	^self value: 27
]

{ #category : #'accessing untypeable characters' }
Character class >> home [
	^ self value: 1
]

{ #category : #initialization }
Character class >> initialize [
	"Create the DigitsValues table."
 
	self initializeDigitValues
]

{ #category : #initialization }
Character class >> initializeDigitValues [
	"Initialize the well known digit value of ascii characters.
	Note that the DigitValues table is 1-based while ascii values are 0-based, thus the offset+1."
	DigitValues := Array new: 256 withAll: -1.
	"the digits"
	0 to: 9 do: [:i | DigitValues at: 48 + i + 1 put: i].
	 "the uppercase letters"
	10 to: 35 do: [:i | DigitValues at: 55 + i + 1 put: i].
	"the lowercase letters"
	10 to: 35 do: [:i | DigitValues at: 87 + i + 1 put: i]
]

{ #category : #'accessing untypeable characters' }
Character class >> insert [
	^ self value: 5
]

{ #category : #'accessing untypeable characters' }
Character class >> lf [
	"Answer the Character representing a linefeed."

	^self value: 10
]

{ #category : #'accessing untypeable characters' }
Character class >> linefeed [
	"Answer the Character representing a linefeed."

	^self value: 10
]

{ #category : #constants }
Character class >> maxVal [
	"Answer the maximum value (code point) for a Character."

	^ (2 ** 30) - 1
]

{ #category : #'accessing untypeable characters' }
Character class >> nbsp [
	"non-breakable space. Latin1 encoding common usage."

	^ Character value: 160
]

{ #category : #'instance creation' }
Character class >> new [
	"Creating new characters is not allowed."

	self error: 'cannot create new characters'
]

{ #category : #'accessing untypeable characters' }
Character class >> newPage [
	"Answer the Character representing a form feed."

	^self value: 12
]

{ #category : #'accessing untypeable characters' }
Character class >> null [
	^ self value: 0
]

{ #category : #'accessing untypeable characters' }
Character class >> pageDown [
	^ self value: 12
]

{ #category : #'accessing untypeable characters' }
Character class >> pageUp [
	^ self value: 11
]

{ #category : #'special characters' }
Character class >> plusOrMinus [
	^self codePoint: 177
]

{ #category : #'instance creation' }
Character class >> separators [
	"Answer a collection of the standard ASCII separator characters as string."

	^ #(32 "space"
		 13 "cr"
		  9 "tab"
		 10 "line feed"
		 12 "form feed")
		collect: [:v | Character value: v] as: String
]

{ #category : #'accessing untypeable characters' }
Character class >> space [
	"Answer the Character representing a space."

	^self value: 32
]

{ #category : #'special characters' }
Character class >> specialCharacters [
	^ '+-/\*~<>=@,%|&?!' , (String
		   with: self centeredDot
		   with: self divide
		   with: self plusOrMinus
		   with: self times)
]

{ #category : #queries }
Character class >> supportsNonASCII [

	^ (self environment includesKey: #Unicode) and: [ 
		((self environment  at: #EncodedCharSet) charsetAt: 255) name = #Unicode ]
]

{ #category : #'accessing untypeable characters' }
Character class >> tab [
	"Answer the Character representing a tab."

	^self value: 9
]

{ #category : #'special characters' }
Character class >> times [
	^self codePoint: 215
]

{ #category : #'instance creation' }
Character class >> value: anInteger [
	"Answer the Character whose value is anInteger."
	<primitive: 170>
	^self primitiveFailed
]

{ #category : #comparing }
Character >> < aCharacter [ 
	"Answer true if the receiver's value < aCharacter's value."

	^self asciiValue < aCharacter asciiValue
]

{ #category : #comparing }
Character >> = aCharacter [ 
	"Primitive. Answer if the receiver and the argument are the
	 same object (have the same object pointer). Optional. See
	 Object documentation whatIsAPrimitive."
	<primitive: 110>
	^self == aCharacter
]

{ #category : #comparing }
Character >> > aCharacter [ 
	"Answer true if the receiver's value > aCharacter's value."

	^self asciiValue > aCharacter asciiValue
]

{ #category : #converting }
Character >> asCharacter [
	"Answer the receiver itself."

	^ self
]

{ #category : #converting }
Character >> asHTMLString [
	"substitute the < & > into HTML compliant elements"
	
	#($< '&lt;' $> '&gt;' $& '&amp;') pairsDo: [:k :v |
		self = k ifTrue: [^ v]].
	^ String with: self
]

{ #category : #converting }
Character >> asInteger [
	"Answer the receiver's character code."
	<primitive: 171>
	^self primitiveFailed
]

{ #category : #converting }
Character >> asLowercase [
	"If the receiver is uppercase, answer its matching lowercase Character."
	^ self characterSet toLowercase: self
]

{ #category : #converting }
Character >> asString [
	^ String with: self
]

{ #category : #converting }
Character >> asSymbol [ 
	"Answer a Symbol consisting of the receiver as the only element."

	^Symbol internCharacter: self
]

{ #category : #converting }
Character >> asUnicode [

	^ self asInteger
]

{ #category : #converting }
Character >> asUppercase [
	"If the receiver is lowercase, answer its matching uppercase Character."
	^ self characterSet toUppercase: self
	

]

{ #category : #accessing }
Character >> asciiValue [
	"Answer the receiver's character code.
	 This will be ascii for characters with value <= 127,
	 and Unicode for those with higher values."
	<primitive: 171>
	^self primitiveFailed
]

{ #category : #comparing }
Character >> basicIdentityHash [
	"Answer the receiver's character code.
	 The value answered is unsigned. It can in theory be in the full
	 poisitive SmallInteger range, but based on Unicode, it is fair
	 to assume that the value is in the range [ 0 ; 16r3FFFFF ]"
	<primitive: 171>
	^self primitiveFailed
]

{ #category : #converting }
Character >> basicPharoToIso [
	| tmp1 |
	self asInteger < 128
		ifTrue: [ ^ self ].
	self asInteger > 255
		ifTrue: [ ^ self ].
	tmp1 := #(196 197 199 201 209 214 220 225 224 226 228 227 229 231 233 232 234 235 237 236 238 239 241 243 242 244 246 245 250 249 251 252 134 176 162 163 167 149 182 223 174 169 153 180 168 128 198 216 129 177 138 141 165 181 142 143 144 154 157 170 186 158 230 248 191 161 172 166 131 173 178 171 187 133 160 192 195 213 140 156 150 151 147 148 145 146 247 179 253 159 185 164 139 155 188 189 135 183 130 132 137 194 202 193 203 200 205 206 207 204 211 212 190 210 218 219 217 208 136 152 175 215 221 222 184 240 254 255 256)
		at: self asciiValue - 127.
	^ Character value: tmp1
]

{ #category : #testing }
Character >> canBeGlobalVarInitial [
	^ self characterSet canBeGlobalVarInitial: self 
]

{ #category : #testing }
Character >> canBeNonGlobalVarInitial [
  ^ self characterSet canBeNonGlobalVarInitial: self
]

{ #category : #accessing }
Character >> charCode [
	^ self asInteger bitAnd: 4194303
]

{ #category : #accessing }
Character >> characterSet [
	^ self class characterSet
]

{ #category : #accessing }
Character >> codePoint [
	"Just for ANSI Compliance"	
	^self asciiValue
]

{ #category : #copying }
Character >> copy [
	"Answer the receiver, because Characters are unique."
	^self
]

{ #category : #copying }
Character >> deepCopy [
	"Answer the receiver, because Characters are unique."
	^self
]

{ #category : #accessing }
Character >> digitValue [
	self asInteger > 255
		ifTrue: [ ^ self characterSet digitValueOf: self ].
	^ DigitValues at: 1 + self asInteger
]

{ #category : #comparing }
Character >> hash [
	"Hash is reimplemented because = is implemented.
	 Answer the receiver's character code."
	<primitive: 171>
	^self primitiveFailed
]

{ #category : #printing }
Character >> hex [
	"Returns a string representation of the receiver as hex, prefixed with 16r.  
	DO NOT CHANGE THIS!  The Cog VMMaker depends on this."
	"$A hex >>> '16r41'"	
			
	^ self asInteger hex
]

{ #category : #accessing }
Character >> hexDigitValue [
	"Return the case independent hexadecimal digit value of the receiver.
	$0 to: $9 will return 0 to 9, while $a to $f and $A to $F both will return 10 to 15.
	If the receiver does not represent a hexadecimal digit, return nil.
	Returns an integer between 0 and 15."
	
	| codePoint |
	^ ((codePoint := self asInteger) between: 0 and: 127)
		ifTrue: [ #(nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 0 1 2 3 4 5 6 7 8 9 nil nil nil nil nil nil nil 10 11 12 13 14 15 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 10 11 12 13 14 15 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil) at: codePoint + 1 ]
		ifFalse: [ nil ]
]

{ #category : #testing }
Character >> isAlphaNumeric [
	"Answer whether the receiver is a letter or a digit."
	"$a isAlphaNumeric >>> true"
	"$A isAlphaNumeric >>> true"
	"$' isAlphaNumeric >>> false"
	"$1 isAlphaNumeric >>> true"
	"Character space isAlphaNumeric >>> false"

	^ self isLetter or: [ self isDigit ]
]

{ #category : #testing }
Character >> isArrow [

	^ { Character arrowUp. Character arrowDown. Character arrowLeft. Character arrowRight } includes: self
]

{ #category : #testing }
Character >> isCasedLetter [
	"We are sorry but this method is unclear and will probably be removed.
	This method only returning false."
	"$a isCasedLetter >>> false"
	"$A isCasedLetter >>> false"
	
	^ self characterSet isCasedLetter: self
]

{ #category : #testing }
Character >> isCharacter [

	^ true

]

{ #category : #testing }
Character >> isClosePunctuation [
	"Return whether the receiver is one of these characters:  )]}"
	"$a isClosePunctuation >>> false"
	"$( isClosePunctuation >>> false"
	"$) isClosePunctuation >>> true"
	"$] isClosePunctuation >>> true"
	"$} isClosePunctuation >>> true"
	
	^ self characterSet isClosePunctuation: self
]

{ #category : #testing }
Character >> isConnectorPunctuation [
	"Return whether the receiver is one of these characters:   _"
	"$_ isConnectorPunctuation >>> true"
	"$( isConnectorPunctuation >>> false"
	"$) isConnectorPunctuation >>> false"
	"$> isConnectorPunctuation >>> false"
	"$} isConnectorPunctuation >>> false"
	
	^ self characterSet isConnectorPunctuation: self
]

{ #category : #testing }
Character >> isControlOther [
	"Return whether the receiver is one of these characters: backspace, delete, escape, arrowUp, arrowLeft, arrowDown, arrowRight, pageUp, pageDown, end, home, nbsp, insert"
	"Character delete isControlOther >>> true"
	"Character backspace isControlOther >>> true"
	"Character space isControlOther >>> false"
	"Character home isControlOther >>> true"
	"Character pageUp isControlOther >>> true"
	"Character arrowDown isControlOther >>> true"
	"Character end isControlOther >>> true"
	
	"$) isControlOther >>> false"
	"$> isControlOther >>> false"
	"$} isControlOther >>> false"
	
	^ self characterSet isControlOther: self

]

{ #category : #testing }
Character >> isCurrencySymbol [
	"Return whether the receiver is one of these characters:   $ and euro"
	"$$ isCurrencySymbol >>> true"
	"Character euro isCurrencySymbol >>> true"
	"$} isControlOther >>> false"
	
	^ self characterSet isCurrencySymbol: self
]

{ #category : #testing }
Character >> isDashPunctuation [
	"Return whether the receiver is one of these characters:   $-"
	"$- isDashPunctuation >>> true"
	"$_ isDashPunctuation >>> false"
	
	^ self characterSet isDashPunctuation: self
]

{ #category : #testing }
Character >> isDecimalDigit [
	"Return whether the receiver is a digit."
	"$1 isDecimalDigit >>> true"
	"$0 isDecimalDigit >>> true"

	^ self characterSet isDecimalDigit: self
]

{ #category : #testing }
Character >> isDigit [
	"Return whether the receiver is a digit."
	"$1 isDigit >>> true"
	"$0 isDigit >>> true"
	
	^ self characterSet isDigit: self

]

{ #category : #testing }
Character >> isDoubleQuote [
	"Returns whether the receiver is a Double Quote"

	^ self = $"
]

{ #category : #'testing unicode' }
Character >> isEnclosingMark [
	"Return whether the receiver is ... one of these https://www.compart.com/en/unicode/category/Me"
	"$' isEnclosingMark >>> false"
	
	
	^ self characterSet isEnclosingMark: self
]

{ #category : #'testing unicode' }
Character >> isFinalQuote [
	"Return whether the receiver is https://www.compart.com/en/unicode/category/Pf"
	"$' isFinalQuote >>> false"
	
	^ self characterSet isFinalQuote: self
]

{ #category : #'testing unicode' }
Character >> isFormatOther [
	"Return whether the receiver in this category: https://www.compart.com/en/unicode/category/Cf"
	^ self characterSet isFormatOther: self
]

{ #category : #testing }
Character >> isImmediateObject [
	"This is needed for the boostrap"
	^ true
]

{ #category : #'testing unicode' }
Character >> isInitialQuote [
	"Return whether the receiver is https://www.compart.com/en/unicode/category/Pi"
	"$' isInitialQuote >>> false"
	
	^ self characterSet isInitialQuote: self
]

{ #category : #testing }
Character >> isLetter [
	"Return whether the receiver is a letter."
	"$a isLetter >>> true"
	"$é isLetter >>> true"
	"$A isLetter >>> true"

	^ self characterSet isLetter: self

]

{ #category : #'testing unicode' }
Character >> isLetterModifier [
	"Return whether the receiver is https://www.compart.com/en/unicode/category/Lm"
	
	^ self characterSet isLetterModifier: self
]

{ #category : #'testing unicode' }
Character >> isLetterNumber [
	"Return whether the receiver is part of https://www.compart.com/en/unicode/category/Nl"
	^ self characterSet isLetterNumber: self
]

{ #category : #'testing unicode' }
Character >> isLineSeparator [
	"Return whether the receiver is https://www.compart.com/en/unicode/category/Zl"
	
	^ self characterSet isLineSeparator: self
]

{ #category : #'testing kind' }
Character >> isLiteral [

	^ true
]

{ #category : #testing }
Character >> isLowercase [

	^ self characterSet isLowercase: self

]

{ #category : #testing }
Character >> isMathSymbol [
	^ self characterSet isMathSymbol: self
]

{ #category : #testing }
Character >> isModifierSymbol [

	^ self characterSet isModifierSymbol: self
]

{ #category : #testing }
Character >> isNonspacingMark [
^ self characterSet isNonspacingMark: self
]

{ #category : #'testing kind' }
Character >> isOctetCharacter [
	^ self asInteger < 256
]

{ #category : #testing }
Character >> isOpenPunctuation [
^ self characterSet isOpenPunctuation: self
]

{ #category : #testing }
Character >> isOtherLetter [
^ self characterSet isOtherLetter: self
]

{ #category : #testing }
Character >> isOtherNumber [
	^ self characterSet isOtherNumber: self
]

{ #category : #testing }
Character >> isOtherPunctuation [
^ self characterSet isOtherPunctuation: self
]

{ #category : #testing }
Character >> isOtherSymbol [
^ self characterSet isOtherSymbol: self
]

{ #category : #testing }
Character >> isParagraphSeparator [
^ self characterSet isParagraphSeparator: self
]

{ #category : #testing }
Character >> isPrivateOther [
^ self characterSet isPrivateOther: self
]

{ #category : #testing }
Character >> isSafeForHTTP [
	"Return whether a character is 'safe', or needs to be escaped when used, eg, in a URL"
	"See http://www.faqs.org/rfcs/rfc1738.html. ~ is unsafe and has been removed"
	
	^ self charCode < 128
		and: [self isAlphaNumeric
				or: ['.-_' includes: (Character value: self charCode)]]
]

{ #category : #testing }
Character >> isSeparator [
	"Returns whether the receiver is a separator i.e., a space, tab, lf, cr, and newPage"
	"Character space isSeparator >>> true"
	"Character lf isSeparator >>> true"
	"Character cr isSeparator >>> true"
	"Character newPage isSeparator >>> true"
	"Character tab isSeparator >>> true"
	"$' isSeparator >>> false"
	
	| in |
	^ (in := self asInteger) == 32 or: [ in == 13 or: [ in == 9 or: [ in == 10 or: [ in == 12 ] ] ] ]
]

{ #category : #testing }
Character >> isSpaceSeparator [
^ self characterSet isSpaceSeparator: self
]

{ #category : #testing }
Character >> isSpacingCombiningMark [
^ self characterSet isSpacingCombiningMark: self
]

{ #category : #testing }
Character >> isSpecial [
	"Answer whether the receiver is one of the special characters: i.e., +-/\*~<>=@,%|&?! and a couple of others."

	^ self class specialCharacters includes: self

]

{ #category : #testing }
Character >> isSurrogateOther [
^ self characterSet isSurrogateOther: self
]

{ #category : #testing }
Character >> isTitlecaseLetter [
^ self characterSet isTitlecaseLetter: self
]

{ #category : #testing }
Character >> isUppercase [

	^ self characterSet isUppercase: self

]

{ #category : #testing }
Character >> isVowel [
	"Answer whether the receiver is one of the vowels, AEIOU, in upper or 
	lower case."

	^'AEIOU' includes: self asUppercase
]

{ #category : #converting }
Character >> lowercase [
	^ self asLowercase
]

{ #category : #'memory scanning' }
Character >> nextObject [
	"Characters are immediate objects, and, as such, do not have successors in object memory."

	self shouldNotImplement 
]

{ #category : #printing }
Character >> printOn: aStream [
	| name |
	(self asInteger > 32 and: [ self asInteger ~= 127])
		ifTrue: [ aStream nextPut: $$; nextPut: self ]
		ifFalse: [
			name := self class constantNameFor: self.
			aStream nextPutAll: self class name.
			name notNil
				ifTrue: [ aStream space; nextPutAll: name ]
				ifFalse: [ aStream nextPutAll: ' value: '; print: self asInteger ] ]
]

{ #category : #printing }
Character >> printStringHex [
	"$A printStringHex >>> '41'"

	^ self asInteger printStringBase: 16
]

{ #category : #comparing }
Character >> sameAs: aCharacter [ 
	"Answer whether the receiver is equal to aCharacter, ignoring case"
	^ (self asLowercase = aCharacter asLowercase)	
]

{ #category : #private }
Character >> setValue: newValue [
	self error: 'Characters are immutable'
]

{ #category : #copying }
Character >> shallowCopy [
	"Answer the receiver, because Characters are unique."
	^self
]

{ #category : #'testing kind' }
Character >> shouldBePrintedAsLiteral [
	^ self asInteger between: 33 and: 255
]

{ #category : #printing }
Character >> storeBinaryOn: aStream [
	self asInteger < 256
		ifTrue: [ aStream basicNextPut: self asInteger ]
		ifFalse: [ aStream nextInt32Put: self asInteger ]
]

{ #category : #printing }
Character >> storeOn: aStream [
	"Common character literals are preceded by '$', however special need to be encoded differently: for some this might be done by using one of the shortcut constructor methods for the rest we have to create them by ascii-value."

	| name |
	self shouldBePrintedAsLiteral
		ifTrue: [ aStream nextPut: $$; nextPut: self ]
		ifFalse: [
			name := self class constantNameFor: self.
			name notNil
				ifTrue: [ aStream nextPutAll: self class name; space; nextPutAll: name ]
				ifFalse: [
					aStream 
						nextPut: $(; nextPutAll: self class name; 
						nextPutAll: ' value: '; print: self asInteger; nextPut: $) ] ]
]

{ #category : #converting }
Character >> to: other [
	"Answer with a collection in ascii order -- $a to: $z"
	^ (self asciiValue to: other asciiValue) collect:
				[:ascii | Character value: ascii]
]

{ #category : #testing }
Character >> tokenish [
	"Answer whether the receiver is a valid token-character -- letter, digit, underscore, or colon."
	"$' tokenish >>> false"
	"$: tokenish >>> true"
	"${ tokenish >>> false"
	"Character space tokenish >>> false"
	
	^ self isLetter or: [ self isDigit or: [ self = $_ or: [ self = $: ] ] ]
]

{ #category : #converting }
Character >> uppercase [
	^ self asUppercase
]

{ #category : #copying }
Character >> veryDeepCopyWith: deepCopier [
	"Answer the receiver, because Characters are unique."
	^self
]
