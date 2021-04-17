Class {
	#name : #KMShortcutPrinterTest,
	#superclass : #ParametrizedTestCase,
	#instVars : [
		'platform',
		'shortcut',
		'result'
	],
	#category : #'Keymapping-Tests'
}

{ #category : #'building suites' }
KMShortcutPrinterTest class >> testParameters [
	| cmd ctrl alt shift enter |

	cmd :=	 (Character value: 16r2318) asString.
	alt := (Character value: 16r2325) asString. 
	ctrl := (Character value: 16r2303) asString. 
	shift := (Character value: 16r21E7) asString.
	enter := (Character value: 16r23ce) asString.

	^ super testParameters
		"linux"
		addCase: { #platform -> UnixPlatform new. #shortcut -> $n meta. #result -> 'Ctrl+N' };
		addCase: { #platform -> UnixPlatform new. #shortcut -> $n command. #result -> 'Cmd+N' };
		addCase: { #platform -> UnixPlatform new. #shortcut -> $n control. #result -> 'Ctrl+N' };
		addCase: { #platform -> UnixPlatform new. #shortcut -> $n alt. #result -> 'Alt+N' };
		addCase: { #platform -> UnixPlatform new. #shortcut -> $n shift. #result -> 'Shift+N' };
		addCase: { 
			#platform -> UnixPlatform new. 
			#shortcut -> $n shift alt control command. 
			#result -> 'Shift+Alt+Ctrl+Cmd+N' };
		addCase: { 
			#platform -> UnixPlatform new. 
			#shortcut -> Character cr shift. 
			#result -> 'Shift+Enter' };
		"windows"
		addCase: { #platform -> WinPlatform new. #shortcut -> $n meta. #result -> 'Ctrl+N' };
		addCase: { #platform -> WinPlatform new. #shortcut -> $n command. #result -> 'Cmd+N' };
		addCase: { #platform -> WinPlatform new. #shortcut -> $n control. #result -> 'Ctrl+N' };
		addCase: { #platform -> WinPlatform new. #shortcut -> $n alt. #result -> 'Alt+N' };
		addCase: { #platform -> WinPlatform new. #shortcut -> $n shift. #result -> 'Shift+N' };
		addCase: { 
			#platform -> WinPlatform new. 
			#shortcut -> $n shift alt control command. 
			#result -> 'Shift+Alt+Ctrl+Cmd+N' };
		addCase: { 
			#platform -> WinPlatform new. 
			#shortcut -> Character cr shift. 
			#result -> 'Shift+Enter' };
		"mac"
		addCase: { #platform -> MacOSPlatform new. #shortcut -> $n command. #result -> (cmd, 'N') };
		addCase: { #platform -> MacOSPlatform new. #shortcut -> $n control. #result -> (ctrl, 'N') };
		addCase: { #platform -> MacOSPlatform new. #shortcut -> $n alt. #result -> (alt, 'N') };
		addCase: { #platform -> MacOSPlatform new. #shortcut -> $n shift. #result -> (shift, 'N') };
		addCase: { 
			#platform -> MacOSPlatform new. 
			#shortcut -> $n shift alt control command. 
			#result -> (shift, alt, ctrl, cmd, 'N') };
		addCase: { 
			#platform -> MacOSPlatform new. 
			#shortcut -> Character cr shift. 
			#result -> (shift, enter) };
		addCase: { #platform -> MacOSPlatform new. #shortcut -> ($n shift , $m shift). #result -> (shift, 'N' , ',' , shift , 'M') };
		addCase: { #platform -> UnixPlatform new. #shortcut -> ($n shift , $m shift). #result -> 'Shift+N,Shift+M' };
		addCase: { #platform -> WinPlatform new. #shortcut -> ($n shift , $m shift). #result -> 'Shift+N,Shift+M' };
		addCase: { #platform -> MacOSPlatform new. #shortcut -> ($n control , $m control). #result -> (ctrl, 'N' , ',' , ctrl , 'M') };
		addCase: { #platform -> UnixPlatform new. #shortcut -> ($n control , $m control). #result -> 'Ctrl+N,Ctrl+M' };
		addCase: { #platform -> WinPlatform new. #shortcut -> ($n control , $m control). #result -> 'Ctrl+N,Ctrl+M' }

]

{ #category : #accessing }
KMShortcutPrinterTest >> platform [
	^ platform
]

{ #category : #accessing }
KMShortcutPrinterTest >> platform: anObject [
	platform := anObject
]

{ #category : #accessing }
KMShortcutPrinterTest >> result [
	^ result
]

{ #category : #accessing }
KMShortcutPrinterTest >> result: anObject [
	result := anObject
]

{ #category : #accessing }
KMShortcutPrinterTest >> shortcut [
	^ shortcut
]

{ #category : #accessing }
KMShortcutPrinterTest >> shortcut: anObject [
	shortcut := anObject
]

{ #category : #tests }
KMShortcutPrinterTest >> testPrintShortcut [
	| printed |

	printed := shortcut acceptVisitor: platform shortcutPrinter.
	self assert: printed equals: result
]
