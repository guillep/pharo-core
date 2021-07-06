Class {
	#name : #BaselineOfOpalCompilerPlugins,
	#superclass : #BaselineOf,
	#category : #BaselineOfOpalCompilerPlugins
}

{ #category : #baselines }
BaselineOfOpalCompilerPlugins >> baseline: spec [
	<baseline>
	spec for: #'common' do: [
		spec 
			package: 'OpalCompiler-Plugins';
			package: 'OpalCompiler-Plugins-Tests'.
			
		spec 
			group: 'core' with: #('OpalCompiler-Plugins');
			group: 'tests' with: #('OpalCompiler-Plugins-Tests');
			group: 'default' with: #('core' 'tests') ]
]
