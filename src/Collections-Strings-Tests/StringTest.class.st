"
This is the unit test for the class String. Unit tests are a good way to exercise the functionality of your system in a repeatable and automatic manner. They are therefore recommended if you plan to release anything. For more information, see: 
	- http://www.c2.com/cgi/wiki?UnitTest
	- there is a chapter in the PharoByExample book (http://pharobyexample.org/)
	- the sunit class category
"
Class {
	#name : #StringTest,
	#superclass : #CollectionRootTest,
	#traits : 'TIncludesTest + TCloneTest + TCopyTest + TSetArithmetic + TIterateSequencedReadableTest + TPrintOnSequencedTest + TAsStringCommaAndDelimiterSequenceableTest + TIndexAccess + TSequencedElementAccessTest + TSubCollectionAccess + TPutBasicTest + TCopySequenceableSameContents + TCopyPartOfSequenceable + TCopyPartOfSequenceableForMultipliness + TCopySequenceableWithOrWithoutSpecificElements + TCopySequenceableWithReplacement + TReplacementSequencedTest + (TConvertTest - {#testAsByteArray}) + TConvertAsSortedTest + TBeginsEndsWith + (TIndexAccessForMultipliness - {#testIdentityIndexOfIAbsentDuplicate. #testIdentityIndexOfDuplicate. #collectionWithNonIdentitySameAtEndAndBegining}) + TSequencedConcatenationTest + TPutTest + TConvertAsSetForMultiplinessTest + TSortTest + TSequencedStructuralEqualityTest + TOccurrencesForMultiplinessTest + TCreationWithTest',
	#classTraits : 'TIncludesTest classTrait + TCloneTest classTrait + TCopyTest classTrait + TSetArithmetic classTrait + TIterateSequencedReadableTest classTrait + TAsStringCommaAndDelimiterSequenceableTest classTrait + TIndexAccess classTrait + TSequencedElementAccessTest classTrait + TSubCollectionAccess classTrait + TPutBasicTest classTrait + TCopySequenceableSameContents classTrait + TCopyPartOfSequenceable classTrait + TCopyPartOfSequenceableForMultipliness classTrait + TCopySequenceableWithOrWithoutSpecificElements classTrait + TCopySequenceableWithReplacement classTrait + TReplacementSequencedTest classTrait + TConvertTest classTrait + TConvertAsSortedTest classTrait + TBeginsEndsWith classTrait + TIndexAccessForMultipliness classTrait + TSequencedConcatenationTest classTrait + TPrintOnSequencedTest classTrait + TPutTest classTrait + TConvertAsSetForMultiplinessTest classTrait + TSortTest classTrait + TSequencedStructuralEqualityTest classTrait + TOccurrencesForMultiplinessTest classTrait + TCreationWithTest classTrait',
	#instVars : [
		'string',
		'emptyString',
		'elementInNonEmpty',
		'notIn',
		'nonEmpty1element',
		'withoutEqualElements',
		'collectionNotIncluded',
		'indexInNonEmptyArray',
		'sameAtEndAndBegining',
		'nonEmpty5ElementsSorted',
		'unsortedCollection',
		'subcollection3ElementsSorted',
		'arrayWithCharacters'
	],
	#category : #'Collections-Strings-Tests-Base'
}

