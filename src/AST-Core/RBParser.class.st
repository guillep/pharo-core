"
RBParser takes a source code string and generates an AST for it. This is a hand-written, recursive descent parser and has been optimized for speed. The simplest way to call this is either 'RBParser parseExpression: aString' if you want the AST for an expression, or 'RBParser parseMethod: aString' if you want to parse an entire method.

Instance Variables:
	currentToken	<RBToken>	The current token being processed.
	emptyStatements	<Boolean>	True if empty statements are allowed. In IBM, they are, in VW they aren't.
	errorBlock	<BlockClosure>	The block to evaluate on a syntax error.
	nextToken	<RBToken>	The next token that will be processed. This allows one-token lookahead.
	scanner	<RBScanner>	The scanner that generates a stream of tokens to parse.
	source	<String>	The source code to parse
	tags	<Collection of: Interval>	The source intervals of the tags appearing at the top of a method (e.g. Primitive calls)

Shared Variables:
	ParserType	<Symbol>	the type code we are parsing
"
Class {
	#name : #RBParser,
	#superclass : #Object,
	#instVars : [
		'scanner',
		'currentToken',
		'nextToken',
		'errorBlock',
		'source',
		'comments',
		'pragmas'
	],
	#category : #'AST-Core-Parser'
}

{ #category : #accessing }
RBParser class >> errorNodeBlock [
	^ [ :aString :position :parser| parser parseErrorNode: aString ]
]

{ #category : #'instance creation' }
RBParser class >> newFaulty [
	
	^ self newWithErrorBlock: self errorNodeBlock
]

{ #category : #'instance creation' }
RBParser class >> newWithErrorBlock: aBlock [
	
	^ self new
		errorBlock: aBlock;
		yourself
]

{ #category : #parsing }
RBParser class >> parseExpression: aString [ 
	^self parseExpression: aString onError: nil
]

{ #category : #parsing }
RBParser class >> parseExpression: aString onError: aBlock [
	| node |
	node := self new
		        errorBlock: aBlock;
		        initializeParserWith: aString;
		        parseExpression: aString.
	^ (node statements size == 1 and: [ node temporaries isEmpty ])
		  ifTrue: [ node statements first ]
		  ifFalse: [ node ]
]

{ #category : #parsing }
RBParser class >> parseFaultyExpression: aString [ 
	"parse aString even if syntactically incorrect. Instead of raising an error, we create an AST with RB RBParseErrorNode"
	^self parseExpression: aString onError: self errorNodeBlock
]

{ #category : #parsing }
RBParser class >> parseFaultyMethod: aString [
	"parse aString even if syntactically incorrect. Instead of raising an error, we create an AST with RB RBParseErrorNode"

	^ self parseMethod: aString onError: self errorNodeBlock
]

{ #category : #parsing }
RBParser class >> parseLiterals: aString [
	^ self new
		  initializeParserWith: aString;
		  parseLiterals: aString
]

{ #category : #parsing }
RBParser class >> parseMethod: aString [ 
	^self parseMethod: aString onError: nil
]

{ #category : #parsing }
RBParser class >> parseMethod: aString onError: aBlock [ 
	| parser |
	parser := self new
		errorBlock: aBlock;
		initializeParserWith: aString.
	^ [ parser parseMethod: aString ]
		on: ReparseAfterSourceEditing
		do: [ :exception | self parseMethod: exception newSource onError: aBlock ]
]

{ #category : #parsing }
RBParser class >> parseMethodPattern: aString [
	^ (self new
		   errorBlock: [ :error :position | ^ nil ];
		   initializeParserWith: aString;
		   parseMessagePattern) selector
]

{ #category : #parsing }
RBParser class >> parsePragma: aString [
	^ self new
		  initializeParserWith: aString;
		  parsePragmaAndReturn
]

{ #category : #parsing }
RBParser class >> parseRewriteExpression: aString [ 
	^self parseRewriteExpression: aString onError: nil
]

{ #category : #parsing }
RBParser class >> parseRewriteExpression: aString onError: aBlock [ 
	^RBPatternParser parseExpression: aString onError: aBlock
]

{ #category : #parsing }
RBParser class >> parseRewriteMethod: aString [ 
	^self parseRewriteMethod: aString onError: nil
]

{ #category : #parsing }
RBParser class >> parseRewriteMethod: aString onError: aBlock [ 
	^RBPatternParser parseMethod: aString onError: aBlock
]

{ #category : #private }
RBParser >> addCommentsTo: aNode [
	aNode comments: aNode comments , comments.
	comments do: [ :each | each parent: aNode ].
	comments := OrderedCollection new
]

{ #category : #'private-parsing' }
RBParser >> addParserError: errorMessage to: aNode [
	| errorNode |
	errorNode := self parserError: errorMessage.
	aNode addFaultyNode: errorNode.
	^ aNode
]

{ #category : #private }
RBParser >> addPragma: aPragma [
	pragmas ifNil: [ pragmas := OrderedCollection new ].
	pragmas addLast: aPragma
]

{ #category : #'private-classes' }
RBParser >> arrayNodeClass [
	^ RBArrayNode
]

{ #category : #'private-classes' }
RBParser >> assignmentNodeClass [
	^ RBAssignmentNode
]

{ #category : #testing }
RBParser >> atEnd [
	^currentToken isEOF
]

{ #category : #'private-parsing' }
RBParser >> basicParsePragma [
	"Current token must be Identifier, Keyword or Binary. Else it throws an error."
	^ currentToken isIdentifier
		ifTrue: [ self parseUnaryPragma ]
		ifFalse: [
			currentToken isKeyword
				ifTrue: [ 	
					currentToken isPrimitiveKeyword
						ifTrue: [ ^ self parsePrimitiveKeywordPragma ].
					self parseKeywordPragma ]
				ifFalse: [ self parseBinaryPragma ] ]
]

{ #category : #'private-classes' }
RBParser >> blockNodeClass [
	^ RBBlockNode
]

{ #category : #'private-classes' }
RBParser >> cascadeNodeClass [
	^ RBCascadeNode
]

{ #category : #accessing }
RBParser >> currentToken [
	^currentToken 
]

{ #category : #'private-classes' }
RBParser >> englobingErrorNodeClass [ 
	^RBEnglobingErrorNode
]

{ #category : #'error handling' }
RBParser >> errorBlock [
	^errorBlock ifNil: [[:message :position | ]] ifNotNil: [errorBlock]
]

{ #category : #accessing }
RBParser >> errorBlock: aBlock [ 
	errorBlock := aBlock.
	scanner notNil ifTrue: [scanner errorBlock: aBlock]
]

{ #category : #'error handling' }
RBParser >> errorPosition [
	^currentToken ifNotNil: [ :token | token start] ifNil:[1]
]

{ #category : #private }
RBParser >> extractCommentsFrom: aToken [
 
	aToken comments 
		collect: [:commentToken | RBComment with: commentToken ]
		into: comments
]

{ #category : #'error handling' }
RBParser >> getErrorFromClosuresWithMissingOpenings: aCollection [
	^((currentToken isSpecial and: ['])}' includes: currentToken value])
				" We make a distinction between the bracket and the other closures because blocks are the only ones that can contain multiple statements. "
				ifTrue: [ currentToken value = $) 
					ifFalse: [ | errorNode | 
								  errorNode := self parseEnglobingError: aCollection copy with: currentToken errorMessage: (currentToken value = $] ifTrue: [ '''['' expected' ]ifFalse: [ '''{'' expected' ]).  
								  aCollection removeAll. errorNode ]
					ifTrue: [  aCollection isEmpty 
							ifFalse: [| errorNode | errorNode := self parseEnglobingError: (OrderedCollection with: aCollection last) with: currentToken errorMessage: ''')'' expected'.  aCollection removeLast. errorNode] 
							ifTrue: [ self parseEnglobingError: aCollection copy with: currentToken errorMessage: ''')'' expected'] ] ] 			
				ifFalse: [ self parserError: 'Unknown input at end' ]).
]

{ #category : #initialization }
RBParser >> initialize [
	comments := OrderedCollection new
]

{ #category : #accessing }
RBParser >> initializeParserWith: aString [ 
	source := aString.
	self scanner: (self scannerClass on: (ReadStream on: aString) errorBlock: self errorBlock)		
]

{ #category : #'private-classes' }
RBParser >> literalArrayNodeClass [
	^ RBLiteralArrayNode
]

{ #category : #'private-classes' }
RBParser >> literalNodeClass [
	^ RBLiteralNode
]

{ #category : #'private-classes' }
RBParser >> literalValueNodeClass [
	^ RBLiteralValueNode
]

{ #category : #'private-classes' }
RBParser >> messageNodeClass [
	^ RBMessageNode
]

{ #category : #'private-classes' }
RBParser >> methodNodeClass [
	^ RBMethodNode
]

{ #category : #private }
RBParser >> nextToken [
	^nextToken ifNil: [nextToken := self scannerNext] ifNotNil: [nextToken]
]

{ #category : #'private-parsing' }
RBParser >> parseArgs [
	"Return a collection of variable node."
	| args |
	args := OrderedCollection new.
	[currentToken isIdentifier] whileTrue: [args add: self parseVariableNode].
	^args
]

{ #category : #'private-parsing' }
RBParser >> parseArray [
	"Although an array node represents an array, it is not an Array-like object."
	| startToken node |
	startToken := currentToken.
	self step.
	node := self arrayNodeClass new.
	node left: startToken start.
	self parseStatementList: false  into: node untilAnyCloserOf: '}'.
	(currentToken isSpecial and: [currentToken value = $}]) 
		ifFalse: [ ^ self parseEnglobingError: node statements with: startToken errorMessage: 'expected }'].
	node right: currentToken start.
	self step.
	^ node
]

{ #category : #'private-parsing' }
RBParser >> parseAssignment [
	"Need one token lookahead to see if we have a ':='. This method could 
	make it possible to assign the literals true, false and nil."

	| node position |
	(currentToken isIdentifier and: [self nextToken isAssignment]) 
		ifFalse: [^self parseCascadeMessage].
	node := self parseVariableNode.
	position := currentToken start.
	self step.
	^self assignmentNodeClass 
		variable: node
		value: self parseAssignment
		position: position
]

{ #category : #'private-parsing' }
RBParser >> parseBinaryMessage [
	| node |
	node := self parseUnaryMessage.
	
	[currentToken isLiteralToken ifTrue: [self patchNegativeLiteral].
	currentToken isBinary] 
			whileTrue: [node := self parseBinaryMessageWith: node].
	^node
]

{ #category : #'private-parsing' }
RBParser >> parseBinaryMessageWith: aNode [ 
	| binaryNode |
	binaryNode := self selectorNodeClass
		value: currentToken value
		keywordPositions: (Array with: currentToken start).
	self step.
	^self messageNodeClass 
		receiver: aNode
		selector:  binaryNode
		keywordsPositions: binaryNode keywordPositions
		arguments: (Array with: self parseUnaryMessage)
]

{ #category : #'private-parsing' }
RBParser >> parseBinaryPattern [
	| binaryToken node args |
	currentToken isBinary
		ifFalse: [ 
		^ self methodNodeClass 
			selector: #faulty
			arguments: #()
			body: (self sequenceNodeClass statements: (OrderedCollection with: (self parserError: 'Message pattern expected')))].
	
	binaryToken := currentToken.
	self step.
	args := Array with: self parseVariableNode.
	node := self methodNodeClass
		selector: binaryToken value asSymbol
		keywordsPositions: (Array with: binaryToken start)
		arguments: args.
	node comments: node comments , args last comments.
	args last comments ifNotEmpty: [ args last comments: #() ].
	^node
]

{ #category : #'private-parsing' }
RBParser >> parseBinaryPragma [
	| binaryToken |
	currentToken isBinary 
		ifFalse: [ ^ self parserError: 'Message pattern expected' ].
	binaryToken := currentToken.
	self step.
	^ self pragmaNodeClass
		selector: binaryToken value asSymbol
		keywordsPositions: (Array with: binaryToken start)
		arguments: (Array with: self parsePragmaLiteral)
]

{ #category : #'private-parsing' }
RBParser >> parseBlock [
	| startToken node |
	startToken := currentToken.
	self step.
	node := self blockNodeClass new. 
	self parseBlockArgsInto: node.
	self addCommentsTo: node.		
	node left: startToken start.
	node body: self sequenceNodeClass new.
	
	self
		parseStatements: false
		into: node body
		untilAnyCloserOf: ']'.
	
	(currentToken isSpecial and: [currentToken value = $]])
		ifFalse: [ ^ self parseEnglobingError: node body statements with: startToken errorMessage: ''']'' expected'].
	node right: currentToken start.
	self step.
	^node
]

{ #category : #'private-parsing' }
RBParser >> parseBlockArgsInto: node [ 
	| verticalBar args colons |
	args := OrderedCollection new: 2.
	colons := OrderedCollection new: 2.
	verticalBar := false.
	[currentToken isSpecial and: [currentToken value = $:]] whileTrue: 
			[colons add: currentToken start.
			self step.	":"
			verticalBar := true.
			args add: self parseVariableNode].
	verticalBar 
		ifTrue: 
			[currentToken isBinary 
				ifTrue: 
					[node bar: currentToken start.
					currentToken value = #| 
						ifTrue: [self step]
						ifFalse: 
							[currentToken value = #'||' 
								ifTrue: 
									["Hack the current token to be the start 
									of temps bar"

									currentToken
										value: #|;
										start: currentToken start + 1]
								ifFalse: [ args add:(self parserError: '''|'' expected')]]]
				ifFalse: 
					[(currentToken isSpecial and: [currentToken value = $]]) 
						ifFalse: [ args add:(self parserError: '''|'' expected')]]].
	node
		arguments: args;
		colons: colons.
	^node
]

{ #category : #'private-parsing' }
RBParser >> parseCascadeMessage [
	| node receiver messages semicolons |
	"Parse of the first message. It can be either unary, binary or keyword."
	node := self parseKeywordMessage.

	"Quick check if this matches a cascade. If not, return the already parsed node"
	(currentToken isSpecial and: [ currentToken value = $; ])
		ifFalse: [ ^ node ].

	"At this point we know we should create a cascade node."
	messages := OrderedCollection new: 3.
	semicolons := OrderedCollection new: 3.
	
	"Handle invalid cascade sequences such as:
	
	(self foo); bar
	7; message
	
	In this case, the cascade receiver should be an invalid cascade node.
	"
	(node isMessage not or: [ node hasParentheses ]) ifTrue: [ 
		"Cut parsing with an error.
		If in faulty mode, continue the execution and generate a faulty cascade node."
		self parserError: 'cascaded message not allowed'.
		receiver := node := RBInvalidCascadeErrorNode
			content: { node }
			start: node start
			stop: currentToken stop
			errorMessage: 'End of statement expected'.
	] ifFalse: [ 
		receiver := node receiver.
	 	messages add: node.
	].

	"Extract the messages following the cascade marker $;"
	[currentToken isSpecial and: [currentToken value = $;]] whileTrue: [
		|newMessage|
		semicolons add: currentToken start.
		newMessage := nil.
		self step.
		self saveCommentsDuring: [
			newMessage := self parseCascadeMessageWithReceiver: receiver ].
		self addCommentsTo: newMessage.
		messages add: newMessage ].

	^self cascadeNodeClass messages: messages semicolons: semicolons
]

{ #category : #'private-parsing' }
RBParser >> parseCascadeMessageWithReceiver: receiver [
	
	| errorNode |
	currentToken isIdentifier 
		ifTrue: [ ^ self parseUnaryMessageWith: receiver].
		
	currentToken isKeyword 
		ifTrue: [ ^ self parseKeywordMessageWith: receiver].

	currentToken isLiteralToken ifTrue: [ self patchNegativeLiteral ].
	"Upon encountering an error in the cascade, it stores an error node as it would store a message node and continues the parsing of the cascade.
	This can allow the possibility of fixing the cascade simply by replacing the false node by another."
	currentToken isBinary ifTrue: [ 
		^ self parseBinaryMessageWith: receiver ].
	
	"At this point we know this is an invalid cascade.
	Many things can happen next: it could be a closer parenthesis or bracket, the end of the stream, a non-identifier or an empty cascade.
	For now, if it is a closer return an empty error node.
	If it is not a closer, consume it"
	errorNode := self parserError: 'Cascade message expected'.
	(currentToken value ~= $.
		and: [ ('])};' includes: currentToken value) not
			and: [ currentToken isEOF not ] ] )
				ifTrue: [ self step ].
	^ errorNode
]

{ #category : #'private-classes' }
RBParser >> parseEnglobingError: aCollection with: aToken errorMessage: anErrorMessage [
	| firstParse |
	firstParse := self parserError: anErrorMessage.
	^[firstParse isParseError
		ifTrue: [ (self englobingErrorNodeClass error: aToken withNodes: aCollection) value: aToken value asString ]
		ifFalse: [ firstParse ]] on: Error do: [ firstParse ].
]

{ #category : #'error handling' }
RBParser >> parseErrorNode: aMessageString [
	| errorPosition|
	currentToken isError
		ifTrue: [ | errorNode| 
				    errorNode := RBParseErrorNode errorMessage: currentToken cause value: currentToken value at: currentToken start.
					 self step.
					 ^errorNode].
	errorPosition := self errorPosition.
	(errorPosition = 0) ifTrue: [ errorPosition := self errorPosition].
	^ RBParseErrorNode errorMessage: aMessageString value: currentToken value asString at: errorPosition
]

{ #category : #accessing }
RBParser >> parseExpression: anExpressionString [
	"Parse and return an AST corresponding to the expression passed as argument."
	
	| node |
	node := self parseStatements: false.
	(self methodNodeClass selector: #noMethod body: node) source: anExpressionString.	"Make the sequence node have a method node as its parent"
	self atEnd ifFalse: [ ^ self parseIncompleteExpression: node ].
	(node statements isEmpty and: [currentToken comments notNil]) 
			ifTrue: [self extractCommentsFrom: currentToken. self addCommentsTo: node.].
	^node
]

{ #category : #'private-parsing' }
RBParser >> parseIncompleteExpression: priorStatementsNode [
	" This method is used when parsing an expression or a method, if the parsing of the list of statements finishes but there are some tokens left to parse."
	 | statements error |
	statements := priorStatementsNode statements copy.
	" Checks if the current token is a closure to create an englobing error node or a parse error node otherwise. "
	error := self getErrorFromClosuresWithMissingOpenings: statements.
	error parent: priorStatementsNode.
	statements add: error.
	self step.
	priorStatementsNode statements: statements.
	^self atEnd ifTrue: [ priorStatementsNode ] 
				  ifFalse: [ self parseStatementList: false into: priorStatementsNode until: [ false "No extra condition, just until the end of the stream" ].
								self atEnd ifFalse: [ self parseIncompleteExpression: priorStatementsNode ]
											  ifTrue: [ priorStatementsNode ] ]
]

{ #category : #'private-parsing' }
RBParser >> parseKeywordMessage [
	^self parseKeywordMessageWith: self parseBinaryMessage
]

{ #category : #'private-parsing' }
RBParser >> parseKeywordMessageWith: node [ 
	| args isKeyword keywordsStartPositions selector|
	args := OrderedCollection new: 3.
	keywordsStartPositions := OrderedCollection new: 3.
	selector := self selectorNodeClass value: ''.
	
	isKeyword := false.
	[currentToken isKeyword] whileTrue: 
			[keywordsStartPositions add: currentToken start.
			selector value: selector value, currentToken value.
			self step.
			args add: self parseBinaryMessage.
			isKeyword := true].
	selector keywordPositions: keywordsStartPositions.
	^isKeyword
		ifTrue: 
			[self messageNodeClass 
				receiver: node
				selector: selector
				keywordsPositions: keywordsStartPositions
				arguments: args]
		ifFalse: [node]
]

{ #category : #'private-parsing' }
RBParser >> parseKeywordPattern [
	| selector positions args node |
	selector := ''.
	positions := OrderedCollection new: 2.
	args := OrderedCollection new: 2.
	[currentToken isKeyword]
		whileTrue:
			[selector := selector, currentToken value.
			 positions add: currentToken start.
			self step.
			args add: self parseVariableNode].
	node := self methodNodeClass
		selector: selector asSymbol
		keywordsPositions: positions asIntegerArray
		arguments: args.
	node comments: (node comments, args last comments).
	args last comments ifNotEmpty: [ args last comments: #() ].
	^node
]

{ #category : #'private-parsing' }
RBParser >> parseKeywordPragma [
	| selector positions arguments |
	selector := ''.
	positions := OrderedCollection new: 2.
	arguments := OrderedCollection new: 2.
	[ currentToken isKeyword ] whileTrue: [
		selector := selector, currentToken value.
		positions add: currentToken start.
		self step.
		arguments addLast: self parsePragmaLiteral ].
	^ self pragmaNodeClass
		selector: selector asSymbol
		keywordsPositions: positions asIntegerArray
		arguments: arguments.
]

{ #category : #'private-parsing' }
RBParser >> parseLiteralArray [
	| literals startToken stop |
	startToken := currentToken.
	literals := (OrderedCollection new: 5).
	self step.
	[self atEnd or: [currentToken isSpecial and: [currentToken value = $)]]] 
		whileFalse: [literals add: self parseLiteralArrayObject].
	stop := currentToken stop.
	(currentToken isSpecial and: [currentToken value = $)]) 
		ifFalse: [ ^ self parseEnglobingError: literals with: startToken errorMessage: ''')'' expected'].
	self step.
	^self literalArrayNodeClass 
		startPosition: startToken start
		contents: literals
		stopPosition: stop
		isByteArray: false
]

{ #category : #'private-parsing' }
RBParser >> parseLiteralArrayObject [
	currentToken isSpecial 
		ifTrue: 
			[currentToken value = $( ifTrue: [^self parseLiteralArray].
			"currentToken value == $[ ifTrue: [^self parseLiteralByteArray]"].
	currentToken isLiteralArrayToken 
		ifTrue: 
			[^currentToken isForByteArray 
				ifTrue: [self parseLiteralByteArray]
				ifFalse: [self parseLiteralArray]].
	currentToken isError ifTrue:[ |errorNode| errorNode :=  self parserError: currentToken cause.
		 ^ errorNode].
	currentToken isLiteralToken ifFalse: [self patchLiteralArrayToken].
	^self parsePrimitiveLiteral
]

{ #category : #'private-parsing' }
RBParser >> parseLiteralByteArray [
	"Current token is litteral array token #[ which means following tokens are part of the array 
	 until the encounter of the special character ] ."
	| stream startToken stop |
	startToken := currentToken.
	stream := (Array new: 5) writeStream.
	self step.
	[self atEnd or: [currentToken isSpecial and: [currentToken value = $]]]] 
		"Put literal value nodes corresponding to the bytes in the stream."
		whileFalse: [stream nextPut: self parseLiteralByteArrayObject].
	(currentToken isSpecial and: [currentToken value = $]]) 
		ifFalse: [ ^ self parseEnglobingError: stream contents with: startToken errorMessage: ''']'' expected'].
	stop := currentToken stop.
	self step.
	^self literalArrayNodeClass 
		startPosition: startToken start
		contents: stream contents
		stopPosition: stop
		isByteArray: true
]

{ #category : #'private-parsing' }
RBParser >> parseLiteralByteArrayObject [
	"Ensure that the object contained in the array is the value of a byte."
	"Return a literal value node of said byte."
	(currentToken isLiteralToken and: 
			[currentToken value isInteger and: [currentToken value between: 0 and: 255]]) 
		ifFalse: [
			| errorNode |
			errorNode := self parserError: 'Expecting 8-bit integer'.
			self step.
			^ errorNode ].
	^self parsePrimitiveLiteral
]

{ #category : #accessing }
RBParser >> parseLiterals: aString [ 
	| stream |
	stream := (Array new: 5) writeStream.
	[self atEnd or: [currentToken isSpecial and: [currentToken value = $)]]] 
		whileFalse: [stream nextPut: self parseLiteralArrayObject].
	self atEnd ifFalse: [ ^ self parserError: 'Unknown input at end'].
	^stream contents collect: [ :each | each value ]
]

{ #category : #'private-parsing' }
RBParser >> parseMessagePattern [
	currentToken isLiteralToken ifTrue: [self patchLiteralMessage].
	^currentToken isIdentifier 
		ifTrue: [self parseUnaryPattern]
		ifFalse: 
			[currentToken isKeyword 
				ifTrue: [self parseKeywordPattern]
				ifFalse: [self parseBinaryPattern]]
]

{ #category : #'private-parsing' }
RBParser >> parseMethod [
	| methodNode sequenceNode | 
	methodNode := self parseMessagePattern.
	self parsePragmas.
	self addCommentsTo: methodNode.
	
	methodNode body ifNil: [
		sequenceNode := self sequenceNodeClass new.
		methodNode body: sequenceNode ].
	
	self parseStatements: true into: methodNode body untilAnyCloserOf: #().
		
	pragmas ifNotNil: [ methodNode pragmas: pragmas ].
	^methodNode
]

{ #category : #accessing }
RBParser >> parseMethod: aMethodDefinitionString [
	"Parse and return a abstract syntax tree from the argument"
	
	| node |
	node := self parseMethod.
	node source: aMethodDefinitionString.
	self atEnd
		ifFalse: [ 
			 ^ self parseIncompleteExpression: node body ].
	node source: aMethodDefinitionString.
	^ node
]

{ #category : #'private-parsing' }
RBParser >> parseNumberLiteral [
	"Creates a literal value node from a number literal token."
	| token |
	"self deprecated: 'Unnecessary method because it is the same as parsePrimitiveValueLiteral, both called only by parsePrimitiveLiteral' transformWith: self parsePrimitiveLiteral."
	token := currentToken.
	self step.
	
	^self literalValueNodeClass 
		value: token value 
		start: token start
		stop: token stop
		source: token source
	
]

{ #category : #'private-parsing' }
RBParser >> parseParenthesizedExpression [
	| node startToken |
	startToken := currentToken.
	self step.
	node := self parseAssignment.
	^(currentToken isSpecial and: [currentToken value = $)])
		ifTrue: 
			[node addParenthesis: (startToken start to: currentToken start).
			self step.
			node]
		ifFalse: [ ^ self parseEnglobingError: (OrderedCollection with: node) with: startToken errorMessage: ''')'' expected']
]

{ #category : #'private-parsing' }
RBParser >> parsePragma [
	"Method called by parsePragmas which already verified that current token is the special character <"
	| startToken pragma |
	startToken := currentToken.
	self step.
	pragma := self basicParsePragma.
	(currentToken isBinary and: [ currentToken value == #> ]) 
		ifFalse: [  ^self addPragma: ( self parseEnglobingError: (OrderedCollection with: pragma) with: startToken errorMessage: '''>'' expected')].
	pragma left: startToken start; right: currentToken start.
	self addPragma: pragma.
]

{ #category : #'private-parsing' }
RBParser >> parsePragmaLiteral [
	"A literal array token is #( or #[."
	currentToken isLiteralArrayToken 
		ifTrue: 
			[^currentToken isForByteArray 
				ifTrue: [self parseLiteralByteArray]
				ifFalse: [self parseLiteralArray]].
	currentToken isLiteralToken ifFalse: [^self parserError:'Literal constant expected'].
	"Return a literal value node."
	^self parsePrimitiveLiteral
]

{ #category : #'private-parsing' }
RBParser >> parsePragmas [
	[ currentToken isBinary and: [ currentToken value = #< ] ] whileTrue: [
		self parsePragma.
		self step ]
]

{ #category : #'private-parsing' }
RBParser >> parsePrimitiveIdentifier [
	"Creates a Variable Node and copies the value, start position and comments in said node."
	"This method is called by parseVariableNode which makes sure current token is Identifier."
	| token node |
	token := currentToken.
	self step.
	node := self variableNodeClass identifierNamed: token value at: token start.
	self addCommentsTo: node.
	^node
]

{ #category : #'private-parsing' }
RBParser >> parsePrimitiveKeywordPragma [
	| selector positions arguments |
	selector := ''.
	positions := OrderedCollection new: 2.
	arguments := OrderedCollection new: 2.
	[ currentToken isKeyword ] whileTrue: [
		selector := selector, currentToken value.
		positions add: currentToken start.
		self step.
		arguments addLast: self parsePrimitiveLiteral ].
	^ self pragmaNodeClass
		selector: selector asSymbol
		keywordsPositions: positions asIntegerArray
		arguments: arguments.
]

{ #category : #'private-parsing' }
RBParser >> parsePrimitiveLiteral [
	^ currentToken isNumberLiteralToken
		ifTrue: [ self parseNumberLiteral ]
		ifFalse: [ self parsePrimitiveValueLiteral ]
]

{ #category : #'private-parsing' }
RBParser >> parsePrimitiveObject [
	| errorNode |
	currentToken isIdentifier ifTrue: [^self parsePrimitiveIdentifier].
	(currentToken isLiteralToken and: [currentToken isMultiKeyword not]) 
		ifTrue: [^self parsePrimitiveLiteral].
	currentToken isLiteralArrayToken
		ifTrue: 
			[^currentToken isForByteArray 
				ifTrue: [self parseLiteralByteArray]
				ifFalse: [self parseLiteralArray]].
	(currentToken isSpecial and: ('[({' includes: currentToken value))
		ifTrue: 
			[currentToken value = $[ ifTrue: [^self saveCommentsDuring:[self parseBlock]].
			currentToken value = $( ifTrue: [^self parseParenthesizedExpression].
			currentToken value = ${ ifTrue: [^self parseArray]].
	errorNode := self parserError: 'Variable or expression expected'.
	^errorNode.
]

{ #category : #'private-parsing' }
RBParser >> parsePrimitiveValueLiteral [
	"Creates a literal value node from a literal token."
	| token |
	"self deprecated: 'Unnecessary method because it is the same as parseNumberLiteral, both called only by parsePrimitiveLiteral' transformWith: self parsePrimitiveLiteral."
	token := currentToken.
	self step.

	^self literalValueNodeClass 
		value: token value 
		start: token start
		stop: token stop
		source: token source
	
]

{ #category : #'private-parsing' }
RBParser >> parseStatementInto: statementList periodList: periods [

	| returnPosition node startOfStatementToken |
	
	"Record the token found at the beginning of the statement.
	If at the end we did not consume it, consume it and mark it as a bad statement for now"
	startOfStatementToken := currentToken.
	
	"If the current statement starts with ^, parse it as a return + an expression.
	Otherwise just parse it as an expression.
	Expressions start with assignments, which have lower precedence"
	(currentToken isSpecial and: [ currentToken value = $^ ])
		ifTrue: [ 
			returnPosition := currentToken start.
			self step.
			node := self returnNodeClass
				        return: returnPosition
				        value: self parseAssignment ]
		ifFalse: [ node := self parseAssignment ].

	"At this point we have parsed a full statement.
	Next we should have the end of the statement
	  - a dot or
	  - a scope closer e.g., )]} or
	  -  or the end of the stream.
	If it is neither, we should mark our statement as unfinished statement."
	(currentToken value ~= $. 
		and: [ ('])}' includes: currentToken value) not
			and: [ currentToken isEOF not ] ] ) ifTrue: [
		self parserError: 'End of statement expected'.
		node := RBUnfinishedStatementErrorNode
			content: { node }
			start: node start
			stop: node stop
			errorMessage: 'End of statement expected'
	].

	"Then consume all dots and comments coming after this well formed statement, if there was any"
	(currentToken isSpecial and: [ currentToken value = $. ]) ifTrue: [ 
		periods add: currentToken start.
		self step.
		self addCommentsTo: node ].

	[ currentToken isSpecial and: [ currentToken value = $. ] ] 
		whileTrue: [ 
			periods add: currentToken start.
			self step ].

	"If the previous node in the statement list is a return node, mark this node as unreachable"
	
	(statementList notEmpty and: [ statementList last isReturn ]) ifTrue: [
		self parserError: 'Unreachable code'.
		node := RBUnreachableStatementErrorNode
			content: { node }
			start: node start
			stop: node stop
			errorMessage: 'Unreachable code' ].

	"Commit the statement to the statements list"
	statementList add: node.
	
	"Consume it. This is a hack to get to work"
	startOfStatementToken = currentToken ifTrue: [ self step ]
	
]

{ #category : #'private-parsing' }
RBParser >> parseStatementInto: statementList periodList: periods withAcceptedStatementClosers: aCollectionOfClosers [

	"Parse a statement and store it into the statement list.
	Parse statements as valid only if they end in one of the accepted statement closers provided by the enclosing scope.
	E.g., if we are parsing a block, a valid closer is ].
	
	Put any period found at the end of this statement int the periods collection.
	"
	| returnPosition node startOfStatementToken |
	
	"Record the token found at the beginning of the statement.
	If at the end we did not consume it, consume it and mark it as a bad statement for now"
	startOfStatementToken := currentToken.
	
	"If the current statement starts with ^, parse it as a return + an expression.
	Otherwise just parse it as an expression.
	Expressions start with assignments, which have lower precedence"
	(currentToken isSpecial and: [ currentToken value = $^ ])
		ifTrue: [ 
			returnPosition := currentToken start.
			self step.
			node := self returnNodeClass
				        return: returnPosition
				        value: self parseAssignment ]
		ifFalse: [ node := self parseAssignment ].
		
	"If the parsing failed because it did not match anything, consume the current token and continue parsing."
	startOfStatementToken = currentToken ifTrue: [ self step ].

	"At this point we have parsed a full statement."
	"If the statement is followed by closers that do not match the current scope, consume them and produce the corresponding errors wrapping the statement."
	[(')]}' includes: currentToken value)
		and: [ (aCollectionOfClosers includes: currentToken value) not ]]
			whileTrue: [
				self parserError: 'Missing opener for closer: ', currentToken value asString.
				node := RBUnfinishedStatementErrorNode
					content: { node }
					start: node start
					stop: currentToken stop
					errorMessage: 'Missing opener for closer: ', currentToken value asString.
				self step ].
	
	"Next we should have the end of the statement
	  - a dot or
	  - an accepted scope closer e.g., )]} or
	  - or the end of the stream.
	If it is neither, we should mark our statement as unfinished statement."
	(currentToken value ~= $. 
		and: [ (aCollectionOfClosers includes: currentToken value) not
			and: [ currentToken isEOF not ] ] ) ifTrue: [
		self parserError: 'End of statement expected'.
		node := RBUnfinishedStatementErrorNode
			content: { node }
			start: node start
			stop: node stop
			errorMessage: 'End of statement expected'
	].

	"Then consume all dots and comments coming after this well formed statement, if there was any"
	(currentToken isSpecial and: [ currentToken value = $. ]) ifTrue: [ 
		periods add: currentToken start.
		self step.
		self addCommentsTo: node ].

	[ currentToken isSpecial and: [ currentToken value = $. ] ] 
		whileTrue: [ 
			periods add: currentToken start.
			self step ].

	"If the previous node in the statement list is a return node, mark this node as unreachable"
	
	(statementList notEmpty and: [ statementList last isReturn ]) ifTrue: [
		self parserError: 'Unreachable code'.
		node := RBUnreachableStatementErrorNode
			content: { node }
			start: node start
			stop: node stop
			errorMessage: 'Unreachable code' ].

	"Commit the statement to the statements list"
	statementList add: node.
	
]

{ #category : #'private-parsing' }
RBParser >> parseStatementList: pragmaBoolean into: sequenceNode until: aBlock [

	"Parse a list of statements and set those statetements to a sequence node.
	Stop parsing when we finish the current scope.
	Different scopes such as blocks or methods can decide different stop conditions."

	| statements return periods |
	return := false.
	statements := sequenceNode statements.
	periods := OrderedCollection new.

	self addCommentsTo: sequenceNode.

	pragmaBoolean ifTrue: [ self parsePragmas ].

	[ currentToken isSpecial and: [ currentToken value = $. ] ] 
		whileTrue: [ 
			periods add: currentToken start.
			self step ].

	[  self atEnd or: [ aBlock value ] ] whileFalse: [ 
		self parseStatementInto: statements periodList: periods ].

	statements notEmpty ifTrue: [ self addCommentsTo: statements last ].
	sequenceNode
		statements: statements;
		periods: periods.
	^ sequenceNode
]

{ #category : #'private-parsing' }
RBParser >> parseStatementList: pragmaBoolean into: sequenceNode untilAnyCloserOf: aCollectionOfClosers [

	"Parse a list of statements and set those statetements to a sequence node.
	Stop parsing when we finish the current scope, delimited by a colleciton of closers.
	Different scopes such as blocks or methods can decide different stop conditions."

	| statements return periods |
	return := false.
	statements := sequenceNode statements.
	periods := OrderedCollection new.

	self addCommentsTo: sequenceNode.

	pragmaBoolean ifTrue: [ self parsePragmas ].

	[ currentToken isSpecial and: [ currentToken value = $. ] ] 
		whileTrue: [ 
			periods add: currentToken start.
			self step ].

	[ self atEnd or: [ currentToken isSpecial
		and: [aCollectionOfClosers includes: currentToken value] ] ]
			whileFalse: [
				self 
					parseStatementInto: statements
					periodList: periods
					withAcceptedStatementClosers: aCollectionOfClosers ].

	statements
		ifEmpty: [ self addCommentsTo: sequenceNode ]
		ifNotEmpty: [ self addCommentsTo: statements last ].
	sequenceNode
		statements: statements;
		periods: periods.
	^ sequenceNode
]

{ #category : #'private-parsing' }
RBParser >> parseStatements: pragmaBoolean [
	^ self
		parseStatements: pragmaBoolean
		into: self sequenceNodeClass new
		untilAnyCloserOf: #()
]

{ #category : #'private-parsing' }
RBParser >> parseStatements: pragmaBoolean into: aSequenceNode until: aBlock [
	
	self parseTemporariesInto: aSequenceNode.
	
	^self
		parseStatementList: pragmaBoolean
		into: aSequenceNode
		until: aBlock
]

{ #category : #'private-parsing' }
RBParser >> parseStatements: pragmaBoolean into: aSequenceNode untilAnyCloserOf: aCollectionOfClosers [
	
	self parseTemporariesInto: aSequenceNode.
	
	^self
		parseStatementList: pragmaBoolean
		into: aSequenceNode
		untilAnyCloserOf: aCollectionOfClosers
]

{ #category : #'private-parsing' }
RBParser >> parseTemporariesInto: aSequenceNode [
	| temps leftBar rightBar errorNode startToken |
	temps := OrderedCollection new.
	leftBar := rightBar := nil.
	currentToken isBinary 
		ifTrue: 
			[currentToken value = #| 
				ifTrue: 
					[ startToken := currentToken.
					leftBar := currentToken start.
					self step.
					temps := self parseTemps.
					(currentToken isBinary and: [currentToken value = #|]) 
						ifFalse: [ errorNode :=  self parseEnglobingError: temps with: startToken errorMessage: '''|'' expected'.
									 aSequenceNode addFaultyNode: errorNode.
									 temps := OrderedCollection new.
									 leftBar := nil.
								    ]
						ifTrue: [ rightBar := currentToken start ].
					self step]
				ifFalse: 
					[currentToken value = #'||' 
						ifTrue: 
							[rightBar := (leftBar := currentToken start) + 1.
							self step]]].
				
	aSequenceNode leftBar: leftBar temporaries: temps rightBar: rightBar
]

{ #category : #'private-parsing' }
RBParser >> parseTemps [
	| temps |
	temps := OrderedCollection new.
	[currentToken isIdentifier] whileTrue: [temps add: self parsePrimitiveIdentifier].
	^temps
]

{ #category : #'private-parsing' }
RBParser >> parseUnaryMessage [
	| node |
	node := self parsePrimitiveObject.
	self addCommentsTo: node.
	[currentToken isLiteralToken ifTrue: [self patchLiteralMessage].
	currentToken isIdentifier] 
			whileTrue: [node := self parseUnaryMessageWith: node].
	self addCommentsTo: node.
	^node
]

{ #category : #'private-parsing' }
RBParser >> parseUnaryMessageWith: aNode [ 
	| selector |
	selector := self selectorNodeClass value: currentToken value keywordPositions: (Array with: currentToken start).
	self step.
	^self messageNodeClass
		receiver: aNode
		selector:  selector
		keywordsPositions: selector keywordPositions
		arguments: #()
]

{ #category : #'private-parsing' }
RBParser >> parseUnaryPattern [
	| selector |
	selector := currentToken.
	self step.
	^self methodNodeClass selector: selector value asSymbol keywordsPositions: (Array with: selector start) arguments: #()
]

{ #category : #'private-parsing' }
RBParser >> parseUnaryPragma [
	"Current Token must be an Identifier."
	"Return an RBPragmaNode."
	| selector |
	selector := currentToken.
	self step.
	^ self pragmaNodeClass selector: selector value asSymbol keywordsPositions: (Array with: selector start) arguments: #()
]

{ #category : #'private-parsing' }
RBParser >> parseVariableNode [
	"If called without having an Identifier Token : sends an error.
	 Return a variable node with current token value, start position and comments."
	currentToken isIdentifier 
		ifFalse: [ ^ self parserError: 'Variable name expected' ].
	^self parsePrimitiveIdentifier
]

{ #category : #'error handling' }
RBParser >> parserError: aString [ 
	"Let the errorBlock try to recover from the error. Answer a ParseNode (possibly an RBParseErrorNode) or signal there is new source"
	| errorNode errorMessage errorPosition newSource |
	errorNode := self errorBlock cull: aString cull: self errorPosition cull: self.
	errorNode ifNotNil: [ ^ errorNode ].
	currentToken isError 
		ifTrue: [ errorMessage := currentToken cause. errorPosition := currentToken location ] 
		ifFalse: [errorMessage := aString. errorPosition := currentToken start].
	
	newSource := SyntaxErrorNotification
						inClass: Object
						withCode: source
						doitFlag: false
						errorMessage: errorMessage
						location: errorPosition.
	
	"If the syntax error notification is resumed, then the source was corrected and we have to announce that parsing can restart."					
	ReparseAfterSourceEditing signalWithNewSource: newSource.
]

{ #category : #private }
RBParser >> patchLiteralArrayToken [
	(currentToken isIdentifier and: 
			[self nextToken isAssignment 
				and: [currentToken stop + 1 = self nextToken start]]) 
		ifTrue: 
			[currentToken := RBLiteralToken 
						value: (currentToken value , ':') asSymbol
						start: currentToken start
						stop: self nextToken start.
			nextToken := RBLiteralToken 
						value: #=
						start: nextToken stop
						stop: nextToken stop.
			^self].
	currentToken isAssignment 
		ifTrue: 
			[currentToken := RBLiteralToken 
						value: #':'
						start: currentToken start
						stop: currentToken start.
			nextToken := RBLiteralToken 
						value: #=
						start: currentToken stop
						stop: currentToken stop.
			^self].
	currentToken isSpecial 
		ifTrue: 
			[currentToken := RBLiteralToken 
						value: (String with: currentToken value) asSymbol
						start: currentToken start
						stop: currentToken stop.
			^self].
	(currentToken isIdentifier and: [currentToken value includes: $.]) 
		ifTrue: 
			[currentToken := RBLiteralToken 
						value: currentToken value
						start: currentToken start
						stop: currentToken stop.
			^self].
	(currentToken isIdentifier 
		or: [currentToken isBinary or: [currentToken isKeyword]]) 
			ifFalse: [^self parserError: 'Invalid token'].
	currentToken := RBLiteralToken 
				value: currentToken value asSymbol
				start: currentToken start
				stop: currentToken stop
				source: currentToken value asString.
]

{ #category : #private }
RBParser >> patchLiteralMessage [

	currentToken value == true
		ifTrue: [ ^ currentToken := RBIdentifierToken value: 'true' start: currentToken start ].
	currentToken value == false
		ifTrue: [ ^ currentToken := RBIdentifierToken value: 'false' start: currentToken start ].
	currentToken value
		ifNil: [ ^ currentToken := RBIdentifierToken value: 'nil' start: currentToken start ]
]

{ #category : #private }
RBParser >> patchNegativeLiteral [
	"Handle the special negative number case for binary message sends."

	currentToken value isNumber 
		ifFalse: [^self].
	currentToken value <= 0 ifFalse: [^self].
	currentToken value = 0 
		ifTrue: 
			[(source notNil and: 
					[source notEmpty 
						and: [(source at: (currentToken start min: source size)) = $-]]) 
				ifFalse: [^self]].
	nextToken := currentToken.
	currentToken := RBBinarySelectorToken value: #- start: nextToken start.
	nextToken value: nextToken value negated.
	(nextToken isKindOf: RBNumberLiteralToken) 
		ifTrue: 
			[nextToken source: (nextToken source copyFrom: 2 to: nextToken source size)].
	nextToken start: nextToken start + 1
]

{ #category : #'private-classes' }
RBParser >> pragmaNodeClass [
	^ RBPragmaNode
]

{ #category : #'private-classes' }
RBParser >> returnNodeClass [
	^ RBReturnNode
]

{ #category : #'private-parsing' }
RBParser >> saveCommentsDuring: aBlock [
	| currentComments |
	currentComments := comments copy.
	comments removeAll.
	^ aBlock
		ensure: [ comments := comments, currentComments ]
]

{ #category : #initialization }
RBParser >> scanner: aScanner [ 
	scanner := aScanner.
	pragmas := nil.
	aScanner errorBlock: self errorBlock.
	self initialize.
	self step.
]

{ #category : #accessing }
RBParser >> scannerClass [
	^RBScanner
]

{ #category : #private }
RBParser >> scannerNext [

	^ scanner next
]

{ #category : #'private-classes' }
RBParser >> selectorNodeClass [
	^ RBSelectorNode
]

{ #category : #'private-classes' }
RBParser >> sequenceNodeClass [
	^ RBSequenceNode
]

{ #category : #private }
RBParser >> step [
	(currentToken notNil and: [currentToken comments notNil]) 
		ifTrue: [self extractCommentsFrom: currentToken].
	nextToken notNil 
		ifTrue: 
			[currentToken := nextToken.
			nextToken := nil]
		ifFalse: [currentToken := self scannerNext].
]

{ #category : #'private-classes' }
RBParser >> variableNodeClass [
	^ RBVariableNode
]
