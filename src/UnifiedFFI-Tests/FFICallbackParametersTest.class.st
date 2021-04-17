"
This TestSuite evaluates the correct implementation of the callback parameter extraction.
"
Class {
	#name : #FFICallbackParametersTest,
	#superclass : #TestCase,
	#instVars : [
		'callback'
	],
	#pools : [
		'FFITestEnumeration'
	],
	#category : #'UnifiedFFI-Tests-Tests'
}

{ #category : #executing }
FFICallbackParametersTest >> callCallback: aFFICallback withArgs: aCollection [ 

	self assert: aCollection isArray.
	^ aFFICallback invokeAsFunctionWithArguments: aCollection.
]

{ #category : #running }
FFICallbackParametersTest >> testCharacterParameters [
	
	| params |
	params := (1 to: 6) collect: [ :i | i asCharacter ].	
	
	callback := FFICallback 
		signature: #(int (char, char, char, char, char, char))
		block: [ :a :b :c :d :e :f  |
			self assert: a value equals: 1 asCharacter.
			self assert: b value equals: 2 asCharacter.
			self assert: c value equals: 3 asCharacter.
			self assert: d value equals: 4 asCharacter.
			self assert: e value equals: 5 asCharacter.
			self assert: f value equals: 6 asCharacter.
			$z asInteger
		].

	self assert: (self callCallback: callback withArgs: params) equals: $z asInteger
]

{ #category : #running }
FFICallbackParametersTest >> testFloatParameters [ 
	
	callback := FFICallback 
		signature: #(double (double a, double b, float c, float d, double e, float f))
		block: [ :a :b :c :d :e :f  | 
			self assert: a value equals: 1.0.
			self assert: b value equals: 2.0.
			self assert: c value equals: 3.0.
			self assert: d value equals: 4.0.
			self assert: e value equals: 5.0.
			self assert: f value equals: 6.0.
			7.0
		].

	self assert: (self callCallback: callback withArgs: {1.0. 2.0. 3.0. 4.0. 5.0. 6.0}) equals: 7.0
]

{ #category : #running }
FFICallbackParametersTest >> testIdentityStruct [ 
	
	| param result |
	
	"This is ugly, but the tests are not running with Alien callbacks"
	true ifTrue: [ ^ self skip. ].
	
	callback := FFICallback 
		signature: #(FFITestStructureSmallIntFloatStructure (FFITestStructureSmallIntFloatStructure a))
		block: [ :a |
			self assert: a x equals: 2.0. 
			self assert: a y equals: 3. 
			self assert: a w equals: 5.0. 
			self assert: a z equals: 7.0. 

			a x: 3.0.
			a y: 4.
			a w: 6.0.
			a z: 8.0. 
						
			a
		].

	param := FFITestStructureSmallIntFloatStructure new
		x: 2.0;
		y: 3;
		w: 5.0;
		z: 7;
		yourself.

	result := self callCallback: callback withArgs: { param }.

	"They are passed and returned by copy, so they should not be the same"	
	self deny: param equals: result.
	
	self assert: result x equals: 3.0. 
	self assert: result y equals: 4. 
	self assert: result w equals: 6.0. 
	self assert: result z equals: 8.0. 

]

{ #category : #running }
FFICallbackParametersTest >> testIntegerParameters [ 
	
	callback := FFICallback 
		signature: #(int (int, int, int, int, int, int))
		block: [ :a :b :c :d :e :f  | 
			self assert: a equals: 1.
			self assert: b equals: 2.
			self assert: c equals: 3.
			self assert: d equals: 4.
			self assert: e equals: 5.
			self assert: f equals: 6.
			7
		].

	self assert: (self callCallback: callback withArgs: #(1 2 3 4 5 6)) equals: 7


]

{ #category : #running }
FFICallbackParametersTest >> testIntegerPointerParameters [ 
	
	| params |
	params := {
		ExternalAddress fromAddress: 1.
		ExternalAddress fromAddress: 2.
		ExternalAddress fromAddress: 3.
		ExternalAddress fromAddress: 4.
		ExternalAddress fromAddress: 5.
		ExternalAddress fromAddress: 6.}.	
	
	callback := FFICallback 
		signature: #(void (void* a, void* b, int* c, int* d, int* e, float* f))
		block: [ :a :b :c :d :e :f  | 
			self assert: a value equals: 1.
			self assert: b value equals: 2.
			self assert: c value equals: 3.
			self assert: d value equals: 4.
			self assert: e value equals: 5.
			self assert: f value equals: 6.
		].

	self callCallback: callback withArgs: params
]

{ #category : #running }
FFICallbackParametersTest >> testMixingParameters [ 
	
	callback := FFICallback 
		signature: #(void (int a, float b, char c, int d, double e, int f, char g))
		block: [ :a :b :c :d :e :f :g | 
			self assert: a value equals: 1.
			self assert: b value equals: 2.0.
			self assert: c value equals: $c.
			self assert: d value equals: 4.
			self assert: e value equals: 5.0.
			self assert: f value equals: 6.
			self assert: g value equals: $g.
		].

	self callCallback: callback withArgs: {1. 2.0. $c. 4. 5.0. 6. $g}
]

{ #category : #running }
FFICallbackParametersTest >> testPassing2DoubleStructureInTheStack [ 
			
	| param |
	callback := FFICallback 
		signature: #(int (FFITestStructure2DoubleStructure a))
		block: [ :a |
			self assert: a x equals: 2.0. 
			self assert: a y equals: 3.0. 

			99
		].

	param := FFITestStructure2DoubleStructure externalNew
		x: 2.0;
		y: 3.0;
		autoRelease;
		yourself.

	self assert: (self callCallback: callback withArgs: { param }) equals: 99
]

{ #category : #running }
FFICallbackParametersTest >> testPassing2Int64StructureInTheStack [ 
			
	| param |
	callback := FFICallback 
		signature: #(int (FFITestStructure2Int64Structure a))
		block: [ :a |
			self assert: a x equals: 2. 
			self assert: a y equals: 3. 

			99
		].

	param := FFITestStructure2Int64Structure externalNew
		x: 2;
		y: 3;
		autoRelease;
		yourself.

	self assert: (self callCallback: callback withArgs: { param }) equals: 99
]

{ #category : #running }
FFICallbackParametersTest >> testPassing4DoubleStructureInTheStack [ 
			
	| param |
	callback := FFICallback 
		signature: #(int (FFITestStructureDoubleStructure a))
		block: [ :a |
			self assert: a x equals: 2.0. 
			self assert: a y equals: 3.0. 
			self assert: a w equals: 5.0. 
			self assert: a z equals: 7.0. 

			a x: 3.0.
			a y: 4.0.
			a w: 5.0.
			a z: 7.0. 

			99
		].

	param := FFITestStructureDoubleStructure externalNew
		x: 2.0;
		y: 3.0;
		w: 5.0;
		z: 7.0;
		autoRelease;
		yourself.

	self assert: (self callCallback: callback withArgs: { param }) equals: 99
]

{ #category : #running }
FFICallbackParametersTest >> testPassing4Int64StructureInTheStack [ 
			
	| param |
	callback := FFICallback 
		signature: #(int (FFITestStructure4Int64Structure a))
		block: [ :a |
			self assert: a x equals: 2. 
			self assert: a y equals: 3. 
			self assert: a w equals: 5. 
			self assert: a z equals: 7. 

			99
		].

	param := FFITestStructure4Int64Structure externalNew
		x: 2;
		y: 3;
		w: 5;
		z: 7;
		autoRelease;
		yourself.

	self assert: (self callCallback: callback withArgs: { param }) equals: 99
]

{ #category : #running }
FFICallbackParametersTest >> testPassing4IntStructureInTheStack [ 
			
	| param |
	callback := FFICallback 
		signature: #(int (FFITestStructureIntStructure a))
		block: [ :a |
			self assert: a x equals: 2. 
			self assert: a y equals: 3. 
			self assert: a w equals: 5. 
			self assert: a z equals: 7. 

			99
		].

	param := FFITestStructureIntStructure externalNew
		x: 2;
		y: 3;
		w: 5;
		z: 7;
		autoRelease;
		yourself.

	self assert: (self callCallback: callback withArgs: { param }) equals: 99
]

{ #category : #running }
FFICallbackParametersTest >> testPassingStructureInTheStack [ 
	
	| param |
	callback := FFICallback 
		signature: #(int (FFITestStructureSmallIntFloatStructure a))
		block: [ :a |
			self assert: a x equals: 2.0. 
			self assert: a y equals: 3. 
			self assert: a w equals: 5.0. 
			self assert: a z equals: 7.0. 

			a x: 3.0.
			a y: 4.
			a w: 5.0.
			a z: 7.0. 

			77 
		].

	param := FFITestStructureSmallIntFloatStructure externalNew
		x: 2.0;
		y: 3;
		w: 5.0;
		z: 7.0;
		autoRelease;
		yourself.
		
	self assert: (self callCallback: callback withArgs: { param }) equals: 77
]
