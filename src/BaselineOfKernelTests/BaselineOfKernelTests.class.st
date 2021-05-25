Class {
	#name : #BaselineOfKernelTests,
	#superclass : #BaselineOf,
	#category : #BaselineOfKernelTests
}

{ #category : #baselines }
BaselineOfKernelTests >> baseline: spec [
	<baseline>
	spec for: #'common' do: [
		spec 
			package: 	'CodeImport-Tests'	; 

			package: 	'Collections-Abstract-Tests';					
			package: 	'Collections-Atomic-Tests';
			package:	'Collections-Sequenceable-Tests';
			package: 	'Collections-Stack-Tests';	
			package: 	'Collections-Streams-Tests';		
			package: 	'Collections-Strings-Tests';	
			package: 	'Collections-Support-Tests';								
			package: 	'Collections-Unordered-Tests';
			package: 	'Collections-Weak-Tests' with: [ spec requires: #('Collections-Unordered-Tests') ];					
			package: 	'Collections-Tests' with: [ spec requires: #('Collections-Abstract-Tests' 'Collections-Atomic-Tests' 'Collections-Sequenceable-Tests'  
					   'Collections-Streams-Tests' 'Collections-Strings-Tests' 'Collections-Support-Tests' 'Collections-Stack-Tests' 'Collections-Weak-Tests') ];
			package: 	'Kernel-Tests'; 
			package: 	'Kernel-Tests-Extended' ;
			package: 	'Kernel-Tests-WithCompiler';
			package: 	'Announcements-Core-Tests';
			package: 	'Compression-Tests'; 
			package: 	'FileSystem-Tests-Core' with: [ spec requires: #('Collections-Tests') ];
			package: 	'FileSystem-Tests-Disk';
			package: 	'FileSystem-Tests-Attributes';
			package: 	'Files-Tests' ;
			package: 	'Jobs-Tests' ;
			package: 	'OpalCompiler-Tests'; 
			package: 	'Random-Tests';
			package: 	'Ring-Definitions-Tests-Core';
			package: 	'Ring-Definitions-Tests-Containers'; 
			package: 	'System-Object Events-Tests';
			package: 	'System-OSEnvironments-Tests';
			package: 	'Zinc-Character-Encoding-Tests' ;
			package: 	'System-Platforms-Tests';
			package: 	'Text-Tests';
			package: 'Debugging-Core-Tests' ]
]
