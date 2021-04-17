"
I am the abstract strategy to use when a duplication is produced loading a package.
My subclasses gives different options that can be set by a command line parameter.
Each subclass has a classSide message #keyword that identifies it self.
I look up the corresponding subclass to use.
"
Class {
	#name : #HEDuplicationModeStrategy,
	#superclass : #Object,
	#category : #'Hermes-Extensions-ClassInstaller'
}

{ #category : #'instance creation' }
HEDuplicationModeStrategy class >> forOption: keyword [
	^ (self allSubclasses
		detect: [ :e | e keyword = keyword ]
		ifNone: [ self error: 'There is no duplication strategy for ''' , keyword , '''' ]) new
]

{ #category : #'validating existence' }
HEDuplicationModeStrategy >> doExistingClass: aClass hermesClass: aHEClass installer: installer [
	self subclassResponsibility 
]

{ #category : #'validating existence' }
HEDuplicationModeStrategy >> doExistingTrait: aTrait hermesTrait: aHETrait installer: installer [
	self subclassResponsibility 
]

{ #category : #'validating existence' }
HEDuplicationModeStrategy >> doShouldBuildMethod: aHEMethod in: installer installer: aClass original: aMethod [
	self subclassResponsibility 
]

{ #category : #'validating existence' }
HEDuplicationModeStrategy >> existingClass: aHEClass on: installer [
	^ installer environment
		at: aHEClass className
		ifPresent: [ :aClass | 
			self 
				doExistingClass: aClass 
				hermesClass: aHEClass 
				installer: installer  ]
		ifAbsent: [ nil ]
]

{ #category : #'validating existence' }
HEDuplicationModeStrategy >> existingTrait: aHETrait on: installer [
	^ installer environment
		at: aHETrait traitName
		ifPresent: [ :aTrait | 
			self 
				doExistingTrait: aTrait 
				hermesTrait: aHETrait 
				installer: installer ]
		ifAbsent: [ nil ]
]

{ #category : #'validating existence' }
HEDuplicationModeStrategy >> shouldBuildMethod: aHEMethod in: aClass installer: installer [
	^ aClass
		compiledMethodAt: aHEMethod name
		ifPresent: [ :m | 
			(m isFromTrait and: [ aClass isTrait not ])
				ifTrue: [ ^ true ].
			self 
				doShouldBuildMethod: aHEMethod 
				in: installer 
				installer: aClass 
				original: m]
		ifAbsent: [ true ]
]
