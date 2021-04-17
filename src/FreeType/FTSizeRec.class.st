"
I map the FT_SizeRec type.
"
Class {
	#name : #FTSizeRec,
	#superclass : #FFIExternalStructure,
	#classVars : [
		'OFFSET_FACE',
		'OFFSET_GENERIC',
		'OFFSET_INTERNAL',
		'OFFSET_METRICS'
	],
	#pools : [
		'FT2Types'
	],
	#category : #'FreeType-Bindings'
}

{ #category : #'field definition' }
FTSizeRec class >> fieldsDesc [

	"self rebuildFieldAccessors"

	^ #(
	 FT_Face           face;
    FT_Generic        generic;
    FT_Size_Metrics   metrics;
    FT_Size_Internal  internal;	
)
]

{ #category : #'accessing structure variables' }
FTSizeRec >> face [
	"This method was automatically generated"
	^FTFaceRec fromHandle: (handle pointerAt: OFFSET_FACE)
]

{ #category : #'accessing structure variables' }
FTSizeRec >> face: anObject [
	"This method was automatically generated"
	handle pointerAt: OFFSET_FACE put: anObject getHandle.
]

{ #category : #'accessing structure variables' }
FTSizeRec >> generic [
	"This method was automatically generated"
	^ FTGeneric fromHandle: (handle referenceStructAt: OFFSET_GENERIC length: FTGeneric byteSize)
]

{ #category : #'accessing structure variables' }
FTSizeRec >> generic: anObject [
	"This method was automatically generated"
	handle structAt: OFFSET_GENERIC put: anObject getHandle length: FTGeneric byteSize
]

{ #category : #'accessing structure variables' }
FTSizeRec >> internal [
	"This method was automatically generated"
	^ExternalData fromHandle: (handle pointerAt: OFFSET_INTERNAL) type: ExternalType void asPointerType
]

{ #category : #'accessing structure variables' }
FTSizeRec >> internal: anObject [
	"This method was automatically generated"
	handle pointerAt: OFFSET_INTERNAL put: anObject getHandle.
]

{ #category : #'accessing structure variables' }
FTSizeRec >> metrics [
	"This method was automatically generated"
	^ FTSizeMetrics fromHandle: (handle referenceStructAt: OFFSET_METRICS length: FTSizeMetrics byteSize)
]

{ #category : #'accessing structure variables' }
FTSizeRec >> metrics: anObject [
	"This method was automatically generated"
	handle structAt: OFFSET_METRICS put: anObject getHandle length: FTSizeMetrics byteSize
]
