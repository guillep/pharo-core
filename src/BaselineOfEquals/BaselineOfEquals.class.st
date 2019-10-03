Class {
	#name : #BaselineOfEquals,
	#superclass : #BaselineOf,
	#category : #BaselineOfEquals
}

{ #category : #baselines }
BaselineOfEquals >> baseline: spec [
	<baseline>

	spec for: #'common' do: [
		spec 
			package: #Equals;
			package: #'Equals-Tests' with: [ spec requires: #(Equals) ] ].

]
