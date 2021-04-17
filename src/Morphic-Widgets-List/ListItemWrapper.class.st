"
Contributed by Bob Arning as part of the ObjectExplorer package.

"
Class {
	#name : #ListItemWrapper,
	#superclass : #Model,
	#instVars : [
		'item',
		'model'
	],
	#category : #'Morphic-Widgets-List'
}

{ #category : #'instance creation' }
ListItemWrapper class >> with: anObject [

	^self new setItem: anObject
]

{ #category : #'instance creation' }
ListItemWrapper class >> with: anObject model: aModel [

	^self new setItem: anObject model: aModel
]

{ #category : #'dropping/grabbing' }
ListItemWrapper >> acceptDroppingObject: anotherItem [

	^item acceptDroppingObject: anotherItem
]

{ #category : #converting }
ListItemWrapper >> asString [

	^item asString
]

{ #category : #accessing }
ListItemWrapper >> balloonText [

	^nil
]

{ #category : #testing }
ListItemWrapper >> canBeDragged [

	^true
]

{ #category : #accessing }
ListItemWrapper >> contents [

	^Array new
]

{ #category : #testing }
ListItemWrapper >> handlesMouseOver: evt [

	^false
]

{ #category : #accessing }
ListItemWrapper >> hasContents [

	^self contents isEmpty not
]

{ #category : #testing }
ListItemWrapper >> hasEquivalentIn: aCollection [
	^ aCollection anySatisfy: [ :each | each withoutListWrapper = item withoutListWrapper ]
]

{ #category : #accessing }
ListItemWrapper >> highlightingColor [
	^ self theme selectionColor
]

{ #category : #accessing }
ListItemWrapper >> icon [
	"Answer a form to be used as icon"
	^ nil
]

{ #category : #accessing }
ListItemWrapper >> item [
	"Answer the item. It is useful!"
	
	^item
]

{ #category : #accessing }
ListItemWrapper >> item: newItem [
	item := newItem
]

{ #category : #accessing }
ListItemWrapper >> model [
	"Answer the model. It is useful!"
	
	^model
]

{ #category : #accessing }
ListItemWrapper >> preferredColor [
	^ nil
]

{ #category : #'dropping/grabbing' }
ListItemWrapper >> sendSettingMessageTo: aModel [

	aModel 
		perform: (self settingSelector ifNil: [^self])
		with: self withoutListWrapper

]

{ #category : #accessing }
ListItemWrapper >> setItem: anObject [

	item := anObject
]

{ #category : #accessing }
ListItemWrapper >> setItem: anObject model: aModel [

	item := anObject.
	model := aModel.
]

{ #category : #accessing }
ListItemWrapper >> setItemFromBlock: aBlock [

	self setItem: aBlock value
]

{ #category : #accessing }
ListItemWrapper >> settingSelector [

	^nil
]

{ #category : #testing }
ListItemWrapper >> wantsDroppedObject: anotherItem [

	^false
]

{ #category : #converting }
ListItemWrapper >> withoutListWrapper [

	^item withoutListWrapper
]
