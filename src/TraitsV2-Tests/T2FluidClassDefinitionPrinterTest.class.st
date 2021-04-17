Class {
	#name : #T2FluidClassDefinitionPrinterTest,
	#superclass : #T2CommonClassDefinitionPrinterTest,
	#category : #'TraitsV2-Tests'
}

{ #category : #helpers }
T2FluidClassDefinitionPrinterTest >> expandedForClass: aClass [
	^ (FluidClassDefinitionPrinter for: aClass) expandedDefinitionString 

]

{ #category : #helpers }
T2FluidClassDefinitionPrinterTest >> forClass: aClass [
	^ (FluidClassDefinitionPrinter for: aClass) definitionString 


]

{ #category : #running }
T2FluidClassDefinitionPrinterTest >> setUp [

	super setUp.
	ClassDefinitionPrinter showFluidClassDefinition: true
]

{ #category : #'tests - traits' }
T2FluidClassDefinitionPrinterTest >> testAlignmentMorphClass [

	self 
		assert: (self forClass: AlignmentMorph class) 
		equals: 'AlignmentMorph class
	uses: TAbleToRotate classTrait' 
]

{ #category : #'tests - complex slots' }
T2FluidClassDefinitionPrinterTest >> testClassDefinitionWithComplexSlotShouldBeDisplayedAsFluid [

	ClassDefinitionPrinter showFluidClassDefinition: false.
	self assert: TMockWithComplexSlot needsSlotClassDefinition.

	self 
		assert: (self forClass: TMockWithComplexSlot) 
		equals: 'Trait << #TMockWithComplexSlot
	slots: { #complexSlot => ObservableSlot };
	package: ''TraitsV2-Tests''' 
]

{ #category : #'tests - metaclasses' }
T2FluidClassDefinitionPrinterTest >> testClassSideDoesNotShowPackage [

	self assert: (self forClass: MOPTraitTest class) equals: 'MOPTraitTest class'
]

{ #category : #'tests - template' }
T2FluidClassDefinitionPrinterTest >> testCompactTraitFullTemplate [ 

	self 
		assert: (FluidClassDefinitionPrinter new compactTraitDefinitionTemplateInPackage: 'TraitsV2') equals: 'Trait << #TMyTrait
	uses: {};
	slots: {};
	package: ''TraitsV2'''
]

{ #category : #'tests - traits' }
T2FluidClassDefinitionPrinterTest >> testComplexTrait [

	self assert: (self forClass: MOPTestClassD) equals: 'Object << #MOPTestClassD
	trait: Trait2 @ {#c3->#c2};
	tag: ''Traits-MOP'';
	package: ''Tests''' 
]

{ #category : #'tests - complex slots' }
T2FluidClassDefinitionPrinterTest >> testDefinitionWithComplexSlot [
	"Fluid definition support complex slots."
	
	self assert: (self forClass: TMockWithComplexSlot) equals: 'Trait << #TMockWithComplexSlot
	slots: { #complexSlot => ObservableSlot };
	package: ''TraitsV2-Tests''' 
]

{ #category : #'tests - expanded' }
T2FluidClassDefinitionPrinterTest >> testExpandedEpTEventVisitorClassTrait [

	self 
		assert: (self expandedForClass: EpTEventVisitor classTrait)   
		equals: 'EpTEventVisitor classTrait
	uses: EpTCodeChangeVisitor classTrait;
	slots: {}'
]

{ #category : #'tests - expanded' }
T2FluidClassDefinitionPrinterTest >> testExpandedMetaclassWithTrait [
	
	self assert: (self expandedForClass: MOPTestClassD class) equals: 'MOPTestClassD class
	uses: Trait2 classTrait;
	slots: {}' 
]

{ #category : #'tests - expanded' }
T2FluidClassDefinitionPrinterTest >> testExpandedTComparableClassTrait [

	self 
		assert:  (self expandedForClass: TComparable classTrait) 
		equals:  'TComparable classTrait
	uses: {};
	slots: {}'
	
]

{ #category : #'tests - expanded' }
T2FluidClassDefinitionPrinterTest >> testExpandedTrait3ClassTrait [

	self 
		assert: (self expandedForClass: Trait3 classTrait) 
		equals:  'Trait3 classTrait
	uses: Trait2 classTrait;
	slots: {}'
		
]

{ #category : #'tests - template' }
T2FluidClassDefinitionPrinterTest >> testFullTraitTemplate [

	self 
		assert: (FluidClassDefinitionPrinter new traitDefinitionTemplateInPackage: 'TraitsV2') equals: 'Trait << #TMyTrait
	trait: TEmpty;
	slots: {};
	tag: '''' ;
	package: ''TraitsV2'''
]

{ #category : #'tests - metaclasses' }
T2FluidClassDefinitionPrinterTest >> testMetaclassWithTrait [
	
	self assert: (self forClass: MOPTestClassD class) equals: 'MOPTestClassD class
	uses: Trait2 classTrait' 
]

{ #category : #'tests - traits' }
T2FluidClassDefinitionPrinterTest >> testMultiPools [

	self assert: (self forClass: ClassMultiplePoolUser) equals: 'Object << #ClassMultiplePoolUser
	sharedPools: { PoolDefiner . PoolDefiner2 };
	tag: ''Classes'';
	package: ''Kernel-Tests''' 
]

{ #category : #'tests - traits' }
T2FluidClassDefinitionPrinterTest >> testTBehavior [

	self 
		assert: (self forClass: TBehavior) 
		equals: 'Trait << #TBehavior
	tag: ''Traits'';
	package: ''TraitsV2-Compatibility'''
]

{ #category : #'tests - traits' }
T2FluidClassDefinitionPrinterTest >> testTComparableClassTrait [

	self assert: (self forClass: TComparable classTrait) equals: 'TComparable classTrait' 
]

{ #category : #'tests - traits' }
T2FluidClassDefinitionPrinterTest >> testTEventVisitorClassTrait [

	self assert: (self forClass: EpTEventVisitor classTrait) equals: 'EpTEventVisitor classTrait
	uses: EpTCodeChangeVisitor classTrait'
]

{ #category : #'tests - traits' }
T2FluidClassDefinitionPrinterTest >> testTSlot [

	self 
		assert: (Trait << #TTUses slots: {  #x . #y }; package: 'Fake') build definitionString 
		equals: 
	'Trait << #TTUses
	slots: { #x . #y };
	package: ''_UnpackagedPackage''' 
]

{ #category : #'tests - traits' }
T2FluidClassDefinitionPrinterTest >> testTUses [

	self assert: (Trait << #TTUses trait: TBehavior; package: 'Fake') build definitionString equals:  'Trait << #TTUses
	trait: TBehavior;
	package: ''_UnpackagedPackage'''
]

{ #category : #'tests - traits' }
T2FluidClassDefinitionPrinterTest >> testTrait [
	
	self assert: (self forClass: RubScrolledTextModel) equals: 'Object << #RubScrolledTextModel
	trait: TViewModel;
	slots: { #hasUnacceptedEdits . #announcer . #text . #primarySelectionInterval . #interactionModel };
	tag: ''Editing-Widgets'';
	package: ''Rubric''' 
]

{ #category : #'tests - traits' }
T2FluidClassDefinitionPrinterTest >> testTrait3 [

	self assert: (self forClass: Trait3 classTrait) equals: 'Trait3 classTrait
	uses: Trait2 classTrait'
]

{ #category : #'tests - traits' }
T2FluidClassDefinitionPrinterTest >> testTrait3AndTag [

	self 
		assert: (self forClass: Trait3) 
		equals: 'Trait << #Trait3
	trait: Trait2;
	tag: ''Traits-MOP'';
	package: ''Tests''' 
]
