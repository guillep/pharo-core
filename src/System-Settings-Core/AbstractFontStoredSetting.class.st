"
I am an abstract class and my subclasses are responsible for storing information about a font object. 
"
Class {
	#name : #AbstractFontStoredSetting,
	#superclass : #AbstractStoredSetting,
	#instVars : [
		'fontClassName',
		'familyName',
		'pointSize',
		'emphasized'
	],
	#category : #'System-Settings-Core-Persistence-Ston-StoredSettings'
}

{ #category : #testing }
AbstractFontStoredSetting class >> isAbstract [

	^ self == AbstractFontStoredSetting
]

{ #category : #accessing }
AbstractFontStoredSetting >> emphasized [
	^ emphasized
]

{ #category : #accessing }
AbstractFontStoredSetting >> emphasized: anObject [
	emphasized := anObject
]

{ #category : #accessing }
AbstractFontStoredSetting >> familyName [
	^ familyName
]

{ #category : #accessing }
AbstractFontStoredSetting >> familyName: anObject [
	familyName := anObject
]

{ #category : #accessing }
AbstractFontStoredSetting >> fontClassName [
	^ fontClassName
]

{ #category : #accessing }
AbstractFontStoredSetting >> fontClassName: anObject [
	fontClassName := anObject
]

{ #category : #accessing }
AbstractFontStoredSetting >> pointSize [
	^ pointSize
]

{ #category : #accessing }
AbstractFontStoredSetting >> pointSize: anObject [
	pointSize := anObject
]
