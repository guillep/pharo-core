Class {
	#name : #ClySubclassN2OfClass1FromP1,
	#superclass : #ClyClass1FromP1,
	#instVars : [
		'subclassSameVar',
		'subclassN2Var'
	],
	#category : #'Calypso-SystemQueries-Tests-P1WithHierarchy'
}

{ #category : #accessing }
ClySubclassN2OfClass1FromP1 class >> classSideMethodFromSubclassN2 [
]

{ #category : #accessing }
ClySubclassN2OfClass1FromP1 >> subclassN2VarReaderMethod [
	^subclassN2Var
]

{ #category : #accessing }
ClySubclassN2OfClass1FromP1 >> subclassN2VarWriterMethod [
	subclassN2Var := #subclassN2VarValue
]

{ #category : #accessing }
ClySubclassN2OfClass1FromP1 >> subclassSameVar [

	^ subclassSameVar
]

{ #category : #accessing }
ClySubclassN2OfClass1FromP1 >> superclassVar1ReaderMethod [
	^instanceSideVar1 
]

{ #category : #accessing }
ClySubclassN2OfClass1FromP1 >> superclassVar1WriterMethod [
	instanceSideVar1 := #subclassVar1Value 
]
