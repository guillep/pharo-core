Class {
	#name : #TKTUIProcessTaskRunner,
	#superclass : #TKTRunner,
	#category : #'TaskIt-Kernel'
}

{ #category : #scheduling }
TKTUIProcessTaskRunner >> isUIRunner [
	^ true 
]

{ #category : #scheduling }
TKTUIProcessTaskRunner >> scheduleTaskExecution: aTaskExecution [
	WorldState addDeferredUIMessage: [ self executeTask: aTaskExecution ]
]

{ #category : #polymorphism }
TKTUIProcessTaskRunner >> start [

]