{ #category : #requirements }
StringTest >> aValue [
	"Return a value to put into nonEmpty"
	
	^ elementInNonEmpty 
]

{ #category : #requirements }
StringTest >> anIndex [
	"Return an index in nonEmpty bounds"
	
	^ 2
]

{ #category : #'tests - includes' }
StringTest >> anotherElementNotIn [
	^ $k
]

{ #category : #requirements }
StringTest >> anotherElementOrAssociationIn [
	" return an element (or an association for Dictionary ) present  in 'collection' "
	^ self collection  anyOne
]

{ #category : #requirements }
StringTest >> anotherElementOrAssociationNotIn [
	" return an element (or an association for Dictionary )not present  in 'collection' "
	^ notIn 
]

{ #category : #requirements }
StringTest >> anotherValue [
	"Return a value (not equal to 'aValue') to put into nonEmpty"
	
	^ self nonEmpty anyOne
]

{ #category : #coverage }
StringTest >> classToBeTested [
	^ String
]

{ #category : #'tests - includes' }
StringTest >> collection [
	^ 'ghj'
]

{ #category : #'tests - set arithmetic' }
StringTest >> collectionClass [
	"Return the class to be used to create instances of the class tested"

	^ String
]

{ #category : #requirements }
StringTest >> collectionMoreThan1NoDuplicates [
	" return a collection of size > 1 without equal elements"
	^ withoutEqualElements 
]

{ #category : #requirements }
StringTest >> collectionMoreThan5Elements [
" return a collection including at least 5 elements"
	
	^ nonEmpty5ElementsSorted 
]

{ #category : #requirements }
StringTest >> collectionNotIncluded [
	"Return a collection for wich each element is not included in 'nonEmpty'"

	^ collectionNotIncluded  
]

{ #category : #requirements }
StringTest >> collectionWith1TimeSubcollection [
	"Return a collection including 'oldSubCollection' only one time"
	
	^ nonEmpty5ElementsSorted
]

{ #category : #requirements }
StringTest >> collectionWith2TimeSubcollection [
	"Return a collection including 'oldSubCollection' two or many time"
	
	^ nonEmpty5ElementsSorted, subcollection3ElementsSorted 
]

{ #category : #requirements }
StringTest >> collectionWithElement [
	"Returns a collection that already includes what is returned by #element."
	^ nonEmpty5ElementsSorted
]

{ #category : #requirements }
StringTest >> collectionWithElementsToRemove [
	"Return a collection of elements included in 'nonEmpty'"

	^ subcollection3ElementsSorted 
]

{ #category : #requirements }
StringTest >> collectionWithEqualElements [
	"Return a collecition including atLeast two elements equal"

	^ sameAtEndAndBegining 
]

{ #category : #requirements }
StringTest >> collectionWithSameAtEndAndBegining [
	"Return a collection with elements at end and begining equals
	 (other elements of the collection are not equal to those elements)"

	^ sameAtEndAndBegining 
]

{ #category : #requirements }
StringTest >> collectionWithSortableElements [
	"Return a collection only including elements that can be sorted (understanding '<')"

	^ nonEmpty5ElementsSorted
]

{ #category : #requirements }
StringTest >> collectionWithoutEqualElements [
	"Return a collection not including equal elements"
	
	^ withoutEqualElements 
]

{ #category : #requirements }
StringTest >> collectionWithoutNilElements [
	"Return a collection that doesn't include a nil element and that doesn't include equal elements'"

	^ nonEmpty5ElementsSorted
]

{ #category : #requirements }
StringTest >> element [
	"Returns an object that can be added to the collection returned by #collection."
	
	^ elementInNonEmpty 
]

{ #category : #requirements }
StringTest >> elementInForElementAccessing [
	"Return an element included in 'moreThan4Elements'"
	
	^ self moreThan4Elements anyOne
]

{ #category : #requirements }
StringTest >> elementInForIncludesTest [
	"Return an element included in nonEmpty"
	
	^ elementInNonEmpty 
]

{ #category : #requirements }
StringTest >> elementInForIndexAccessing [
" return an element included in 'accessCollection' "
	^ withoutEqualElements anyOne
]

{ #category : #requirements }
StringTest >> elementNotIn [
	"Return an element not included in 'nonEmpty'"

	^notIn 
]

{ #category : #requirements }
StringTest >> elementNotInForElementAccessing [
	"Return an element not included in 'moreThan4Elements'"

	^ notIn 
]

{ #category : #requirements }
StringTest >> elementNotInForIndexAccessing [
	"Return an element not included in 'accessCollection'"
	
	^ notIn 
]

{ #category : #'tests - includes' }
StringTest >> elementNotInForOccurrences [
	^ $z
]

{ #category : #'tests - copy' }
StringTest >> elementToAdd [
	^ $u
]

{ #category : #requirements }
StringTest >> elementTwiceInForOccurrences [
" return an element included exactly two time in # collectionWithEqualElements"
^ sameAtEndAndBegining first .
]

{ #category : #requirements }
StringTest >> empty [
	^ emptyString
]

{ #category : #'tests - indexof' }
StringTest >> findFirstInString: aString fromString: searchString [

	^ String findFirstInString: aString inSet: (CharacterSet newFrom: searchString) byteArrayMap startingAt: 1
]

{ #category : #requirements }
StringTest >> firstCollection [
	"Return a collection that will be the first part of the concatenation"
	
	^ nonEmpty5ElementsSorted
]

{ #category : #requirements }
StringTest >> firstIndex [
	"Return an index between 'nonEmpty' bounds that is < to 'second index'"

	^3
]

{ #category : #requirements }
StringTest >> indexArray [
	"Return a Collection including indexes between bounds of 'nonEmpty'"

	^ indexInNonEmptyArray 
]

{ #category : #requirements }
StringTest >> indexInForCollectionWithoutDuplicates [
	"Return an index between 'collectionWithoutEqualsElements' bounds"
	
	^ 2
]

{ #category : #requirements }
StringTest >> indexInNonEmpty [
	"Return an index between bounds of 'nonEmpty'"

	^ 2
]

{ #category : #requirements }
StringTest >> integerCollectionWithoutEqualElements [
	"Return a collection of integer without equal elements"	
		
	^ nonEmpty5ElementsSorted
]

{ #category : #requirements }
StringTest >> moreThan3Elements [
	"Return a collection including at least 3 elements"
	
	^ nonEmpty5ElementsSorted
]

{ #category : #requirements }
StringTest >> moreThan4Elements [
	"Return a collection including at least 4 elements"

	^ nonEmpty5ElementsSorted
]

{ #category : #requirements }
StringTest >> newElement [
	"Return an element that will be put in the collection in place of another"
	
	^ elementInNonEmpty 
]

{ #category : #requirements }
StringTest >> nonEmpty [
	^ nonEmpty5ElementsSorted
]

{ #category : #requirements }
StringTest >> nonEmpty1Element [
	"Return a collection of size 1 including one element"
	
	^ nonEmpty1element 
]

{ #category : #requirements }
StringTest >> nonEmptyMoreThan1Element [
	"Return a collection that don't includes equal elements'"
	
	^ nonEmpty5ElementsSorted
]

{ #category : #requirements }
StringTest >> oldSubCollection [
	"Return a subCollection included in collectionWith1TimeSubcollection.
		Example:  subCollection := #( 2 3 4) and collectionWith1TimeSubcollection := #(1 2 3 4 5)"
		
	^ subcollection3ElementsSorted  
]

{ #category : #requirements }
StringTest >> otherCollection [
	"Returns a collection that does not include what is returned by #element."
	
	^ collectionNotIncluded 
]

{ #category : #requirements }
StringTest >> replacementCollection [
	"Return a collection that will be used to replace 'oldSubcollection' in ' 	 collectionWith1TimeSubcollection'" 
	^ string
]

{ #category : #requirements }
StringTest >> replacementCollectionSameSize [
	"Return a collection of size (secondIndex - firstIndex + 1)"
	
	^nonEmpty1element 
]

{ #category : #requirements }
StringTest >> secondCollection [
	"Return a collection that will be the second part of the concatenation"
	
	^ nonEmpty1element 
]

{ #category : #requirements }
StringTest >> secondIndex [
	"Return an index between 'nonEmpty' bounds that is > to 'second index'"
	
	^ self firstIndex 
]

{ #category : #running }
StringTest >> setUp [
	super setUp.
	string := 'Hi, I am a String'.
	emptyString := ''.
	subcollection3ElementsSorted := 'bcd'.
	nonEmpty5ElementsSorted := 'a' , subcollection3ElementsSorted , 'e'.
	unsortedCollection := 'azsbe' copy.
	indexInNonEmptyArray := #(1 3 2 ).
	arrayWithCharacters := #($a $b $c ).
	nonEmpty1element := 'a'.
	withoutEqualElements := 'abcde'.
	
	sameAtEndAndBegining := 'abca'.
	elementInNonEmpty := $c.
	collectionNotIncluded := notIn asString , notIn asString.
	notIn := $z
]

{ #category : #requirements }
StringTest >> sizeCollection [
	"Answers a collection whose #size is 4"
	^ 'abcd'
]

{ #category : #requirements }
StringTest >> sortedInAscendingOrderCollection [
" return a collection sorted in an acsending order"
	^nonEmpty5ElementsSorted 
	
]

{ #category : #requirements }
StringTest >> subCollectionNotIn [
	"Return a collection for which at least one element is not included in 'moreThan4Elements'"
	
	^ collectionNotIncluded 
]

{ #category : #tests }
StringTest >> testAlike [

	self assert: ('test' alike: 'test') >= 8.   "twice second argument size is the best score"
	self assert: ('TEST' alike: 'test') >= 8.   "case is ignored"
	self assert: ('é è à ô ü ö ß ä ó ñ í á' alike: 'test') equals: 0. 
	self assert: ('é è à ô ü ö' alike: 'é è à ô ü ö ß ä ó ñ í á') >= 10. 
	self assert: ('eeeee' alike: 'ééééé') <= 1  "evaluation based on ascii value"
]

{ #category : #tests }
StringTest >> testAllRangesOfSubstring [

	self assert: ('aabbccbb' allRangesOfSubstring: 'bb' ) equals: {(3 to: 4). (7 to: 8)}.
	self assert: ('é è à ô ü ö ß ä ó ñ í á' allRangesOfSubstring: 'ö ß ä') equals: {(11 to: 15)}.
	self assert: ('test' allRangesOfSubstring: '') equals: #()
]

{ #category : #'tests - converting' }
StringTest >> testAsCamelCase [

	self assert: 'A man, a plan, a canal, panama' asCamelCase equals: 'AMan,APlan,ACanal,Panama'.
	self assert: 'Here 123should % be 6 the name6 of the method' asCamelCase equals: 'Here123should%Be6TheName6OfTheMethod'.
 
]

{ #category : #tests }
StringTest >> testAsDate [

	self assert: 'Jan 1 2015' asDate asString equals: '1 January 2015'. 
	self assert: '1/1/2015' asDate asString equals: '1 January 2015'.
	self assert: '1 1 1' asDate asString equals: '1 January 2001'.
	self assert: '1 J 1' asDate asString equals: '1 January 2001'.
	self should: [ '' asDate ] raise: Error.
	self should: [ '1234' asDate ] raise: Error 
]

{ #category : #tests }
StringTest >> testAsHTMLString [

	self assert: '<a>' asHTMLString equals: '&lt;a&gt;'.
	self assert: '<!DOCTYPE html>' asHTMLString equals: '&lt;!DOCTYPE html&gt;'. 
	self assert: 'é è à ô ü ö ß ä ó ñ í á' asHTMLString equals: 'é è à ô ü ö ß ä ó ñ í á'.
	self assert: '' asHTMLString equals: ''
]

{ #category : #'tests - converting' }
StringTest >> testAsInteger [

	self assert: '1796exportFixes-tkMX' asInteger equals: 1796.
	self assert: 'donald' asInteger isNil.
	self assert: 'abc234def567' asInteger equals: 234.
	self assert: '-94' asInteger equals: -94.
	self assert: 'foo-bar-92' asInteger equals: -92
]

{ #category : #tests }
StringTest >> testAsLowercase [ 

	self assert: '1 2 3 É È À Ô Ü Ö ẞ t e s T' asLowercase equals: '1 2 3 é è à ô ü ö ß t e s t'.
	self assert: '!@#$' asLowercase equals: '!@#$'.
	self assert: '' asLowercase equals: ''
]

{ #category : #tests }
StringTest >> testAsPluralBasedOn [

	self assert: ('test' asPluralBasedOn: #(1)) equals: 'test'.
	self assert: ('test' asPluralBasedOn: #(1 2 3)) equals: 'tests'.
	self assert: ('test' asPluralBasedOn: 1) equals: 'test'.
	self assert: ('test' asPluralBasedOn: false) equals: 'tests'.
	self assert: ('é è à ô ü ö ß ä ó ñ í á' asPluralBasedOn: 10) equals: 'é è à ô ü ö ß ä ó ñ í ás'.
	self assert: ('' asPluralBasedOn: 1) equals: ''.
	self assert: ('%' asPluralBasedOn: 10) equals: '%s'
]

{ #category : #tests }
StringTest >> testAsSignedInteger [

	self assert: 'test' asSignedInteger isNil.
	self assert: 'é è à ô ü ö ß ä ó ñ í á' asSignedInteger isNil.
	self assert: 'test-10test' asSignedInteger equals: -10.
	self assert: ('' asSignedInteger) equals: nil.
	self assert: '1234567890-1234567890' asSignedInteger equals: 1234567890.
	self assert: '--12345' asSignedInteger equals: -12345
]

{ #category : #'tests - converting' }
StringTest >> testAsSmalltalkComment [
	| exampleStrings |
	exampleStrings := #('' ' ' '"' '""' '"""' 'abc"abc' 'abc""abc' 'abc"hello"abc' 'abc"' '"abc').

	"check that the result of scanning the comment is empty"
	exampleStrings
		do: [ :s | 
			| tokens |
			tokens := s asComment parseLiterals.
			self assertEmpty: tokens ].

	"check that the result has the same non-quote characters as the original"
	exampleStrings do: [ :s | self assert: (s copyWithout: $") equals: (s asComment copyWithout: $") ].

	"finnaly, test for some common kinds of inputs"
	self assert: 'abc' asComment equals: '"abc"'.
	self assert: 'abc"abc' asComment equals: '"abc""abc"'.
	self assert: 'abc""abc' asComment equals: '"abc""abc"'
]

{ #category : #tests }
StringTest >> testAsString [ 

	self assert: 123 asString equals: '123'.
	self assert: #(1 2 3) asString equals: '#(1 2 3)'.
	self assert: (OrderedCollection new) asString equals: 'an OrderedCollection()'.
	self assert: (1 < 3) asString equals: 'true'.
	self assert: 'é è à ô ü ö ß ä ó ñ í á' asString equals: 'é è à ô ü ö ß ä ó ñ í á'.
	self assert: '' asString equals: ''
]

{ #category : #tests }
StringTest >> testAsSymbol [
	self assert: 'hel' , 'lo' asSymbol equals: #hello.
	self assert: 'é è à ô ü' asSymbol equals: #'é è à ô ü'.
	self assert: '' asSymbol equals: #''.
	self assert: 'test' asSymbol identicalTo: #test
]

{ #category : #tests }
StringTest >> testAsTime [ 

	self assert: '1:00:00' asTime asString equals: '1:00 am'.
	self assert: '1:00' asTime asString equals: '1:00 am'.
	self assert: '1' asTime asString equals: '1:00 am'.
	self assert: '13' asTime asString equals: '1:00 pm'

]

{ #category : #tests }
StringTest >> testAsUppercase [ 

	self assert: ('éèàôütest' asUppercase) equals: 'ÉÈÀÔÜTEST'.
	self assert: ('123éàôüößTEST' asUppercase) equals: '123ÉÀÔÜÖẞTEST'.
	self assert: ('' asUppercase) equals: ''
]

{ #category : #'tests - accessing' }
StringTest >> testAt [
	self assert: (string at: 1) equals: $H.
]

{ #category : #tests }
StringTest >> testBeginsWithEmptyCaseSensitive [

	self deny: ('éèàôüößäóñíá' beginsWithEmpty: 'ß' caseSensitive: true).
	self assert: ('éèàôüößäóñíá' beginsWithEmpty: 'éèàô' caseSensitive: true).
	self assert: ('éèàôüö' beginsWithEmpty: '' caseSensitive: true).
	self deny: ('éèàôüö' beginsWithEmpty: 'ÉÈÀ' caseSensitive: true).
	self assert: ('ÉÈÀÔÜÖ' beginsWithEmpty: 'ÉÈÀ' caseSensitive: true).
	self assert: ('123test' beginsWithEmpty: '123' caseSensitive: true).
	self should: ('aaee' beginsWithEmpty: 'AA' caseSensitive: false).
	self should: ('???' beginsWithEmpty: '??' caseSensitive: false)
	"self assert: ('ÉÈÀÔÜÖ' beginsWithEmpty: 'éèà' caseSensitive: false)."
]

{ #category : #'tests - converting' }
StringTest >> testCapitalized [
	| uc lc empty |
	uc := 'MElViN'.
	lc := 'mElViN'.
	empty := ' '.
	self assert: lc capitalized equals: uc.
	self assert: uc capitalized equals: uc.
	"the string gets copied"
	self deny: uc capitalized identicalTo: uc.
	self deny: empty capitalized identicalTo: empty
]

{ #category : #tests }
StringTest >> testCaseInsensitiveLessOrEqual [

	self assert: ('EEA' caseInsensitiveLessOrEqual: 'fgh').
	self deny: ('éèàôüößäóñíá' caseInsensitiveLessOrEqual: 'éèàôüöß').
	self assert: ('éèàôüößäóñíá' caseInsensitiveLessOrEqual: 'éèàôüößäóñíá').
	self deny: ('ÉÈÀÔÜÖ' caseInsensitiveLessOrEqual: 'èàôüö').
	self assert: ('eea' caseInsensitiveLessOrEqual: 'ÉÈÀ')
]

{ #category : #tests }
StringTest >> testCaseSensitiveLessOrEqual [

	self assert: ('EEA' caseSensitiveLessOrEqual: 'fgh').
	self deny: ('éèàôüößäóñíá' caseSensitiveLessOrEqual: 'éèàôüöß'). 
	self assert: ('éèàôüößäóñíá' caseSensitiveLessOrEqual: 'éèàôüößäóñíá').
	self assert: ('ÉÈÀÔÜÖ' caseSensitiveLessOrEqual: 'èàôüö').
	self assert: ('eea' caseSensitiveLessOrEqual: 'ÉÈÀ')
]

{ #category : #tests }
StringTest >> testCharactersExactlyMatching [

	self assert: 5 equals: ('voiture' charactersExactlyMatching: 'voituze').
	self assert: 0 equals: ('voiture' charactersExactlyMatching: '').
	self assert: 1 equals: ('voiture' charactersExactlyMatching: 'v').
	self assert: 0 equals: ('voiture' charactersExactlyMatching: 'abcdef')
]

{ #category : #tests }
StringTest >> testCompare [

	self assert: ('EEA' compare: 'fgh') equals: 1.
	self assert: ('ABCDEFGH' compare: 'ABCDEFGH') equals: 2.
	self assert: ('fgh' compare: 'fg') equals: 3.
	self assert: ('éèàôüöß' compare: 'ÉÈÀÔÜÖẞ') equals: 1.
	self assert: ('éèàôüößäóñíá' compare: 'éèàôüößäóñíá') equals: 2.
	self assert: ('ÉÈÀÔÜ' compare: 'ÔÜÖ') equals: 1.
	self assert: ('eeao' compare: 'éèàô') equals: 1.
	self assert: ('!@#' compare: '123') equals: 1
]

{ #category : #tests }
StringTest >> testCompareCaseSensitive [

	self assert: ('EEA' compare: 'fgh' caseSensitive: true) equals: 1.
	self assert: ('ABCDEFGH' compare: 'abcdefgh' caseSensitive: false) equals: 2.
	self assert: ('fgh' compare: 'fg' caseSensitive: false) equals: 3.
	self assert: ('éèàôüößäóñíá' compare: 'éèàôüößäóñíá' caseSensitive: false) equals: 2.
	self assert: ('ÉÈÀÔÜ' compare: 'ÔÜÖ' caseSensitive: true) equals: 1.
	self assert: ('éèàôüöß' compare: 'ÉÈÀÔÜÖẞ' caseSensitive: false) equals: 1
]

{ #category : #'tests - comparing' }
StringTest >> testComparing [
	self assert: 'foo' < 'foo:'.
	self assert: 'foo' < 'fooBar'.
	self assert: 'foo' <= 'foo:'.
	self assert: 'foo' <= 'fooBar'.
	self assert: 'foo:' > 'foo'.
	self assert: 'fooBar' > 'foo'.
	self assert: 'foo:' >= 'foo'.
	self assert: 'fooBar' >= 'foo'
]

{ #category : #'tests - comparing' }
StringTest >> testComparingCaseInsensitiveLatin1 [

	"ascii-letter"
	self assert: ('e' compare: 'E' caseSensitive: false) equals: 2.
	self assert: ('E' compare: 'e' caseSensitive: false) equals: 2.
	self assert: ('e' compare: 'E' caseSensitive: true) equals: 3.
	self assert: ('E' compare: 'e' caseSensitive: true) equals: 1.
	
	"ascii-number (no difference between number chars and number chars asUppercase "
	self assert: ('1' compare: '1' asUppercase caseSensitive: false) equals: 2.
	self assert: ('1' asUppercase compare: '1' caseSensitive: false) equals: 2.
	self assert: ('1' compare: '1' asUppercase caseSensitive: true) equals: 2.
	self assert: ('1' asUppercase compare: '1' caseSensitive: true) equals: 2.
	
	"non-ascii"
	self assert: ('é' compare: 'É' caseSensitive: false) equals: 2.
	self assert: ('É' compare: 'é' caseSensitive: false) equals: 2.
	self assert: ('é' compare: 'É' caseSensitive: true) equals: 3.
	self assert: ('É' compare: 'é' caseSensitive: true) equals: 1

]

{ #category : #'tests - copy' }
StringTest >> testCopyNonEmptyWithoutAllNotIncluded [
	
]

{ #category : #'tests - copy' }
StringTest >> testCopyReplaceAllWith [
	self assert: ('--A--' copyReplaceAll: 'A' with: 'ABC') equals: '--ABC--'.
	self assert: ('--A--' copyReplaceAll: 'A' with: 'X') equals: '--X--'.
	self assert: ('--ABC--' copyReplaceAll: 'ABC' with: 'X') equals: '--X--'.
	self assert: ('--A--' copyReplaceAll: 'A' with: '') equals: '----'.
	self assert: ('' copyReplaceAll: 'A' with: 'ABC') equals: ''.
	self assert: ('A--A--A' copyReplaceAll: 'A' with: 'ABC') equals: 'ABC--ABC--ABC'.
	self assert: ('A--A--A' copyReplaceAll: 'A' with: 'X') equals: 'X--X--X'.
	self assert: ('ABC--ABC--ABC' copyReplaceAll: 'ABC' with: 'X') equals: 'X--X--X'.
	self assert: ('A--A--A' copyReplaceAll: 'A' with: '') equals: '----'.
	self assert: ('A--ABC--A' copyReplaceAll: 'ABC' with: 'X') equals: 'A--X--A'.
	self assert: ('AB--ABC--AB' copyReplaceAll: 'ABC' with: 'X') equals: 'AB--X--AB'.
	self assert: ('--A--' copyReplaceAll: '' with: '') equals: '--A--'.
	self assert: ('AAAA-' copyReplaceAll: 'AA' with: 'X') equals: 'XX-'
]

{ #category : #'tests - copy' }
StringTest >> testCopyReplaceAllWithAsTokens [

	self assert: ('test te str' copyReplaceAll: 'te' with: 'longone' asTokens: true) equals: 'test longone str'.
	self assert: ('test te str' copyReplaceAll: 'te' with: 'longone' asTokens: false) equals: 'longonest longone str'.
	self assert: ('123 test xyz' copyReplaceAll: 'st' with: 'mper' asTokens: true) equals: '123 test xyz'.
	self assert: ('éèàôüößäóñíá' copyReplaceAll: 'àôüö' with: 'A' asTokens: false) equals: 'éèAßäóñíá'.
	self assert: ('éèàôü éèàôüt éèàôü' copyReplaceAll: ' ' with:  'ß' asTokens: false) equals: 'éèàôüßéèàôütßéèàôü'.
]

{ #category : #'tests - copying' }
StringTest >> testCopyUpToSubstring [ 

	self assert: ('abcdef' copyUpToSubstring: '') equals: ''.
	self assert: ('abcdef' copyUpToSubstring: 'a') equals: ''.
	self assert: ('abcdef' copyUpToSubstring: 'b') equals: 'a'.
	self assert: ('abcdef' copyUpToSubstring: 'de') equals: 'abc'.
	self assert: ('abcdef' copyUpToSubstring: 'ef') equals: 'abcd'.
	self assert: ('abcdef' copyUpToSubstring: 'f') equals: 'abcde'.
	self assert: ('abcdef' copyUpToSubstring: 'fg') equals: 'abcdef'.
	self assert: ('' copyUpToSubstring: 'abc') equals: ''.
	self assert: ('abcdef' copyUpToSubstring: 'g') equals: 'abcdef'.
	self assert: ('abcdef' copyUpToSubstring: 'gh') equals: 'abcdef'.

]

{ #category : #'tests - comparing' }
StringTest >> testCorrectAgainst [

	| coll |
	coll := OrderedCollection new addAll: #('nest' 'temperature' 'text' 'Jupiter' 'denial' 'nest' 'tttt' 'e' 'alpha' 'beautest'); yourself.

	self assert: ('test' correctAgainst: coll) asArray equals: #('beautest' 'nest' 'text' 'nest' 'tttt' 'temperature').
	self assert: ('123' correctAgainst: coll) asArray equals: #('tttt' 'nest' 'text' 'nest').

	coll := OrderedCollection new.
	self assert: ('test' correctAgainst: coll) asArray equals: #().
]

{ #category : #'tests - printing' }
StringTest >> testDisplayString [

	| actual |
	actual := 'some string' displayString.
	self assert: actual equals: 'some string'
]

{ #category : #tests }
StringTest >> testEndsWith [ 

	self deny: ('éèàôüößäóñíá' endsWith: 'ia').
	self deny: ('éèàôüößäóñíá' endsWith: '').
	self assert: ('éèàôüößäóñíá' endsWith: 'éèàôüößäóñíá').
	self deny: ('test' endsWith: 'ST').
	self assert: ('test' endsWith: 'st').
	self deny: ('ÉÈÀÔÜÖẞÄÓÑÍÁ' endsWith: 'íá').
	self deny: ('test' endsWith: 'tester').

]

{ #category : #'tests - testing' }
StringTest >> testEndsWithAColon [

	self assert: 'fred:' endsWithAColon.

	self deny: 'fred' endsWithAColon
]

{ #category : #tests }
StringTest >> testEndsWithAnyOf [

	self deny: ('éèàôüößäóñíá' endsWithAnyOf: #('ia' 'ñí' '' 'áß')).
	self assert: ('éèàôüößäóñíá' endsWithAnyOf: #('test' 'ÉÈÀ' 'äóñíá')).
	self assert: ('test' endsWithAnyOf: #('tests' 'tester' 'testing' 't')).

]

{ #category : #tests }
StringTest >> testEndsWithDigit [

	self deny: ('éèàôüößäóñíá' endsWithDigit).
	self assert: ('éèàôüößäóñíá9' endsWithDigit).
	self deny: ('99test' endsWithDigit).
	self assert: ('  999' endsWithDigit).
]

{ #category : #tests }
StringTest >> testEquality [
	
	self assert: 'abc' equals: 'abc' asWideString.
	self assert: 'abc' asWideString equals: 'abc'.
	self assert: ( #[97 0 0 0] asString ~= 'a000' asWideString).
	self assert: ('a000' asWideString ~=  #[97 0 0 0] asString).

	self assert: ('abc' sameAs: 'aBc' asWideString).
	self assert: ('aBc' asWideString sameAs: 'abc').
	self assert: ( #[97 0 0 0] asString 
						sameAs: 'Abcd' asWideString) not.
	self assert: ('a000' asWideString sameAs: #[97 0 0 0] asString) not.
]

{ #category : #'tests - formatting' }
StringTest >> testExpandMacros [

	self
		assert: '<t><n><r><l>' expandMacros
		equals:
			(String
				streamContents: [ :stream | 
					stream
						nextPut: Character tab;
						nextPutAll: OSPlatform current lineEnding;
						nextPut: Character cr;
						nextPut: Character lf ])
]

{ #category : #'tests - formatting' }
StringTest >> testExpandMacrosSkip [
	self assert: '%<' expandMacros equals: '<'
]

{ #category : #'tests - formatting' }
StringTest >> testExpandMacrosTernary [
	self assert: ('<1?success:error>' expandMacrosWith: true) equals: 'success'.
	self assert: ('<1?success:error>' expandMacrosWith: false) equals: 'error'
]

{ #category : #'tests - formatting' }
StringTest >> testExpandMacrosWithArguments [
	self assert: ('<1s>' expandMacrosWithArguments: {'str''ing'}) equals: 'str''ing'.
	self assert: ('<1p>' expandMacrosWithArguments: {'str''ing'}) equals: '''str''''ing'''.
	self assert: ('<1p>: <2p>' expandMacrosWith: 'Number' with: 5) equals: '''Number'': 5'
]

{ #category : #'tests - formatting' }
StringTest >> testExpandMacrosWithArgumentsLongText [
	"printString truncates strings"
	self assert: ('<1p>' expandMacrosWith: ('a' repeat: 10)) size equals: 12.
	self assert: ('<1p>' expandMacrosWith: ('a' repeat: 100000)) size equals: 100002
]

{ #category : #tests }
StringTest >> testFindAnySubstringStartingAt [

	self assert: ('tester12345' findAnySubstring: #('st' $1) startingAt: 1) equals: 3.
	self assert: ('éèàôüößäóñíá1234' findAnySubstring: #('st' '' 'óñ' '123') startingAt:  1) equals: 9.
	self assert: ('éèàôüößäóñíá' findAnySubstring: #('') startingAt: 2) equals: 13.
	self assert: ('éèàôüößäóñíá' findAnySubstring: #('óñ') startingAt: 3) equals: 9.
	self assert: ('éèàôüößäóñíá' findAnySubstring: #() startingAt: 3) equals: 13.
	self assert: ('test12345' findAnySubstring: #('"' '@') startingAt: 12) equals: 10
]

{ #category : #tests }
StringTest >> testFindBetweenSubstrings [
 
	self assert: ('éèà ôüößäó ñíá' findBetweenSubstrings: #(' ')) asArray equals: #('éèà' 'ôüößäó' 'ñíá').
	self assert: ('ieaoftaaka' findBetweenSubstrings: #($a)) asArray equals: #('ie' 'oft' 'k').
	self assert: ('this is an issue is it not' findBetweenSubstrings: #('is' 'not')) asArray 
                                               equals: #('th' ' ' ' an ' 'sue ' ' it ').
]

{ #category : #tests }
StringTest >> testFindCloseParenthesisFor [

	self assert: ('(1 + 3(2 * 9) - 15)' findCloseParenthesisFor: 1) equals: 19.
	self assert: ('(1+(2-3))-3.14159' findCloseParenthesisFor: 1) equals: 9.
	self assert: ('(1+(2-3))-3.14159' findCloseParenthesisFor: 4) equals: 8.
	self assert: ('()' findCloseParenthesisFor: 10) equals: 3
]

{ #category : #tests }
StringTest >> testFindDelimitersStartingAt [

	self assert: ('this is a string' findDelimiters: ' ' startingAt: 1) equals: 5.
	self assert: ('this is a string' findDelimiters: 'i' startingAt: 1) equals: 3.
	self assert: ('this is a string' findDelimiters: #($a $e $s) startingAt: 5) equals: 7.
	self assert: ('éèàôüöß éèàôüöß' findDelimiters: 'ß' startingAt: 2) equals: 7
]

{ #category : #'tests - indexof' }
StringTest >> testFindFirstInString [	
	"These tests are more specific than those in testIndexOf."
	
	"more boundary tests"
	self assert: (self findFirstInString: '' fromString: '') equals: 0.
	self assert: (self findFirstInString: 'x' fromString: '') equals: 0.
	self assert: (self findFirstInString: '' fromString: 'x') equals: 0.
	
	self assert: (self findFirstInString: 'x' fromString: 'x') equals: 1.
	
	self assert: (self findFirstInString: 'hello' fromString: 'hello') equals: 1.
	self assert: (self findFirstInString: 'hello' fromString: 'ello') equals: 2.
	self assert: (self findFirstInString: 'hello' fromString: 'llo') equals: 3.
	self assert: (self findFirstInString: 'hello' fromString: 'o') equals: 5.
	self assert: (self findFirstInString: 'hello' fromString: 'x') equals: 0.

]

{ #category : #tests }
StringTest >> testFindLastOccurrenceOfStringStartingAt [

	self assert: ('Smalltalk' findLastOccurrenceOfString: 'al' startingAt: 2) equals: 7.
	self assert: ('aaa' findLastOccurrenceOfString: 'aa' startingAt: 1) equals: 2.
	self assert: ('Smalltalk' asWideString findLastOccurrenceOfString: 'al' startingAt: 2) equals: 7.
	self assert: ('Smalltalk' asWideString findLastOccurrenceOfString: 'al' asWideString startingAt: 2) equals: 7.
	self assert: (('Smalltalk' copyWith: 835 asCharacter) findLastOccurrenceOfString: 'al' asWideString startingAt: 2) equals: 7
]

{ #category : #'tests - iterate on sequenced reable collections' }
StringTest >> testFindSelector [
	self assert: #isSymbol equals: 'isSymbol' findSelector.
	self assert: #between:and: equals: 'between:and:' findSelector .
	self assert: #+ equals: '+' findSelector .
	self assert: #isSymbol equals: '#isSymbol' findSelector.
	self assert: #between:and: equals: '#between:and:' findSelector .
	self assert:#+ equals: '#+' findSelector

]

{ #category : #tests }
StringTest >> testFindString [

	self assert: ('éèàôüößäóñíá' findString: 'ÉÈ') equals: 0.
	self assert: ('éèàôüößäóñíá' findString: 'éè') equals: 1.
	self assert: ('salkjsdlkgfee' findString: 'EE') equals: 0.
	self assert: ('salkjsdlkgfee' findString: 'ee') equals: 12.
	self assert: (' ' findString: '') equals: 0
]

{ #category : #tests }
StringTest >> testFindStringStartingAt [

	self assert: ('éèàôüößäóñíá' findString: 'ÉÈ' startingAt: 1) equals: 0.
	self assert: ('éèàôüößäóñíá' findString: 'éè' startingAt: 10) equals: 0.
	self assert: ('éèàôüößäóñíá' findString: 'ß' startingAt: 5) equals: 7.
	self assert: ('salkjsdlkgfee' findString: 'lke' startingAt: 1) equals: 0.
	self assert: ('salkjsdlkgfee' findString: 'ee'startingAt: 3) equals: 12.
	self assert: (' ' findString: '' startingAt: 1) equals: 0
]

{ #category : #tests }
StringTest >> testFindStringStartingAtCaseSensitive [

	self assert: ('éèàôüößäóñíá' findString: 'Á' startingAt: 1 caseSensitive: false) equals: 12.
	self assert: ('éèàôüößäóñíá' findString: 'Á' startingAt: 1 caseSensitive: true) equals: 0.
	self assert: ('suiehl5tlr' findString: 'r' startingAt:  5 caseSensitive: true) equals: 10.
	self assert: ('test' findString: 'T' startingAt: 3 caseSensitive: false) equals: 4.
	self assert: ('test' findString: '' startingAt: 1 caseSensitive: false) equals: 0
]

{ #category : #tests }
StringTest >> testFindTokens [

	|s |
	s := OrderedCollection withAll: #( 'i' 'd toke' 's').
	self assert: ('find tokens' findTokens: #($a $f $n)) equals: s.

	s := OrderedCollection withAll: #('éèàôüößäóñí').
	self assert: ('éèàôüößäóñíá' findTokens: $á) equals: s.

	s := OrderedCollection withAll: #().
	self assert: ('' findTokens: '') equals: s.

	s := OrderedCollection withAll: #('es' ' ' 'his').
	self assert: ('test this' findTokens: 't') equals: s
]

{ #category : #tests }
StringTest >> testFindTokensEscapedBy [

	|s|
	s := OrderedCollection withAll: #('éèà' 'üößä' 'íá').
	self assert: ('éèàôüößäóñíá' findTokens: #($ô $ó) escapedBy:'ñí') equals: s.

	s := OrderedCollection withAll: #('ths,').
	self assert: ('this,is' findTokens: ',' escapedBy: 'is' ) equals: s.

	s := OrderedCollection withAll: #('this,is').
	self assert: ('this , is' findTokens: ',' escapedBy: ' ') equals: s.

	s := OrderedCollection withAll: #('ths , s').
	self assert: ('this , is' findTokens: ' ' escapedBy: $i) equals: s
]

{ #category : #'tests - tokenizing' }
StringTest >> testFindTokensEscapedBy01 [

	| tokens |
	string := 'this, is, "a, test"'.
	tokens := string findTokens: ',' escapedBy: '"'.
	self assert: tokens size equals: 3
]

{ #category : #'tests - tokenizing' }
StringTest >> testFindTokensEscapedBy02 [
	| tokens |
	string := ''.
	tokens := string findTokens: ',' escapedBy: '"'.
	self assertEmpty: tokens
]

{ #category : #'tests - tokenizing' }
StringTest >> testFindTokensEscapedBy03 [

	| tokens |
	string := 'this, is, a, test'.
	tokens := string findTokens: ',' escapedBy: '"'.
	self assert: tokens size equals: 4
]

{ #category : #'tests - tokenizing' }
StringTest >> testFindTokensEscapedBy04 [

	| tokens |
	string := 'this, is, a"," test'.
	tokens := string findTokens: ',' escapedBy: '"'.
	self assert: tokens size equals: 3.
	self assert: tokens third equals: ' a, test'
]

{ #category : #'tests - tokenizing' }
StringTest >> testFindTokensEscapedBy05 [

	| tokens |
	string := 'this, /is, a"," test/'.
	tokens := string findTokens: ',#' escapedBy: '"/'.
	self assert: tokens size equals: 2.
	self assert: tokens first equals: 'this'.
	self assert: tokens second equals: ' is, a"," test'.
]

{ #category : #'tests - tokenizing' }
StringTest >> testFindTokensEscapedBy06 [

	| tokens |
	string := 'this, is, "a, test'.
	tokens := string findTokens: ',' escapedBy: '"'.
	self assert: tokens size equals: 3.
	self assert: tokens third equals: ' a, test'
]

{ #category : #'tests - tokenizing' }
StringTest >> testFindTokensEscapedBy07 [

	| tokens |
	string := 'a:b::c'.
	tokens := string findTokens: ':' escapedBy: '"'.
	self assert: tokens size equals: 4.
	self assert: tokens first equals: 'a'.
	self assert: tokens second equals: 'b'.
	self assert: tokens third equals: ''.
	self assert: tokens fourth equals: 'c'
]

{ #category : #'tests - tokenizing' }
StringTest >> testFindTokensEscapedBy08 [

	| tokens |
	string := 'this, is, ##a, test'.
	tokens := string findTokens: ',' escapedBy: '#'.
	self assert: tokens size equals: 4.
	self assert: tokens third equals: ' a'.
	self assert: tokens fourth equals: ' test'
]

{ #category : #'tests - tokenizing' }
StringTest >> testFindTokensEscapedBy09 [

	| tokens |
	string := 'this, is, ###a, test#'.
	tokens := string findTokens: ',' escapedBy: '#'.
	self assert: tokens size equals: 3.
	self assert: tokens third equals: ' #a, test'
]

{ #category : #'tests - tokenizing' }
StringTest >> testFindTokensEscapedBy10 [

	| tokens |
	string := 'this, is, ###a, test'.
	tokens := string findTokens: ',' escapedBy: '#'.
	self assert: tokens size equals: 3.
	self assert: tokens third equals: ' #a, test'
]

{ #category : #'tests - tokenizing' }
StringTest >> testFindTokensEscapedBy11 [

	| tokens |
	string := 'this, is, """a, test"'.
	tokens := string findTokens: ',' escapedBy: '"'.
	self assert: tokens size equals: 3.
	self assert: tokens third equals: ' "a, test'
]

{ #category : #'tests - tokenizing' }
StringTest >> testFindTokensEscapedBy12 [

	| tokens |
	string := 'one, two# three; four. five'.
	tokens := string findTokens: ',#;.' escapedBy: '"'.
	self assert: tokens size equals: 5.
	self assert: tokens third equals: ' three'
]

{ #category : #'tests - tokenizing' }
StringTest >> testFindTokensEscapedBy13 [

	| tokens |
	string := 'one, two# three; four. five'.
	tokens := string findTokens: ',#;.' escapedBy: nil.
	self assert: tokens size equals: 5.
	self assert: tokens third equals: ' three'
]

{ #category : #'tests - tokenizing' }
StringTest >> testFindTokensEscapedBy14 [

	| tokens |
	string := 'one, "two# three"; &four. five&'.
	tokens := string findTokens: ',#;.' escapedBy: '"&'.
	self assert: tokens size equals: 3.
	self assert: tokens second equals: ' two# three'.
	self assert: tokens third equals: ' four. five'
]

{ #category : #'tests - tokenizing' }
StringTest >> testFindTokensEscapedBy15 [

	| tokens |
	string := 'one, "two# three"; &four. five&'.
	tokens := string findTokens: nil escapedBy: '"&'.
	self assert: tokens size equals: 1.
	self assert: tokens first equals: 'one, two# three; four. five'
]

{ #category : #'tests - tokenizing' }
StringTest >> testFindTokensEscapedBy16 [

	| tokens |
	string := 'one, "two# three"; &four. five&'.
	tokens := string findTokens: nil escapedBy: nil.
	self assert: tokens size equals: 1.
	self assert: tokens first equals: string
]

{ #category : #'tests - tokenizing' }
StringTest >> testFindTokensEscapedBy21 [

	| tokens |
	string := 'this, is, "a, test"'.
	tokens := string findTokens: $, escapedBy: $".
	self assert: tokens size equals: 3
]

{ #category : #'tests - tokenizing' }
StringTest >> testFindTokensEscapedBy22 [

	| tokens |
	string := ''.
	tokens := string findTokens: $, escapedBy: $".
	self assert: tokens size equals: 0
]

{ #category : #'tests - tokenizing' }
StringTest >> testFindTokensEscapedBy23 [

	| tokens |
	string := 'this, is, a, test'.
	tokens := string findTokens: $, escapedBy: $".
	self assert: tokens size equals: 4
]

{ #category : #'tests - tokenizing' }
StringTest >> testFindTokensEscapedBy24 [

	| tokens |
	string := 'this, is, a"," test'.
	tokens := string findTokens: $, escapedBy: $".
	self assert: tokens size equals: 3.
	self assert: tokens third equals: ' a, test'
]

{ #category : #'tests - tokenizing' }
StringTest >> testFindTokensEscapedBy25 [

	| tokens |
	string := 'this, /is, a"," test/'.
	tokens := string findTokens: $, escapedBy: $/.
	self assert: tokens size equals: 2.
	self assert: tokens first equals: 'this'.
	self assert: tokens second equals: ' is, a"," test'.
]

{ #category : #'tests - tokenizing' }
StringTest >> testFindTokensEscapedBy26 [

	| tokens |
	string := 'this, is, "a, test'.
	tokens := string findTokens: $, escapedBy: $".
	self assert: tokens size equals: 3.
	self assert: tokens third equals: ' a, test'
]

{ #category : #tests }
StringTest >> testFindTokensIncludes [

	self assert: ('test this' findTokens: 't' includes: 'his') equals: 'his'.
	self assert: ('test this' findTokens: 's' includes: 'HI') isNil.
	self assert: ('test this' findTokens: 's' includes: 'hi') equals: 't thi'.
	self assert: ('test that' findTokens: 't' includes: 'that') isNil.
	self assert: ('éèàôüößäóñíá' findTokens: #($ô $ó) includes:'ñí') equals: 'ñíá'

]

{ #category : #tests }
StringTest >> testFindWordStartStartingAt [

	self assert: ('test this string' findWordStart: 'th' startingAt: 1) equals: 6.
	self assert: ('test this string' findWordStart: 'st' startingAt: 1) equals: 11.
	self assert: ('test this string' findWordStart: 'st' startingAt: 12) equals: 0.
	self assert: ('test this string' findWordStart: '' startingAt: 1) equals: 0

]

{ #category : #'tests - formatting' }
StringTest >> testFormat [

	self
		assert: ('This is {1} !' format: #('a test'))
		equals: 'This is a test !'.

 	{ 
 		[ '\{ \} \\ foo {1} bar {2}' format: { 12. 'string' } ] -> '{ } \ foo 12 bar string'. 
 		[ '\{ \} \\ foo {2} bar {1}' format: { 'string'. 12 } ] -> '{ } \ foo 12 bar string'. 
 		[ '\{1}' format: {} ] -> '{1}'. 
 		[ '\{1}{1}' format: { $a } ] -> '{1}a'. 
 	} do: [ :each | 
		self assert: each key value equals: each value ]
]

{ #category : #'tests - formatting' }
StringTest >> testFormatExtended [

	self
		assert: ('This is {foo} !' format: (Dictionary with: #foo->'a test'))
		equals: 'This is a test !'.

 	{ 
 		[ '\{ \} \\ foo {foo} bar {bar}' format: { #foo->12. #bar->'string' } asDictionary ] -> '{ } \ foo 12 bar string'. 
 		[ '\{ \} \\ foo {bar} bar {foo}' format: { 'bar'->12. 'foo'->'string' } asDictionary ] -> '{ } \ foo 12 bar string'. 
 		[ '\{x}' format: {} ] -> '{x}'. 
 		[ '\{x}{x}' format: { #x->$a } asDictionary ] -> '{x}a'. 
 	} do: [ :each | 
		self assert: each key value equals: each value ]
]

{ #category : #'tests - formatting' }
StringTest >> testFormatFailures [

	self
		should: [ 'This is {foo} !' format: Dictionary new ]
		raise: KeyNotFound.
		
	self
		should: [ 'This is {1} !' format: Array new ]
		raise: SubscriptOutOfBounds.

]

{ #category : #tests }
StringTest >> testHasWideCharacterFromTo [

	self assert: ('te€st' hasWideCharacterFrom: 1 to: 3).
	self deny: ('test' hasWideCharacterFrom: 1 to: 4).  
	self assert: ('€₤' hasWideCharacterFrom: 1 to: 2).  
	self assert: ('test this string €₤' hasWideCharacterFrom: 18 to: 19)
]

{ #category : #'tests - includes' }
StringTest >> testIncludesElementIsNotThere [
	
	self deny: (self nonEmpty includes: self elementNotInForOccurrences).
	self assert: (self nonEmpty includes: self nonEmpty anyOne).
	self deny: (self empty includes: self elementNotInForOccurrences)
]

{ #category : #tests }
StringTest >> testIncludesSubstring [

	self assert: ('testing this string' includesSubstring: 'ring'). 
	self assert: ('éèàôüößäóñíá' includesSubstring: '').
	self assert: ('' includesSubstring: '').
	self deny: ('éèàôüößäóñíá' includesSubstring: 'a'). 
	self assert: ('éèàôüößäóñíá' includesSubstring: 'ßä').
	self deny: ('kjdsnlksjdf' includesSubstring: 'K') 

]

{ #category : #test }
StringTest >> testIncludesSubstringAt [

	"Test empty strings"
	self assert: ('' includesSubstring: '' at: 1).
	self assert: ('test' includesSubstring: '' at: 1).
	self deny: ('' includesSubstring: 'test' at: 1).
	"Test out of bounds indexes"
	self deny: ('test' includesSubstring: 't' at: 0).
	self deny: ('test' includesSubstring: 't' at: 10).
	"Test matching substring"
	self assert: ('test' includesSubstring: 'st' at: 3).
	"Test partially matching substring"
	self deny: ('test' includesSubstring: 'sty' at: 3).
	
	
]

{ #category : #tests }
StringTest >> testIncludesSubstringCaseSensitive [

	self deny: ('test this string' includesSubstring: 'Ring' caseSensitive: true ). 
	self assert: ('test this string' includesSubstring: 'Ring' caseSensitive: false). 
	self deny: ('123éàôüöß' includesSubstring: '' caseSensitive: false). 
	self assert: ('123éàôüöß' includesSubstring: 'öß' caseSensitive: true).
	self assert: ('123éàôüöß' includesSubstring: 'ÀÔ' caseSensitive: false)


]

{ #category : #tests }
StringTest >> testIndexOf [

	self assert: ('test this string' indexOf: $k) equals: 0.
	self assert: ('test this string' indexOf: 't') equals: 0.
	self assert: ('test this string' indexOf: $t) equals: 1.
	self assert: ('123éàôüöß' indexOf: $ß) equals: 9.
	self assert: ('123éàôüöß' indexOf: $E) equals: 0
 
]

{ #category : #tests }
StringTest >> testIndexOfFirstUppercaseCharacter [

	self assert: 'test thiS strIng' indexOfFirstUppercaseCharacter equals: 9.
	self assert: 'test this string' indexOfFirstUppercaseCharacter equals: 0.
	self assert: '123éàôüöß' indexOfFirstUppercaseCharacter equals: 0.
	self assert: '123éàôüÖẞ' indexOfFirstUppercaseCharacter equals: 8
 
]

{ #category : #tests }
StringTest >> testIndexOfWideCharacterFromTo [

	self assert: ('123éàôüÖẞ' indexOfWideCharacterFrom: 1 to: 9) equals: 9.
	self assert: ('te€st' indexOfWideCharacterFrom: 1 to: 5) equals: 3.
	self assert: ('te€st this string' indexOfWideCharacterFrom: 4 to: 10) equals: 0.
	self assert: ('€₤' indexOfWideCharacterFrom: 1 to: 2) equals: 1
]

{ #category : #tests }
StringTest >> testInitialIntegerOrNil [

	self assert: '234Whoopie' initialIntegerOrNil equals: 234.
	self assert: 'wimpy' initialIntegerOrNil isNil.
	self assert: '234' initialIntegerOrNil equals: 234.
	self assert: '2N' initialIntegerOrNil equals: 2.
	self assert: '  89Ten ' initialIntegerOrNil isNil.
	self assert: '78 92' initialIntegerOrNil equals: 78.
	self assert: '123éàôüÖẞ' initialIntegerOrNil equals: 123
]

{ #category : #tests }
StringTest >> testIsAllAlphaNumerics [

	self assert: '123dwef890' isAllAlphaNumerics.
	self deny: '12 34 top &^' isAllAlphaNumerics. 
	self assert: '' isAllAlphaNumerics.
	self deny: ' 234 ' isAllAlphaNumerics.
	self deny: '()' isAllAlphaNumerics. 
	self assert: '123éàôüÖẞ' isAllAlphaNumerics
]

{ #category : #tests }
StringTest >> testIsAllDigits [

	self assert: '' isAllDigits equals: false.
	self assert: '1.23' isAllDigits equals: false.
	self assert: '12 3' isAllDigits equals: false.
	self assert: '-123' isAllDigits equals: false.
	self assert: '0123456789' isAllDigits equals: true
]

{ #category : #tests }
StringTest >> testIsAsciiString [
	"Non-regression for https://pharo.manuscript.com/f/cases/15232 "
	
	self assert: '' isAsciiString equals: true.
	self assert: 'abcdefGHIJKL 98765,./@#%$' isAsciiString equals: true.
	self assert: 'éÀ' isAsciiString equals: false
]

{ #category : #tests }
StringTest >> testIsLiteralSymbol [

	self assert: ('*+-/\~=<>&@%,|' allSatisfy: [:char | (Symbol with: char) isLiteralSymbol])
		description: 'single letter binary symbols can be printed without string quotes'.
		
	self assert: (#('x' 'x:' 'x:y:' 'from:to:by:' 'yourself') allSatisfy: [:str | str asSymbol isLiteralSymbol])
		description: 'valid ascii selector symbols can be printed without string quotes'
]

{ #category : #tests }
StringTest >> testIsPatternVariable [

	self assert: '`pattern' isPatternVariable.
	self assert: '`pattern:' isPatternVariable.
	self assert: '`pattern:`varible:' isPatternVariable.
	self assert: 'pattern:`varible:' isPatternVariable.
	
	self deny: 'notAPattern:varible:' isPatternVariable.
	self deny: 'notAPattern' isPatternVariable
		

]

{ #category : #'tests - testing' }
StringTest >> testIsValidSelector [
	self assert: 'class' isValidSelector.
	self deny: '0class' isValidSelector
]

{ #category : #tests }
StringTest >> testIsWideString [

	self assert: '€₤' isWideString.
	self deny: 'test this string' isWideString. 
	self assert: ' test ₤' isWideString.
	self deny: '' isWideString. 
	self assert: 'éàôüÖẞ' isWideString.
	self deny: 'éàôüÖ' isWideString 
]

{ #category : #tests }
StringTest >> testLastSpacePosition [

	self assert: 'fred the bear' lastSpacePosition equals: 9.
	self assert: 'ziggie' lastSpacePosition equals: 0.
	self assert: 'elvis ' lastSpacePosition equals: 6.
	self assert: 'wimpy  ' lastSpacePosition equals: 7.
	self assert: '' lastSpacePosition equals: 0.
	self assert: ' 123  éà ôüÖ ẞ' lastSpacePosition equals: 13
]

{ #category : #tests }
StringTest >> testLeadingCharRunLengthAt [

	self assert: ('test' leadingCharRunLengthAt: 1) equals: 4.
	self assert: ('éà ôüÖ ẞ' leadingCharRunLengthAt: 2) equals: 7.
	self assert: ('123ea slkj jfek' leadingCharRunLengthAt: 1) equals: 15.
	self assert: ('te€st this string' leadingCharRunLengthAt: 1) equals: 17.
	self assert: (' ' leadingCharRunLengthAt: 1) equals: 1.
	self assert: ('te€st this string' leadingCharRunLengthAt: 10) equals: 8
]

{ #category : #tests }
StringTest >> testLessThan [

	self assert: ('@' < 'A').
	self assert: ('abcd' < 'à ô ü').
	self assert: ('xyz' < 'ß').
	self assert: ('ß t e s t' < 'à ô ü').
	self assert: ('' < 'a').
	self deny: ('à ô ü' < 'à ô ü').
	self deny: ('aaa' < 'AAA')


]

{ #category : #'tests - lines' }
StringTest >> testLineCorrespondingToIndex [
	| sampleCRString sampleLFString sampleCRLFString anIndex |
	sampleCRString := 'Fred', String cr, 'the', String cr, 'Bear'.
	sampleLFString := 'Fred', String lf, 'the', String lf, 'Bear'.
	sampleCRLFString := 'Fred', String crlf, 'the', String crlf, 'Bear'.
	
	anIndex := sampleCRString indexOf: $h.
	self assert: (sampleCRString lineCorrespondingToIndex: anIndex) equals: 'the'.
	anIndex := sampleLFString indexOf: $h.
	self assert: (sampleLFString lineCorrespondingToIndex: anIndex) equals: 'the'.
	anIndex := sampleCRLFString indexOf: $h.
	self assert: (sampleCRLFString lineCorrespondingToIndex: anIndex) equals: 'the'.
	
	anIndex := sampleCRString indexOf: $B.
	self assert: (sampleCRString lineCorrespondingToIndex: anIndex) equals: 'Bear'.
	anIndex := sampleLFString indexOf: $B.
	self assert: (sampleLFString lineCorrespondingToIndex: anIndex) equals: 'Bear'.
	anIndex := sampleCRLFString indexOf: $B.
	self assert: (sampleCRLFString lineCorrespondingToIndex: anIndex) equals: 'Bear'.
	
	anIndex := sampleCRString indexOf: $d.
	self assert: (sampleCRString lineCorrespondingToIndex: anIndex) equals: 'Fred'.
	anIndex := sampleLFString indexOf: $d.
	self assert: (sampleLFString lineCorrespondingToIndex: anIndex) equals: 'Fred'.
	anIndex := sampleCRLFString indexOf: $d.
	self assert: (sampleCRLFString lineCorrespondingToIndex: anIndex) equals: 'Fred'.
]

{ #category : #'tests - lines' }
StringTest >> testLineCount [
	| sampleCRString sampleLFString sampleCRLFString |
	sampleCRString := 'Fred', String cr, 'the', String cr, 'Bear'.
	sampleLFString := 'Fred', String lf, 'the', String lf, 'Bear'.
	sampleCRLFString := 'Fred', String crlf, 'the', String crlf, 'Bear'.
	
	self assert: sampleCRString lineCount equals: 3.
	self assert: sampleLFString lineCount equals: 3.
	self assert: sampleCRLFString lineCount equals: 3.
]

{ #category : #'tests - lines' }
StringTest >> testLineNumber [
	| sampleCRString sampleLFString sampleCRLFString |
	sampleCRString := 'Fred', String cr , 'the', String cr, 'Bear'.
	sampleLFString := 'Fred', String lf , 'the', String lf, 'Bear'.
	sampleCRLFString := 'Fred', String crlf, 'the', String crlf, 'Bear'.
	
	self assert: (sampleCRString lineNumber: 2) equals: 'the'.
	self assert: (sampleLFString lineNumber: 2) equals: 'the'.
	self assert: (sampleCRLFString lineNumber: 2) equals: 'the'.
]

{ #category : #'tests - lines' }
StringTest >> testLines [
	| sampleCRString sampleLFString sampleCRLFString sampleMixedString sampleMixedString2 |
	sampleCRString := 'Fred', String cr, 'the', String cr, 'Bear'.
	sampleLFString := 'Fred', String lf, 'the', String lf, 'Bear'.
	sampleCRLFString := 'Fred', String crlf, 'the', String crlf, 'Bear'.
	sampleMixedString := 'Fred', String lf, 'the', String cr, 'Bear'.
	sampleMixedString2 := 'Fred', String crlf, 'the', String cr, 'Bear'.
	
	self assert: sampleCRString lines equals: #('Fred' 'the' 'Bear').
	self assert: sampleLFString lines equals: #('Fred' 'the' 'Bear').
	self assert: sampleCRLFString lines equals: #('Fred' 'the' 'Bear').
	self assert: sampleMixedString lines equals: #('Fred' 'the' 'Bear').
	self assert: sampleMixedString2 lines equals: #('Fred' 'the' 'Bear').
]

{ #category : #'tests - lines' }
StringTest >> testLinesDo [
	| sampleCRString sampleLFString sampleCRLFString lines |
	sampleCRString := 'Fred', String cr , 'the' , String cr , 'Bear'.
	sampleLFString := 'Fred', String lf , 'the' , String lf , 'Bear'.
	sampleCRLFString := 'Fred', String crlf , 'the' , String crlf , 'Bear'.
	
	lines := OrderedCollection new.
	sampleCRString linesDo: [:aLine |
		self deny: (aLine includes: Character cr).
		self deny: (aLine includes: Character lf).
		lines add: aLine].
	self assert: lines asArray equals: #('Fred' 'the' 'Bear').
	
	lines := OrderedCollection new.
	sampleLFString linesDo: [:aLine |
		self deny: (aLine includes: Character cr).
		self deny: (aLine includes: Character lf).
		lines add: aLine].
	self assert: lines asArray equals: #('Fred' 'the' 'Bear').

	lines := OrderedCollection new.
	sampleCRLFString linesDo: [:aLine |
		self deny: (aLine includes: Character cr).
		self deny: (aLine includes: Character lf).
		lines add: aLine].
	self assert: lines asArray equals: #('Fred' 'the' 'Bear').


]

{ #category : #'tests - line breaking' }
StringTest >> testLinesDoWithCr [

	| myString  |
	myString := 'This is a test of line breaking', String cr.
	myString linesDo: [ :line |
		self assert: (line size + 1) equals: myString size]
]

{ #category : #'tests - line breaking' }
StringTest >> testLinesDoWithCrBetween [

	| aString |
	aString := ' This is a test ', String cr, 'of line breaking'.
	aString linesDo: [:line |
		self assert: line size equals: 16 ]
]

{ #category : #'tests - line breaking' }
StringTest >> testLinesDoWithCrLf [

	| aString |
	aString := 'This is a test of line breaking', String crlf.
	aString linesDo: [ :line |
		self assert: (line size + 2) equals: aString size ]
]

{ #category : #'tests - line breaking' }
StringTest >> testLinesDoWithCrLfBetween [

	| aString |
	aString := '-This is a test-', String crlf, 'of line breaking'.
	aString linesDo: [:line | 
		self assert: line size equals: 16 ]
]

{ #category : #'tests - instance creation' }
StringTest >> testLoremIpsum [
	| fillerText |
	fillerText := String loremIpsum.
	self denyEmpty: fillerText.
	self assert: (fillerText beginsWith: 'Lorem ipsum').
	self assert: (fillerText endsWith: 'laborum.').
	self assert: fillerText lines first equals: fillerText.
	self assert: fillerText isAsciiString.
	self assert: (Character space split: fillerText) size > 10
]

{ #category : #'tests - instance creation' }
StringTest >> testLoremIpsum2048 [
	| fillerText |
	fillerText := String loremIpsum: 2048.
	self assert: fillerText size equals: 2048.
	self assert: (fillerText beginsWith: 'Lorem ipsum').
	self assert: (fillerText includesSubstring: 'laborum.').
	self assert: (fillerText endsWith: ('.', String cr)).
	self assert: fillerText lines size > 2.
	self assert: fillerText isAsciiString.
	self assert: (Character space split: fillerText) size > 75
]

{ #category : #'tests - comparing' }
StringTest >> testMatch [

	#('**' 'f**'  'f**o' 'f*' '*f*' 'f#*' 'f##' '*oo' '#oo' '*o*' '#o#' '#o*' '*o#' 'fo*' 'fo#' '*foo*' '###' '*#'  'f*#' 'f*#o')
		do: [ :each | self assert: (each match: 'foo') ].
	#('bar' 'foo#' '#foo' '*foo#' '#foo*' '*bar*') do: [ :each |
		self deny: (each match: 'foo') ]
]

{ #category : #tests }
StringTest >> testNumArgs [
	"This is about http://code.google.com/p/pharo/issues/detail?id=237"
	
	| binary |
	binary := '*+-/\~=<>&@%,|'.
	self assert: (binary allSatisfy: [:char1 |
			(String with: char1) numArgs = 1 and: [binary allSatisfy: [:char2 |
				(String with: char1 with: char2) numArgs = 1 and: [binary allSatisfy: [:char3 |
					(String with: char1 with: char2 with: char3) numArgs = 1]]]]])
		description: 'binary selectors have 1 argument'.
		
	self assert: 'x' numArgs = 0
		description: 'unary selectors have 0 arguments'.
	self assert: 'x0' numArgs = 0
		description: 'unary selectors have 0 arguments'.
	self assert: 'yourself' numArgs = 0
		description: 'unary selectors have 0 arguments'.
		
	self assert: 'x:' numArgs = 1
		description: 'keyword selectors have as many elements as colons characters'.
	self assert: 'x:y:' numArgs = 2
		description: 'keyword selectors have as many elements as colons characters'.
	self assert: 'at:put:' numArgs = 2
		description: 'keyword selectors have as many elements as colons characters'.
			
	self assert: 'x_y_z' numArgs = 0
		description: 'selectors can contain underscores'.
	self assert: '_x' numArgs = 0
		description: 'selectors can begin with an underscore'.
	self assert: '_:_:' numArgs = 2
		description: 'keyword selectors can contain underscores'.
		
	self assert: 'at:withoutTrailingColon' numArgs = -1
		description: 'keyword selectors should have a trailing colon character'.
		
	self assert: ':x' numArgs = -1
		description: 'keyword selectors cannot begin with a colon character'.
		
	self assert: 'x::y:' numArgs = -1
		description: 'keyword selectors cannot have two consecutive colon characters'.
		
	self assert: '0x' numArgs = -1
		description: 'selectors cannot begin with a digit'.
		
	self assert: 'x::0y:' numArgs = -1
		description: 'keyword selectors cannot have any key beginning with a digit'.
	
	
]

{ #category : #tests }
StringTest >> testNumericSuffix [

	self assert: 'abc98' numericSuffix equals: 98.
	self assert: '98abc' numericSuffix equals: 0.
	self assert: '  123abc456' numericSuffix equals: 456.
	self assert: 'abc456 789' numericSuffix equals: 789.
	self assert: '012éà ôüÖ ẞ123' numericSuffix equals: 123
]

{ #category : #tests }
StringTest >> testOccursInWithEmptyCaseSensitive [

	self assert: ('abc98def' occursInWithEmpty: 'abc' caseSensitive: true). 
	self deny: ('abc98def' occursInWithEmpty: 'Abc' caseSensitive: true). 
	self assert: ('abc98def' occursInWithEmpty: 'Abc' caseSensitive: false).
	self assert: ('012éà ôüÖ ẞ345' occursInWithEmpty: '012' caseSensitive: true).
	self deny: ('012éàôüÖ ẞ345' occursInWithEmpty: 'ÉÀÔÜÖ' caseSensitive: true)

]

{ #category : #tests }
StringTest >> testOnlyLetters [

	self assert: 'abc98def' onlyLetters equals: 'abcdef'.
	self assert: 'abc 98 12 def' onlyLetters equals: 'abcdef'.
	self assert: '012éà ôüÖ ẞ345' onlyLetters equals: 'éàôüÖẞ'.
	self assert: '123 456' onlyLetters equals: ''.
	self assert: '' onlyLetters equals: ''


]

{ #category : #tests }
StringTest >> testPadLeftTo [

	self assert: ('a' padLeftTo: 3) equals: '  a'. 
	self assert: ('a' padLeftTo: 1) equals: 'a'. 
	self assert: ('a' padLeftTo: 0) equals: 'a'
]

{ #category : #tests }
StringTest >> testPadLeftToWith [

	self assert: ('a' padLeftTo: 3 with: $#) equals: '##a'. 
	self assert: ('a' padLeftTo: 1 with: $#) equals: 'a'. 
	self assert: ('a' padLeftTo: 0 with: $#) equals: 'a'
]

{ #category : #tests }
StringTest >> testPadRightTo [

	self assert: ('a' padRightTo: 3) equals: 'a  '. 
	self assert: ('a' padRightTo: 1) equals: 'a'. 
	self assert: ('a' padRightTo: 0) equals: 'a'
]

{ #category : #tests }
StringTest >> testPadRightToWith [

	self assert: ('a' padRightTo: 3 with: $#) equals: 'a##'. 
	self assert: ('a' padRightTo: 1 with: $#) equals: 'a'. 
	self assert: ('a' padRightTo: 0 with: $#) equals: 'a'
]

{ #category : #tests }
StringTest >> testReadFrom [
	self 
		assert: (String readFrom: ($' asString, 'foo', $' asString) readStream)
		equals: 'foo'.
	self 
		assert: (String readFrom: ($' asString, 'this ', $' asString, $' asString, ' is embedded', $' asString) readStream)
		equals: 'this '' is embedded'.
	self 
		assert: (String readFrom: ('<whitespace>', $' asString, 'foo', $' asString, '<whitespace>') readStream)
		equals: 'foo'.
	self
		assert: (String readFrom: 'this '' is embedded' printString readStream)
		equals: 'this '' is embedded'
]

{ #category : #'tests - streaming' }
StringTest >> testReadStreamDo [
	string readStreamDo: [ :stream | self assert: stream contents equals: string ]
]

{ #category : #'tests - converting' }
StringTest >> testRepeat [

	self 
	assert: ('123' repeat: 1) equals: '123';
	assert: ('123' repeat: 2) equals: '123123';
	assert: ('123' repeat: 0) equals: '';
	should: [ '123' repeat: -1 ] raise: Error.
]

{ #category : #'tests - converting' }
StringTest >> testRomanNumber [

	self assert: 'I' romanNumber equals: 1.
	self assert: 'V' romanNumber equals: 5.
	self assert: 'XVI' romanNumber equals: 16.
	self assert: 'XIV' romanNumber equals: 14.
	self assert: 'MDCLXXXVII' romanNumber equals: 1687.
	self assert: 'MCMXLII' romanNumber equals: 1942.
	self assert: 'DCLXVI' romanNumber equals: 666.
	self assert: '-V' romanNumber equals: -5.
	self assert: '-MDCCCXCV' romanNumber equals: -1895.
]

{ #category : #test }
StringTest >> testSkipAnySubstringStartingAt [
	
	"Simple skip"
	self assert: ('abcd' skipAnySubstring: #('a') startingAt: 1) equals: 2. 
	"Test multiple substrings to skip"
	self assert: ('abcd' skipAnySubstring: #('a' 'b' 'd') startingAt: 1) equals: 3.
	"Test skip symbol"
	self assert: ('abcd' skipAnySubstring: #(ab) startingAt: 1) equals: 3.
	"Test string is full of substrings to skip"
	self assert: ('abcd' skipAnySubstring: #('ab' 'cd') startingAt: 1) equals: 5. 
	"Test first substring matches but second substring is larger than entire string"
	self assert: ('abcd' skipAnySubstring: #('ab' 'abcdefg') startingAt: 1) equals: 3.
	"Test first substring is larger than entire string, and second substring matches string"
	self assert: ('abcd' skipAnySubstring: #('abcdefg' 'ab') startingAt: 1) equals: 3.
	"Test string is empty, return length of string + 1"
	self assert: ('' skipAnySubstring: #('ab') startingAt: 1) equals: 1.
	"Test starting at index > 1"
	self assert: ('abcde' skipAnySubstring: #('cd') startingAt: 3) equals: 5.
	"Test substring appears multiple times in a row"
	self assert: ('ababc' skipAnySubstring: #('ab') startingAt: 1) equals: 5.
	"Test if delimiters is a string it is treated as a collection of characters"
	self assert: (', ab' skipAnySubstring: ' ,' startingAt: 1) equals: 3.
	"Test how delimiters order matters: substrings are skipped greedily with no backtracking"
	self assert: ('abcdefg' skipAnySubstring: #('abcd' 'abc' 'def' 'g') startingAt: 1) equals: 5.
	self assert: ('abcdefg' skipAnySubstring: #('abc' 'def' 'g' 'abcd') startingAt: 1) equals: 8.
]

{ #category : #'tests - instance creation' }
StringTest >> testSpace [
		
	string := String new.
	self assert: string size equals: 0. 
	
	string := String space.
	self assert: string size equals: 1.
	self assert: string equals: ' '
]

{ #category : #tests }
StringTest >> testStoreOn [
	self assert: (String streamContents: [ :s | 'Foo''Bar' storeOn: s ]) equals: '''Foo''''Bar'''
]

{ #category : #'tests - converting' }
StringTest >> testSubstrings [
	| allByteCharacters substring separators |

	allByteCharacters := Character allByteCharacters asString.
	substring := allByteCharacters select: [:each | each isLetter].
	separators := allByteCharacters reject: [:each | each isLetter].
	{'' -> {}.
		separators -> {}.
		substring -> {substring}.
		(substring, separators) -> {substring}.
		(separators, substring) -> {substring}.
		(separators, substring, separators) -> {substring}.
		(substring, separators, substring) -> {substring. substring}.
		(substring, separators, substring, separators) -> {substring. substring}.
		(separators, substring, separators, substring) -> {substring. substring}}
		do: [:each | self assert: (each key substrings: separators) equals: each value].

	"test the unary version"
	substring := allByteCharacters reject: [:each | each isSeparator].
	separators := allByteCharacters select: [:each | each isSeparator].
	{'' -> {}.
		separators -> {}.
		substring -> {substring}.
		(substring, separators) -> {substring}.
		(separators, substring) -> {substring}.
		(separators, substring, separators) -> {substring}.
		(substring, separators, substring) -> {substring. substring}.
		(substring, separators, substring, separators) -> {substring. substring}.
		(separators, substring, separators, substring) -> {substring. substring}}
		do: [:each | self assert: each key substrings equals: each value].
]

{ #category : #tests }
StringTest >> testTranslateToLowercase [
	
	self assert: 'test this string' copy translateToLowercase equals: 'test this string'.
	self assert: ' Test THIS sTRing' copy translateToLowercase equals: ' test this string'.
	self assert: '' copy translateToLowercase equals: ''.
	self assert: 'ÔÜÖ' copy translateToLowercase equals: 'ôüö'.
	self assert: '123éàôüÖẞ' copy translateToLowercase equals: '123éàôüöẞ'
]

{ #category : #tests }
StringTest >> testTranslateToUppercase [

	self assert: 'test this string' copy translateToUppercase equals: 'TEST THIS STRING'.
	self assert: ' Test THIS sTRing' copy translateToUppercase equals: ' TEST THIS STRING'.
	self assert: '' copy translateToUppercase equals: ''.
	self assert: 'ÔÜÖ' copy translateToUppercase equals: 'ÔÜÖ'.
	self assert: '123éàôüÖẞ' copy translateToUppercase equals: '123ÉÀÔÜÖẞ'
]

{ #category : #'tests - converting' }
StringTest >> testTrimBoth [
	self assert: '' trimBoth equals: ''.
	self assert: ' ' trimBoth equals: ''.
	self assert: '	' trimBoth equals: ''.
	self assert: 'foo' trimBoth equals: 'foo'.
	self assert: ' foo ' trimBoth equals: 'foo'.
	self assert: '  foo  ' trimBoth equals: 'foo'.
	self assert: ((String with: Character cr), '   foo  ') trimBoth equals: 'foo'.
	
	self assert: ('aabbaa' trimBoth: [ :each | each = $a ]) equals: 'bb'.
	self assert: ('bbaabb' trimBoth: [ :each | each = $a ]) equals: 'bbaabb'
]

{ #category : #'tests - converting' }
StringTest >> testTrimLeft [
	self assert: '' trimLeft equals: ''.
	self assert: ' ' trimLeft equals: ''.
	self assert: '	' trimLeft equals: ''.
	self assert: 'foo' trimLeft equals: 'foo'.
	self assert: ' foo ' trimLeft equals: 'foo '.
	self assert: '  foo  ' trimLeft equals: 'foo  '.
	
	self assert: ('aabbaa' trimLeft: [ :each | each = $a ]) equals: 'bbaa'.
	self assert: ('bbaabb' trimLeft: [ :each | each = $a ]) equals: 'bbaabb'
]

{ #category : #'tests - converting' }
StringTest >> testTrimLineSpaces [
	self assert: 'test     \do' withCRs trimLineSpaces equals: 'test\do' withCRs.
	self assert: 'test     \  do' withCRs trimLineSpaces equals: 'test\  do' withCRs.
	self assert: 'test \do\' withCRs trimLineSpaces equals: 'test\do' withCRs.
	self assert: 'test \do' withCRs trimLineSpaces equals: 'test\do' withCRs.
	self assert: 'test do' withCRs trimLineSpaces equals: 'test do' withCRs.
	self assert: 'test\ \ ' withCRs trimLineSpaces equals: 'test\\' withCRs.
]

{ #category : #'tests - converting' }
StringTest >> testTrimRight [
	self assert: '' trimRight equals: ''.
	self assert: ' ' trimRight equals: ''.
	self assert: '	' trimRight equals: ''.
	self assert: 'foo' trimRight equals: 'foo'.
	self assert: ' foo ' trimRight equals: ' foo'.
	self assert: '  foo  ' trimRight equals: '  foo'.
	
	self assert: ('aabbaa' trimRight: [ :each | each = $a ]) equals: 'aabb'.
	self assert: ('bbaabb' trimRight: [ :each | each = $a ]) equals: 'bbaabb'
]

{ #category : #'tests - copying' }
StringTest >> testTrimmed [
	self assert: '  a  ' trimmed equals: 'a'.
]

{ #category : #'tests - converting' }
StringTest >> testUncapitalized [
	| uc lc empty |
	uc := 'MElViN'.
	lc := 'mElViN'.
	empty := ' '.
	self assert: uc uncapitalized equals: lc.
	self assert: lc uncapitalized equals: lc.
	"the string gets copied"
	self deny: lc uncapitalized identicalTo: lc.
	self deny: empty uncapitalized identicalTo: empty
]

{ #category : #'tests - converting' }
StringTest >> testUpTo [
	
	self assert: #up:to: keywords equals: #(up: to:).
	self assert: #copy:from:to: keywords equals: #(copy: from: to:).
	self assert: #up keywords equals: #(up).
	self assert: #at: keywords equals: #(at:).
	
]

{ #category : #'tests - converting' }
StringTest >> testWithBlanksCondensed [
	#( 
		'foo' 'foo'
		'foo bar' 'foo bar'
		'' ''
		' ' ''
		'foo  bar  !' 'foo bar !'
		' foo  bar  ! ' 'foo bar !'
		'  foo  bar  !  ' 'foo bar !'
		'		tabs		tabs	!		' 'tabs	tabs	!'
		'space followed by tab 	!' 'space followed by tab !'
	) pairsDo: [ :input :output |
		self assert: input withBlanksCondensed equals: output ]
	
]

{ #category : #'tests - converting' }
StringTest >> testWithFirstCharacterDownshifted [
	| uc lc empty |
	uc := 'MElViN'.
	lc := 'mElViN'.
	empty := ' '.
	self assert: uc uncapitalized equals: lc.
	self assert: lc uncapitalized equals: lc.
	"the string gets copied"
	self deny: lc uncapitalized identicalTo: lc.
	self deny: empty uncapitalized identicalTo: empty
]

{ #category : #'tests - internet' }
StringTest >> testWithInternalLineEndings [

	{
		'abc' -> 'abc'.
		'abc', String cr -> ('abc', String cr).
		'abc', String lf -> ('abc', String cr).
		'abc', String crlf -> ('abc', String cr).
		String cr, 'abc' -> (String cr, 'abc').
		String lf, 'abc' -> (String cr, 'abc').
		String crlf, 'abc' -> (String cr, 'abc').
		'abc', String cr, String cr, 'abc' -> ('abc', String cr, String cr, 'abc').
		'abc', String lf, String lf, 'abc' -> ('abc', String cr, String cr, 'abc').
		'abc', String crlf, String crlf, 'abc' -> ('abc', String cr, String cr, 'abc').
		String cr, 'abc', String cr, String crlf, 'abc', String lf -> (String cr, 'abc', String cr, String cr, 'abc', String cr).
		String lf, 'abc', String lf, String crlf, 'abc', String cr -> (String cr, 'abc', String cr, String cr, 'abc', String cr).
		(WideString with: 403 asCharacter with: Character lf) -> (WideString with: 403 asCharacter with: Character cr).
	} do: [ :each |
		self assert: each key withInternalLineEndings equals: each value ]
]

{ #category : #'tests - internet' }
StringTest >> testWithInternetLineEndings [

	{
		'abc' -> 'abc'.
		'abc', String cr -> ('abc', String crlf).
		'abc', String lf -> ('abc', String crlf).
		'abc', String crlf -> ('abc', String crlf).
		String cr, 'abc' -> (String crlf, 'abc').
		String lf, 'abc' -> (String crlf, 'abc').
		String crlf, 'abc' -> (String crlf, 'abc').
		'abc', String cr, String cr, 'abc' -> ('abc', String crlf, String crlf, 'abc').
		'abc', String lf, String lf, 'abc' -> ('abc', String crlf, String crlf, 'abc').
		'abc', String crlf, String crlf, 'abc' -> ('abc', String crlf, String crlf, 'abc').
		String cr, 'abc', String cr, String crlf, 'abc', String lf -> (String crlf, 'abc', String crlf, String crlf, 'abc', String crlf).
		String lf, 'abc', String lf, String crlf, 'abc', String cr -> (String crlf, 'abc', String crlf, String crlf, 'abc', String crlf).
	} do: [ :each |
		self assert: each key withInternetLineEndings equals: each value ]
]

{ #category : #'tests - converting' }
StringTest >> testWithNoLineLongerThan [

	self assert: ('Hello World' withNoLineLongerThan: 5) equals: ('Hello' , String cr , 'World').

	self assert: ('Sample text to line break at some point' withNoLineLongerThan: 28)
		  equals: ('Sample text to line break at' , String cr , 'some point').
		
	self assert: ('Sample text' , String cr , 'to line break' , String cr , 'at some point' withNoLineLongerThan: 28)
		  equals: ('Sample text' , String cr , 'to line break' , String cr , 'at some point')
]

{ #category : #'tests - converting' }
StringTest >> testWithSeparatorsCompacted [
	#( 
		'foo' 'foo'
		'foo bar' 'foo bar'
		'' ''
		' ' ' '
		'foo  bar  !' 'foo bar !'
		' foo  bar  ! ' ' foo bar ! '
		'  foo  bar  !  ' ' foo bar ! '
		'		tabs		tabs	!		' ' tabs tabs ! '
		'space followed by tab 	!' 'space followed by tab !'
	) pairsDo: [ :input :output |
		self assert: input withSeparatorsCompacted equals: output ]
	
]

{ #category : #'tests - internet' }
StringTest >> testWithUnixLineEndings [

	| original newString |
	{
		'abc' -> 'abc'.
		'abc', String cr -> ('abc', String lf).
		'abc', String lf -> ('abc', String lf).
		'abc', String crlf -> ('abc', String lf).
		String cr, 'abc' -> (String lf, 'abc').
		String lf, 'abc' -> (String lf, 'abc').
		String crlf, 'abc' -> (String lf, 'abc').
		'abc', String cr, String cr, 'abc' -> ('abc', String lf, String lf, 'abc').
		'abc', String lf, String lf, 'abc' -> ('abc', String lf, String lf, 'abc').
		'abc', String crlf, String crlf, 'abc' -> ('abc', String lf, String lf, 'abc').
		String cr, 'abc', String cr, String crlf, 'abc', String lf -> (String lf, 'abc', String lf, String lf, 'abc', String lf).
		String lf, 'abc', String lf, String crlf, 'abc', String cr -> (String lf, 'abc', String lf, String lf, 'abc', String lf).
		(WideString with: 403 asCharacter with: Character cr) -> (WideString with: 403 asCharacter with: Character lf).
	} do: [ :each |
		self assert: each key withUnixLineEndings equals: each value ].
	
	original :='asa' , String cr , 'asa'.
	self assert: (original at: 4) equals: Character cr.
	newString := original withUnixLineEndings.
	self assert: (original at: 4) equals: Character cr.
	self assert: (newString at: 4) equals: Character lf.
]

{ #category : #'tests - converting' }
StringTest >> testWithoutLeadingDigits [
	#( 
		'foo' 'foo'
		'123foo' 'foo'
		'123 bar7' 'bar7'
		' 123 	bar7' 'bar7'
		'foo.123.txt' 'foo.123.txt'
		'' ''
		'1' ''
		'1 2 3 ' ''
	) pairsDo: [ :input :output |
		self assert: input withoutLeadingDigits equals: output ]
	
]

{ #category : #'tests - converting' }
StringTest >> testWithoutPeriodSuffix [
	#( 
		'foo' 'foo'
		'foo.' 'foo'
		'foo.bar' 'foo'
		'foo.bar.txt' 'foo'
		'' ''
		'.' '.'
	) pairsDo: [ :input :output |
		self assert: input withoutPeriodSuffix equals: output ]
	
]

{ #category : #'tests - element accessing' }
StringTest >> testWithoutPrefix [
	self assert: ('UMLClass' withoutPrefix: 'UML') equals: 'Class'.
	self assert: ('UMLClass' withoutSuffix: 'Class') equals: 'UML'.
	
	self assert: ('UMLClass' withoutPrefix: 'Class') equals: 'UMLClass'.
	self assert: ('UMLClass' withoutSuffix: 'UML') equals: 'UMLClass'.
]

{ #category : #'tests - internet' }
StringTest >> testWithoutQuoting [

 	#( '"foo"' 'foo'
		'''foo''' 'foo'
		'"foo''' '"foo'''
		'''foo"' '''foo"'
		'"foo' '"foo'
		'foo"' 'foo"'
		'foo' 'foo') 
	pairsDo: [ :before :after |
		self assert: before withoutQuoting equals: after ]
]

{ #category : #'tests - converting' }
StringTest >> testWithoutTrailingDigits [
	#( 
		'foo' 'foo'
		'foo123' 'foo'
		'bar 123 ' 'bar'
		'foo.123.txt' 'foo.123.txt'
		'' ''
		'1' ''
		'1 2 3 ' ''
	) pairsDo: [ :input :output |
		self assert: input withoutTrailingDigits equals: output ]
	
]

{ #category : #'tests - copying' }
StringTest >> testWithoutTrailingNewlines [

	self assert: ('123',String cr) withoutTrailingNewlines equals: '123'.
	self assert: ('123',String lf) withoutTrailingNewlines equals: '123'.
	self assert: ('123',String cr, String lf) withoutTrailingNewlines equals: '123'.
]

{ #category : #'tests - converting' }
StringTest >> testWriteStreamConvertsToWideString [
	| oldWideString newString ws |
	"test that a write stream on a ByteString is autoconverted into a WideString if a Wide character is inserted into it"
	oldWideString := (WideString new: 1) wordAt: 1 
										put: 20984060; 
										yourself.
	newString := (String new: oldWideString size).
	ws := newString writeStream.
	oldWideString do: [:each | ws nextPut: each].
	self assert: newString equals: oldWideString.
]

{ #category : #'tests - streaming' }
StringTest >> testWriteStreamDo [
	emptyString
		writeStreamDo: [ :stream | 
			stream nextPutAll: string.
			self assert: stream contents equals: string ].
	self assert: (emptyString writeStreamDo: [ :stream | true ])
]

{ #category : #'tests - lines' }
StringTest >> testWthNoLineLongerThan [
	| phrases |
	phrases := {
		'Fred the bear went down to the brook to read his book in silence'.
		'Fred the bear went down' , String cr , ' to the brook to ' , String cr , 'read his book in silence'.
		'Fred the bear went down' , String lf , '  to the brook to ' , String lf , 'read his book in silence'.
		'Fred the bear went down' , String crlf , '  to the brook to ' , String crlf , 'read his book in silence'.
		}.
	#(5 7 9) do: [:length |
		phrases do: [:phrase |
			| split |
			split := phrase withNoLineLongerThan: length.
			self
				assert: (split copyWithoutAll: CharacterSet separators) = (phrase copyWithoutAll: CharacterSet separators)
				description: 'no information should be lost'.
			split linesDo: [:line |
				self assert: line size <= length description: 'lines should not be longer than prescribed'].
			phrase lineCount = 1 ifTrue: [| lastLineSize |
				lastLineSize := length.
				split linesDo: [:line |
					line isEmpty ifFalse: [| firstWordSize |
						firstWordSize := line indexOfAnyOf: CharacterSet separators startingAt: 1 ifAbsent: [line size + 1].
						self assert: (lastLineSize + firstWordSize) > length description: 'split was too short'.
						lastLineSize := line size]]]]]
]

{ #category : #'tests - converting' }
StringTest >> testindexOfstartingAt [

	self assert: ('aa aa éé aa aa' indexOf: $a startingAt: 8) equals: 10.
	self assert: ('aa aa éé aa aa' indexOf: $z startingAt: 8) equals: 0.
]

{ #category : #requirements }
StringTest >> unsortedCollection [
	^ unsortedCollection 
]

{ #category : #requirements }
StringTest >> withEqualElements [
	" return a collection  including equal elements (classic equality)"
	^ sameAtEndAndBegining 	
]
