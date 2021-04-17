Class {
	#name : #BaselineOfCalypso,
	#superclass : #BaselineOf,
	#category : #BaselineOfCalypso
}

{ #category : #baselines }
BaselineOfCalypso >> baseline: spec [
   <baseline>

	| repository | 
	repository := self packageRepositoryURL.

	spec for: #'common' do: [
		spec 
			baseline: 'ClassAnnotation' with: [
				spec
					repository: repository;
					loads: 'Core' ];
			project: 'ClassAnnotationTests' copyFrom: 'ClassAnnotation' with: [
				spec loads: 'Tests'];
			baseline: 'Commander' with: [
				spec repository: repository ];
			baseline: 'SystemCommands' with: [
				spec repository: repository ].

		spec 
			package: #'Calypso-NavigationModel';
			package: #'Calypso-NavigationModel-Tests' with: [
				spec requires: #(#'Calypso-NavigationModel' )];
			package: #'Calypso-SystemQueries' with: [
				spec requires: #(#'Calypso-NavigationModel' #'ClassAnnotation' ). ];
			package: #'Calypso-SystemQueries-Tests' with: [
				spec requires: #(#'Calypso-NavigationModel-Tests' #'ClassAnnotationTests' #'Calypso-SystemQueries' #'Calypso-SystemQueries-Tests-PWithSingleClass' #'Calypso-SystemQueries-Tests-PExtendedByP1' #'Calypso-SystemQueries-Tests-P1WithHierarchy' #'Calypso-SystemQueries-Tests-P2WithSubclassFromP1' #'Calypso-SystemQueries-Tests-P3WithSubclassFromP2' #'Calypso-SystemQueries-Tests-PExtendedByP5' #'Calypso-SystemQueries-Tests-P5WithTags' #'Calypso-SystemPlugins-Traits-Queries-Tests-PWithTraits' #'Calypso-SystemPlugins-Traits-Queries-Tests-PExtendingTrait' ). ];
			package: #'Calypso-SystemQueries-Tests-P1WithHierarchy' with: [
				spec requires: #(#'Calypso-SystemQueries-Tests-PExtendedByP1' ). ];
			package: #'Calypso-SystemQueries-Tests-P2WithSubclassFromP1' with: [
				spec requires: #(#'Calypso-SystemQueries-Tests-P1WithHierarchy' ). ];
			package: #'Calypso-SystemQueries-Tests-P3WithSubclassFromP2' with: [
				spec requires: #(#'Calypso-SystemQueries-Tests-P2WithSubclassFromP1' ). ];
			package: #'Calypso-SystemQueries-Tests-P5WithTags' with: [
				spec requires: #(#'Calypso-SystemQueries-Tests-PExtendedByP5' ). ];
			package: #'Calypso-SystemQueries-Tests-PExtendedByP1' with: [
				spec requires: #(#'Calypso-SystemQueries-Tests-PWithSingleClass' ). ];
			package: #'Calypso-SystemQueries-Tests-PExtendedByP5';
			package: #'Calypso-SystemQueries-Tests-PWithSingleClass';
			
			package: #'Calypso-SystemPlugins-Traits-Queries' with: [
				spec requires: #(#'Calypso-SystemQueries' ). ];
			package: #'Calypso-SystemPlugins-Traits-Queries-Tests-PWithTraits';
			package: #'Calypso-SystemPlugins-Traits-Queries-Tests-PExtendingTrait' with: [
				spec requires: #(#'Calypso-SystemPlugins-Traits-Queries-Tests-PWithTraits' )];			
			package: 'Calypso-SystemPlugins-Traits-Queries-Tests' with: [
				spec requires: #(#'Calypso-SystemPlugins-Traits-Queries' #'Calypso-SystemQueries-Tests' 'Calypso-SystemPlugins-Traits-Queries-Tests-PWithTraits' 'Calypso-SystemPlugins-Traits-Queries-Tests-PExtendingTrait') ];
			package: #'Calypso-SystemPlugins-Traits-Browser' with: [
				spec requires: #(#'Calypso-SystemTools-FullBrowser' #'Calypso-SystemPlugins-Traits-Queries' ). ];
			
			
			package: #'Calypso-ProcessQueries' with: [
				spec requires: #(#'Calypso-SystemQueries')];
			package: #'Calypso-ProcessQueries-Tests' with: [
				spec requires: #(#'Calypso-ProcessQueries')];
			
			package: #'Calypso-SystemPlugins-Critic-Browser' with: [
				spec requires: #(#'Calypso-SystemTools-FullBrowser' #'Calypso-SystemPlugins-Critic-Queries' ). ];
			package: #'Calypso-SystemPlugins-Critic-Queries' with: [
				spec requires: #(#'Calypso-SystemQueries' ). ];
			package: 'Calypso-SystemPlugins-Critic-Queries-Tests' with: [
				spec requires: #(#'Calypso-SystemPlugins-Critic-Queries' #'Calypso-SystemQueries-Tests' ). ];
			
			package: #'Calypso-SystemPlugins-Deprecation-Browser' with: [
				spec requires: #(#'Calypso-SystemPlugins-Deprecation-Queries' #'Calypso-SystemTools-FullBrowser' ). ];
			package: #'Calypso-SystemPlugins-Deprecation-Queries' with: [
				spec requires: #(#'Calypso-SystemQueries' ). ];
			package: #'Calypso-SystemPlugins-Deprecation-Queries-Tests' with: [
				spec requires: #(#'Calypso-SystemPlugins-Deprecation-Queries' ). ];
			
			package: #'Calypso-SystemPlugins-FileOut-Browser' with: [
				spec requires: #(#'Calypso-SystemPlugins-FileOut-Queries' #'Calypso-SystemTools-Core' ). ];
			package: #'Calypso-SystemPlugins-FileOut-Queries';
			
			package: 'Calypso-SystemPlugins-InheritanceAnalysis-Browser' with: [
				spec requires: #('Calypso-SystemPlugins-InheritanceAnalysis-Queries' #'Calypso-SystemTools-FullBrowser' ). ];
			package: 'Calypso-SystemPlugins-InheritanceAnalysis-Queries' with: [
				spec requires: #(#'Calypso-SystemQueries' ). ];
			package: 'Calypso-SystemPlugins-InheritanceAnalysis-Queries-Tests' with: [
				spec requires: #('Calypso-SystemPlugins-InheritanceAnalysis-Queries' ). ];
			
			package: #'Calypso-SystemPlugins-MethodDiffTool' with: [
				spec requires: #(#'Calypso-SystemTools-Core' ). ];
			
			package: #'Calypso-SystemPlugins-Monticello-Browser' with: [
				spec requires: #(#'Calypso-SystemPlugins-Monticello-Queries' #'Calypso-SystemTools-FullBrowser' ). ];
			package: #'Calypso-SystemPlugins-Monticello-Queries' with: [
				spec requires: #(#'Calypso-SystemQueries' ). ];
				
			package: #'Calypso-SystemPlugins-Reflectivity-Browser' with: [
				spec requires: #(#'Calypso-SystemPlugins-Reflectivity-Queries' #'Calypso-SystemTools-FullBrowser' #'Calypso-SystemTools-QueryBrowser' ) ];
			package: #'Calypso-SystemPlugins-Reflectivity-Browser-Tests' with: [
				spec requires: #(#'Calypso-SystemPlugins-Reflectivity-Browser' ) ];
			package: #'Calypso-SystemPlugins-Reflectivity-Queries' with: [
				spec requires: #(#'Calypso-SystemQueries' ) ];
			package: #'Calypso-SystemPlugins-Reflectivity-Queries-Tests' with: [
				spec requires: #(#'Calypso-SystemQueries-Tests' #'Calypso-SystemPlugins-Reflectivity-Queries' ) ];
			
			package: #'Calypso-SystemPlugins-SUnit-Browser' with: [
				spec requires: #(#'Calypso-SystemPlugins-SUnit-Queries' #'Calypso-SystemTools-FullBrowser' ) ];
			package: #'Calypso-SystemPlugins-SUnit-Queries' with: [
				spec requires: #(#'Calypso-SystemQueries' ) ];
			package: #'Calypso-SystemPlugins-SUnit-Queries-Tests' with: [
				spec requires: #(#'Calypso-SystemQueries-Tests' #'Calypso-SystemPlugins-SUnit-Queries' ) ];
			
			package: #'Calypso-SystemPlugins-Undeclared-Queries' with: [
				spec requires: #(#'Calypso-SystemQueries' ). ];
			package: #'Calypso-SystemPlugins-Undeclared-Queries-Tests' with: [
				spec requires: #(#'Calypso-SystemQueries-Tests' #'Calypso-SystemPlugins-Undeclared-Queries' ). ];
			package: #'Calypso-SystemPlugins-Undeclared-Browser' with: [
				spec requires: #(#'Calypso-SystemPlugins-Undeclared-Queries' #'Calypso-SystemTools-Core' ). ];
			
			package: #'Calypso-SystemPlugins-FFI-Queries' with: [
				spec requires: #(#'Calypso-SystemQueries' ). ];
			package: #'Calypso-SystemPlugins-FFI-Queries-Tests' with: [
				spec requires: #(#'Calypso-SystemQueries-Tests' #'Calypso-SystemPlugins-FFI-Queries' ). ];
			package: #'Calypso-SystemPlugins-FFI-Browser' with: [
				spec requires: #(#'Calypso-SystemPlugins-FFI-Queries' #'Calypso-SystemTools-Core' ) ];

			package: #'Calypso-SystemPlugins-Flags-Queries' with: [
				spec requires: #(#'Calypso-SystemQueries' ). ];
			package: #'Calypso-SystemPlugins-Flags-Queries-Tests' with: [
				spec requires: #(#'Calypso-SystemQueries-Tests' #'Calypso-SystemPlugins-Flags-Queries' ) ];
			package: #'Calypso-SystemPlugins-Flags-Browser' with: [
				spec requires: #(#'Calypso-SystemPlugins-Flags-Queries' #'Calypso-SystemTools-Core' ) ];
		
			package: #'Calypso-SystemPlugins-ClassScripts-Queries' with: [
				spec requires: #(#'Calypso-SystemQueries' ). ];
			package: #'Calypso-SystemPlugins-ClassScripts-Queries-Tests' with: [
				spec requires: #(#'Calypso-SystemQueries-Tests' #'Calypso-SystemPlugins-ClassScripts-Queries' ) ];
			package: #'Calypso-SystemPlugins-ClassScripts-Browser' with: [
				spec requires: #(#'Calypso-SystemPlugins-ClassScripts-Queries' #'Calypso-SystemTools-Core' ) ];
			
			package: #'Calypso-SystemPlugins-DependencyAnalyser-Browser' with: [
				spec requires: #(#'Calypso-SystemTools-Core' ) ];			
			
			package: #'Calypso-Browser' with: [
				spec requires: #(#'Calypso-NavigationModel' 'Commander' ). ];

			package: #'Calypso-SystemTools-Core' with: [
				spec requires: #(#'Calypso-SystemQueries' #'Calypso-Browser' 'SystemCommands' ). ];
			package: #'Calypso-SystemTools-Core-Tests' with: [
				spec requires: #(#'Calypso-SystemTools-Core' ). ];
			 
			package: #'Calypso-SystemTools-FullBrowser' with: [
				spec requires: #(#'Calypso-SystemTools-Core' ). ];
			package: #'Calypso-SystemTools-FullBrowser-Tests' with: [
				spec requires: #(#'Calypso-SystemTools-FullBrowser' ). ];
			
			package: #'Calypso-SystemTools-QueryBrowser' with: [
				spec requires: #(#'Calypso-SystemTools-FullBrowser' ). ];
			package: #'Calypso-SystemTools-QueryBrowser-Tests' with: [
				spec requires: #(#'Calypso-SystemTools-QueryBrowser' #'Calypso-SystemTools-FullBrowser-Tests' ). ];		
			
			package: #'Calypso-SystemTools-OldToolCompatibillity' with: [
				spec requires: #(#'Calypso-SystemTools-QueryBrowser' ). ];

			package: #'Calypso-SystemTools-Debugger' with: [
				spec requires: #(#'Calypso-ProcessQueries' #'Calypso-SystemTools-QueryBrowser' ). ];
			
			package: #'Calypso-SystemTools-ProcessBrowser' with: [
				spec requires: #(#'Calypso-ProcessQueries' #'Calypso-SystemTools-Debugger' ). ].


		spec 
			group: 'CoreEnvironment' with: #(#'Calypso-NavigationModel');
			group: 'CoreBrowser' with: #(#'Calypso-Browser');
			
			group: 'MinimalEnvironment' with: #(#'Calypso-SystemQueries' #'Calypso-SystemPlugins-Traits-Queries' #'Calypso-SystemPlugins-Monticello-Queries' #'Calypso-SystemPlugins-SUnit-Queries' 'Calypso-SystemPlugins-InheritanceAnalysis-Queries' #'Calypso-SystemPlugins-FileOut-Queries' #'Calypso-SystemPlugins-Deprecation-Queries' #'Calypso-SystemPlugins-Undeclared-Queries' #'Calypso-SystemPlugins-FFI-Queries' #'Calypso-SystemPlugins-Flags-Queries' #'Calypso-SystemPlugins-ClassScripts-Queries');			
			group: 'FullEnvironment' with: #('MinimalEnvironment' #'Calypso-SystemPlugins-Reflectivity-Queries' #'Calypso-SystemPlugins-Critic-Queries' );
			
			group: 'SystemBrowser' with: #(#'Calypso-SystemTools-FullBrowser' #'Calypso-SystemTools-QueryBrowser' #'Calypso-SystemPlugins-Traits-Browser'  #'Calypso-SystemPlugins-SUnit-Browser' #'Calypso-SystemTools-OldToolCompatibillity' #'Calypso-SystemPlugins-Critic-Browser' 'Calypso-SystemPlugins-InheritanceAnalysis-Browser' #'Calypso-SystemPlugins-FileOut-Browser' #'Calypso-SystemPlugins-MethodDiffTool' #'Calypso-SystemPlugins-Deprecation-Browser' #'Calypso-SystemPlugins-Reflectivity-Browser' #'Calypso-SystemPlugins-Undeclared-Browser' #'Calypso-SystemPlugins-FFI-Browser' #'Calypso-SystemPlugins-Flags-Browser' #'Calypso-SystemPlugins-ClassScripts-Browser' #'Calypso-SystemPlugins-DependencyAnalyser-Browser');

			group: 'IcebergSupport' with: #(#'Calypso-SystemPlugins-Monticello-Browser');
			
			group: 'MinimalEnvironmentTests' with: #(#'Calypso-NavigationModel-Tests' #'Calypso-SystemQueries-Tests' #'Calypso-SystemPlugins-Traits-Queries-Tests' 'Calypso-SystemPlugins-InheritanceAnalysis-Queries-Tests' #'Calypso-SystemPlugins-Deprecation-Queries-Tests' #'Calypso-SystemPlugins-SUnit-Queries-Tests' #'Calypso-SystemPlugins-Undeclared-Queries-Tests' #'Calypso-SystemPlugins-FFI-Queries-Tests' #'Calypso-SystemPlugins-Flags-Queries-Tests' #'Calypso-SystemPlugins-ClassScripts-Queries-Tests');
						
			group: 'Tests' with: #('MinimalEnvironmentTests' #'Calypso-SystemTools-FullBrowser-Tests' #'Calypso-SystemTools-QueryBrowser-Tests' #'Calypso-SystemPlugins-Reflectivity-Queries-Tests' #'Calypso-SystemPlugins-Reflectivity-Browser-Tests' #'Calypso-SystemPlugins-Critic-Queries-Tests');
			
			group: 'ProcessEnvironment' with: #(#'Calypso-ProcessQueries');
			group: 'ProcessBrowser' with: #(#'Calypso-SystemTools-ProcessBrowser');
			group: 'ProcessBrowserTests' with: #(#'Calypso-ProcessQueries-Tests');
			
			group: 'default' with: #('FullEnvironment' 'SystemBrowser' 'Tests' 'ProcessEnvironment' 'ProcessBrowser' 'ProcessBrowserTests' ) ].

]
