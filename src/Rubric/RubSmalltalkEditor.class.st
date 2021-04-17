"
I am the editor for smalltalk code, I allow to browse, execute etc
"
Class {
	#name : #RubSmalltalkEditor,
	#superclass : #RubTextEditor,
	#instVars : [
		'notificationStrategy',
		'completionEngine'
	],
	#classVars : [
		'CompletionEngineClass'
	],
	#category : #'Rubric-Editing-Code'
}

{ #category : #keymapping }
RubSmalltalkEditor class >> buildShortcutsOn: aBuilder [
	"We are defining the bindings twice because we want to support 
	both Cmd and meta for Windows and Linux. This should happen at least as long as in the development environment
	both of these are supported.
	
	We list both variations explicitly because we want to be able to see the action code when inspecting the morph.
	"

	<keymap>	
	(aBuilder shortcut: #browseFullClass)
		category: RubSmalltalkEditor name
		default: $b meta
		do: [ :target | target editor browseFullClass ]
		description: 'Browse'.
	
	(aBuilder shortcut: #doIt)
		category: RubSmalltalkEditor name
		default: $d meta
		do: [ :target | target editor doIt: nil ]
		description: 'Do it'.
	
	(aBuilder shortcut: #inspectIt)
		category: RubSmalltalkEditor name
		default: $i meta
		do: [ :target | target editor inspectIt: nil ]
		description: 'Inspect it'.
	
	(aBuilder shortcut: #basicInspectIt)
		category: RubSmalltalkEditor name
		default: $i meta shift
		do: [ :target | target editor basicInspectIt ]
		description: 'Basic Inspect it'.
	
	(aBuilder shortcut: #implementorsOfIt)
		category: RubSmalltalkEditor name
		default: $m meta
		do: [ :target | target editor implementorsOfIt: nil ]
		description: 'Implementors of it'.
	
	(aBuilder shortcut: #senderOfIt)
		category: RubSmalltalkEditor name
		default: $n meta
		do: [ :target | target editor sendersOfIt: nil ]
		description: 'Senders of it'.
	
	(aBuilder shortcut: #printIt)
		category: RubSmalltalkEditor name
		default: $p meta
		do: [ :target | target editor printIt ]
		description: 'Print it'.
	
	(aBuilder shortcut: #debugIt)
		category: RubSmalltalkEditor name
		default: $d meta shift
		do: [ :target | target editor debugIt: nil ]
		description: 'Debug it'.
	
	(aBuilder shortcut: #referencesToIt)
		category: RubSmalltalkEditor name
		default: $n meta shift
		do: [ :target | target editor referencesToIt: nil ]
		description: 'References to it'.
	
	(aBuilder shortcut: #methodStringsContainingIt)
		category: RubSmalltalkEditor name
		default: $e meta shift
		do: [ :target | target editor methodStringsContainingIt: nil ]
		description: 'Method strings containing it'.
	
	(aBuilder shortcut: #format)
		category: RubSmalltalkEditor name
		default: PharoShortcuts current formatCodeShortcut
		do: [ :target | target formatMethodCode ].
		
	
	(aBuilder shortcut: #jumpToNextKeywordOfIt)
		category: RubSmalltalkEditor name
		default: $j meta
		do: [ :target | target editor jumpToNextKeywordOfIt: true ]
		description: 'Jump to next keyword'.
		
	(aBuilder shortcut: #jumpToNextKeywordOfIt)
		category: RubSmalltalkEditor name
		default: $j shift meta
		do: [ :target | target editor jumpToNextKeywordOfIt: false ]
		description: 'Jump to previous keyword'.
		
	(aBuilder shortcut: #widenSelectionOfIt)
		category: RubSmalltalkEditor name
		default: $2 meta
		do: [ :target | target editor widenSelectionOfIt ]
		description: 'Widen selection'.
	
]

{ #category : #'completion engine' }
RubSmalltalkEditor class >> completionEngineClass [
	
	^ CompletionEngineClass
]

{ #category : #'completion engine' }
RubSmalltalkEditor class >> completionEngineClass: anEngine [
	
	CompletionEngineClass := anEngine
]

{ #category : #'completion engine' }
RubSmalltalkEditor class >> noCompletion [

	CompletionEngineClass := nil
]

{ #category : #'completion engine' }
RubSmalltalkEditor >> atCompletionPosition [
	"Return true if the cursor is at a possible completion position"
	| cursorPosition |
	cursorPosition := self startIndex.
	cursorPosition < 2 ifTrue: [ ^ false ].
	^ (self text at: cursorPosition - 1) isCompletionCharacter
]

{ #category : #'do-its' }
RubSmalltalkEditor >> basicInspectIt [
	self evaluateSelectionAndDo: [:result | result basicInspect]
]

{ #category : #'source navigation' }
RubSmalltalkEditor >> bestNodeInString: source at: selectionInterval editingMode: aRubEdittingMode shouldFavourExpressions: isFavouringExpressions onError: aBlock [
	"Find the best node in the source text in the identified selection area"
	
	| ast node start stop |

	source ifEmpty: aBlock.
	start := selectionInterval first min: source size.
	stop := selectionInterval last min: source size.
	
	ast := aRubEdittingMode parseSource: source.
	
	ast ifNotNil: [ 
		"If there is no text selection"
		(selectionInterval isEmpty and: [ isFavouringExpressions and: [ 
			(source at: (stop + 1 min: source size)) isAlphaNumeric not ]]) ifTrue: [ 
				"If there is white space or statement terminator, try to backup to find a better node"		
				[stop > 0 and: [('.;' includes: (source at: stop)) or: [(source at: stop) isSeparator ]]]
					whileTrue: [ start := stop := stop - 1 ].
				start := stop].
		node := ast bestNodeFor: (start to: stop).
		
		node ifNil: [ 
			node := RBParseErrorNodeVisitor
				visit: ast 
				detect: [ :n | n intersectsInterval: (start to: start)]
				ifNone: [ ^aBlock value ]].
		
		node isFaulty ifTrue: [ 
			node allChildren size = 1 ifTrue: [ 
				(aRubEdittingMode parseExpression: (node value padLeftTo: source size)) 
					ifNil: [ ^node ] 
					ifNotNil: [ :newNode |
						ast replaceNode: node withNode: newNode.
						node := newNode ].
				].
			
			node := RBGenericNodeVisitor 
				visit: node 
				detect: [ :n | n intersectsInterval: (start to: start) ] 
				ifNone: [ node ] ] ].
	

	^node

]

{ #category : #generated }
RubSmalltalkEditor >> bestNodeInString: source at: selectionInterval edittingMode: aRubEdittingMode shouldFavourExpressions: isFavouringExpressions onError: aBlock [

	"Find the best node in the source text in the identified selection area"

	self
		deprecated:
		'Use #bestNodeInString:at:editingMode:shouldFavourExpressions:onError: instead'
		transformWith:
			'`@rec bestNodeInString: `@arg1 at: `@arg2 edittingMode: `@arg3 shouldFavourExpressions: `@arg4 onError: `@arg5'
			->
			'`@rec bestNodeInString: `@arg1 at: `@arg2 editingMode: `@arg3 shouldFavourExpressions: `@arg4 onError: `@arg5'.
	^ self
		  bestNodeInString: source
		  at: selectionInterval
		  editingMode: aRubEdittingMode
		  shouldFavourExpressions: isFavouringExpressions
		  onError: aBlock
]

{ #category : #'source navigation' }
RubSmalltalkEditor >> bestNodeInTextArea [
	"Find the best node in the editor text area at the current pointer location"
	
	| node start stop |
	
	start := self textArea startIndex.
	stop := self textArea stopIndex.
	
	[node := RBParser parseMethod: self textArea string onError: [ 
		RBParser parseFaultyExpression: self textArea string]
	] on: Error do: [^nil].
	
	^node bestNodeFor: (start to: stop).
	
]

{ #category : #'source navigation' }
RubSmalltalkEditor >> bestNodeInTextAreaOnError: aBlock [
	"Find the best node in the editor text area at the current pointer location"

	| start stop source |
	start := self textArea startIndex.
	stop := self textArea stopIndex.

	source := self textArea string.

	^ self
		bestNodeInString: source
		at: (start to: stop)
		editingMode: self editingMode
		shouldFavourExpressions: true
		onError: aBlock
]

{ #category : #'as yet unclassified' }
RubSmalltalkEditor >> bestNodeInTextAreaWithoutSelection [
	"Find the best node in the editor text area trimming the selection to prepare for eventual deletion"
	
	| node start stop intervalTrimmedText |
	
	start := self textArea startIndex.
	stop := self textArea stopIndex.
	intervalTrimmedText := start = stop 
					ifFalse: [ 	| beginning end |
									beginning := end := ''.
									start <= 1 ifFalse: [ beginning := self textArea string copyFrom: 1 to: start - 1 ].
									stop >= self textArea text size ifFalse: [ end :=  self textArea string copyFrom: stop + 1 to: self textArea text size ].
									beginning,end ]
					 ifTrue: [ self textArea string ].
		
	node := self isScripting
		ifTrue: [ RBParser parseFaultyExpression: intervalTrimmedText ]
		ifFalse: [ RBParser parseFaultyMethod: intervalTrimmedText ].

	^node bestNodeFor: (start to: start)
]

{ #category : #binding }
RubSmalltalkEditor >> bindingOf: aString [
	^ self textArea bindingOf: aString
]

{ #category : #'menu messages' }
RubSmalltalkEditor >> browseClassFrom: aClassString [
	"Launch a hierarchy browser for the class indicated by the current selection.  If multiple classes matching the selection exist, let the user choose among them."

	| selectedClass |
	"self lineSelectAndEmptyCheck: [ ^ self ]."
	( aClassString isNil or: [ aClassString isEmpty ] )
		ifTrue: [ textArea flash.
			^ self ].

	selectedClass := self model systemNavigation
		classFromPattern: aClassString
		withCaption: 'choose a class to browse...'.
	selectedClass ifNil: [ ^ self internalCallToImplementorsOf: aClassString ].
	Smalltalk tools browser openOnClass: selectedClass
]

{ #category : #'editing keys' }
RubSmalltalkEditor >> browseClassOfExpression [
 	"Launch a browser for the class of the current selection, i.e. if you select 1+2 then you will get a class browser on class Point. Notice that this method handles also when the expression is a class."
	
 	self evaluateSelectionAndDo: [:result | result class instanceSide browse ].
	^ true
]

{ #category : #'menu messages' }
RubSmalltalkEditor >> browseFullClass [
	"Launch a browser for the class indicated by the current selection. Note that if the selection is a valid expression it will browse the class of the result. If multiple classes matching the selection exist, let the user choose among them."
	

	"previous code was: self browseClassFrom: self findClassFromAST"
	self browseClassOfExpression 
]

{ #category : #'editing keys' }
RubSmalltalkEditor >> browseFullClassIt: t1 [ 

	self browseFullClass.
	^ true
]

{ #category : #'menu messages' }
RubSmalltalkEditor >> classCommentsContainingIt [
	"Open a browser class comments which contain the current selection somewhere in them."

	self lineSelectAndEmptyCheck: [^ self].
	self model systemNavigation  browseClassCommentsWithString: self selection string matchCase: false. 
]

{ #category : #'menu messages' }
RubSmalltalkEditor >> classNamesContainingIt [
	"Open a browser on classes whose names contain the selected string"

	self lineSelectAndEmptyCheck: [^self].
	self model systemNavigation 
		browseClassesWithNamesContaining: self selection string
		caseSensitive: Sensor shiftPressed
]

{ #category : #'do-its' }
RubSmalltalkEditor >> compile: aStream for: anObject in: evalContext [
	| methodClass |
	methodClass := evalContext
		ifNil: [ anObject class ]
		ifNotNil: [ evalContext methodClass ].
	^self class compiler
		source: aStream;
		class: methodClass;
		context: evalContext;
		requestor: self morph;
		noPattern: true;
		failBlock: [ ^ nil ];
		compile
]

{ #category : #'do-its' }
RubSmalltalkEditor >> compileSelectionFor: anObject in: evalContext [
	^ self compile: self selectionAsStream for: anObject in: evalContext
]

{ #category : #'completion engine' }
RubSmalltalkEditor >> completionAround: aBlock keyDown: anEvent [
	"I'm a editor for Smalltalk, so, do completion around"
	
	self isCompletionEnabled ifFalse: [  ^aBlock value ].
	
	(completionEngine handleKeyDownBefore: anEvent editor: self) ifTrue:  [^ self ].
	
	aBlock value.
	
	completionEngine handleKeyDownAfter: anEvent editor: self

]

{ #category : #'completion engine' }
RubSmalltalkEditor >> completionAround: aBlock keyStroke: anEvent [
	"I'm a editor for Smalltalk, so, do completion around"
	
	self isCompletionEnabled ifFalse: [  ^aBlock value ].
	
	(completionEngine handleKeystrokeBefore: anEvent editor: self) ifTrue:  [^ self ].
	
	aBlock value.	
	completionEngine handleKeystrokeAfter: anEvent editor: self

]

{ #category : #'completion engine' }
RubSmalltalkEditor >> completionEngine [

	^ completionEngine ifNil: [
		CompletionEngineClass ifNotNil: [
			self completionEngine: CompletionEngineClass new.
			completionEngine ] ]
]

{ #category : #'completion engine' }
RubSmalltalkEditor >> completionEngine: aCompletionEngine [

	completionEngine := aCompletionEngine.
	self textArea ifNotNil: [:txtArea | txtArea setCompletionEngine: aCompletionEngine] 
]

{ #category : #'new selection' }
RubSmalltalkEditor >> computeSelectionIntervalForCurrentLine [
	| i left right s quoteCounter|
	s := self string.
	i := s encompassParagraph: self selectionInterval.
	left := i first.
	right := i last.
	"we need to skip all text that is inside of quote pairs"
	quoteCounter := 0.
	[ left <= right and: [ (s at: left) = $"
			or: [ quoteCounter % 2 = 1
				or: [(s at: left) isSeparator] ] ] ]
		whileTrue: [ 
			(s at: left) = $" ifTrue: [ quoteCounter := quoteCounter + 1 ].
			left := left + 1 ].
	quoteCounter := 0.
	[ left <= right and: [ ((s at: right) = $"
			"we need to stop if quote is defined as character"
			and: [ right - 1 < 1 or: [ (s at: right - 1) ~= $$ ] ])
				or: [ quoteCounter % 2 = 1 or: [(s at: right) isSeparator] ] ] ]
		whileTrue: [
			(s at: right) = $" ifTrue: [ quoteCounter := quoteCounter + 1 ].
			right := right - 1 ].
	^ left to: right
]

{ #category : #private }
RubSmalltalkEditor >> computeSelectionIntervalFromCodeIn: aString at: anInterval [
	^ (RBParser parseExpression: (aString copyFrom: anInterval first to: anInterval last)) sourceInterval
]

{ #category : #private }
RubSmalltalkEditor >> computeSelectionIntervalFromCommentIn: aString at: anInterval [
	| comment commentInterval |
	comment := (RBScanner on: (aString copyFrom: anInterval first to: anInterval last) readStream) getComments.
	comment ifNil: [ ^ 0 to: -1 ].
	commentInterval := comment first.
	^ commentInterval first + 1 to: commentInterval last - 1
]

{ #category : #'menu messages' }
RubSmalltalkEditor >> copySelection [
	"Copy the current selection and store it in the paste buffer, unless a caret.  Undoer & Redoer: undoCutCopy"

	| node escapingCharacter selection |
	"Research of selected node for eventual nesting of comment or string."
	self lineSelectAndEmptyCheck: [^ self].
	node := self bestNodeInTextArea.
	escapingCharacter := self getEscapeCharacterFromAst: node.
	
	selection := (escapingCharacter notNil and: [ 
		"The node, if a comment or a string, should entirely contain the selection.
		We convert the node source interval to an open interval to ignore the node delimiters."
		node sourceInterval asOpenInterval includesAll: self selectionInterval ])
		ifTrue: [ self unescapeCharacter: escapingCharacter inString:  self selection ]
		ifFalse: [ self selection ].
	self clipboardTextPut: selection.
	self editingState previousInterval: self selectionInterval.

]

{ #category : #'do-its' }
RubSmalltalkEditor >> debug: aStream [
	| method receiver context |
	(self model respondsTo: #doItReceiver)
		ifTrue: [ receiver := self model doItReceiver.
			context := self model doItContext ]
		ifFalse: [ receiver := context := nil ].
	method := self compile: aStream for: receiver in: context.
	method isReturnSpecial
		ifTrue: [ self inform: 'Nothing to debug, the expression is optimized'.
			^ self ].
	method notNil
		ifTrue: [ self debug: method receiver: receiver in: context ]
]

{ #category : #'do-its' }
RubSmalltalkEditor >> debug: aCompiledMethod receiver: anObject in: evalContext [

	| process suspendedContext |
	process := [ 
	           aCompiledMethod
		           valueWithReceiver: anObject
		           arguments:
		           (evalContext
			            ifNil: [ #(  ) ]
			            ifNotNil: [ { evalContext } ]) ] newProcess.
	suspendedContext := process suspendedContext.
	(OupsDebugRequest newForContext: suspendedContext)
		process: process;
		compiledMethod: aCompiledMethod;
		label: 'debug it';
		submit
]

{ #category : #'do-its' }
RubSmalltalkEditor >> debugHighlight [
	"Treat the current highlight as an expression; evaluate and debugg it in a new debugger."

	self highlightAndEmptyCheck: [ ^ self ].
	self debug: self highlightedTextAsStream
]

{ #category : #'do-its' }
RubSmalltalkEditor >> debugIt [

	^ self debugSelection
]

{ #category : #'editing keys' }
RubSmalltalkEditor >> debugIt: aKeyboardEvent [
	"Evaluate the current selection in the Debugger."

	self debugIt.
	^ true
]

{ #category : #'do-its' }
RubSmalltalkEditor >> debugSelection [
	"Treat the current selection as an expression; evaluate and debugg it in a new debugger."
	
	self lineSelectAndEmptyCheck: [^self].
	self debug: self selectionAsStream
]

{ #category : #'typing/selecting keys' }
RubSmalltalkEditor >> displayIfFalse: aKeyboardEvent [
	"Replace the current text selection with the text 'ifFalse:'--initiated by 
	ctrl-f."

	self addString: 'ifFalse:'.
	^false
]

{ #category : #'typing/selecting keys' }
RubSmalltalkEditor >> displayIfTrue: aKeyboardEvent [
	"Replace the current text selection with the text 'ifTrue:'--initiated by 
	ctrl-t."

	self addString: 'ifTrue:'.
	^false
]

{ #category : #'do-its' }
RubSmalltalkEditor >> doIt [
	"Set the context to include pool vars of the model.  Then evaluate."
	^ self evaluateSelection
]

{ #category : #'editing keys' }
RubSmalltalkEditor >> doIt: aKeyboardEvent [
	"Called when user hits cmd-d.  Select the current line, if relevant, then evaluate and execute.  2/1/96 sw.
	2/29/96 sw: don't call selectLine; it's done by doIt now"
	
	self doIt.
	^ true
]

{ #category : #private }
RubSmalltalkEditor >> editingMode [
	^self textArea editingMode
]

{ #category : #'do-its' }
RubSmalltalkEditor >> evaluate: aStream andDo: aBlock [
	"Treat the current selection as an expression; evaluate it and invoke aBlock with the result."
	| result rcvr ctxt |
	(self model respondsTo: #doItReceiver) 
		ifTrue: [ rcvr := self model doItReceiver.
				ctxt := self model doItContext]
		ifFalse: [ rcvr := ctxt := nil].
	result := rcvr class compiler
			source: aStream;
			context: ctxt;
			receiver: rcvr;
			requestor: self morph  "don't set it to self.. The receiver can be destroyed as a result of evaluateSelection";
			failBlock:  [self morph flash. ^ nil];
			evaluate.		
			
	^ aBlock value: result
]

{ #category : #'do-its' }
RubSmalltalkEditor >> evaluateSelection [
	"Treat the current selection as an expression; evaluate it and return the result"
	
	^self evaluateSelectionAndDo: [:result | result]
]

{ #category : #'do-its' }
RubSmalltalkEditor >> evaluateSelectionAndDo: aBlock [
	"Treat the current selection as an expression; evaluate it and invoke aBlock with the result.
	If no selection is present select the current line."

	self lineSelectAndEmptyCheck: [^ ''].
	^ self 
		evaluate: self selectionForDoitAsStream 
		andDo: aBlock
]

{ #category : #'do-its' }
RubSmalltalkEditor >> exploreIt [
	self evaluateSelectionAndDo: [:result | result inspect]
]

{ #category : #'editing keys' }
RubSmalltalkEditor >> exploreIt: aKeyboardEvent [
	"Explore the selection -- invoked via cmd-shift-I.  If there is no current selection, use the current line."
	
	self exploreIt.
	^ true
]

{ #category : #'source navigation' }
RubSmalltalkEditor >> findClassFromAST [
	"Try to make a class name out of the current text selection"

	| node fallbackBlock className |		
	"Preserve original behavior - although could consider building AST from selection"
	self hasSelection ifTrue: [ 
		^(self selection string copyWithoutAll: CharacterSet crlf) trimBoth ].
	fallbackBlock := [^nil].
	node := self bestNodeInTextAreaOnError: fallbackBlock.
	[node isVariable] whileFalse: [ 
	 	(node := node parent) ifNil: fallbackBlock ].
	className := node name.
	[ className first isUppercase ] whileFalse: [ 
		(className := className allButFirst) ifEmpty: fallbackBlock  ].
	^className
]

{ #category : #'source navigation' }
RubSmalltalkEditor >> findNextKeywordIn: sourceCode selection: selectionInterval searchingForward: isFwd ifFound: textSelectionBlock [
	"Find the next keyword/useful source location to then apply a @textSelectionBlock to.
	Anser the result of the @textSelectionBlock"
	
	| checkBlock ranges potentialLocation selectionEnd|
	
	"match on typical locations you jump to in source to complete typing. We use regex to more 
	easily cope with broken source code (where its very handy to jump while fixing code) - 
	and get initial location hints which can then use an ast to infer on. It might be possible
	to do this completely with the AST, but this was an easier starting point"
	
	ranges := sourceCode allRangesOfRegexMatches: 
		'\S+\:\s|', "ifTrue1: I...."
		'\:=\s*|', "x := Iself ..."
		'\|\s*|', "[ :var | Iself...]"
		'\:\S+|', "[ :varI :var2I | ..."
		'\;\s+|', " self msg1; Imsg2...." 
		'\,\s*|', " 'string1', I'string 2'...."
		
		'\)|', " 4 + 5)I ifTrue..."
		'\]|', " true and: [ true ]I )..."
		'\^\s*|', "  ^ Iself"
		'self\s+|', "self Imsg"
			
		"Note sure if these ones cause over-jumping, so currently excluded"
		"'\[\s*|'," "[ Iself msg1... ]"
		"'\(\s*|'," "( I5 + 2..."
		
		"Should insist on whitespace after a $. or do we want to jump between {1.2.3}?"
		'\.\s+'.  "self msg1. Iself msg2..."

	selectionEnd := selectionInterval 
		ifEmpty: [selectionInterval first]
		ifNotEmpty: [selectionInterval last].
	
	isFwd
		ifTrue: [ checkBlock := [ :match | match last > selectionEnd ] ]
		ifFalse: [ ranges := ranges reversed.
			checkBlock := [ :match | match last < (selectionEnd - 1) ] ].
		
	ranges
		do: [ :match | 
			(checkBlock value: match)
				ifTrue: [ 
					potentialLocation := match last.
					self
						findValidKeywordIn: sourceCode
						at: potentialLocation
						ifFound: [ 
								^textSelectionBlock value: potentialLocation] ] ].

		
	"If nothing found, then jump to end of any current selection"
	selectionInterval isEmpty 
		ifTrue: [ textSelectionBlock value: 
			(isFwd ifTrue: [sourceCode size] ifFalse: [ 0 ]) ]
		ifFalse: [ textSelectionBlock value: selectionEnd ]
]

{ #category : #'source navigation' }
RubSmalltalkEditor >> findSelectorFromAST [
	"Try to make a selector out of the current text selection"

	| node fallbackBlock |

	fallbackBlock := [ ^ nil ].
	node := self bestNodeInTextAreaOnError: fallbackBlock.
	
	node isMethod ifFalse: [ 
		(node isValue and: [ node value isSymbol ]) ifTrue: [ ^node value ].
				
		[ node isMessage ] whileFalse: [ 
	 		(node := node parent) ifNil: fallbackBlock ]].
	
	^node selector
]

{ #category : #'source navigation' }
RubSmalltalkEditor >> findValidKeywordIn: sourceCode at: locationIndex ifFound: aBlock [
	"find a valid keyword in the source, starting at @locationIndex. If a suitable node is found,
	evaluate the Block"
	
	| node validLocation locationInterval |
	
	validLocation := true.
	locationInterval := locationIndex to: locationIndex.
	
	node := self
		bestNodeInString: sourceCode
		at: locationInterval
		editingMode: self editingMode 
		shouldFavourExpressions: false
		onError: [ nil ].
		
	node
		ifNotNil: [ 
			node isLiteralNode
				ifTrue: [ validLocation := false ].
			node isCommentNode ifTrue: [ validLocation := false ] ].
			
	validLocation ifTrue: aBlock 
			
]

{ #category : #'do-its' }
RubSmalltalkEditor >> format [
	self model formatSourceCodeInView
]

{ #category : #'do-its' }
RubSmalltalkEditor >> highlightEvaluateAndDo: aBlock [
	"Treat the current selection as an expression; evaluate it and invoke aBlock with the result."
	
	self highlightAndEmptyCheck: [ ^ '' ].
	^ self 
		evaluate: self highlightedTextAsStream
		andDo: [:result | aBlock value: result]
]

{ #category : #'menu messages' }
RubSmalltalkEditor >> implementorsOf: aSelector [
	"Open an implementors browser on the given selector"

	(self model systemNavigation allImplementorsOf: aSelector) isEmpty
		ifTrue: [ self internalCallToBrowse: aSelector ]
		ifFalse: [ self model interactionModel systemNavigation browseAllImplementorsOf: aSelector ]
]

{ #category : #'menu messages' }
RubSmalltalkEditor >> implementorsOfIt [
	"Open an implementors browser on the selected selector"

	| aSelector |
	(aSelector := self selectedSelector) ifNil: [^ textArea flash].
	aSelector isCharacter ifTrue: [^ textArea flash].
	self implementorsOf: aSelector
]

{ #category : #'editing keys' }
RubSmalltalkEditor >> implementorsOfIt: aKeyboardEvent [
	"Triggered by Cmd-m; browse implementors of the selector represented by the current selection, if plausible. 2/1/96 sw"

	self implementorsOfIt.
	^ true
]

{ #category : #initialization }
RubSmalltalkEditor >> initialize [
	super initialize.
	notificationStrategy := RubTextInsertionStrategy new editor: self
]

{ #category : #keymapping }
RubSmalltalkEditor >> initializeShortcuts: aKMDispatcher [
	super initializeShortcuts: aKMDispatcher.
	aKMDispatcher attachCategory: RubSmalltalkEditor name
]

{ #category : #'do-its' }
RubSmalltalkEditor >> inspectIt [
	self evaluateSelectionAndDo: [:result | result inspect]
]

{ #category : #'editing keys' }
RubSmalltalkEditor >> inspectIt: aKeyboardEvent [
	"Inspect the selection -- invoked via cmd-i.  If there is no current selection, use the current line.  1/17/96 sw
	 2/29/96 sw: don't call selectLine; it's done by inspectIt now"

	self inspectIt.
	^ true
]

{ #category : #'menu messages' }
RubSmalltalkEditor >> internalCallToBrowse: aSelector [
	"Launch a browser for the class indicated by the given selector. 
	If multiple classes matching the selection exist, let the user choose among them."
	| aClass |
	aClass := self model systemNavigation 
				classFromPattern: aSelector
				withCaption: 'choose a class to browse...'.
	aClass ifNil: [^ self].
	Smalltalk tools browser openOnClass: aClass
]

{ #category : #'menu messages' }
RubSmalltalkEditor >> internalCallToImplementorsOf: aSelector [
	"Open an implementors browser on the given selector"
	
	 (self model systemNavigation allImplementorsOf: aSelector) isEmpty
				ifFalse: [ self model systemNavigation browseAllImplementorsOf: aSelector]
			
	
]

{ #category : #'completion engine' }
RubSmalltalkEditor >> isCompletionEnabled [
	CompletionEngineClass ifNil: [ ^false ].
	CompletionEngineClass isCompletionEnabled ifFalse: [ ^false ].
	^ self editingMode isCompletionEnabled
]

{ #category : #testing }
RubSmalltalkEditor >> isScripting [
	^ self editingMode isScripting
]

{ #category : #testing }
RubSmalltalkEditor >> isSmalltalkEditor [
	^ true 
]

{ #category : #'menu messages' }
RubSmalltalkEditor >> jumpToNextKeywordOfIt [
	"Jump to the next keyword after the cursor - this is for legacy support"

	self jumpToNextKeywordOfIt: true
]

{ #category : #'menu messages' }
RubSmalltalkEditor >> jumpToNextKeywordOfIt: isForwardJump [
	"Jump to the next/previous keyword after the cursor"

	self
		findNextKeywordIn: self textArea string
		selection: self textArea selectionInterval
		searchingForward: isForwardJump
		ifFound: [ :foundIndex | self selectFrom: foundIndex + 1 to: foundIndex ]
]

{ #category : #'typing support' }
RubSmalltalkEditor >> keyDown: aKeyboardEvent [

	self completionAround: [super keyDown: aKeyboardEvent ] keyDown: aKeyboardEvent
	
]

{ #category : #'typing support' }
RubSmalltalkEditor >> keystroke: aKeyboardEvent [

	self completionAround: [super keystroke: aKeyboardEvent ] keyStroke: aKeyboardEvent
	
]

{ #category : #'menu messages' }
RubSmalltalkEditor >> methodCaseSensitiveStringsContainingit [
	"Open a browser on methods which contain the current selection as part of a string constant."

	self lineSelectAndEmptyCheck: [^ self].
	
	self model systemNavigation  browseMethodsWithString: self selection string matchCase: true
]

{ #category : #'menu messages' }
RubSmalltalkEditor >> methodNamesContainingIt [
	"Open a browser on methods names containing the selected string"

	self lineSelectAndEmptyCheck: [ ^ self ].
	Cursor wait
		showWhile: [ self model interactionModel systemNavigation
				browseMethodsWhoseNamesContain: self selection string trimBoth ]
]

{ #category : #'editing keys' }
RubSmalltalkEditor >> methodNamesContainingIt: aKeyboardEvent [
	"Browse methods whose selectors containing the selection in their names"

	self methodNamesContainingIt.
	^ true
]

{ #category : #'menu messages' }
RubSmalltalkEditor >> methodSourceContainingIt [
	"Open a browser on methods which contain the current selection in their source (case-sensitive full-text search of source)."

	self lineSelectAndEmptyCheck: [ ^ self ].
	self model interactionModel systemNavigation
		browseMethodsWithSourceString: self selection string
		matchCase: false
]

{ #category : #'editing keys' }
RubSmalltalkEditor >> methodStringsContainingIt: aKeyboardEvent [
	"Invoked from cmd-E -- open a browser on all methods holding string constants containing it."

	self methodStringsContainingit.
	^ true
]

{ #category : #'menu messages' }
RubSmalltalkEditor >> methodStringsContainingit [
	"Open a browser on methods which contain the current selection as part of a string constant."

	self lineSelectAndEmptyCheck: [ ^ self ].
	self model interactionModel systemNavigation
		browseMethodsWithString: self selection string
		matchCase: false
]

{ #category : #private }
RubSmalltalkEditor >> modelCurrentSelectedClass [
	" ugly dispatch, but current Browser protocol names aren't really cool "
	" for Nautilus ( and other tools), selectedClass sounds better, but I think it shouldn't be hardcoded "
	" IT'S A TEMP SOLUTION -- BenjaminVanRyseghem 14/04/11"

	" From now, all tools should use #selectedBehavior, waiting for a better solution - Thx Nice "
	(self model interactionModel respondsTo: #selectedBehavior)
		ifTrue: [^ self model interactionModel selectedBehavior ].
	
	" old selectors in order of uses "
	(self model respondsTo: #selectedClass)
		ifTrue: [^ self model selectedClass ].
	(self model respondsTo: #selectedClassOrMetaClass)
		ifTrue: [ ^ self model selectedClassOrMetaClass ].
	
		
	^ nil
]

{ #category : #'new selection' }
RubSmalltalkEditor >> nextTokenFrom: start direction: dir [
	"simple token-finder for compiler automated corrections"
	| loc str |
	loc := start + dir.
	str := self string.
	[(loc between: 1 and: str size) and: [(str at: loc) isSeparator]]
		whileTrue: [loc := loc + dir].
	^ loc
]

{ #category : #accessing }
RubSmalltalkEditor >> notificationStrategy [
	^ notificationStrategy
]

{ #category : #accessing }
RubSmalltalkEditor >> notificationStrategy: aStrategy [
	notificationStrategy := aStrategy.
	aStrategy editor: self
]

{ #category : #'new selection' }
RubSmalltalkEditor >> notify: aString at: anInteger in: aStream [ 
	^ self notificationStrategy 
		notify: aString 
		at: anInteger 
		in: aStream 

]

{ #category : #'menu messages' }
RubSmalltalkEditor >> paste [
	"Paste the text from the shared buffer over the current selection and 
	redisplay if necessary.  Undoer & Redoer: undoAndReselect."
	| node character escapedText |
	"This method is specialized for Pharo code.
	If paste happens in the context of a comment or a string, the pasted contents should be properly escaped."
	
	"Get the AST node corresponding to where we are going to paste.
	If there is a selection, cut it off, because pasting it will over-write it, and get the AST node at the cut position.
	This is specially important when the selection spans multiple scopes (e.g., it starts inside a comment and finished in the middle of another)."
	node := self bestNodeInTextAreaWithoutSelection.

	"The pasted text could be inserted in some context requiring escaping, e.g., a comment, a string.
	If so, get the escaping character, and escape the pasted text before pasting it."
	character := self getEscapeCharacterFromAst: node.
	escapedText := (self shouldEscapeCharacter: character)
		  ifTrue: [ self escapeCharacter: character inString: self clipboardText ]
		  ifFalse: [ self clipboardText ].
	
	self replace: self selectionInterval with: escapedText and:
		[self selectAt: self pointIndex]
]

{ #category : #'editing keys' }
RubSmalltalkEditor >> pasteInitials: aKeyboardEvent [ 
	"Replace the current text selection by an authorship name/date stamp; invoked by cmd-shift-v, easy way to put an authorship stamp in the comments of an editor."

	self closeTypeIn.
	self replace: self selectionInterval with: (Text fromString: Author changeStamp) and: [self selectAt: self stopIndex].
	^ true
]

{ #category : #'do-its' }
RubSmalltalkEditor >> printIt [
	"Treat the current text selection as an expression; evaluate it. Insert the 
	description of the result of evaluation after the selection and then make 
	this description the new text selection."

	| printString |
	self
		evaluateSelectionAndDo: [ :result | 
			printString := [ result printString ]
				on: Error
				do: [ '<error in printString: try ''Inspect it'' to debug>' ].
			self afterSelectionInsertAndSelect: printString ]
]

{ #category : #'menu messages' }
RubSmalltalkEditor >> referencesTo: aVariableOrClassName [
	"Open a references browser on the given symbol"
	| env ref |

	" ugly dispatch, but current Browser protocol names aren't really cool "
	env := self modelCurrentSelectedClass ifNil: [ Smalltalk globals ].

	env isBehavior ifTrue: [
		(env hasSlotNamed: aVariableOrClassName) ifTrue: [
		 ^ self systemNavigation browseAllAccessesTo: aVariableOrClassName from: env]].

	ref:= (env bindingOf: aVariableOrClassName) ifNil: [ ^ self ].
	
	self systemNavigation browseAllSendersOf: ref
]

{ #category : #'menu messages' }
RubSmalltalkEditor >> referencesToIt [
	"Open a references browser on the selected symbol"

	| aSymbol |
	"self selectLine."
	(aSymbol := self selectedSymbol) ifNil: [^ textArea flash].

	self referencesTo: aSymbol
]

{ #category : #'editing keys' }
RubSmalltalkEditor >> referencesToIt: aKeyboardEvent [
	"Triggered by Cmd-N; browse references to the current selection"

	self referencesToIt.
	^ true
]

{ #category : #'editing keys' }
RubSmalltalkEditor >> save: aKeyboardEvent [
	"Submit the current text.  Equivalent to 'accept' 1/18/96 sw"

	self closeTypeIn.
	self accept.
	^ true
]

{ #category : #'new selection' }
RubSmalltalkEditor >> selectPrecedingIdentifier [
	"Invisibly select the identifier that ends at the end of the selection, if any."

	| string sep stop tok |
	tok := false.
	string := self string.
	stop := self stopIndex - 1.
	[stop > 0 and: [(string at: stop) isSeparator]] whileTrue: [stop := stop - 1].
	sep := stop.
	[sep > 0 and: [(string at: sep) tokenish]] whileTrue: [tok := true. sep := sep - 1].
	tok ifTrue: [self selectInvisiblyFrom: sep + 1 to: stop]
]

{ #category : #'menu messages' }
RubSmalltalkEditor >> selectedSelector [
	"Try to make a selector out of the current text selection"

	| extractor |
	extractor := CNSelectorExtractor new.
	self hasSelection ifFalse: [ 
		| source ast |

		source := self textArea string.
		ast := self editingMode parseSource: source.

		^ extractor extractSelectorFromAST: ast atPosition: self textArea startIndex
	].

	^ extractor extractSelectorFromSelection: self selection string
]

{ #category : #'menu messages' }
RubSmalltalkEditor >> selectedSymbol [
	"Return the currently selected symbol, or nil if none.  Spaces, tabs and returns are ignored"

	| aString |
	self hasCursor ifTrue: [^self findSelectorFromAST].
	aString := self selection string copyWithoutAll:
		{Character space.  Character cr.  Character tab}.
	aString size = 0 ifTrue: [^ nil].
	Symbol hasInterned: aString ifTrue: [:sym | ^sym].

	^ nil
]

{ #category : #'do-its' }
RubSmalltalkEditor >> selectionForDoitAsStream [
	"Answer a ReadStream on the text in the paragraph that is currently
	selected. "
	^ ReadWriteStream
		on: self string
		from: self startIndex 
		to: self stopIndex - 1
]

{ #category : #accessing }
RubSmalltalkEditor >> selectionPosition: aString [

	| startIndex |
	startIndex := self startIndex.
	^[
		| bottomLeft topLeft index |
		index := startIndex - aString size.
		self selectInvisiblyFrom: index to: index - 1.
		bottomLeft := textArea cursor bottomLeft.
		topLeft := textArea owner positionInWorld.
		topLeft + bottomLeft - textArea offset]
			ensure: [ self selectInvisiblyFrom: startIndex to: startIndex - 1 ]
]

{ #category : #'do-its' }
RubSmalltalkEditor >> selectionString [
	"remove the initial and final quote marks, if present"
	"'''h''' withoutWrappingDoubleQuotes"
	| quote selection  |
	selection :=  self selection string trimBoth .
	selection size < 2 ifTrue: [ ^ selection ].
	quote := selection first.
	^ quote = $"
		ifTrue: [ selection copyFrom: 2 to: selection size - 1 ]
		ifFalse: [ selection ].
]

{ #category : #'menu messages' }
RubSmalltalkEditor >> sendersOf: selectedSelector [
	" opens a Browser on the given selector"
	self model systemNavigation browseAllSendersOf: selectedSelector
]

{ #category : #'menu messages' }
RubSmalltalkEditor >> sendersOfIt [
	"Open a senders browser on the selected selector"

	| selectedSelector syst |
	(selectedSelector := self selectedSelector) ifNil: [ ^ textArea flash ].
	syst := self model interactionModel systemNavigation.
	syst browseAllSendersOrUsersOf: selectedSelector
]

{ #category : #'editing keys' }
RubSmalltalkEditor >> sendersOfIt: aKeyboardEvent [
	"Triggered by Cmd-n; browse implementors of the selector represented by the current selection, if plausible. 2/1/96 sw"

	self sendersOfIt.
	^ true
]

{ #category : #'do-its' }
RubSmalltalkEditor >> tally: aStream [
	"Treat the current selection as an expression; evaluate and tally it."
	| receiver context v compiledMethod profiler |
	(self model respondsTo: #doItReceiver) 
		ifTrue: 
			[receiver := self model doItReceiver.
			context := self model doItContext]
		ifFalse:
			[receiver := context := nil].
	compiledMethod := self compile: aStream for: receiver in: context.
	compiledMethod ifNil: [^ self].
	profiler := TimeProfiler spyOn: [ v:= compiledMethod valueWithReceiver: receiver arguments: #()].
	profiler showResult: v.
	

]

{ #category : #'do-its' }
RubSmalltalkEditor >> tallyHighlight [
	"Treat the current highlight as an expression; evaluate and tally it."
	
	self highlightAndEmptyCheck: [ ^ self ].
	self tally: self highlightedTextAsStream
	

]

{ #category : #'do-its' }
RubSmalltalkEditor >> tallyIt [

	^ self tallySelection
]

{ #category : #'do-its' }
RubSmalltalkEditor >> tallySelection [
	"Treat the current selection as an expression; evaluate and tally it."

	self lineSelectAndEmptyCheck: [ ^ self ].
	self lineSelectAndEmptyCheck: [ ^ self ].
	self tally: self selectionAsStream
	

]

{ #category : #'completion engine' }
RubSmalltalkEditor >> textArea: atextArea [

	atextArea setCompletionEngine: self completionEngine.
	super textArea: atextArea.
]

{ #category : #'menu messages' }
RubSmalltalkEditor >> widenSelectionIn: sourceCode selection: selectionInterval ifFound: selectionBlock [
	"Extend the current highlight selection using knowledge of the AST and cursor location"
	| node start stop comments cursorIndex |
	
	node := self 
		bestNodeInString: sourceCode 
		at: selectionInterval 
		editingMode: self editingMode 
		shouldFavourExpressions: true 
		onError: [ ^nil ].
	
	cursorIndex := selectionInterval last.
	selectionInterval
		ifNotEmpty: [ 
			node parent ifNotNil: [ node := node parent ].
			node isSequence ifTrue: [ node := node parent]].
	
	start := node start.
	stop := node stop max: cursorIndex - 1.
	
	comments := OrderedCollection new.
	RBCommentNodeVisitor visit: node do: [ :cmnts | comments add: cmnts ].

	comments 
		detect: [ :c | c start < cursorIndex and: [ c stop >= cursorIndex ] ] 
		ifFound: [ :c | start := c start. stop := c stop ].
	
	"Handle cascaded messages"
	node isMessage ifTrue: [
		(node isCascaded) 
			ifTrue: [ | i cascadeStart|
				(i := node parent messages indexOf: node) > 1 
					ifTrue: [ 
						cascadeStart := (node parent semicolons at: i - 1).
						cascadeStart < cursorIndex ifTrue: [ start := cascadeStart ]]]
			ifFalse: [
				"Try to select the first chained message send - experimental"
				"self hasSelection ifFalse: [ 
					start := node receiver stop + 1.
					node hasParentheses ifTrue: [stop := stop - 1]]"]].
			
	selectionBlock value: (start to: stop)
]

{ #category : #'menu messages' }
RubSmalltalkEditor >> widenSelectionOfIt [
	"Extend the current highlight selection using knowledge of the AST and cursor location"
	self 
		widenSelectionIn: self textArea string
		selection: self selectionInterval
		ifFound: [ :interval | self selectInterval: interval ]
]
