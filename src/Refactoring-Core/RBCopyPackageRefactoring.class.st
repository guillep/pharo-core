"
I am a refactoring for copy a package.

My preconditions verify, that the copied package exists (in  the current environment) and that the new copy package name is valid and not yet used as a global variable name 

The refactoring transformation create a new package and copy defined classes of origin package (exclude all class' extensions)

Example
---------------
```
	(RBCopyPackageRefactoring 
		copyPackage: #'Refactoring-Help' 
		in: #'Refactoring-Help1') execute. 
```
"
Class {
	#name : #RBCopyPackageRefactoring,
	#superclass : #RBPackageRefactoring,
	#instVars : [
		'package'
	],
	#category : #'Refactoring-Core-Refactorings'
}

{ #category : #copying }
RBCopyPackageRefactoring class >> copyPackage: aString1 in: aString2 [
	^ self new copyPackage: aString1 in: aString2; yourself
]

{ #category : #copying }
RBCopyPackageRefactoring class >> model: aRBSmalltalk copyPackage: aString1 in: aString2 [
	^ self new 
		model: aRBSmalltalk;
		copyPackage: aString1 in: aString2; yourself
]

{ #category : #preconditions }
RBCopyPackageRefactoring >> changeReferencesOf: classes with: copyClasses [
	classes with: copyClasses do: [ :cls :cp | | rbClass |
		rbClass := self model classNamed: cls.
		self renameReferencesOf: rbClass with: cp.
	]
]

{ #category : #preconditions }
RBCopyPackageRefactoring >> copyAllClasses: classes [
	^ classes collect: [ :symbol | | copyClassName |
		copyClassName := self copyNameFor: symbol.
		self performCompositeRefactoring: 
			(RBCopyClassRefactoring
				model: self model
				copyClass: symbol 
				withName: copyClassName
				in: newName).
		copyClassName
	]
]

{ #category : #preconditions }
RBCopyPackageRefactoring >> copyNameFor: symbol [
	| string counter copyName |
	string := 'Copy'.
	counter := 1.
	copyName := symbol, string.
	[ self model includesGlobal: copyName ] 
		whileTrue: [ copyName := symbol, string, counter asString.
			counter := counter + 1 ].
	^ copyName
]

{ #category : #copying }
RBCopyPackageRefactoring >> copyPackage: aString1 in: aString2 [
	packageName := aString1 asSymbol.
	package := self model packageNamed: packageName.
	newName := aString2 asSymbol.
]

{ #category : #preconditions }
RBCopyPackageRefactoring >> preconditions [ 
	^ super preconditions & (RBCondition withBlock: [ newName = packageName ifTrue: 
		[ self refactoringError: 'Use a different name' ].
		true ]) &
	(RBCondition withBlock: [ [RPackage organizer validatePackageDoesNotExist: newName. true]
			on: Error 
			do: [ :e | self refactoringError: e messageText ]
		])
]

{ #category : #'as yet unclassified' }
RBCopyPackageRefactoring >> renameReferencesOf: aClass1 with: aClass2 [
	| replacer |
	replacer := (self parseTreeRewriterClass replaceLiteral: aClass1 name with: aClass2)
				replace: aClass1 name with: aClass2;
				replaceArgument: aClass2
					withValueFrom: 
						[:aNode | 
						self 
							refactoringFailure: aClass2 , ' already exists within the reference scope'];
				yourself.
	self model allReferencesToClass: aClass1 inPackages: { newName }
		do: 
			[:method | 
			(method modelClass hierarchyDefinesVariable: aClass2) 
				ifTrue: 
					[self refactoringFailure: aClass2 , ' is already defined in hierarchy of ' 
								, method modelClass printString].
			self 
				convertMethod: method selector
				for: method modelClass
				using: replacer]
]

{ #category : #preconditions }
RBCopyPackageRefactoring >> reparent: classes  with: copyClasses [
	| subclasses dict |
	dict := Dictionary newFromKeys: classes andValues: copyClasses.
	subclasses := copyClasses 
		collect: [ :cls | self model classNamed: cls] 
		thenSelect: [ :rb | classes includes: rb superclass name ].
	subclasses do: [ :cls |
		self model reparentClasses: { cls } to: (self model classNamed: (dict at: cls superclass name))
	]
	
]

{ #category : #printing }
RBCopyPackageRefactoring >> storeOn: aStream [ 
	aStream nextPut: $(.
	self class storeOn: aStream.
	aStream nextPutAll: ' copyPackage: '.
	aStream nextPutAll: package name.
	aStream
		nextPutAll: ' in: #';
		nextPutAll: newName;
		nextPut: $)
]

{ #category : #preconditions }
RBCopyPackageRefactoring >> transform [ 
	| classes copyClasses |
	self model addPackageNamed: newName.
	classes := (package realPackage definedClasses collect: #name) asArray.
	copyClasses := self copyAllClasses: classes.
	self changeReferencesOf: classes with: copyClasses.
	self reparent: classes  with: copyClasses.
]
