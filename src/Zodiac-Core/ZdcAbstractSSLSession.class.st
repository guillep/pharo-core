"
I am ZdcAbstractSSLSession, an object managing the secure communication between two parties.

I define the abstract interface for my subclasses.

More specifically, I handle connection setup handshaking as well as the encryption
and decryption of data travelling between two parties.

Apart from instanciating and later explicitely destroying me, I am used by feeding data 
into me using the methods in my operations protocol. These might result in data that
has to be sent to the other side.

I am propably too primitive to be used directly, see ZdcSecureSocketStream for a higher level client.
"
Class {
	#name : #ZdcAbstractSSLSession,
	#superclass : #Object,
	#category : #'Zodiac-Core'
}

{ #category : #testing }
ZdcAbstractSSLSession class >> isAbstract [ 

	^self == ZdcAbstractSSLSession
]

{ #category : #operations }
ZdcAbstractSSLSession >> accept: srcBuf from: start to: stop into: dstBuf [
	"Start or continue the server handshake using the given input token"

	self subclassResponsibility
]

{ #category : #accessing }
ZdcAbstractSSLSession >> certificateName [
	"The name of the local certificate to provide to the remote peer"

	self subclassResponsibility
]

{ #category : #accessing }
ZdcAbstractSSLSession >> certificateName: aString [
	"Sets the name of the local certificate to provide to the remote peer.
	OpenSSL: The name is the full path to a .pem file.
	WinSSL: The name is matched against the 'subject' of a certificate in the cert store"

	self subclassResponsibility
]

{ #category : #accessing }
ZdcAbstractSSLSession >> certificateVerificationState [
	"Returns the certificate verification bits. The returned value indicates
	whether the certificate is valid. The two standard values are:
		0   - The certificate is valid
		-1  - No certificate has been provided by the peer
	Otherwise, the result is a bit mask of the following values:
		1   - If set, there is an unspecified issue with the cert (generic error)
		2   - If set, the root CA is untrusted (usually a self-signed cert)
		4   - If set, the certificate is expired
		8   - If set, the certificate is used for the wrong purpose
		16 - If set, the CN of the certificate is invalid
		32 - If set, the certificate was revoked"

	self subclassResponsibility
]

{ #category : #operations }
ZdcAbstractSSLSession >> connect: srcBuf from: start to: stop into: dstBuf [
	"Start or continue the client handshake using the given input token"

	self subclassResponsibility
]

{ #category : #operations }
ZdcAbstractSSLSession >> decrypt: srcBuf from: start to: stop into: dstBuf [
	"Decrypt the input in srcBuf from start to stop into dstBuf."

	self subclassResponsibility
]

{ #category : #initialization }
ZdcAbstractSSLSession >> destroy [
	"Do any necessary cleanup when I am no longer needed"
	
	self subclassResponsibility
]

{ #category : #operations }
ZdcAbstractSSLSession >> encrypt: srcBuf from: start to: stop into: dstBuf [
	"Encrypt the input in srcBuf from start to stop into dstBuf."

	self subclassResponsibility
]

{ #category : #testing }
ZdcAbstractSSLSession >> isConnected [
	"Returns true if the SSL handshake has been completed"

	self subclassResponsibility
]

{ #category : #accessing }
ZdcAbstractSSLSession >> peerCertificateName [
	"Returns the certificate name of the remote peer.
	The method only returns a name if the certificate has been verified"

	self subclassResponsibility
]

{ #category : #accessing }
ZdcAbstractSSLSession >> serverName [
	"Get the Server Name Indication (SNI) property"
	
	self subclassResponsibility
]

{ #category : #accessing }
ZdcAbstractSSLSession >> serverName: serverName [
	"Set the Server Name Indication (SNI) to serverName, 
	the fully qualified domain name of the host to connect to.
	This should be set by a client before #connect is attempted."
	
	self subclassResponsibility
]

{ #category : #accessing }
ZdcAbstractSSLSession >> sslState [
	"Returns the current state of the SSL connection:
		0 - Unused
		1 - In accept handshake
		2 - In connect handshake
		3 - Connected"
		
	self subclassResponsibility
]
