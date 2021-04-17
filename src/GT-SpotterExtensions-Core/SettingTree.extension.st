Extension { #name : #SettingTree }

{ #category : #'*GT-SpotterExtensions-Core' }
SettingTree class >> gtExampleSettingTree [
	<gtExample>
	<label: 'Settings tree'>
	
	^ SettingTree new acceptableKeywords: SettingBrowser settingsKeywords
]
