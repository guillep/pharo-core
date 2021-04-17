"
A DrTestsUITest is a test class for testing the behavior of DrTests-CommentsToTestsTest 
"
Class {
	#name : #CommentsToTestsTest,
	#superclass : #TestCase,
	#category : #'DrTests-CommentsToTests-Tests-Base'
}

{ #category : #tests }
CommentsToTestsTest >> testErrorComment [
	"(1+3)+6/0>>>4"
	
	| docComment commentTestCase |

	docComment := thisContext method ast pharoDocCommentNodes first.
	commentTestCase := CommentTestCase for: docComment.	
	self assert: commentTestCase hasError
]

{ #category : #tests }
CommentsToTestsTest >> testSimpleComment [
	"(1+3)>>>4"
	
	| docComment commentTestCase |

	docComment := thisContext method ast pharoDocCommentNodes first.
	commentTestCase := CommentTestCase for: docComment.
		
	self deny: commentTestCase hasError.	
	self
		assert: commentTestCase currentValue
		equals: commentTestCase expectedValue
]
