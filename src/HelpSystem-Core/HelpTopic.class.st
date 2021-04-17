"
A HelpTopic provides content information that can be used as a help to the user.
It can be labeled with a title, identified using an (optional) unique key and marked 
with an (optional) icon.

Help topics form a hierarchy since any topic is able to have zero or more
subtopics. 


Instance Variables
	contents:		<Object>      The help topic contents
	icon:			<Form|nil>	   An optional icon for the topic
	key:			<String|nil>    An optional unique key
	subtopics:	      <Collection>  A collection of subtopics
	title:			<String>        The title

contents
	- The help topic contents - typically containing the help topics information

icon
	- An optional icon for the topic

key
	- An optional unique key which can be used to identify the topic. 

subtopics
	- A collection of subtopics. 
	  By default the subtopics are not sorted, so the insertion order is used. 
	  If necessary it is possible to sort the subtopics by title.

title
	- A meaninful title for the help topic

"
Class {
	#name : #HelpTopic,
	#superclass : #Object,
	#instVars : [
		'title',
		'key',
		'icon',
		'contents',
		'subtopics',
		'owner'
	],
	#category : #'HelpSystem-Core-Model'
}

{ #category : #'instance creation' }
HelpTopic class >> named: aString [
	"Create a new instance with given title and empty contents"
	
	^(self new)
		title: aString;
		yourself
]

{ #category : #'instance creation' }
HelpTopic class >> title: aTitle contents: aText [
	"Create a new instance with given title and content"
	
	^(self new)
		title: aTitle;
		contents: aText;
		yourself.
		
]

{ #category : #'instance creation' }
HelpTopic class >> title: aTitle icon: anIcon contents: aText [
	"Create a new instance with given title, icon and content"
	
	^(self new)
		title: aTitle;
		icon: anIcon;
		contents: aText;
		yourself.
		
]

{ #category : #'instance creation' }
HelpTopic class >> title: aTitle iconName: anIconName contents: aText [
	"Create a new instance with given title, icon and content"
	
	^(self new)
		title: aTitle;
		iconName: anIconName;
		contents: aText;
		yourself.
		
]

{ #category : #comparing }
HelpTopic >> <= anotherHelpTopic [
	"Use sorting by title as the default sort order"
	
	^self title <= anotherHelpTopic title 
]

{ #category : #accessing }
HelpTopic >> addSubtopic: aTopic [
	"Adds the given topic to the receivers collection of subtopics, and set this object as owner of the subtopic"
	
	self subtopics add: aTopic.
	aTopic owner: self.
	^aTopic
]

{ #category : #conversion }
HelpTopic >> asHelpTopic [ 
	"Converts the receiver to a help topic"
	
	^self
]

{ #category : #accessing }
HelpTopic >> contents [
	"Returns the receivers contents"
	
	^ contents
]

{ #category : #accessing }
HelpTopic >> contents: anObject [
	"Sets the receivers contents to the given object" 
		
	contents := anObject
]

{ #category : #defaults }
HelpTopic >> defaultTitle [
	"Returns the receivers default title"
	
	^'Unnamed Topic'
	
]

{ #category : #printing }
HelpTopic >> displayStringOn: stream [
	^ stream nextPutAll: self title
]

{ #category : #testing }
HelpTopic >> hasSubtopics [ 
	"Returns true if the receiver has subtopics, false otherwise"
	
	^self subtopics notEmpty 
]

{ #category : #accessing }
HelpTopic >> icon [ 
 	"Returns the receivers icon"
	
	^icon
]

{ #category : #accessing }
HelpTopic >> icon: aSymbol [
	"Sets the receivers icon"
	
	icon := aSymbol 
]

{ #category : #accessing }
HelpTopic >> iconName: aSymbol [
	"Sets the receivers icon"
	
	self icon: (self iconNamed: aSymbol) 
]

{ #category : #initialization }
HelpTopic >> initialize [ 
	"Initializes the receiver"
	
	super initialize.
	self title: self defaultTitle.
	self contents: ''.
	self key: '' 
]

{ #category : #accessing }
HelpTopic >> key [ 	
	"Returns a unique key identifying the receiver in the help system"	
		
	^key
]

{ #category : #accessing }
HelpTopic >> key: aUniqueKey [
	"Sets a unique key identifying the receiver in the help system"	
		
	key := aUniqueKey 
]

{ #category : #accessing }
HelpTopic >> owner [
	"an ownder is a HelpTopic that uses the current HelptTopic as subtopic"
^ owner
]

{ #category : #accessing }
HelpTopic >> owner: topic [
	"an owner is a HelpTopic that uses the current HelptTopic as subtopic"
owner := topic
]

{ #category : #accessing }
HelpTopic >> pathToTopicSatisfying: aBlock [
	"I return the complete path to the first topic satifying the given block.
	The path is a collection starting with the root node and ending with the 
	node satifying the given block. If no node is found I return an empty collection."
	
	(aBlock value: self) ifTrue: [ ^ {self} ].
	
	self subtopics do: [ :aHelpTopic |
		(aHelpTopic pathToTopicSatisfying: aBlock)
			ifNotEmpty: [ :aPath |
				^ { self }, aPath ] ].
	^ #()
]

{ #category : #operating }
HelpTopic >> sortSubtopicsByTitle [
	"Sort the subtopics by title"
	
	subtopics := SortedCollection withAll: self subtopics  
]

{ #category : #accessing }
HelpTopic >> subtopics [ 
	"Returns the receivers list of subtopics"
	
	^ subtopics ifNil: [subtopics := OrderedCollection new]
]

{ #category : #accessing }
HelpTopic >> subtopics: aCollection [ 
	"Sets the receivers subtopics"
	
	aCollection do: [ :topic|  topic owner: self  ].
	subtopics := aCollection.
]

{ #category : #accessing }
HelpTopic >> title [
	"Returns the receivers title"
	
	^ title
]

{ #category : #accessing }
HelpTopic >> title: anObject [
	"Sets the receivers title"
	
	title := anObject
]
