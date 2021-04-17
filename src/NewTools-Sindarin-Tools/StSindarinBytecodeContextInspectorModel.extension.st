Extension { #name : #StSindarinBytecodeContextInspectorModel }

{ #category : #'*NewTools-Sindarin-Tools' }
StSindarinBytecodeContextInspectorModel >> contextReceiverSlotNodes [
	^ self inspectedObject receiver class allSlots
		collect: [ :each | 
			StBytecodeInspectorSlotNode
				hostObject: self inspectedObject receiver
				slot: each ]
]

{ #category : #'*NewTools-Sindarin-Tools' }
StSindarinBytecodeContextInspectorModel >> contextTempNodes [
	^ self inspectedObject astScope allTemps collect: [ :temp | 
		  (StInspectorTempNode hostObject: self inspectedObject) tempVariable: temp ]

]
