"
I represent a scaled decimal.
I am stored as a Fraction (check HEFraction class) but also adding the scale.
The scale is stored as a exported literal.
"
Class {
	#name : #HEScaledDecimal,
	#superclass : #HEFraction,
	#category : #'Hermes-Model'
}

{ #category : #accessing }
HEScaledDecimal class >> tag [ 
	^ 25
]

{ #category : #reading }
HEScaledDecimal >> doReadFrom: aReader [
	| scale |
	super doReadFrom: aReader.
	scale := HEExportedLiteral readFrom: aReader.
	
	value := ScaledDecimal newFromNumber: value scale: scale value.
	
	
]
