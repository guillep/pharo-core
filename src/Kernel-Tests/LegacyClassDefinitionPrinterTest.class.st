Class {
	#name : #LegacyClassDefinitionPrinterTest,
	#superclass : #CommonClassDefinitionPrinterTest,
	#category : #'Kernel-Tests-Fluid'
}

{ #category : #helpers }
LegacyClassDefinitionPrinterTest >> forClass: aClass [
	^ (ClassDefinitionPrinter legacy for: aClass) definitionString 


]

{ #category : #'tests - classes' }
LegacyClassDefinitionPrinterTest >> testArray [

	self 
		assert: (self forClass: Array) 
		equals: 'ArrayedCollection variableSubclass: #Array
	instanceVariableNames: ''''
	classVariableNames: ''''
	poolDictionaries: ''''
	category: ''Collections-Sequenceable-Base'''
]

{ #category : #'tests - classes' }
LegacyClassDefinitionPrinterTest >> testArrayedCollectionWithPoolDictionary [

	self assert: (self forClass: ExampleForTestWithSharedPool)
		equals: 'ArrayedCollection subclass: #ExampleForTestWithSharedPool
	instanceVariableNames: ''''
	classVariableNames: ''''
	poolDictionaries: ''ChronologyConstants''
	category: ''Kernel-Tests-Classes'''
]

{ #category : #'tests - classes' }
LegacyClassDefinitionPrinterTest >> testByteString [

	self 
		assert: (self forClass: ByteString) 
		equals: 'String variableByteSubclass: #ByteString
	instanceVariableNames: ''''
	classVariableNames: ''NonAsciiMap''
	poolDictionaries: ''''
	category: ''Collections-Strings-Base'''
]

{ #category : #'tests - classes' }
LegacyClassDefinitionPrinterTest >> testChronologyConstants [

	self
		assert: (self forClass: ChronologyConstants)
		equals: 'SharedPool subclass: #ChronologyConstants
	instanceVariableNames: ''''
	classVariableNames: ''DayNames DaysInMonth HoursInDay MicrosecondsInDay MinutesInHour MonthNames NanosInMillisecond NanosInSecond SecondsInDay SecondsInHour SecondsInMinute SqueakEpoch''
	poolDictionaries: ''''
	category: ''Kernel-Chronology'''
]

{ #category : #'tests - metaclasses' }
LegacyClassDefinitionPrinterTest >> testClassSideDoesNotShowPackage [

	self assert: (self forClass: ContextTest class) equals: 'ContextTest class
	instanceVariableNames: '''''
]

{ #category : #'tests - metaclasses' }
LegacyClassDefinitionPrinterTest >> testMetaclass [
	
	self
		assert: (self forClass: Metaclass)
		equals: 'ClassDescription subclass: #Metaclass
	instanceVariableNames: ''thisClass''
	classVariableNames: ''''
	poolDictionaries: ''''
	category: ''Kernel-Classes'''
]

{ #category : #'tests - metaclasses' }
LegacyClassDefinitionPrinterTest >> testMetaclassClass [
	
	self 
		assert: (self forClass: Metaclass class) 
		equals: 'Metaclass class
	instanceVariableNames: '''''	
]

{ #category : #'tests - classes' }
LegacyClassDefinitionPrinterTest >> testPoint [

	self 
		assert: (self forClass: Point)
		equals: 'Object subclass: #Point
	instanceVariableNames: ''x y''
	classVariableNames: ''''
	poolDictionaries: ''''
	category: ''Kernel-BasicObjects'''
]

{ #category : #'tests - classes' }
LegacyClassDefinitionPrinterTest >> testProtoObject [
	
	self
		assert: (self forClass: ProtoObject)
		equals: 'ProtoObject subclass: #ProtoObject
	instanceVariableNames: ''''
	classVariableNames: ''''
	poolDictionaries: ''''
	category: ''Kernel-Objects''.
ProtoObject superclass: nil'
]

{ #category : #'tests - metaclasses' }
LegacyClassDefinitionPrinterTest >> testSystemAnnouncerClass [
	
	self 
		assert: (self forClass: SystemAnnouncer class) 
		equals: 'SystemAnnouncer class
	instanceVariableNames: ''announcer'''
]
