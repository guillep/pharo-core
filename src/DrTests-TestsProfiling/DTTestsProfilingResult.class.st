"
I build a tree with DTTestCaseProfilingData objects listed in groups: 
-Errors
-Failures
-Skipped tests
-Passed test
Each group has in adition the total execution time for each test.
I am used in DrTestsUI to show the results in a orderly manner.
"
Class {
	#name : #DTTestsProfilingResult,
	#superclass : #DTPluginResult,
	#instVars : [
		'testsResult'
	],
	#category : #'DrTests-TestsProfiling'
}

{ #category : #accessing }
DTTestsProfilingResult >> buildTreeForUI [
	<dtTestsProfilingResultTreeNamed: 'Grouped by type of result' order: 1>
	^ DTTreeNode new
		subResults:
			{(self buildTreeNode
				name: 'Errors';
				subResults:
					((self testResults
						select:
							[ :testCaseToTimeTaken | testCaseToTimeTaken testResult errors isNotEmpty ])
						collect: [ :testCaseToTimeTaken | 
							DTTreeLeafNode new
								content: testCaseToTimeTaken;
								yourself ]);
				yourself).
			(self buildTreeNode
				name: 'Failures';
				subResults:
					((self testResults
						select:
							[ :testCaseToTimeTaken | testCaseToTimeTaken testResult failures isNotEmpty ])
						collect: [ :testCaseToTimeTaken | 
							DTTreeLeafNode new
								content: testCaseToTimeTaken;
								yourself ]);
				yourself).
			(self buildTreeNode
				name: 'Skipped tests';
				subResults:
					((self testResults
						select:
							[ :testCaseToTimeTaken | testCaseToTimeTaken testResult skipped isNotEmpty ])
						collect: [ :testCaseToTimeTaken | 
							DTTreeLeafNode new
								content: testCaseToTimeTaken;
								yourself ]);
				yourself).
			(self buildTreeNode
				name: 'Passed tests';
				subResults:
					((self testResults
						select:
							[ :testProfilerResult | testProfilerResult testResult passed isNotEmpty ])
						collect: [ :testCaseToTimeTaken | 
							DTTreeLeafNode new
								content: testCaseToTimeTaken;
								yourself ]);
				yourself)};
		yourself
]

{ #category : #accessing }
DTTestsProfilingResult >> buildTreeGroupedByClass [
	<dtTestsProfilingResultTreeNamed: 'Grouped by class' order: 2>
	^ self buildTreeNode
		subResults: ((self testResults groupedBy: [ :d | d testCase class ]) associations collect: [ :assoc |
			self buildTreeNode
					name: assoc key name;
					subResults: (assoc value collect: [ :t | DTTreeLeafNode content: t ]);
					yourself ]);
		yourself
]

{ #category : #private }
DTTestsProfilingResult >> buildTreeNode [
	"Returns a node with the sub-results aggregator initialized in a way that it sum the durations of sub results."

	^ DTTreeNode new
		subResultsAggregator: [ :subResults | 
			subResults
				inject: 0 milliSecond
				into: [ :totalDuration :dtTreeLeaf | totalDuration + dtTreeLeaf content duration ] ];
		yourself
]

{ #category : #accessing }
DTTestsProfilingResult >> testResults [
	^ testsResult
]

{ #category : #accessing }
DTTestsProfilingResult >> testResults: anObject [
	testsResult := anObject
]
