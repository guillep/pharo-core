Extension { #name : #Object }

{ #category : #'*GT-Spotter-UI' }
Object >> spotterPreviewRawIn: aComposite [
	<spotterPreview: 40>

	aComposite table
		title: [ self displayString ];
		display: [ :anObject | (anObject gtInspectorVariableValuePairs asSortedCollection asOrderedCollection yourself) addFirst: 'self' -> anObject; yourself ];
		column: 'Variable'
			evaluated: [:assoc |	GTObjectPrinter asNonTruncatedTextFrom: assoc key ]
			styled: [ :aBrick | aBrick textPosition: #rightCenter; margin: #(0 15 0 0); textColor: aComposite themer textLightColor; height: 30 ];
		column: 'Value'
			evaluated: [:assoc | GTObjectPrinter asTruncatedTextFrom: assoc value ]
			styled: [ :aBrick | aBrick margin: #(0 0 0 15); height: 30 ];
		entity: self.
		
	self flag: 'move "entity: self" somewhere else, maybe'
]
