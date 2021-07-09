"
I provide settings for Morphic appearance (theme, fonts, colors, ...) that can be found and changed in the Settings browser.
"
Class {
	#name : #PolymorphSystemSettings,
	#superclass : #Object,
	#classVars : [
		'DesktopColor',
		'DesktopGradientDirection',
		'DesktopGradientFillColor',
		'DesktopGradientOrigin',
		'DesktopImageFileName',
		'DesktopImageLayout',
		'DesktopLogo',
		'DesktopLogoFileName',
		'ShowDesktopLogo',
		'UseDesktopGradientFill'
	],
	#category : #'Settings-Polymorph'
}

{ #category : #settings }
PolymorphSystemSettings class >> appearanceSettingsOn: aBuilder [ 
	<systemsettings>
	(aBuilder group: #appearance)
		label: 'Appearance' ;  
		description: 'All settings concerned with the look''n feel of your system';
		with: [
			(aBuilder pickOne: #uiThemeClass)
				label: 'User interface theme';
				target: self;
				default: (Smalltalk at: #PharoLightTheme);
				order: 1;
				domainValues: self uiThemeClassChoices.
			self morphicSettingsOn: aBuilder.
			self desktopSettingsOn: aBuilder.
			self soundSettingsOn: aBuilder]
]

{ #category : #desktop }
PolymorphSystemSettings class >> desktopBackgroundChanged [
	| fill |
	
	self desktopImageFileName
		ifEmpty: [UIManager default currentWorld world backgroundMorph: nil]
		ifNotEmpty: [ [
				self currentWorld backgroundImage: (Form fromFileNamed: self desktopImageFileName) layout: self desktopImageLayout 
			] on: Error	do: []
		].
	
	self useDesktopGradientFill
		ifTrue: [self currentWorld fillStyle isGradientFill
				ifTrue: [fill := self currentWorld fillStyle]
				ifFalse: [fill := GradientFillStyle new].
			fill colorRamp: {0.0 -> self desktopColor darker. 1.0 -> self desktopGradientFillColor lighter}.
			fill origin: (self currentWorld perform: self desktopGradientOrigin).
			self desktopGradientDirection = #Vertical
				ifTrue: [fill radial: false.
					fill normal: self currentWorld width @ 0.
					fill direction: 0 @ self currentWorld height].
			self desktopGradientDirection = #Horizontal
				ifTrue: [fill radial: false.
					fill normal: 0 @ self currentWorld height.
					fill direction: self currentWorld width @ 0]. 
			self desktopGradientDirection = #Radial
				ifTrue: [
					fill radial: true.
					self desktopGradientOrigin = #center
						ifTrue: [fill direction: self currentWorld width // 2 @ 0.
							fill normal: 0 @ (self currentWorld height // 2)]
						ifFalse: [fill direction: self currentWorld width @ 0.
							fill normal: 0 @ self currentWorld height]].
			self currentWorld fillStyle: fill]
		ifFalse: [self currentWorld color: self desktopColor].
		
		self currentWorld changed
]

{ #category : #desktop }
PolymorphSystemSettings class >> desktopColor [
	^ DesktopColor ifNil: [DesktopColor := self currentWorld defaultWorldColor] 
]

{ #category : #desktop }
PolymorphSystemSettings class >> desktopColor: aColor [
	DesktopColor := aColor.
	self desktopBackgroundChanged
]

{ #category : #desktop }
PolymorphSystemSettings class >> desktopColorSettingsOn: aBuilder [ 
	(aBuilder setting: #desktopColor) label: 'Color';
		 description: 'This is the only color of your desktop if no gradient is used. If you make use of a gradient, then this color is the first one of the gradient';
		 default: PharoDarkTheme current desktopColor;
		with: [(aBuilder setting: #useDesktopGradientFill) label: 'Gradient';
				description: 'If true, then more settings will be available in order to define the desktop background color gradient';
				noOrdering;
				default: false;
				with: [(aBuilder setting: #desktopGradientFillColor) label: 'Other color';
						default: PharoDarkTheme current desktopColor;
						description: 'This is the second color of your gradient (the first one is given by the "Color" setting'.
					(aBuilder pickOne: #desktopGradientDirection) label: 'Direction';
						default: #Vertical;
						domainValues: {#Horizontal. #Vertical. #Radial}.
					(aBuilder pickOne: #desktopGradientOrigin) label: 'Origin';
						domainValues: {
							'Top left' translated -> #topLeft. 
							'Top' translated -> #topCenter. 
							'Top right' translated -> #topRight. 
							'Right' translated -> #rightCenter. 
							'Bottom right' translated -> #bottomRight. 
							'Bottom' translated -> #bottomCenter. 
							'Bottom left' translated -> #bottomLeft. 
							'Left' translated -> #leftCenter. 
							'Center' translated -> #center}]]
]

{ #category : #desktop }
PolymorphSystemSettings class >> desktopGradientDirection [
	"#Radial #Vertical or #Horizontal"
	^ DesktopGradientDirection ifNil: [DesktopGradientDirection := #Vertical]
]

{ #category : #desktop }
PolymorphSystemSettings class >> desktopGradientDirection: aSymbol [
	"#Radial #Vertical or #Horizontal"
	DesktopGradientDirection := aSymbol.
	self desktopBackgroundChanged

]

{ #category : #desktop }
PolymorphSystemSettings class >> desktopGradientFillColor [
	^ DesktopGradientFillColor ifNil: [DesktopGradientFillColor := self desktopColor]
]

{ #category : #desktop }
PolymorphSystemSettings class >> desktopGradientFillColor: aColor [ 
	DesktopGradientFillColor := aColor.
	self desktopBackgroundChanged
]

{ #category : #desktop }
PolymorphSystemSettings class >> desktopGradientOrigin [
	"#topLeft #topCenter #topRight #rightCenter #bottomRight #bottomCenter #bottomLeft #leftCenter #center"
	^ DesktopGradientOrigin ifNil: [DesktopGradientOrigin := #topLeft]
]

{ #category : #desktop }
PolymorphSystemSettings class >> desktopGradientOrigin: aSymbol [
	"#Radial #Vertical or #Horizontal"
	DesktopGradientOrigin := aSymbol.
	self desktopBackgroundChanged

]

{ #category : #desktop }
PolymorphSystemSettings class >> desktopImageFileName [
	^ DesktopImageFileName ifNil: [DesktopImageFileName := '']
]

{ #category : #desktop }
PolymorphSystemSettings class >> desktopImageFileName: aFileName [
	DesktopImageFileName := aFileName.
	self desktopBackgroundChanged
]

{ #category : #desktop }
PolymorphSystemSettings class >> desktopImageLayout [
	^ DesktopImageLayout ifNil: [DesktopImageLayout := #scaled]
]

{ #category : #desktop }
PolymorphSystemSettings class >> desktopImageLayout: aSymbol [
	DesktopImageLayout := aSymbol.
	self desktopBackgroundChanged
]

{ #category : #desktop }
PolymorphSystemSettings class >> desktopLogo [
	^ DesktopLogo ifNil: [self showDesktopLogo ifTrue: [DesktopLogo := self pharoLogo]]	
]

{ #category : #desktop }
PolymorphSystemSettings class >> desktopLogo: anImageMorph [
	DesktopLogo := anImageMorph
]

{ #category : #desktop }
PolymorphSystemSettings class >> desktopLogoChanged [
	self showDesktopLogo
		ifFalse: [self setDesktopLogoWith: nil.
			^ self].
	self desktopLogoFileName
		ifEmpty: [self setDesktopLogoWith: self pharoLogo]
		ifNotEmpty: [[self
				setDesktopLogoWith: (ImageMorph withForm: (Form fromFileNamed: self desktopLogoFileName))]
				on: Error
				do: [self setDesktopLogoWith: self pharoLogo]].

]

{ #category : #desktop }
PolymorphSystemSettings class >> desktopLogoFileName [
	^ DesktopLogoFileName ifNil: [DesktopLogoFileName := '']
]

{ #category : #desktop }
PolymorphSystemSettings class >> desktopLogoFileName: aFileName [
	DesktopLogoFileName = aFileName ifTrue: [^ self].
	DesktopLogoFileName := aFileName.
	self desktopLogoChanged 
]

{ #category : #desktop }
PolymorphSystemSettings class >> desktopSettingsOn: aBuilder [ 
	(aBuilder group: #desktopSettings)
		label: 'Desktop';
		target: self;
		noOrdering;
		with: [
			(aBuilder setting: #showDesktopLogo)
				label: 'Show logo' ;
				description: 'If true, then a logo if shown on the top left of the desktop' ;
				default: true;
				with: [
					(aBuilder setting: #desktopLogoFileName)
						type: #FilePathEncoder;
						default: '';
						description: 'The path of an image file for your own logo, the default pharo logo is used if empty.' ;
						label: 'Logo image file name'].
			self desktopColorSettingsOn: aBuilder.
			(aBuilder setting: #desktopImageFileName)
				type: #FilePathEncoder;
				default: '';
				description: 'The path of an image file which will be imported as a form and displayed as your desktop background';
				label: 'Desktop background image file name';
			with: [
				(aBuilder pickOne: #desktopImageLayout) label: 'Layout';
				 description: 'Size and placement of the background image';
				 target: self;
				 order: 0;
				 default: #scaled;
				 domainValues: #(#center #tiled #scaled #scaledAspect
		#topLeft #topCenter #topRight #rightCenter
		#bottomRight #bottomCenter #bottomLeft #leftCenter).
				]]
		
						
]

{ #category : #settings }
PolymorphSystemSettings class >> morphicHaloSettingsOn: aBuilder [ 
	(aBuilder group: #halo)
		label: 'Halo';
		parent: #morphic;
		description: 'All halo settings';
		noOrdering;
		with: [
			(aBuilder setting: #cycleHalosBothDirections)
				label: 'Cycle both directions';
				target: Morph;
				default: false;
				description: 'By default, halos only cycle from front-most submorph to parent (shift key down). This setting enables halos to also cycle from top-level morph down through the submorphs (no shift key)'.
			(aBuilder setting: #haloEnclosesFullBounds)
				label: 'Encloses fullbounds';
				default: false;
				target: HaloMorph;
				description: 'If true, halos will enclose the full bounds of the target Morph, rather than just the bounds'.
			(aBuilder setting: #showBoundsInHalo)
				label: 'Exhibits bounds' ;
				target: HaloMorph;
				default: false;
				description: 'If true, halos will include a fine rectangle around the bounds of the target morph.'
		]
]

{ #category : #morphic }
PolymorphSystemSettings class >> morphicMenuSettingsOn: aBuilder [ 
	(aBuilder group: #menu)
		label: 'Menus';
		parent: #morphic;
		description: 'All menu settings' ;
		target: UITheme;
		targetSelector: #currentSettings;
		noOrdering;
		with: [
			(aBuilder setting: #preferGradientFill)
				label: 'Gradient filling' ;
				default: false;
				description: 'If true, then menus will have a gradient look' .
			(aBuilder setting: #flatMenu)
				label: 'Flat appearance' ;
				default: true;
				description: 'If true, then menu will without 3D like borders.' .
			(aBuilder setting: #autoMenuColor)
				label: 'Computed color' ;
				default: false;
				description: 'If true, then the menu color will be computed from world dressing.' .
			(aBuilder setting: #menuColor)
				label: 'Menu color';
				default: (Color r: 0.823069403714565 g: 0.823069403714565 b: 0.823069403714565 alpha: 1.0);
				description: 'The menu color to use if it is not computed automatically (see the ''Computed color'' setting)' .
			(aBuilder setting: #menuSelectionColor)
				label: 'Menu selection color' ;
				default: (Color r: 0.38025415444770283 g: 0.6383186705767351 b: 0.8817204301075269 alpha: 1.0);
				description: 'The background color of a selected menu item' .
			(aBuilder setting: #menuSelectionTextColor)
				description: 'The text color of a selected menu item' ;
				default: Color black;
				label: 'Menu selection text color' .
		]
]

{ #category : #morphic }
PolymorphSystemSettings class >> morphicSettingsOn: aBuilder [ 
	(aBuilder group: #morphic)
		label: 'Morphic';
		description: 'All morphic settings';
		noOrdering;
		with: [
			self morphicWindowsSettingsOn: aBuilder.
			self morphicMenuSettingsOn: aBuilder.
			self morphicHaloSettingsOn: aBuilder.
			(aBuilder setting: #keyboardFocusOnMouseDown)
				label: 'Keyboard focus on mouse down';
				default: true;
				target: ModelMorphic;
				description: 'When enabled the mouse button must be clicked within a morph for it to take the keyboard focus.' .
			(aBuilder setting: #mouseOverForKeyboardFocus)
				label: 'Lose keyboard focus when mouse leave';
				target: ModelMorphic;
				default: false;
				description: 'When true, the mouse must be over a text or list pane in morphic for keystrokes to be felt, and when the mouse is out over the desktop, the so-called desktop-command-keys, such as cmd-b and cmd-R, are honored.  When false, list panes and text panes in morphic remain sensitive to keystrokes even after the mouse is no longer over the pane.' .
			(aBuilder setting: #balloonHelpEnabled)
				label: 'Balloon Tooltips'; 
				description: 'If true, tooltips are shown when leaving the cursor on top of a graphic element';
				default: true;
				target: UITheme;
				targetSelector: #currentSettings.
			(aBuilder setting: #editableStringMorph)
				label: 'String morphs are editable';
				target: StringMorph;
				default: false;
				description: 'If true, editing on StringMorph is possible if the shift key is pressed while selecting the morphs.' .
			(aBuilder setting: #defaultYellowButtonMenuEnabled)
				label: 'Show default action click menu';
				target: Morph;
				default: false;
				description: 'If true, populate an action click menu (default context menu).'.
			(aBuilder setting: #easySelectingWorld)
				label: 'Easy selection';
				default: false;
				target: WorldState;
				description: 'If true, select multiple Morphs in the world by dragging a selection box around them.']
]

{ #category : #morphic }
PolymorphSystemSettings class >> morphicWindowsSettingsOn: aBuilder [ 
	(aBuilder group: #windows)
		label: 'Windows';
		description: 'All windows settings';
		noOrdering;
		with: [
			(aBuilder setting: #preferRoundCorner)
				target: UITheme;
				targetSelector: #currentSettings;
				default: false;
				label: 'Rounded corners';
				description: 'If true, then windows, menu and other popups will have their corners rounded.'.
			(aBuilder range: #fullscreenMargin) 
						target: SystemWindow;
						default: 0;
						label: 'Fullscreen margin';
						description: 'Specify the amount of space that is let around a windows when it''s opened fullscreen';
						range: (-5 to: 100).
			(aBuilder setting: #fadedBackgroundWindows)
				target: UITheme;
				targetSelector: #currentSettings;
				default: false;
				label: 'Fade background windows';
				description: 'If true then, background windows appear more "washed out" to distinguish from the active window'.
			(aBuilder setting: #fastDragging)
				target: UITheme;
				targetSelector: #currentSettings;
				label: 'Fast dragging';
				default: false;
				description: 'If true, window drag will be done by dragging an outline of the window instead of the whole window. It is very convenient on a slow machine' .
			(aBuilder range: #textEntryFieldMinimumWidth)
				label: 'Text entry dialog width';
				default: 450;
				target: TextEntryDialogWindow;
				selector: #minimumWidth;
				range: (100 to: 800);
				description: 'Set the default text field width of the text entry dialog window' ]
			
			
			

]

{ #category : #desktop }
PolymorphSystemSettings class >> pharoLogo [
	^ ImageMorph withForm: self pharoLogoForm
]

{ #category : #desktop }
PolymorphSystemSettings class >> pharoLogoContents [
	^ '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
FksWd0bJR8VF1UdNRXtFl0VLl1gsWbPkRoxajCCmPRYfGxV7JHZyqffS3UuH4+ziCuPuLjNc
lrPs2nK15anLz66QX8FZcSoeGx8d3xD/iRPCqeVMrvRfuXflBNeTu4f7kufGK+eN8V34ZfyR
BJeEsoTRRJfEXYljSa5JFUnjAk9BteB1sl/ygeSplJCUoykzqdGpzWmEtPi000IlYYqwK10z
PSe9L8M0ozBDuspp1e5VE6JA0ZFMKHNZZruYjv5M9UiMJJslg1kLs2qy3mdHZZ/KUcwR5vTk
muRuyx3J88n7fjVmNXd1Z752/ob8wTXuaw6thdauXNu5Tnddwbrh9b7rj20gbUjZ8MtGy41l
G99uit7UUaBRsL5gaLPv5sZCuUJR4b0tzlsObMVsFWzt3WazrWrblyJe0fViy+KK4k8l3JLr
31l9V/ndzPaE7b2l9qX7d+B2CHfc3em681iZYlle2dCu4F2t5czyovK3u1fsvlZhW3FgD2mP
ZI+0MqiyvUqvakfVp+qk6oEaj5rmvep7t+2d2sfb17/fbX/TAY0DxQc+HhQcvH/I91BrrUFt
xWHc4azDz+ui6rq/Z39ff0TtSPGRz0eFR6XHwo911TvU1zeoN5Q2wo2SxrHjccdv/eD1Q3sT
q+lQM6O5+AQ4ITnx4sf4H++eDDzZeYp9qukn/Z/2ttBailqh1tzWibakNml7THvf6YDTnR3O
HS0/m/989Iz2mZqzymdLz5HOFZybOZ93fvJCxoXxi4kXhzpXdD66tOTSna6wrt7LgZevXvG5
cqnbvfv8VZerZ645XTt9nX297Yb9jdYeu56WX+x+aem172296XCz/ZbjrY6+BX3n+l37L972
un3ljv+dGwOLBvruLr57/17cPel93v3RB6kPXj/Mejj9aP1j7OOiJwpPKp6qP6391fjXZqm9
9Oyg12DPs4hnj4a4Qy//lfmvT8MFz6nPK0a0RupHrUfPjPmM3Xqx9MXwy4yX0+OFvyn+tveV
0auffnf7vWdiycTwa9HrmT9K3qi+OfrW9m3nZOjk03dp76anit6rvj/2gf2h+2P0x5Hp7E/4
T5WfjT93fAn88ngmbWbm3/eE8/syOll+AAAACXBIWXMAAAsTAAALEwEAmpwYAABAAElEQVR4
AexdB4AU1fl/U3f3KnAcB4gKSL1eUCOKorGiJjEKJiZqjAU4ioLJX03++XuaajQi7SjGaKIx
ComJGk2MMTY0Frh+R5EOSq9Xtkz7/77Z22P3bu92d2aOkuyDvZl58973yrz3ve997TGWDMke
SPZAsgeSPZDsgWQPJHsg2QPJHkj2QLIHkj2Q7IFkD/wX9oBhGPx/arP/Yxv2n/rBku1K9kCy
ByJ7AAiaQ0x6ZOx/zlMSSf/nfMtkS5I98F/ZAxzHGWg4cLWJrP8r+yDZ6OPVAzTIkgPtePV2
spz/oB4gdgd+ff6DmtTRFNomJIOjPWBw5835t7tlZJqbU41UprNUXuKzNMHoI2pGCscbWZoh
pXJMdzFD78cxPl3n9BSeEzMZ01MEQRb8qv+O+vLCzY5WKwks2QP/4T0AJN0XTTzcTln/x7RW
/I9pyUnSkPzFDUO8XOZ2mecY5zq2BoocOEv4jwHEsOTT5gw1Dv54JgBf63hGesPQRZ7l4CGJ
pE+Sb5qsRu/2wOQVK4Tq3SWiSwhIPKdJsuAS/N6A4PL4TXasT/UYblFUfa2qriqC4h+wSxm6
janvVFysdqqZD8+UR+sUf0o/JpG0w5/PYAGXKKQwXdeCeLgDfnzjRjd0TtOE0zqyJW+SPfAf
1gOFC2uHYUdZIjDpPNAnYzfvM07LkALZgihLmDQiSBfenSIDN8kmleORqAM4NSVN0kHHKHog
Rz08UD1UurTpc0NRN6iC8G+OqWtAAK03jLfdSBzfZDtF+vUYqXeKVPhkr2bBwroClyzX6Xrn
RT7OmoPi1gx1Wu30wmVx5kgmS/bASdsD+YvrTxeYNpbnxQsEURyva9rZQMQZPA98TDtJg3aQ
tKeke9pZxhkwT0zkhZ0ph3uabwbjvOmi0NisqO/qmv6BprO6htkFm+KEeNImS1LSTn8ajqVx
PLrVKpKmoabxHqerlYSX7IHj1QOn/ezjrKyMtLt43rhDFMThjJPMnaWuHiNcdF2xVx0gdxOl
E25vJ5whdfe0KPo4oO1xkiTeKwN5Fy+u3wNe9e9VTZjfeHfednuFnpjcSSTtcL+LzEihYWMr
iFwSSdvqwGTm490D+b+qP110s1sEUfo6xCrFJHqhaWB5R2mrAYa5KBDXgxf4HFDac0XBmFu2
fG2Tqqh/M1T9mbq7ixpsFWEhMxaLdLBkmhPNmkTSifZYjPSgg9NsIWkMbI7DcE+GZA+c5D2Q
V9EocwP0MS5eeJhx/FeBmJmuBanlRDgXvdpMVMQw2lnUGsuVBDHXkLh7i5c2rmJK4EeCrH2y
Zuq4tt6sA5AzCTP747fPSjmm9NRKxmSe6D3AGUZ/A0JDywED3dCVQ5bzJzMme+A49EBBZc1t
7kFCvYsXqzFiv2qAvRdC0Meh+C5FdPCnwakO/euSCBE6ELaBhURg7AJBcr3NcenrSxbX3B8t
rRNxQNAy4GTht8+qamCvU9KlS9ZeweuBXjDZFJmma60Gx6n4Kq0qx1pETj3KfOxwzZySw050
sBUYhsBybDI7sFWzUnIyT7IHerkHKir4ouzrvyYI/E95ThhzYlgZx9pI6qzYueIf38I4faOh
qvsMnkthBqenynymz5CxI9WywL4mHdc+pnASqUlYCeQJQIjR9CGC6P45NEXu1nX9R3sF3/Nf
OERZowzaEaeinpYo6FBLex1JM874KxNJncb5IEDjOAiVYxIvwFaPMzTOp5ctbjiE+081jv3d
61X+vGFu8efOlx4dIgbMEPDkor+MKxaDTtAPxJU0mSjZA8epB3KX1JS4efcfwWgeBvVSTjeO
CQGPSxWIyQ1BoBnar6qqNKqc/rCvSXp5Y9ZohT3YLgwCHvDuWjt088HA/orGRu++pmzui7T0
Pikp8sVgJv5UFOWR5gLTzpNpX2wGioLw5CCW9ot+S2q+0zC9+K922gUEDbYnqsxxtueyuUuw
U5me8hYuqP0SVB//HVKz6Smto+/wQUktx/xkhDAFcauuqB8D+a2oemvty2zlFBv8iJ5rWrp0
/avMUK7pOVX3b3ksNgEt8LW68qJXuk+VfJPsgePTA6MXVg32SO55oLKmmLSnLQIkjjqbc5cI
X41oZJqnrRrPreV0vVHT9FpOYLvhqaPVrysNa2eWbusOIpAkaVdnA0l+0TlN/sL6cbLAXweh
4uVINy6SqAJKRB2APN5WFO3u+lmF9Z3zx3oGzAFIE0DZjuzoexVJl1TW/FgQ3P97ordFZqfS
SgzdTEUL+NCJP+b9amVvsEXKlq+rAc+rKNaH7O499En1gOIfXzez6OPu0iTjkz3Q+z1gcPlL
G65z8fIL4DeTkUnvFgmiCmO/VVEC+3he/41X0F9sWdu2Y+e88V4rBWOOE24rA6Jc3VP+oiX1
U2DhuFTTlb6RbaQdLakO+u6t7rduPpsSH2GHcgejPDJNd0wY2atIuqyyvho6MMWRK1VPXXY8
3qHzUQwnCNB511Yc8eydufW2i8mc1JEA3tZRkAGWefC8IKlKwFtcO7O40ZEKJYEkeyDBHhj+
izcz+/Q5/SWI2S4J7YLNnSngkCUtEFCCELtPzguQLWnqUd0wZmgB9mb/w/sPRDH37h5AD2+A
MIlY2o769iiIL1u2OlPT3b8WBekGXeukv02UPS/Waa1tXwVRt7WH4ojPPaK9vEBP6RJ951xv
dyp59CPr0lMz9S/wkYk3c1IGrNzwf6Qf1VTtttoZBRiU9sLw+avPyJQ920icYTXwosvnC/hG
Ncwo2GEVRjJfsges9kDR4poLeFH+K29wmaRnTII5zJMjGtNfNhTfKo6X7gHSy42kOi2URuxI
ULm6ojxYM7PwdQsQYmYB0iTB3dmo7/s9JiaqG3zs4sXV33LLnv8NaNqY8PbRAmUKHQ39xqrp
BSs6w0I5xFoZhd9GlOXv/N7uc6+p4Hnc3oH4uKR+ctIGkw2j6xmSKP6xZGnja3YrmiZK5wsC
lHvsBF3VxYCasMK7nSKTeZM9QD1QVFn3f5Kc+h74v5kcHITBjYwCwvnbvrZDo5mqK6LoXg6q
zhaCNhGeAf8bTP1a1dSxZ/cWgqb2AGGaO2Qg0Z4nZdAfNau++aw3/j2+rggi0at4UeqQjJqc
ALB7BMH1Ykll4wsEOxQAmwzPiGJf2xsImsrpNSSNFo00eVlUykkeSFoNMeyksmXr1pGgxHJ1
ee4KfDTL2WkAw8/XwZojh1ssA0lmTPZAoj1Q8bZYurRhhSRID+lqgEjnLxS/7xtV5XkyBHX9
3Cl9N0LIdjuxOuwEjhegp8w9f4DpOTXTCl+2AyuBvDuRNiOu9OnpmVzelEDdtLy/K17vOdDc
e4VDB4SCBn4Mz3M3Fi9t+jDj8Q/7Gc3NJCAcDuS8Gj87Kl2hIqJeew1Jg9c0HitQr7FTorbG
RiS5CoVEeXSq5Nk+dn71SCugBIMfH75NsgIDxjBbWFcXjFZAJfMkeyB2DxCCHpjzb9Brk4nA
AFLaFfBqpRCaCcWVDZug9rYAfNo0WwZaqAUvyG1QmZtVPX3st7aXF/bII45d6YRS7Efq8bFy
tFPEHcRR7ezi6prpY7+q6MoTkBN1ZCeqGsyP8/LS+65bc4TlATn3uuyo15A0NhuXd7TslLkB
FWzogsflem/Ego/iW33b25b3eGM/uFocbEdIyvHw5mWwd06Z7kpW9JTugbyKt9PGDR4MJGOM
g+onCb6mwfDsAsnNvyHy3O8FnhtuGzkDLkjzrYFD3tG1MwoXHe8OAxIl1mEftC01Rtk037ss
HnXlhXN0LXBjOEVNhJhf1bPvfP2LF0csbcyNAdf2695B0pMnw7JEL7ZduxMCgEQlbGCmmF4z
8WnTN21cteBcOhz1myagcaWPloioeew93ov2LhmX7AEne+CsxZ+c7hk4cCuQ8CioL/gDft8N
wD27NF7aBCegRfBrTkjbVpFgbygQOC5as2fFWXX3FRHb4USFj1BwXozCh+J9Bx86PC0JCwOq
cpHOCRAKhpgDwBOakt2HE2qL51X3Kq7rFSQ99uL7z4YA7dgeIbzFp8A9UcMwLx122DfgF/FW
V+SMfPDsbLWZJMj63gM0oJIh2QO91gODK1an9BHTPwVJkAXL3M8DfjVPEeAgV+Behp00kLNd
9ioQGeQr/oA6vnpq3ixWUWEXoK2+ADW9CQCGdAcEi5Eb7zJ64ivXzyx8b3Zxxs/82OqGBygf
iGJqyvv5C+rPCo938r5XkLTEYH7poC6lkw2OGxbxngT+7sJFVV+OJw/4VheCVRJP0m7TYEu1
qbHi4g6+WLcJky+SPWCxB8p+sTpz0KD0Wuic5WDbtsqv7h4jauoBDy88S7w2u8HUp+b5A/6A
r7hhVkGPhiR2ywrlB5KFe+CYQWtHxtESno3IbdFeUBzy9cXvxtvOlR43NO1CEoCi/zqSw7FU
mssl1hY8tnpMR6SDN84jaegc4gy/CeRt6lQPOMeKiZJ7IZTdY1PIunGlnfaaH93QGuzASOZN
9kCsHjD6pPwT+7URqqH8pao8d0LjjItbIIRZAUyUZuoCxwLQw3vwngGG+7Rq14sDGmeX1vaQ
1OlXhID7xwC6Ee8v6ZwG+QgHjsbvs87v6JkQNC5ww8q9yHEDWppmF71vGIGrsNMOS46e07VU
OT3tH2xFDHW/sFzx3jqOpPNWNsFlqzTCCVdu6BhQsxLUXqL8zHiox/QixU50BbQtxqoBscvH
De9g8KT6wPEWWRtZD/TRVT1pCm69B5M5Y/RA8dK1r2K+jMPcfLdmWsF1lDx/fvV4CKwvi5E1
5msSPOqcUcXxrecfb/YG8AQZkBwGQj0dP1c3lV2P+AK870xwEavDBxhdthFIW4h31DfP4dcR
qqYV/R3s+lupzRHB0E4vObCuLhFZVkT+bh7EbuItR6tbBBfryw104ixIcIY3wA/G83Da3aWe
HLm849hAaCeOFCRpCFDcIFDvHix9luseLaOJqEWxEu+65TlxonyhAH1KO57BYMnFFCNQFa0O
ybhkD9jtgdLFdXNAz1yD8fxh1fS8iQSvDHxUQxb+Qf6VbQUA1gz2r+ppeXGxBm2V1U1mIFlq
xA4gVkLEh/C8MzwpvUc8IepB+G0Pe0esjs1hz+Yt0l6ImzOR79nO7+i5elru74oqG86C57z/
C2nAIA9Y8UbuEd+Ax5GkPFo+K3FdkJ8VIOF5PLL3LKbJln1XdMAis1Fd/XNNeeFDHXHRbrC/
GrFwoyzyB9M8YtpN0Mh8FGPGZZc/3FEUOl4S5eFkLls7o3hVR3zYjS5pl8NtalhM4rcafAZo
mq8m8ZzJHMke6LkHiiurrxYkz+Mwxjhc9VYjIR9WUFnXVxfEVbyhp9oha4hNhymyb9+GQ9f0
XIvj8xZItR7IEu6CDdop/AXP4c17D3ETWP71fXKG5pzJGZK72estTfd4fhVeO+T9Np53dIeg
Q2lr+zc9XHJw7FCBl27pcCIHDS1BkKcXL6rfUjOz4NFQWjtXe5glWskucZLpfyrauwTiBPKr
oXOxKUt8hI2zR/rXzTz3AFbyhW1HD2aDub+MmPtOBaI0eE6MOggnr1ghwIjlHDvWWBgMYH7p
Wxvu+dIep+qchJPsAeoBHHGVxgnupyDc8uPfhJCbXpkXn8bkH0jUn60gCPDaqJ9n1VudrbK7
yYz5RFT0B/h9G+0bRskmVlSI2VdOn/HwM6+8mDN0UC3U6V4ZNiRrxa9fee/+M6d878+Zl02F
y1JDwu8OJCenTO9Svh4DPONVTyu4Fbbzb5E2Syjomh+yLOnHTml8HIMcKsH+9atAObYDqQFp
XCBhX67r77uguXpGwTQ4TbqPHCg5EUhnlBOlS6LB2rlzCA4lloZEexd/HEf60a/Fnz6ZMtkD
8fWANED7p8hxOS1+7z2hw1fJRwdQM468sifcN/nQiv+uhtkFpOJ2UgUg2b34EaviWiDey+o+
3vcyL8sPb9+931Uy6kzmC6is+Kwz2P4jLay1zXdBZp/0j+o371iI9B8h33uJNCbFS762uSPH
ND5od6G5JIGjhcJ2cBZJ08GU8Dpld3GmxoIy9TbMKFtrtYU1M/J/qWkaPpITSwZqoWmlEIh0
6a8DLKUfaks2/JYDpO2M+dmfLANIZkz2QJQeIF/Joug6V9G0FevvLl1KSUoWN3xTFOSH7LID
yQIP8+v+6hlFT0Up+mSKWvTzZ15+cObkKyedPnAA27m+mk0p7sumn7WDXZfnYelH1rP8nBR2
4xUXC9/48VNT5Ytu7SxYjNmWD+fktpyexl0drsSAhYHxopBTvKTxJzEBxEjgDKnZXkhJll6I
wx05OGmJUWyM19j+G7oRe7sRA8y+zzKm5oxtvRbsij4xksbx2hDys6//UgOr+DA8cZrELsCC
You3AlZK215Ns6ayBN8LI/p5Uvrxmebg0qRWTvSrgY8Hbm+N11F5eHtO+D1kDEMfeseVmj1A
9GvNvJqeExCbVWPjrBEBTAKbe/MT3rqEKzAUVq+uvYMkF+/HiZ6i0liRF9fkGv3IqnSwDJ/F
RAroqno/FXw2rAwNQXi+g3+acG2CGUBpgvbR1wX6c/Msgjhu2TKuKh+JYXPu/GtOY2/fOZCl
767DqYOwhP8y6K3B+9llbe+z+y84l9Wv+hnbrg1iu1Kzfw7bcFOdFoiW8CP9aG6F7smzZwiR
k5c92o40v/ytMR8WL2laLPH8DNp5U6CdisALP4R157JNM87ZYUZa+OMokjZ4Ix8ksIVqdM5C
c1F/uXNsos87553uza6sfwMddWOo4xKFEUrPwwWpZGhfwnMEkjYEcQqdvWbLSovj9rhFuTVU
VqzrkMc/9GSJ6d8URP06gxPyBZ7PMATJ/JY868NUWdHKDuQd0hbXr4aJ73NVM/JfjQXzRL7H
MWsTeIm/UtC587QlDadzA/qnkd6lW8zgdW+LH8eIamVLGtv0yrrdQNRN8K64ptkn/n3TvSel
z22OVUAqU2HdK1rxwrrJOLTzOvRHse4z+sDzBAThki6kGd6SyvrPdY57Ex5tn8fRTuuifjcs
dJ6ljc8Clcp+Tf9W/awiOO0yeJVvega7vqhZEokEFb3vsF8o3jhlZFwLRiKwnU57pqznvV70
T23AvjbRqD2bKWMvZ0xBtfudxthRhRlp5zCtehUb1a8/+8OVLvaulJ8y4VXjTkx3IuxoG34U
v634bcZvL370TJok+AyRREPhEuVhqBnMwLtjAQg7Q0j7J1uxItcq0eQoksZxJ7YEaKGWkfcM
XvW/GXq2c9U57WmBk260u70DZY/hzUWz0b+UtjZWA1loKZqyeeMsUEizu4dChyikZPqv4Zh8
K9boyzFAiJ6B2h8UFcnnhx5+yhBROlxfURSHQ81+Clyw7oL2yCJB8D+xxqGTkLuvaew3hUtq
B/CGcBXP8zegEROxwqXh9Asc8qyROYQJAEcKo5loBpxOUaBYnomgivgJBtQVM1M0VrqsaTfy
vg/K8DVFEN9unJq33Uxs80/p4sYRqMtpGm94OJXP4Hg9A58/FYt9Bnq6L8eEvqhVOhaSTFQw
E/6X01G/FOjUpwE991ONpgrQaw8lUo3ixY3FILtmY0s2GfnSCD0YPEYc/QNFRnPC/M8Jpwsc
/yVoFP2o7Ml12w2f/7aqWUX/Ci9r7IKaEYLHcw0ouer68rzn6V1u/6aLsZhfYkfATXBovAZU
9faNs8eQbvJJHTAvOQhK/+Fd7VY1MdPFtmJ46NVMOLOQOtesO8dlMXHsFGJnMsN7lE0cNHiN
KpiGLduQYA9mWVu8jaybXrS3tLJuKpQWloVwAl0xbkYW7sudhDFhiVhyFEnDeX4+qZLZDRBI
HATtsMsuHMqv7pE+4HNUGt82gzlNhoUDGf1E7Wj4KMmwM/BNM1pV/6DbrTyKLVzW9F0Qk4sE
3u0OHe9D6wIhLgrBa6cWIsExq099kCCIP+V04b78yvoJDeUFGC/HP5z2s4+zBvRJmQdK7Gb4
5SW5A3BssB5Gp3ETaltHAiQji7iIHYtuDET0ZPBdJ4sABP7fPwHnHrtHj3Ei/wQcvF8tYvED
AdteMi545kHWUz3MYAreCIEGA13J6k404jdsGlrxtrtPTs5voG/7Tfq2IVjHbkLfF2/M/8f6
gNOMM1TW1UeOSxJfAmoXVE25n2pGHhrdAv+GbnOXS2QBvtnsuhkFlpBNsJes/zWRbtfsaYgK
/cjqMKv9R2rAaYGrf5PC60skFvAxwwd862sFMsZcIRN48jp5eB8o6beZfmgXk3U/83nbPurz
0nXvIK+l0Np89A9pfbJ/hsOoqR5mABHBCTxbjgfS0U44OIqk8QGLEq5BlAygDndn7Gp2ZCsF
Hl5L6bLGL/BRBkcpKqEofNoI/e8UiRXQh2bmZE0IVEdiE/Ew7vWOiLAbCH5uFpeLD6OAobQi
hxB0WJK4b01JPsdlyLy0unhB9Yya2SVPxp3ZZsKxjzWd6UkzHgUC+wowjYsQLc0RpwLUy0xQ
oDAvNUS5oXRpYzX666fV0/MtCWOxawpous9y9YDWB8STuXRxw7WYvfQdcqx8W3iYY762SA2o
gvnVX4XLXDj7UldCr/8fVA/Zwy+E6Sz5Io2nWt2kAbXASft4obnXBIX4ZmT9RxaDRHEQbqJn
+hHZS3Kf0C+4cgbXL+IJ0zNdd+K3BT+iFGlQ+Nt+eLObX18311AVHGAgMtfXbweixn7tyBHG
pWMjpLiZMOJixg58wbQ17zPtUDOyWQ+kXVa8qO4FQZZnhBsJQdNsYGFl7QN15UU/TxS6Y0g6
d1FNHhBORqIV6Jye1HpUVW1w6jBKE77GduCz20bSgBUxyjnSj8Y2yVbQdK1O8laFwyh7bHV/
I83zDNiyV8OXbfgrW/eE6LHCS5InbTmU7bdC2f5NWwBjZB769BZ3pretHFTzr2jWQS0pRg57
r8Oo7BL03R9Llqx9V/MHptbdU0SWZvEHDnzgiC8df9bgEOFiIunSJXVT4Qh/qZ3vC4zlX39f
6RfhtZNcrnvBdtEUVf0FxY+ZVz0UOOwm89uHJ0zwnuNEpqj+p2pnjAM5ai+gLkT50pAg5Es/
6m0ZP+LZEXKld8ROOQjqnRCw5WCUDeaPCB6MPJmJU77DWvxu1vL2G0xMAaryyMyTV8Rafv8s
85SewzKvvIOletJOM1ZNd6Ncy6u0wvl+IhgiWRxSO8xg6AqTRXf5iAWfPU52HaH4eK6OIWmR
eIw2TaODFeYZeIHvx1P5eNOA/RSIZPHHmzMyHbaQHZ1uvpHkEobOtxN0nvuUTR3XAQTU83Uc
Lz+Nj5ppZwJ3XyeY8Kp+Ug/6R+HC2uF1JFTqhUAeweRA4DVYAQ0n5GwZ51msG00KTLSL5BRX
fdHi+t/goOFp8YLCWuaJ/NDx5gymgzyJEE+3oWRJw5OgrO6w+30hNN4WXkjugsYSHAM3ARTc
hrqZhdWkMup2iy8jDgukvS+Avc8eOO1/ILw8G/emkBzfx16lYlRgWUrKoOe2HJojs72e02+4
nckH/azp2Xksc9AI2D0cZoc+q2EF94xgR0aeyzb//jnmSk9lWWPP+0HhWbll6K8lqN+qGEVE
fd0445zdhYubZsqisPgYK5Q01tQhqZI+CZn+HDVjN5E9DqZu8kSNxikOXwmjZKKmiSfSwK5F
bg38M5608aZB9wT3w/Fm6CYdGA4HIl9p0QSJkUl6ejJxvvG3UBJoMDwm8sJLOhB0KK63roSE
BJf0AmavHXwUtXrYxs+R01PXYlACQdsihKLCjzsSiAlsBIhKxKmlS5vqyhbWFcSTF+zyCLZW
PHniTVOytOFXIGbusKsGZ5bHcRFI2iXpy4kw9TNlLog4oyDrmlGS4Mq1u4MhuQkEuQ/G28ZY
6Qg59zaC/nWGa4THw76A1PX72Vd+QzAEjjUumcfU5qPMk3Ma8+3ZjbHhY5ue+x3rX1zA0nOG
M82vsd1Vb2e9dd3VN713262PAFHfih/sPhI/zEPbZ/waYx87+GPTi1Yk3mCVsfqn83tHkDRc
eaaAW1RA/FW7AR3SvOZ749bZhROZn7OvJ02dbXBbQ3DHLKoZBQQXyz1iKHnUK1T3DN1vvE/9
h9PKq6HJcC9pahyPQMgTG8lzChbXT3CqvLwVjTIO6XyDF8XHg9Zs9seD/boRBQM2i6EXcC5X
dcHCuptiwUSt+8VKY+V9yaLGh+DnYa5dpGmWjfGoqQHiwZohf1n9WYLoLsSytKWhvOQ1ipR5
z+0aDvkO23UHEyf4F9oKPkNVT4iwMMGqdiSXJUPSQJtlFU1gms/P1v/hNyZHmzYU7qy+TPEe
hjhJYm37drC9H3/MhlxxFbAXBMOII2ej2/664nMsJL8FQGJ7lAMv5XYAj+OG9NmNgDqD1HOh
AaSRlg7wBbk+Hli8tI6o6biDI0ha04UBkIY75YHuw7hrH2dC9M3pcSbtNhl1Ms6hrwklcHHs
amLv2AlQOwtofKCZGSnVoFWKj22N7EBNJC8GDS88k0iO7tKOWFCV7TrEfSRw3OWOUIndFWQj
HlS1IEvS74uXNi7rEYxmU7YShY8KYdJdvCT8nxUBYbS6tlO3W0LvJI27AQ7JZOxeXqE48oGu
88ZMQgx2AqlAqor/r9WzInnfdmAej7x+6B3kFOFcaJCuO995mcF9slksB4m1nJnJVI04LkTl
cmz7my+D4OWZp+9gdJdmxvKMJx45sczqcVmEH44ENL6O3ziKjydUzS56Fd71m5DnIL7CGsCC
ph9OHGfiN+PJH0rjCJLmNOEMDJCQFU4ItqUrqPG3LWXsJhPp5GJ3ZYviJdCmMYzO1oSKwQqJ
M+HsUb3gDRuiKP8LbR5lF1aoXgldMYHh5nVYwdK6CxPK1ylx/hP1OemyqxbzoSRIQXdKcBI9
0iQUOeEuUPzvj35qVRe2xmmLPs4CRznWoaU9tMikmfaGJ4DHuTLJ5V5GfHKnApWi8sbmDng8
P4ucikEO/UeKUxXXzfDGRpoRtgI0XZprZhTeaAvICch87ae1PrXNt25v1bsmdRyqgsDDLgis
cLJ7CAVelNmWv77Ahl77NZroQNTGRkUXTcErpQFyVQlZ4/cSHr14j7lvetqLSaVpiu95qOlm
q4b6qanEG1w0vxoqO56rI0gavXAeqEDbsDDIdN6vfhBPxeNNI+jsSp5zYP3AV2lYlW865TfZ
O7yYZ5dKQRvc6LR0B+DE2x1d0hFlJ6p8QoMmHAhpD8ge8TOMe/jztrdohcPtzXui9KGEdUGa
krW686nwfXRpiH3HXNyRUP3zFjemuQTxn2BNIIooN2cCqZPBAbnJ7iipbPwKhIXvQPtic8id
Lliwl9B5hXaC6UDJ0H8MGKfGh21vLKbq4NThw1uqPv6oyOBcAcKLhJKBfpmYkcWMAJQrjuFo
803gyGG275PVLCu/lLWqbefcdvDoR+3gIi5A1I2I+At+1CeXo6zhEQk6PeB0p+U0L3B4iQ/i
83vJWx6o9vSCJXXf6pS020fbiNWEzHGXdVtCAi8wOZQ2Acx2pwIJxTjhm4YDckNOEOrYSpjE
IQQ0eaAIB7300U/5gBHMS+JEK+0YA6oz1eN6DxYOoEhPsb6gmctxo1L8MDkLC7wgloTJesLe
xH9raHqHIZYscq9hGNqXiXQq3kT6orgDCzwGpX4B0MA/kMTkG5P7XGCFXLvsM+oivy6s6FT0
Sf0IpEm7I196evq+CkxV3ZBaVaheq7COo5+cncPajh7FvWz+NDCg6aeDu7G7/kMmpmVB84Ol
9NTIdsr6C1xJ6E9sEBIuDsavyypcPbt0H3aXH2CX+TXR6/0DrGxVkPFwMcHu7amM8HeOIGnU
7NxwoJbuMTNU1d/aHPBFbBUtwWrPVPhYXQoOLT8HnWcHDE1mECVKx8oKcd8I8P4cIM/tVcup
3GABlLC7liXUnvOfWpeeyqc1oQ7g99vsX6cakiActPvzuu+fuyU8G44YLQ5/Tvwe+kk820T5
ipbWzMLkvJBYLE4HYivVv71uW9nyNaKh+Z+FRdu9YNO8TuVU7y4BR0foa6dM4tFCy+hfa2fm
brMD53jmxTxPmQoEDeR5sDIzs+/irIyzNU52a/CHpMM2hn5yTg478vle3Mv4AUHjav5IgUPM
YHsb6tjoydN/WJnqvvTJ1NScWPVHWZ/h9ynSkYCRkHXXBVll94C3P9TncQ8wFA1EKLEZPWOI
TRgLPr23jaQLFq4ew/EcKafbCiYnT2eNO+eO99oCFJaZT+XLYRptW1IPiTw07PU3Q6B5Xr4A
W5guq2bo/al35biionMvSKTeXr/6R+hAD3CSl06IAawzMAW4FuyA6iF0+QTb+k3g5WHiIR48
VycDlt63IuDBCRFOiC+0w1cnggAqfGsL59WWipx7gZP9E6orkAL10UZy4A9fLAr8mZ8myu4C
kflXURpD8Q2AlhAWT+uB2oHDVk0hpHUoxzfngkHDbiweeOZLywadvo1zZ+zlxcxPNNHl0WA5
rwlAxpjHEijp5r37QTkjDtSz+QM7VMdPw6+tpZXt+uCT6Z5+A99k7pTdT2XlbHkyK/u3i/sN
7rE/aWHA7xO0WEbfnYVfdqj1suHeAHZHm6AZk1WmwfoTxp+65uJ5fVQoTU9XMLbsBU5yXQGH
M1gb7LGtghM0KPSwV6Ng7rHzmgaBL/dLJyaJCoGP/6iLtpPBoLOrSOHxxARaG5wtm9SEQFWM
B+C342lT8eK65WALOKrFAVYXHLZp76mq9pP6mYXvhzdy8uQVwmcXjvwS2DLf4wUXylVSbPPx
qc2aHoGk83KbRO6QMAS7pHi6IXoawPWrvg2pKSl/RD2RpjfWcsDUNdrFmAE4GxaFbOcRf6ZG
EWke/lJ42RDsjBJsy9E9iimEDJZy8v6twNLe57QRb8HJ/kQNgj8cZkis32Cg+/b5QgsP1DBZ
2xEoVJkuT0JzqT0NdRjiD0OHOuPMYaxt8ybgU3GoyBlDeVUjqvfKdqjdXoCoiROwF2Vl4kdI
eOfU5Wu8a9T0raA/Juzf0HLlgFGZv0I8z8nyxbjSWO8xhJrSY6KeXkIAc75dAQXBJ2GOYOhv
9FRWIu88Kdx8aOAnkiVqWnPx0PVfr79vTLOZoGKFDARdGjVxb0USdQkqEkOJ3MStxU0zuU51
KgQXMiOubX7xsuqroQd9pzNqdtj20WQxuFd9LUdHVk/PuxwI+j20K+LDrQTFWDOr5IMqnHCt
+VtGYtL9zi7yA8kMib1RE9GHTYwOrYhrCxqRL+wBVHSzxOSfoU+hqkVIoDcCsVSENSZkUP+S
nHqZEmh9J2RuDAT9I3ulovt5fp/Iq4fswTk+uSsIfXD820Qtq1C106GtodFVCt6rost81iBs
1SUX80JvWpUoLZ7phzGoUl7EBfO5WPPBA0weOAgUuIh3YsDrEW5KpDVA1iQ8/gw/Y9ldZTlp
orpKktPyRmT6FewQ/0HyLDCz4xLY20LSE+FwHg7r852Q6gMZHl5dnqCPhW56rWxR/Wz4L5hM
K6fdgG2lonNyRQhOUfaoc+B60Fa/hWDFuppbfEE8iDMbnzW0wHlAYmLV1LzcqvL8DPg3ucbg
BZyJ6AwigM73yFj1gRn5MJ65/oopEStpzPcYxFh4xLaAzzutqjzvKw33xucUnfR117zV9F3b
QluOC7Tp4ufhFXUN0IdrhganDtYDhHXpoOhA2drvo+5qQeNaNIIykuLs+sdAVQ/EQkcIgeU8
WpuKnh1mZ+yTdosS8P/lZHBr210fdI6fu3PDw17Gv6kTWwNImpCuAnaGAiSs4UfPGiHo5lac
kw2kDcRMzwoQOP00IHRC0EHkLTM/jtfSwJYAt2Szn2NT5+7cebBzmbGeMcbJstKL385Jg+Qf
KwFvljBs4HBN8VYKKBPWZMVsMoi+GMEWsmkelC4DSYPysI8MsbrUxqhrXK/pyCBsIx53ZJIA
kWAB+qh2z6gOaT3Wv5hbnrgqGiMRqVhpuvr0dkU7s7q84Jaq8qIOwSVlrSkveA2uKMeTUNOJ
oHN6jxJtKkOU5KecQtC6wXsNVS+qnV3cs2FJlMYVTRz1ZXi8i/Imviha/HQl8Pm6mWMPhOeA
hsTV1qGGINHm2v58CEGLdkX9gabbNpvvOO6OYBrd5EcP8uiX4nSkaNkSiEMLNOMnCWQ4KZJ+
f0v9FW1+bpQicR8b7UiXEHb4r/VoC6hpdxBJYzEiZE0Udwd/mvjUQOgMfQj+9PQ9Z+eNnfP5
1mfsNvC+SSN3wofKobYA99VHC6VqKEmA3yHwBReMKYgF29aY9LVyg6H1AMGcTUQBRAM+YH2s
ysZ6XwSfESIvvkiWZbHSxvOeznFTNfX7HadsQMVGFPjxvSGtD9WHEAjUp7arinpJTXnhd/fN
yGsJvet8rS8v3IxV5FG7iNpEKgZLISu1zmWEngsW183BZ7o49Gz1araPcVsV/5FhVTPyNlqB
wxv8FVjUrWQN5qHxxoy/dwVgTLI9lrsCTTiGdhlEzbb3FfJjfiGOnmlMQgjll7TsvcULqydK
kiudjGS8fs8GsyBDxDbb3iIBQ499dbOLdiZc8ROcAb1k/GhnzWf3r6v5UoCJfzGRMxCuycoA
Nc2npbNWUNKG2x1kbbSzN1Rid5jsD0LoxCIB5S1KH87d2rS0YuXKgGPN4oXXvao66YqLCnbg
a/4bHxKOztiFseCLsRL09F50SVeamoH2xgStKPBDoJBk1FKg89w86X0rBYH/th3JfGThtHDo
L9TNLDINWOjdiIUbZd4tDnfKtDeyPJqH4PAz1uBqPXTOv+PUcgkE9OfcHmmubuA8CRuBmA++
XdGdv+UtazzDxYm/tN9uEznuPXzYW7z5/i8Rz85SgNbB5aRrajWAFQZtHeVPEfmxQMGJ/gWO
7MAiAMf/QMiZEySvpvh34riBV1WN/cOt+9Z+zvHeQTxLCWjcaYIolIIiKwkM1HzSXqmYxrth
8Ps2zB1tsm6ww77W7nfCuVDb4q/1yZlS8evTpQzXtboOJWhgb2xLGZ/Rh7X5FPCgaafRGWmR
8JBCMB6blXfNRwf/BAL+P0kCW0kgoSz9K1nXIZjl8mIVYQtJQwI8CcMKzerc4FjFdnpPvaMr
dZ1i43g0uLKlTfej+78HxkQ/5xA0yU0EvaXN+0B4JVxqINUwhAHhcU7dk2MXVVdXCLz320DQ
pBYQV5B4ZRfHuwMwy/fElaH7REbjIG/UDynqxiMGp9oaK4SAoJzm9ftbz958/zjLCLp4XnUf
mNIPtYOIgADV+rc3rgrvinzNNZb8O4QOEAh/19v3Qcs+1goK9iEcGruien/+jo7dW3vhu4PX
bbh8GKpPUWX98HZ5UMeOxM/037iYMDeIcEIpE7sCXdne1SZWYi+kHpq6Xz8i/Bluj4sNTndj
bzJE7teHHfliH1NdEjkXAz4+NtyD/YURSqha1xcGDOFnTteK9+ofCP3SuLHzq0e2KS1vyu6+
rSDLRpJBEii0Y5XpVLD1iYcvyS0xvowO6AQy8UeyjFJ5cShcSfp9irC3cUjuETYlaN0XDu28
x3d4vJ79OfAjMxwsW5yP13QbnJG7OQd9IlB5tNXEqnffujklW8PLx84J/qNtI8NwkOY9UdCg
nl6pmZm4j4R9qq8lW5P9QIKWHVzRQqtzamu4X+tQJQsW1V0IJ0zfsLsAgj2h+duaxzfOOWd7
CLaVq87zQzCN3FbyhvJAr7iWdIxDz3TlOT0XEzk8qtfvaeEC6ezDwvCUfy83N96TwEMVEzmu
P81s/LaE4gSoehPSDz8VJPQuvqupULs+vrQnb6qKd94hPcrJD5ReMUE22F8CArTH0jKgnrfX
5D+bn9pE0kEK2vwWir46oCp3/bjp/ereaFnd94v2liyuP5Ai8P3S93u3NA/qswWaUlkTH3pH
eCd42EHUYi0j6ZKFVWN5tyQ7Qnmgs+Cd7M9AjqpbUrWSA01+rrLhACTUB9GZELNiDvHcID9/
NEviU0R4tsLxc6rJG9CNuInOqB3QOdJEWIb2BpzhP9b5HS9qU8xTfWxstTvDJIVO7EQ+4qXA
DV3exRGRkypj58S1YKJ2tXSKI38oCSa3P3QfupL2zhFJnG8XQYOHSt6/ZgFBR6q8hQpK4GpI
xtnQp7Y8bkFakGVrl3rASVixxjk7lnpqFnmXA4beEtACl5qyhZ4Sd/NOBe9YgDEA2BMdBmDQ
SEghvjUxdKwEYHhDUfzkn+LEhRkvjGKLvxHksduoxf+Mm3SzJEu/U6CNhGMGmZTiwekf4AqK
wcWYaFc6EAGq1YehPXXj+tH93lq5cmXE4m2j+K5ZYa7P7eNEqHyMwMlTHxdW1n8ky+4rd/Yb
QqzKbj+Y5cGuSXIhWPFdK2IxBoiAw+QjwZVElBKQciYom+EmOLOWQGVA5k4cdNt9FVEyLxxS
9QO3REuDAzcmkQctpwJKwwQzNvK7vF9eU3HsdJZE4MOAgc8QfW6Q/4lk65IWSsNQ54sMh7Oz
S2ARUWynxbToQd7wKjRUlkRCt/YEnylX29EwMeUfhkJmvBFBkIR88Doi4nrrgRC0ZhjLa3av
mM4qKixvRYFQYelLspNj3vBkPgCPjzG1unpqGljcxxxE9ZSw1955AiZ/3Q787589aSDn8iz1
0z6DhK0QDH5heEBFA5kAMZN2EFhF+3U18MvmLGPBwr+96T/m49JOyT3knYLd25L6vThxbxil
gnuJnVBDTc1Wd/Ed/Koo2S0jaWDMUqiIRQHpTFRQz9MOeki8HjAY8So8K6ubej5ZDUWEsnmr
B8EQfEg4HysigYUHTpD9hrd1EhB0m4XsZhbBu0dmmf3A6rA8181By+tcV8qFY8+FBClW6wfx
9V6eNV9vOX+njLzGru7qxqZToh4eCUGKhtSVkmYs93iMNuwWwdnS7qmdnbeoh2rG98rQP4Us
47uCYJwRyqDr4lkgG0OPiV85Xhd4LUI1MXEgNnM8dgs5e7YV9PSMn2OHmUJkMo1hXpaYq+Uw
O4pdnSiJAdgZ/NZzcP3MisbG7rQ3iIZyfEgAh6yFX5Wx1Di4rACeMdyBVLKh6j5YJr8kUS62
hRi6r9MJeQOqBHxh5at1d47ZEq0ChiwViaQ/6VRAeX7FN6vm7hLTCMEqWMmVCSdSsuXvSOUS
Pw7UWMQWFyeYXCWKEvxcWx+nZCUJ1sL/kX8Jq+0Lz5e3pPYSJgq2+NEqXIYe0eUIJN3/kXXp
oM5N6ia8PGfvwfuk/lAC1zuCoFE5aKLQbp12mOTcJxh4PdUWboEQSw/A6fIpHuDmYGLQYCVo
pMJ7UlhzW4B0oF9Q/PyoR97/4109IGg2/eJvXtgbXQBayiMKYt8gbGEYPh6neIh50H2wQUnr
Rd2DPbXeYMuhaKp2U0+nZ4PZcrYzptBAirRF5bm/188ofNJuT/Gy3gd629a/Iyqgg2cHd5cR
En1REqZCB95W9eAi9iMcXpqwsUp3hUoa/207PlOCi5H+Ych8OlTO6emBCwzyOd4L3upCZYAv
j6PSfLfUzCp+ORRn9wreZn+omMFzDmsOwRKZWKTbWFixYpOKQ3fUZaiYk/p61VVXuRTdPZQW
MArkZkdISd3efLRt6rx3n4+iHx9MF/p795fvyNFE/Zd4PjcU59zV+NjgxVsInsAbcCSGf10Y
jZGlWZrcefMbz4AOca+ookVWr7efQN0IkH16AxNr7i7oUG2KViovyKVOnT8IPwOg2gP3RCsn
0ThB53JABtvSkSYVSkHROlQgz13wUYZqsK9ap6ExMURZC/jVGYm2p7v0pqENJ51vXWshCJnT
hb90LgNygSuhKeEkJyuiCNK2UBTlhtpZxXSyh2MBfkKAjk3XZukmULibRTOut7X7gRZOgMnd
GlA5VvleBDSADRhigAdtLmDYsaqa9vD3lj+0MCMjY3+sYm+/4vZ+MG6hnVawT2NlSPA9p5OH
R9OtKYlAdiB7zF1wzATR6iCI+mXEHjilAxAlx8uf6/7Wc2MhaLOdHF/iSHtRLva8D9Y55KcE
KjwloIRtfQz0xIGaOSWHQ+3zS6kP2xFEkkqhrio1dTNzq0Iw7V5bAmnZQEnD7cLRWKALJQuB
8KW9RkUTgla1X9TOKHAUQVM/gIgm3xDkR8wkmLIHX+ACv94S4RXqV+wWdRfMQUPPp+LVJfYZ
ZMD025BcR32aMWnx35Y9iEMAYtIcd1498wrZndqoS+JAXRRSb758muOEKD6ZC5PVpPHx8eIi
rix9UPgXuo5W8FM1kB60ZuifVO364nxWcXFMKcuox1b3x9b9TCfaC6pq12FdesQJWAQDWgIX
mbqINgACqXYIDcsqcPI7x99qV+0OiOnbNqrUJSu8iN0OlGRpvIaAwZrvoMh5d4ae6Uq7hoAg
YmfYG5odmIu6vqJ2Rn6EUVR4+XbuDQ1+ts1prptjMydbPx2qGUEMYAGwqa+vaevDF2wLYE54
Fr8k9INqm3GkueX8Z/+2pKG9Qt1+4JsLv5fqOktbKvDit0PKEESEwgBjBPJ2USKw00CB51tg
iDWaYOBg6wYw/2OO6ZgJOlcor6JR5nV2Dp3Ce6oFGoS0uMCy766arKbfsGmRBg3dtSclRbgc
RjMg5GLi8+5AmPFAEth6+ZZtnF3URSe5x4w9vOQ5Y4Kt9RKUGKin9aEi9CxXLrz8pdthK2A2
vFM/q3BdCKYTV1gJ3gufYvZA6fqe9F04RjosqCw1G5MTFrrdzuGw1PHfEoWrM25P25GDd8Sf
K7GUUMQ4nfjPvMH1pZxHjx7endUHrnTsBI5ts5P9ZMhrYNEFJlz+7GsLQgiaqtVF/ek7X7un
D9zcPSjx/HdhPZ6hEC8fc9QM+H5wcToS9z2yQYOJ4/8L4tAropgRs1538UbzF4aeqkoouScI
CW+TxRwlW5DkE3p4ak8NivbO3BJC9Qnf4J9+rXVQzfT8JxnpLMYZsCu50QlNFjiRaq2ZXvRQ
nMXGTFa2oP4s1K1/zIQ9JCC9YbhC7bCwMmT+a3iOaxsWDSwOAyBWxzPR3lmNK66svloUXZl2
tBZMvrDqq4IRQcRK6xe0s3rjKDRsZfWjbd4L1t93QYdQz2r7u81HAxsrNHjqJmbe/sCEQ7D6
2t5t+rheGClxJTs5EnEMBledq2II7iPPrHhkWigePHrCcx1I+lvf+p8hN9/4fz9hnvRD8Jh5
j8LzGaavaXILQN4n6Uc8bd49PATDqSu4EJfCBmT3xoWT/IxL6YtP2HZAzuqoW7RyujQwWqKI
OEU6zeA1B3XRIqA7+kCCU6JeNc1fB6ujmxum59eb0usESqGdAybCubbZO8QDZ0ZFAkXHTArr
u+t5yB1g4hMzbXcJyCWq7jvmgRDG+N+2Y7BDFqg4qdJR/iu07qYGT9vurhXxxPPQguDf7ZxS
5qRxZEjVOd7OMy1Umqr+YNPcso124MTMazDoE1PV9awRC153bZw9yQ89cPI/fkbMvN0l0J0/
NLe7ohyIN1jjvi5UqE9b+2In2NRJKml99O1/7jMSJ12ncaoruFojO+QGJgGAW0qIeYo/iMOA
6QTH/qNuDFMM7R0TkMCD2NVbswKHtK09QE64EoJIqmg4avNkDYQMwU+CTmobpt6fA5r3y9XT
C4oaygvqEkXQ1EShnzoAVFwfu6J/UHKKz+9d4Vi3kT4r4y6zy4JRAz7409VJms1KH18zAqv8
mVbrGGQnseedpB7zF9aPAyV0rdU6hfKRe1m/Gngj9By6gsaaGLp35EpsDlVfjwMaSIWrVwMQ
ymY6+gxjS5SMQSZiBvtjq/VCSfvOPG07DhDgPd217BjVjSPO4sjkfJJOPlioAJh2R7C0nlv+
0oBb7nz0wb4DLzzECa5vBDjmMilnLKZgjUAdln5Sxz1ZJeLkG9amBWyryHZuMDQc+/K68jeK
xyGHxRD+Hlyzq6xHKitxZMuLl9rZdkZUmnZrDgUMVBxUIuGIM20TGPLlR/xiv5ppeV+vm170
LztFYKuBM+9Mc3XLYIICmUBN493jtlsG0inj0Ge2ugTeNdaeuhX6n9cb4TviEIE3XNINxBaw
GqguOlPnW83fOR9Rh5LE/9mJ8Qae9t6o/W9w53Qu184zXBkonNJ2uRWCIOFyDQYvpuSJk2c4
fWM45dcCvldIMG4l0PczBH5I3uJGmJvHCtApWb6rw4hGGqjnx8pxIt5fd9svr3mrfuc2lRPv
h18TjwoCjo7LIraGbiLjIHuj4xnxnJyi+nX+upUrH3FsvobaDtoqDQdeHKRncGGG4ZSWHZ09
HobShq6Jf01DGx/KbOeKNduv64EfCJx4NrYbY+G4YwR4a6m03xBoq0HIghj54cFkwQERtBtZ
gO93gBO4RhyT/oGqKKvA6m+smVm6LTyL3Xs4Dh/PGfZ2DiTvUlT2Q7t1Cc8vH24ebHjE08Lj
rNyDGRak7jF64FfgIjuHsMIo6IDIvOHCGitV6siTIZ15J+jEIVh4O+Is3xjcW53z5s1ffQZ0
jXFgaOc31p4JYWrQ5qhxcDHuqSY6JE/mBh3jCzsgEE/sDdh076Z6WDUNx5mTkuRtJTlHS09l
B99VYPhg3Ex8SFAWfqM2dvrjm2Ly1PmvoMRrSWda8WE9AXI2WRmIpE8e1H2gOyxOuAiEuDVt
q6p4b1z53P9+gheOhjGLPs4SZE+W0ubFOaXwC/nk+lI1oH4cq5CEkDQNalAIA7ogz1ildHof
lHdoW2vLix8PfwWDhZRWThwi+QKDBFFEOSwV/Js+YA1hZ0/om+2FS8mjakDcsU/RN+35fpFt
G//w8qPd49Dky+1QqwQTFf+iYWbBm9HgW41LcXPfpQFnB79QXkFTVlId8lY2STAvH2nLqtLQ
tg/vt9m/xmqjwvIVw+cuem6hIwgai7vGtC5IWnBJE00WjR2/J2F1BqshgF1ch8Aq7FWv3EIF
77AhwgkiLEZBTefSxOcWrwGV5rFeHlmvyuJgANgaHxBQ1O9078EtPhjOprr85kdT09JSq8Du
hFsDnbXio9BpKzQRUduOACtb3BNaAcLmuMMBTV3+0lP33mdG9MKfFD7lNN3vDzTMLtg0gn3m
4lPlXEP1z4tVVEJIWpTFS2k7jLPeY8Ht8T3pcEPA1IU/2H7w5QZkpt9JEXCKx3m2KkI8Sjoq
x/kwNWy8WYIOyncfRu02yixsUyWWKVrWFGn3Lle9MgGtmW4rjROwBff6V+xQ9eGwyakRp6lV
4XF0DyQ3Ht6WOkdbejZ9v2ja9xpnFMRBgVoqoksmXRE+1+AnmTaYvCiNoYWWJyZrO+LpkiGO
CMxtbG6F2UjqqOpZHEU7liQlq89vVM0YFSQmgWuAmQ0BbKEgPsaHx4zEZ4cVMewMNCbgsAUU
/thLy+f06rfzwykdGC0mDZOt7uP9at8UprR8FKvhCfGkOUNw5Hgh4lziNJXXYlXuRL8vnF+b
j61jhp16EL8QOsdOEJcd1SheXH22JMj97exoTLVETd0IoYXJV9Rd/EAIhKHmZjFAgIWz6ru4
ALUCrWhA0zMQ9I2xkjdaHtCXAR5HUkW8w0Lg4oRi8lviRDA44ajhV591Ala8MBrn5h0EPt4U
JBH5LHXLIZcuwjlSCBnFCygiHVwlGOxoRNRJ9QCLptkru2W5XlH+6xHgP08xecygnoO8ZggF
2+9NISEd1Ct79gU47pdKizHopcoZFSsrZ/QqgqYudLs8BVgA/0H3gdShnKGqO+u+39XjJr0P
D3FT0pPhsHrTQR7+K+zzB+nIn1bN/W54RU7Ge7jnviKosWC9zeTwPqArpvaEU22E7w9oddhD
LmSco+jKmyGhBSjNAmIvWg9YenV/tfX8wZxwhP6AJIo3h+QOduGZrLWAsrt6Vsl+RvRhe5h4
5la5JSAMtsq7DcGhKwnq/Ip/fn2YaX34+968h3+Kv+Bsz3vRjkwhNe0MnIVx1BCsj1ezrgYb
1rXOocERzjDomqr3Y4DbDv2uW/637pKnwaQbxHJ7H4QJHEL8aAzUX77eZ9sD8fnyJh1rB46f
QsfoAe9kWVWvpD7ytW4d7PKkx0W8ESkUsAAAIIpJREFUxU1J72s9W8KxQ4Oc+Ag8J67r7InM
CbjOwqBBKUCQZm/A6wpOnTME28grvG2i4LrGroUc8XqNgPZ8CK4oC6UmQgtFJHgleFybvi3B
bBHJCxfX3i4L0s+cQtAEnBZZlen/wk0EX2PfoV0p2ARbZu9EVBwne9Tve6kiIu44PUCt8A+h
HZVLEL/dcGB/DfovYIflgeX2y0H7gLBGVLwjsIqHIJGMI8xZ4ZHueaE0jpTWkjzbg79pUZyg
gyVLFDNpbxggkhgEh4YI1gYvPQJuzuDXn/juffEg6Infedo9afbTt1qrZGSunO+9kQr2Yp8D
LN3c0Unu9NvgcsdUxYtM2fUpbkp6/8F92a7UNNuD2pT/6VpD16qcXDFly9agb1LH2ELSJj9a
39lYXrDbqdYVPlo7AKyA8+zQvFQXTje21N1TtD5ULzgiB3uBoEbgstDr2FfouDW28Za3yUUL
6i+XZfnXQaMVu607Vl1TrUzV/3AsJngnuFNHQTBiQ8LWDpHYPJr2u3gmfec6OPHcVxvQFODb
DoB/n4Uvdyt80TxgLG38KSwFHrIq8IaWA8eyW85H/d7uqGMnS82O+IgbEDaTH5LYvClehbEu
MoCIpL3wUAYvgFCvOx3sLdBXwbMLsc/BdFE/ONLCTf608psJzUMhy3UlbG+vR1WftlvdnKGD
78au+rONB0eYbBXgwTGQVj0XD9y4KWk+Je18fPS403dXOFSFMKj14/4Bu6tPd/Huw2luUGE5
3b2PJ54WJHSZo1odfBp3Lx39YysEJSgR/FNsm8+wAxO+XGDA5YkwuY4XXnFl7a2SS/47jtlC
FucQtFk+MFfdIfH9znWBmuck6K11jk742TQm0f0RfZkwEBsZhgz5N50Uv4kYyTgweBBpxSit
OpCKvS26qMuXJ14tVGJlBaj4ExM8/dLSOLcnQ4eQUCehoOg+gl3UZf/0rL3o08opCSHoi763
4jzBLf9Z48RhTrQGeG8CfPe+RuzF0Y+sSscwv9C/j98UD+y4R6mga5PtbIc7KgPLHsEwHOXR
dsB28OaQp3kE1NFsCQ2JkvHr2h+dqtaIBVDbYcLtZD1nJ5C2Q4D5SIc0LJD/B2A0qwFqn0Oh
IZlo9uLKhjtE0f0MdOYdxs7tNeHh4a8irwvigLbaJFvtBXiaDzD/Xlc9q3R1ou12Kj1p0/h1
dSWO0cLXQ30k4fL+zft3gVG+1moZZNoPTa4rSA5lFcaJyMeL6X2AnEUdrA1VEN48eHT/0Ld/
NvmtRHc5l9z/p+tEj+t9GL/QmYjkZMlWmFixxS2J0kWt/qPLCJAnNeMS8ED/FO/p8PFPKo67
xO6gpgoSvzGgCxFHNVH8yRZkwX29XawBKivQVzAcm8Au5h8DC2Dbxhc4KqvNqyqfRfS5Ydha
kICxhLTs/tkRMGM8lFTWL8ERXU8GedB2ezt6YUBbHSydjhTLVkvQty+zyg4IwSGZFAxKfhB6
PlHXHUd3PEWIlVQWoex+NTmRUv3+X5GKmeVgcHnbj4y1zd60XL6FjIos9tElWcaJ4L96r+Ka
y2ueuK3DR3q84C568K9PGympL2kYz2QarkuCNOGB1xMa153LOjyg+RYdpxRtmDv+c3oHdswE
pisPd07X3XNcSLpw4bph8N6EY5psUFpmDWj7r+1vvDtve3cVOlniYT16re268PzevUrKEdtw
2gHIMv9NTMa45QjRyiU9d81Q39g4+0sR/GMMHFsfF+5NmcgZV0Urs3Nc4cKPh5UtX/9v1GWa
k0LCzuUQO0NR1Q2d44tVIc8WAmsHKAjCEd/RI//sDP94Px954JpDmJqPm6wig11VUFnXt3ZW
4dPo281W6wLhoQzx4x1W85+IfKB6x/hU/dEPH7zye4mWf97Dr9100U/+uRk87e+o6EzzfEQS
OsopcFlqDEwUXnh6yAd+ic3vo6E4TDUBu68vQs+xrnEhaYH5C0iVzG6g7SHOzvyXXTi9nd/0
XWBwhXYWJeJH40TizyEoIEarQ8HAcVS2cCl2WQap3v20c4WAom2RsrqukCrazIlRXEeGyiKL
UlDP00Q5czPOT/ySXTXCENzurnRKKyZEFyQNhmVukC3fXc744gOqvna99/zW+FL3cirV/wtB
dnlJmwV+t39Cpfl9geuJtWWlZBoMWLj/B1SVrXFhpWyreQQmqx+pFz8Qb/7JcApV+uM3x47/
6b+qeTnt9+CJDQvqV8NNKbktJe0QsE7A7Ld8QgsWzEsFV4pbZdpHVK/RlfWF6FiToo63nnEh
abjtKwsKdeIFGz2dOSk55hiPNnop9mN5TSsTSOHdRjD9J3D6RyE9ZBugzKzFlXU3gfJMswsH
lnEbGmeUdJEJQLBhbzHB2oHZXHBkQP8oEusKvmRJ/b0cS92INixxQjc5nn4gN7W6wXXZtcHV
c6EG9oCdQLrRmMJ/c+r72qkL5a2eXbpP9be9Sfshl+y6ddSy1f3VDM8m7Fy9VmATgYKdQgZk
Bg9ayX8i8vj4tnfi/R7jHnnnsu3nDPlEcqfWaaJQjDM9TdNxFQabKu026ScG73UBXjAtBomX
ygO+tmUhJ2YezvgOzEMTwoFxbZ2hnlUM/1oWq3ksG3i0ulfzOe645FgJztyJol5IPD57gVTn
NWe2wrCO47imu8DQt1UlorIg6PprVCC6sQeerYZEfRdnJC3C2HHdWLq06UqON940dG4P6LGx
GP8XQCPF8dNPYlWL/JCIHN9lW8lJciEHS0PUy3IgrykKU1+0DKAXMrb6/XNS3eJXOFVNTeVS
b6m+fczjxUvq3hR56TorevWUBz50HixaUPN67ezik37eVv9g0r6eupW8KvZR+l7BOPE+qL+N
h8tMJIdRGHEJICINMvyCW8qQVxzSt9ZEzRJvvt+CzzIMPdCvVvTfSPUiwb+utzXWzRi7lZ7j
DfFR0rwBEj1ekN2ng/38gRRJ77Eju899/N4YnAQn//h4NoKG7b/qbfvQBoiOrOf2+ziNF4RS
O+wXAkYsK2xeX+oAHHaDLfJWkxYOi7Nya/rbMPRMQzNuAG9rBrbLl8D/yXFH0FR3XVVZi+Dv
gqThzCHX9nDWjH1OHSZspZ+j5dkw5+zNAsdWEeKBM4KbKY1fE39CFr6WAyhqXhZM9ollGBYz
ytNeyCemi8XsEdmKHl8zJVUfuEuX3S+rPDeeNDeCqnrktjTI2jBZHaCkzZNZoC0D4xe8Ax1L
SNxCOEP03wxkv55NHWfuUt2878K9mtZJqyo24JhIOu/xD/vBjHJobFBxpNC1XZ3PmIsj13FP
gjPvioFcbJULzuDGxrnjD9oC0p7ZJ6bfCqOadFuwwIRVAr49ODrsg2hwVN6Aiaq9NkeDe0Lj
sJnZMHXcgfA6jMDBs0BiZ4bHWbnX+ZNTthJQlcUCnZTN8cWFi9dcuRYntmMH1WCljZSHdkci
L19asLTuPKswuuYD4g0/MKBrAjOGk0U/rBytI2nwnPMX1swqWtK0ATygF5ko9NUI5xMCNpEx
XcPvCUHjHFJC2vQefGmwP9RmXX+1myoGoyuedkd7j71ait6qzQ29g77I8N0HSyLGY+hdT9eY
7A5BSr2Y+Ku2LO9QA9IqUFSlrvMZcz1V7kS8y5vcKOO0k1x7ZZue7960B+NYboEzHqJDWO2g
UBrp4Ed3SxFJAf1f5mHzx4o9pe9ISA0DHTJgiOi2NDFjAtmwQA3RevuoMw3NkV2S9UpEz9mm
p/yZU3xvSbzwZZ7z3Acs+4ZaWbtMEt0Lrbqh1TSFwzFjs1CiQ94cwVhYztqit+BYrH/B9RvZ
HQES2oFtlkCAfvfofYUXAmv9AW5Xc1QVIkGoa8FWHC5JQ3Do++MhbJdBM8wcFfhDVotg8x7V
A8r5OGmo624sBIaue91Q0TN2hhgmEJBLR/yZfF35yA6NDhhs3QPo78bLMw8HH5OSFgV+cuQw
D8+eyL1Z1KpEcpyQtBcqF4Py6PiUVupA2XUWeMdK3s55ChbVTQKbom+IR9b5fdzPvNB8mPd2
axkn8t61YKn03qGpcVc0mJD451DNSDBX5+R8FNaacbVdtg58z+iKHljdubST4Zl84viZcgec
vTKB5y4qXlYzQt0nLQd/GUjRRn9y7Jtj5lUPPb5tBDL/9U0JIeixj1WdOfZIyUeyJPyLE/gc
nPeIZhPDGT/0SZDFQVfykIcraXFAQEg/opyJ9WG43VC7k1YdPOobW3d3UcxdSArUuMIp/oAh
X5YueeeE+so0CtL1xtrpxZZ8+PSMpCGwgvAH2xwbPK32mpKVXEDQ/hWq+Ml6haBpit26QQ8e
bC8p5seNpxwZTnNIvc1OIHVATNKazbvKukXCnoPeNvC8t9opx6m8hKDhQvRP4GXvtw6T1O/U
vZ3zoycmhlNPnd/H9YzzKg1VA+V0coZ100u2tvn3DQUVvZ3TxeVk2aYy9oAdHE3sv1S31EEZ
nlwtD/KtcyvXX8WlpW2Ff+hxQUFpvLslLF4mUQBELkjb4FN7etO0MRN23BefLnPb8pt3hVs1
giIXgDffC/XRB03DXdiLWN6F9Iik8/s0ZIsed7ZdgRVVFqdHNK+dVvJZqOIn5RU6oSLPXUwD
0l7gAl61JSEKIFp5ZcuWSTi5+3q7OxnzRHBVWdTTVovYULqqvUaqZScyEFsMutzvVpfn34At
p99WXTQuAsmfC2k7joc6w+54xunz3kNuFgHbVj17IfPamedv8+n6baInbWLBwrqrMgztWRzM
0O0iHasKQfVZ/obSJY0zY6U97u/vWi4O/sUHX+Uk4XXaw5p1TaASQVVNeE/WtO/k9qk6Cwh6
aQLZO5IWLqgdUlJZdVHdtKJXa2YUBNlhIHT7p0pc44y8lo6ECd70iKRhOzsQFIOcIMzoyXne
8koSHaDzsSULq/tzomtgoh85vCbEC4VN7ufrZp6bsIAgHA7dq9r5/wu1Rdv9r+nq/tqZxSs6
w+/83KwFHrfrF6QzzESeaYEAq3glTtqeGMzH7Uokf5e0PAdm5LHg41sHgjdpqz9NKl8z1n0x
dVxMnuqxkk/MXeOM/LcVX/MKSXb9ahUOG9Z07SMan1YDzQuMx4V5OHTCKoxgPlC+odPFKyq6
4qCrXne5Zv9xUlgZPVd68F1av8zsOYmoqJrsNBAE0DH8FIvurc1tB7LXlY/9rZ2ThXhReItj
0qGwejMijOpsHvPXtYPCSoAaWgn0o9ES+wGI4qRndRiC6zTQ/LYmMW2bdI7ZFhqSdR5cRs4O
btvs9b+uc4/FA2EjDCKgFTDPFu8ynoKipcGEASn/26ppY4+xm9qP9oqWPHYcRq/BvohIpwtD
MZFtbRVocvOc9rcIuCfxQ830whthdTkWso274BfvcZM3a6O+5DfcLbp+e97jH3qsgwGveeWU
oNL/F6PIsVckEv7bJL/BBYLsJELmd684vaeyRvTbKOHklTPi2gGbAkFJ0Tm9SlECExrvHHHO
2mm5v9s5d7wlox+zXlhoSpY0fAKLT7WqvKCup7paedcjkuYl6SInjhcChUQyVNMs0kolj1ce
XYDTHU21tSjRVloQjD/brbMWcJ0D+SPUxewFXnQpmhq/Jz5vW+uj0OYBC/P4BdIeUpXAnVAP
/E5EqTq3LuI5wQf0X8Tk5yXuXCx6EXEJgiTePugW/fVE853I9HCR+R23J22R37/jE2hpRRGm
Jly7sW2e9E8SzhUtw/KbwDYKmpGEvw7MvymI7AiZz5+ynd38u1TwfaPiK5/qpvg0IPtwEBH3
xPIjMxWca/lYQNHGNN01pmzDjLxVEYkmr8jsoPAjXvT8UDxgym9EQTrb33L0mz2ntPY2aqND
oECLXBK6t3WFoIXTjO22YByHzDITJtrVooCwS2/27XzfdnVF4V5YPfb4fWKVwUHtSAl4G+h0
4lhpQ+/Xzhm3S1XavntceNOgauDoaLviN86rm1n061AdQlddUTc64fM5BA972wuP3Vu7A7sg
cCJdk1qpdc3Mot+qgVZR9pz5d07nKuywPKh8Op0cKn754E//1Ep9eswDyjmHEHLn0N/dx7O/
4Lxo+tVu8XMJaD7F3AF2xtO0s2X8HhhZPREIHMpsKh/1/Q3lozZ3Bk/P0un6UNbX44r2Lmoc
UdCVjUskSbq1zdda3HBP2TEq2kGfJ90igVGPre6PBe6MqJVLJBJ0iwFMwXxsbyLZTkRaTdMv
s12uIDZunD3JlsCrcP6n+aIgXGO3LkTVq7xG+q0JhdqZpc/CfPwXTniK665gUPhQGtKfM4yj
I+pm50bfZQlaI7kS6A5GrHjYykWOb0MbFytPzPecsDZmmpMwAcbCfIFnZ2tM+y6QtOU+DTWN
dtgQ7P6g6PGavFCcU9c9h6Fx2jnMm/J5lqRVsQ2jIuQMlEziM/ri5EPToITGPP1IfdPA5+c0
9j9Hdh8d3jh1zJzOnh87F6E8/o1atvzauGQNhU/Uji7JmbwOZvPTfGrLtxtnl3acu0jvRv/m
A1D2zoTIQRwGU3a7JuBs97AYa7d0WjbOBl9vl3lurfT4c5FklvQq488RPaWhBY6tptGTxI7l
5VZFVx82BPETGmxBZ03dfqpu4WEy1jdOL4lqYdhtpvYX1TPyH1A15ac4lw0xtjgEHUUR94F4
ulBRbMDJrVeDf3fzmnaT2Y5EYTfwWPIF2g79w65zNixZ97e63sGTHr2wdhh2FpYd5YQKAUXm
iGplCN7xutaUF87VGbddFMUyINjEB1OUigINMiHV9XyUV9aiyp8eaPKqXw1DlJNXeBjOGiSA
O3EsF3vnYpWVryDWRseg5HUjB6bvgjlXsBLB5zrc8bLlPOcf2FA+6tEvKpwV8hYvrrtT9siN
As+PBDGztH56ye9DDYYHzYEtnOhdf/sFljVpQrBC124/ligaX6ZG2/3BaoeUYl4NFXiyXtHh
l5tbfBttJvUxTWfVdttYN6toS+20vAer7xpz7v5DWj9NUX8IrYtNvCgH4t3+U12gY/+0nbrU
TM/7X43p1wG5eeMtt7vygGyxAeSOwlfvtDXTxhasnpkbk6/bd8+hParqPRBcpBIci8R/hIQv
VB8PDDuc+L6qrteEYJ5iV3iH9V0G9UbbVHRHu0Gxgr1XCA+HT3bE2bmpvG13KHv6jJey2Kzn
MoC0veyZ23zy3StuCr2DMyQILY/xsVWJjSRCQvUHiO98wOv1jls3bfTUhjsLbKvBdpRJNxjB
RQtrrpBcnmWQTdCicDjgYz8Mpcl/oj7HpakjNzvsLz86qYzK6Esb3w4EyGG6vW8KvUWR+fQX
Qw05Wa+6pm2BOfgcHbPQah2x9RF5Q/iT1fzR8m1/oPDQdsZ+hhHy87JlTacrinauJIs3YcP6
NVD+Jn8w2rwjpzp+w/u7aDATiauZmvuX4nnVgw236zaRE+4HJTyAxkQsrROYoGPe0KKlYvrw
b2iGsUBvVt5NZEdFutsFC6vuAHIdgzZ2INx46o9FildV471QWtjfbQSPe66aIJxQfrqKEodT
5Ngr4XGn0j3UMDdAZzpPkvhPsadJM9kCNhtAYw8WsXfAU96TiXjKI1/OK9O1HPabb3bsdsKr
0uxp8bGj3iBrY8afzgzMv54odi5t2u+yW1y+CB/eHBNzTVsA3fvCtnW1lb55k9ccg0UU9zGE
fiw+8buSpU2/FWTPTVrAx3GidNB3uOWcxv8ZZ/rnKZu3epAqaIVVs4rfSBxyzzk6tgw9J0u+
Pdl6YMSs113pY864EYch3ySIchHMX83TI2jSEEsBFPATNdPyO0xTnap//tL6y2SN/wZsqkoF
Xu4HDmAKKAwXWCsiJj1R+m0QoTdDJ3cd1N3eaObZHzdNLzrp5RFO9c+pAId4ppJHXoUVvr8T
iBqrMAL/j6ppuVfE3/4KPm1WblbLwildtU3uer4/6+P1s1/eHmIZUAlBntddKzJlmZ2hMW6I
5lOqyGx8VOXaV7Ho7FlfPuaOjvJJdQ+aIZ7yleO9rh3VbN5cyyp2Q6BumO3J/AzykdPIjoAT
5BZfW+sljfeUfErlEYtD5PTJteUFCzvKd/AmiaQd7MwTAgq7nrLlazxevzhalqVpsOO/VZA8
QttRf07j3Dxzle+NetEJLFvPHCqmtrWJaZrMqy54tPDvM1SXSOp7ypq7ykBCO0PB9Eb9/9th
0onVKWn9ngAX6rtOIGoiDEBTv39o967Lt1Zc7IurfysqRNaYK5ksjfAM3wKbY4CcziAsDI8O
v3ff/dLPfVLLT9hjt7SOXbLuybXVLeVsedAlaHi6IO86+jjMr1xTyLG2HfXlEw5F5jn2VLyw
4XycbbsUsoh8ioV1oq8toI2Bd8Ft9IydCU6tYlNq+6+rYDgUmOKcDkkk7XSPnmh4oCCKLskr
q52W+2kSSZ7oj3GSlw9vcWUHC1YBkTlylFkQURsfBJj/rsZppU1RW4/x6e4vnOlbcv3mqO8p
cvJkgeXlGayRiWzlgwq7+dkU9uwt7SyOIPtCnvPilMC8G1e45r4watSI3H3eV99p2zZ8cLFs
6NtawWVjnmYf25LeZgoiuymopLLuvexW46p/RLEILFrUdDMnGNMFjjuP1HJJ6A0+6Aa9LfD1
2rnFjQSyaEnDFeDnnV07s/An3RThSHQSSTvSjUkgyR44NXtgYsUWd/PAtr2gptOdaQHQGZQF
VM24tu+e3X8nuYJtuMS6yGsyWMWDpFtnBA1OmjwsOzeNce4stvgrQJpA3hUrJXZgN8cWzoYf
6hWy6xB/l3/+DYu6K3/Moqrz1s0s/TeDf43iATVXcZxUigIKeYNBiYDPgMIDwAJBQ76CS8PB
3XvODu0SShbVTkdL86pmFs7sDr5T8ZDuJEOyB5I98N/aA+9UDPMFmHYFqZTbNXIJ9iHoThw9
Bx/orx4dOPCz0sX1FZb6lhBzKKycosv7c/Oku/80w4wauBsKD7leSeAHyWIArisQZrw40nWU
v9RE0HiUDglFvF+Pavk78ekt7pLKhj/JTCouWtTwi7JB63fCpctfwXN+GMe83QBXwxnmaTbA
zEGHX+ypqrcaiglBT15hCMVLG/8K19TK8UDQ1LQkJU29kAzJHvgv74G8BQ1FLln8Gzb1g6Jp
C1ntHvgoB0fAeF/xaZMb7klAJW7WApeJcO9+PocFIJBe8q1DmTNfGeZ1tbgCzc2bXCzzjAyR
33PUJfzc0P1PdpiRhyr6naf75BePcwku/jZe10bi4IInRUE+YojCLKimfiaJ8k85Q/eYLBpo
IHUJZJ/A8X5F1ebWzcivpPcFy1aPEQ3PMghbflQ/LbdDc6hLXocjkkja4Q5Ngkv2wKnaA3Dq
lanrnp8LvDA96MPcOfQAo6hWaEZ8Aq2fN+B+97W66WHO9MknR0VFdNVXUNSpfVhB62nZDQys
E3H2H8arRuYatnCSX5z1x1+JIrfYN68rfzsX7lk9LteLoOrTiRQ1LVc5XoMAUCKWCQLKM45R
62EfzaSeGVvj97V+vfHucdvxiitdUncPDqX9VqD18OVOHYsXVmSPt859hR6LSb5M9kCyB06V
HihZXH87L4rkTqDI1PwgfOZAIKqVfkCOTDH0B92B5ic+nv2lo2wiLArfuc3HRsxysSFf10yr
wijlSbNeKmKCl4MN6iGcqpIe8B3ZzJZPbeuctHh+9UgxNXWNrgQS4rNT3WBw1QbfJAvgLvcH
VNGixfVfl0TxpxozPqyemnt757KOx3MSSR+PXk6WkeyBU7AHCpfUThcNfg4sXUfoOOfQySbA
NYDJbNVU/V2dqb+AcM7DFKWvLzVl5fodo1vZg6RS0a46N7lCNrU8QAG7Z794sU9orpWNvk8H
Wg7exX59ZxerwsLK2jtk0fUkHJTFXWWyRoWBVn1Lq/eSojM2H/p069DsrPSUpYwXr2aKdsH/
t3cuIVFFYRw/555774zjNCqmi4TUaBFoglFGUdHSTcvATYu2ThlC0LbHplWgFemylVi0q02r
JHsIafmAkF6SUMIsVEZz5s499/Q/dxwQUUm8M83oNzDcyzy+c85v4D+H73yP0StNI/9sLOAP
Bgo+4LmROSJABIqAQOuDiXPMNJ8ZnO/fQcLmhivRh5U6S0XLsX/lhoPTuhnsgr8iumIWUj7l
cctZSfKB6W9DUeyc/UYQZ5/8rpldTiVnLjemELMfTtQwJFNV1UsVno8Kbxg5040bDrjmxezY
OriOvU5J1ZVOJL+X10Q67XCkG6UYalGO4N7SvLw5feNILqlmzbcLd0siXTjWNBIRKFkCush/
KlIxiOiHdkQ+oFurltR8PlBMYLW0gC6n47oZbKzZPMohJBBZ4eDarCOmoe7JbPigFltfcP0d
uu+m2WR6fhQLFw7iUKakm76eVqGJiJC3sXXvNK2Qrm0+aWdUx0hX08ax3pvYzdfLJNL5Ikt2
icAuJNDSM94sbKtfCHEaLpD/sEJIllatbf5JaGHmBrqBey7KCKu+pYzsK0OmoC2sOMS5EjZt
lFaYQ+eZS4ZwhraqzljoRZNIF5o4jUcEdgGB448mzyvDuoMgiTOoAVLUK4K/2/E8NQwBfouj
S2FYdh0OBy/ivsx33xj8s3LdnrF4S38xLoREuhh/FZoTESgRAi0Pxy8I03oKwQsF7a8ODIFi
KPzF0sIM7UO8tA7AY9y0mYTfG1Em8an40ZeBjZUHQyTSeYBKJonAXiJw6O6HioqqcqRJs6tw
KhzQO+sgE2KCYKlrkmuPNYrsJpjkj13PGUDLtrEgbOfbBol0vgmTfSKwhwj4pWw9dk1Y4RPY
WVdni+MDwDZ9yDtGpk8bMSYSUyQSaRYyMjWqXHkfNbWf79h2gQ2QSBcYOA1HBPYCgZO9X2J/
+Eq9Jcx2ZBh2QDOP6Uw+/fAbRgQt2hjA8GOvsVtGmjfMT+JuMO25L8Km/IGDwMVS5U4iXaq/
HM2bCJQQgcO972NlZqyNM9mGeOtWCGqD4EL3JkTXWRnN7rThkNA7YF+V1kvTaiA11NcPvcPa
IcvLaAuzgIpOc1K5P+Fr/ojU8zGWZm8+dbculBCeLae6nsSWH6Y3iQARIAKBEECzCnaL8Yb6
V3Z5orbSiMo6U6oGzxAHlaliQhnVHvQ4Nxb3PBTmx5PzXxklZ9hyZjZmuovvuk9lGwzkshNz
X6ArESACRIAIEAEiQASIABEgAkSACBABIkAEiAARIAJEgAgQASKwbQJ/AQb4me4AfccBAAAA
AElFTkSuQmCC'
]

{ #category : #desktop }
PolymorphSystemSettings class >> pharoLogoForm [
	^ Form fromBinaryStream: self pharoLogoContents base64Decoded readStream
]

{ #category : #desktop }
PolymorphSystemSettings class >> setDesktopLogoWith: aMorph [
	self desktopLogo ifNotNil: [ self desktopLogo delete ].
	self desktopLogo: aMorph.
	self desktopLogo
		ifNotNil: [ :logo | 
			logo
				beSticky;
				lock.
			"The logo image should appear just below the menu bar"
			logo position: 10 @ (self currentWorld menubar height + 10).
			self currentWorld backgroundMorph
				ifNil: [ self currentWorld addMorphBack: logo ]
				ifNotNil: [ self currentWorld addMorph: logo inFrontOf: self currentWorld backgroundMorph ] ]
]

{ #category : #desktop }
PolymorphSystemSettings class >> showDesktopLogo [
	^ ShowDesktopLogo ifNil: [ShowDesktopLogo := true]
]

{ #category : #desktop }
PolymorphSystemSettings class >> showDesktopLogo: aBoolean [
	ShowDesktopLogo = aBoolean ifTrue: [^ self].
	ShowDesktopLogo := aBoolean.
	self desktopLogoChanged
]

{ #category : #sound }
PolymorphSystemSettings class >> soundSettingsOn: aBuilder [
	(aBuilder setting: #soundEnabled)
		label: 'Sound'; 
		target: SoundSystem;
		default: false;
		noOrdering;
		with: [
			(aBuilder setting: #useThemeSounds)
				label: 'Use theme sounds';
				target: SoundTheme; 
				default: true;
				with: [
					(aBuilder pickOne: #soundThemeClass)
						label: 'Sound theme' ;
						target: self;
						domainValues: self soundThemeClassChoices]]
]

{ #category : #sound }
PolymorphSystemSettings class >> soundThemeClass [
	^ SoundTheme current class

]

{ #category : #sound }
PolymorphSystemSettings class >> soundThemeClass: aSoundThemeClass [
	aSoundThemeClass ifNil: [^ self].
	self soundThemeClass ~= aSoundThemeClass
		ifTrue: [aSoundThemeClass beCurrent]
]

{ #category : #sound }
PolymorphSystemSettings class >> soundThemeClassChoices [
	^ SoundTheme allThemeClasses collect: [:c | c themeName -> c]
]

{ #category : #morphic }
PolymorphSystemSettings class >> uiThemeClass [
	^ UITheme current class

]

{ #category : #morphic }
PolymorphSystemSettings class >> uiThemeClass: aUIThemeClass [
	| themeClass |
	themeClass := aUIThemeClass 
		ifNil: [ UITheme standardThemeClass ]. 
	 themeClass beCurrent.
]

{ #category : #morphic }
PolymorphSystemSettings class >> uiThemeClassChoices [
	^ UITheme allThemeClasses collect: [:c | c themeName -> c]
]

{ #category : #desktop }
PolymorphSystemSettings class >> useDesktopGradientFill [
	^ UseDesktopGradientFill ifNil: [UseDesktopGradientFill := false]
]

{ #category : #desktop }
PolymorphSystemSettings class >> useDesktopGradientFill: aBoolean [ 
	UseDesktopGradientFill := aBoolean.
	self desktopBackgroundChanged
]

{ #category : #morphic }
PolymorphSystemSettings class >> windowPositionStrategySettingsOn: aBuilder [
	<systemsettings>
	(aBuilder pickOne: #usedStrategy) 
		label: 'Window position strategy';
		parent: #windows;
		target: RealEstateAgent;
		default: #cascadeFor:initialExtent:world:;
		domainValues: {'Reverse Stagger' -> #staggerFor:initialExtent:world:. 'Cascade' -> #cascadeFor:initialExtent:world:. 'Standard' -> #standardFor:initialExtent:world:};
		description: 'If Reversed Stagger, windows are placed in free space,
if Cascade, windows are placed in cascade based on current active window or based on cursor position.' .
]
