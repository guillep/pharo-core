Extension { #name : #SymbolicBytecode }

{ #category : #'*OpalCompiler-Tools' }
SymbolicBytecode >> gtInspectorSourceCodeIn: composite [
	<gtInspectorPresentationOrder: 30> 

	^ composite pharoMethod 
		title: 'Source';
		display: [ self method sourceCode ];
		smalltalkClass: [ self method methodClass ]; 
		initialize: [ :presentation | 
			presentation selectionInterval: self sourceInterval ];
		act: [ self method compiledMethod browse ] icon: GLMUIThemeExtraIcons glamorousBrowse entitled: 'Browse'
]

{ #category : #'*OpalCompiler-Tools' }
SymbolicBytecode >> gtInspectorTreeIn: composite [
	<gtInspectorPresentationOrder: 30> 
	^composite tree
		rootsExpanded;
		title: 'SourceNode';
		display: [ :anObject | {anObject sourceNode} ];
		children: [ :each | each children ];
		selectionPopulate: #selectedNode
			on: $o
			entitled: 'Open'
			with: [ :tree | tree selection ];
		format: [ :each | each printString ]
]

{ #category : #'*OpalCompiler-Tools' }
SymbolicBytecode >> gtSpotterCodePreviewIn: aComposite [
	<spotterPreview: 1>
	^ (aComposite pharoMethod
			title: [ self displayString ]; 
			display: [ :entity | self method sourceCode ];
			smalltalkClass: [ self method methodClass ];
			selectionInterval: [ self sourceInterval ];
			entity: self) 
]

{ #category : #'*OpalCompiler-Tools' }
SymbolicBytecode >> spotterActDefault [
	self method compiledMethod browse
]
