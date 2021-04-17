"
I am a command to remove given methods.

I use special remove strategy to define what to do when given methods are in use.

So I delegate actual remove operation to the strategy: 

	removeStrategy removeMethods: methods
 
Internal Representation and Key Implementation Points.

    Instance Variables
	removeStrategy:		<SycRemoveMethodStrategy>
"
Class {
	#name : #SycRemoveMethodCommand,
	#superclass : #SycMethodCommand,
	#instVars : [
		'removeStrategy'
	],
	#category : #'SystemCommands-MethodCommands'
}

{ #category : #accessing }
SycRemoveMethodCommand >> defaultMenuIconName [
	^#removeIcon
]

{ #category : #accessing }
SycRemoveMethodCommand >> defaultMenuItemName [
	^'Remove'
]

{ #category : #execution }
SycRemoveMethodCommand >> execute [
	
	removeStrategy removeMethods: methods
]

{ #category : #initialization }
SycRemoveMethodCommand >> initialize [
	super initialize.
	
	removeStrategy := SycSilentlyRemoveMethodStrategy new
]

{ #category : #execution }
SycRemoveMethodCommand >> prepareFullExecutionInContext: aToolContext [
	super prepareFullExecutionInContext: aToolContext.
	
	removeStrategy := aToolContext requestRemoveMethodStrategyFor: methods.
]

{ #category : #accessing }
SycRemoveMethodCommand >> removeStrategy [
	^ removeStrategy
]

{ #category : #accessing }
SycRemoveMethodCommand >> removeStrategy: anObject [
	removeStrategy := anObject
]
