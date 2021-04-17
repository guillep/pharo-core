"
A morph that can expand or collapse to show its contents.
"
Class {
	#name : #ExpanderMorph,
	#superclass : #PanelMorph,
	#instVars : [
		'titleMorph',
		'announcer'
	],
	#category : #'Polymorph-Widgets-Base'
}

{ #category : #'instance creation' }
ExpanderMorph class >> titleText: aStringOrText [
	"Answer a new instance of the receiver with the given title text."

	^self new titleText: aStringOrText
]

{ #category : #operations }
ExpanderMorph >> addedMorph: aMorph [
	"Notify the receiver that the given morph was just added."

	aMorph == self titleMorph ifFalse: [
		self titleMorph ifNotNil: [
			aMorph
				visible: self expanded;
				disableTableLayout: self expanded not]]
]

{ #category : #operations }
ExpanderMorph >> announce: anAnnouncement [
	"see Announcements packages.
	No need to announce if no subscribers."
	
	announcer ifNotNil: [announcer announce: anAnnouncement]
]

{ #category : #accessing }
ExpanderMorph >> announcer [
	"Answer the receiver's announcer, creating if required."
	
	^ announcer ifNil: [ announcer := Announcer new ]
]

{ #category : #accessing }
ExpanderMorph >> announcer: anObject [

	announcer := anObject
]

{ #category : #initialization }
ExpanderMorph >> defaultTitleMorph [
	"Answer a default title morph for the receiver."

	^ExpanderTitleMorph basicNew
		basicTheme: self theme;
		initialize;
		hResizing: #spaceFill;
		vResizing: #shrinkWrap;
		basicTheme: nil
]

{ #category : #accessing }
ExpanderMorph >> expanded [
	"Answer whether the title is expanded."
	
	^self titleMorph expanded
]

{ #category : #accessing }
ExpanderMorph >> expanded: aBoolean [
	"Set whether the title is expanded."
	
	self titleMorph expanded: aBoolean
]

{ #category : #operations }
ExpanderMorph >> expandedSizingRigid [
	"Set the vResizing to be (temporarily) #rigid."

	self expanded ifTrue: [self vResizing: #rigid]
]

{ #category : #operations }
ExpanderMorph >> fixLayout [
	"Fix the owner layout, nasty!"

	self owner ifNil: [ ^ self ].
	self owner
		allMorphsDo: [ :m | 
			(m respondsTo: #resetExtent)
				ifTrue: [ 
					self defer: (MessageSend receiver: m selector: #resetExtent).
					self defer: (MessageSend receiver: m selector: #setScrollDeltas) ].
			(m isKindOf: self class)
				ifTrue: [ self defer: (MessageSend receiver: m selector: #adoptPaneColor) ] ].
	self defer: (MessageSend receiver: self owner selector: #changed)
]

{ #category : #accessing }
ExpanderMorph >> font [
	"Answer the title font"

	^self titleMorph font
]

{ #category : #accessing }
ExpanderMorph >> font: aFont [
	"Set the title font"

	self titleMorph font: aFont
]

{ #category : #initialization }
ExpanderMorph >> initialize [
	"Initialize the receiver."

	super initialize.
	self
		changeTableLayout;
		listDirection: #topToBottom;
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		titleMorph: self defaultTitleMorph;
		expanded: false
]

{ #category : #operations }
ExpanderMorph >> showMorphs: aBoolean [
	"Hide/Show the other morphs."

	self submorphs do: [:m |
		m == self titleMorph ifFalse: [
			m
				visible: aBoolean;
				disableTableLayout: aBoolean not]]
]

{ #category : #accessing }
ExpanderMorph >> titleMorph [
	"Answer the value of titleMorph"

	^ titleMorph
]

{ #category : #accessing }
ExpanderMorph >> titleMorph: aMorph [
	"Set the value of titleMorph"

	titleMorph ifNotNil: [titleMorph delete; removeDependent: self].
	titleMorph := aMorph.
	aMorph ifNotNil: [
		aMorph addDependent: self.
		 self addMorph: aMorph]
]

{ #category : #operations }
ExpanderMorph >> titleText: aStringOrText [

	self titleMorph titleText: aStringOrText
]

{ #category : #updating }
ExpanderMorph >> update: aspect [
	"Update the receiver."

	aspect = #expanded
		ifTrue: [self spaceFillWeight: (self expanded
					ifTrue: [1]
					ifFalse: [0]).
				self showMorphs: self expanded.
				self fixLayout.
				self expanded
					ifTrue: [self announce: (ExpanderMorphExpanded on: self)]
					ifFalse: [self announce: (ExpanderMorphContracted on: self)]]
]
