"
! Stylesheets for Morphic backend

A style is a property container to ""style"" morphic components, and define (in a certain degree) its behaviour within the different layouts implemented.
There are two kinds of style elements: style classes and style properties.

!! Stylesheet STON format
To easy the definition and storage outside an image, a stylesheet may be defined as a STON file, string or stream, that you can later read using *class:SpStyleSTONReader*.
A defined stylesheet has to have always a root element, and this root element needs to be called ==.application==. 

See this small example: 

[[[language=Smalltalk
SpStyleSTONReader fromString: '
.application [  
	.myButton [
		Geometry { #width: 150 }
	]
]'
]]]

As a more complex example, see *method:SpStyle class#createDefaultStyleSheet* who defines the default behaviour of all elements of a Morphic Spec backend.

!! Referencing style elements in your presenters
You can add styles to your presenters easily by using *class:SpAbstractWidgetPresenter>>#addStyle:*

@@TODO more examples

See *class:SpStyleClass*, *class:SpStyleProperty*, *class:SpMorphStyle*
"
Class {
	#name : #SpStyle,
	#superclass : #Object,
	#classVars : [
		'DefaultStyleSheet'
	],
	#category : #'Spec2-Adapters-Morphic-StyleSheet'
}

{ #category : #private }
SpStyle class >> createDefaultStyleSheet [

	^ SpStyleVariableSTONReader fromString: self defaultStyleSheetData
	
]

{ #category : #accessing }
SpStyle class >> defaultStyleSheet [

	self flag: #TODO. "This is wrong. Default style sheet should reside in the Pharo application, 
	but since we do not have that abstraction (yet) in the system, we put it here for now"
	^ DefaultStyleSheet ifNil: [ 
		DefaultStyleSheet := self createDefaultStyleSheet ].

]

{ #category : #private }
SpStyle class >> defaultStyleSheetData [

	^'
.application [
	Font { #name : EnvironmentFont(#default) },
	Geometry { #height: 25 },
	.box [ Geometry { #height: Reset, #vResizing: true, #hResizing: true } ],
	.label [
		Geometry { #hResizing: true, #height: 18 },
		.headerError [ Draw { #color:  #red }  ],
		.headerSuccess [ Draw { #color: #green } ],
		.header [ Draw { #color: Color{ #rgb: 622413393 } } ],
		.shortcut [ Draw { #color: Color{ #rgb: 622413393 } } ],
		.fixed [ Geometry { #hResizing: false, #width: 100 } ],
		.dim [ Draw { #color : Color{ #rgb: 708480675 } } ]
	],
	.link [ Geometry { #hResizing: true } ],
	.button [  
		Geometry { #width: 100 },
		.small [ Geometry { #width: 25, #height: 25 } ]
	],
	.checkBox [  
		Geometry { #hResizing: true },
		.compact [ Geometry { #hResizing: false, #width: 20 } ]
	],
	.radioButton [ Geometry { #hResizing: true } ],
	.dropList [ Geometry { #width: 150, #hResizing: true } ],
	.list [ Geometry { #width: 150, #minHeight: 125, #hResizing: true, #vResizing: true } ],
	.slider [ Geometry { #width: 150, #hResizing: true } ],
	.actionBar [  
		Container { #borderWidth: 0, #padding: 5 },
		Geometry { #width: 150, #height: 29, #hResizing: true, #vResizing: false }
	],
	.menuBar [ Geometry { #width: 150, #hResizing: true } ],
	.actionButton [  
		Geometry { #width: 60, #hResizing: false },
		.showIcon [ Geometry { #width: 25 } ]
	],
	.toolbar [ 
		Geometry { #height: Reset, #hResizing: true },
		.icons [ Geometry { #height: 30 } ],
		.iconsAndLabel [ Geometry { #height: 45 } ]
	],
	.text [ Geometry { #height: Reset } ],
	.code [ Font { #name: EnvironmentFont(#code) } ],
	.codePopover [ 
		Draw { #color : #transparent },
		.button [ Geometry { #width : 25 } ]
	],
	.codePopoverError [ 
		Draw { #backgroundColor: #C20000 },
		Font { #color: #white } 
	],
	.scrollbarPopoverLarge [ Geometry { #height: 350 } ],
	.popover [
		.print [ Draw { #color: EnvironmentColor(#balloonBackground) } ],
		.error [ Draw { #color: #C20000 } ],
		.popoverButton [ Draw { #color: EnvironmentColor(#popoverButton) } ] ],
	.paginator [ Geometry { #height: 20 } ] ]
'
]

{ #category : #'instance creation' }
SpStyle class >> newApplication [

	^ SpStyleClass new 
		name: 'application';
		yourself
]

{ #category : #accessing }
SpStyle class >> reset [ 
	<script>

	DefaultStyleSheet := nil
]

{ #category : #operations }
SpStyle >> applyTo: aMorph [

	self subclassResponsibility
]

{ #category : #testing }
SpStyle >> isStyleClass [

	^ false
]

{ #category : #testing }
SpStyle >> isStyleProperty [

	^ false
]
