"
ZnHTTPSTests.

These require that the ZnZodiacNetworkingUtils socket stream factory is enabled:

	ZnNetworkingUtils default: ZnZodiacNetworkingUtils new.
	
Part of Zinc HTTP Components
"
Class {
	#name : #ZnHTTPSTest,
	#superclass : #TestCase,
	#category : #'Zinc-Zodiac'
}

{ #category : #accessing }
ZnHTTPSTest class >> defaultTimeLimit [
	^10 seconds
]

{ #category : #testing }
ZnHTTPSTest class >> generateTestData: size [
	"self generateTestData: 1111"
	
	^ String 
		streamContents: [ :stream |
			stream << 'Transfer test file of size '; print: size; << ' bytes.'; lf.
			1 to: size do: [ :each |
				stream nextPutAll: 'Line '; print: each; lf ] ] 
		limitedTo: size 
]

{ #category : #testing }
ZnHTTPSTest class >> generateTestFiles [
	"self generateTestFiles"
	
	(Integer primesUpTo: 100) do: [ :each | | size |
		size := 1024 * each + each.
		('test-', size asString, '.txt') asFileReference writeStreamDo: [ :stream |
			stream nextPutAll: (self generateTestData: size) ] ]
]

{ #category : #testing }
ZnHTTPSTest >> disabledTestPayPal [
	| client |
	self ensureSocketStreamFactory.
	self isNativeSSLPluginPresent ifFalse: [ ^ self ].
	(client := ZnClient new) 
		get: 'https://www.paypal.com'.
	self assert: client isSuccess.
	self assert: (client contents includesSubstring: 'PayPal').
	client close
]

{ #category : #private }
ZnHTTPSTest >> doesNativeSSLPluginSupportSNI [
	"Return whether the SSL VM plugin supports SNI."
	
	^ [ ZdcPluginSSLSession new serverName; serverName: nil; destroy. true ]
			on: ZdcPluginMissing, PrimitiveFailed
			do: [ false ]
]

{ #category : #private }
ZnHTTPSTest >> ensureSocketStreamFactory [
	self 
		assert: ZnNetworkingUtils default secureSocketStreamClass notNil
		description: 'Please set a secure socket stream class in ZnNetworkingUtils default or switch to the ZnZodiacNetworkingUtils socket stream factory'
]

{ #category : #private }
ZnHTTPSTest >> isNativeSSLPluginPresent [
	"Return whether the SSL VM plugin can be instanciated and intialized."
	
	^ [ ZdcPluginSSLSession new destroy. true ]
			on: ZdcPluginMissing
			do: [ false ]
]

{ #category : #private }
ZnHTTPSTest >> runningOnWindows [
	"Pharo 3+"
	[ ^ OSPlatform current isWindows ] on: MessageNotUnderstood do: [ ].
	"Pharo 2-"
	[ ^ OSPlatform isWin32 ] on: MessageNotUnderstood do: [ ].
	"Give up"
	^ false
]

{ #category : #private }
ZnHTTPSTest >> runningOnWindowsInriaCI [
	| platform ci |
	self runningOnWindows
		ifFalse: [ ^ false ].
	^ [ 
	platform := OSPlatform current.
	ci := platform environment at: 'CI' ifAbsent: [ '' ].
	ci = 'ci.inria.fr' ]
		on: MessageNotUnderstood
		do: [ false ]
]

{ #category : #testing }
ZnHTTPSTest >> testAmazonAWS [
	| client |
	self ensureSocketStreamFactory.
	self isNativeSSLPluginPresent ifFalse: [ ^ self ].
	(client := ZnClient new) 
		get: 'https://aws.amazon.com/'.
	self assert: client isSuccess.
	self assert: (client contents includesSubstring: 'Amazon').
	client close
]

{ #category : #testing }
ZnHTTPSTest >> testGForceInria [
	| client |
	self ensureSocketStreamFactory.
	self isNativeSSLPluginPresent ifFalse: [ ^ self ].
	(client := ZnClient new)
		get: 'http://gforge.inria.fr/frs/?group_id=1299'.
	self assert: client isSuccess.
	self assert: (client contents includesSubstring: 'inria').
	client close
]

{ #category : #testing }
ZnHTTPSTest >> testGetPharoVersion [
	| lastBuildVersion version url versionName |
	self ensureSocketStreamFactory.
	self isNativeSSLPluginPresent ifFalse: [ ^ self ].
	self runningOnWindowsInriaCI ifTrue: [ ^ self ].
	
	versionName := SystemVersion current type , SystemVersion current dottedMajorMinor.

	url := ZnUrl new 
		scheme: #https;
		host: 'ci.inria.fr';
		addPathSegments: #('pharo-ci-jenkins2' 'job' 
			'Test pending pull request and branch Pipeline' 'job');
		addPathSegment: versionName;
		addPathSegments: #('api' 'xml');
		queryAt: 'xpath' add: '/*/fullDisplayName';
		yourself.
	
	lastBuildVersion := ZnClient new
		beOneShot;
		get: url.
	self assert: lastBuildVersion notNil.
	self assert: lastBuildVersion isString.
	self assert: lastBuildVersion size > 0.
	version := (lastBuildVersion copyAfter: $>) copyUpTo: $<.
	self deny: version isEmpty
]

{ #category : #testing }
ZnHTTPSTest >> testGmailEncrypted [
	| client |
	self ensureSocketStreamFactory.
	self isNativeSSLPluginPresent ifFalse: [ ^ self ].  
	(client := ZnClient new) 
		get: 'https://www.gmail.com'.
	self assert: client isSuccess.
	self assert: (client contents includesSubstring: 'Google').    
	self assert: (client contents includesSubstring: 'mail'). 
	client close
]

{ #category : #testing }
ZnHTTPSTest >> testGoogleEncrypted [
	| client |
	self ensureSocketStreamFactory.
	self isNativeSSLPluginPresent ifFalse: [ ^ self ].
	(client := ZnClient new) 
		get: 'https://encrypted.google.com/search?q=Smalltalk'.
	self assert: client isSuccess.
	self assert: (client contents includesSubstring: 'Google').    
	self assert: (client contents includesSubstring: 'Smalltalk').
	client close
]

{ #category : #testing }
ZnHTTPSTest >> testRequestResponse [
	| query stream request response |
	self ensureSocketStreamFactory.
	self isNativeSSLPluginPresent ifFalse: [ ^ self ].
	query := 'Smalltalk'.
	stream := ZdcSecureSocketStream openConnectionToHostNamed: 'duckduckgo.com' port: 443.
	request := nil.
	response := [
		request := ZnRequest get: 'https://duckduckgo.com?q=', query.
		stream connect.
		request writeOn: stream.
		stream flush.
		ZnResponse readFrom: stream.
	] ensure: [ stream close ].
	self assert: response isSuccess.
	self assert: (response contents includesSubstring: 'Duck').   
	self assert: (response contents includesSubstring: query).
]

{ #category : #testing }
ZnHTTPSTest >> testSNIPage [
	| client |
	self ensureSocketStreamFactory.
	self isNativeSSLPluginPresent ifFalse: [ ^ self skip ].
	self doesNativeSSLPluginSupportSNI ifFalse: [ ^ self skip ].
	
	(client := ZnClient new) 
		get: 'https://www.mnot.net/blog/2014/05/09/if_you_can_read_this_youre_sniing'.

	self assert: client isSuccess.

	client close
]

{ #category : #testing }
ZnHTTPSTest >> testTransfers [
	self timeLimit: 300 seconds.
	self ensureSocketStreamFactory.
	self isNativeSSLPluginPresent ifFalse: [ ^ self ].
	
	(Integer primesUpTo: 100) do: [ :each | | size client |
		size := 1024 * each + each.
		(client := ZnClient new)
			https;
			host: 's3-eu-west-1.amazonaws.com';
			addPath: 'public-stfx-eu';
			addPath: ('test-', size asString, '.txt');
			get;
			close.
		self assert: client isSuccess.
		self assert: (client response contentType matches: ZnMimeType textPlain).
		self assert: client response contentLength equals: size.
		self 
			assert: client contents 
			equals: (self class generateTestData: size)	]
]

{ #category : #testing }
ZnHTTPSTest >> testTransfersSingleClient [
	| client |
	self ensureSocketStreamFactory.
	self isNativeSSLPluginPresent ifFalse: [ ^ self ].
	(client := ZnClient new)
		https;
		host: 's3-eu-west-1.amazonaws.com'.
	(Integer primesUpTo: 100) do: [ :each | | size |
		size := 1024 * each + each.
		client
			url: ('/public-stfx-eu/test-', size asString, '.txt');
			get.
		self assert: client isSuccess.
		self assert: (client response contentType matches: ZnMimeType textPlain).
		self assert: client response contentLength equals: size.
		self 
			assert: client contents 
			equals: (self class generateTestData: size)	].
	client close
]

{ #category : #testing }
ZnHTTPSTest >> testWikimedia [
	| client |
	self ensureSocketStreamFactory.
	self isNativeSSLPluginPresent ifFalse: [ ^ self ]. 
	(client := ZnClient new) 
		get: 'https://secure.wikimedia.org/'.
	self assert: client isSuccess.
	self assert: (client contents includesSubstring: 'Wikimedia').
	client close
]

{ #category : #private }
ZnHTTPSTest >> timeLimit: seconds [
	(TestCase canUnderstand: #timeLimit:)
		ifTrue: [ super timeLimit: seconds ]
]
