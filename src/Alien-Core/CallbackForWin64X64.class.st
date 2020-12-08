"
A CallbackForWin64X64 is a callback for platforms with x64/x86_64 processors using the Win64 ABI.
"
Class {
	#name : #CallbackForWin64X64,
	#superclass : #Callback,
	#category : #'Alien-Core'
}

{ #category : #accessing }
CallbackForWin64X64 class >> abi [
	^'X64Win64'
]

{ #category : #'class initialization' }
CallbackForWin64X64 class >> isForCurrentPlatform [

	^ Win64Platform isActivePlatform
]

{ #category : #signatures }
CallbackForWin64X64 >> hwndlparamRetbool: callbackContext regs: regsAlien [
	<signature: #(BOOL CALLBACK (*)(HWND, LPARAM))>
	^callbackContext wordResult:
		(block
			value: (Alien forPointer: (regsAlien unsignedLongLongAt: 1))
			value: (regsAlien unsignedLongLongAt: 9)) asAlien "i.e. coerce true to 1 and false to 0"
]

{ #category : #signatures }
CallbackForWin64X64 >> intcharstarRetint: callbackContext regs: regsAlien [
	<signature: #(int (*)(int, char *))>
	^callbackContext wordResult:
		(block
			value: (regsAlien signedLongLongAt: 1)
			value: (Alien forPointer: (regsAlien unsignedLongLongAt: 9)))
]

{ #category : #signatures }
CallbackForWin64X64 >> logfontstartextmetricstardwordlparamRetint: callbackContext regs: regsAlien [
	<signature: #(int CALLBACK (*)(const LOGFONT *, const TEXTMETRIC *, DWORD, LPARAM))>
	^callbackContext wordResult:
		(block
			value: (Alien forPointer: (regsAlien unsignedLongLongAt: 1))
			value: (Alien forPointer: (regsAlien unsignedLongLongAt: 9))
			value: (regsAlien unsignedLongAt: 17)
			value: (regsAlien signedLongLongAt: 25))
]

{ #category : #evaluation }
CallbackForWin64X64 >> valueInContext: callbackContext [ "<VMCallbackContext32|VMCallbackContext64> ^<Integer>"
	numEvaluatorArgs = 2 ifTrue:
		[^self perform: evaluator
			with: callbackContext
			with: callbackContext stackp].
	numEvaluatorArgs = 3 ifTrue:
		[^self perform: evaluator
			with: callbackContext
			with: callbackContext intregargsp
			with: callbackContext stackp].
	numEvaluatorArgs = 4 ifTrue:
		[^self perform: evaluator
			with: callbackContext
			with: callbackContext intregargsp
			with: callbackContext stackp
			with: callbackContext floatregargsp].
	numEvaluatorArgs = 1 ifTrue: "legacy support"
		[^self perform: evaluator
			with: callbackContext].
	self error: 'invalid evaluator argument count'
]

{ #category : #signatures }
CallbackForWin64X64 >> voidstarvoidstarRetint: callbackContext regs: regsAlien [
	<signature: #(int (*)(const void *, const void *))>
	^callbackContext wordResult:
		(block
			value: (Alien forPointer: (regsAlien unsignedLongLongAt: 1))
			value: (Alien forPointer: (regsAlien unsignedLongLongAt: 9)))
]
