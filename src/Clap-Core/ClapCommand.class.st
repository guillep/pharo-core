"
I represent a command or subcommand.

Commands are recognized by a keyword, possibly with aliases for convenience. Besides positionals, commands can have flags, as well as nested (sub)commands.

Subcommands work like a trie, to organize and select the various behaviors of a complex program. At each level in a given invocation, at most one subcommand will be recognized, most often as the last parameter of its parent command.


To create a new instance of this class, you must write this:
	ClapCommand withName: <CommandName>
	
And after, if you want to add a flag:
	addFlag: ClapFlag withName: <FlagName>
	
If you want to add a positional:
	addPositional: ClapPositional withName: <PositionalName>
	
If you want to add a subcommand:
	addSubCommand: <subCommand>
	
Example for the eval command: 
	(ClapCommand withName: 'eval')
		addFlag: ClapFlag withName: 'help';
		addPositional: ClapPositionnal withName: 'smalltalk 		expression'.
"
Class {
	#name : #ClapCommand,
	#superclass : #ClapParameterized,
	#instVars : [
		'flags',
		'subcommands'
	],
	#category : #'Clap-Core-Specification'
}

{ #category : #'predefined commands' }
ClapCommand class >> forHelp [
	^ (self id: #helpCommand)
		description: 'Prints command documentation';
		canonicalName: 'help';

		add: ((ClapPositional id: #topic)
			description: 'The subcommand to document (defaults to the current one)';
			meaning: [ :pos :cmd | cmd subcommandNamed: pos word ifNone: nil ];
			implicitMeaning: [ :pos :cmd | cmd ]);

		meaning: [ :match | | doc parent query topic |
			doc := ClapDocumenter on: match context stdout.
			parent := match parent specification.
			query := match at: #topic.
			topic := query value: parent.
			topic
				ifNil: [ match context exitFailure: 'Unknown subcommand: ' , query word ]
				ifNotNil: [ doc explain: topic ] ]

]

{ #category : #adding }
ClapCommand >> addFlag: aFlag [
	flags add: aFlag
]

{ #category : #adding }
ClapCommand >> addSubcommand: aCommand [
	subcommands add: aCommand
]

{ #category : #adding }
ClapCommand >> addTo: parentParameter [
	^ parentParameter addSubcommand: self
]

{ #category : #generated }
ClapCommand >> atName: specName [

	self
		deprecated: 'Use #at: instead'
		transformWith: '`@rec atName: `@arg' -> '`@rec at: `@arg'.
	^ self at: specName
]

{ #category : #'matching - testing' }
ClapCommand >> canMatchWith: word [
	^ self hasAlias: word
]

{ #category : #accessing }
ClapCommand >> flags [
	^ flags
]

{ #category : #initialization }
ClapCommand >> initialize [
	super initialize.
	subcommands := OrderedCollection new.
	flags := OrderedCollection new.
]

{ #category : #enumerating }
ClapCommand >> parametersDo: aBlock [
	super parametersDo: aBlock.
	self flags do: aBlock.
	self subcommands do: aBlock
]

{ #category : #accessing }
ClapCommand >> subcommandNamed: specName ifNone: aBlock [
	^ subcommands
		detect: [ :cmd | cmd hasAlias: specName ]
		ifNone: aBlock
]

{ #category : #accessing }
ClapCommand >> subcommands [
	^ subcommands
]

{ #category : #documenting }
ClapCommand >> synopsisOn: aStream [
	aStream nextPutAll: self canonicalName
]

{ #category : #accessing }
ClapCommand >> valueFor: aMatch with: arg [
	^ aMatch
		matchedSubcommand: [ :sub | sub value: arg ]
		ifNone: [ super valueFor: aMatch with: arg ]
]
