"
I am general http repository for monticello.
I support the general protocol for listing files in a remote repository.
"
Class {
	#name : #MCHttpRepository,
	#superclass : #MCFileBasedRepository,
	#instVars : [
		'location',
		'user',
		'password',
		'readerCache'
	],
	#category : #MonticelloRemoteRepositories
}

{ #category : #accessing }
MCHttpRepository class >> baseURL [
	^ ''
]

{ #category : #'instance creation' }
MCHttpRepository class >> basicFromUrl: aZnUrl [
	^ aZnUrl hasUsername
		ifFalse: [ self location: aZnUrl location ]
		ifTrue: [ (self repositoryClassFor: aZnUrl location) new
				location: aZnUrl location;
				user: aZnUrl username;
				password: aZnUrl password;
				yourself  ]
]

{ #category : #initialization }
MCHttpRepository class >> clearPasswords [
	self allSubInstancesDo: [:ea | ea password: ''].

]

{ #category : #'creation template' }
MCHttpRepository class >> creationTemplate [
	^self creationTemplateLocation: self baseURL
		user: ''
		password: ''

]

{ #category : #'creation template' }
MCHttpRepository class >> creationTemplateLocation: location user: user password: password [
	^
self name, '
	location: {1}
	user: {2}
	password: {3}' format: {location printString. user printString. password printString}
]

{ #category : #accessing }
MCHttpRepository class >> description [
	^ 'HTTP'
]

{ #category : #testing }
MCHttpRepository class >> isResponsibleFor: aURLString [
	"Override in subclasses to enable custom instances for certain URLs"
	^ true
]

{ #category : #'instance creation' }
MCHttpRepository class >> location: location [
	^ MCServerRegistry uniqueInstance 
		repositoryAt: location credentialsDo: [ :username :password |
			(self repositoryClassFor: location) new
				location: location;
				user: username;
				password: password;
				yourself ]
]

{ #category : #'instance creation' }
MCHttpRepository class >> location: aUrl user: user password: password [

	| result |
	result := self location: aUrl.
	user ifNotEmpty: [
		result
			user: user;
			password: password ].
	^ result.
]

{ #category : #'instance creation' }
MCHttpRepository class >> pharoInboxRepository [
	^ self location: 'http://smalltalkhub.com/mc/Pharo/Pharo60Inbox/main'.
]

{ #category : #'instance creation' }
MCHttpRepository class >> pharoRepository [
	^ self location: 'http://smalltalkhub.com/mc/Pharo/Pharo60/main'.
]

{ #category : #'instance creation' }
MCHttpRepository class >> project: aProjectIdentifier [
	^ self location: self baseURL, aProjectIdentifier
]

{ #category : #'instance creation' }
MCHttpRepository class >> repositoryClassFor: location [
	MCHttpRepository subclassesDo: [ :subclass | 
		(subclass isResponsibleFor: location)
			ifTrue: [ ^ subclass ]].
	^ MCHttpRepository
]

{ #category : #accessing }
MCHttpRepository class >> urlSchemes [
	^ #(http https)
]

{ #category : #converting }
MCHttpRepository >> asCreationTemplate [
	^self class creationTemplateLocation: self location user: user password: password
]

{ #category : #private }
MCHttpRepository >> assertBinaryResponse: response [ 

	response contentType isBinary ifFalse: [ 
		MCRepositoryError signal: 'Expected a binary response instead of ', response contentType printString ].
]

{ #category : #private }
MCHttpRepository >> assertNonBinaryResponse: response [ 
	
	response contentType isBinary ifTrue: [ MCRepositoryError signal: 'Did not expect a binary response but got ', response contentType printString ].
]

{ #category : #'i/o' }
MCHttpRepository >> cacheRawVersionNamed: aString stream: contents [
	"directly forward the contents to the cache repository. 
	this avoids and unnecessary serialization step"
	MCCacheRepository uniqueInstance 
		writeStreamForFileNamed: aString 
		replace: true 
		do: [ :s| s nextPutAll: contents ]
]

{ #category : #accessing }
MCHttpRepository >> credentials [
	^ MCServerCredentials user: self user password: self password
]

{ #category : #accessing }
MCHttpRepository >> credentials: mcServerCredentials [
	self user: mcServerCredentials username.
	self password: mcServerCredentials password.
]

{ #category : #accessing }
MCHttpRepository >> description [
	^ self location
]

{ #category : #'i/o' }
MCHttpRepository >> displayProgress: label during: workBlock [
	| nextUpdateTime |
	nextUpdateTime := 0.
	^UIManager default displayProgress: label 
		from: 0.0 to: 1.0 during:[:bar|
			[workBlock value] on: HTTPProgress do:[:ex|
				(ex total == nil or: [ex amount == nil]) ifFalse:[
					(nextUpdateTime < Time millisecondClockValue 
						or:[ex total = ex amount]) ifTrue:[
							bar current: ex amount asFloat / ex total asFloat.
							nextUpdateTime := Time millisecondClockValue + 100.
					].
				].
				ex resume.
			]
		].

]

{ #category : #printing }
MCHttpRepository >> displayStringOn: aStream [
	aStream nextPutAll: self location
]

{ #category : #private }
MCHttpRepository >> entityStreamContents: aBlock [
	"Generate output in a buffer because we need the length"
	
	| stream |
	stream := ReadWriteStream on: ByteArray new.
	aBlock value: stream.
	stream reset.
	^ (ZnStreamingEntity type: ZnMimeType applicationOctetStream)
		stream: stream;
		contentLength: stream size;
		yourself
]

{ #category : #actions }
MCHttpRepository >> flushCache [
	super flushCache.
	readerCache := nil.
]

{ #category : #'i/o' }
MCHttpRepository >> handleUnsuccessfulResponse: aZnResponse [
	(#(403 401) includes: aZnResponse code)
		ifTrue: [ MCPermissionDenied signalFor: self ].
	Error signal: 'Could not save version.'
]

{ #category : #private }
MCHttpRepository >> httpClient [
	"Return a new, specifically configured instance of the HTTP client for internal use.
	Note how we request GZIP compression and will signal progress."

	^ ZnClient new
		systemPolicy;
		beOneShot;
		username: self user password: self password;
	
		signalProgress: true;
		yourself
]

{ #category : #'i/o' }
MCHttpRepository >> loadAllFileNames [
	| client |
	self displayProgress: 'Loading all file names from ', self description during: [
		client := self httpClient.
		client
			ifFail: [ :exception | 
				(exception className beginsWith: 'Zn')
					ifTrue: [ MCRepositoryError signal: 'Could not access ', self location, ': ', exception printString ]
					ifFalse: [ exception pass ] ];
			url: self locationWithTrailingSlash;
			queryAt: 'C' put: 'M;O=D';	"legacy that some servers maybe expect"
			get.
		self assertNonBinaryResponse: client response ].
	^ self parseFileNamesFromStream: client contents readStream
]

{ #category : #accessing }
MCHttpRepository >> location [
	^ location
]

{ #category : #accessing }
MCHttpRepository >> location: aUrlString [
	location := aUrlString
]

{ #category : #actions }
MCHttpRepository >> locationWithTrailingSlash [
	^ (self location endsWith: '/')
		ifTrue: [self location]
		ifFalse: [self location, '/']
]

{ #category : #actions }
MCHttpRepository >> parseFileNamesFromStream: aStream [
	| names fullName |
	names := OrderedCollection new.
	[aStream atEnd] whileFalse:
		[[aStream upTo: $<. {$a. $A. nil} includes: aStream next] whileFalse.
		aStream upTo: $".
		aStream atEnd ifFalse: [
			fullName := aStream upTo: $".
			names add: fullName urlDecoded ]].
	^ names
]

{ #category : #actions }
MCHttpRepository >> password [
	self userAndPasswordFromSettingsDo: [:usr :pwd | ^pwd].

	self user isEmpty ifTrue: [^password ifNil: ['']].

	password isEmptyOrNil ifTrue: [
		| answer |
		user isEmptyOrNil ifTrue: [
			"Give the user a chance to change the login"
			answer := UIManager default request: 'User name for ', String cr, location
				initialAnswer: ''.
			answer isEmptyOrNil
				ifTrue: [^password]
				ifFalse: [self user: answer] ].
		
		password := UIManager default requestPassword: 'Password for "', self user, '" at ', String cr, self location.
		"The user doesn't care about logging into this repo. Clear the username so they will not be prompted every time"
		password isEmptyOrNil ifTrue: [ user := '' ].
	].

	^ password
]

{ #category : #accessing }
MCHttpRepository >> password: passwordString [
	password := passwordString
]

{ #category : #accessing }
MCHttpRepository >> project [
	"Return a project name"
	^ (self location splitOn: $/) last
]

{ #category : #'i/o' }
MCHttpRepository >> readStreamForFileNamed: aString do: aBlock [
	| client |
	self displayProgress: 'Downloading ', aString during: [
		client := self httpClient.
		client
			ifFail: [ :exception | self error: 'Could not load ', aString, ': ', exception printString ];
			get: (self urlForFileNamed: aString).
		self assertBinaryResponse: client response.
		"immediately cache the version and avoid an unnecessary serialization"
		self cacheRawVersionNamed: aString stream: client contents ].
	^ aBlock value: client contents readStream
]

{ #category : #actions }
MCHttpRepository >> retryOnCredentialRequest: aBlock [
	aBlock	on: MCPermissionDenied do: [ :error | |credentials| 
		credentials := MCCredentialsRequest 
							signalUrl: self location
							username: self user
							password: self password.
		credentials 
			ifNotNil: [ 
				self credentials: credentials.
				^ self retryOnCredentialRequest: aBlock ]]
]

{ #category : #storing }
MCHttpRepository >> storeVersion: aVersion [
	self retryOnCredentialRequest: [ super storeVersion: aVersion ]
]

{ #category : #actions }
MCHttpRepository >> urlForFileNamed: aString [
	^ self locationWithTrailingSlash, aString urlEncoded
]

{ #category : #accessing }
MCHttpRepository >> user [
	self userAndPasswordFromSettingsDo: [:usr :pwd | ^usr].
	"not in settings"
	user isEmptyOrNil ifFalse: [ ^user ].
	^ ''
]

{ #category : #accessing }
MCHttpRepository >> user: userString [
	user := userString
]

{ #category : #actions }
MCHttpRepository >> userAndPasswordFromSettingsDo: aBlock [
	"The mcSettings file in ExternalSettings preferenceDirectory should contain entries for each account:
	
		account1: *myhost.mydomain* user:password
		account2: *otherhost.mydomain/somerep* dXNlcjpwYXNzd29yZA==

	That is it must start with 'account', followed by anything to distinguish accounts, and a colon. Then comes a match expression for the repository url, and after a space the user:password string.
	
	To not have the clear text password on your disc, you can base64 encode it:
			(Base64MimeConverter mimeEncode: 'user:password' readStream) contents
	"

	
	Settings ifNotNil: [
		Settings keysAndValuesDo: [:key :value | | entry userAndPassword |
			(key asLowercase beginsWith: 'account') ifTrue: [
				entry := value findTokens: '	 '.
				(entry first match: self location) ifTrue: [
					userAndPassword := entry second.
					(userAndPassword includes: $:) ifFalse: [
						userAndPassword := userAndPassword base64Decoded decodeWith: #null].
					userAndPassword := userAndPassword findTokens: $:.
					^aBlock value: userAndPassword first 
						value: userAndPassword second 
					]
			]
		]
	].
	^nil
]

{ #category : #actions }
MCHttpRepository >> versionReaderForFileNamed: aString [
	readerCache ifNil: [readerCache := Dictionary new].
	^ readerCache at: aString ifAbsent:
		[self resizeCache: readerCache.
		super versionReaderForFileNamed: aString do:
			[:r |
			r ifNotNil: [readerCache at: aString put: r]]]
	
]

{ #category : #actions }
MCHttpRepository >> versionReaderForFileNamed: aString do: aBlock [
	^ (self versionReaderForFileNamed: aString) ifNotNil: aBlock
]

{ #category : #'i/o' }
MCHttpRepository >> writeStreamForFileNamed: aString replace: ignoreBoolean do: aBlock [
	| entity |
	entity := self entityStreamContents: aBlock.
	self displayProgress: 'Uploading ', aString during: [
		self httpClient
			entity: entity;
			ifFail: [ :exception | 
				(exception isKindOf: ZnHttpUnsuccessful) 
					ifTrue: [ ^ self handleUnsuccessfulResponse: exception response ].
				self error: 'Could not save ', aString, ': ', exception printString ];
			url: (self urlForFileNamed: aString);
			put ]
]
