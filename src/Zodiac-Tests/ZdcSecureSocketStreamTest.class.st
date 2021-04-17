"
ZdcSecureSocketStreamTests tests ZdcSecureSocketStream 
"
Class {
	#name : #ZdcSecureSocketStreamTest,
	#superclass : #TestCase,
	#category : #'Zodiac-Tests'
}

{ #category : #private }
ZdcSecureSocketStreamTest >> isNativeSSLPluginPresent [
	"Return whether the SSL VM plugin can be instanciated and intialized."
	
	^ [ ZdcPluginSSLSession new destroy. true ]
			on: ZdcPluginMissing
			do: [ false ]
]

{ #category : #tests }
ZdcSecureSocketStreamTest >> testIsNativeSSLPluginPresent [
	"This test succeeds when the SSL VM plugin can be instantiated and intialized."
	
	self 
		assert: self isNativeSSLPluginPresent 
		description: 'It seems that the native VM SSL plugin cannot be instantiated and initialized. (VM plugin missing ? OS libraries missing ?)'
]

{ #category : #tests }
ZdcSecureSocketStreamTest >> testPlain [
	| query stream request response |
	self isNativeSSLPluginPresent ifFalse: [ ^ self ].
	query := 'Smalltalk'.
	stream := ZdcSecureSocketStream openConnectionToHostNamed: 'duckduckgo.com' port: 443.
	request := nil.
	response := [
		request := String streamContents: [ :out |
			out << 'GET /?q=' << query << ' HTTP/1.1' << String crlf.
			out << 'Host: duckduckgo.com' << String crlf.
			out << 'Connection: close' << String crlf.
			out << String crlf ].
		stream connect.
		stream nextPutAll: request asByteArray.
		stream flush.
		stream upToEnd asString.
	] ensure: [ stream close ].
	self assert: (response includesSubstring: '200 OK').      
	self assert: (response includesSubstring: 'Duck').
	self assert: (response includesSubstring: query).
]
