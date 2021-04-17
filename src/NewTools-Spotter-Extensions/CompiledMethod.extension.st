Extension { #name : #CompiledMethod }

{ #category : #'*NewTools-Spotter-Extensions' }
CompiledMethod >> spotterForBytecodesFor: aStep [
	<stSpotterOrder: 15>
	aStep listProcessor
		title: 'Bytecode';
		allCandidates: [ self symbolicBytecodes ];
		itemName: #printString;
		filter: GTFilterSubstring
]

{ #category : #'*NewTools-Spotter-Extensions' }
CompiledMethod >> spotterForImplementorsFor: aStep [
	<stSpotterOrder: 10>
	aStep listProcessor
			title: 'Implementors';
			allCandidates: [ self implementors collect: [:each | each compiledMethod] ];
			filter: GTFilterSubstring;
			keyBinding: $m command
]

{ #category : #'*NewTools-Spotter-Extensions' }
CompiledMethod >> spotterForMessagesFor: aStep [
	<stSpotterOrder: 12>
	aStep listProcessor
			title: 'Messages';
			allCandidates: [ self messages asSortedCollection collect: [:each | GTSelector new name: each ] ];
			filter: GTFilterSubstring
]

{ #category : #'*NewTools-Spotter-Extensions' }
CompiledMethod >> spotterForSendersFor: aStep [
	<stSpotterOrder: 11>
	aStep listProcessor
			title: 'Senders';
			allCandidates: [ self senders collect: [:each | each compiledMethod] ];
			filter: GTFilterSubstring;
			keyBinding: $n command
]

{ #category : #'*NewTools-Spotter-Extensions' }
CompiledMethod >> spotterMethodClassFor: aStep [
	<stSpotterOrder: 50>
	aStep listProcessor
			allCandidates: [  {self methodClass }];
			title: 'Class';
			filter: GTFilterSubstring;
			itemIcon: #systemIcon
]

{ #category : #'*NewTools-Spotter-Extensions' }
CompiledMethod >> spotterPreview: aBuilder [

	^ aBuilder newCode
		beForMethod: self;
		beNotEditable;
		text: self sourceCode;
		yourself
]
