Extension { #name : #MenuItemMorph }

{ #category : #'*NewTools-Spotter-Processors' }
MenuItemMorph >> withAllLeafItemsDo: aBlockClosure [

	self subMenu ifNil: [ ^ aBlockClosure cull: self ].
	self subMenu items do: [ :anItem | anItem withAllLeafItemsDo: aBlockClosure ]
]
