"
This class collects simple demos for Reflectivity.

each method contains a small, self-contained demo.
"
Class {
	#name : #ReflectivityDemos,
	#superclass : #Object,
	#classVars : [
		'CachedLink'
	],
	#category : #'Reflectivity-Examples'
}

{ #category : #cleanup }
ReflectivityDemos >> cleanUp [
	<script: 'self new cleanUp'>
	CachedLink ifNotNil: [ :link | link uninstall. CachedLink := nil ]
]

{ #category : #demos }
ReflectivityDemos >> demoSelfSendLogging [
	<script: 'self new demoSelfSendLogging'>
	
	"Running this method, Open first a Transcript and then the SpDemoNotebookPresenter.	
		
	Transcript open.
	SpDemoNotebookPresenter example.
	
	To clean up, run the #cleanUp script of this class.
	
	We use option #optionCompileOnLinkInstallation because we analyse the sender context
	and do not want to have the code generation be interering.
	"
	
	| theClass |
	theClass := SpDemoNotebookPresenter.
	CachedLink := MetaLink new
		metaObject: [ :context :object | context sender receiver == object
				ifTrue: [ context crTrace ] ];
		selector: #value:value:;
		option: #(+optionCompileOnLinkInstallation);
		arguments: #(context object);
		control: #before.
		
	theClass methods do: [ :each | each ast link: CachedLink ].

]
