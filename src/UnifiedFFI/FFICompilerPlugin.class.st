"
I am a FFICompilerPlugin - a compiler plugin for the OpalCompiler that makes the compiled method store the arguments names to be used for FFI when the sources are not loaded or unloaded.
I can be activated with the command 

  FFICompilerPlugin install

I am pragma-based to detect the methods where the arguments names should be remembered.
The pragma should be added in the FFI API methods, i.e., the methods that are called by the FFI methods where the arguments have to be remembered.
Example:

This FFI method should remember the name of the argument named config:

repository_config: config
	^ self
		call: #(#LGitReturnCodeEnum #git_repository_config #(#LGitConfig #* #config #, #self))
		options: #()

So, the FFI function should wear the pragma <ffiCalloutTranslator>:

call: fnSpec options: options
	<ffiCalloutTranslator>
	^ (self safeFFICalloutIn: thisContext sender)
		cdecl;
		options: options;
		function: fnSpec module: self ffiLibraryName

To remove to be able to remove the sources (.changes and .sources), you only have to activate the plugin, no recompilation is necessary. You can even import new FFI methods or change the FFI API.

N.B: Users that redefine the FFI API (like TLGitCalloutTrait >> call:options:) also have to wear the pragma. See also FFIAdditionalFFIMethodState and FDBDecompiler>>createNArgs:
"
Class {
	#name : #FFICompilerPlugin,
	#superclass : #OCStaticASTCompilerPlugin,
	#classVars : [
		'FFICalloutSelectors'
	],
	#category : #'UnifiedFFI-Base'
}

{ #category : #accessing }
FFICompilerPlugin class >> ffiCalloutSelectors [
	<script: 'self ffiCalloutSelectors inspect'>
	
	^FFICalloutSelectors ifNil: [ self initializeFFICalloutSelectors ]
]

{ #category : #'class initialization' }
FFICompilerPlugin class >> initialize [

	self 
		initializeFFICalloutSelectors;
		recompileSenders;
		install
]

{ #category : #private }
FFICompilerPlugin class >> initializeFFICalloutSelectors [

	FFICalloutSelectors := (Pragma allNamed: #ffiCalloutTranslator) collect: [ :pragma | pragma method selector ] as: IdentitySet
]

{ #category : #installation }
FFICompilerPlugin class >> install [
	<script>
	(CompilationContext defaultTransformationPlugins includes: self)
		ifTrue: [ ^ self ].
	CompilationContext addDefaultTransformationPlugin: self.
	self recompileSenders.
]

{ #category : #private }
FFICompilerPlugin class >> priority [
	^ 2
]

{ #category : #private }
FFICompilerPlugin class >> recompileSenders [

	self ffiCalloutSelectors do: [ :selector | selector senders do: [ :sender | sender recompile ] ]
]

{ #category : #installation }
FFICompilerPlugin class >> uninstall [
	<script>
	CompilationContext removeDefaultTransformationPlugin: self.
	self recompileSenders
]

{ #category : #'private - accessing' }
FFICompilerPlugin >> ffiCalloutSelectors [

	^self class ffiCalloutSelectors
]

{ #category : #api }
FFICompilerPlugin >> transform [
	"While plugin is used to compile every method we can use it for two purposes:
		- collect all ffiCallout selectors like ffiCall:, nbCall:
		- mark ffi methods which use collected selectors that they are FFI"
	self transformsFFIMethod ifFalse: [ ^ast].
	 
	ast ensureCachedArgumentNames.
	ast methodPropertyAt: #isFFIMethod put: true.
	^ast
]

{ #category : #api }
FFICompilerPlugin >> transformsFFIMethod [
	
	(ast hasPragmaNamed: #ffiCalloutTranslator)
		ifTrue: [ ^ false ].
	ast nodesDo: [ :each | 
			each isMessage ifTrue: [
				(self ffiCalloutSelectors includes: each selector)
					ifTrue: [ ^ true ] ] ].
	^ false
]
