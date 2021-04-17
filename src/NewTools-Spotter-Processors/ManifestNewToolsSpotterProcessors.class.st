"
I store metadata for this package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : #ManifestNewToolsSpotterProcessors,
	#superclass : #PackageManifest,
	#category : #'NewTools-Spotter-Processors-Manifest'
}

{ #category : #'code-critics' }
ManifestNewToolsSpotterProcessors class >> ruleReClassNotReferencedRuleV1FalsePositive [
	^ #(#(#(#RGPackageDefinition #(#'NewTools-Spotter-Processors')) #'2020-03-26T18:37:51.234976+01:00') )
]
