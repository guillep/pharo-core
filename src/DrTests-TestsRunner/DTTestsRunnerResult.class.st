"
I build a tree with the testsResult listed in groups: 
-Errors
-Failures
-Skipped tests
-Passed test
I am used in DrTestsUI to show the results in a orderly manner.
"
Class {
	#name : #DTTestsRunnerResult,
	#superclass : #DTPluginResult,
	#instVars : [
		'testsResult'
	],
	#category : #'DrTests-TestsRunner-Base'
}

{ #category : #accessing }
DTTestsRunnerResult >> backgroundColor [
	testsResult errors ifNotEmpty: [ ^ DTErrorResultType backgroundColor ].
	testsResult failures ifNotEmpty: [ ^ DTFailResultType backgroundColor  ].
	^ DTPassResultType backgroundColor
]

{ #category : #'tree building' }
DTTestsRunnerResult >> buildLeavesFrom: aCollection type: testResultType [
	^ aCollection collect: [ :t | DTTestLeafNode content: t type: testResultType ]
]

{ #category : #'tree building' }
DTTestsRunnerResult >> buildNodeGroupedByTypeAndClass: anOrderedColletion type: testResultType [
	^ DTTreeNode new
			name: testResultType pluralName;
			subResults: ((anOrderedColletion groupedBy: #class) associations collect: [ :assoc |
				DTTreeNode new
					name: assoc key name;
					browseBlock: [ assoc key drTestsBrowse ];
					subResults: (self buildLeavesFrom: assoc value type: testResultType);
					yourself ]);
			yourself
]

{ #category : #'tree building' }
DTTestsRunnerResult >> buildNodeGroupedByTypeClassAndProtocol: anOrderedColletion type: testResultType [
	^ DTTreeNode new
			name: testResultType pluralName;
			subResults: ((anOrderedColletion groupedBy: #class) associations collect: [ :assoc |
				DTTreeNode new
					name: assoc key name;
					subResults: ((assoc value groupedBy: [ :testCase | (testCase class lookupSelector: testCase selector) protocol ]) associations collect: [ :protocolToTest |
						DTTreeNode new
							name: protocolToTest key;
							subResults: (self buildLeavesFrom: protocolToTest value type: testResultType) ]);
					yourself ]);
			yourself
]

{ #category : #accessing }
DTTestsRunnerResult >> buildTreeForUI [
	<dtTestRunnerResultTreeNamed: 'Grouped by type of result' order: 1>
	^ DTTreeNode new
		subResults:
			{DTTreeNode new
				name: DTTestResultType error pluralName;
				subResults: (self buildLeavesFrom: self testResults errors asOrderedCollection type: DTTestResultType error);
				yourself.
			DTTreeNode new
				name: DTTestResultType fail pluralName;
				subResults: (self buildLeavesFrom: self testResults failures asOrderedCollection type: DTTestResultType fail).
			DTTreeNode new
				name: DTTestResultType skipped pluralName;
				subResults: (self buildLeavesFrom: self testResults skipped asOrderedCollection type: DTTestResultType skipped).
			DTTreeNode new
				name: DTTestResultType pass pluralName;
				subResults: (self buildLeavesFrom: self testResults passed asOrderedCollection type: DTTestResultType pass)
		};
		yourself
]

{ #category : #accessing }
DTTestsRunnerResult >> buildTreeForUIByClasses [
	<dtTestRunnerResultTreeNamed: 'Grouped by type of result and classes' order: 2>

	| errors failures skipped passed |
	errors := self buildNodeGroupedByTypeAndClass: self testResults errors type: DTTestResultType error.
	failures := self buildNodeGroupedByTypeAndClass: self testResults failures asOrderedCollection type: DTTestResultType fail.
	skipped := self buildNodeGroupedByTypeAndClass: self testResults skipped type: DTTestResultType skipped.
	passed := self buildNodeGroupedByTypeAndClass: self testResults passed type: DTTestResultType pass.
	^ DTTreeNode new
		subResults:
			{errors.
			failures.
			skipped.
			passed};
		yourself
]

{ #category : #accessing }
DTTestsRunnerResult >> buildTreeForUIByClassesAndProtocol [
	<dtTestRunnerResultTreeNamed: 'Grouped by type of result, classes, and protocol' order: 3>

	| errors failures skipped passed |
	errors := self buildNodeGroupedByTypeClassAndProtocol: self testResults errors type: DTTestResultType error.
	failures := self buildNodeGroupedByTypeClassAndProtocol: self testResults failures asOrderedCollection type: DTTestResultType fail.
	skipped := self buildNodeGroupedByTypeClassAndProtocol: self testResults skipped type: DTTestResultType skipped.
	passed := self buildNodeGroupedByTypeClassAndProtocol: self testResults passed type: DTTestResultType pass.
	^ DTTreeNode new
		subResults:
			{errors.
			failures.
			skipped.
			passed};
		yourself
]

{ #category : #accessing }
DTTestsRunnerResult >> summarizeInfo [
	"Text showed in miniDrTests with info of the result "

	^ String
		streamContents: [ :s | 
			s
				print: self testResults passed size;
				<< ' passed';
				cr;
				print: self testResults failures size;
				<< ' failures';
				cr;
				print: self testResults errors size;
				<< ' errors';
				cr;
				print: self testResults skipped size;
				<< ' skipped' ]
]

{ #category : #accessing }
DTTestsRunnerResult >> testResults [
	^ testsResult
]

{ #category : #accessing }
DTTestsRunnerResult >> testResults: anObject [
	testsResult := anObject
]

{ #category : #accessing }
DTTestsRunnerResult >> textColor [
	testsResult errors ifNotEmpty: [ ^ DTErrorResultType textColor ].
	testsResult failures ifNotEmpty: [ ^ DTFailResultType textColor  ].
	^ DTPassResultType textColor
]
