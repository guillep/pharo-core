"
I represent a keyboard Key, I am independent from the text issued from myself.
That is, when you press e.g., the combination Alt + A, you get the Character å (as in ""an instance of Character"") in a text event, but in the KeyDown/Up events you get an instance of the myself, the KeyboardKey A (see section Keys vs Characters below).

# Implementation details

I keep a flyweight of Keys that can be accessed by id or name.

```
KeyboardKey value: anID.
KeyboardKey named: 'RETURN'.
```

The ID of a key corresponds to the keycodes in Unix's X11 key mapping.
Such ID was chosen because Unix X11 is a super set of the keys supported in Win32 and Cocoa.

Internally I also keep a mapping between Win32 and Cocoa keycodes to X11's keycodes.
See my class side:
```
valueForWindowsPlatform:
valueForUnixPlatform:
valueForMacOSXPlatform:
```

# Keys vs Characters

KeyboardKeys and characters do not have a 1 to 1 mapping. Be careful that keys and Characters do not represent the same thing, specially when we are outside of the english alphabet. In such cases, a Key like E could trigger a Character like e or € depending on the configured keyboard layout and key combinations done. This is specially trickier in asian alphabets.

For backwards compatibility, I provide a helper method that tries to do a mapping in the direction Character -> key (see fromCharacter:) but should be used sparingly and it will be deprecated in the future.
"
Class {
	#name : #KeyboardKey,
	#superclass : #Object,
	#instVars : [
		'value',
		'name'
	],
	#classVars : [
		'KeyCodeTable',
		'KeyFromCharacterTable',
		'KeyNameTable',
		'MacosVirtualKeyTable',
		'UnixVirtualKeyTable',
		'WindowsVirtualKeyTable'
	],
	#category : #'System-Platforms-Utilities'
}

