Extension { #name : #Form }

{ #category : #'*Graphics-Files-FileRegistry' }
Form class >> fileReaderServicesForFile: fullName suffix: suffix [
	<fileService>

	^((ImageReadWriter allTypicalFileExtensions add: '*'; add: 'form'; yourself)
		includes: suffix)
		ifTrue: [ self services ]
		ifFalse: [#()]

]

{ #category : #'*Graphics-Files' }
Form class >> fromBase64String: aBase64EncodedString [
	"Convenient method to instantiate a Form from an image content encoded in base64 (used to store image data in a method for example".
	"Encoded string can be obtained with:
	(Base64MimeConverter mimeEncode: 'picture.png' asFileReference binaryReadStream) contents."
	
	^ self fromBinaryStream: aBase64EncodedString base64Decoded asByteArray readStream
]

{ #category : #'*Graphics-Files' }
Form class >> fromBinaryStream: aBinaryStream [

	"Read a Form or ColorForm from given file, using the first byte of the file to guess its format. Currently handles: GIF, uncompressed BMP, and new DisplayObject writeOn: formats, JPEG, and PCX. Return nil if the file could not be read or was of an unrecognized format."

	| firstByte |
	firstByte := aBinaryStream peek.
	firstByte = 1 ifTrue: [ ^ self error: 'old ST80 format not supported' ].
	firstByte = 2 ifTrue: [ ^ self new readFrom: aBinaryStream ].

	"Try for JPG, GIF, or PCX..."
	"Note: The following call closes the stream."
	^ ImageReadWriter formFromStream: aBinaryStream
]

{ #category : #'*Graphics-Files' }
Form class >> fromFileNamed: fileName [ 
	"Read a Form or ColorForm from the given file."
	
	^ fileName asFileReference 
			binaryReadStreamDo: [ :in | self fromBinaryStream: in ]
]

{ #category : #'*Graphics-Files-FileRegistry' }
Form class >> openImageInWindow: fullName [ 
	"Handle five file formats: GIF, JPG, PNG, Form storeOn: (run coded), and
	BMP. Fail if file format is not recognized."
	
	| image |
	image := self fromFileNamed: fullName.
	(ImageMorph withForm: image) openInWorld
]

{ #category : #'*Graphics-Files' }
Form >> readNativeResourceFrom: byteStream [
	| img |
	img := [ ImageReadWriter formFromStream: byteStream ]
		on: Error
		do: [ :ex | ^ nil ].
	(img isColorForm and: [ self isColorForm ])
		ifTrue: [ | cc |
			cc := img colors.
			img colors: nil.
			img displayOn: self.
			img colors: cc ]
		ifFalse: [ img displayOn: self ]
]

{ #category : #'*Graphics-Files' }
Form >> readResourceFrom: aStream [ 
	"Store a resource representation of the receiver on aStream.
	Must be specific to the receiver so that no code is filed out."

	| bitsSize msb |
	(aStream next: 4) asString = self resourceTag 
		ifFalse: 
			[aStream position: aStream position - 4.
			^self readNativeResourceFrom: aStream].
	width := aStream nextNumber: 4.
	height := aStream nextNumber: 4.
	depth := aStream nextNumber: 4.
	bitsSize := aStream nextNumber: 4.
	bitsSize = 0 
		ifFalse: 
			[bits := aStream next: bitsSize.
			^self].
	msb := (aStream nextNumber: 4) = 1.
	bitsSize := aStream nextNumber: 4.
	bits := Bitmap new: self bitsSize.
	(Form 
		extent: width @ height
		depth: depth
		bits: (aStream next: bitsSize * 4)) displayOn: self.
	msb = EndianDetector isBigEndian 
		ifFalse: 
			[Bitmap 
				swapBytesIn: bits
				from: 1
				to: bits size]
]

{ #category : #'*Graphics-Files' }
Form >> resourceTag [
	^'FORM'
]

{ #category : #'*Graphics-Files-FileRegistry' }
Form class >> serviceImageAsBackground [
	"Answer a service for setting the desktop background from a given graphical file's contents"
	<formService>
	^ SimpleServiceEntry 
		provider: self 
		label: 'Use graphic as background'
		selector: #setBackgroundFromImageFileNamed:
		description: 'Use the graphic as the background for the desktop'
		buttonLabel: 'Background'
]

{ #category : #'*Graphics-Files-FileRegistry' }
Form class >> serviceOpenImageInWindow [
	"Answer a service for opening a graphic in a window"
	<formService>
	^ SimpleServiceEntry 
		provider: self 
		label: 'Open graphic in a window'
		selector: #openImageInWindow:
		description: 'Open a graphic file in a window'
		buttonLabel: 'Open'
]

{ #category : #'*Graphics-Files-FileRegistry' }
Form class >> services [
	"Defines what options are available when a user drags and drop an image file (jpeg, png...) onto the pharo image. These options are defined by methods with the #formService pragma on this class."
	| services |
	services := OrderedCollection new.
	(Pragma allNamed: #formService in: self class) do: [:pragma | 
		pragma method selector isUnary ifTrue: [  
			services add: (self perform: (pragma method selector))
		]
	].
	^ services asArray.
]

{ #category : #'*Graphics-Files-FileRegistry' }
Form class >> setBackgroundFromImageFileNamed: aFileName [

	(self fromFileNamed: aFileName) setAsBackground
]

{ #category : #'*Graphics-Files' }
Form >> storeResourceOn: aStream [
	"Store a resource representation of the receiver on aStream.
	Must be specific to the receiver so that no code is filed out."
	self hibernate.
	aStream nextPutAll: self resourceTag asByteArray. "tag"
	aStream nextNumber: 4 put: width.
	aStream nextNumber: 4 put: height.
	aStream nextNumber: 4 put: depth.
	(bits isMemberOf: ByteArray) ifFalse:
		"must store bitmap"
		[aStream nextNumber: 4 put: 0. "tag"
		aStream nextNumber: 4 put: (EndianDetector isBigEndian ifTrue:[1] ifFalse: [0])].
	aStream nextNumber: 4 put: bits size.
	aStream nextPutAll: bits.

]

{ #category : #'*Graphics-Files' }
Form >> writeBMPfileNamed: fName [  "Display writeBMPfileNamed: 'display.bmp'"
	BMPReadWriter putForm: self onFileNamed: fName
]

{ #category : #'*Graphics-Files' }
Form >> writeJPEGfileNamed: fileName [ 
	"Write a JPEG file to the given filename using default settings"

	self writeJPEGfileNamed: fileName progressive: false

"
Display writeJPEGfileNamed: 'display.jpeg'
Form fromUser writeJPEGfileNamed: 'yourPatch.jpeg'
"
]

{ #category : #'*Graphics-Files' }
Form >> writeJPEGfileNamed: fileName  progressive: aBoolean [
	"Write a JPEG file to the given filename using default settings.  Make it progressive or not, depending on the boolean argument"

	PluginBasedJPEGReadWriter putForm: self quality: -1 "default" progressiveJPEG: aBoolean onFileNamed: fileName

"
Display writeJPEGfileNamed: 'display.jpeg' progressive: false.
Form fromUser writeJPEGfileNamed: 'yourPatch.jpeg' progressive: true
"
]

{ #category : #'*Graphics-Files' }
Form >> writeOnMovie: file [
	"Write just my bits on the file."
	self unhibernate.
	bits writeUncompressedOn: file
]

{ #category : #'*Graphics-Files' }
Form >> writePNGFileNamed: fileName [  
	PNGReadWriter putForm: self onFileNamed: fileName
]
