"
I know the items to create a testSuite that will be analysed by a DrTestsPlugin.
"
Class {
	#name : #DTCommentTestConfiguration,
	#superclass : #DTPluginConfiguration,
	#category : #'DrTests-CommentsToTests-Base'
}

{ #category : #converting }
DTCommentTestConfiguration >> asTestSuite [

	| suite methods |
	suite := TestSuite named: 'Test Generated From Comments'.
	methods := self items flatCollect: [ :each | each methods ].
	methods do: [ :method | 
		method pharoDocCommentNodes do: [ :docComment | 
			suite addTest: (CommentTestCase for: docComment) ] ].
	^ suite
]
