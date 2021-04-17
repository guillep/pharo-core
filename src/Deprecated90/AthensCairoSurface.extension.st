Extension { #name : #AthensCairoSurface }

{ #category : #'*Deprecated90' }
AthensCairoSurface class >> ioFindSurface: id handle: handlePtr [
"	int ioFindSurface(int surfaceID, sqSurfaceDispatch *fn, int *surfaceHandle);
		Find the surface with the given ID, and, optionally,
		the given set of surface functions. The registered handle
		is returned in surfaceHandle. Return true if successful
		(e.g., the surface has been found), false otherwise.
"

	"This is deprecated... We should use the plugin. Mixing FFI calls and Primitive calls breaks the guarantees of the initialization of plugins."

	self ffiCall: #( bool ioFindSurface(int id, 0 , int *handlePtr) ) module: #SurfacePlugin
]

{ #category : #'*Deprecated90' }
AthensCairoSurface class >> ioRegisterSurface: aCairoSurfaceHandle dispatch: sqSurfaceDispatchPtr surfaceId: idHolder [
"
	int ioRegisterSurface(int surfaceHandle, sqSurfaceDispatch *fn, int *surfaceID);

	Register a new surface with the given handle and
	the set of surface functions. The new ID is returned
	in surfaceID. Returns true if successful, false 
	otherwise.

"

	"This is deprecated... We should use the plugin. Mixing FFI calls and Primitive calls breaks the guarantees of the initialization of plugins."

	self ffiCall: #(bool ioRegisterSurface(void* aCairoSurfaceHandle, void *sqSurfaceDispatchPtr, void *idHolder)) module: #SurfacePlugin
]

{ #category : #'*Deprecated90' }
AthensCairoSurface class >> ioUnregisterSurface: aCairoSurfaceId [
"
	ioUnregisterSurface:
	Unregister the surface with the given id.
	Returns true if successful, false otherwise. 

"
	"This is deprecated... We should use the plugin. Mixing FFI calls and Primitive calls breaks the guarantees of the initialization of plugins."
	
	self ffiCall: #( int ioUnregisterSurface(ulong aCairoSurfaceId) ) module: #SurfacePlugin
]
