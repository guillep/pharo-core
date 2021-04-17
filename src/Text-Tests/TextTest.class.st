"
A TextTest is a test class for testing the behavior of Text
"
Class {
	#name : #TextTest,
	#superclass : #TestCase,
	#instVars : [
		'text',
		'string'
	],
	#category : #'Text-Tests-Base'
}

{ #category : #examples }
TextTest >> example1: size [
	<sampleInstance>
	^(TextStream on: (Text new: size))
		nextPutAll: 'xxxxx' asText;
		nextPutAll: 'yyyyy' asText allBold;
		nextPutAll: 'zzzzzzz' asText;
		contents
]

{ #category : #examples }
TextTest >> example2 [
	<sampleInstance>
	^(TextStream on: (Text new: 50))
		nextPutAll: 'abc' asText;
		nextPutAll: 'def' asText allBold;
		nextPutAll: 'ghijk' asText;
		contents
]

{ #category : #examples }
TextTest >> replacementExample3 [
  "For a Text t, the following assertion should always hold:
     t string size = t run size 
   This test examines the preservation of this assertion for in-place replacement 
   Here, the replacement text is shorteer than the text that is shall replace."
   | replacement startPos length startPosInRep string2 |
   text := (string := 'This is again simple text' copy) asText.
   "Without the copy, we would modify a constant that the compiler attached at the compiled method."
   startPos := string findString: 'simple'. 
   length  := 'simple' size.
   replacement := (string2 := 'both simple and short') asText.
   startPosInRep :=  string2 findString: 'short'.
   text replaceFrom: startPos to: startPos + length - 1 with: replacement startingAt: startPosInRep
]

{ #category : #running }
TextTest >> setUp [
	super setUp.
	string := 'Pharo is cool'.
	text :=  string copy asText.
	text addAttribute: TextEmphasis bold from: 1 to: 5.
	text addAttribute: TextColor blue from: 1 to: 5.
	text addAttribute: TextEmphasis underlined from: 7 to: 8.
	text addAttribute: TextColor red from: 7 to: 13.
]

{ #category : #'tests-error' }
TextTest >> testAddAttributeFromTo [
	"Adding attributes before begining"
	text := 'foo' asText.
	self should: [ text addAttribute: TextColor red from: 0 to: text size ] raise: Error.
	"Adding attribute after the end"
	text := 'foo' asText.
	self should: [ text addAttribute: TextColor red from: 2 to: text size + 1 ] raise: Error
]

{ #category : #tests }
TextTest >> testAdjacentRunsWithIdentitcalAttributes [
	"This test verifies that adjacent runs with identical attributes are coalesced."

	| ts rangeOfBold |
	ts := TextStream on: (Text new: 50).
	ts nextPutAll: 'abc' asText.
	ts nextPutAll: 'def' asText allBold.
	ts nextPutAll: 'ghijk'.
	text := ts contents.
	rangeOfBold := text find:  TextEmphasis bold.
	text removeAttribute: TextEmphasis bold from: rangeOfBold first to: rangeOfBold last. 
   "Now, check that only one run is left and that it has the correct size."
	self assert: text runs runs size = 1 & (text runs size = text string size)

]

{ #category : #tests }
TextTest >> testAppend [
	| receiver argument result expectedResult |
	"Append text without attribute"
	receiver := 'xxx' asText addAttribute: TextEmphasis bold from: 1 to: 3.
	argument := 'yyy'.
	expectedResult := 'xxxyyy' asText addAttribute: TextEmphasis bold from: 1 to: 3.
	result := receiver append: argument.
	self assert: result identicalTo: receiver.
	self assert: result string equals: expectedResult string.
	self assert: result runs equals: expectedResult runs.

	"Append text with attribute"
	receiver := 'xxx' asText addAttribute: TextEmphasis bold from: 1 to: 3.
	argument := 'yyy' asText addAttribute: TextEmphasis italic from: 1 to: 3.
	result := receiver append: argument.
	expectedResult := 'xxxyyy' asText
		addAttribute: TextEmphasis bold from: 1 to: 3;
		addAttribute: TextEmphasis italic from: 4 to: 6.
	self assert: result identicalTo: receiver.
	self assert: result string equals: expectedResult string.
	self assert: result runs equals: expectedResult runs
]

{ #category : #tests }
TextTest >> testAsNumber [
	self assert: '123' asText asNumber equals: 123.
	self assert: '1.23e2' asText asNumber equals: 123.
	self assert: '2r1000' asText asNumber equals: 8.


]

{ #category : #tests }
TextTest >> testAsString [
	self assert: text asString equals: 'Pharo is cool'


]

{ #category : #tests }
TextTest >> testAt [ 
	string withIndexDo: [ :char :index |
		self assert: (text at: index) equals: char]
]

{ #category : #tests }
TextTest >> testAtPut [
	text at: 2 put: $H.
	text at: 3 put: $A.
	text at: 4 put: $R.
	text at: 5 put: $O.
	self assert: text string equals: 'PHARO is cool'
]

{ #category : #tests }
TextTest >> testExampleText1 [
	"Inspired by a bug report from Tim Olson.
	Text attributes are lost when the stream collection is expanded.
	Documented BUG!!!"

    | text1 text2 atts1 atts2 |
	text1 := self example1: 10. " here we will loose the attribute bold "
	text2 := self example1: 50. " here we have a larger buffer and will not loose text attributes "
	atts1 := text1 runs copyFrom: 6 to: 10. 
	atts2 := text2 runs copyFrom: 6 to: 10. 

	self assert: atts1 equals: atts2
      
]

{ #category : #tests }
TextTest >> testExampleText2 [
	"a Text looses its attributes when it is reversed "
	
	| text1 text2 |
	text1 := self example2.
	text2 := text1 reversed reversed.
	self assert: text1 runs equals: text2 runs
 

]

{ #category : #tests }
TextTest >> testFindStringStartingAt [
	self assert: (text findString: 'Pharo' startingAt: 1) equals: 1.
	self assert: (text findString: 'cool' startingAt: 1) equals: 10.
	self assert: (text findString: 'Pharo' startingAt: 2) equals: 0.
	
]

{ #category : #tests }
TextTest >> testFindStringStartingAtCaseSensitive [
	self assert: (text findString: 'pharo' startingAt: 1 caseSensitive: false) equals: 1.
	self assert: (text findString: 'pharo' startingAt: 1 caseSensitive: true) equals: 0.

	self assert: (text findString: 'COOL' startingAt: 1  caseSensitive: false) equals: 10.
	self assert: (text findString: 'COOL' startingAt: 1  caseSensitive: true) equals: 0.

	
]

{ #category : #test }
TextTest >> testGtDisplayOn [

	| hello exp res |
	hello := 'Hello Pharo' asText.
	exp := String streamContents: [:s | hello printOn: s].
	res := String streamContents: [:s | hello displayStringOn: s].
	self assert: res equals: exp.
]

{ #category : #tests }
TextTest >> testHowManyMatch [
	self assert: (text howManyMatch: 'Pharo') equals: 5.
	self assert: (text howManyMatch: 'Pha') equals: 3.
	self assert: (text howManyMatch: 'P') equals: 1.
	self assert: (text howManyMatch: 'p') equals: 0.
	self assert: (text howManyMatch: 'is') equals: 0.
	self assert: (text howManyMatch: 'cool') equals: 0.

]

{ #category : #tests }
TextTest >> testIncludesSubstring [
	"Test that Text correctly checks that the supplied substring is present (case sensitive)."
	self assert: ('testing this string' asText includesSubstring: 'ring').
	self assert: ('éèàôüößäóñíá' asText includesSubstring: '').
	self deny: ('éèàôüößäóñíá' asText includesSubstring: 'a').
	self assert: ('éèàôüößäóñíá' asText includesSubstring: 'ßä').
	self deny: ('kjdsnlksjdf' asText includesSubstring: 'K')
]

{ #category : #tests }
TextTest >> testIncludesSubstringCaseSensitive [
	"Test that Text correctly checks that the supplied substring is present,
	 both case sensitive and case insensitive."
	self deny: ('test this string' asText includesSubstring: 'Ring' caseSensitive: true).
	self assert: ('test this string' asText includesSubstring: 'Ring' caseSensitive: false).
	self deny: ('123éàôüöß' asText includesSubstring: '' caseSensitive: false).
	self assert: ('123éàôüöß' asText includesSubstring: 'öß' caseSensitive: true).
	self assert: ('123éàôüöß' asText includesSubstring: 'ÀÔ' caseSensitive: false)
]

{ #category : #tests }
TextTest >> testLineCount [
	text := Text streamContents: [:str | str << 'Pharo' << Character cr << 'is' << Character cr << 'cool'].
	self assert: text lineCount equals: 3
	
]

{ #category : #tests }
TextTest >> testPrepend [
	| receiver argument result expectedResult |
	"Prepend text without attribute"
	receiver := 'xxx' asText addAttribute: TextEmphasis bold from: 1 to: 3.
	argument := 'yyy'.
	expectedResult := 'yyyxxx' asText addAttribute: TextEmphasis bold from: 4 to: 6.
	result := receiver prepend: argument.
	self assert: result identicalTo: receiver.
	self assert: result string equals: expectedResult string.
	self assert: result runs equals: expectedResult runs.

	"Prepend text with attribute"
	receiver := 'xxx' asText addAttribute: TextEmphasis bold from: 1 to: 3.
	argument := 'yyy' asText addAttribute: TextEmphasis italic from: 1 to: 3.
	expectedResult := 'yyyxxx' asText
		addAttribute: TextEmphasis italic from: 1 to: 3;
		addAttribute: TextEmphasis bold from: 4 to: 6.
	result := receiver prepend: argument.
	self assert: result identicalTo: receiver.
	self assert: result string equals: expectedResult string.
	self assert: result runs equals: expectedResult runs
]

{ #category : #tests }
TextTest >> testRangeOfStartingAt [
	self assert: (text rangeOf: TextEmphasis bold startingAt: 1) equals: (1 to: 5).
	"even an index at beginning of the range, it returns the whole interval"
	self assert: (text rangeOf: TextEmphasis bold startingAt: 2) equals: (1 to: 5).
	self assert: (text rangeOf: TextEmphasis bold startingAt: 5) equals: (1 to: 5).
	"but not when index is outside the range"
	self deny: (text rangeOf: TextEmphasis bold startingAt: 6) equals: (1 to: 5).
	"search for alternate attribute works too"
	self assert: (text rangeOf: TextColor blue startingAt: 2) equals: (1 to: 5).
	"attributes with different range"
	self assert: (text rangeOf: TextColor red startingAt: 7) equals: (7 to: 13).
	self assert: (text rangeOf: TextEmphasis underlined startingAt: 7) equals: (7 to: 8).
	self assert: (text rangeOf: TextEmphasis underlined startingAt: 8) equals: (7 to: 8).
	self deny: (text rangeOf: TextEmphasis underlined startingAt: 5) equals: (7 to: 8).
]

{ #category : #'tests-error' }
TextTest >> testRemoveAttribute [
	"Removing attribute before the beginning"
	text := Text string: 'foo' attribute: TextColor red.
	self should: [ text removeAttribute: TextColor red from: 0 to: text size ] raise: Error.
	"Removing attribute after the end"
	text := Text string: 'foo' attribute: TextColor red.
	self should: [ text addAttribute: TextColor red from: 2 to: text size + 1 ] raise: Error
]

{ #category : #tests }
TextTest >> testReplaceFromToWith [
	| anotherText bold|
	bold := TextEmphasis bold.
	anotherText := 'hot' asText addAttribute: bold.
	text replaceFrom: 10 to: 13 with: anotherText.
	self assert: text string equals: 'Pharo is hot'.
	self assert: text size equals: 12.
	"check attribute is has expected"
	10 to: 12 do: [ :index | 
		| attr |
		attr := text attributesAt: index.
		self assert: attr size equals: 1.
		self assert: attr first equals: bold ]
]

{ #category : #tests }
TextTest >> testReplacementAtStartPos1 [
	"For a Text t, the following assertion should always hold:
     t string size = t run size 
	This test examines the preservation of this assertion for in-place replacement"
	| replacement  length  |
	text := 'This is a simple text' copy asText.
	"Without the copy, we would modify a constant that the compiler attached at the compiled method."
	length := 'This' size.
	replacement := 'That' asText.
	text replaceFrom: 1 to: length with: replacement startingAt: 1.
	self assert: text string size equals: text runs size
]

{ #category : #tests }
TextTest >> testReplacementAtStartPos2 [
  	"For a Text t, the following assertion should always hold:
     t string size = t run size 
	 This test examines the preservation of this assertion for in-place replacement."
	| replacement  length  |
	text := 'This is a simple text' copy asText.
	"Without the copy, we would modify a constant that the compiler attached at the compiled method."
	length  := 'This' size.
	replacement := 'That********' asText.
	text replaceFrom: 1 to: length with: replacement startingAt: 1.
	self assert: text string size equals: text runs size
]

{ #category : #'tests-error' }
TextTest >> testReplacementAtStartPos3 [
	"For a Text t, the following assertion should always hold:
		t string size = t run size 
	This test examines the preservation of this assertion for in-place replacement 
	Here, the replacement text is shorter than the text that is shall replace."
   |  replacement  length  |
   text := 'This is a simple text' copy asText.
   "Without the copy, we would modify a constant that the compiler attached at the compiled method."
   length  := 'This' size.
   replacement := 'Thy' asText.
  self should: [ text replaceFrom: 1 to: length with: replacement startingAt: 1] raise: Error
]

{ #category : #tests }
TextTest >> testRuns [
	| attributes |
	attributes := RunArray new: 13 withAll: TextColor red.
	text runs: attributes.
	
	attributes := RunArray new: 12 withAll: TextColor red.
	self should: [ text runs: attributes ] raise: Error.

	attributes := RunArray new: 14 withAll: TextColor red.
	self should: [ text runs: attributes ] raise: Error.
]

{ #category : #'tests-error' }
TextTest >> testSettingRunsOfWrongSize [
	|  newRuns |
	newRuns := text runs copyReplaceFrom: 2 to: 1 with: (Array with: TextColor red).
	self should: [text runs: newRuns] raise: Error
]

{ #category : #tests }
TextTest >> testSize [
	self assert: text size equals: 13
]

{ #category : #tests }
TextTest >> testString [
	self assert: text string equals: 'Pharo is cool'
]

{ #category : #tests }
TextTest >> testTextEmphasisRangeDetection1 [
	"This tests the detection of the range of a text attribute."
	| startPos boldStyle |
	text := 'This is a text with attriute bold for some characters' asText.
	startPos := text findString: 'bold' startingAt: 1.
	text addAttribute: TextEmphasis bold from: startPos to: startPos + 3.
	boldStyle := TextEmphasis bold.

  "Uncomment the following statement for examine failures:"
  "-----------------
       (1 to: text size) do:
           [:idx | | range |
              range := text rangeOf: boldStyle startingAt: idx.
             Transcript show: startPos; show: ' -- '; show: idx printString; show: '  '; show: range printString; show: range size printString; show: ((idx between: startPos and: startPos + 3)
                  ifTrue:
                    [range first = startPos & (range size = 4)]
                  ifFalse:
                    [range first = idx & (range size = 0)]) printString; cr.
           ].
    ------------- "

	self assert: 
		((1 to: text size) allSatisfy:
			[:idx | | range |
				range := text rangeOf: boldStyle startingAt: idx.
				(idx between: startPos and: startPos + 3)
					ifTrue: [range first = startPos & (range size = 4)]
					ifFalse: [range first = idx & range isEmpty]])
]

{ #category : #tests }
TextTest >> testTextEmphasisRangeDetection2 [
	"This tests the detection of the range of a text attribute.
	 Here the searched attribute spans three runs. The objective of the test is whether the entire
	 range is always found."
	| startPos searchedStyle |
	text := 'This is a text with attriute bold for some characters' asText.
	startPos := text findString: 'bold' startingAt: 1.
	text addAttribute: TextEmphasis bold from: startPos to: startPos + 3.
	text addAttribute: TextEmphasis italic from: startPos - 2 to: startPos + 5.
	searchedStyle := TextEmphasis italic.

  "uncomment the following statement for examine failures: " 
  "-----------------------
       (1 to: text size) do:
           [:idx | | range | 
              range := text rangeOf: searchedStyle startingAt: idx.
             Transcript show: startPos; show: ' -- '; show: idx printString; show: '  '; show: range printString; show: range size printString; show: ((idx between: startPos - 2 and: startPos -2 + 7)
                  ifTrue:
                    [range first = (startPos - 2) & (range size = 8)]
                  ifFalse:
                    [range first = idx & (range size = 0)]) printString; cr.
           ].
   ----------------------- "
	self assert: 
			((1 to: text size) allSatisfy:
				[:idx | | range |
					range := text rangeOf: searchedStyle startingAt: idx.
					(idx between: startPos - 2 and: startPos -2 + 7)
						ifTrue: [range first = (startPos - 2) & (range size = 8)]
						ifFalse: [range first = idx & range isEmpty]])
]

{ #category : #tests }
TextTest >> testTextEmphasisRangeDetection3 [
	"This tests the detection of the range of a text attribute.
    Here the searched attribute spans three runs. The the range to be detected begins at text position 	 1. The objective of the test is whether the entire range is always found."

	| startPos searchedStyle |
	text := 'This is a text with attriute bold for some characters' asText.
	startPos := text findString: 'bold' startingAt: 1.
	text addAttribute: TextEmphasis bold from: startPos to: startPos + 3.
	text addAttribute: TextEmphasis italic from: 1 to: startPos + 5.
	searchedStyle := TextEmphasis italic.

	"Uncomment the following statement to examine failures:"
 	"-----------------------
       (1 to: text size) do:
           [:idx | | range | 
              range := text rangeOf: searchedStyle startingAt: idx.
             Transcript show: startPos;
					show: ' -- ';
					show: idx printString;
					show: '  ';
					show: range printString;
					show: range size printString;
                        show: ' ';
					 show: ((idx between: 1 and: startPos + 5)
                  					ifTrue:
                  					  [range first = 1 & (range size = (startPos + 5))]
                					ifFalse:
                   					 [range first = idx & (range size = 0)]) printString; cr.
           ].
   ----------------------- "
	self assert: 
       ((1 to: text size) allSatisfy:
           [:idx | | range |
              range := text rangeOf: searchedStyle startingAt: idx.
              (idx between: 1 and: startPos + 5)
                  ifTrue:
                    [range first = 1 & (range size = (startPos + 5))]
                  ifFalse:
                    [range first = idx & range isEmpty]])
]

{ #category : #tests }
TextTest >> testTextEmphasisRangeDetection4 [
	"This tests the detection of the range of a text attribute.
	 Here the searched attribute spans three runs. The the range to be detected extends to 
	 the end of the text . The objective of the test is whether the entire range is always found."

	| startPos searchedStyle |
	text := 'This is a text with attriute bold for some characters' asText.
	startPos := text findString: 'bold' startingAt: 1.
	text addAttribute: TextEmphasis bold from: startPos to: startPos + 3.	
	text addAttribute: TextEmphasis italic from: startPos - 2 to: text size.
	searchedStyle := TextEmphasis italic.

	"Uncomment the following statement to examine failures:"
 	"-----------------------------------------
       (1 to: text size) do:
           [:idx | | range | 
              range := text rangeOf: searchedStyle startingAt: idx.
             Transcript show: startPos;
					show: ' -- ';
					show: idx printString;
					show: '  ';
					show: range printString;
					show: range size printString;
                        show: ' ';
					 show: ((idx between: startPos - 2 and: text size)
                  			ifTrue:
   			                 [range first = (startPos - 2) & (range size = (text size - (startPos - 2) + 1))]
                  			ifFalse:
 			                 [range first = idx & (range size = 0)]) printString;
					cr.
           ].
   -------------------------------"

	self assert: 
       ((1 to: text size) allSatisfy:
           [:idx | | range |
              range := text rangeOf: searchedStyle startingAt: idx.
              (idx between: startPos - 2 and: text size)
                  ifTrue: [range first = (startPos - 2) & (range size = (text size - (startPos - 2) + 1))]
                  ifFalse: [range first = idx & range isEmpty]])
]

{ #category : #tests }
TextTest >> testTextReplacement1 [
	"For a Text t, the following assertion should always hold:
     t string size = t run size 
	This test examines the preservation of this assertion for in-place replacement"
   | replacement startPos length startPosInRep string2 |
   text := (string := 'This is a simple text' copy) asText.
   "Without the copy, we would modify a constant that the compiler attached at the compiled method."
   startPos := string findString: 'simple'. 
   length  := 'simple' size.
   replacement := (string2 := 'both simple and short*') asText.
   startPosInRep :=  string2 findString: 'short'.
   text replaceFrom: startPos to: startPos + length - 1 with: replacement startingAt: startPosInRep.
   self assert: text string size equals: text runs size
]

{ #category : #tests }
TextTest >> testTextReplacement2 [
	"For a Text t, the following assertion should always hold:
     	t string size = t run size 
    This test examines the preservation of this assertion for in-place replacement.
    Here, the replacement text has trailing characters."
	| replacement startPos length startPosInRep string2 |
	text := (string := 'This is simple text' copy) asText.
	"Without the copy, we would modify a constant that the compiler attached at the compiled method."
	startPos := string findString: 'simple'. 
	length := 'simple' size.
	replacement := (string2 := 'both simple and short*************') asText.
	startPosInRep :=  string2 findString: 'short'.
	text replaceFrom: startPos to: startPos + length - 1 with: replacement startingAt: startPosInRep.
	self assert: text string size equals: text runs size
]

{ #category : #'tests-error' }
TextTest >> testTextReplacement3 [
	"For a Text t, the following assertion should always hold:
		t string size = t run size 
	This test examines the preservation of this assertion for in-place replacement 
	Here, the replacement text is shorteer than the text that is shall replace."
	self should: [ self replacementExample3 ] raise: Error
]

{ #category : #tests }
TextTest >> testUnembellished [
	| anotherText |
	self deny: text unembellished.
	anotherText := 'Hello' asText 
		addAttribute: TextEmphasis bold.
	self assert: anotherText unembellished.
	anotherText addAttribute: TextFontChange font2.
	self deny: anotherText unembellished.

]
