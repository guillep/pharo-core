"
I am a simple class to benchmark the old squeak FFI implementation
"
Class {
	#name : #BenchSqueakFFIPlugin,
	#superclass : #Object,
	#category : #'ThreadedFFI-UFFI-Tests-Benchs'
}

{ #category : #private }
BenchSqueakFFIPlugin >> doCallWith: aFloat another: aDouble [

	^ self ffiCall: #(float sumAFloatAndADouble(float aFloat, double aDouble))
]

{ #category : #accessing }
BenchSqueakFFIPlugin >> ffiLibraryName [

	^ 'libTestLibrary.dylib'
]

{ #category : #running }
BenchSqueakFFIPlugin >> runCall [
	<script: 'self new runCall'>
	| return | 

	^ [ return := self doCallWith: 1.0 another: 2.0.
		 self assert: return = 3.0 ] bench
]
