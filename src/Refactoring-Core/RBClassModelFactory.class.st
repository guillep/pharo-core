"
None of the classes inside this package should be directly accessed. They should be accessed via myself. I'm a class factory. 

I'm an important design point: I will let future evolution of the system to be experimented without the needs to change all the users. Then once the experiments and a good solution is found it may be the time to remove me and to think that I'm an overengineered solution. Right now I'm a change enabler. For example people can try to use Ring models to model RBmodel. 
"
Class {
	#name : #RBClassModelFactory,
	#superclass : #Object,
	#classVars : [
		'RBclass',
		'RBmetaclass',
		'RBmethod',
		'RBnamespace',
		'RBpackage',
		'RBtrait',
		'RBtraitMetaclass'
	],
	#category : #'Refactoring-Core-Model'
}

{ #category : #'factory access' }
RBClassModelFactory class >> rbClass [
 
	^ RBclass ifNil: [ RBclass := RBClass ]
]

{ #category : #'factory access' }
RBClassModelFactory class >> rbMetaclass [
 
	^ RBmetaclass ifNil: [ RBmetaclass := RBMetaclass ]
]

{ #category : #'factory access' }
RBClassModelFactory class >> rbMethod [
 
	^ RBmethod ifNil: [ RBmethod := RBMethod ]
]

{ #category : #'factory access' }
RBClassModelFactory class >> rbNamespace [
 
	^ RBnamespace ifNil: [ RBnamespace := RBNamespace ]
]

{ #category : #'factory access' }
RBClassModelFactory class >> rbPackage [
 
	^ RBpackage ifNil: [ RBpackage := RBPackage ]
]

{ #category : #'factory access' }
RBClassModelFactory class >> rbTrait [
 
	^ RBtrait ifNil: [ RBtrait := RBTrait ]
]

{ #category : #'factory access' }
RBClassModelFactory class >> rbTraitMetaclass [
 
	^ RBtraitMetaclass ifNil: [ RBtraitMetaclass := RBTraitedMetaclass ]
]

{ #category : #'factory customisation' }
RBClassModelFactory class >> setRBClass: aClass [

	RBclass := aClass
]

{ #category : #'factory customisation' }
RBClassModelFactory class >> setRBMetaclass: aClass [

	RBmetaclass := aClass
]

{ #category : #'factory customisation' }
RBClassModelFactory class >> setRBMethod: aClass [

	RBmethod := aClass
]

{ #category : #'factory customisation' }
RBClassModelFactory class >> setRBNamespace: aClass [
 
	RBnamespace := aClass
]

{ #category : #'factory customisation' }
RBClassModelFactory class >> setRBPackage: aClass [
 
	RBpackage := aClass
]

{ #category : #'factory customisation' }
RBClassModelFactory class >> setRBTrait: aClass [

	RBtrait := aClass
]

{ #category : #'factory customisation' }
RBClassModelFactory class >> setRBTraitMetaclass: aClass [

	RBtraitMetaclass := aClass
]

{ #category : #'factory access' }
RBClassModelFactory >> rbClass [ 

	^ self class rbClass
]

{ #category : #'factory access' }
RBClassModelFactory >> rbMetaclass [

	^ self class rbMetaclass
]

{ #category : #'factory access' }
RBClassModelFactory >> rbMethod [

	^ self class rbMethod
]

{ #category : #'factory access' }
RBClassModelFactory >> rbNamespace [

	^ self class rbNamespace
]

{ #category : #'factory access' }
RBClassModelFactory >> rbPackage [

	^ self class rbPackage
]

{ #category : #'factory access' }
RBClassModelFactory >> rbTrait [

	^ self class rbTrait
]

{ #category : #'factory access' }
RBClassModelFactory >> rbTraitMetaclass [

	^ self class rbTraitMetaclass
]
