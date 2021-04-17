"
I am a simple benchmark class to test the TFFISameThread scheme
"
Class {
	#name : #BenchTFFISameThread,
	#superclass : #Object,
	#category : #'ThreadedFFI-UFFI-Tests-Benchs'
}

{ #category : #accessing }
BenchTFFISameThread >> calloutAPIClass [ 

	^ TFCalloutAPI
]

{ #category : #private }
BenchTFFISameThread >> doCallWith: aFloat another: aDouble [

	^ self ffiCall: #(float sumAFloatAndADouble(float aFloat, double aDouble))
]

{ #category : #accessing }
BenchTFFISameThread >> ffiLibrary [

	^ TFTestLibraryUsingSameThreadRunner uniqueInstance
]

{ #category : #running }
BenchTFFISameThread >> runCall [
	<script: 'self new runCall'>
	| return | 

	^ [ return := self doCallWith: 1.0 another: 2.0.
		 self assert: return = 3.0 ] bench
]
