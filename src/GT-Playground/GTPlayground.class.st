"
Playground is the correspondent of a classic Smalltalk Workspace. The problem with the name Workspace is that it implies that work should be carried out in this space, while this is not a best practice. Playground describes better the intention of providing a place in which we can quickly play with some code.

The model behind a Playground instance is a PlayPage object.

!!Use cases
The Playground can be used in two ways

# As a place to construct and try out code snippets.
# as an entry point into an inspection process.

In both cases, the ability of diving into objects to the right is an important feature.

!!Running
[ [ [ 
	self open.
 ] ] ]
"
Class {
	#name : #GTPlayground,
	#superclass : #GLMCompositePresentation,
	#classVars : [
		'GTPlaygroundEnabledStatus',
		'PreferredExtent',
		'RememberPreferredExtent'
	],
	#category : #'GT-Playground'
}

{ #category : #menu }
GTPlayground class >> contextMenuBasicActionsFor: aPlayground [
	<playgroundContextMenu>
	
	^ aPlayground codePresentation defaultSelectionActions 
]

{ #category : #'compatibility-tools' }
GTPlayground class >> edit: aString label: aLabel [

"Open a new playground with the given contents"
"Compatibility with the original Workspace"
"#edit: aText label: labelString accept: anAction"
"	^(Smalltalk tools workspace openLabel: labelString)
		acceptContents:  aText;
		acceptAction: anAction;
		yourself."

"Open an editor on the given string/text"
	| page |
	"self halt"

	page := GTPlayPage new
		saveContent: aString;
		title: aLabel;
		yourself.
		
	self flag: #TODO. "We need to put an equivalent to the acceptAction thing."
	^ self new openOn: page
]

{ #category : #examples }
GTPlayground class >> examplePlaygroundWithBindings [
	| playground wsBindings |
	wsBindings := Dictionary newFrom: { #number-> 1 }.
	playground := Smalltalk tools workspace
		openContents: 'number + 1'.
	playground
		setBindings: wsBindings.
]

{ #category : #settings }
GTPlayground class >> extentSettingsOn: aBuilder [ 
	<systemsettings>
	
	(aBuilder setting: #GTPlaygroundPreferredWidth)
		target: self;
		parent: #gt;
		getSelector: #preferredWidth;
		setSelector: #preferredWidth:;
		default: 600; 
		label: 'Playground width';
		description: 'The preferred width of new Playground windows'.
	(aBuilder setting: #GTPlaygroundPreferredHeight)
		target: self;
		parent: #gt;
		getSelector: #preferredHeight;
		setSelector: #preferredHeight:; 
		default: 400;
		label: 'Playground height';
		description: 'The preferred height of new Playground windows'.
	(aBuilder setting: #GTPlaygroundRememberPreferredExtent)
		target: self;
		parent: #gt;
		getSelector: #rememberPreferredExtent;
		setSelector: #rememberPreferredExtent:; 
		label: 'Remember extent of Playground';
		default: true;
		description: 'Enable or disable remembering of the extent of Playground windows on resize. When the preference is true, resizing a Playground window will affect the preferred width and height of future Playground windows'.
	



]

{ #category : #settings }
GTPlayground class >> isGTPlaygroundEnabled [

	^ GTPlaygroundEnabledStatus ifNil: [ GTPlaygroundEnabledStatus := Smalltalk tools workspace = self ]
]

{ #category : #'world menu' }
GTPlayground class >> menuCommandOn: aBuilder [
	<worldMenu>
	(aBuilder item: #Playground)
		parent: #InputOutput;
		action: [ Smalltalk tools openWorkspace ];
		order: 1;
		keyText: 'o, w';
		help: 'A window used as a scratchpad area where fragments of Pharo code can be entered, stored, edited, and evaluated.';
		icon: (self iconNamed: #workspaceIcon)
]

{ #category : #'instance creation' }
GTPlayground class >> open [
	"self open"
	| page |
	page := GTPlayPage new.
	^ self openOn: page
]

{ #category : #'instance creation' }
GTPlayground class >> openContents: aString [
	"Open a new playground with the given contents. aString has to be Smalltalk code. The style is applied"
	

	| page |
	
	page := GTPlayPage new
		saveContent: aString;
		yourself.
	^ self new 
		openOn: page;
		yourself
]

{ #category : #'instance creation' }
GTPlayground class >> openContents: aString label: aLabel [
	"Open a new playground with the given contents"

	| page |

	page := GTPlayPage new
		saveContent: aString;
		title: aLabel;
		yourself.
	^ self openOn: page
]

{ #category : #'compatibility-tools' }
GTPlayground class >> openLabel: aLabel [
	| page |

	page := GTPlayPage new
		title: aLabel;
		yourself.
	^ self openOn: page
]

{ #category : #'instance creation' }
GTPlayground class >> openUrl: urlOrString [
	"Open a new Playground with the contents of a text/plain web resource at urlOrString,
	like the one you get from remote publishing a Playground as a Shared Smalltalk Workspace. 
	See http://ws.stfx.eu - a Pastebin for Smalltalk - https://en.wikipedia.org/wiki/Pastebin"
	
	"self openUrl: 'http://ws.stfx.eu/1WS4U'"
	
	| page |
	page := GTPlayPage basicLoadFromPublishUrl: urlOrString asUrl.
	page title: urlOrString asUrl printString.
	^ self openOn: page
]

{ #category : #settings }
GTPlayground class >> preferredExtent [
	^ PreferredExtent ifNil: [ PreferredExtent := 600@400 ]
]

{ #category : #settings }
GTPlayground class >> preferredExtent: aPoint [
	PreferredExtent := aPoint
]

{ #category : #settings }
GTPlayground class >> preferredHeight [
	^ self preferredExtent y
]

{ #category : #settings }
GTPlayground class >> preferredHeight: aHeight [
	self preferredExtent setX: self preferredExtent x setY: aHeight
]

{ #category : #settings }
GTPlayground class >> preferredWidth [
	^ self preferredExtent x
]

{ #category : #settings }
GTPlayground class >> preferredWidth: aWidth [
	self preferredExtent setX: aWidth setY: self preferredExtent y
]

{ #category : #'tools registry' }
GTPlayground class >> register [

	Smalltalk tools register: self as: #workspace
]

{ #category : #'tools registry' }
GTPlayground class >> registerToolsOn: registry [
	"Add ourselves to registry. See [Smalltalk tools]"
	"IMPORTANT: This method is disabled because the bootstrap process initializes tools by traversing
	 all classes implementing this method in alphabetical order. Since GTPlayground is not anymore the 
	 default playground, we disable its auto-registration in that step. 
	 Notice that the #register method still works if needed"
	
	"self registerToolsOn: Smalltalk tools" 
	"registry register: self as: #workspace"

]

{ #category : #settings }
GTPlayground class >> rememberPreferredExtent [
	^ RememberPreferredExtent ifNil: [ RememberPreferredExtent := true ]
]

{ #category : #settings }
GTPlayground class >> rememberPreferredExtent: aBoolean [
	^ RememberPreferredExtent := aBoolean
]

{ #category : #settings }
GTPlayground class >> setGTPlaygroundEnabledStatus: aBoolean [
	| oldStatus |
	
	oldStatus := self isGTPlaygroundEnabled.
	GTPlaygroundEnabledStatus := aBoolean.
	oldStatus ~= GTPlaygroundEnabledStatus ifTrue: [ 
		GTPlaygroundEnabledStatus 
			ifTrue: [ self register ]
			ifFalse: [ Workspace registerToolsOn: Smalltalk tools ] ]
	
	
]

{ #category : #settings }
GTPlayground class >> setPreferredExtentIfWanted: anExtent [
	self rememberPreferredExtent ifTrue: [ 
		self preferredExtent: anExtent ]
]

{ #category : #settings }
GTPlayground class >> settingsOn: aBuilder [ 
	<systemsettings>
	
	(aBuilder setting: #GTPlaygroundStatus)
		target: self;
		parent: #gt;
		getSelector: #isGTPlaygroundEnabled;
		setSelector: #setGTPlaygroundEnabledStatus:; 
		label: 'GTPlayground';
		default: false;
		description: 'Enable or disable the GTPlayground.'.
	(aBuilder setting: #cacheDirectory)
		parent: #gt;
		type: #Directory;
		default: GTPlayBook defaultCacheDirectory;
		target: GTPlayBook;
		description: 'The path to the local Playground cache that stores all Playground scripts in ph files';
		label: 'Local Playground cache directory'.
	(aBuilder setting: #stashDirectory)
		parent: #gt;
		type: #Directory;
		default: (FileLocator localDirectory / 'play-cache') resolve;
		target: GTPlayBook;
		description: 'The path to the local Playground stash that stores all named Playground scripts in ph files';
		label: 'Local Playground stash directory'
]

{ #category : #'tools registry' }
GTPlayground class >> taskbarIconName [
	"Answer the icon for the receiver in a task bar."

	^ #workspaceIcon
]

{ #category : #'instance creation' }
GTPlayground class >> title [
	^ 'Playground'
]

{ #category : #accessing }
GTPlayground >> acceptAction: anAction [
	"acceptAction := anAction."
]

{ #category : #accessing }
GTPlayground >> acceptContents: aString [

	^ (self entity acceptContents: aString)
		ifTrue: [  
			self update.
			true]
]

{ #category : #actions }
GTPlayground >> actOnBrowserClosing: ann [

	"This is a hack for the moment.
	We need a better mechanism from Glamour to help 
	us keep the model in sync"
	self entity
		saveContent: self first panes first presentations first text.
	GTPlayBook instance addPageIfInteresting: self entity
]

{ #category : #building }
GTPlayground >> codeIn: a [
	^ (self codePresentationIn: a)
		title: [ :page | 
			GTPlaygroundEditableTabLabel new
				text: page title;
				when: #accepted
					do: [ :text | page setTitleAndEnsureInStash: text asString ];
				yourself ];
		format: [ :page | page content ];
		act: [ :text :page | 
				text selectionInterval: (1 to: text text size).
				text highlightEvaluateAndDo: [ :result | text selection: result ] ]
			icon: GLMUIThemeExtraIcons glamorousGo
			on: $G
			entitled: 'Do it all and go';
		act: [ :text :page | page publish ]
			iconName: #glamorousSaveToUrl
			entitled: 'Remote publish';
		addAction:
			(GLMPopupAction new
				action: [ :text :page :popup | 
					GTPlaygroundBindingsList new
						on: self currentBindingsSorted;
						when: #bindingRemoved
							do: [ :binding | self removeBinding: binding ];
						when: #inspect do: [ :binding | binding value inspect ];
						when: #go do: [ :binding | text selection: binding value ];
						yourself ];
				iconName: #glamorousTable;
				title: 'Bindings';
				yourself);
		addAction:
			(GLMPopupAction new
				action: [ :text :page :popup | 
					GTPlaygroundPlayPagesList new
						on: GTPlayBook instance;
						when: #pageAccepted
							do: [ :playPage | 
							text entity saveContent: playPage content.
							text update ];
						yourself ];
				iconName: #glamorousMore;
				title: 'Play pages';
				yourself);
		with: [ :presentation | self pageActionsIn: presentation ];
		dynamicActionsOnSelection: [ self contextMenuActions ];
		onChangeOfPort: #text
			act: [ :text :page | 
			page saveContent: text text.
			text clearUserEdits ]
]

{ #category : #'accessing-dynamic' }
GTPlayground >> codePresentation [

	^ self inspectorPresentation firstPresentation
]

{ #category : #building }
GTPlayground >> codePresentationIn: composite [

	^ composite pharoScript
]

{ #category : #building }
GTPlayground >> compose [
	self title: self defaultPlaygroundTitle.
	self titleIcon: self playgroundIcon.
	self act: [:b | b update] icon: GLMUIThemeExtraIcons glamorousRefresh entitled: 'Update'.
		
	self act: [ :b | 
			SettingBrowser new 
				changePackageSet: { (RPackageOrganizer default packageNamed: 'GT-Playground') }; 
				open; 
				expandAll ] 
		icon: (Smalltalk ui icons iconNamed: #smallCogInitialState)
		entitled: 'Global Setting'.
		
	self custom:
			(GTInspector new
				noTitle; 
				noActions;
				wantsAutomaticRefresh: true;
				showFirst: [ :composite |
					self codeIn: composite ];
				yourself);
		when: GLMBrowserClosing do: [ :ann |
			self actOnBrowserClosing: ann ].
	
	GTInspector isStepRefreshEnabled ifTrue: [
		self wantsAutomaticRefresh: true.
		self wantsSteps: true.
		self stepTime: GTInspector stepRefreshRate ].
	
	self playgroundActionsIn: self.
]

{ #category : #'building actions' }
GTPlayground >> contextMenuActions [
	^ (Pragma
		allNamed: self contextMenuPragma
		from: self class class
		to: Object class)
		flatCollect:
			[ :eachPragma | self class perform: eachPragma methodSelector with: self ]
]

{ #category : #accessing }
GTPlayground >> contextMenuPragma [

	^ #playgroundContextMenu
]

{ #category : #'accessing-dynamic' }
GTPlayground >> currentBindings [ 

	^ self codePresentation currentBindings
]

{ #category : #'accessing-dynamic' }
GTPlayground >> currentBindingsSorted [

	^ self currentBindings associations asSortedCollection: [ :first :second | first key < second key ]
]

{ #category : #'accessing-defaults' }
GTPlayground >> defaultPlaygroundTitle [
	^ 'Playground'
]

{ #category : #'accessing-dynamic' }
GTPlayground >> inspectorPresentation [

	^ self presentations first 
]

{ #category : #accessing }
GTPlayground >> label: aString [
	"Set the window label to the given string"
	self title: aString.
	self update
]

{ #category : #'scripting opening' }
GTPlayground >> openOn: aPage [
	| window |
	window := super openOn: aPage.
	window extent: self class preferredExtent.
	window when: WindowResizing do: [ 
		(window isMinimized or: [ window isMaximized ]) ifFalse: [ 
			"we only wnat to react to real resizing,
			not to minization or maximization"
			self class setPreferredExtentIfWanted: window extent ] ].
	^ window
]

{ #category : #accessing }
GTPlayground >> pageActionPragma [
	^ #pageActionOrder:
]

{ #category : #'building actions' }
GTPlayground >> pageActions [
	^ (Pragma
		allNamed: self pageActionPragma
		from: self class
		to: Object
		sortedByArgument: 1)
		collect:
			[ :eachPragma | self perform: eachPragma methodSelector ]
]

{ #category : #'building actions' }
GTPlayground >> pageActionsIn: aGLMPharoScriptPresentation [ 
	"Build Page actions that appears next to the page title."
	self pageActions do: [ :eachAction | 
		aGLMPharoScriptPresentation addAction: eachAction ]
]

{ #category : #accessing }
GTPlayground >> playgroundActionPragma [
	^ #playgroundActionOrder:
]

{ #category : #'building actions' }
GTPlayground >> playgroundActions [
	^ (Pragma
		allNamed: self playgroundActionPragma
		from: self class
		to: Object
		sortedByArgument: 1)
		collect:
			[ :eachPragma | self perform: eachPragma methodSelector ]
]

{ #category : #'building actions' }
GTPlayground >> playgroundActionsIn: aGTPlayground [ 
	"Build Playground actions that appears on the title bar."
	self playgroundActions do: [ :eachAction | 
		aGTPlayground addAction: eachAction ]
]

{ #category : #accessing }
GTPlayground >> playgroundIcon [
	
	^ self iconNamed: #workspace
]

{ #category : #'accessing-dynamic' }
GTPlayground >> removeBinding: anAssociation [

	|bindings|
	bindings := self currentBindings copy.
	bindings removeKey: anAssociation key ifAbsent: [ ].
	self setBindings: bindings.
]

{ #category : #updating }
GTPlayground >> requestRefresh [
	self inspectorPresentation refreshPanes
]

{ #category : #actions }
GTPlayground >> resetBindings [

	^ self inspectorPresentation firstPresentation resetBindings
]

{ #category : #actions }
GTPlayground >> setBindings: aDictionary [

	self inspectorPresentation firstPresentation 
		variableBindings: [ aDictionary associations ];
		updateVariableBindings
]

{ #category : #stepping }
GTPlayground >> step [
	self window ifNil: [ ^ self ].
	self window isActive ifFalse: [ ^ self ].
	
	self wantsAutomaticRefresh ifTrue: [
		self requestRefresh ]
]
