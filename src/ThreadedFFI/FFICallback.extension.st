Extension { #name : #FFICallback }

{ #category : #'*ThreadedFFI' }
FFICallback >> beFailed [

	^ self backendCallback beFailed
]

{ #category : #'*ThreadedFFI' }
FFICallback >> beSuccess [

	^ self backendCallback beSuccess
]

{ #category : #'*ThreadedFFI' }
FFICallback >> isSuccess [

	^ self backendCallback isSuccess
]

{ #category : #'*ThreadedFFI' }
FFICallback >> tfPointerAddress [

	^ self getHandle tfPointerAddress
]

{ #category : #'*ThreadedFFI' }
FFICallback >> tfPrintString [

	^ block printString
]
