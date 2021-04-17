Class {
	#name : #RBClassUsingSharedPoolForTestData,
	#superclass : #Object,
	#traits : 'RBDummy',
	#classTraits : 'RBDummy classTrait',
	#pools : [
		'RBSharedPoolForTestData'
	],
	#category : #'Refactoring-Tests-Core-Data'
}

{ #category : #'accessing instances and variables' }
RBClassUsingSharedPoolForTestData >> msg1 [

	var1 asString
]

{ #category : #'accessing instances and variables' }
RBClassUsingSharedPoolForTestData >> msg2 [

	var1
]

{ #category : #'accessing instances and variables' }
RBClassUsingSharedPoolForTestData >> msg3 [

	^ Var1
]
