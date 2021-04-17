"
I'm a base command to be used on spec 2 presenters. 
My children will define actions that can be executed as part of the Pharo System. 

"
Class {
	#name : #SpToolCommand,
	#superclass : #CmCommand,
	#instVars : [
		'transform'
	],
	#category : #'Spec2-Commands-Presenters'
}

{ #category : #documentation }
SpToolCommand class >> addDocumentContextRequiredSelectors: aBuilder [
	| requiredSelectors |

	requiredSelectors := self documentContextRequiredSelectors. 

	aBuilder newLine.
	aBuilder header: [ :builder | builder text: 'Required Context API' ] withLevel: 2.	
	requiredSelectors 
		ifNotEmpty: [ 
			aBuilder text: 'To work properly, the context passed to this command has to implement the following vocabulary (See `CmCommand>>#context:`).'.
			aBuilder newLine.
			aBuilder unorderedListDuring: [  
				(requiredSelectors sorted) do: [ :each |
					aBuilder item: [
						aBuilder monospace: each ] ] ] ]
		ifEmpty: [ 
			aBuilder text: '(No required API is defined)' ]
]

{ #category : #documentation }
SpToolCommand class >> buildMicroDownUsing: aBuilder withComment: aString [
	
	super buildMicroDownUsing: aBuilder withComment: aString.
	self addDocumentContextRequiredSelectors: aBuilder
]

{ #category : #defaults }
SpToolCommand class >> defaultIconName [
	^nil
]

{ #category : #defaults }
SpToolCommand class >> defaultShortcutKey [

	^ nil
]

{ #category : #documentation }
SpToolCommand class >> documentContextRequiredSelectors [

	^ #()
]

{ #category : #default }
SpToolCommand class >> shortName [
	"For menus some commands can implement this helper to provide shorter names.
	Example: default name = 'Browse Command', short name = 'command'.
	It is intended to be accessed through a menu 'browse' then  'command' instead of directly 'browse command'"

	^ self defaultName
]

{ #category : #converting }
SpToolCommand >> asSpecCommand [
	| command |
	
	command := super asSpecCommand.
	self shortcutKey ifNotNil: [ :key | command shortcutKey: key ].
	self defaultIconName
		ifNotNil: [ :iconName | command iconName: iconName ].
	
	^ SpToolCurrentApplicationCommand decorate: command
]

{ #category : #accessing }
SpToolCommand >> defaultIconName [
	^self class defaultIconName
]

{ #category : #initialization }
SpToolCommand >> initialize [

	super initialize.
	transform := [ :aContext | aContext ]
]

{ #category : #accessing }
SpToolCommand >> shortcutKey [

	^ self class defaultShortcutKey
]

{ #category : #accessing }
SpToolCommand >> target [

	^ self transform value: self context
]

{ #category : #accessing }
SpToolCommand >> transform [

	^ transform
]

{ #category : #accessing }
SpToolCommand >> transform: aBlock [

	transform := aBlock
]
