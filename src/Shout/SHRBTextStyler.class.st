"
I'm the one who visits node to coloring the code
"
Class {
	#name : #SHRBTextStyler,
	#superclass : #SHTextStyler,
	#traits : 'TRBProgramNodeVisitor',
	#classTraits : 'TRBProgramNodeVisitor classTrait',
	#instVars : [
		'charAttr',
		'parentheseLevel',
		'bracketLevel',
		'classOrMetaClass',
		'font',
		'isForWorkspace',
		'pixelHeight',
		'workspace'
	],
	#classInstVars : [
		'styleTable',
		'textAttributesByPixelHeight',
		'formatIncompleteIdentifiers'
	],
	#category : #'Shout-Styling'
}

{ #category : #attributes }
SHRBTextStyler class >> attributeArrayForColor: aColorOrNil emphasis: anEmphasisSymbolOrArrayorNil font: aTextStyleOrFontOrNil [ 

	| emphArray answer |	
	answer := Array new.
	aColorOrNil ifNotNil: [ answer := answer , {TextColor color: aColorOrNil}].
	
	anEmphasisSymbolOrArrayorNil
		ifNotNil: [
			emphArray := anEmphasisSymbolOrArrayorNil isSymbol
						ifTrue: [{anEmphasisSymbolOrArrayorNil}]
						ifFalse: [anEmphasisSymbolOrArrayorNil].
			emphArray do: [:each | 
				each ~= #normal
					ifTrue: [answer := answer , {TextEmphasis perform: each}]]].
	
	aTextStyleOrFontOrNil
		ifNotNil: [ answer := answer , {TextFontReference toFont: aTextStyleOrFontOrNil}].
		
	^ answer
]

{ #category : #attributes }
SHRBTextStyler class >> attributesFor: aSymbol pixelHeight: aNumber [ 
	^ (self textAttributesByPixelHeight
		at: aNumber
		ifAbsentPut: [self initialTextAttributesForPixelHeight: aNumber])
		at: aSymbol
		ifAbsent: [#()]
]

{ #category : #styles }
SHRBTextStyler class >> blueStyleTable [
	"color can be a valid argument to Color class>>colorFrom: , or nil to
	use the editor text color.
	Multiple emphases can be specified using an array e.g. #(bold italic).
	If emphasis is not specified, #normal will be used.
	if pixel height is not specified , then the editor font size will be used.
	"
	<styleTable: 'Blue'>
								
			"(symbol color [emphasisSymbolOrArray [textStyleName [pixelHeight]]])" 
 ^ #(
			(default 								black)
			(invalid 									red)
			(excessCode 							red)
			
			(comment 								(gray darker))
			(unfinishedComment 					(red muchDarker))
			
			(#'$' 									(red muchDarker))
			(character 								(red muchDarker))
			(integer 								(red muchDarker))
			(number 								(red muchDarker)) 
			(#- 										(red muchDarker))
			(symbol 								(magenta muchDarker)) 
			(stringSymbol 							(magenta muchDarker)) 
			(literalArray 							(magenta muchDarker))
			(string 									(magenta muchDarker) normal)										
			(unfinishedString 						red normal)
	
			(assignment 							nil)
			(ansiAssignment 						nil)
	
			(literal 									nil italic)
			(keyword 								(black))
			(binary 									(black)) 
			(unary 									(black))
										
			(#self 									(cyan muchDarker ))
			(#super 								(cyan muchDarker ))
			(#true 									(red muchDarker))
			(#false 									(red muchDarker))
			(#nil 									(red muchDarker))
			(#thisContext 							(cyan muchDarker ))
			(#return 								(cyan muchDarker ) bold)
			(patternArg 							(blue muchDarker)) 
			(methodArg 							(blue muchDarker))
			(blockPatternArg 						(blue muchDarker))
			(blockArg 								(blue muchDarker))
			(argument 								(blue muchDarker))
			(blockTempVar 						(blue muchDarker))
			(blockPatternTempVar 					(blue muchDarker))
			(instVar 								(blue muchDarker))
			(workspaceVar 							(blue muchDarker))
		
			(tempVar 								(blue muchDarker))
			(patternTempVar 						(blue muchDarker))
			(poolConstant 							(blue muchDarker))
			(classVar 								(blue muchDarker))
			(globalVar 								(blue muchDarker))
												
			(incompleteIdentifier 					blue italic)
			(incompleteKeyword 					nil  italic)
			(incompleteBinary 						nil  italic) 
			(incompleteUnary 						nil  italic)					
				
			(undefinedIdentifier 					red)						
			(undefinedKeyword 					red)
			(undefinedBinary 						red) 
			(undefinedUnary 						red) 
	
			(patternKeyword 						nil bold)
			(patternBinary 							nil bold)
			(patternUnary 							nil bold) 
			(blockArgColon 						black)
			(leftParenthesis 						black)
			(rightParenthesis 						black)
			(leftParenthesis1 						(green muchDarker))
			(rightParenthesis1 						(green muchDarker))
			(leftParenthesis2 						(magenta muchDarker))
			(rightParenthesis2 						(magenta muchDarker))
			(leftParenthesis3 						(red muchDarker))
			(rightParenthesis3 						(red muchDarker))
			(leftParenthesis4 						(green darker))
			(rightParenthesis4 						(green darker))
			(leftParenthesis5 						(orange darker))
			(rightParenthesis5 						(orange darker))
			(leftParenthesis6 						(magenta darker))
			(rightParenthesis6 						(magenta darker))
			(leftParenthesis7 						blue)
			(rightParenthesis7 						blue)
			(blockStart 								black)
			(blockEnd 								black)
			(blockStart1 							(green muchDarker))
			(blockEnd1 								(green muchDarker))
			(blockStart2 							(magenta muchDarker))
			(blockEnd2 								(magenta muchDarker))
			(blockStart3 							(red muchDarker))
			(blockEnd3 								(red muchDarker))
			(blockStart4 							(green darker))
			(blockEnd4 								(green darker))
			(blockStart5 							(orange darker))
			(blockEnd5 								(orange darker))
			(blockStart6 							(magenta darker))
			(blockEnd6 								(magenta darker))
			(blockStart7 							blue)
			(blockEnd7 								blue) 
			(arrayStart 								black)
			(arrayEnd 								black)
			(arrayStart1 							black)
			(arrayEnd1 								black)
			(leftBrace 								black)
			(rightBrace 								black)
			(cascadeSeparator 					black)
			(statementSeparator 					black)
			(methodTempBar 						(black))
			(blockTempBar 						(black))
			(blockArgsBar 							(black))
										
			(externalCallType 						black)
			(externalCallTypePointerIndicator 		black)
			(primitiveOrExternalCallStart 			black bold)
			(primitiveOrExternalCallEnd 			black bold)
			(primitive 								(green muchDarker))
			(pragmaKeyword 						(green muchDarker))
			(pragmaUnary 							(green muchDarker))
			(pragmaBinary 							(green muchDarker)) 
			(externalFunctionCallingConvention 	(green muchDarker) bold)
			(module 								(green muchDarker) bold))
]

{ #category : #styles }
SHRBTextStyler class >> darkStyleTable [
	"color can be a valid argument to Color class>>colorFrom: , or nil to
	use the editor text color.
	Multiple emphases can be specified using an array e.g. #(bold italic).
	If emphasis is not specified, #normal will be used.
	if pixel height is not specified , then the editor font size will be used.
	
	This style is inspired on darkula theme from eclipse: http://eclipsecolorthemes.org/?view=theme&id=15515.  
	"
	<styleTable: 'Dark'>

			"(symbol color [emphasisSymbolOrArray [textStyleName [pixelHeight]]])" 
 ^ #(
			(default 								white)
			(invalid 								'FF8A80')
			(excessCode 							'FF8A80')
			
			(comment 								'7D8C93')
			(unfinishedComment 				'FF8A80')
			
			(#'$' 									('E38C1E' lighter))
			(character 							('E38C1E' lighter))
			(integer 								('FFE54B'))
			(number 								('FFE54B'))
			(#- 									('FFE54B'))
			(symbol 								('E38C1E')) 
			(stringSymbol 						('E38C1E')) 
			(literalArray 						white)
			(string 								('E38C1E'))
												
			(unfinishedString 					'FF8A80' normal)
			(assignment 							nil bold)
			(ansiAssignment 					nil bold)
										
			(literal 								nil italic)
												
			(keyword 								white)
			(binary 								white) 
			(unary 								white)
										
			(#true 								('00CC6E' darker))
			(#false 								('00CC6E' darker))
			(#nil 									('00CC6E' darker))
													
			(#self 								'00CC6E')
			(#super								'00CC6E')
			(#thisContext 						'00CC6E')
			(#return 								'00CC6E' bold)
												
			(patternArg 							'A7E2ED') 
			(methodArg 							'A7E2ED')
			(blockPatternArg 					'A7E2ED' italic)
			(blockArg 							'A7E2ED' italic)
			(argument 							'A7E2ED')
			(blockTempVar 						'A7E2ED')
			(blockPatternTempVar 				'A7E2ED')
								
			(instVar 								'A7E2ED')
			(workspaceVar 						'A7E2ED' bold)
										
			(tempVar 								'A7E2ED')
			(patternTempVar 					'A7E2ED')
										
			(poolConstant 						'A7E2ED' bold)
			(classVar 							'A7E2ED' bold)
			(globalVar 							white bold)
												
		
			(incompleteIdentifier 			'E8E2B7' italic)
			(incompleteKeyword 				'E8E2B7' italic)
			(incompleteBinary 					'E8E2B7' italic) 
			(incompleteUnary 					'E8E2B7' italic)
				
			(undefinedIdentifier 				'FF8A80')						
			(undefinedKeyword 					'FF8A80')
			(undefinedBinary 					'FF8A80') 
			(undefinedUnary 					'FF8A80') 
			
			(patternKeyword 					nil bold)
			(patternBinary 						nil bold)
			(patternUnary 						nil bold) 
			(blockArgColon 						white)
			(leftParenthesis 					white)
			(rightParenthesis 					white)
			(leftParenthesis1 					(green muchLighter))
			(rightParenthesis1 				(green muchLighter))
			(leftParenthesis2 					(magenta muchLighter))
			(rightParenthesis2 				(magenta muchLighter))
			(leftParenthesis3 					('FF8A80' muchLighter))
			(rightParenthesis3 				('FF8A80' muchLighter))
			(leftParenthesis4 					(green lighter))
			(rightParenthesis4 				(green lighter))
			(leftParenthesis5 					(orange lighter))
			(rightParenthesis5 				(orange lighter))
			(leftParenthesis6 					(magenta lighter))
			(rightParenthesis6 				(magenta lighter))
			(leftParenthesis7 					blue)
			(rightParenthesis7 				blue)
			(blockStart 							white)
			(blockEnd 							white)
			(blockStart1 						(green muchLighter))
			(blockEnd1 							(green muchLighter))
			(blockStart2 						(magenta muchLighter))
			(blockEnd2 							(magenta muchLighter))
			(blockStart3 						(red muchLighter))
			(blockEnd3 							(red muchLighter))
			(blockStart4 						(green lighter))
			(blockEnd4 							(green lighter))
			(blockStart5 						(orange lighter))
			(blockEnd5 							(orange lighter))
			(blockStart6 						(magenta lighter))
			(blockEnd6 							(magenta lighter))
			(blockStart7 						blue)
			(blockEnd7 							blue) 
			(arrayStart 							white)
			(arrayEnd 							white)
			(arrayStart1 						white)
			(arrayEnd1 							white)
			(leftBrace 							white)
			(rightBrace 							white)
			(cascadeSeparator 					white bold)
			(statementSeparator 				white bold)
			(methodTempBar 						white)
			(blockTempBar 						white)
			(blockArgsBar 						white)
										
			(externalCallType 								white)
			(externalCallTypePointerIndicator 		white)
			(primitiveOrExternalCallStart 				white bold)
			(primitiveOrExternalCallEnd 				white bold)
			(primitive 										'B4DD6E')
			(pragmaKeyword 									'B4DD6E')
			(pragmaUnary 									'B4DD6E')
			(pragmaBinary 									'B4DD6E') 
			(externalFunctionCallingConvention 		'B4DD6E' bold)
			(module 											'B4DD6E' bold))
]

{ #category : #styles }
SHRBTextStyler class >> defaultStyleTable [
	"color can be a valid argument to Color class>>colorFrom: , or nil to
	use the editor text color.
	Multiple emphases can be specified using an array e.g. #(bold italic).
	If emphasis is not specified, #normal will be used.
	if pixel height is not specified , then the editor font size will be used.
	"
								
 	^ self blueStyleTable
]

{ #category : #styles }
SHRBTextStyler class >> formatIncompleteIdentifiers [

	^ formatIncompleteIdentifiers ifNil: [ formatIncompleteIdentifiers := true ]
]

{ #category : #styles }
SHRBTextStyler class >> formatIncompleteIdentifiers: aValue [

	formatIncompleteIdentifiers := aValue
]

{ #category : #attributes }
SHRBTextStyler class >> initialTextAttributesForPixelHeight: aNumber [ 
	| d |
	d := IdentityDictionary new.
	self styleTable
		do: [:each | 
			| textStyle element emphasis font pixelHeight attrArray color textStyleName |
			element := each first.
			color := each
						at: 2
						ifAbsent: [].
			color := color
						ifNotNil: [Color colorFrom: color].
			emphasis := each
						at: 3
						ifAbsent: [].
			textStyleName := each
						at: 4
						ifAbsent: [].
			pixelHeight := each
						at: 5
						ifAbsent: [aNumber].
			textStyleName
				ifNil: [pixelHeight := nil].
			textStyle := TextStyle named: textStyleName.
			font := textStyle
						ifNotNil: [pixelHeight
								ifNotNil: [textStyle fontOfSize: pixelHeight]].
			attrArray := self
						attributeArrayForColor: color
						emphasis: emphasis
						font: font.
			attrArray notEmpty
				ifTrue: [d at: element put: attrArray]].
	^ d
]

{ #category : #initialization }
SHRBTextStyler class >> initialize [
	styleTable := nil.
	textAttributesByPixelHeight := nil.
]

{ #category : #styles }
SHRBTextStyler class >> settingsOn: aBuilder [ 
	<systemsettings>
	
	(aBuilder setting: #formatIncompleteIdentifiers) 
		target: self;
		default: true;
		order: 1;
		label: 'Format Incomplete Identifiers';
		parentName: #'Syntax Highlighting';
		description: 'If the code highlighter tryies to format incomplete identifiers and selectors or not. This is not recomended for big images, as it traverse all the image to get the information'

]

{ #category : #styles }
SHRBTextStyler class >> solarizedStyleTable [
	"color can be a valid argument to Color class>>colorFrom: , or nil to
	use the editor text color.
	Multiple emphases can be specified using an array e.g. #(bold italic).
	If emphasis is not specified, #normal will be used.
	if pixel height is not specified , then the editor font size will be used.
	
	This style is based on old theme and other old environments.  
	"
	<styleTable: 'Solarized'>
								
			"(symbol color [emphasisSymbolOrArray [textStyleName [pixelHeight]]])" 
 ^ #(
			(default 								('657A81' muchDarker))
			(invalid 									red)
			(excessCode 							red)
			
			(comment 								'586E75')
			(unfinishedComment 					(red muchDarker))
			
			(#'$' 									('268BD2' lighter))
			(character 								('268BD2' lighter))
			(integer 								('2AA198'))
			(number 								('2AA198'))
			(#- 										('2AA198'))
			(symbol 								('268BD2')) 
			(stringSymbol 							('268BD2')) 
			(literalArray 							black)
			(string 									('268BD2'))
												
			(unfinishedString 						red normal)
			(assignment 							nil bold)
			(ansiAssignment 						nil bold)
										
			(literal 									nil italic)
												
			(keyword 								nil)
			(binary 									nil) 
			(unary 									nil)
										
			(#true 									('CB4B16' darker))
			(#false 									('CB4B16' darker))
			(#nil 									('CB4B16' darker))
													
			(#self 									'B58900')
			(#super								'B58900')
			(#thisContext 							'B58900')
			(#return 								'B58900' bold)
												
			(patternArg 							('D33682')) 
			(methodArg 							('D33682'))
			(blockPatternArg 						('D33682'))
			(blockArg 								('D33682'))
			(argument 								('D33682'))
			(blockTempVar 						('D33682'))
			(blockPatternTempVar 					('D33682'))
								
			(instVar 								('D33682'))
			(workspaceVar 							('D33682') bold)
										
			(tempVar 								('D33682'))
			(patternTempVar 						('D33682'))
										
			(poolConstant 							('D33682') bold)
			(classVar 								('D33682') bold)
			(globalVar 								('268BD2' muchDarker) bold)
												
			(undefinedIdentifier 					red)
			(incompleteIdentifier 					'D33682' italic)
			(incompleteKeyword 					nil  italic)
			(incompleteBinary 						nil  italic) 
			(incompleteUnary 						nil  italic)
			(undefinedKeyword 					red)
			(undefinedBinary 						red) 
			(undefinedUnary 						red) 
			(patternKeyword 						'657A81' bold)
			(patternBinary 							'657A81' bold)
			(patternUnary 							'657A81' bold) 
			(blockArgColon 						black)
			(leftParenthesis 						black)
			(rightParenthesis 						black)
			(leftParenthesis1 						(green muchDarker))
			(rightParenthesis1 						(green muchDarker))
			(leftParenthesis2 						(magenta muchDarker))
			(rightParenthesis2 						(magenta muchDarker))
			(leftParenthesis3 						(red muchDarker))
			(rightParenthesis3 						(red muchDarker))
			(leftParenthesis4 						(green darker))
			(rightParenthesis4 						(green darker))
			(leftParenthesis5 						(orange darker))
			(rightParenthesis5 						(orange darker))
			(leftParenthesis6 						(magenta darker))
			(rightParenthesis6 						(magenta darker))
			(leftParenthesis7 						blue)
			(rightParenthesis7 						blue)
			(blockStart 								black)
			(blockEnd 								black)
			(blockStart1 							(green muchDarker))
			(blockEnd1 								(green muchDarker))
			(blockStart2 							(magenta muchDarker))
			(blockEnd2 								(magenta muchDarker))
			(blockStart3 							(red muchDarker))
			(blockEnd3 								(red muchDarker))
			(blockStart4 							(green darker))
			(blockEnd4 								(green darker))
			(blockStart5 							(orange darker))
			(blockEnd5 								(orange darker))
			(blockStart6 							(magenta darker))
			(blockEnd6 								(magenta darker))
			(blockStart7 							blue)
			(blockEnd7 								blue) 
			(arrayStart 								black)
			(arrayEnd 								black)
			(arrayStart1 							black)
			(arrayEnd1 								black)
			(leftBrace 								black)
			(rightBrace 								black)
			(cascadeSeparator 					black bold)
			(statementSeparator 					black bold)
			(methodTempBar 						black)
			(blockTempBar 						black)
			(blockArgsBar 							black)
										
			(externalCallType 						black)
			(externalCallTypePointerIndicator 		black)
			(primitiveOrExternalCallStart 			black bold)
			(primitiveOrExternalCallEnd 			black bold)
			(primitive 								(cyan muchDarker))
			(pragmaKeyword 						(cyan muchDarker))
			(pragmaUnary 							(cyan muchDarker))
			(pragmaBinary 							(cyan muchDarker)) 
			(externalFunctionCallingConvention 	(cyan muchDarker) bold)
			(module 								(cyan muchDarker) bold))
]

{ #category : #accessing }
SHRBTextStyler class >> styleTable [
	^ styleTable
		ifNil: [styleTable := self defaultStyleTable]
]

{ #category : #accessing }
SHRBTextStyler class >> styleTable: anArray [ 
	styleTable := anArray.
	textAttributesByPixelHeight := nil
]

{ #category : #styles }
SHRBTextStyler class >> tangoStyleTable [
	"color can be a valid argument to Color class>>colorFrom: , or nil to
	use the editor text color.
	Multiple emphases can be specified using an array e.g. #(bold italic).
	If emphasis is not specified, #normal will be used.
	if pixel height is not specified , then the editor font size will be used.
	
	This is a syntax coloring scheme based on the tango desktop icon scheme:
	http://tango.freedesktop.org/Tango_Icon_Theme_Guidelines
	"
	<styleTable: 'Tango'>
								
			"(symbol color [emphasisSymbolOrArray [textStyleName [pixelHeight]]])" 
 ^ #(
			(default 								black)
			(invalid 									red)
			(excessCode 							red)
			
			(comment 								'888a85')
			(unfinishedComment 					(red muchDarker))
			
			(#'$' 									'ce5c00')
			(character 								'ce5c00')
			(integer 								'8f5902')
			(number 								'8f5902')
			(#- 										'8f5902')
			(symbol 								'c4a000') 
			(stringSymbol 							'c4a000') 
			(literalArray 							black)
			(string 									'ce5c00')
												
			(unfinishedString 						red normal)
			(assignment 							nil)
			(ansiAssignment 						nil)
										
			(literal 									'8F5902')
												
			(keyword 								(black))
			(binary 									(black)) 
			(unary 									(black))
										
			(#true 									'8F5902')
			(#false 									'8F5902')
			(#nil 									'8F5902')
													
			(#self 									'4d9a06')
			(#super 								'4d9a06')
			(#thisContext 							'4d9a06')
			(#return 								black bold)
												
			(patternArg 							'2e3426' italic) 
			(methodArg 							'555753' italic)
			(blockPatternArg 						'888a85' bold)
			(blockArg 								'555753' italic)
			(argument 								'555753' italic)
			(blockTempVar 						'555753' italic)
			(blockPatternTempVar 					'888a85' italic)
								
			(instVar 								'204a87')
			(workspaceVar 							'204a87')
										
			(tempVar 								'555753' italic)
			(patternTempVar 						'888a85' italic)
										
			(poolConstant 							'ad7fa8' bold)
			(classVar 								'ad7fa8' bold)
			(globalVar 								'5c3566' bold)
												
			
			(incompleteIdentifier 					blue italic)
			(incompleteKeyword 					blue italic)
			(incompleteBinary 						blue italic) 
			(incompleteUnary 						blue italic)
									
			(undefinedIdentifier 					red)						
			(undefinedKeyword 					red)
			(undefinedBinary 						red) 
			(undefinedUnary 						red) 
			(patternKeyword 						nil bold)
			(patternBinary 							nil bold)
			(patternUnary 							nil bold) 
			(blockArgColon 						black)
			(leftParenthesis 						black)
			(rightParenthesis 						black)
			(leftParenthesis1 						(green muchDarker))
			(rightParenthesis1 						(green muchDarker))
			(leftParenthesis2 						(magenta muchDarker))
			(rightParenthesis2 						(magenta muchDarker))
			(leftParenthesis3 						(red muchDarker))
			(rightParenthesis3 						(red muchDarker))
			(leftParenthesis4 						(green darker))
			(rightParenthesis4 						(green darker))
			(leftParenthesis5 						(orange darker))
			(rightParenthesis5 						(orange darker))
			(leftParenthesis6 						(magenta darker))
			(rightParenthesis6 						(magenta darker))
			(leftParenthesis7 						blue)
			(rightParenthesis7 						blue)
			(blockStart 								black)
			(blockEnd 								black)
			(blockStart1 							(green muchDarker))
			(blockEnd1 								(green muchDarker))
			(blockStart2 							(magenta muchDarker))
			(blockEnd2 								(magenta muchDarker))
			(blockStart3 							(red muchDarker))
			(blockEnd3 								(red muchDarker))
			(blockStart4 							(green darker))
			(blockEnd4 								(green darker))
			(blockStart5 							(orange darker))
			(blockEnd5 								(orange darker))
			(blockStart6 							(magenta darker))
			(blockEnd6 								(magenta darker))
			(blockStart7 							blue)
			(blockEnd7 								blue) 
			(arrayStart 								black)
			(arrayEnd 								black)
			(arrayStart1 							black)
			(arrayEnd1 								black)
			(leftBrace 								black)
			(rightBrace 								black)
			(cascadeSeparator 					black)
			(statementSeparator 					black)
			(methodTempBar 						black)
			(blockTempBar 						black)
			(blockArgsBar 							black)
										
			(externalCallType 						black)
			(externalCallTypePointerIndicator 		black)
			(primitiveOrExternalCallStart 			black bold)
			(primitiveOrExternalCallEnd 			black bold)
			(primitive 								(green muchDarker))
			(pragmaKeyword 						(green muchDarker))
			(pragmaUnary 							(green muchDarker))
			(pragmaBinary 							(green muchDarker)) 
			(externalFunctionCallingConvention 	(green muchDarker) bold)
			(module 								(green muchDarker) bold))
]

{ #category : #attributes }
SHRBTextStyler class >> textAttributesByPixelHeight [
	^ textAttributesByPixelHeight
		ifNil: [textAttributesByPixelHeight := Dictionary new]
]

{ #category : #styles }
SHRBTextStyler class >> vintageStyleTable [
	"color can be a valid argument to Color class>>colorFrom: , or nil to
	use the editor text color.
	Multiple emphases can be specified using an array e.g. #(bold italic).
	If emphasis is not specified, #normal will be used.
	if pixel height is not specified , then the editor font size will be used.
	
	This style is based on old theme and other old environments.  
	"
	<styleTable: 'Vintage'>
								
			"(symbol color [emphasisSymbolOrArray [textStyleName [pixelHeight]]])" 
 ^ #(
			(default 								black)
			(invalid 									red)
			(excessCode 							red)
			
			(comment 								'006400')
			(unfinishedComment 					(red muchDarker))
			
			(#'$' 									('801f91' lighter))
			(character 								('801f91' lighter))
			(integer 								('801f91'))
			(number 								('801f91'))
			(#- 										('801f91'))
			(symbol 								('801f91')) 
			(stringSymbol 							('801f91')) 
			(literalArray 							black)
			(string 									('801f91'))
												
			(unfinishedString 						red normal)
			(assignment 							nil bold)
			(ansiAssignment 						nil bold)
										
			(literal 									nil italic)
												
			(keyword 								black)
			(binary 									black) 
			(unary 									black)
										
			(#true 									('A31515' darker))
			(#false 									('A31515' darker))
			(#nil 									('A31515' darker))
													
			(#self 									'A31515')
			(#super								'A31515')
			(#thisContext 							'A31515')
			(#return 								'A31515' bold)
												
			(patternArg 							(blue muchDarker)) 
			(methodArg 							(blue muchDarker))
			(blockPatternArg 						(blue muchDarker))
			(blockArg 								(blue muchDarker))
			(argument 								(blue muchDarker))
			(blockTempVar 						(blue muchDarker))
			(blockPatternTempVar 					(blue muchDarker))
								
			(instVar 								(blue muchDarker))
			(workspaceVar 							(blue muchDarker) bold)
										
			(tempVar 								(blue muchDarker))
			(patternTempVar 						(blue muchDarker))
										
			(poolConstant 							(blue muchDarker) bold)
			(classVar 								(blue muchDarker) bold)
			(globalVar 								black bold)
												
		
			(incompleteIdentifier 					blue italic)
			(incompleteKeyword 					blue italic)
			(incompleteBinary 						blue italic) 
			(incompleteUnary 						blue italic)
				
			(undefinedIdentifier 					red)						
			(undefinedKeyword 					red)
			(undefinedBinary 						red) 
			(undefinedUnary 						red) 
			
			(patternKeyword 						nil bold)
			(patternBinary 							nil bold)
			(patternUnary 							nil bold) 
			(blockArgColon 						black)
			(leftParenthesis 						black)
			(rightParenthesis 						black)
			(leftParenthesis1 						(green muchDarker))
			(rightParenthesis1 						(green muchDarker))
			(leftParenthesis2 						(magenta muchDarker))
			(rightParenthesis2 						(magenta muchDarker))
			(leftParenthesis3 						(red muchDarker))
			(rightParenthesis3 						(red muchDarker))
			(leftParenthesis4 						(green darker))
			(rightParenthesis4 						(green darker))
			(leftParenthesis5 						(orange darker))
			(rightParenthesis5 						(orange darker))
			(leftParenthesis6 						(magenta darker))
			(rightParenthesis6 						(magenta darker))
			(leftParenthesis7 						blue)
			(rightParenthesis7 						blue)
			(blockStart 								black)
			(blockEnd 								black)
			(blockStart1 							(green muchDarker))
			(blockEnd1 								(green muchDarker))
			(blockStart2 							(magenta muchDarker))
			(blockEnd2 								(magenta muchDarker))
			(blockStart3 							(red muchDarker))
			(blockEnd3 								(red muchDarker))
			(blockStart4 							(green darker))
			(blockEnd4 								(green darker))
			(blockStart5 							(orange darker))
			(blockEnd5 								(orange darker))
			(blockStart6 							(magenta darker))
			(blockEnd6 								(magenta darker))
			(blockStart7 							blue)
			(blockEnd7 								blue) 
			(arrayStart 								black)
			(arrayEnd 								black)
			(arrayStart1 							black)
			(arrayEnd1 								black)
			(leftBrace 								black)
			(rightBrace 								black)
			(cascadeSeparator 					black bold)
			(statementSeparator 					black bold)
			(methodTempBar 						black)
			(blockTempBar 						black)
			(blockArgsBar 							black)
										
			(externalCallType 						black)
			(externalCallTypePointerIndicator 		black)
			(primitiveOrExternalCallStart 			black bold)
			(primitiveOrExternalCallEnd 			black bold)
			(primitive 								(cyan muchDarker))
			(pragmaKeyword 						(cyan muchDarker))
			(pragmaUnary 							(cyan muchDarker))
			(pragmaBinary 							(cyan muchDarker)) 
			(externalFunctionCallingConvention 	(cyan muchDarker) bold)
			(module 								(cyan muchDarker) bold))
]

{ #category : #formatting }
SHRBTextStyler >> addAttributes: attributes forNode: anRBNode [
	self 
		addAttributes: attributes
		from: anRBNode start
		to: anRBNode stop
]

{ #category : #formatting }
SHRBTextStyler >> addAttributes: attributes from: start to: stop [
	charAttr
		from: start
		to: stop
		put: attributes
]

{ #category : #converting }
SHRBTextStyler >> addAttributesFrom: attributeRuns satisfying: aTestBlock to: aText [

	attributeRuns withStartStopAndValueDo: [:start :stop :attributes | 
		attributes 
			select: aTestBlock 
			thenDo: [ :selectedAttribute| 
				aText
					addAttribute: selectedAttribute
					from: start
					to: stop ]].
		
	^ aText
]

{ #category : #formatting }
SHRBTextStyler >> addStyle: styleSymbol attribute: additionalAttribute forNode: anRBNode [
	self 
		addStyle:styleSymbol
		attributes: { additionalAttribute }
		forNode: anRBNode.
]

{ #category : #formatting }
SHRBTextStyler >> addStyle: styleSymbol attribute: additionalAttribute from: start to: end [
	self addAttributes: (self attributesFor: styleSymbol), {additionalAttribute} from: start to: end.
]

{ #category : #formatting }
SHRBTextStyler >> addStyle: styleSymbol attributes: additionalAttributes forNode: anRBNode [
	self 
		addAttributes: (self attributesFor: styleSymbol), additionalAttributes 
		forNode: anRBNode.
]

{ #category : #formatting }
SHRBTextStyler >> addStyle: styleSymbol forNode: anRBNode [
	self addAttributes: (self attributesFor: styleSymbol) forNode: anRBNode.
]

{ #category : #formatting }
SHRBTextStyler >> addStyle: styleSymbol from: start to: end [
	self addAttributes: (self attributesFor: styleSymbol) from: start to: end.
]

{ #category : #private }
SHRBTextStyler >> attributesFor: aSymbol [ 
	^ self class attributesFor: aSymbol pixelHeight: self pixelHeight
]

{ #category : #accessing }
SHRBTextStyler >> classOrMetaClass: aBehavior [ 
	classOrMetaClass := aBehavior
]

{ #category : #private }
SHRBTextStyler >> currentClosedBracketStyleName [
	bracketLevel isZero ifTrue: [ ^ #blockEnd ].
	^ (#blockEnd asString , bracketLevel asString) asSymbol
]

{ #category : #private }
SHRBTextStyler >> currentClosedParenthesisStyleName [
	parentheseLevel isZero ifTrue: [ ^ #rightParenthesis ].
	^ (#rightParenthesis asString , parentheseLevel asString) asSymbol
]

{ #category : #private }
SHRBTextStyler >> currentOpenedBracketStyleName [
	bracketLevel isZero ifTrue: [ ^ #blockStart ].
	^ (#blockStart asString , bracketLevel asString) asSymbol
]

{ #category : #private }
SHRBTextStyler >> currentOpenedParenthesisStyleName [
	parentheseLevel isZero ifTrue: [ ^ #leftParenthesis ].
	^ (#leftParenthesis asString , parentheseLevel asString) asSymbol
]

{ #category : #accessing }
SHRBTextStyler >> font: aFont [ 
	font := aFont
]

{ #category : #visiting }
SHRBTextStyler >> formatIncompleteSelector: aMessageNode [
	^ (self class formatIncompleteIdentifiers
		and: [ (Symbol
						selectorThatStartsCaseSensitive: aMessageNode selector asString
						skipping: nil) isNotNil ])
			ifTrue: [ #incompleteKeyword ]
			ifFalse: [ #undefinedKeyword ]
]

{ #category : #accessing }
SHRBTextStyler >> isForWorkspace [
	^ isForWorkspace ifNil: [ workspace notNil ]
]

{ #category : #accessing }
SHRBTextStyler >> isForWorkspace: aBoolean [
	isForWorkspace := aBoolean
]

{ #category : #formatting }
SHRBTextStyler >> literalStyleSymbol: aValue [

	aValue isSymbol
		ifTrue: [ ^ #symbol ].
	aValue isString
		ifTrue: [ ^ #string ].
	aValue isCharacter
		ifTrue: [ ^ #character ].
	aValue isNumber
		ifTrue: [ ^ #number ].
	aValue == true
		ifTrue: [ ^ #true ].
	aValue == false
		ifTrue: [ ^ #false ].
	aValue ifNil: [ ^ #nil ].
	^ #default
]

{ #category : #private }
SHRBTextStyler >> methodOrBlockArgStyleFor: anArgumentNode [
	^ anArgumentNode isDefinedByBlock
		ifTrue: [ anArgumentNode isDefinition 
				ifTrue: [ #blockPatternArg ]
				ifFalse: [ #blockArg ] ]
		ifFalse: [ #methodArg ]
]

{ #category : #private }
SHRBTextStyler >> methodOrBlockTempDeclStyleFor: aSequenceNode [
	^ aSequenceNode scope isBlockScope
		ifTrue: [ #blockPatternTempVar ]
		ifFalse: [ #patternTempVar ]
]

{ #category : #private }
SHRBTextStyler >> methodOrBlockTempStyleFor: aTemporaryNode [
	^ aTemporaryNode isDefinedByBlock
		ifTrue: [ #blockTempVar ]
		ifFalse: [ #tempVar ]
]

{ #category : #private }
SHRBTextStyler >> pixelHeight [
	^ pixelHeight ifNil: [ pixelHeight := (font ifNil: [ TextStyle defaultFont ]) pixelSize ]
]

{ #category : #private }
SHRBTextStyler >> privateStyle: aText [
	| ast |
	aText ifEmpty: [ ^ self ].
	ast := classOrMetaClass compiler
		source: aText asString;
		noPattern: self isForWorkspace ;
		options:  #(+ optionParseErrors + optionSkipSemanticWarnings);
		requestor: workspace;
		parse.				
	^ self style: aText ast: ast
]

{ #category : #private }
SHRBTextStyler >> resolveStyleFor: aVariableNode [
	aVariableNode binding ifNil: [^#default].
	aVariableNode isArgumentVariable ifTrue: [ ^#methodArg].
	aVariableNode isTempVariable ifTrue: [ ^#tempVar].
	aVariableNode isGlobalVariable ifTrue: [ ^#globalVar].
	"here we should add support for #classVar"
	aVariableNode isClassVariable ifTrue: [ ^#globalVar].
	aVariableNode isInstanceVariable ifTrue: [ ^#instVar]. 
	"for now we use temp variable here, we could now color them with their own color"
	aVariableNode isWorkspaceVariable ifTrue: [ ^#tempVar]. 
	
	(self class formatIncompleteIdentifiers and: [ aVariableNode hasIncompleteIdentifier ]) 
		ifTrue:[ ^#incompleteIdentifier] .

	^#invalid.
]

{ #category : #private }
SHRBTextStyler >> resolveTextLinkFor: aVariableNode [

	aVariableNode binding isGlobalVariable
		ifTrue: [ ^ TextClassLink className: aVariableNode name ].	
	^ TextVariableLink variableName: aVariableNode name
]

{ #category : #private }
SHRBTextStyler >> resolveVariableAttributesFor: aVariableNode [
	| textLink global |
	textLink := self resolveTextLinkFor: aVariableNode.
	aVariableNode binding isGlobalVariable ifFalse: [ ^{textLink} ].
	
	global :=	 aVariableNode binding value.
	(global isClass and: [ global isDeprecated ]) ifFalse: [ ^{textLink} ].
	
	^{ textLink. TextEmphasis struckOut }
]

{ #category : #private }
SHRBTextStyler >> style: aText ast: ast [
	aText ifEmpty: [ ^ self ].
	text := aText.	
	charAttr := Array new: aText size withAll: (self attributesFor: #default).
	bracketLevel := 0.
	parentheseLevel:=0.
	self visitNode: ast.
	^aText runs: (RunArray newFrom: charAttr)	

]

{ #category : #private }
SHRBTextStyler >> styleCloseBracket: aBlockNode [
	bracketLevel := bracketLevel - 1.
	(aBlockNode right isZero or: [ aBlockNode value isNil ]) ifTrue:[ ^self ].
	self addStyle: self currentClosedBracketStyleName from: aBlockNode right to: aBlockNode right
]

{ #category : #private }
SHRBTextStyler >> styleCloseParenthese: aMessageNode [
	aMessageNode parentheses
		ifNotEmpty: [ 
			aMessageNode parentheses
				reverseDo: [:interval | 
					| pos |
					pos := interval last.
					parentheseLevel := parentheseLevel - 1.
					self addStyle: self currentClosedParenthesisStyleName from: pos to: pos ]]
]

{ #category : #private }
SHRBTextStyler >> styleOpenBracket: aBlockNode [
	| style |
	style := aBlockNode isFaulty
		ifTrue: [ #invalid ]
		ifFalse: [ self currentOpenedBracketStyleName ].
	self addStyle: style from: aBlockNode left to: aBlockNode left.
	bracketLevel := bracketLevel + 1
]

{ #category : #private }
SHRBTextStyler >> styleOpenParenthese: aMessageNode [
	aMessageNode parentheses
		ifNotEmpty: [ 
			aMessageNode parentheses
				do: [ :interval | 
					| pos |
					pos := interval first.
					self addStyle:  self currentOpenedParenthesisStyleName from: pos to: pos.
					parentheseLevel := parentheseLevel + 1 ]]
]

{ #category : #private }
SHRBTextStyler >> styleTempBars: aSequenceNode [
	| tempBarAttribute |
	tempBarAttribute := aSequenceNode scope isMethodScope
		ifTrue: [ #methodTempBar ]
		ifFalse: [ #blockTempBar ].
	aSequenceNode leftBar
		ifNotNil: [ :pos | self addStyle: tempBarAttribute from: pos to: pos ].
	aSequenceNode rightBar
		ifNotNil: [ :pos | self addStyle: tempBarAttribute from: pos to: pos ]
]

{ #category : #styling }
SHRBTextStyler >> unstyledTextFrom: aText [ 
	"return a Text object without all styling attributes"
	| answer |
	answer := super unstyledTextFrom: aText.
	self 
		addAttributesFrom: aText runs 
		satisfying: [ :each| each isKindOf: TextAction ]
		to: answer.
	^ answer
]

{ #category : #visiting }
SHRBTextStyler >> visitArgumentNode: anArgumentNode [
	| blockOrMethodArgStyle |
	blockOrMethodArgStyle := self methodOrBlockArgStyleFor: anArgumentNode.
	self addStyle: blockOrMethodArgStyle forNode: anArgumentNode
]

{ #category : #visiting }
SHRBTextStyler >> visitAssignmentNode: anAssignmentNode [
	self visitNode: anAssignmentNode variable.
	self visitNode: anAssignmentNode value.
	anAssignmentNode variable binding isWritable
		ifFalse: [ self addStyle: #invalid forNode: anAssignmentNode ]
]

{ #category : #visiting }
SHRBTextStyler >> visitBlockNode: aBlockNode [
	aBlockNode comments
		do:
			[ :comment | self addStyle: #comment from: comment start to: comment stop ].
	aBlockNode arguments do: [ :argument | self visitNode: argument ].
	aBlockNode bar
		ifNotNil: [ :pos | self addStyle: #blockArgsBar from: pos to: pos ].
	aBlockNode colons
		do: [ :pos | self addStyle: #blockArgColon from: pos to: pos ].
	self styleOpenBracket: aBlockNode.
	self visitNode: aBlockNode body.
	self styleCloseBracket: aBlockNode
]

{ #category : #visiting }
SHRBTextStyler >> visitCascadeNode: aCascadeNode [
	aCascadeNode messages do: [ :each | self visitNode: each ].
	aCascadeNode semicolons do: [ :pos | self addStyle: #cascadeSeparator from: pos to: pos ]
]

{ #category : #visiting }
SHRBTextStyler >> visitEnglobingErrorNode: anEnglobingErrorNode [

	self addStyle: #invalid from: anEnglobingErrorNode stop to: anEnglobingErrorNode stop + 1.
	anEnglobingErrorNode content do: [:each | self visitNode: each ]
]

{ #category : #visiting }
SHRBTextStyler >> visitLiteralArrayNode: aRBLiteralArrayNode [
	"In a (valid) byte array all elements are of the same type, style the whole contents
at once, but for ordinary literal arrays, style every node"

	(aRBLiteralArrayNode isForByteArray and: [ 
		aRBLiteralArrayNode isFaulty not and: [ 
			aRBLiteralArrayNode contents isNotEmpty 
		]
	]) ifTrue: [ 
			self addStyle: #number 
				from: aRBLiteralArrayNode start + 2 
				to: aRBLiteralArrayNode stop - 1 ]
		ifFalse: [ aRBLiteralArrayNode contents do: [ :each | self visitNode: each ]]
]

{ #category : #visiting }
SHRBTextStyler >> visitLiteralValueNode: aLiteralValueNode [
	| value link |
	value := aLiteralValueNode value.
	
	
	"We can have 3 different kind of links from a literal: 
	- In case it is a symbol representing a class, we want to return a TextClassLink to browse the class or its references
	- In case it is another symbol, we want to return a TextMethodLink to browser the implementors or senders of this selector
	- In case it is another literal value, we return a TextClassLink to browse the class defining this litera."
	link := value isSymbol
		ifTrue: [
			self class environment
				at: value
				ifPresent: [ :aGlobal | TextClassLink className: value ]
				ifAbsent: [ TextMethodLink selector: value ] ]
		ifFalse: [ TextClassLink class: value class ].
	self addStyle: (self literalStyleSymbol: value) attribute: link forNode: aLiteralValueNode
]

{ #category : #visiting }
SHRBTextStyler >> visitMessageNode: aMessageNode [
	| style link |
	style := #keyword.
	
	(Symbol findInternedSelector: aMessageNode selector asString)
		ifNil:[ style := self formatIncompleteSelector: aMessageNode ].
		
	link := TextMethodLink sourceNode: aMessageNode.
	self styleOpenParenthese: aMessageNode.
	
	aMessageNode selectorParts
		with: aMessageNode keywordsPositions
		do: [ :keyword :position | 
			self
				addStyle: style
				attribute: link
				from: position
				to: position + keyword size - 1 ].
	
	(aMessageNode isCascaded not or: [ aMessageNode isFirstCascaded ])
		ifTrue: [ self visitNode: aMessageNode receiver ].
	
	aMessageNode arguments do: [ :each | self visitNode: each ].
	self styleCloseParenthese: aMessageNode
]

{ #category : #visiting }
SHRBTextStyler >> visitMethodNode: aMethodNode [
	| link |
	self visitMethodComments: aMethodNode comments.
	aMethodNode arguments do: [ :argument | self addStyle: #patternArg forNode: argument ].
	link := TextMethodLink selector: aMethodNode selector.
	aMethodNode selectorParts
		with: aMethodNode keywordsPositions
		do:
			[ :keyword :position | 
			self
				addStyle: #patternKeyword
				attribute: link
				from: position
				to: position + keyword size - 1 ].
	aMethodNode pragmas do: [ :each | self visitNode: each ].
	self visitNode: aMethodNode body
]

{ #category : #visiting }
SHRBTextStyler >> visitNode: aNode [ 
	aNode comments do: [:comment|
		self 
			addStyle: #comment
			from: comment start
			to: comment stop ].

	^aNode acceptVisitor: self
]

{ #category : #visiting }
SHRBTextStyler >> visitParseErrorNode: anErrorNode [
	self 
		addStyle: #invalid
		forNode: anErrorNode
]

{ #category : #visiting }
SHRBTextStyler >> visitPragmaNode: aPragmaNode [
	aPragmaNode selectorParts with: aPragmaNode keywordsPositions do: [ :keyword : position|
	self 
		addStyle: #pragmaKeyword
		from: position
		to: position + keyword size ].
	
	aPragmaNode arguments do: [ :each | self visitNode: each ]
]

{ #category : #visiting }
SHRBTextStyler >> visitReturnNode: aReturnNode [ 
	self 
		addStyle: #return
		from: aReturnNode start
		to: aReturnNode stop.
		
	self visitNode: aReturnNode value
]

{ #category : #visiting }
SHRBTextStyler >> visitSelfNode: aSelfNode [
	self 
		addStyle: #self
		forNode: aSelfNode
]

{ #category : #visiting }
SHRBTextStyler >> visitSequenceNode: aSequenceNode [
	self styleTempBars: aSequenceNode.
	aSequenceNode temporaries do: [ :each | self visitNode: each ].
	aSequenceNode statements do: [ :each | self visitNode: each ].
	aSequenceNode periods
		do: [ :pos | self addStyle: #statementSeparator from: pos to: pos ]
]

{ #category : #visiting }
SHRBTextStyler >> visitSuperNode: aSuperNode [
	self addStyle: #super forNode: aSuperNode
]

{ #category : #visiting }
SHRBTextStyler >> visitTemporaryDeclarationNode: aTemporaryDeclarationNode [
	| patternTempStyle |
	patternTempStyle := self
		methodOrBlockTempDeclStyleFor: aTemporaryDeclarationNode parent.
	self addStyle: patternTempStyle forNode: aTemporaryDeclarationNode
]

{ #category : #visiting }
SHRBTextStyler >> visitTemporaryNode: aTemporaryNode [
	| methodOrBlockTempStyle |
	methodOrBlockTempStyle := self methodOrBlockTempStyleFor: aTemporaryNode.
	self addStyle: methodOrBlockTempStyle forNode: aTemporaryNode
]

{ #category : #visiting }
SHRBTextStyler >> visitThisContextNode: aThisContextNode [
	self addStyle: #thisContext forNode: aThisContextNode
]

{ #category : #visiting }
SHRBTextStyler >> visitVariableNode: aVariableNode [
	self 
		addStyle: (self resolveStyleFor: aVariableNode) 
		attributes: (self resolveVariableAttributesFor: aVariableNode)
		forNode: aVariableNode
]

{ #category : #accessing }
SHRBTextStyler >> workspace: aWorkspace [ 
	workspace := aWorkspace.
	isForWorkspace ifNil: [ isForWorkspace := true ]
]
