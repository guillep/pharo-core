Class {
	#name : #FluidClassDefinitionPrinterTest,
	#superclass : #CommonClassDefinitionPrinterTest,
	#category : #'Kernel-Tests-Fluid'
}

{ #category : #helpers }
FluidClassDefinitionPrinterTest >> expandedForClass: aClass [
	^ (FluidClassDefinitionPrinter for: aClass) expandedDefinitionString 


]

{ #category : #helpers }
FluidClassDefinitionPrinterTest >> forClass: aClass [
	^ (FluidClassDefinitionPrinter for: aClass) definitionString 


]

{ #category : #running }
FluidClassDefinitionPrinterTest >> setUp [

	super setUp.
	ClassDefinitionPrinter showFluidClassDefinition: true
]

{ #category : #'tests - classes' }
FluidClassDefinitionPrinterTest >> testArray [

	self 
		assert: (self forClass: Array)
		equals: 'ArrayedCollection << #Array
	layout: VariableLayout;
	tag: ''Base'';
	package: ''Collections-Sequenceable'''
]

{ #category : #'tests - classes' }
FluidClassDefinitionPrinterTest >> testArrayedCollectionWithPoolDictionary [

	self assert: (self forClass: ExampleForTestWithSharedPool) equals: 'ArrayedCollection << #ExampleForTestWithSharedPool
	sharedPools: { ChronologyConstants };
	tag: ''Classes'';
	package: ''Kernel-Tests''' 
]

{ #category : #'tests - classes' }
FluidClassDefinitionPrinterTest >> testByteString [

	self assert: (self forClass: ByteString) equals: 'String << #ByteString
	layout: ByteLayout;
	sharedVariables: { #NonAsciiMap };
	tag: ''Base'';
	package: ''Collections-Strings'''  
]

{ #category : #'tests - classes' }
FluidClassDefinitionPrinterTest >> testChronologyConstants [

	self
		assert: (self forClass: ChronologyConstants)
		equals: 'SharedPool << #ChronologyConstants
	sharedVariables: { #NanosInSecond . #MonthNames . #SecondsInHour . #SecondsInDay . #DayNames . #DaysInMonth . #HoursInDay . #NanosInMillisecond . #SecondsInMinute . #SqueakEpoch . #MinutesInHour . #MicrosecondsInDay };
	tag: ''Chronology'';
	package: ''Kernel'''
]

{ #category : #'tests - complex slots' }
FluidClassDefinitionPrinterTest >> testClassDefinitionWithComplexSlotShouldBeDisplayedAsFluid [

	ClassDefinitionPrinter showFluidClassDefinition: false.
	self assert: MockWithComplexSlot needsSlotClassDefinition.

	self 
		assert: (self forClass: MockWithComplexSlot) 
		equals: 'Object << #MockWithComplexSlot
	slots: { #aComplexSlot => ObservableSlot };
	tag: ''Fluid'';
	package: ''Kernel-Tests''' 
]

{ #category : #'tests - template' }
FluidClassDefinitionPrinterTest >> testCompactClassTemplate [

	self 
		assert: (FluidClassDefinitionPrinter new compactClassDefinitionTemplateInPackage: 'Kernel') 
		equals:  'Object << #MyClass
	slots: {};
	sharedVariables: {};
	package: ''Kernel'''
]

{ #category : #'tests - complex slots' }
FluidClassDefinitionPrinterTest >> testDefinitionWithComplexSlot [
	"Fluid definition support complex slots."
	
	self assert: (self forClass: MockWithComplexSlot) equals: 'Object << #MockWithComplexSlot
	slots: { #aComplexSlot => ObservableSlot };
	tag: ''Fluid'';
	package: ''Kernel-Tests''' 
]

{ #category : #'tests - unnecessary values' }
FluidClassDefinitionPrinterTest >> testDisplayEmptySlots [
	"I would like to be able to test if I provide too many empty values that
	the default empty values are just ignored."
	| class |
	ClassDefinitionPrinter displayEmptySlots: true.
	class := (Object << #CDFluidMock
	slots: {};
	tag: 'BasicObjects';
	package: 'Kernel') build.
	self assert: (self forClass: class) equals: 'Object << #CDFluidMock
	slots: {};
	package: ''_UnpackagedPackage'''
	
]

{ #category : #'tests - unnecessary values' }
FluidClassDefinitionPrinterTest >> testDoesNotDisplayEmptySlots [

	| class |
	ClassDefinitionPrinter displayEmptySlots: false.
	class := (Object << #CDFluidMock
	slots: {};
	tag: 'BasicObjects';
	package: 'Kernel') build.
	self assert: (self forClass: class) equals: 'Object << #CDFluidMock
	package: ''_UnpackagedPackage'''
	
]

{ #category : #'tests - expanded' }
FluidClassDefinitionPrinterTest >> testExpandedEmptyLayoutClass [

	self 
		assert: (self expandedForClass: EmptyLayout class)  
		equals: 'EmptyLayout class
	uses: {};
	slots: { #instance }'
]

{ #category : #'tests - expanded' }
FluidClassDefinitionPrinterTest >> testExpandedOnClassWithoutTag [

	self 
		assert: (self expandedForClass: EncoderForV3PlusClosures)
		equals:   'BytecodeEncoder << #EncoderForV3PlusClosures
	layout: FixedLayout;
	uses: {};
	slots: {};
	sharedVariables: {};
	sharedPools: {};
	tag: '''';
	package: ''Kernel-BytecodeEncoders'''
]

{ #category : #'tests - expanded' }
FluidClassDefinitionPrinterTest >> testExpandedPoint [

	self 
		assert: (self expandedForClass: Point) 
		equals: 'Object << #Point
	layout: FixedLayout;
	uses: {};
	slots: { #x . #y };
	sharedVariables: {};
	sharedPools: {};
	tag: ''BasicObjects'';
	package: ''Kernel''' 
	
]

{ #category : #'tests - expanded' }
FluidClassDefinitionPrinterTest >> testExpandedTime [

	self 
		assert: (self expandedForClass: Time)  
		equals: 'Magnitude << #Time
	layout: FixedLayout;
	uses: {};
	slots: { #seconds . #nanos };
	sharedVariables: {};
	sharedPools: { ChronologyConstants };
	tag: ''Chronology'';
	package: ''Kernel'''
]

{ #category : #'tests - template' }
FluidClassDefinitionPrinterTest >> testFullClassTemplate [

	self 
		assert: (FluidClassDefinitionPrinter new classDefinitionTemplateInPackage: 'Kernel') 
		equals:  'Object << #MyClass
	layout: FixedLayout;
	uses: {};
	slots: {};
	sharedVariables: {};
	sharedPools: {};
	tag: '''' ;
	package: ''Kernel'''
		
]

{ #category : #'tests - metaclasses' }
FluidClassDefinitionPrinterTest >> testMetaclass [
	
	self assert: (self forClass: Metaclass) equals: 'ClassDescription << #Metaclass
	slots: { #thisClass };
	tag: ''Classes'';
	package: ''Kernel''' 
]

{ #category : #'tests - metaclasses' }
FluidClassDefinitionPrinterTest >> testMetaclassClass [
	
	self assert: (self forClass: Metaclass class) equals: 
 'Metaclass class'	
]

{ #category : #'tests - classes' }
FluidClassDefinitionPrinterTest >> testPoint [
	
	self assert: (self forClass: Point) equals: 'Object << #Point
	slots: { #x . #y };
	tag: ''BasicObjects'';
	package: ''Kernel'''
	
]

{ #category : #'tests - unnecessary values' }
FluidClassDefinitionPrinterTest >> testPointMinimalInformation [
	"I would like to be able to test if I provide too many empty values that
	the default empty values are just ignored."
	| class |
	class := (Object << #CDFluidMock
	slots: {#x . #y};
	tag: 'BasicObjects';
	package: 'Kernel') build.
	"I cannot test the tag because the class is not installed so the package manager
	does not know the package and the class."
	self assert: (self forClass: class) equals: 'Object << #CDFluidMock
	slots: { #x . #y };
	package: ''_UnpackagedPackage'''
	
]

{ #category : #'tests - classes' }
FluidClassDefinitionPrinterTest >> testProtoObject [
	
	self assert: (self forClass: ProtoObject) equals: 'nil << #ProtoObject
	tag: ''Objects'';
	package: ''Kernel''' 
]

{ #category : #'tests - classes' }
FluidClassDefinitionPrinterTest >> testProtoObjectClass [
	
	self assert: (self forClass: ProtoObject class) equals: 'ProtoObject class'
]

{ #category : #'tests - metaclasses' }
FluidClassDefinitionPrinterTest >> testSystemAnnouncerClass [
	
	self assert: (self forClass: SystemAnnouncer class) equals: 'SystemAnnouncer class
	slots: { #announcer }'
]
