"
I represent a handle of SDL rendering context, coming from SDL2 library
"
Class {
	#name : #'SDL_Renderer',
	#superclass : #SDL2Handle,
	#pools : [
		'SDL2Constants',
		'SDL2Types'
	],
	#category : #'OSWindow-SDL2-Bindings'
}

{ #category : #finalization }
SDL_Renderer class >> destroyRenderer: aHandle [
	^ self ffiCall: #( void SDL_DestroyRenderer ( void *aHandle ) )
]

{ #category : #finalization }
SDL_Renderer class >> finalizeResourceData: aHandle [
	aHandle isNull ifTrue: [ ^ self ].
	self destroyRenderer: aHandle.
	aHandle beNull
]

{ #category : #rendering }
SDL_Renderer >> clear [
	^ self ffiCall: #( int SDL_RenderClear ( self ) )
]

{ #category : #rendering }
SDL_Renderer >> copy: texture [
	^ self ffiCall: #( int SDL_RenderCopy ( self , SDL_Texture texture , nil, nil ) )
]

{ #category : #rendering }
SDL_Renderer >> copy: texture srcRect: srcRect dstRect: dstRect [
	^ self ffiCall: #( int SDL_RenderCopy ( self , SDL_Texture texture , SDL_Rect* srcRect , SDL_Rect* dstRect ) )
]

{ #category : #rendering }
SDL_Renderer >> createTextureFormat: format access: access width: width height: height [

	^ self
		  primCreateTextureFormat: format
		  access: access
		  width: width
		  height: height
]

{ #category : #initialization }
SDL_Renderer >> destroy [
	handle isNull ifTrue: [ ^ self ].
	self primDestroy.
	handle beNull
]

{ #category : #rendering }
SDL_Renderer >> drawBlendMode: blendMode [
	^ self ffiCall: #( int SDL_SetRenderDrawBlendMode ( self , SDL_BlendMode blendMode ) )
]

{ #category : #rendering }
SDL_Renderer >> drawColorR: r g: g b: b a: a [
	^ self ffiCall: #( int SDL_SetRenderDrawColor ( self , Uint8 r , Uint8 g , Uint8 b , Uint8 a ) )
]

{ #category : #rendering }
SDL_Renderer >> drawLineX1: x1 y1: y1 x2: x2 y2: y2 [
	^ self ffiCall: #( int SDL_RenderDrawLine ( self , int x1 , int y1 , int x2 , int y2 ) )
]

{ #category : #rendering }
SDL_Renderer >> drawPointX: x y: y [
	^ self ffiCall: #( int SDL_RenderDrawPoint ( self , int x , int y ) )
]

{ #category : #rendering }
SDL_Renderer >> drawRect: rect [
	^ self ffiCall: #( int SDL_RenderDrawRect ( self , SDL_Rect* rect ) )
]

{ #category : #rendering }
SDL_Renderer >> fillRect: rect [
	^ self ffiCall: #( int SDL_RenderFillRect ( self , SDL_Rect* rect ) )
]

{ #category : #rendering }
SDL_Renderer >> getLogicalSizeW: w h: h [
	^ self ffiCall: #( int SDL_RenderGetLogicalSize ( self , int* w, int* h ) )
]

{ #category : #rendering }
SDL_Renderer >> getOutputSizeW: w h: h [
	^ self ffiCall: #( int SDL_GetRendererOutputSize ( self , int* w, int* h ) )
]

{ #category : #accessing }
SDL_Renderer >> info [
	| info |
	
	info := SDL_RendererInfo externalNew autoRelease.
	self primGetRendererInfo: info.
	^ info
]

{ #category : #initialization }
SDL_Renderer >> initialize [
	self autoRelease
]

{ #category : #rendering }
SDL_Renderer >> noClipRect [
	^ self ffiCall: #( int SDL_RenderSetClipRect ( self , nil ) )
]

{ #category : #rendering }
SDL_Renderer >> noRenderTarget [
	^ self ffiCall: #( int SDL_SetRenderTarget ( self , nil ) )
]

{ #category : #rendering }
SDL_Renderer >> outputExtent [

	^ ExternalAddress allocate: 8 bytesDuring: [ :buffer | 
		  self getOutputSizeW: buffer h: buffer + 4.
		  (buffer unsignedLongAt: 1) @ (buffer unsignedLongAt: 5) ]
]

{ #category : #rendering }
SDL_Renderer >> present [
	^ self ffiCall: #( void SDL_RenderPresent ( self ) )
]

{ #category : #private }
SDL_Renderer >> primCreateTextureFormat: format access: access width: width height: height [
	^ self ffiCall: #( SDL_Texture SDL_CreateTexture ( self , Uint32 format , int access , int width , int height ) )
]

{ #category : #initialization }
SDL_Renderer >> primDestroy [
	^ self ffiCall: #( void SDL_DestroyRenderer ( self ) )
]

{ #category : #private }
SDL_Renderer >> primGetRendererInfo: info [
	^ self ffiCall: #( int SDL_GetRendererInfo (self, SDL_RendererInfo* info) )
]

{ #category : #rendering }
SDL_Renderer >> renderTargetSupported [
	^ self ffiCall: #( bool SDL_RenderTargetSupported ( self ) )
]

{ #category : #rendering }
SDL_Renderer >> setClipRect: rect [
	^ self ffiCall: #( int SDL_RenderSetClipRect ( self , SDL_Rect* rect ) )
]

{ #category : #rendering }
SDL_Renderer >> setRenderTarget: renderTarget [
	^ self ffiCall: #( int SDL_SetRenderTarget ( self , SDL_Texture renderTarget ) )
]
