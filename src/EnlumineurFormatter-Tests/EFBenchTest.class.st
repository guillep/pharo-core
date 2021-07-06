"
This class contains just some benchs.
"
Class {
	#name : #EFBenchTest,
	#superclass : #TestCase,
	#category : #'EnlumineurFormatter-Tests'
}

{ #category : #tests }
EFBenchTest >> basicMethod [
	[[[[[ [ 
		[ :y :z |
		[ :x | 1 to: 10 do: [:i | self trace: (String streamContents: [:stream | stream 
			print: i printString;
			cr;
			cr
		]).] ]]]
 ]]]]]
]

{ #category : #tests }
EFBenchTest >> basicMethod2 [
	<sampleInstance>
	
	1 to: 10 do: [:i |self trace: (String streamContents: [:stream | stream 
			print: i printString; cr; cr ])]
 
]

{ #category : #tests }
EFBenchTest >> basicMethod3 [
	"a method with many similar expressions."
	| x y |
	x to: y do: [:i | Transcript show:i ; cr ;cr].
	x to: y do: [:i | Transcript show:i ; cr ;cr].
	x to: y do: [:i | Transcript show:i ; cr: x ; cr: x ].
 
]

{ #category : #resources }
EFBenchTest >> longNestedMethod [

	self foo: [ :b1 | 
		b1 value: [ :b2 |  
			b2 value: [ :b3 |  
				b2 value: [ :b4 |  
				b3 value: [ :b5 |  
				b4 value: [ :b6 |  
				b5 value:  [ :b7 |  
				b6 value: [ :b8|  
				b7 value: [ :b9 |  
				b8 value: [ :b10 |  
				b9 value:  2] ] ] ]] ] ] ] ] ]
]

{ #category : #resources }
EFBenchTest >> longNestedMethodShort [
  | b0 |
  self value: [:b1 |  b0 value: [:b2 |  b1 value: [:b3 |  b2 value: [:b4 |  b3 value: [:b5 |  b4 value: [:b6 |  b5 value: [:b7 |  b7 value: 2 ] ] ] ] ] ] ]
]

{ #category : #tests }
EFBenchTest >> testBasicEF [
	self skip.
	[ EFFormatter format: (EFBenchTest >> #basicMethod) ast ] bench
]

{ #category : #tests }
EFBenchTest >> testBasicEF2 [
	self skip.
	EFFormatter format: (EFBenchTest >> #basicMethod2) ast 
]

{ #category : #tests }
EFBenchTest >> testEF [
	self skip.
  "
	[ EFFormatter format: (EFBenchTest >> #longNestedMethodShort) ast ] bench  '0.159 per second'

  [ RBSimpleFormatter format: (EFBenchTest >> #longNestedMethodShort) ast ] bench 
	>>>'15597.361 per second'
	
  [ BIConfigurableFormatter  format: (EFBenchTest >> #longNestedMethodShort) ast ] bench  '7341.000 per second'

	"
]
