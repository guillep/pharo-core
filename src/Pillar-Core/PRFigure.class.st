"
I'm a Figure.
I can have a label and a caption in parameter. 
My alias (inherited) represents the figure caption.

```
+A nice caption for our nice figure.>file://figures/pharo-logo.png|width=50|label=pharoLogo+
```
"
Class {
	#name : #PRFigure,
	#superclass : #PRReference,
	#category : #'Pillar-Core-Model'
}

{ #category : #testing }
PRFigure class >> extensionOf: aString isOneOf: extensions [
	| extension |
	extension := (aString splitOn: $.) last asLowercase.
	^ extensions includes: extension
]

{ #category : #testing }
PRFigure class >> isValidReference: aString [
	^ (self extensionOf: aString isOneOf: self pictureExtensions)
		and: [ aString includesSubstring: '://' caseSensitive: true ]
]

{ #category : #private }
PRFigure class >> pictureExtensions [
	^ #('png' 'jpg' 'jpeg' 'pdf')
]

{ #category : #visiting }
PRFigure >> accept: aVisitor [
	^ aVisitor visitFigure: self
]

{ #category : #testing }
PRFigure >> hasCaption [
	^ self hasChildren
]

{ #category : #testing }
PRFigure >> hasFigureExtension [
	^ self class pictureExtensions includes: self reference asFileReference extension
]

{ #category : #testing }
PRFigure >> hasLabel [
	^ self label isNotNil
]

{ #category : #accessing }
PRFigure >> label [
	^ self parameters at: 'label' ifAbsent: [ nil ]
]

{ #category : #accessing }
PRFigure >> label: aString [
	self parameters at: 'label' put: aString
]

{ #category : #accessing }
PRFigure >> pathInternFile [
	| path |
	path := self reference.
	(path beginsWith: 'file://') ifTrue: [ path := path allButFirst: 7 ].
	^ path
]