{ #category : #accessing }
KeyboardKey class >> A [
	^ self named: 'A'
]

{ #category : #accessing }
KeyboardKey class >> B [
	^ self named: 'B'
]

{ #category : #accessing }
KeyboardKey class >> C [
	^ self named: 'C'
]

{ #category : #accessing }
KeyboardKey class >> D [
	^ self named: 'D'
]

{ #category : #accessing }
KeyboardKey class >> E [
	^ self named: 'E'
]

{ #category : #accessing }
KeyboardKey class >> F [
	^ self named: 'F'
]

{ #category : #accessing }
KeyboardKey class >> G [
	^ self named: 'G'
]

{ #category : #accessing }
KeyboardKey class >> H [
	^ self named: 'H'
]

{ #category : #accessing }
KeyboardKey class >> I [
	^ self named: 'I'
]

{ #category : #accessing }
KeyboardKey class >> J [
	^ self named: 'J'
]

{ #category : #accessing }
KeyboardKey class >> K [
	^ self named: 'K'
]

{ #category : #accessing }
KeyboardKey class >> L [
	^ self named: 'L'
]

{ #category : #accessing }
KeyboardKey class >> M [
	^ self named: 'M'
]

{ #category : #accessing }
KeyboardKey class >> N [
	^ self named: 'N'
]

{ #category : #accessing }
KeyboardKey class >> O [
	^ self named: 'O'
]

{ #category : #accessing }
KeyboardKey class >> P [
	^ self named: 'P'
]

{ #category : #accessing }
KeyboardKey class >> Q [
	^ self named: 'Q'
]

{ #category : #accessing }
KeyboardKey class >> R [
	^ self named: 'R'
]

{ #category : #accessing }
KeyboardKey class >> S [
	^ self named: 'S'
]

{ #category : #accessing }
KeyboardKey class >> T [
	^ self named: 'T'
]

{ #category : #accessing }
KeyboardKey class >> U [
	^ self named: 'U'
]

{ #category : #accessing }
KeyboardKey class >> V [
	^ self named: 'V'
]

{ #category : #accessing }
KeyboardKey class >> W [
	^ self named: 'W'
]

{ #category : #accessing }
KeyboardKey class >> X [
	^ self named: 'X'
]

{ #category : #accessing }
KeyboardKey class >> Y [
	^ self named: 'Y'
]

{ #category : #accessing }
KeyboardKey class >> Z [
	^ self named: 'Z'
]

{ #category : #accessing }
KeyboardKey class >> backspace [

	^ self named: 'BACKSPACE'
]

{ #category : #accessing }
KeyboardKey class >> braceLeft [
	
	^ self named: 'BRACELEFT'
]

{ #category : #accessing }
KeyboardKey class >> bracketLeft [
	
	^ self named: 'BRACKETLEFT'
]

{ #category : #accessing }
KeyboardKey class >> comma [
	
	^ self named: 'COMMA'
]

{ #category : #accessing }
KeyboardKey class >> delete [

	^ self named: 'DELETE'
]

{ #category : #accessing }
KeyboardKey class >> doubleQuote [

	^ self named: 'QUOTEDBL'
]

{ #category : #accessing }
KeyboardKey class >> down [

	^ self named: 'DOWN'
]

{ #category : #accessing }
KeyboardKey class >> end [
	
	^ self named: 'END'
]

{ #category : #accessing }
KeyboardKey class >> enter [

	^ self named: 'RETURN'
]

{ #category : #accessing }
KeyboardKey class >> equal [

	^ self named: 'EQUAL'
]

{ #category : #accessing }
KeyboardKey class >> escape [

	^ self named: 'ESCAPE'
]

{ #category : #'instance creation' }
KeyboardKey class >> fromCharacter: aCharacter [
	"For backwards compatibility mainly.
	Return the key that should correspond to some character.
	Handle normal ascii characters and special control keys only (enter, tab space...)
	
	 (KeyboardKey fromCharacter: $a) >>> KeyboardKey A
	"
	
	^ self keyFromCharacterTable at: aCharacter ifAbsent: [ self named: aCharacter asString asUppercase ]
]

{ #category : #'instance creation' }
KeyboardKey class >> fromCharacter: aCharacter ifNone: aBlock [
	"For backwards compatibility mainly.
	Return the key that should correspond to some character.
	Handle normal ascii characters and special control keys only (enter, tab space...)
	
	 (KeyboardKey fromCharacter: $a) >>> KeyboardKey A
	"
	
	^ self keyFromCharacterTable
		at: aCharacter 
		ifAbsent: [ 
			self
				named: aCharacter asString asUppercase
				ifNone: aBlock ]
]

{ #category : #accessing }
KeyboardKey class >> home [
	
	^ self named: 'HOME'
]

{ #category : #'class initialization' }
KeyboardKey class >> initialize [
	self
		initializeKeyTable;
		initializeMacOSVirtualKeyTable;
		initializeUnixVirtualKeyTable;
		initializeWindowsVirtualKeyTable;
		initializeKeyFromCharacterCompatibilityTable
]

{ #category : #'key table' }
KeyboardKey class >> initializeKeyFromCharacterCompatibilityTable [
	KeyFromCharacterTable := Dictionary new.
	{ 
		Character backspace 	. #Backspace "XK_BackSpace".
		Character tab 			. #Tab "XK_Tab".
		Character cr 			. #Return "XK_Return".
		Character escape		. #Escape "XK_Escape".
		Character home			. #Home "XK_Home".
		Character arrowLeft 	. #Left "XK_Left".
		Character arrowUp 		. #Up "XK_Up".
		Character arrowRight 	. #Right "XK_Right".
		Character arrowDown 	. #Down "XK_Down".
		Character pageUp 		. #Page_Up "XK_Page_Up".
		Character pageDown 	. #Page_Down "XK_Page_Down".
		Character end 			. #End "XK_End".
		Character space 		. #Space "XK_Space".
		$/ 							. #SLASH.
		$] 							. #BRACKETLEFT.
		$[ 							. #BRACKETRIGHT.
		$( 							. #parenleft.
		$) 							. #parenright.
		$< 							. #less.
		$< 							. #greater.
		$| 							. #bar.
		$- 							. #minus}
			pairsDo: [ :character :keyname |
				KeyFromCharacterTable at: character put: (self named: keyname asUppercase) ].
]

{ #category : #'key table' }
KeyboardKey class >> initializeKeyTable [
	KeyCodeTable := Dictionary new.
	KeyNameTable := Dictionary new.
	#(
		16r0000 Null
		16r08f6 Function "XK_function"
		16rff08 BackSpace "XK_BackSpace"
		16rff09 Tab "XK_Tab"
		16rff0a Linefeed "XK_Linefeed"
		16rff0b Clear "XK_Clear"
		16rff0d Return "XK_Return"
		16rff13 Pause "XK_Pause"
		16rff14 Scroll_Lock "XK_Scroll_Lock"
		16rff15 Sys_Req "XK_Sys_Req"
		16rff1b Escape "XK_Escape"
		16rffff Delete "XK_Delete"
		16rff50 Home "XK_Home"
		16rff51 Left "XK_Left"
		16rff52 Up "XK_Up"
		16rff53 Right "XK_Right"
		16rff54 Down "XK_Down"
		16rff55 Prior "XK_Prior"
		16rfe03 Level3Shift "XK_ISO_Level3_Shift"
		16r00a1 ExclamationDown "XK_exclamdown"
		16r00bf QuestionDown "XK_questiondown"
		16r00f1 NTilde "XK_ntilde"
		16r00d1 CapitalNTilde "XK_ntilde"
		16r00ba Masculine "XK_masculine"
		16r00e7 CCedilla "XK_ccedilla"
		16r00c7 CapitalCCedilla "XK_ccedilla"
		16r00aa FeminineOrdinal "XK_ordfeminine"
		16r00b7 MiddlePoint "XK_periodcentered"
		"16rff55 Prior ""XK_Prior"
		16rff55 Page_Up "XK_Page_Up"
		"16rff56 Next" "XK_Next"
		16rff56 Page_Down "XK_Page_Down"
		16rff57 End "XK_End"
		16rff58 Begin "XK_Begin"
		16rff80 KP_Space "XK_KP_Space"
		16rff89 KP_Tab "XK_KP_Tab"
		16rff8d KP_Enter "XK_KP_Enter"
		16rff91 KP_F1 "XK_KP_F1"
		16rff92 KP_F2 "XK_KP_F2"
		16rff93 KP_F3 "XK_KP_F3"
		16rff94 KP_F4 "XK_KP_F4"
		16rff95 KP_Home "XK_KP_Home"
		16rff96 KP_Left "XK_KP_Left"
		16rff97 KP_Up "XK_KP_Up"
		16rff98 KP_Right "XK_KP_Right"
		16rff99 KP_Down "XK_KP_Down"
		16rff9a KP_Prior "XK_KP_Prior"
		16rff9a KP_Page_Up "XK_KP_Page_Up"
		16rff9b KP_Next "XK_KP_Next"
		16rff9b KP_Page_Down "XK_KP_Page_Down"
		16rff9c KP_End "XK_KP_End"
		16rff9d KP_Begin "XK_KP_Begin"
		16rff9e KP_Insert "XK_KP_Insert"
		16rff9f KP_Delete "XK_KP_Delete"
		16rffbd KP_Equal "XK_KP_Equal"
		16rffaa KP_Multiply "XK_KP_Multiply"
		16rffab KP_Add "XK_KP_Add"
		16rffac KP_Separator "XK_KP_Separator"
		16rffad KP_Subtract "XK_KP_Subtract"
		16rffae KP_Decimal "XK_KP_Decimal"
		16rffaf KP_Divide "XK_KP_Divide"
		16rffb0 KP_0 "XK_KP_0"
		16rffb1 KP_1 "XK_KP_1"
		16rffb2 KP_2 "XK_KP_2"
		16rffb3 KP_3 "XK_KP_3"
		16rffb4 KP_4 "XK_KP_4"
		16rffb5 KP_5 "XK_KP_5"
		16rffb6 KP_6 "XK_KP_6"
		16rffb7 KP_7 "XK_KP_7"
		16rffb8 KP_8 "XK_KP_8"
		16rffb9 KP_9 "XK_KP_9"
		16rffbe F1 "XK_F1"
		16rffbf F2 "XK_F2"
		16rffc0 F3 "XK_F3"
		16rffc1 F4 "XK_F4"
		16rffc2 F5 "XK_F5"
		16rffc3 F6 "XK_F6"
		16rffc4 F7 "XK_F7"
		16rffc5 F8 "XK_F8"
		16rffc6 F9 "XK_F9"
		16rffc7 F10 "XK_F10"
		16rffc8 F11 "XK_F11"
		16rffc9 F12 "XK_F12"
		16rffe1 Shift_L "XK_Shift_L"
		16rffe2 Shift_R "XK_Shift_R"
		16rffe3 Control_L "XK_Control_L"
		16rffe4 Control_R "XK_Control_R"
		16rffe5 Caps_Lock "XK_Caps_Lock"
		16rffe6 Shift_Lock "XK_Shift_Lock"
		16rffe7 Meta_L "XK_Meta_L"
		16rffe8 Meta_R "XK_Meta_R"
		16rffe9 Alt_L "XK_Alt_L"
		16rffea Alt_R "XK_Alt_R"
		16rffeb Super_L "XK_Super_L"
		16rffec Super_R "XK_Super_R"
		16rffed Hyper_L "XK_Hyper_L"
		16rffee Hyper_R "XK_Hyper_R"
		16rfe50 dead_grave "XK_dead_grave"
		16rfe51 dead_acute "XK_dead_acute"
		16rfe52 dead_circumflex "XK_dead_circumflex"
		16rfe53 dead_tilde "XK_dead_tilde"
		16rfe53 dead_perispomeni "XK_dead_perispomeni"
		16rfe54 dead_macron "XK_dead_macron"
		16rfe55 dead_breve "XK_dead_breve"
		16rfe56 dead_abovedot "XK_dead_abovedot"
		16rfe57 dead_diaeresis "XK_dead_diaeresis"
		16rfe58 dead_abovering "XK_dead_abovering"
		16rfe59 dead_doubleacute "XK_dead_doubleacute"
		16rfe5a dead_caron "XK_dead_caron"
		16rfe5b dead_cedilla "XK_dead_cedilla"
		16rfe5c dead_ogonek "XK_dead_ogonek"
		16rfe5d dead_iota "XK_dead_iota"
		16rfe5e dead_voiced_sound "XK_dead_voiced_sound"
		16rfe5f dead_semivoiced_sound "XK_dead_semivoiced_sound"
		16rfe60 dead_belowdot "XK_dead_belowdot"
		16rfe61 dead_hook "XK_dead_hook"
		16rfe62 dead_horn "XK_dead_horn"
		16rfe63 dead_stroke "XK_dead_stroke"
		16rfe64 dead_abovecomma "XK_dead_abovecomma"
		16rfe64 dead_psili "XK_dead_psili"
		16rfe65 dead_abovereversedcomma "XK_dead_abovereversedcomma"
		16rfe65 dead_dasia "XK_dead_dasia"
		16rfe66 dead_doublegrave "XK_dead_doublegrave"
		16rfe67 dead_belowring "XK_dead_belowring"
		16rfe68 dead_belowmacron "XK_dead_belowmacron"
		16rfe69 dead_belowcircumflex "XK_dead_belowcircumflex"
		16rfe6a dead_belowtilde "XK_dead_belowtilde"
		16rfe6b dead_belowbreve "XK_dead_belowbreve"
		16rfe6c dead_belowdiaeresis "XK_dead_belowdiaeresis"
		16rfe6d dead_invertedbreve "XK_dead_invertedbreve"
		16rfe6e dead_belowcomma "XK_dead_belowcomma"
		16rfe6f dead_currency "XK_dead_currency"
		16r0020 space "XK_space"
		16r0021 exclam "XK_exclam"
		16r0022 quotedbl "XK_quotedbl"
		16r0023 numbersign "XK_numbersign"
		16r0024 dollar "XK_dollar"
		16r0025 percent "XK_percent"
		16r0026 ampersand "XK_ampersand"
		16r0027 apostrophe "XK_apostrophe"
		"16r0027 quoteright" "XK_quoteright"
		16r0028 parenleft "XK_parenleft"
		16r0029 parenright "XK_parenright"
		16r002a asterisk "XK_asterisk"
		16r002b plus "XK_plus"
		16r002c comma "XK_comma"
		16r002d minus "XK_minus"
		16r002e period "XK_period"
		16r002f slash "XK_slash"
		16r0030 0 "XK_0"
		16r0031 1 "XK_1"
		16r0032 2 "XK_2"
		16r0033 3 "XK_3"
		16r0034 4 "XK_4"
		16r0035 5 "XK_5"
		16r0036 6 "XK_6"
		16r0037 7 "XK_7"
		16r0038 8 "XK_8"
		16r0039 9 "XK_9"
		16r003a colon "XK_colon"
		16r003b semicolon "XK_semicolon"
		16r003c less "XK_less"
		16r003d equal "XK_equal"
		16r003e greater "XK_greater"
		16r003f question "XK_question"
		16r0040 at "XK_at"
		16r0041 A "XK_A"
		16r0042 B "XK_B"
		16r0043 C "XK_C"
		16r0044 D "XK_D"
		16r0045 E "XK_E"
		16r0046 F "XK_F"
		16r0047 G "XK_G"
		16r0048 H "XK_H"
		16r0049 I "XK_I"
		16r004a J "XK_J"
		16r004b K "XK_K"
		16r004c L "XK_L"
		16r004d M "XK_M"
		16r004e N "XK_N"
		16r004f O "XK_O"
		16r0050 P "XK_P"
		16r0051 Q "XK_Q"
		16r0052 R "XK_R"
		16r0053 S "XK_S"
		16r0054 T "XK_T"
		16r0055 U "XK_U"
		16r0056 V "XK_V"
		16r0057 W "XK_W"
		16r0058 X "XK_X"
		16r0059 Y "XK_Y"
		16r005a Z "XK_Z"
		16r005b bracketleft "XK_bracketleft"
		16r005c backslash "XK_backslash"
		16r005d bracketright "XK_bracketright"
		16r005e asciicircum "XK_asciicircum"
		16r005f underscore "XK_underscore"
		16r0060 grave "XK_grave"
		"16r0060 quoteleft" "XK_quoteleft"
		16r007b braceleft "XK_braceleft"	
		16r007c bar "XK_bar"
		16r007d braceright "XK_braceright"
		16r007e asciitilde "XK_asciitilde"
		16rff63 Insert "XK_Insert"
		16rff7f Num_Lock "XK_Num_Lock"
		
		16rffca F13	 "XK_F13"
		16rffcb F14	 "XK_F14"
		16rffcc F15	 "XK_F15"
		16rffcd F16	 "XK_F16"
		16rffce F17	 "XK_F17"
		16rffcf F18	 "XK_F18"
		16rffd0 F19	 "XK_F19"
		16rffd1 F20	 "XK_F20"
		16rffd2 F21	 "XK_F21"
		16rffd3 F22	 "XK_F22"
		16rffd4 F23	 "XK_F23"
		16rffd5 F24	 "XK_F24"
			
		16rff60 Select "XK_Select"
		16rff61 Print "XK_Print"
		16rff62 Execute "XK_Execute"
		16rff63 Insert "XK_Insert"
		16rff65 Undo "XK_Undo"
		16rff66 Redo "XK_Redo"
		16rff67 Menu "XK_Menu"
		16rff68 Find "XK_Find"
		16rff69 Cancel "XK_Cancel"
		16rff6a Help "XK_Help"
		16rff6b Break "XK_Break"

		16rff15 Sys_Req "XK_Sys_Req"
		16rfd1d PrintScreen "XK_3270_PrintScreen"
		16rfd1b ExSelect "XK_3270_ExSelect"
		16rfd1c CursorSelect "XK_3270_CursorSelect"

		16r1008FF57 Copy "XF86XK_Copy"
		16r1008FF58 Cut "XF86XK_Cut"
		16r1008FF6D Paste "XF86XK_Paste"

		)
			pairsDo: [ :keyCode :keyname |
			|key|
			key := self basicNew withValue: keyCode andName: keyname asString asUppercase asSymbol.
			KeyCodeTable at: keyCode put: key.
			KeyNameTable at: key name put: key.
		].
]

{ #category : #macos }
KeyboardKey class >> initializeMacOSVirtualKeyTable [
	self flag: #pharoTodo. "Some values are missing, need to gather them from users who are able to."
	MacosVirtualKeyTable := Dictionary new.
	MacosVirtualKeyTable
		at: 16r24 put: (self value: 16rff0d); " kVK_Return                    = 0x24"
		at: 16r30 put: (self value: 16rff09); "  kVK_Tab                       = 0x30"
		at: 16r31 put: (self value: 16rff80); "  kVK_Space                     = 0x31"
		at: 16r33 put: (self value: 16rFF08); "  kVK_Backspace                 = 0x33 "
		at: 16r35 put: (self value: 16rff1b); "  kVK_Escape                    = 0x35"
		at: 16r37 put: (self value: 16rffe7); "  kVK_Command                   = 0x37"
		at: 16r38 put: (self value: 16rffe1); "  kVK_Shift                     = 0x38"
		at: 16r39 put: (self value: 16rffe5); "  kVK_CapsLock                  = 0x39"
		at: 16r3A put: (self value: 16rffe9); "  kVK_Option                    = 0x3A"
		at: 16r3B put: (self value: 16rffe3); "  kVK_Control                   = 0x3B"
		at: 16r3C put: (self value: 16rffe2); "  kVK_RightShift                = 0x3C"
		at: 16r3D put: (self value: 16rffea); "  kVK_RightOption               = 0x3D"
		at: 16r3E put: (self value: 16rffe4); "  kVK_RightControl              = 0x3E"
		at: 16r3F put: (self value: 16r08f6); "  kVK_Function                  = 0x3F"
		at: 16r48 put: (self value: 16r48); "  kVK_VolumeUp                  = 0x48"  "Not mapped"
		at: 16r49 put: (self value: 16r49); "  kVK_VolumeDown                = 0x49" "Not mapped"
		at: 16r4A put: (self value: 16r4A); "  kVK_Mute                      = 0x4A" "Not mapped"
		at: 16r7A put: (self value: 16rffbe); "  kVK_F1                        = 0x7A"
		at: 16r78 put: (self value: 16rffbf); "  kVK_F2                        = 0x78"
		at: 16r63 put: (self value: 16rffc0); "  kVK_F3                        = 0x63"
		at: 16r76 put: (self value: 16rffc1); "  kVK_F4                        = 0x76"
		at: 16r60 put: (self value: 16rffc2); "  kVK_F5                        = 0x60"
		at: 16r61 put: (self value: 16rffc3); "  kVK_F6                        = 0x61"
		at: 16r62 put: (self value: 16rffc4); "  kVK_F7                        = 0x62"
		at: 16r64 put: (self value: 16rffc5); "  kVK_F8                        = 0x64"
		at: 16r65 put: (self value: 16rffc6); "  kVK_F9                        = 0x65"
		at: 16r67 put: (self value: 16rffc8); "  kVK_F11                       = 0x67"
		at: 16r6D put: (self value: 16rffc7); "  kVK_F10                       = 0x6D"
		at: 16r6F put: (self value: 16rffc9); "  kVK_F12                       = 0x6F"
		"at: 16r72 put: (self value: 16r72);" "  kVK_Help                      = 0x72" "Not mapped"
		at: 16r73 put: (self value: 16rff50); "  kVK_Home                      = 0x73"
		at: 16r74 put: (self value: 16rff55); "  kVK_PageUp                    = 0x74"
		at: 16r75 put: (self value: 16rffff); "  kVK_ForwardDelete             = 0x75"
		at: 16r77 put: (self value: 16rff57); "  kVK_End                       = 0x77"
		at: 16r79 put: (self value: 16rff56); "  kVK_PageDown                  = 0x79"
		at: 16r7B put: (self value: 16rff96); "  kVK_LeftArrow                 = 0x7B"
		at: 16r7C put: (self value: 16rff98); "  kVK_RightArrow                = 0x7C"
		at: 16r7D put: (self value: 16rff99); "  kVK_DownArrow                 = 0x7D"
		at: 16r7E put: (self value: 16rff97); "  kVK_UpArrow                   = 0x7E"
		at: 16r00 put: (self value: 16r41); "kVK_ANSI_A                    = 0x00"
		at: 16r0B put: (self value: 16r42); "  kVK_ANSI_B                    = 0x0B"
		at: 16r08 put: (self value: 16r43); "  kVK_ANSI_C                    = 0x08"
		at: 16r02 put: (self value: 16r44); "  kVK_ANSI_D                    = 0x02"
		at: 16r0E put: (self value: 16r45); "  kVK_ANSI_E                    = 0x0E"
		at: 16r03 put: (self value: 16r46); "  kVK_ANSI_F                    = 0x03"
		at: 16r05 put: (self value: 16r47); "  kVK_ANSI_G                    = 0x05"
		at: 16r04 put: (self value: 16r48); "  kVK_ANSI_H                    = 0x04"
		at: 16r22 put: (self value: 16r49); "  kVK_ANSI_I                    = 0x22"
		at: 16r26 put: (self value: 16r4a); "  kVK_ANSI_J                    = 0x26"
		at: 16r28 put: (self value: 16r4b); "  kVK_ANSI_K                    = 0x28"
		at: 16r25 put: (self value: 16r4c); "  kVK_ANSI_L                    = 0x25"
		at: 16r2E put: (self value: 16r4d); "  kVK_ANSI_M                    = 0x2E"
		at: 16r2D put: (self value: 16r4e); "  kVK_ANSI_N                    = 0x2D"
		at: 16r1F put: (self value: 16r4f); "  kVK_ANSI_O                    = 0x1F"
		at: 16r23 put: (self value: 16r50); "  kVK_ANSI_P                    = 0x23"
		at: 16r0C put: (self value: 16r51); "  kVK_ANSI_Q                    = 0x0C"
		at: 16r0F put: (self value: 16r52); "  kVK_ANSI_R                    = 0x0F"
		at: 16r01 put: (self value: 16r53); "  kVK_ANSI_S                    = 0x01"
		at: 16r11 put: (self value: 16r54); "  kVK_ANSI_T                    = 0x11"
		at: 16r20 put: (self value: 16r55); "  kVK_ANSI_U                    = 0x20"
		at: 16r09 put: (self value: 16r56); "  kVK_ANSI_V                    = 0x09"
		at: 16r0D put: (self value: 16r57); "  kVK_ANSI_W                    = 0x0D"
		at: 16r07 put: (self value: 16r58); "  kVK_ANSI_X                    = 0x07"
		at: 16r10 put: (self value: 16r59); "  kVK_ANSI_Y                    = 0x10"
		at: 16r06 put: (self value: 16r5a); "  kVK_ANSI_Z                    = 0x06"
		
		at: 16r1D put: (self value: 16r30); "  kVK_ANSI_0                    = 0x1D"
		at: 16r12 put: (self value: 16r31); "  kVK_ANSI_1                    = 0x12"
		at: 16r13 put: (self value: 16r32); "  kVK_ANSI_2                    = 0x13"
		at: 16r14 put: (self value: 16r33); "  kVK_ANSI_3                    = 0x14"
		at: 16r15 put: (self value: 16r34); "  kVK_ANSI_4                    = 0x15"
		at: 16r17 put: (self value: 16r35); "  kVK_ANSI_5                    = 0x17"
		at: 16r16 put: (self value: 16r36); "  kVK_ANSI_6                    = 0x16"
		at: 16r1A put: (self value: 16r37); "  kVK_ANSI_7                    = 0x1A"
		at: 16r1C put: (self value: 16r38); "  kVK_ANSI_8                    = 0x1C"
		at: 16r19 put: (self value: 16r39); "  kVK_ANSI_9                    = 0x19"

		at: 16r1B put: (self value: 16r2d); "  kVK_ANSI_Minus                = 0x1B"
		at: 16r18 put: (self value: 16r3d); "  kVK_ANSI_Equal                = 0x18"
		at: 16r21 put: (self value: 16r5b); "  kVK_ANSI_LeftBracket          = 0x21"
		at: 16r1E put: (self value: 16r5d); "  kVK_ANSI_RightBracket         = 0x1E"
		at: 16r27 put: (self value: 16r27); "  kVK_ANSI_Quote                = 0x27"
		at: 16r29 put: (self value: 16r3b); "  kVK_ANSI_Semicolon            = 0x29"
		at: 16r2A put: (self value: 16r5c); "  kVK_ANSI_Backslash            = 0x2A"
		at: 16r2B put: (self value: 16r2c); "  kVK_ANSI_Comma                = 0x2B"
		at: 16r2C put: (self value: 16r2f); "  kVK_ANSI_Slash                = 0x2C"
		at: 16r2F put: (self value: 16r2e); "  kVK_ANSI_Period               = 0x2F"
		at: 16r32 put: (self value: 16r60); "  kVK_ANSI_Grave                = 0x32"
		at: 16r41 put: (self value: 16rffae); "  kVK_ANSI_KeypadDecimal        = 0x41"
		at: 16r43 put: (self value: 16rffaa); "  kVK_ANSI_KeypadMultiply       = 0x43"
		at: 16r45 put: (self value: 16rffab); "  kVK_ANSI_KeypadPlus           = 0x45"
		at: 16r47 put: (self value: 16r47); "  kVK_ANSI_KeypadClear          = 0x47" "Not mapped"
		at: 16r4B put: (self value: 16rffaf); "  kVK_ANSI_KeypadDivide         = 0x4B"
		at: 16r4C put: (self value: 16rff8d); "  kVK_ANSI_KeypadEnter          = 0x4C"
		at: 16r4E put: (self value: 16rffad); "  kVK_ANSI_KeypadMinus          = 0x4E"
		at: 16r51 put: (self value: 16rffbd); "  kVK_ANSI_KeypadEquals         = 0x51"
		at: 16r52 put: (self value: 16rffb0); "  kVK_ANSI_Keypad0              = 0x52"
		at: 16r53 put: (self value: 16rffb1); "  kVK_ANSI_Keypad1              = 0x53"
		at: 16r54 put: (self value: 16rffb2); "  kVK_ANSI_Keypad2              = 0x54"
		at: 16r55 put: (self value: 16rffb3); "  kVK_ANSI_Keypad3              = 0x55"
		at: 16r56 put: (self value: 16rffb4); "  kVK_ANSI_Keypad4              = 0x56"
		at: 16r57 put: (self value: 16rffb5); "  kVK_ANSI_Keypad5              = 0x57"
		at: 16r58 put: (self value: 16rffb6); "  kVK_ANSI_Keypad6              = 0x58"
		at: 16r59 put: (self value: 16rffb7); "  kVK_ANSI_Keypad7              = 0x59"
		at: 16r5B put: (self value: 16rffb8); "  kVK_ANSI_Keypad8              = 0x5B"
		at: 16r5C put: (self value: 16rffb9) "  kVK_ANSI_Keypad9              = 0x5C"
]

{ #category : #unix }
KeyboardKey class >> initializeUnixVirtualKeyTable [
	self flag: #pharoTodo. "Some values are missing, need to gather them from users who are able to."
	UnixVirtualKeyTable := Dictionary new.
	UnixVirtualKeyTable
		at: Character cr asciiValue put: (self value: 16rff0d); " kVK_Return       = 0x24"
		at: Character tab asciiValue put: (self value: 16rff09); "  kVK_Tab        = 0x30"
		at: Character space asciiValue put: (self value: 16rff80); "  kVK_Space    = 0x31"
		at: Character delete asciiValue put: (self value: 16rffff); "  kVK_Delete  = 0x33"
		at: Character escape asciiValue put: (self value: 16rff1b); "  kVK_Escape  = 0x35"
		at: 8 put: (self value: 16rff08); "  kVK_Command                           = 0x37"
		at: -1 put: (self value: 16rffe7); "  kVK_Command                          = 0x37"
		at: 255 put: (self value: 16rffe1); "  kVK_Shift                           = 0x38"
		at: -1 put: (self value: 16rffe5); "  kVK_CapsLock                         = 0x39"
		at: 247 put: (self value: 16rffe9); "  kVK_Option                          = 0x3A"
		at: 251 put: (self value: 16rffe3); "  kVK_Control                         = 0x3B"
		at: 254 put: (self value: 16rffe2); "  kVK_RightShift                      = 0x3C"
      at: 246 put: (self value: 16rffea); " kVK_RightOption                      = 0x3D"
      at: 250 put: (self value: 16rffe4); " kVK_RightControl                     = 0x3E"
		at: -1 put: (self value: 16r08f6); "  kVK_Function                         = 0x3F"
		at: -1 put: (self value: 16r48); "  kVK_VolumeUp                           = 0x48"  "Not mapped"
		at: -1 put: (self value: 16r49); "  kVK_VolumeDown                         = 0x49" "Not mapped"
		at: -1 put: (self value: 16r4A); "  kVK_Mute                               = 0x4A" "Not mapped"
		at: -1 put: (self value: 16rffbe); "  kVK_F1                               = 0x7A"
		at: -1 put: (self value: 16rffbf); "  kVK_F2                               = 0x78"
		at: -1 put: (self value: 16rffc0); "  kVK_F3                               = 0x63"
		at: -1 put: (self value: 16rffc1); "  kVK_F4                               = 0x76"
		at: -1 put: (self value: 16rffc2); "  kVK_F5                               = 0x60"
		at: -1 put: (self value: 16rffc3); "  kVK_F6                               = 0x61"
		at: -1 put: (self value: 16rffc4); "  kVK_F7                               = 0x62"
		at: -1 put: (self value: 16rffc5); "  kVK_F8                               = 0x64"
		at: -1 put: (self value: 16rffc6); "  kVK_F9                               = 0x65"
		at: -1 put: (self value: 16rffc8); "  kVK_F11                              = 0x67"
		at: -1 put: (self value: 16rffc7); "  kVK_F10                              = 0x6D"
		at: -1 put: (self value: 16rffc9); "  kVK_F12                              = 0x6F"
		"at: -1 put: (self value: 16r72);" "  kVK_Help                               = 0x72" "Not mapped"
		at: Character home asciiValue put: (self value: 16rff50); "  kVK_Home      = 0x73"
		at: Character pageUp asciiValue put: (self value: 16rff55); "  kVK_PageUp  = 0x74"
		at: Character delete asciiValue put: (self value: 16rffff); "  kVK_ForwardDelete   = 0x75"
		at: Character end asciiValue put: (self value: 16rff57); "  kVK_End                = 0x77"
		at: Character pageDown asciiValue put: (self value: 16rff56); "  kVK_PageDown      = 0x79"
		at: Character arrowLeft asciiValue put: (self value: 16rff96); "  kVK_LeftArrow    = 0x7B"
		at: Character arrowRight asciiValue put: (self value: 16rff98); "  kVK_RightArrow  = 0x7C"
		at: Character arrowDown asciiValue put: (self value: 16rff99); "  kVK_DownArrow    = 0x7D"
		at: Character arrowUp asciiValue put: (self value: 16rff97); "  kVK_UpArrow        = 0x7E"
		at: $a asciiValue put: (self value: 16r41); "kVK_ANSI_A                    = 0x00"
		at: $b asciiValue put: (self value: 16r42); "  kVK_ANSI_B                  = 0x0B"
		at: $c asciiValue put: (self value: 16r43); "  kVK_ANSI_C                  = 0x08"
		at: $d asciiValue put: (self value: 16r44); "  kVK_ANSI_D                  = 0x02"
		at: $e asciiValue put: (self value: 16r45); "  kVK_ANSI_E                  = 0x0E"
		at: $f asciiValue put: (self value: 16r46); "  kVK_ANSI_F                  = 0x03"
		at: $g asciiValue put: (self value: 16r47); "  kVK_ANSI_G                  = 0x05"
		at: $h asciiValue put: (self value: 16r48); "  kVK_ANSI_H                  = 0x04"
		at: $i asciiValue put: (self value: 16r49); "  kVK_ANSI_I                  = 0x22"
		at: $j asciiValue put: (self value: 16r4a); "  kVK_ANSI_J                  = 0x26"
		at: $k asciiValue put: (self value: 16r4b); "  kVK_ANSI_K                  = 0x28"
		at: $l asciiValue put: (self value: 16r4c); "  kVK_ANSI_L                  = 0x25"
		at: $m asciiValue put: (self value: 16r4d); "  kVK_ANSI_M                  = 0x2E"
		at: $n asciiValue put: (self value: 16r4e); "  kVK_ANSI_N                  = 0x2D"
		at: $o asciiValue put: (self value: 16r4f); "  kVK_ANSI_O                  = 0x1F"
		at: $p asciiValue put: (self value: 16r50); "  kVK_ANSI_P                  = 0x23"
		at: $q asciiValue put: (self value: 16r51); "  kVK_ANSI_Q                  = 0x0C"
		at: $r asciiValue put: (self value: 16r52); "  kVK_ANSI_R                  = 0x0F"
		at: $s asciiValue put: (self value: 16r53); "  kVK_ANSI_S                  = 0x01"
		at: $t asciiValue put: (self value: 16r54); "  kVK_ANSI_T                  = 0x11"
		at: $u asciiValue put: (self value: 16r55); "  kVK_ANSI_U                  = 0x20"
		at: $v asciiValue put: (self value: 16r56); "  kVK_ANSI_V                  = 0x09"
		at: $w asciiValue put: (self value: 16r57); "  kVK_ANSI_W                  = 0x0D"
		at: $x asciiValue put: (self value: 16r58); "  kVK_ANSI_X                  = 0x07"
		at: $y asciiValue put: (self value: 16r59); "  kVK_ANSI_Y                  = 0x10"
		at: $z asciiValue put: (self value: 16r5a). "  kVK_ANSI_Z                  = 0x06"
	
	"Map also uppercase letters.
	Old VM events use the ascii value of characters in linux to refer to keys.
	Work it around by making lowercase and uppercase letters both refer to the same key"
	($A to: $Z) do: [ :c |
		UnixVirtualKeyTable at: c asciiValue put: (UnixVirtualKeyTable at: c asLowercase asciiValue) ].
		
	UnixVirtualKeyTable
		at: $0 asciiValue put: (self value: 16r30); "  kVK_ANSI_0                  = 0x1D"
		at: $1 asciiValue put: (self value: 16r31); "  kVK_ANSI_1                  = 0x12"
		at: $2 asciiValue put: (self value: 16r32); "  kVK_ANSI_2                  = 0x13"
		at: $3 asciiValue put: (self value: 16r33); "  kVK_ANSI_3                  = 0x14"
		at: $4 asciiValue put: (self value: 16r34); "  kVK_ANSI_4                  = 0x15"
		at: $5 asciiValue put: (self value: 16r35); "  kVK_ANSI_5                  = 0x17"
		at: $6 asciiValue put: (self value: 16r36); "  kVK_ANSI_6                  = 0x16"
		at: $7 asciiValue put: (self value: 16r37); "  kVK_ANSI_7                  = 0x1A"
		at: $8 asciiValue put: (self value: 16r38); "  kVK_ANSI_8                  = 0x1C"
		at: $9 asciiValue put: (self value: 16r39); "  kVK_ANSI_9                  = 0x19"

		at: $- asciiValue put: (self value: 16r2d); "  kVK_ANSI_Minus              = 0x1B"
		at: $= asciiValue put: (self value: 16r3d); "  kVK_ANSI_Equal              = 0x18"
		at: $[ asciiValue put: (self value: 16r5b); "  kVK_ANSI_LeftBracket        = 0x21"
		at: $] asciiValue put: (self value: 16r5d); "  kVK_ANSI_RightBracket       = 0x1E"
		at: $' asciiValue put: (self value: 16r27); "  kVK_ANSI_Quote              = 0x27"
		at: $; asciiValue put: (self value: 16r3b); "  kVK_ANSI_Semicolon          = 0x29"
		at: $/ asciiValue put: (self value: 16r5c); "  kVK_ANSI_Backslash          = 0x2A"
		at: $, asciiValue put: (self value: 16r2c); "  kVK_ANSI_Comma              = 0x2B"
		at: $\ asciiValue put: (self value: 16r2f); "  kVK_ANSI_Slash              = 0x2C"
		at: $. asciiValue put: (self value: 16r2e); "  kVK_ANSI_Period             = 0x2F"
		at: $` asciiValue put: (self value: 16r60)"; ""  kVK_ANSI_Grave              = 0x32""
		at: 1 put: (self value: 16rffae); ""  kVK_ANSI_KeypadDecimal                = 0x41""
		at: 1 put: (self value: 16rffaa); ""  kVK_ANSI_KeypadMultiply               = 0x43""
		at: 1 put: (self value: 16rffab); ""  kVK_ANSI_KeypadPlus                   = 0x45""
		at: 1 put: (self value: 16r47); ""  kVK_ANSI_KeypadClear                    = 0x47"" ""Not mapped""
		at: 1 put: (self value: 16rffaf); ""  kVK_ANSI_KeypadDivide                 = 0x4B""
		at: 1 put: (self value: 16rff8d); ""  kVK_ANSI_KeypadEnter                  = 0x4C""
		at: 1 put: (self value: 16rffad); ""  kVK_ANSI_KeypadMinus                  = 0x4E""
		at: 1 put: (self value: 16rffbd); ""  kVK_ANSI_KeypadEquals                 = 0x51""
		at: 1 put: (self value: 16rffb0); ""  kVK_ANSI_Keypad0                      = 0x52""
		at: 1 put: (self value: 16rffb1); ""  kVK_ANSI_Keypad1                      = 0x53""
		at: 1 put: (self value: 16rffb2); ""  kVK_ANSI_Keypad2                      = 0x54""
		at: 1 put: (self value: 16rffb3); ""  kVK_ANSI_Keypad3                      = 0x55""
		at: 1 put: (self value: 16rffb4); ""  kVK_ANSI_Keypad4                      = 0x56""
		at: 1 put: (self value: 16rffb5); ""  kVK_ANSI_Keypad5                      = 0x57""
		at: 1 put: (self value: 16rffb6); ""  kVK_ANSI_Keypad6                      = 0x58""
		at: 1 put: (self value: 16rffb7); ""  kVK_ANSI_Keypad7                      = 0x59""
		at: 1 put: (self value: 16rffb8); ""  kVK_ANSI_Keypad8                      = 0x5B""
		at: 1 put: (self value: 16rffb9) ""  kVK_ANSI_Keypad9                       = 0x5C"""
]

{ #category : #windows }
KeyboardKey class >> initializeWindowsVirtualKeyTable [
	self flag: #pharoTodo. "Some values are missing, need to gather them from users who are able to."
	WindowsVirtualKeyTable := Dictionary new.
	WindowsVirtualKeyTable
		at: 16r0d put: (self value: 16rff0d); " kVK_Return                    = 0x24"
		at: 16r09 put: (self value: 16rff09); "  kVK_Tab                       = 0x30"
		at: 16r20 put: (self value: 16rff80); "  kVK_Space                     = 0x31"
		at: 16r2e put: (self value: 16rffff); "  kVK_Delete                    = 0x33"
		at: 16r1b put: (self value: 16rff1b); "  kVK_Escape                    = 0x35"
		at: 16r5B put: (self value: 16rff08); "  kVK_Command                   = 0x37"
		at: 16r5c put: (self value: 16rffe7); "  kVK_Command                   = 0x37"
		at: 16r10 put: (self value: 16rffe1); "  kVK_Shift                     = 0x38"
		at: 16r14 put: (self value: 16rffe5); "  kVK_CapsLock                  = 0x39"
		at: 16r12 put: (self value: 16rffe9); "  kVK_Option                    = 0x3A"
		at: 16r11 put: (self value: 16rffe3); "  kVK_Control                   = 0x3B"
		at: 16ra0 put: (self value: 16rffe2); "  kVK_RightShift                = 0x3C"
		at: 16ra5 put: (self value: 16rffea); "  kVK_RightOption               = 0x3D"
		at: 16ra3 put: (self value: 16rffe4); "  kVK_RightControl              = 0x3E"
		at: -1 put: (self value: 16r08f6); "  kVK_Function                  = 0x3F"
		at: 16raf put: (self value: 16r48); "  kVK_VolumeUp                  = 0x48"  "Not mapped"
		at: 16rae put: (self value: 16r49); "  kVK_VolumeDown                = 0x49" "Not mapped"
		at: 16rad put: (self value: 16r4A); "  kVK_Mute                      = 0x4A" "Not mapped"
		at: 16r70 put: (self value: 16rffbe); "  kVK_F1                        = 0x7A"
		at: 16r71 put: (self value: 16rffbf); "  kVK_F2                        = 0x78"
		at: 16r72 put: (self value: 16rffc0); "  kVK_F3                        = 0x63"
		at: 16r73 put: (self value: 16rffc1); "  kVK_F4                        = 0x76"
		at: 16r74 put: (self value: 16rffc2); "  kVK_F5                        = 0x60"
		at: 16r75 put: (self value: 16rffc3); "  kVK_F6                        = 0x61"
		at: 16r76 put: (self value: 16rffc4); "  kVK_F7                        = 0x62"
		at: 16r77 put: (self value: 16rffc5); "  kVK_F8                        = 0x64"
		at: 16r78 put: (self value: 16rffc6); "  kVK_F9                        = 0x65"
		at: 16r79 put: (self value: 16rffc8); "  kVK_F11                       = 0x67"
		at: 16r7a put: (self value: 16rffc7); "  kVK_F10                       = 0x6D"
		at: 16r7b put: (self value: 16rffc9); "  kVK_F12                       = 0x6F"
		"at: 16r2f put: (self value: 16r72);" "  kVK_Help                      = 0x72" "Not mapped"
		at: 16r24 put: (self value: 16rff50); "  kVK_Home                      = 0x73"
		at: 16r21 put: (self value: 16rff55); "  kVK_PageUp                    = 0x74"
		at: 16r2e put: (self value: 16rffff); "  kVK_ForwardDelete             = 0x75"
		at: 16r23 put: (self value: 16rff57); "  kVK_End                       = 0x77"
		at: 16r22 put: (self value: 16rff56); "  kVK_PageDown                  = 0x79"
		at: 16r1c put: (self value: 16rff96); "  kVK_LeftArrow                 = 0x7B"
		at: 16r1d put: (self value: 16rff98); "  kVK_RightArrow                = 0x7C"
		at: 16r1f put: (self value: 16rff99); "  kVK_DownArrow                 = 0x7D"
		at: 16r1e put: (self value: 16rff97); "  kVK_UpArrow                   = 0x7E"
		at: 16r41 put: (self value: 16r41); "kVK_ANSI_A                    = 0x00"
		at: 16r42 put: (self value: 16r42); "  kVK_ANSI_B                    = 0x0B"
		at: 16r43 put: (self value: 16r43); "  kVK_ANSI_C                    = 0x08"
		at: 16r44 put: (self value: 16r44); "  kVK_ANSI_D                    = 0x02"
		at: 16r45 put: (self value: 16r45); "  kVK_ANSI_E                    = 0x0E"
		at: 16r46 put: (self value: 16r46); "  kVK_ANSI_F                    = 0x03"
		at: 16r47 put: (self value: 16r47); "  kVK_ANSI_G                    = 0x05"
		at: 16r48 put: (self value: 16r48); "  kVK_ANSI_H                    = 0x04"
		at: 16r49 put: (self value: 16r49); "  kVK_ANSI_I                    = 0x22"
		at: 16r4a put: (self value: 16r4a); "  kVK_ANSI_J                    = 0x26"
		at: 16r4b put: (self value: 16r4b); "  kVK_ANSI_K                    = 0x28"
		at: 16r4c put: (self value: 16r4c); "  kVK_ANSI_L                    = 0x25"
		at: 16r4d put: (self value: 16r4d); "  kVK_ANSI_M                    = 0x2E"
		at: 16r4e put: (self value: 16r4e); "  kVK_ANSI_N                    = 0x2D"
		at: 16r4f put: (self value: 16r4f); "  kVK_ANSI_O                    = 0x1F"
		at: 16r50 put: (self value: 16r50); "  kVK_ANSI_P                    = 0x23"
		at: 16r51 put: (self value: 16r51); "  kVK_ANSI_Q                    = 0x0C"
		at: 16r52 put: (self value: 16r52); "  kVK_ANSI_R                    = 0x0F"
		at: 16r53 put: (self value: 16r53); "  kVK_ANSI_S                    = 0x01"
		at: 16r54 put: (self value: 16r54); "  kVK_ANSI_T                    = 0x11"
		at: 16r55 put: (self value: 16r55); "  kVK_ANSI_U                    = 0x20"
		at: 16r56 put: (self value: 16r56); "  kVK_ANSI_V                    = 0x09"
		at: 16r57 put: (self value: 16r57); "  kVK_ANSI_W                    = 0x0D"
		at: 16r58 put: (self value: 16r58); "  kVK_ANSI_X                    = 0x07"
		at: 16r59 put: (self value: 16r59); "  kVK_ANSI_Y                    = 0x10"
		at: 16r5a put: (self value: 16r5a); "  kVK_ANSI_Z                    = 0x06"
		
		at: $0 asciiValue put: (self value: 16r30); "  kVK_ANSI_0                    = 0x1D"
		at: $1 asciiValue put: (self value: 16r31); "  kVK_ANSI_1                    = 0x12"
		at: $2 asciiValue put: (self value: 16r32); "  kVK_ANSI_2                    = 0x13"
		at: $3 asciiValue put: (self value: 16r33); "  kVK_ANSI_3                    = 0x14"
		at: $4 asciiValue put: (self value: 16r34); "  kVK_ANSI_4                    = 0x15"
		at: $5 asciiValue put: (self value: 16r35); "  kVK_ANSI_5                    = 0x17"
		at: $6 asciiValue put: (self value: 16r36); "  kVK_ANSI_6                    = 0x16"
		at: $7 asciiValue put: (self value: 16r37); "  kVK_ANSI_7                    = 0x1A"
		at: $8 asciiValue put: (self value: 16r38); "  kVK_ANSI_8                    = 0x1C"
		at: $9 asciiValue put: (self value: 16r39); "  kVK_ANSI_9                    = 0x19"

		at: 16rbd put: (self value: 16r2d); "  kVK_ANSI_Minus                = 0x1B"
		at: $= asciiValue put: (self value: 16r3d); "  kVK_ANSI_Equal                = 0x18"
		at: 16rdb put: (self value: 16r5b); "  kVK_ANSI_LeftBracket          = 0x21"
		at: 16rdd put: (self value: 16r5d); "  kVK_ANSI_RightBracket         = 0x1E"
		at: 1 put: (self value: 16r27); "  kVK_ANSI_Quote                = 0x27"
		at: 16rba put: (self value: 16r3b); "  kVK_ANSI_Semicolon            = 0x29"
		at: 16rbf put: (self value: 16r5c); "  kVK_ANSI_Backslash            = 0x2A"
		at: 16rbc put: (self value: 16r2c); "  kVK_ANSI_Comma                = 0x2B"
		at: 16rdc put: (self value: 16r2f); "  kVK_ANSI_Slash                = 0x2C"
		at: 16rbe put: (self value: 16r2e); "  kVK_ANSI_Period               = 0x2F"
		at: 16rc0 put: (self value: 16r60); "  kVK_ANSI_Grave                = 0x32"
		at: 16r6e put: (self value: 16rffae); "  kVK_ANSI_KeypadDecimal        = 0x41"
		at: 16r6a put: (self value: 16rffaa); "  kVK_ANSI_KeypadMultiply       = 0x43"
		at: 16r6b put: (self value: 16rffab); "  kVK_ANSI_KeypadPlus           = 0x45"
		at: 16r0c put: (self value: 16r47); "  kVK_ANSI_KeypadClear          = 0x47" "Not mapped"
		at: 16r6f put: (self value: 16rffaf); "  kVK_ANSI_KeypadDivide         = 0x4B"
		at: 16r0d put: (self value: 16rff8d); "  kVK_ANSI_KeypadEnter          = 0x4C"
		at: 16r6d put: (self value: 16rffad); "  kVK_ANSI_KeypadMinus          = 0x4E"
		at: 1 put: (self value: 16rffbd); "  kVK_ANSI_KeypadEquals         = 0x51"
		at: 16r60 put: (self value: 16rffb0); "  kVK_ANSI_Keypad0              = 0x52"
		at: 16r61 put: (self value: 16rffb1); "  kVK_ANSI_Keypad1              = 0x53"
		at: 16r62 put: (self value: 16rffb2); "  kVK_ANSI_Keypad2              = 0x54"
		at: 16r63 put: (self value: 16rffb3); "  kVK_ANSI_Keypad3              = 0x55"
		at: 16r64 put: (self value: 16rffb4); "  kVK_ANSI_Keypad4              = 0x56"
		at: 16r65 put: (self value: 16rffb5); "  kVK_ANSI_Keypad5              = 0x57"
		at: 16r66 put: (self value: 16rffb6); "  kVK_ANSI_Keypad6              = 0x58"
		at: 16r67 put: (self value: 16rffb7); "  kVK_ANSI_Keypad7              = 0x59"
		at: 16r68 put: (self value: 16rffb8); "  kVK_ANSI_Keypad8              = 0x5B"
		at: 16r69 put: (self value: 16rffb9) "  kVK_ANSI_Keypad9              = 0x5C"
]

{ #category : #'instance creation' }
KeyboardKey class >> keyFromCharacterTable [

	KeyFromCharacterTable ifNil: [ self initializeKeyFromCharacterCompatibilityTable ].
	^ KeyFromCharacterTable
]

{ #category : #accessing }
KeyboardKey class >> keypadDown [

	^ self named: 'KP_DOWN'
]

{ #category : #accessing }
KeyboardKey class >> keypadEnter [

	^ self named: 'KP_ENTER'
]

{ #category : #accessing }
KeyboardKey class >> keypadLeft [

	^ self named: 'KP_LEFT'
]

{ #category : #accessing }
KeyboardKey class >> keypadRight [

	^ self named: 'KP_RIGHT'
]

{ #category : #accessing }
KeyboardKey class >> keypadUp [

	^ self named: 'KP_UP'
]

{ #category : #accessing }
KeyboardKey class >> left [

	^ self named: 'LEFT'
]

{ #category : #accessing }
KeyboardKey class >> lessThan [

	^ self named: 'LESS'
]

{ #category : #macos }
KeyboardKey class >> macOSVirtualKeyTable [
	MacosVirtualKeyTable ifNil: [ self initializeMacOSVirtualKeyTable. ].
	^MacosVirtualKeyTable
]

{ #category : #accessing }
KeyboardKey class >> minus [
	
	^ self named: 'MINUS'
]

{ #category : #'instance creation' }
KeyboardKey class >> named: aString [
	"Returns the instance of myself having aString as name.
	
	 (KeyboardKey named: 'SHIFT_L') >>> (KeyboardKey value: 65505)
	"
	
	^ KeyNameTable at: aString
]

{ #category : #'instance creation' }
KeyboardKey class >> named: aString ifNone: aBlock [
	"Returns the instance of myself having aString as name.
	
	 (KeyboardKey named: 'SHIFT_L') >>> (KeyboardKey value: 65505)
	"
	
	^ KeyNameTable at: aString ifAbsent: aBlock
]

{ #category : #accessing }
KeyboardKey class >> pageDown [

	^ self named: 'PAGE_DOWN'
]

{ #category : #accessing }
KeyboardKey class >> pageUp [
	
	^ self named: 'PAGE_UP'
]

{ #category : #accessing }
KeyboardKey class >> parenthesisLeft [
	
	^ self named: 'PARENLEFT'
]

{ #category : #accessing }
KeyboardKey class >> right [

	^ self named: 'RIGHT'
]

{ #category : #accessing }
KeyboardKey class >> singleQuote [

	^ self named: 'APOSTROPHE'
]

{ #category : #accessing }
KeyboardKey class >> space [

	^ self named: 'SPACE'
]

{ #category : #accessing }
KeyboardKey class >> tab [

	^ self named: 'TAB'
]

{ #category : #unix }
KeyboardKey class >> unixVirtualKeyTable [
	UnixVirtualKeyTable ifNil: [ self initializeUnixVirtualKeyTable. ].
	^UnixVirtualKeyTable
]

{ #category : #unknownKeys }
KeyboardKey class >> unknownKeyName [
	^#Unknown
]

{ #category : #accessing }
KeyboardKey class >> up [

	^ self named: 'UP'
]

{ #category : #'instance creation' }
KeyboardKey class >> value: aKeyValue [
	^KeyCodeTable at: aKeyValue
]

{ #category : #macos }
KeyboardKey class >> valueForMacOSXPlatform: aKeyValue [

	^self macOSVirtualKeyTable at: aKeyValue ifAbsent: [ (self basicNew withValue: aKeyValue andName: #Unknown) ] 
]

{ #category : #unix }
KeyboardKey class >> valueForUnixPlatform: aKeyValue [

	^self unixVirtualKeyTable at: aKeyValue ifAbsent: [ (self basicNew withValue: aKeyValue) ] 
]

{ #category : #windows }
KeyboardKey class >> valueForWindowsPlatform: aKeyCode [

	^self windowsVirtualKeyTable at: aKeyCode ifAbsent: [ (self basicNew withValue: aKeyCode andName: #Unknown) ] 
]

{ #category : #windows }
KeyboardKey class >> windowsVirtualKeyTable [

	WindowsVirtualKeyTable ifNil: [ self initializeWindowsVirtualKeyTable. ].
	^WindowsVirtualKeyTable
]

{ #category : #comparing }
KeyboardKey >> = other [

	^ self species = other species
		and: [ self value = other value ]
]

{ #category : #comparing }
KeyboardKey >> hash [

	^ self species hash bitXor: self value hash
]

{ #category : #testing }
KeyboardKey >> isArrowDown [

	^ {KeyboardKey down . KeyboardKey keypadDown} includes: self
]

{ #category : #testing }
KeyboardKey >> isArrowLeft [

	^ {KeyboardKey left . KeyboardKey keypadLeft} includes: self
]

{ #category : #testing }
KeyboardKey >> isArrowRight [

	^ {KeyboardKey right . KeyboardKey keypadRight} includes: self
]

{ #category : #testing }
KeyboardKey >> isArrowUp [

	^ {KeyboardKey up . KeyboardKey keypadUp} includes: self
]

{ #category : #testing }
KeyboardKey >> isUnkownKey [
	 ^self name == self class unknownKeyName
]

{ #category : #accessing }
KeyboardKey >> name [
	^name
]

{ #category : #printing }
KeyboardKey >> printOn: aStream [
	aStream
		nextPutAll: 'Key ';
		nextPutAll: name;
		nextPutAll: ' code: (';
		print: value;
		nextPutAll: ')'
]

{ #category : #accessing }
KeyboardKey >> value [
	^ value
]

{ #category : #initialization }
KeyboardKey >> withValue: aValue [
	self withValue: aValue andName: self class unknownKeyName
]

{ #category : #initialization }
KeyboardKey >> withValue: aValue andName: aName [
	value := aValue.
	name := aName
]
