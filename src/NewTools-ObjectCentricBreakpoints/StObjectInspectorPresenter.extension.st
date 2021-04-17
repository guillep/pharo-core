Extension { #name : #StObjectInspectorPresenter }

{ #category : #'*NewTools-ObjectCentricBreakpoints' }
StObjectInspectorPresenter >> haltInspectedObjectOnReadAccess [
	^self inspectedObject haltOnRead
]

{ #category : #'*NewTools-ObjectCentricBreakpoints' }
StObjectInspectorPresenter >> haltInspectedObjectOnStateAccess [
	^ self inspectedObject haltOnAccess 
]

{ #category : #'*NewTools-ObjectCentricBreakpoints' }
StObjectInspectorPresenter >> haltInspectedObjectOnWriteAccess [
	^ self inspectedObject haltOnWrite
]

{ #category : #'*NewTools-ObjectCentricBreakpoints' }
StObjectInspectorPresenter class >> objectCentricBreakpointCommandsWith: aPresenter forRootGroup: aRootCommandsGroup [
	<extensionCommands>
	
	aRootCommandsGroup 
		register: (CmCommandGroup forSpec
			beToolbarPopoverButton;
			name: 'Halt';
			icon: (aPresenter application iconNamed: #smallObjects);
			register: (StHaltOnReadCommand forSpec);
			register: (StHaltOnWriteCommand forSpec);
			register: (StHaltOnStateAccessCommand forSpec);
			yourself)
]
