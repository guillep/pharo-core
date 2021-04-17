"
I implement an heuristic for global variables accessible in the completion environment.

See my superclass for details.
"
Class {
	#name : #CoGlobalVariablesHeuristic,
	#superclass : #CoASTNodeFetcherHeuristic,
	#category : #'HeuristicCompletion-Model-Heuristics'
}

{ #category : #requests }
CoGlobalVariablesHeuristic >> appliesForNode: aNode inContext: aContext [

	^ aNode isVariable
]

{ #category : #requests }
CoGlobalVariablesHeuristic >> buildFetcherFor: aNode inContext: completionContext [

	^ CoGlobalVariableFetcher new
			astNode: aNode;
			completionEnvironment: completionContext completionEnvironment;
			yourself
]
