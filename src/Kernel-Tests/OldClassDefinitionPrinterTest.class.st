Class {
	#name : #OldClassDefinitionPrinterTest,
	#superclass : #CommonClassDefinitionPrinterTest,
	#category : #'Kernel-Tests-Fluid'
}

{ #category : #helpers }
OldClassDefinitionPrinterTest >> forClass: aClass [
	^ (OldPharoClassDefinitionPrinter for: aClass) definitionString 


]

{ #category : #running }
OldClassDefinitionPrinterTest >> setUp [

	super setUp.
	ClassDefinitionPrinter showFluidClassDefinition: false
]

{ #category : #'tests - classes' }
OldClassDefinitionPrinterTest >> testArray [

	self 
		assert: (self forClass: Array) 
		equals: 'ArrayedCollection variableSubclass: #Array
	instanceVariableNames: ''''
	classVariableNames: ''''
	package: ''Collections-Sequenceable-Base'''
]

{ #category : #'tests - classes' }
OldClassDefinitionPrinterTest >> testArrayedCollectionWithPoolDictionary [

	self assert: (self forClass: ExampleForTestWithSharedPool) equals: 'ArrayedCollection subclass: #ExampleForTestWithSharedPool
	instanceVariableNames: ''''
	classVariableNames: ''''
	poolDictionaries: ''ChronologyConstants''
	package: ''Kernel-Tests-Classes'''
]

{ #category : #'tests - classes' }
OldClassDefinitionPrinterTest >> testByteString [

	self 
		assert: (self forClass: ByteString) 
		equals: 'String variableByteSubclass: #ByteString
	instanceVariableNames: ''''
	classVariableNames: ''NonAsciiMap''
	package: ''Collections-Strings-Base'''
]

{ #category : #'tests - classes' }
OldClassDefinitionPrinterTest >> testChronologyConstants [

	self
		assert: (self forClass: ChronologyConstants)
		equals: 'SharedPool subclass: #ChronologyConstants
	instanceVariableNames: ''''
	classVariableNames: ''DayNames DaysInMonth HoursInDay MicrosecondsInDay MinutesInHour MonthNames NanosInMillisecond NanosInSecond SecondsInDay SecondsInHour SecondsInMinute SqueakEpoch''
	package: ''Kernel-Chronology'''
]

{ #category : #'tests - metaclasses' }
OldClassDefinitionPrinterTest >> testClassSideDoesNotShowPackage [

	self assert: (self forClass: ContextTest class) equals: 'ContextTest class
	instanceVariableNames: '''''
]

{ #category : #'tests - metaclasses' }
OldClassDefinitionPrinterTest >> testMetaclass [
	
	self assert: (self forClass: Metaclass) equals:  'ClassDescription subclass: #Metaclass
	instanceVariableNames: ''thisClass''
	classVariableNames: ''''
	package: ''Kernel-Classes'''
]

{ #category : #'tests - metaclasses' }
OldClassDefinitionPrinterTest >> testMetaclassClass [
	
	self 
		assert: (self forClass: Metaclass class) 
		equals: 'Metaclass class
	instanceVariableNames: '''''	
]

{ #category : #'tests - classes' }
OldClassDefinitionPrinterTest >> testPoint [

	self 
		assert: (self forClass: Point) 
		equals: 'Object subclass: #Point
	instanceVariableNames: ''x y''
	classVariableNames: ''''
	package: ''Kernel-BasicObjects'''
]

{ #category : #'tests - classes' }
OldClassDefinitionPrinterTest >> testProtoObject [
	
	self assert: (self forClass: ProtoObject) equals: 'ProtoObject subclass: #ProtoObject
	instanceVariableNames: ''''
	classVariableNames: ''''
	package: ''Kernel-Objects''.
ProtoObject superclass: nil'
		
 
]

{ #category : #'tests - metaclasses' }
OldClassDefinitionPrinterTest >> testSystemAnnouncerClass [
	
	self 
		assert: (self forClass: SystemAnnouncer class) 
		equals: 'SystemAnnouncer class
	instanceVariableNames: ''announcer'''
]
