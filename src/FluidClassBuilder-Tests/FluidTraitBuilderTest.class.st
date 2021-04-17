Class {
	#name : #FluidTraitBuilderTest,
	#superclass : #TestCase,
	#instVars : [
		'builder'
	],
	#category : #'FluidClassBuilder-Tests-Base'
}

{ #category : #'private - cleanup' }
FluidTraitBuilderTest >> removeTestArtifactsFromSystem [

	self class environment
		at: #TMyClass
		ifPresent: [ :p | p removeFromSystem: false ]
		ifAbsent: [ ]
]

{ #category : #running }
FluidTraitBuilderTest >> setUp [

	super setUp.
	builder := FluidTraitBuilder new
]

{ #category : #tests }
FluidTraitBuilderTest >> testBuildSimplePoint2 [

	| trait |
	builder := Trait << #TPoint2
					slots: { #x . #y };
					package: 'FakedCore'.
	trait := builder build.
	
	self assert: trait name equals: #TPoint2.
	self assert: trait slots size equals: 2

]

{ #category : #tests }
FluidTraitBuilderTest >> testFillShiftClassBuilder [

	| shift |
	builder := Trait << #TPoint2.
	builder slots: { #x . #y }.
	builder trait: {TViewModelMock}.
	builder tag: 'Mafia'.
	builder package: 'FakedCore'.
	builder fillShiftClassBuilder.
	shift := builder shiftClassBuilder. 
	self assert: shift name equals: #TPoint2.
	self assert: shift slots size equals: 2.
	self assert: shift category equals: 'FakedCore-Mafia'.
	self flag: #askPablo.
	"self assert: clas package packageName equals: 'FakedCore'"
	
]

{ #category : #tests }
FluidTraitBuilderTest >> testInstallMinimalMockClass [

	| shiftClassBuilder installedClass |
	self removeTestArtifactsFromSystem.
	[ 
	builder := self class compilerClass new
		           evaluate: 'Trait << #TMyClass
	uses: {};
	slots: {};
	tag: '''' ;
	package: ''MyPackage'''.
	shiftClassBuilder := builder shiftClassBuilder.
	ShiftClassInstaller new makeWithBuilder: shiftClassBuilder.
	
	installedClass := self class environment at: #TMyClass ifAbsent: [self fail].
	         
	self assert: installedClass name equals: #TMyClass.
	self assert: installedClass isFixed.
	self assert: installedClass slots isEmpty.
	self assert: installedClass traitComposition isEmpty ]
		ensure: [ self removeTestArtifactsFromSystem ]
]

{ #category : #tests }
FluidTraitBuilderTest >> testInstallSimplePoint2 [

	[ | trait |
	self assert: (self class environment at: #TPoint2 ifAbsent: [ true ]).
	
	builder := Trait << #TPoint2
					slots: { #x . #y };
					package: 'FakedCore'.
	builder install.
	trait := self class environment at: #TPoint2. 
	self assert: trait name equals: #TPoint2.
	self assert: trait slots size equals: 2 ] ensure: [  
			self class environment removeKey: #TPoint2 ifAbsent: [self fail]. 
			self assert: (self class environment at: #TPoint2 ifAbsent: [ true ])]

]

{ #category : #tests }
FluidTraitBuilderTest >> testTraitNoSlotsNoUse [

	| trait |
	builder := Trait << #TPoint3
		package: 'Fake'.
	trait := builder build.
	
	self assert: trait name equals: #TPoint3.
	self assert: trait package packageName equals: '_UnpackagedPackage'
	

]

{ #category : #tests }
FluidTraitBuilderTest >> testTraitUse [
	
	| trait |
	builder := Trait << #TPoint3
		trait: TViewModelMock;
		package: 'Fake'.
	trait := builder build.
	
	self assert: trait name equals: #TPoint3.
	self assert: trait traitComposition innerClass equals: TViewModelMock.
	self assert: trait package packageName equals: '_UnpackagedPackage'
]
