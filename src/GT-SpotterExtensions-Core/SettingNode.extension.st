Extension { #name : #SettingNode }

{ #category : #'*GT-SpotterExtensions-Core' }
SettingNode class >> gtExampleSettingNode [
	<gtExample>
	<label: 'Settings node'>
	
	^ SettingTree gtExampleSettingTree nodeList anyOne
]

{ #category : #'*GT-SpotterExtensions-Core' }
SettingNode >> spotterLabel [

	| label |
	label := self settingDeclaration label.
	^ self parentNode ifNil: [ label ] ifNotNil: [ self parentNode spotterLabel , '/' , label ]
]

{ #category : #'*GT-SpotterExtensions-Core' }
SettingNode >> spotterPreviewIn: composite [
	<spotterPreview: 0>
	
	composite custom: (
				(self settingDeclaration inputWidget asBrick)
						hSpaceFill;
						vShrinkWrap;
						vAlign: #center;
						yourself)
]
