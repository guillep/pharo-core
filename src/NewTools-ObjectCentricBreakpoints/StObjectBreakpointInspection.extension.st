Extension { #name : #StObjectBreakpointInspection }

{ #category : #'*NewTools-ObjectCentricBreakpoints' }
StObjectBreakpointInspection class >> browseBreakpointMethodCommandFor: presenter [

	^ ((SpBrowseClassCommand forContext: presenter)
		selector: #doBrowseBreakpointMethod;
			asSpecCommand)
			name: 'Browse method';
			yourself
]

{ #category : #'*NewTools-ObjectCentricBreakpoints' }
StObjectBreakpointInspection class >> objectCentricCommandsWith: presenter forRootGroup: aCmCommandsGroup [
	<extensionCommands>
	
	aCmCommandsGroup
		register: (self removeBreakpointCommandFor: presenter);
		register: (self browseBreakpointMethodCommandFor: presenter)
]

{ #category : #'*NewTools-ObjectCentricBreakpoints' }
StObjectBreakpointInspection class >> removeBreakpointCommandFor: presenter [
	| cmd |
	cmd := StRemoveBreakpointCommand forSpecContext: presenter.
	cmd iconName: #smallDelete.
	cmd innerCommand
		transform: [ :ctx | ctx methodsWithBreakpoints selection selectedItem ].
	^ cmd
]
