"
A Watch save the change of values of expressions. 
I save them as an ordered collection of  key val association where the key is the timestamp an val is the actual value of the expression.

To install a Watch in a node: 
Watch in: aNode
"
Class {
	#name : #Watch,
	#superclass : #Object,
	#instVars : [
		'tagname',
		'node',
		'link',
		'values',
		'recording'
	],
	#classVars : [
		'Watches'
	],
	#category : #'Reflectivity-Breakpoints'
}

{ #category : #accessing }
Watch class >> allWatches [
	^ Watches ifNil: [ Watches := WeakKeyDictionary new ]
]

{ #category : #cleanup }
Watch class >> deleteAllHistory [

	self allWatches valuesDo: [ :aWatch| aWatch deleteHistory].
]

{ #category : #cleanup }
Watch class >> deleteHistoryFrom: aNode [

	(self allWatches at: aNode ifAbsent:[^self]) deleteHistory
]

{ #category : #accessing }
Watch class >> from: aNode [
	^self allWatches at: aNode.
]

{ #category : #accessing }
Watch class >> from: aNode ifAbsent: aBlock [
	^self allWatches at: aNode ifAbsent: aBlock.
]

{ #category : #'instance creation' }
Watch class >> in: aRBProgramNode [
	^self in: aRBProgramNode named: ''.
]

{ #category : #'instance creation' }
Watch class >> in: aRBProgramNode named: aName [
	aRBProgramNode hasWatch ifTrue: [ ^ aRBProgramNode watch ].
	^self new 
		node: aRBProgramNode;
		tagname: aName;
		install.
]

{ #category : #cleanup }
Watch class >> removeAll [
	self allWatches values do: [ :aWatchpoint| aWatchpoint uninstall].
	Watches := nil.
]

{ #category : #cleanup }
Watch class >> removeFrom: aNode [

	(self allWatches at: aNode ifAbsent: [ ^self ]) uninstall
]

{ #category : #adding }
Watch >> addValue: anObject [
	values add: 
		(DateAndTime now -> anObject).
	^anObject.

]

{ #category : #accessing }
Watch >> compiledMethod [ 
	^self node methodNode method
]

{ #category : #cleanup }
Watch >> deleteHistory [
	values := OrderedCollection new.
]

{ #category : #initialization }
Watch >> initialize [
	super initialize.
	values := OrderedCollection new.
	recording := true.
]

{ #category : #install }
Watch >> install [

	node hasWatch ifTrue: [ self error: 'Node already has a Watchpoint'].
	
	link := MetaLink new 
				metaObject: self;
				selector: #addValue:;
				arguments: #(value);
				control: #after;
				condition: [ recording ];
				option: #(+ optionWeakAfter +optionAnnounce).
	node link: link.
	self class allWatches at: node put: self.
]

{ #category : #recording }
Watch >> isRecording [
	^recording
]

{ #category : #accessing }
Watch >> node [
	^ node
]

{ #category : #accessing }
Watch >> node: anObject [
	node := anObject
]

{ #category : #printing }
Watch >> printLastValue [
	values ifNil: [ ^''].
	values ifEmpty: [ ^'not run' ].
	^values last value printStringLimitedTo: 5.
]

{ #category : #printing }
Watch >> printOn: aStream [
	aStream nextPutAll: 'WP'.
	tagname isAllSeparators 
		ifFalse: [ 
			aStream nextPutAll: ' '.
			aStream nextPutAll: tagname ]. 
	aStream nextPutAll: ': '.
	aStream nextPutAll: (self printLastValue).
]

{ #category : #recording }
Watch >> start [
	recording := true.
	link announceChange
]

{ #category : #recording }
Watch >> stop [
	recording := false.
	link announceChange
]

{ #category : #accessing }
Watch >> tagname [
	^ tagname
]

{ #category : #accessing }
Watch >> tagname: anObject [
	tagname := anObject
]

{ #category : #install }
Watch >> uninstall [
	node hasWatch ifFalse: [ ^self ].
	link uninstall.
	self class allWatches removeKey: node.
]

{ #category : #accessing }
Watch >> values [
	^values.
]
