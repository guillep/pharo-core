Class {
	#name : #BaselineOfNewTools,
	#superclass : #BaselineOf,
	#instVars : [
		'initializersEnabled'
	],
	#category : #BaselineOfNewTools
}

{ #category : #accessing }
BaselineOfNewTools class >> releaseCommit [
	"The commit corresponding to current release (to be used on bootstrap process)"
	
	^ 'f35f3f62fea0d4334863a3687ab6d602858f5b65'
]

{ #category : #baselines }
BaselineOfNewTools >> baseline: spec [
	<baseline>

	spec for: #common do: [
		spec preLoadDoIt: #'preload:package:'.
		spec postLoadDoIt: #'postload:package:'.

		"self spec: spec."
		self sindarin: spec.

		spec
			package: 'NewTools-Core';
			package: 'NewTools-Morphic';
			package: 'NewTools-Gtk';
			"Basic tools (inherited from Spec)"
			package: 'NewTools-MethodBrowsers';
			package: 'NewTools-ChangeSorter';
			package: 'NewTools-KeymapBrowser';
			"inspector"
			package: 'NewTools-Inspector' with: [ spec requires: #('NewTools-Inspector-Extensions') ];
			package: 'NewTools-Inspector-Extensions' with: [ spec requires: #('NewTools-Core') ];
			"debugger"
			package: 'NewTools-Debugger' with: [ spec requires: #('NewTools-Inspector' 'NewTools-Debugger-Commands' 'NewTools-Debugger-Extensions' 'NewTools-SpTextPresenterDecorators') ];			
			package: 'NewTools-Debugger-Commands';
			package: 'NewTools-Debugger-Extensions';
			package: 'NewTools-Debugger-Tests' with: [ spec requires: #('NewTools-Debugger') ];
			"playground"
			package: 'NewTools-Playground' with: [ spec requires: #('NewTools-Inspector') ];
			"spotter"
			package: 'NewTools-Spotter' with: [ spec requires: #('NewTools-Core') ];
			package: 'NewTools-Morphic-Spotter' with: [ spec requires: #('NewTools-Morphic') ];
			"browser"
			package: 'NewTools-SystemBrowser' with: [ spec requires: #('NewTools-Inspector') ];
			"system reporter"
			package: 'NewTools-SystemReporter' with: [ spec requires: #('NewTools-Core') ];
			"spotter"
			package: 'NewTools-Spotter-Processors';
			package: 'NewTools-Spotter' with: [ spec requires: #('NewTools-Core' 'NewTools-Spotter-Processors') ];
			package: 'NewTools-Spotter-Extensions' with: [ spec requires: #('NewTools-Spotter') ];
			package: 'NewTools-Spotter-Processors-Tests' with: [ spec requires: #('NewTools-Spotter-Processors') ];
			package: 'NewTools-Morphic-Spotter' with: [ spec requires: #('NewTools-Morphic') ];
			"extras"
			package: 'HelpCenter' with: [ spec requires: #('NewTools-Core') ];
			package: 'NewTools-FlagBrowser' with: [ spec requires: #('NewTools-Core') ];
			package: 'NewTools-FlagBrowser-Tests' with: [ spec requires: #('NewTools-FlagBrowser') ];
			package: 'NewTools-FileDialog' with: [ spec requires: #('NewTools-Core') ];
			package: 'NewTools-FileDialog-Tests' with: [ spec requires: #('NewTools-FileDialog') ];
			package: 'NewTools-SpTextPresenterDecorators';
			package: 'NewTools-Debugger-Breakpoints-Tools' with: [ spec requires: #('NewTools-Inspector') ];
			package: 'NewTools-ProjectLoader';
			package: 'NewTools-ProjectLoader-Microdown';
			"Object-centric breakpoints"
			package: 'NewTools-ObjectCentricBreakpoints';			
			"Sindarin"
			package: 'NewTools-Sindarin-Commands';
			package: 'NewTools-Sindarin-Commands-Tests' with: [  spec requires: #('NewTools-Sindarin-Commands' 'Sindarin') ];
			package: 'NewTools-Sindarin-Tools' with: [ spec requires: #('NewTools-Sindarin-Commands' 'Sindarin') ];
			"package: 'NewTools-Sindarin-ProcessInspector' with: [ spec requires: #('NewTools-Sindarin-Commands' 'Sindarin') ];"
			"Debugger Selector"
			package: 'NewTools-DebuggerSelector' with: [ spec requires: #('NewTools-SpTextPresenterDecorators') ];
			package: 'NewTools-DebuggerSelector-Tests' with: [ spec requires: #('NewTools-DebuggerSelector') ];
			package: 'NewTools-Debugger-Fuel'.

		spec
			group: 'Core' with: #('NewTools-Core' 'NewTools-Morphic');
			group: 'Playground' with: #('Core' 'NewTools-Playground');
			group: 'Inspector' with: #('Core' 'NewTools-Inspector');
			group: 'Debugger' with: #(
				'Core' 
				'Inspector' 
				'NewTools-Debugger-Commands'
				'NewTools-Debugger-Extensions'
				'NewTools-Debugger' 
				'NewTools-ObjectCentricBreakpoints'
				'NewTools-Sindarin-Tools'
				'NewTools-Sindarin-Commands'
				'NewTools-Sindarin-Commands-Tests'
				'NewTools-Debugger-Breakpoints-Tools'
				'NewTools-Debugger-Tests'
				'NewTools-Debugger-Fuel');
			group: 'Spotter' with: #(
				'NewTools-Morphic-Spotter' 
				'NewTools-Spotter-Processors' 
				'NewTools-Spotter' 
				'NewTools-Spotter-Extensions'
				'NewTools-Spotter-Processors-Tests');
			group: 'SystemReporter' with: #('Core' 'NewTools-SystemReporter');
			group: 'Methods' with: #('Core' 'NewTools-MethodBrowsers');
			"Not in the image for the moment, we need a pass on them"
			group: 'ChangeSorter' with: #('Core' 'NewTools-ChangeSorter');
			group: 'KeymapBrowser' with: #('Core' 'NewTools-KeymapBrowser');
			group: 'FlagBrowser' with: #(
				'Core' 
				'NewTools-FlagBrowser' 
				'NewTools-FlagBrowser-Tests');
			group: #development with: #('default'
				'NewTools-DebuggerSelector' 
				'NewTools-DebuggerSelector-Tests');
			group: #broken with: #(
				'NewTools-FileDialog' 
				'NewTools-FileDialog-Tests');
			group: 'default' with: #(
				'Core'
				'Playground'
				'Inspector'
				'Debugger'
				'Methods'
				'Spotter'
				"'ChangeSorter'"
				"'KeymapBrowser'"
				"'FlagBrowser'").
			"A group for running CI"
			"spec group: 'CI' with: #('Spec2' 'default')" ]
]

{ #category : #dependencies }
BaselineOfNewTools >> packageRepositoryURL [
	| url |
	
	url := super packageRepositoryURL.
	url ifEmpty: [ ^ url ].
	
	"Verify if I am running in CI"
	(url includesSubstring: 'pharo-spec') ifTrue: [ ^ '' ].
	
	^ url
]

{ #category : #actions }
BaselineOfNewTools >> postload: loader package: packageSpec [

	MCMethodDefinition initializersEnabled: initializersEnabled
]

{ #category : #actions }
BaselineOfNewTools >> preload: loader package: packageSpec [

	initializersEnabled := MCMethodDefinition initializersEnabled.
	MCMethodDefinition initializersEnabled: true
]

{ #category : #dependencies }
BaselineOfNewTools >> sindarin: spec [

	spec baseline: 'Sindarin' with: [ 
		spec
			repository: (self packageRepositoryURL 
				ifEmpty: [ 'github://pharo-spec/ScriptableDebugger' ]);
			loads: 'Core' ]
]

{ #category : #dependencies }
BaselineOfNewTools >> spec: spec [ 

	spec baseline: 'Spec2' with: [ 
		spec repository: 'github://pharo-spec/Spec' ]
]
