Class {
	#name : #FileDirectoryWrapper,
	#superclass : #ListItemWrapper,
	#instVars : [
		'itemName',
		'balloonText',
		'hasContents'
	],
	#category : #'Tool-FileList'
}

{ #category : #'instance creation' }
FileDirectoryWrapper class >> with: anObject name: aString model: aModel [

	^self new 
		setItem: anObject name: aString model: aModel
]

{ #category : #converting }
FileDirectoryWrapper >> asString [
	 ^itemName
]

{ #category : #accessing }
FileDirectoryWrapper >> balloonText [

	^balloonText
]

{ #category : #accessing }
FileDirectoryWrapper >> balloonText: aStringOrNil [

	balloonText := aStringOrNil
]

{ #category : #accessing }
FileDirectoryWrapper >> contents [

	^((model directoriesFor: item) 
		sort: [ :a :b | a basename caseInsensitiveLessOrEqual: b basename]) 
		collect: [ :directory| 
			self class with: directory name: directory basename model: self ]

]

{ #category : #accessing }
FileDirectoryWrapper >> directoriesFor: anItem [
	^model directoriesFor: anItem
]

{ #category : #accessing }
FileDirectoryWrapper >> hasContents [
	"Return whether this directory has subfolders. The value is cached to 
	avoid a performance penalty.	Also for performance reasons, the code 
	below will just assume that the directory does indeed have contents in a 
	few of cases:  
	1. If the item is not a FileDirectory (thus avoiding the cost 
	of refreshing directories that are not local) 
	2. If it's the root directory of a given volume 
	3. If there is an error computing the FileDirectory's contents
	"
	hasContents ifNil: [
		hasContents := [ 
				item isDirectory 
				and: [ item isReadable 
				and: [ item hasDirectories ]]
			] on: Error do: [ :error | false ]].
	^ hasContents
]

{ #category : #accessing }
FileDirectoryWrapper >> icon [
	"Answer a form to be used as icon"

	"^ item isRemoteDirectory
		ifTrue: [ Smalltalk ui icons smallRemoteOpenIcon]
		ifFalse: [Smalltalk ui icons smallOpenIcon]"

	^ self iconNamed: #smallOpenIcon
]

{ #category : #accessing }
FileDirectoryWrapper >> setItem: anObject name: aString model: aModel [

	item := anObject.
	model := aModel.
	itemName := aString.
	hasContents := nil.

]

{ #category : #accessing }
FileDirectoryWrapper >> settingSelector [

	^#setSelectedDirectoryTo:
]
