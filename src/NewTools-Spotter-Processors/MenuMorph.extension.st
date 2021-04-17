Extension { #name : #MenuMorph }

{ #category : #'*NewTools-Spotter-Processors' }
MenuMorph >> withAllLeafItemsDo: aBlockClosure [ 
	
	self items do: [:anItem | anItem withAllLeafItemsDo: aBlockClosure]
]
