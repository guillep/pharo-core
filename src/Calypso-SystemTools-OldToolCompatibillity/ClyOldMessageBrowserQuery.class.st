"
I am a special query which is based on constant list of methods or class comments. 

I am introduced to support old (current) approach for system queries which is based on SystemNavigation collecting list of methods.

I am used by ClyOldMessageBrowserAdapter which is installed as default as part of Calypso toolset.

I implement semantics of old MessageBrowser.
 
Internal Representation and Key Implementation Points.

    Instance Variables
	criteriaBlock:		<BlockClosure>
	criteriaString:		<String>
	extraMethods:		<Collection of<CompiledMethod>>
"
Class {
	#name : #ClyOldMessageBrowserQuery,
	#superclass : #ClyConstantMethodQuery,
	#instVars : [
		'extraMethods',
		'criteriaString',
		'criteriaBlock'
	],
	#category : #'Calypso-SystemTools-OldToolCompatibillity'
}

{ #category : #accessing }
ClyOldMessageBrowserQuery >> criteriaBlock [
	^ criteriaBlock
]

{ #category : #accessing }
ClyOldMessageBrowserQuery >> criteriaBlock: anObject [
	criteriaBlock := anObject
]

{ #category : #accessing }
ClyOldMessageBrowserQuery >> criteriaString [
	^ criteriaString
]

{ #category : #accessing }
ClyOldMessageBrowserQuery >> criteriaString: anObject [
	criteriaString := anObject asString
]

{ #category : #'tools decoration' }
ClyOldMessageBrowserQuery >> decorateResultMethodEditor: aMethodEditor [

	criteriaString ifNil: [ ^self ].
	
	aMethodEditor selectStringAsInMessageBrowser: criteriaString
]

{ #category : #initialization }
ClyOldMessageBrowserQuery >> initialize [
	super initialize.
	extraMethods := IdentitySet new
]

{ #category : #execution }
ClyOldMessageBrowserQuery >> installedMethods [

	| onlyMethods actualMethods |
	onlyMethods := methods select: [ :each | each isCompiledMethod ].
	
	actualMethods := self filterInstalledMethods: onlyMethods, extraMethods.
	^actualMethods, (methods reject: [ :each | each isCompiledMethod ])
]

{ #category : #testing }
ClyOldMessageBrowserQuery >> selectsMethod: aMethod [
	| result |
	(super selectsMethod: aMethod) ifTrue: [ ^true ].
	criteriaBlock ifNil: [ ^false ].

	extraMethods removeAllSuchThat: [ :each | 
		each calypsoEnvironmentType checkCalypsoItem: each isEqualTo: aMethod].

	result := criteriaBlock value: aMethod.
	result ifTrue: [ extraMethods add: aMethod ].
	^result
]
