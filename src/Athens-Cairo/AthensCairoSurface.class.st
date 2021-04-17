"
I am a concrete implementation of Athens surface which using cairo graphics library for rendering.

Cairo library, by itself can have multiple surface types.
This class uses image surface (a bitmap located in system memory) and maps to cairo_image_surface_t* C type.

**NOTE**
As a workaround of a bug in bitblt, the Cairo surfaces are created internally with 1 extra pixel higher than requested. However, this is hidden for users.
"
Class {
	#name : #AthensCairoSurface,
	#superclass : #AthensSurface,
	#traits : 'TCairoLibrary',
	#classTraits : 'TCairoLibrary classTrait',
	#instVars : [
		'handle',
		'context',
		'builder',
		'id',
		'ftFontRenderer',
		'session'
	],
	#pools : [
		'AthensCairoDefinitions'
	],
	#classInstVars : [
		'session',
		'dispatch',
		'dispatchStruct'
	],
	#category : #'Athens-Cairo-Surface'
}

{ #category : #converting }
AthensCairoSurface class >> asExternalTypeOn: generator [ 
	"use handle ivar to hold my instance (cairo_surface_t)"
	^ FFIExternalObjectType objectClass: self
]

{ #category : #'session management' }
AthensCairoSurface class >> checkSession [
	session == Smalltalk session 
		ifFalse: [ self initializeForNewSession ]
]

{ #category : #'instance creation' }
AthensCairoSurface class >> createFromFile: aFileName ifFailed: aBlock [
	"Right now, this protocol is Cairo backend only. "
	
 	| surface cstring |
	cstring := aFileName , (Character value: 0) asString.
	surface :=  self primCreateFromFile: cstring.
	surface isSuccess not
		ifTrue: [ 
			self destroySurfaceHandle: surface handle asInteger.
			^ aBlock cull: surface status ]
		ifFalse: [ surface initialize ].
	^ surface .
]

{ #category : #'surface plugin callbacks' }
AthensCairoSurface class >> createGetSurfaceFormatFn [
	"
		int getSurfaceFormat(sqIntptr_t handle, int* width, int* height, int* depth, int* isMSB);

		Return general information about the OS drawing surface.
		Return true if successful, false otherwise.

		The returned values describe the basic properties such as
		width, height, depth and LSB vs. MSB pixels.
	"
	^ FFICallback 
		signature: #(int (void *handle, int* width, int* height, int* depth, int* isMSB))
		block: [ :handle :width :height :depth :isMSB |
			[width signedLongAt: 1 put: (self get_width: handle).
			 height signedLongAt: 1 put: (self get_height: handle).
			 depth signedLongAt: 1 put: 32.
			 isMSB signedLongAt: 1 put: 0. 
			 1 "Everything ok"] 
			on: Error do: [ :e | 0 "Error happened" ]]
]

{ #category : #'surface plugin callbacks' }
AthensCairoSurface class >> createLockSurfaceFn [
	"
	int lockSurface(sqIntptr_t handle, int *pitch, int x, int y, int w, int h);
		Lock the bits of the surface.
		Return a pointer to the actual surface bits, or NULL on failure.
		If successful, store the pitch of the surface (e.g., the bytes
		per scan line).

		For equal source/dest handles only one locking operation is performed.
		This is to prevent locking of overlapping areas which does not work with
		certain APIs (e.g., DirectDraw prevents locking of overlapping areas). 
		A special case for non-overlapping but equal source/dest handle would 
		be possible but we would have to transfer this information over to 
		unlockSurfaces somehow (currently, only one unlock operation is 
		performed for equal source and dest handles). Also, this would require
		a change in the notion of ioLockSurface() which is right now interpreted
		as a hint and not as a requirement to lock only the specific portion of
		the surface.

		The arguments in ioLockSurface() provide the implementation with
		an explicit hint what area is affected. It can be very useful to
		know the max. affected area beforehand if getting the bits requires expensive
		copy operations (e.g., like a roundtrip to the X server or a glReadPixel op).
		However, the returned pointer *MUST* point to the virtual origin of the surface
		and not to the beginning of the rectangle. The promise made by BitBlt
		is to never access data outside the given rectangle (aligned to 4byte boundaries!)
		so it is okay to return a pointer to the virtual origin that is actually outside
		the valid memory area.

		The area provided in ioLockSurface() is already clipped (e.g., it will always
		be inside the source and dest boundingBox) but it is not aligned to word boundaries
		yet. It is up to the support code to compute accurate alignment if necessary.
	"

	^ FFICallback 
		signature: #(void * (void *handle, int *pitch, int x, int y, int w, int h))
		block: [ :handle :pitch :x :y :w :h |
			pitch signedLongAt: 1 put: (self get_stride: handle).
			self get_data: handle ]
]

{ #category : #'surface plugin callbacks' }
AthensCairoSurface class >> createShowSurfaceFn [
	"
	int showSurface(sqIntptr_t handle, int x, int y, int w, int h);
		Display the contents of the surface on the actual screen.

		If ioShowSurface() is called the surface in question represents a DisplayScreen.

	"
	^ nil
	"^ FFICallback 
		signature: #(int (void *handle, int x, int y, int w, int h))
		block: [ :handle :x :y :w :h | 0 ""Do nothing"" ]"
]

{ #category : #'surface plugin callbacks' }
AthensCairoSurface class >> createUnlockSurfaceFn [
	"
		int unlockSurface(sqIntptr_t handle, int x, int y, int w, int h);
		Unlock the bits of a (possibly modified) surface after BitBlt completed.
		The return value is ignored.

		The arguments provided specify the dirty region of the surface. If the
		surface is unmodified all arguments are set to zero.

	"
	^ nil
	"^ FFICallback 
		signature: #(int (void *handle, int x, int y, int w, int h))
		block: [ :handle :x :y :w :h | 0 ""Do nothing"" ]"
]

{ #category : #private }
AthensCairoSurface class >> destroyContextHandle: aHandle [
	^ self ffiCall: #( 	void cairo_destroy (size_t aHandle) )
]

{ #category : #private }
AthensCairoSurface class >> destroySurfaceHandle: handle [
	^ self ffiCall: #( void cairo_surface_destroy ( ulong handle ) )


]

{ #category : #'surface plugin callbacks' }
AthensCairoSurface class >> dispatchStruct [
	self checkSession.
	^ dispatchStruct
]

{ #category : #'instance creation' }
AthensCairoSurface class >> extent: anExtent [
	^ self extent: anExtent format: CAIRO_FORMAT_ARGB32
]

{ #category : #'instance creation' }
AthensCairoSurface class >> extent: anExtent format: aFormat [
	^ ( self primImage: aFormat width: anExtent x height: anExtent y + 1) initialize

]

{ #category : #'finalize resources' }
AthensCairoSurface class >> finalizeResourceData: data [
	"Finalize external state"

	| handle id contextHandle |
	handle := data first.
	id := data second.
	contextHandle := data third.
	
	(self findSurface: id) = handle value ifFalse: [ 
		"self error: 'surface is not registered with surface plugin'."
		^ self ].
	
	self unregisterSurfaceWithId: id.
	self destroyContextHandle: contextHandle value. 
	self destroySurfaceHandle: handle value

]

{ #category : #private }
AthensCairoSurface class >> findSurface: surfaceId [
	| buf |
	buf := ByteArray new: 4.  "sizeof(int)"
	
	
	(self primFindSurface: surfaceId handle: buf) ifTrue: [
		^ buf nbUlongAt: 1
		].
	
	^ nil. 
]

{ #category : #'instance creation' }
AthensCairoSurface class >> fromForm: aForm [
	| form surface newBits |
	form := aForm unhibernate; asFormOfDepth: 32.
	surface := self extent: aForm extent.
	"we should convert form bits with premultiplied alpha"
	newBits := form bits collect: [:pixel |
		| alpha r g b|
		alpha := (pixel >> 24) / 255.
		r := ( (pixel bitAnd: 255) * alpha ) asInteger.
		g := ( (pixel >>8 bitAnd: 255) * alpha ) asInteger.
		b := ( (pixel >>16 bitAnd: 255) * alpha ) asInteger.
		(pixel bitAnd: 16rFF000000) + (b<<16) + (g<<8) + r
		].
	LibC memCopy: newBits to: surface getDataPtr getHandle size: (form width * form height *4).
	surface markDirty.
	^ surface.
]

{ #category : #'surface plugin callbacks' }
AthensCairoSurface class >> get_data: surface [
	^ self ffiCall: #(void *cairo_image_surface_get_data (void *surface))
]

{ #category : #'surface plugin callbacks' }
AthensCairoSurface class >> get_height: surface [
	^ self ffiCall: #(int cairo_image_surface_get_height (void *surface))
]

{ #category : #'surface plugin callbacks' }
AthensCairoSurface class >> get_stride: surface [
	^ self ffiCall: #(int cairo_image_surface_get_stride (void *surface))
]

{ #category : #'surface plugin callbacks' }
AthensCairoSurface class >> get_width: surface [
	^ self ffiCall: #(int cairo_image_surface_get_width (void *surface))
]

{ #category : #'session management' }
AthensCairoSurface class >> initializeForNewSession [
	session := Smalltalk session.
	"create a dispatch structure"
	dispatchStruct := SQSurfaceDispatch externalNew.
	dispatchStruct 
		getSurfaceFormatFn: self createGetSurfaceFormatFn;
		lockSurfaceFn: self createLockSurfaceFn;
		unlockSurfaceFn: self createUnlockSurfaceFn;
		showSurfaceFn: self createShowSurfaceFn.
	"assign the pointer"
	dispatch := dispatchStruct getHandle.
]

{ #category : #private }
AthensCairoSurface class >> primCreateFromFile: aFileName [
	^ self ffiCall: #(AthensCairoSurface cairo_image_surface_create_from_png (char* aFileName)) 

]

{ #category : #private }
AthensCairoSurface class >> primFindSurface: id handle: handlePtr [
		"Find the surface with the given ID, and, optionally,
		the given set of surface functions. The registered handle
		is returned in surfaceHandle. Return true if successful
		(e.g., the surface has been found), false otherwise."

	<primitive: 'primitiveFindSurface' module: 'SurfacePlugin'>

	"We keep the call to the FFI just in case we are running in an old VM"	
	^ self ioFindSurface: id handle: handlePtr
]

{ #category : #private }
AthensCairoSurface class >> primImage: aFormat width: aWidth height: aHeight [
	^ self ffiCall: #(AthensCairoSurface cairo_image_surface_create (int aFormat,
                                                         int aWidth,
                                                         int aHeight) )


]

{ #category : #private }
AthensCairoSurface class >> primImageFromData: data width: width height: height pitch: stride [
	
	"CAIRO_FORMAT_ARGB32 -> 0"
	
	^ self ffiCall: #(AthensCairoSurface cairo_image_surface_create_for_data (
		void *data,
		0,
		int width,
		int height,
		int stride) )


]

{ #category : #private }
AthensCairoSurface class >> primRegisterSurface: aCairoSurfaceHandle dispatch: sqSurfaceDispatchPtr surfaceId: idHolder [
"
	Register a new surface with the given handle and
	the set of surface functions. The new ID is returned
	in surfaceID. Returns true if successful, false 
	otherwise."

	<primitive: 'primitiveRegisterSurface' module: 'SurfacePlugin'>

	"We keep the call to the FFI just in case we are running in an old VM"	

	^ self ioRegisterSurface: aCairoSurfaceHandle dispatch: sqSurfaceDispatchPtr surfaceId: idHolder
]

{ #category : #private }
AthensCairoSurface class >> primUnregisterSurface: aCairoSurfaceId [
"
	ioUnregisterSurface:
	Unregister the surface with the given id.
	Returns true if successful, false otherwise. 

"
	<primitive: 'primitiveUnregisterSurface' module: 'SurfacePlugin'>

	"We keep the call to the FFI just in case we are running in an old VM"	

	^ self ioUnregisterSurface: aCairoSurfaceId
]

{ #category : #private }
AthensCairoSurface class >> primWidth: aWidth height: aHeight [
	^ self ffiCall: #( AthensCairoSurface cairo_image_surface_create (
						CAIRO_FORMAT_ARGB32,
						int aWidth,
						int aHeight) )
]

{ #category : #private }
AthensCairoSurface class >> registerSurface: anAthensCairoSurface [
	"register the cairo surface with surface plugin,
	so, it can be used directly by bitblt operations.
	Answer an id and unique session object"
	| id address |

	self checkSession.

	id := ByteArray new: 4.
	address := anAthensCairoSurface getHandle.
	(self primRegisterSurface: address dispatch: dispatch surfaceId: id)
		ifFalse: [ self error: 'Unable to register surface with SurfacePlugin' ].
	id := id signedLongAt: 1.
	
	^ id
]

{ #category : #private }
AthensCairoSurface class >> unregisterSurfaceWithId: anAthensCairoSurfaceId [

	self primUnregisterSurface: anAthensCairoSurfaceId
]

{ #category : #'instance creation' }
AthensCairoSurface class >> width: aWidth height: aHeight [
	^ (self primWidth: aWidth height: aHeight+1) initialize
]

{ #category : #converting }
AthensCairoSurface >> asAthensPaintOn: aCanvas [
	^ AthensCairoPatternSurfacePaint createForSurface: self.
 
]

{ #category : #converting }
AthensCairoSurface >> asForm [
	"create a form and copy an image data there"
	self checkSession.
	self flush.
 	^ (AthensCairoSurfaceForm extent: (self width@(self height)) depth: 32 bits: id)
		surface: self;
		yourself
]

{ #category : #drawing }
AthensCairoSurface >> attemptToRecurseDrawing [
	^ self 
]

{ #category : #caching }
AthensCairoSurface >> cacheAt: anObject ifAbsentPut: aBlock [
	"Answer an object from surface's cache identified by anObject,
	if there is no cached object under such identifier, evaluate a block
	and put it into cache. Then answer the result of evaluation.
	A surface using identity comparison for object identifiers.
	"
	^ CairoBackendCache soleInstance at: anObject ifAbsentPut: aBlock
]

{ #category : #private }
AthensCairoSurface >> checkSession [
	session == Smalltalk session ifFalse: [ 
		self error: 'Attempt to use invalid external resource (left from previous session)' ]
]

{ #category : #accessing }
AthensCairoSurface >> clear [
	^ self clear: Color transparent
]

{ #category : #accessing }
AthensCairoSurface >> clear: clearPaint [
	currentCanvas pathTransform restoreAfter: [
		currentCanvas pathTransform loadIdentity.
		currentCanvas paintMode restoreAfter: [
			currentCanvas paintMode source.
			currentCanvas 
				setPaint: clearPaint;
				drawShape: (0@0 extent: self extent).
				
        ]].


]

{ #category : #paints }
AthensCairoSurface >> createFormPaint: aForm [ 
	"here we should convert form to cairo surface"
	
	| newSurface |

	newSurface := self class fromForm: (aForm asFormOfDepth: 32).
	
	^ newSurface asAthensPaintOn: context


]

{ #category : #paints }
AthensCairoSurface >> createLinearGradient: aColorRamp start: aStartPoint stop: aStopPoint [
	^ AthensCairoGradientPaint 
		createLinearGradient: aColorRamp 
		start: aStartPoint 
		stop: aStopPoint
	
]

{ #category : #paints }
AthensCairoSurface >> createMeshGradientWithPatches: aListOfMeshPatches [
	^ AthensCairoMeshGradientPaint createMeshGradientWithPatches: aListOfMeshPatches
]

{ #category : #creation }
AthensCairoSurface >> createPath: aPathCreatingBlock [
	^ builder createPath:  aPathCreatingBlock 
]

{ #category : #paints }
AthensCairoSurface >> createRadialGradient: colorRamp center: aCenter radius: aRadius focalPoint: fp [
	^AthensCairoGradientPaint	
		radialBetween: fp
		extending: 0
		and: aCenter
		extending: aRadius
		withColorRamp: colorRamp
]

{ #category : #paints }
AthensCairoSurface >> createSolidColorPaint: aColor [ 

	^ AthensCairoSolidPaint new color: aColor
]

{ #category : #paints }
AthensCairoSurface >> createStrokePaintFor: aPaint [

	^ AthensCairoStrokePaint new fillPaint: aPaint
]

{ #category : #drawing }
AthensCairoSurface >> drawDuring: aBlock [

	"You may draw on receiver only when inside a block and only using provided canvas object.
	This ensures releasing system resources used after finishing drawing"

	self checkSession.
	
	currentCanvas ifNotNil: [ self attemptToRecurseDrawing ].
	[
		currentCanvas := context.
		self privSetDefaults.
		aBlock value: currentCanvas.
		self flush.
	] ensure: [
		currentCanvas := nil.
	].
]

{ #category : #accessing }
AthensCairoSurface >> extent [
	^ self width @ self height
]

{ #category : #'rendering dispatch' }
AthensCairoSurface >> fillPath: aPath withSolidColor: aColor [ 

	self loadSolidColor: aColor.
	
	currentCanvas 
		newPath;
		loadPath: aPath;
		fill
	
]

{ #category : #'rendering dispatch' }
AthensCairoSurface >> fillRectangle: aRectangle withSolidColor: aColor [

	self loadSolidColor: aColor.

	currentCanvas
		newPath;
		rectangleX: aRectangle left asFloat
		y: aRectangle top asFloat
		width: aRectangle width asFloat
		height: aRectangle height asFloat;
		fill
]

{ #category : #private }
AthensCairoSurface >> finish [
	^ self ffiCall: #( void cairo_surface_finish (self) )
]

{ #category : #private }
AthensCairoSurface >> flush [
	^ self ffiCall: #( void cairo_surface_flush (self) )
]

{ #category : #caching }
AthensCairoSurface >> flushCacheAt: anObject [

	"Flush (delete) any cached value(s) identified by given object, anObject.
	Do nothing if there's no cached values stored for given object.
	Answer receiver.

	A surface using identity comparison for object identifiers.
	"
	CairoBackendCache soleInstance removeAt: anObject
]

{ #category : #accessing }
AthensCairoSurface >> getDataPtr [
	"get a pointer to surface bitmap data"
	
	^ self ffiCall: #(
		void* cairo_image_surface_get_data ( self ) )


]

{ #category : #'text support' }
AthensCairoSurface >> getFreetypeFontRendererFor: aFreetypeFont [ 
	"answer the same instance, just reset it's font and advance"
	
	^ ftFontRenderer font: aFreetypeFont; advance: 0@0; yourself
]

{ #category : #accessing }
AthensCairoSurface >> getHandle [
	
	^ handle
]

{ #category : #'text support' }
AthensCairoSurface >> getStrikeFontRendererFor: aStrikeFont [ 
	"answer the same instance, just reset it's font and advance"
	
	^ AthensStrikeFontRenderer on: context  forFont: aStrikeFont.
]

{ #category : #accessing }
AthensCairoSurface >> handle [
	^ handle value
]

{ #category : #accessing }
AthensCairoSurface >> height [
	
	^self privateHeight - 1

]

{ #category : #initialization }
AthensCairoSurface >> initialize [
	"the handle should be set already since we using an NB callout to create an instance"
	handle value = 0 ifTrue: [ 
		self error: 'Error creating new surface' ].
	
	session := Smalltalk session.
	
	id := self class registerSurface: self.
		
	context := self newCanvas.
	builder := AthensCairoPathBuilder new.
	builder context: context.
	ftFontRenderer := CairoFreetypeFontRenderer new
		canvas: context. 
	
	FFIExternalResourceManager addResource: self.
]

{ #category : #testing }
AthensCairoSurface >> isSuccess [
	^ self status  =	CAIRO_STATUS_SUCCESS
]

{ #category : #'rendering dispatch' }
AthensCairoSurface >> loadSolidColor: aColor [
	currentCanvas setSourceR: aColor red g: aColor green b: aColor blue a: aColor alpha; resetDash
]

{ #category : #private }
AthensCairoSurface >> markDirty [
	^ self ffiCall: #( void cairo_surface_mark_dirty (self) )
]

{ #category : #private }
AthensCairoSurface >> newCanvas [
	"Answer a preinitialized instance of AthensCanvas.
	Private to receiver and its subclasses, override seldom"
	
	^ self primCreateCanvas surface: self


]

{ #category : #private }
AthensCairoSurface >> primCreateCanvas [
	^ self ffiCall: #( AthensCairoCanvas cairo_create (self) )
]

{ #category : #private }
AthensCairoSurface >> privSetDefaults [
	"reset matrices"
	currentCanvas pathTransform loadIdentity.
	currentCanvas paintTransform loadIdentity.
	currentCanvas paintMode over.
	

]

{ #category : #private }
AthensCairoSurface >> privateHeight [
	^ self ffiCall: #(
		int cairo_image_surface_get_height ( self ) )


]

{ #category : #initialization }
AthensCairoSurface >> resourceData [
	^ { handle value. id. context handle }
]

{ #category : #private }
AthensCairoSurface >> showPage [
	^ self ffiCall: #( void cairo_surface_show_page (self) )
]

{ #category : #accessing }
AthensCairoSurface >> status [
	^ self ffiCall: #(int cairo_surface_status (self) )
	
]

{ #category : #private }
AthensCairoSurface >> statusToString: aCairoStatusT [
	^ self ffiCall: #(String   cairo_status_to_string  (cairo_status_t aCairoStatusT))
]

{ #category : #accessing }
AthensCairoSurface >> stride [
	^ self ffiCall: #(
		int cairo_image_surface_get_stride ( self ) )


]

{ #category : #accessing }
AthensCairoSurface >> width [
	^ self ffiCall: #(
		int cairo_image_surface_get_width ( self ) )


]

{ #category : #converting }
AthensCairoSurface >> writeToPng: aFileName [
	^ self ffiCall: #(void cairo_surface_write_to_png (self, String aFileName) )

]
