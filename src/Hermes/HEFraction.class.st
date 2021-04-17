"
I represent a Fraction.
I store myself as two exported literals: the numerator and the denominator.
"
Class {
	#name : #HEFraction,
	#superclass : #HEExportedLiteral,
	#category : #'Hermes-Model'
}

{ #category : #accessing }
HEFraction class >> tag [ 
	^ 24
]

{ #category : #converting }
HEFraction >> asLiteralIn: aFraction [
	^ value
]

{ #category : #reading }
HEFraction >> doReadFrom: aReader [
	| denominator numerator |
	numerator := HEExportedLiteral readFrom: aReader.
	denominator := HEExportedLiteral readFrom: aReader.
	
	value := Fraction numerator: numerator value denominator: denominator value.
]
