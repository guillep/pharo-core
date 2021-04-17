Extension { #name : #CompositionScanner }

{ #category : #'*Deprecated90' }
CompositionScanner >> registerBreakableIndex [
	"Record left x and character index of the line-wrappable point. 
	Used for wrap-around in eastern Asian languages."
	
	self deprecated: 'only sender was deprecated in Pharo9'.
	spaceX := destX.
	lineHeightAtSpace := lineHeight.
	baselineAtSpace := baseline.
	spaceIndex := lastIndex.
	lastBreakIsNotASpace := true.
]
