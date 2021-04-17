"
A GLMTransmission models the connection between multiple origin ports and one destination port. Whenever an origin port changes the value, the corresponding transmissions are triggered by the browser.

The result of triggering a transmission is the setting of the value in the destination port. The transmissionStrategy can add further different semantics to this behavior.

A transmission takes place in a context. The context is started every time a new value is set from outside. Afterwards, the context is preserved internally. This is important for braking possible loops of transmission propagation.

There are two kind of origins for a transmission, active and passive ones. A change of value in an active origin will trigger the transmissions originating from it. A change of value in a passive origin will not trigger the transmission. However, a value in a passive origin is still part of the transmission value.
"
Class {
	#name : #GLMTransmission,
	#superclass : #GLMLoggedObject,
	#instVars : [
		'context',
		'destination',
		'browser',
		'origins',
		'transmissionStrategy',
		'transformation',
		'condition'
	],
	#category : #'Glamour-Core'
}

{ #category : #accessing }
GLMTransmission >> activeOrigins [ 
	 
	^(self originReferences select: [:each | each isActive]) 
		collect: [:each | each port]
]

{ #category : #accessing }
GLMTransmission >> addActiveOrigin: aPort [ 
	^ self originReferences 
		add: 
			((GLMOriginPortReference new) 
				port: aPort; 
				beActive; 
				yourself)
]

{ #category : #accessing }
GLMTransmission >> addPassiveOrigin: aPort [
	^ self originReferences 
		add: 
			((GLMOriginPortReference new) 
				port: aPort; 
				bePassive; 
				yourself)
]

{ #category : #accessing }
GLMTransmission >> addPresentation: aPresentation [
	self transmissionStrategy addPresentation: aPresentation
]

{ #category : #accessing }
GLMTransmission >> addPresentations: aCollection [
	self transmissionStrategy addPresentations: aCollection
]

{ #category : #scripting }
GLMTransmission >> andShow: aBlock [
	"This method accepts a block with one argument.
	The block will be evaluated with an instance of GLMCompositePresentation.
	
	The block should construct the presentations that go in the composite presentation.
	The composite presentation will be the one that will get installed in the target pane
	once the transmission triggers.

	This method is meant to be used in a Glamour script.
	"
	
	self ensureReplacePresentationsStrategy.
	self transmissionStrategy presentationsFactory: aBlock.
	self origins isEmpty
		ifTrue: [ self from: #outer port: #entity ]
]

{ #category : #scripting }
GLMTransmission >> andShowIfNone: aBlock [
	"This method accepts a block with one argument. 
	The block will be evaluated with an instance of GLMCompositePresentation.
	
	The block should construct the presentations that go in the composite presentation.
	The composite presentation will be the one that will get installed in the target pane
	once the transmission triggers.
	
	The particularity of this method is that the presentation will get installed in the target
	pane only if the target pane has no presentation already.

	This method is meant to be used in a Glamour script.
	"

	self ensurePresentIfNoneStrategy.
	self transmissionStrategy presentationsFactory: aBlock.
	self origins isEmpty
		ifTrue: [ self from: #outer port: #entity ]
]

{ #category : #accessing }
GLMTransmission >> browser [
	^ browser
]

{ #category : #accessing }
GLMTransmission >> browser: anObject [
	browser := anObject
]

{ #category : #copying }
GLMTransmission >> changePortsAccordingToPaneMapping: newPanesMapping [
	"newPanesMapping is a dictionary with 
	keys given by old panes and values by new panes"
	self destination: ((newPanesMapping at: self destination pane) port: self destination name).

]

{ #category : #copying }
GLMTransmission >> changePortsAccordingToPaneMapping: newPanesMapping fromOldBrowser: aBrowser toNewBrowser: anotherBrowser [
	| newPort |
	"newPanesMapping is a dictionary with 
	keys given by old panes and values by new panes"
	self destination: (self destination copyAccordingToPaneMapping: newPanesMapping inNewBrowser: anotherBrowser).
	self originReferences do: [:each | 
		newPort := each port copyAccordingToPaneMapping: newPanesMapping inNewBrowser: anotherBrowser.
		each port: newPort ]
]

{ #category : #accessing }
GLMTransmission >> condition [
	^ condition
]

{ #category : #accessing }
GLMTransmission >> condition: anObject [
	condition := anObject
]

{ #category : #transmitting }
GLMTransmission >> context [
	 context ifNil: [context := OrderedCollection new].
	^context
]

{ #category : #transmitting }
GLMTransmission >> context: aContext [
	 context := aContext
]

{ #category : #accessing }
GLMTransmission >> destination [ 
	 
	^destination
]

{ #category : #accessing }
GLMTransmission >> destination: aPort [ 
	 
	destination := aPort
]

{ #category : #printing }
GLMTransmission >> displayStringOn: stream [
	self origins asArray displayStringOn: stream.
	stream nextPutAll: '->'.
	self destination displayStringOn: stream
]

{ #category : #accessing }
GLMTransmission >> ensurePresentIfNoneStrategy [
	self transmissionStrategy class = GLMPresentIfNoneStrategy ifFalse: [
		self transmissionStrategy: (GLMPresentIfNoneStrategy of: self) ]
]

{ #category : #accessing }
GLMTransmission >> ensureReplacePresentationsStrategy [
	self transmissionStrategy class = GLMReplacePresentationsStrategy ifFalse: [
		self transmissionStrategy: (GLMReplacePresentationsStrategy of: self) ]
]

{ #category : #scripting }
GLMTransmission >> from: aPort [
	"Ideally this method would be implemented as
	^ self from: aPaneSymbol port: #selection.
	
	The problem is that beforehand we only had from: which could receive either a symbol for the pane, or an association for the port. This was bad, and now Glamour offers from:port:, but there are still legacy cases of from: being called with an association."

	^ self addActiveOrigin: (self browser resolveOriginPort: aPort)
]

{ #category : #scripting }
GLMTransmission >> from: aPaneSymbol port: aPortSymbol [
	^ self from: (GLMPortIdentifier pane: aPaneSymbol port: aPortSymbol)
]

{ #category : #scripting }
GLMTransmission >> from: aPaneSymbol port: aPortSymbol transformed: aBlock [
	^ (self from: (GLMPortIdentifier pane: aPaneSymbol port: aPortSymbol)) transformation: aBlock
]

{ #category : #scripting }
GLMTransmission >> from: aPort transformed: aBlock [
	^ (self addActiveOrigin: (self browser resolveOriginPort: aPort)) transformation: aBlock
]

{ #category : #scripting }
GLMTransmission >> fromOutside: aPortSymbol [
	self 
		deprecated: 'Use fromOutsidePort: instead' 
		transformWith: '`@rec fromOutside: `@aPortSymbol' -> '`@rec fromOutsidePort: `@aPortSymbol'.
	^ self fromOutsidePort: aPortSymbol 
]

{ #category : #scripting }
GLMTransmission >> fromOutsideEntityPort [
	^ self fromOutsidePort: #entity
]

{ #category : #scripting }
GLMTransmission >> fromOutsideEntityPortTransformed: aBlock [
	^ self fromOutsidePort: #entity transformed: aBlock
]

{ #category : #scripting }
GLMTransmission >> fromOutsidePort: aPortSymbol [
	^ self from: #outer port: aPortSymbol
]

{ #category : #scripting }
GLMTransmission >> fromOutsidePort: aPortSymbol transformed: aBlock [
	^ self from: #outer port: aPortSymbol transformed: aBlock
]

{ #category : #initialization }
GLMTransmission >> initialize [
	super initialize.
	transmissionStrategy := GLMNoStrategy new.
	condition := true
]

{ #category : #testing }
GLMTransmission >> meetsCondition [
	<debuggingStone: #transmissionCondition label: 'Transmission condition'>
	| originValues |
	originValues := self originReferences size = 1 
		ifTrue: [ self originReferences first value ] 
		ifFalse: [ GLMMultiValue withAll: (self originReferences collect: [:each | each value]) ].
	^ self condition glamourValue: originValues
]

{ #category : #'private accessing' }
GLMTransmission >> originReferences [
	"Returns the set of ports (instances of PortReference) the transmission receives its data from"
	^ origins ifNil: [origins := OrderedCollection new]
]

{ #category : #testing }
GLMTransmission >> originatesAt: aPort [
	^ (self activeOrigins includes: aPort) and: [self meetsCondition]
]

{ #category : #accessing }
GLMTransmission >> origins [
	^ self originReferences collect: [:each | each port]
]

{ #category : #accessing }
GLMTransmission >> passiveOrigins [ 
	 
	^(self originReferences select: [:each | each isPassive]) 
		collect: [:each | each port]
]

{ #category : #scripting }
GLMTransmission >> passivelyFrom: aPort [
	^ self addPassiveOrigin: (self browser resolveOriginPort: aPort)
]

{ #category : #scripting }
GLMTransmission >> passivelyFrom: aPaneSymbol port: aPortSymbol [
	^ self passivelyFrom: (GLMPortIdentifier pane: aPaneSymbol port: aPortSymbol)
]

{ #category : #copying }
GLMTransmission >> postCopy [
	origins := self originReferences collect: [:each | each copy ].
	destination := destination copy.
	transmissionStrategy := transmissionStrategy copy.
	transmissionStrategy transmission: self
]

{ #category : #accessing }
GLMTransmission >> presentations [
	^ self transmissionStrategy presentations
]

{ #category : #accessing }
GLMTransmission >> presentations: aCompositePresentation [
	self transmissionStrategy presentations: aCompositePresentation
]

{ #category : #printing }
GLMTransmission >> printOn: aStream [ 
	 
	aStream 
		nextPutAll: self class name;
		nextPutAll: ' (origins='; 
		print: self origins ; 
		nextPutAll: ' destination='; 
		print: self destination; 
		nextPut: $)
	 
	
]

{ #category : #scripting }
GLMTransmission >> to: aPort [
	"Ideally this method would be implemented as
	^ self to: aPaneSymbol port: #entiity.
	
	The problem is that beforehand we only had from: which could receive either a symbol for the pane, or an association for the port. This was bad, and now Glamour offers to:port:, but there are still legacy cases of to: being called with an association."

	^ self destination: (self browser resolveDestinationPort: aPort)
]

{ #category : #scripting }
GLMTransmission >> to: aPaneSymbol port: aPortSymbol [
	^ self to: (GLMPortIdentifier pane: aPaneSymbol port: aPortSymbol)
]

{ #category : #scripting }
GLMTransmission >> toOutside: aPortSymbol [
	self 
		deprecated: 'Use toOutsidePort: instead' 
		transformWith: '`@rec toOutsidePort: `@aPortSymbol' -> '`@rec toOutsidePort: `@aPortSymbol'.
	^ self toOutsidePort: aPortSymbol
]

{ #category : #scripting }
GLMTransmission >> toOutsidePort: aPortSymbol [
	^ self to: #outer->aPortSymbol
]

{ #category : #scripting }
GLMTransmission >> toWatcher [
	""
	^ self destination: (self browser watcherPane port: #entity)
]

{ #category : #accessing }
GLMTransmission >> transformation [
	^ transformation
]

{ #category : #accessing }
GLMTransmission >> transformation: anObject [ 
	 
	transformation := anObject
]

{ #category : #scripting }
GLMTransmission >> transformed: aBlock [
	self transformation: aBlock
]

{ #category : #accessing }
GLMTransmission >> transmissionStrategy [
	^ transmissionStrategy
]

{ #category : #accessing }
GLMTransmission >> transmissionStrategy: anObject [
	transmissionStrategy := anObject
]

{ #category : #transmitting }
GLMTransmission >> transmit [
	self transmitIn: GLMTransmissionContext new
]

{ #category : #transmitting }
GLMTransmission >> transmitIn: aContext [
	self flag: 'The transmitIt: and receive:in: both end up calling notingPresentationChangeDo:. So they should be handled by a surrounding notingPresentationChangeDo:. However, by doing that it seems that we break the morphic updating. No idea why'.
	self destination notingPresentationChangeDo: [
		self transmissionStrategy transmitIn: aContext.
		self destination receive: self in: aContext ].
	self browser notNil ifTrue: [
		self browser announce: GLMTransmissionTriggered new ]
]

{ #category : #transmitting }
GLMTransmission >> value [

	<debuggingStone: #transmissionTransformation label: 'Transmission transformation'>
	| originalValue |

	originalValue := self originReferences size = 1
		ifTrue: [ self originReferences first value ]
		ifFalse: [ GLMMultiValue withAll: ( self originReferences collect: [ :each | each value ] ) ].
	^ self transformation
		ifNil: [ originalValue ]
		ifNotNil: [ self transformation
				glamourValue: originalValue asGlamorousMultiValue , self origins asGlamorousMultiValue
			]
]

{ #category : #scripting }
GLMTransmission >> when: aBlock [
	self condition: aBlock
]

{ #category : #scripting }
GLMTransmission >> whenKindOf: aClass [ 
	 
	self when: [:each | each isKindOf: aClass]
]
