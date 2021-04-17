Extension { #name : #SpMorphicTreeTableAdapter }

{ #category : #'*Spec2-Morphic-Backend-Tests' }
SpMorphicTreeTableAdapter >> expandRowAt: anInteger [
	"Click on the iconic button of a row at an index in the tree."

	| evt expandIcon |
	expandIcon := self iconOfRowMorphAt: anInteger.

	evt := MouseButtonEvent new
		setType: nil
		position: expandIcon center
		which: MouseButtonEvent redButton
		buttons: MouseButtonEvent redButton
		hand: nil
		stamp: nil.

	expandIcon mouseDown: evt.
	expandIcon mouseUp: evt
]

{ #category : #'*Spec2-Morphic-Backend-Tests' }
SpMorphicTreeTableAdapter >> iconOfRowMorphAt: anInteger [
	"Return the first icon of a row morph at a certain index in the tree. 
	If it is expandable, it will be an IconicButton, else it will be an empty image morph."

	| row indentCell |
	row := self rowMorphAt: anInteger.
	indentCell := row submorphs anyOne.
	"The expand icon should be an IconicButton"

	^ indentCell submorphs first
]

{ #category : #'*Spec2-Morphic-Backend-Tests' }
SpMorphicTreeTableAdapter >> isRowMorphExpandableAt: anInteger [
	"Return true if the row at the index has an expandable icon. This is specific to FastTable."

	^ (self iconOfRowMorphAt: anInteger) isKindOf: IconicButtonMorph
]

{ #category : #'*Spec2-Morphic-Backend-Tests' }
SpMorphicTreeTableAdapter >> rowMorphAt: anInteger [
	"Return the row morph at an index. Used for tests."

	^ self widget container visibleRowMorphAtIndex: anInteger
]
