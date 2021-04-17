"
I represent the project which is managed by concrete package system.
Calypso provides infrastructure for various package management systems. 
Each system should implement subclass of ClyPackageManager which returns my instances created over projects in that system:

	ClyManagerProject for: aConcreteSystemProject named: aString managedBy: aPackageManager

Currently there is only Cargo implementation. But in future we can also provide Metacello support.

So I was introduced for project mode in the browser.
 
Internal Representation and Key Implementation Points.

    Instance Variables
	manager:		<ClyPackageManager>
	name:		<String>
	project:		<Object>
"
Class {
	#name : #ClyManagedProject,
	#superclass : #ClyProjectChildItem,
	#category : #'Calypso-SystemQueries-Domain'
}

{ #category : #testing }
ClyManagedProject class >> checkCalypsoItem: aProject isSameAs: aProject2 [
	^(super checkCalypsoItem: aProject isSameAs: aProject2)
		or: [ aProject = aProject2 ]
]

{ #category : #sorting }
ClyManagedProject class >> defaultSortFunctionForCalypso [
	^ClySortByNameFunction ascending
]

{ #category : #'instance creation' }
ClyManagedProject class >> for: aProject named: aString managedBy: aPackageManager [
	^self new 
		name: aString;
		manager: aPackageManager;
		project: aProject
]

{ #category : #queries }
ClyManagedProject class >> prepareClassQueriesFrom: projects in: aNavigationEnvironment [ 
	^{ClyAllClassesQuery from: ClyProjectScope ofAll: projects in: aNavigationEnvironment }
]
