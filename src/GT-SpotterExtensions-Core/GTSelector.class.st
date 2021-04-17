"
This is a helper class for modeling a selector. We need this in order to support diving in such a selector and to offer specific processors (like implementors or senders) in Spotter .
"
Class {
	#name : #GTSelector,
	#superclass : #Object,
	#instVars : [
		'name',
		'methods'
	],
	#category : #'GT-SpotterExtensions-Core'
}

{ #category : #examples }
GTSelector class >> gtExampleNew [
	<gtExample>
	^ self new name: #new
]

{ #category : #private }
GTSelector class >> substring: aString filter: aFilter [
	| selectors |
	aString isEmptyOrNil ifTrue: [ ^ self ].
	selectors := IdentityDictionary new.
	SystemNavigation default allBehaviorsDo: [ :class | 
		class selectorsAndMethodsDo: [ :selector :method | 
			(selector asString includesSubstring: aString caseSensitive: false) ifTrue: [ 
				| group newGroup | 
				group := selectors 
					at: selector 
					ifAbsentPut: [ aFilter value: (newGroup := GTSelector new name: selector; yourself). newGroup ].
				group addMethod: method ] ] ] 
]

{ #category : #'private accessing' }
GTSelector >> addMethod: aCompiledMethod [
	"this is a private method that can be used by the constructor on the class side
	exclusively within the context of Spotter"
	methods ifNil: [ methods := OrderedCollection new ].
	methods add: aCompiledMethod
]

{ #category : #printing }
GTSelector >> displayStringOn: stream [
	stream nextPutAll: self name
]

{ #category : #printing }
GTSelector >> gtDisplayOn: stream [
	stream nextPutAll: self name
]

{ #category : #querying }
GTSelector >> implementors [
	^ methods ifNil: [ 
		methods := (SystemNavigation default allImplementorsOf: self name) 
			collect: [ :each | each compiledMethod ] ]
]

{ #category : #accessing }
GTSelector >> name [
	^ name
]

{ #category : #accessing }
GTSelector >> name: anObject [
	name := anObject
]

{ #category : #querying }
GTSelector >> senders [
	^ SystemNavigation default allSendersOf: self name
]

{ #category : #ui }
GTSelector >> spotterPreviewIn: aComposite [
	<spotterPreview: 10>
	aComposite list
		title: 'Preview';
		display: [ :x | x ];
		format: [ :method | GTSpotterItemBrick new text: method displayString; disable; yourself ];
		entity: self implementors
]
