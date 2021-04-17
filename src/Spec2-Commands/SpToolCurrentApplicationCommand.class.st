"
A decorator to wrap command on current application dynamic variable.
"
Class {
	#name : #SpToolCurrentApplicationCommand,
	#superclass : #CmCommandDecorator,
	#category : #'Spec2-Commands-Presenters'
}

{ #category : #'reflective operations' }
SpToolCurrentApplicationCommand >> doesNotUnderstand: aMessage [

	^ aMessage sendTo: self decoratedCommand
]

{ #category : #executing }
SpToolCurrentApplicationCommand >> execute [

	SpToolCurrentApplication 
		value: self context application
		during: [ self decoratedCommand execute ]
]
