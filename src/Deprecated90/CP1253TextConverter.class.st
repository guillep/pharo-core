"
Text converter for CP1253.  Windows code page used for Greek. 
"
Class {
	#name : #CP1253TextConverter,
	#superclass : #ByteTextConverter,
	#category : #Deprecated90
}

{ #category : #accessing }
CP1253TextConverter class >> byteToUnicodeSpec [
	"ByteTextConverter generateByteToUnicodeSpec: 'http://unicode.org/Public/MAPPINGS/VENDORS/MICSFT/WINDOWS/CP1253.TXT'"

	^ #(
	16r20AC nil 16r201A 16r0192 16r201E 16r2026 16r2020 16r2021 
	nil 16r2030 nil 16r2039 nil nil nil nil 
	nil 16r2018 16r2019 16r201C 16r201D 16r2022 16r2013 16r2014 
	nil 16r2122 nil 16r203A nil nil nil nil 
	16r00A0 16r0385 16r0386 16r00A3 16r00A4 16r00A5 16r00A6 16r00A7 
	16r00A8 16r00A9 nil 16r00AB 16r00AC 16r00AD 16r00AE 16r2015 
	16r00B0 16r00B1 16r00B2 16r00B3 16r0384 16r00B5 16r00B6 16r00B7 
	16r0388 16r0389 16r038A 16r00BB 16r038C 16r00BD 16r038E 16r038F 
	16r0390 16r0391 16r0392 16r0393 16r0394 16r0395 16r0396 16r0397 
	16r0398 16r0399 16r039A 16r039B 16r039C 16r039D 16r039E 16r039F 
	16r03A0 16r03A1 nil 16r03A3 16r03A4 16r03A5 16r03A6 16r03A7 
	16r03A8 16r03A9 16r03AA 16r03AB 16r03AC 16r03AD 16r03AE 16r03AF 
	16r03B0 16r03B1 16r03B2 16r03B3 16r03B4 16r03B5 16r03B6 16r03B7 
	16r03B8 16r03B9 16r03BA 16r03BB 16r03BC 16r03BD 16r03BE 16r03BF 
	16r03C0 16r03C1 16r03C2 16r03C3 16r03C4 16r03C5 16r03C6 16r03C7 
	16r03C8 16r03C9 16r03CA 16r03CB 16r03CC 16r03CD 16r03CE nil )
]

{ #category : #accessing }
CP1253TextConverter class >> encodingNames [ 

	^ #('cp-1253') copy

]

{ #category : #initialization }
CP1253TextConverter class >> initialize [
	self initializeTables
]

{ #category : #accessing }
CP1253TextConverter class >> languageEnvironment [
	^GreekEnvironment
]
