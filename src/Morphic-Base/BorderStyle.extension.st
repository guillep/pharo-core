Extension { #name : #BorderStyle }

{ #category : #'*Morphic-Base' }
BorderStyle class >> complexAltFramed [
	^ComplexBorderStyle style: #complexAltFramed
]

{ #category : #'*Morphic-Base' }
BorderStyle class >> complexAltInset [
	^ComplexBorderStyle style: #complexAltInset
]

{ #category : #'*Morphic-Base' }
BorderStyle class >> complexAltRaised [
	^ComplexBorderStyle style: #complexAltRaised
]

{ #category : #'*Morphic-Base' }
BorderStyle class >> complexFramed [
	^ComplexBorderStyle style: #complexFramed
]

{ #category : #'*Morphic-Base' }
BorderStyle class >> complexInset [
	^ComplexBorderStyle style: #complexInset
]

{ #category : #'*Morphic-Base' }
BorderStyle class >> complexRaised [
	^ComplexBorderStyle style: #complexRaised
]

{ #category : #'*Morphic-Base' }
BorderStyle class >> inset [
	^InsetBorderStyle new
]

{ #category : #'*Morphic-Base' }
BorderStyle class >> raised [
	^RaisedBorderStyle new
]

{ #category : #'*Morphic-Base' }
BorderStyle class >> simple [
	"Answer a simple border style"

	^ SimpleBorderStyle new
]

{ #category : #'*Morphic-Base' }
BorderStyle class >> width: aNumber color: aColor [
	^SimpleBorderStyle new color: aColor; width: aNumber; yourself
]
