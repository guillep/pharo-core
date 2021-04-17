Class {
	#name : #SHRBTextStylerTest,
	#superclass : #TestCase,
	#instVars : [
		'styler',
		'oldSetting'
	],
	#category : #'Shout-Tests-Styling'
}

{ #category : #running }
SHRBTextStylerTest >> setUp [

	super setUp.
	styler := SHRBTextStyler new.
	oldSetting := SHRBTextStyler instVarNamed: #formatIncompleteIdentifiers.
]

{ #category : #'private - utilities' }
SHRBTextStylerTest >> style: aText [

	| ast |
	
	ast := self class compiler
		source: aText asString;
		noPattern: false ;
		options:  #(+ optionParseErrors + optionSkipSemanticWarnings);
		requestor: nil;
		parse.				
	styler style: aText ast: ast.
	
	^ ast
]

{ #category : #'private - utilities' }
SHRBTextStylerTest >> styleExpression: aText [

	| ast |
	
	ast := self class compiler
		source: aText asString;
		noPattern: true ;
		options:  #(+ optionParseErrors + optionSkipSemanticWarnings);
		requestor: nil;
		parse.				
	styler style: aText ast: ast.
	
	^ ast
]

{ #category : #running }
SHRBTextStylerTest >> tearDown [ 

	SHRBTextStyler formatIncompleteIdentifiers: oldSetting.
	super tearDown.
	
]

{ #category : #tests }
SHRBTextStylerTest >> testArgumentStylingBlock [
	
	| aText index1 index2 attribute |

	aText := 'm1 self do: [:each | each ]' asText.
	self style: aText.
	
	index1 := 15. "fixrst each"
	attribute := aText attributesAt: index1.
	self assert: attribute equals: (SHRBTextStyler  attributesFor: #blockPatternArg pixelHeight: 10).
	
	index2 := 22. "second each"
	attribute := aText attributesAt: index2.
	self assert: attribute equals: (SHRBTextStyler  attributesFor: #blockArg pixelHeight: 10)
]

{ #category : #tests }
SHRBTextStylerTest >> testArgumentStylingExpressionWithComment [
	
	| aText index1 index2 attribute |

	aText := '"comment"3+4.' asText.
	self styleExpression: aText.
	
	index1 := 5. "inside comment"
	attribute := aText attributesAt: index1.
	self assert: attribute equals: (SHRBTextStyler  attributesFor: #comment pixelHeight: 10).
	
	index2 := 11. "outside the +"
	attribute := (aText attributesAt: index2) first.
	self assert: attribute equals: (SHRBTextStyler  attributesFor: #unary pixelHeight: 10) first
]

{ #category : #tests }
SHRBTextStylerTest >> testArgumentStylingExpressionWithComment2 [
	
	| aText index1 index2 attribute |

	aText := '"comment"3.' asText.
	self styleExpression: aText.
	
	index1 := 5. "inside comment"
	attribute := aText attributesAt: index1.
	self assert: attribute equals: (SHRBTextStyler  attributesFor: #comment pixelHeight: 10).
	
	index2 := 10. "outside the 3"
	attribute := (aText attributesAt: index2) first.
	self assert: attribute equals: (SHRBTextStyler  attributesFor: #integer pixelHeight: 10) first
]

{ #category : #tests }
SHRBTextStylerTest >> testArgumentStylingMethod [
	
	| aText index1 index2 attribute |

	aText := 'm1: arg self do: [:each | arg ]' asText.
	self style: aText.
	
	index1 := 5. "first each"
	attribute := aText attributesAt: index1.
	self assert: attribute equals: (SHRBTextStyler  attributesFor: #methodArg pixelHeight: 10).
	
	index2 := 27. "second each"
	attribute := aText attributesAt: index2.
	self assert: attribute equals: (SHRBTextStyler  attributesFor: #tempVar pixelHeight: 10)
]

{ #category : #tests }
SHRBTextStylerTest >> testClassAfterMessageToASymbolLowercaseShouldBeColored [
	
	| aText index attributes |

	SHRBTextStyler formatIncompleteIdentifiers: true.

	aText := 'm1
		#world traceCr.
		Object new.' asText.

	index := aText string indexOfSubCollection: 'Object'.
	
	self style: aText.
	
	attributes := aText attributesAt: index.

	self assertCollection: attributes hasSameElements: { 
		TextClassLink className: #Object. 
		TextColor color: SHPreferences globalVarStyle color }
]

{ #category : #tests }
SHRBTextStylerTest >> testClassAfterMessageToASymbolUppercaseShouldBeColored [
	
	| aText index attributes |

	SHRBTextStyler formatIncompleteIdentifiers: true.

	aText := 'm1
		#World traceCr.
		Object new.' asText.

	index := aText string indexOfSubCollection: 'Object'.
	
	self style: aText.
	
	attributes := aText attributesAt: index.

	self assertCollection: attributes hasSameElements: { 
		TextClassLink className: #Object. 
		TextColor color: SHPreferences globalVarStyle color}
]

{ #category : #tests }
SHRBTextStylerTest >> testSettingFalseTheIncompleteIdentifiersShouldNotFormatIt [
	
	| aText index attributes |

	SHRBTextStyler formatIncompleteIdentifiers: false.

	aText := 'm1
		^ se' asText.

	index := aText string indexOfSubCollection: 'se'.
	
	self style: aText.
	
	attributes := aText attributesAt: index.
	
	self assertCollection: attributes hasSameElements: { TextColor red. TextVariableLink variableName: 'se' }
]

{ #category : #tests }
SHRBTextStylerTest >> testSettingFalseTheIncompleteMessageShouldNotFormatIt [
	
	| aText index attributes ast node |

	SHRBTextStyler formatIncompleteIdentifiers: false.

	aText := 'm1
		^ self prin' asText.

	index := aText string indexOfSubCollection: 'prin'.
	
	ast := self style: aText.
	
	attributes := aText attributesAt: index.

	node := ast allChildren detect: [:e | e isMessage ].
	
	self assertCollection: attributes hasSameElements: { 
		TextMethodLink sourceNode: node. 
		TextColor red }.
]

{ #category : #tests }
SHRBTextStylerTest >> testSettingTrueTheIncompleteIdentifiersShouldFormatIt [
	
	| aText index attributes |

	SHRBTextStyler formatIncompleteIdentifiers: true.

	aText := 'm1
		^ se' asText.

	index := aText string indexOfSubCollection: 'se'.
	
	self style: aText.
	
	attributes := aText attributesAt: index.
	
	self assertCollection: attributes hasSameElements: { TextColor blue. TextEmphasis italic. TextVariableLink variableName: 'se' }
]

{ #category : #tests }
SHRBTextStylerTest >> testSettingTrueTheIncompleteMessageShouldFormatIt [
	
	| aText index attributes ast node |

	SHRBTextStyler formatIncompleteIdentifiers: true.

	aText := 'm1
		^ self prin' asText.

	index := aText string indexOfSubCollection: 'prin'.
	
	ast := self style: aText.
	
	attributes := aText attributesAt: index.

	node := ast allChildren detect: [:e | e isMessage ].
	
	self assertCollection: attributes hasSameElements: { 
		TextMethodLink sourceNode: node. 
		TextEmphasis italic }.
]
