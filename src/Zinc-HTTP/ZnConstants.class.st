"
I am ZnConstants, holding various constants that we use.

Part of Zinc HTTP Components.
"
Class {
	#name : #ZnConstants,
	#superclass : #Object,
	#classVars : [
		'HTTPStatusCodes'
	],
	#category : #'Zinc-HTTP-Support'
}

{ #category : #accessing }
ZnConstants class >> defaultHTTPVersion [
	^ 'HTTP/1.1'
]

{ #category : #accessing }
ZnConstants class >> defaultServerString [ 
	^ self frameworkNameAndVersion , ' (' , self systemVersion , ')'
]

{ #category : #accessing }
ZnConstants class >> defaultUserAgent [
	^ self frameworkNameAndVersion , ' (' , self systemVersion , ')'
]

{ #category : #accessing }
ZnConstants class >> faviconBytes [
	^ #(0 0 1 0 1 0 16 16 16 0 0 0 0 0 40 1 0 0 22 0 0 0 40 0 0 0 16 0 0 0 32 0 0 0 1 0 4 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 255 255 255 0 0 189 255 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 17 17 17 1 16 1 16 1 17 17 17 1 16 1 16 1 16 0 0 1 16 1 16 0 17 0 0 1 16 1 16 0 1 16 0 1 16 1 16 0 0 17 0 1 17 17 16 0 0 1 16 1 1 17 0 0 0 0 17 0 0 0 0 1 17 17 17 0 0 0 0 1 17 17 17 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0) asByteArray
]

{ #category : #accessing }
ZnConstants class >> frameworkLicense [
	"http://en.wikipedia.org/wiki/MIT_License"
	
	^ 'MIT License'
]

{ #category : #accessing }
ZnConstants class >> frameworkMCVersion [
	MCWorkingCopy managersForClass: self class do: [ :each | ^ each ancestors first name ]
]

{ #category : #accessing }
ZnConstants class >> frameworkName [
	^ 'Zinc HTTP Components'
]

{ #category : #accessing }
ZnConstants class >> frameworkNameAndVersion [
	^ self frameworkName, ' ', self frameworkVersion 
]

{ #category : #accessing }
ZnConstants class >> frameworkVersion [
	^ '1.0'
]

{ #category : #accessing }
ZnConstants class >> httpStatusCodes [
	^ HTTPStatusCodes 
]

{ #category : #'class initialization' }
ZnConstants class >> initialize [
	"Forced source code change for automatic initialization: 20170510"
	
	self initializeHTTPStatusCodes
]

{ #category : #private }
ZnConstants class >> initializeHTTPStatusCodes [ 
	HTTPStatusCodes := Dictionary newFromPairs: self officialHTTPStatusCodesSpec 
]

{ #category : #accessing }
ZnConstants class >> knownHTTPMethods [
	^ #(
		"Standard HTTP 1.1 Verbs"
		GET PUT POST DELETE HEAD 
		TRACE OPTIONS CONNECT PATCH
		"WebDAV verbs"
		PROPFIND PROPPATCH MKCOL COPY MOVE LOCK UNLOCK)
]

{ #category : #accessing }
ZnConstants class >> knownHTTPVersions [
	^ #('HTTP/1.1' 'HTTP/1.0')
]

{ #category : #'resource limits' }
ZnConstants class >> maximumLineLength [
	"Return the maximum line length to accept.
	Used by ZnLineReader and thus for reading request/status lines as well as headers.
	This helps to protect us from malicious content."
	
	^ 4096
]

{ #category : #accessing }
ZnConstants class >> officialHTTPStatusCodesSpec [ 
	"This is the official list from http://www.iana.org/assignments/http-status-codes (version 2017-04-14)"

	^ #(
		"1xx: Informational - Request received, continuing process"
		100 'Continue'
		101 'Switching Protocols'
		102 'Processing'
		"2xx: Success - The action was successfully received, understood, and accepted"
		200 'OK'
		201 'Created'
		202 'Accepted'
		203 'Non-Authoritative Information'
		204 'No Content'
		205 'Reset Content'
		206 'Partial Content'
		207 'Multi-Status'
		208 'Already Reported'
		226 'IM Used'
		"3xx: Redirection - Further action must be taken in order to complete the request"
		300 'Multiple Choices'
		301 'Moved Permanently'
		302 'Found'
		303 'See Other'
		304 'Not Modified'
		305 'Use Proxy'
		307 'Temporary Redirect'
		308 'Permanent Redirect'
		"4xx: Client Error - The request contains bad syntax or cannot be fulfilled"
		400 'Bad Request'
		401 'Unauthorized'
		402 'Payment Required'
		403 'Forbidden'
		404 'Not Found'
		405 'Method Not Allowed'
		406 'Not Acceptable'
		407 'Proxy Authentication Required'
		408 'Request Timeout'
		409 'Conflict'
		410 'Gone'
		411 'Length Required'
		412 'Precondition Failed'
		413 'Payload Too Large'
		414 'URI Too Long'
		415 'Unsupported Media Type'
		416 'Requested Range Not Satisfiable'
		417 'Expectation Failed'
		421 'Misdirected Request'
		422 'Unprocessable Entity'
		423 'Locked'
		424 'Failed Dependency'
		426 'Upgrade Required'
		428 'Precondition Required'
		429 'Too Many Requests'
		431 'Request Header Fields Too Large'
		"5xx: Server Error - The server failed to fulfill an apparently valid request"
		500 'Internal Server Error'
		501 'Not Implemented'
		502 'Bad Gateway'
		503 'Service Unavailable'
		504 'Gateway Timeout'
		505 'HTTP Version Not Supported'
		506 'Variant Also Negotiates (Experimental)'
		507 'Insufficient Storage'
		508 'Loop Detected'
		510 'Not Extended'
		511 'Network Authentication Required'
	)
]

{ #category : #accessing }
ZnConstants class >> remoteAddressHeader [
	^ 'X-Zinc-Remote-Address'
]

{ #category : #accessing }
ZnConstants class >> systemVersion [
	^ SystemVersion current type , '/' , SystemVersion current dottedMajorMinor 
]
