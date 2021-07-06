"
This is the unit test for the class Time.


"
Class {
	#name : #TimeTest,
	#superclass : #ClassTestCase,
	#instVars : [
		'time',
		'aTime',
		'localTimeZoneToRestore'
	],
	#category : #'Kernel-Tests-Chronology'
}

{ #category : #coverage }
TimeTest >> classToBeTested [

	^ self timeClass
]

{ #category : #coverage }
TimeTest >> selectorsToBeIgnored [

	 | deprecated private special primitives timing benchmarks |

	deprecated := #().
	private := #( #print24:on: #print24:showSeconds:on: ).
	special := #( #< #= #new #printOn: #storeOn: ).
	primitives := #( #primMillisecondClock #primSecondsClock #primUTCSecondsClock #primUTCMicrosecondsClock #primUTCMillisecondsClock).
	timing := #( #millisecondClockValue #milliseconds:since: #millisecondsSince: ).
	benchmarks := #( #benchmarkMillisecondClock #benchmarkPrimitiveResponseDelay ). 

	^ super selectorsToBeIgnored, deprecated, private, special, primitives, timing, benchmarks.
]

{ #category : #running }
TimeTest >> setUp [
	super setUp.
	localTimeZoneToRestore := DateAndTime localTimeZone.
	DateAndTime localTimeZone: TimeZone default.
	time := self timeClass fromSeconds: 14567.		"4:02:47 am"
	aTime := Time readFrom: '12:34:56 pm' readStream

]

{ #category : #running }
TimeTest >> tearDown [
	DateAndTime localTimeZone: localTimeZoneToRestore.
	super tearDown 

]

{ #category : #tests }
TimeTest >> testAccessing [
	self
		assert: time hours equals: 4;
		assert: time minutes equals: 2;
		assert: time seconds equals: 47;
		assert: time asSeconds equals: 14567
]

{ #category : #tests }
TimeTest >> testAddSeconds [
	self assert: (aTime addSeconds: 1) equals: (Time readFrom: '12:34:57' readStream).
	self assert: (aTime addSeconds: 60) equals: (Time readFrom: '12:35:56' readStream).
	self assert: (aTime addSeconds: 3600) equals: (Time readFrom: '13:34:56' readStream).
	self assert: (aTime addSeconds: 24 * 60 * 60) equals: (Time readFrom: '12:34:56' readStream)
]

{ #category : #tests }
TimeTest >> testAddTime [
	self assert: (aTime addTime: aTime) equals: (Time readFrom: '01:09:52' readStream)
]

{ #category : #tests }
TimeTest >> testArithmetic [
	| t1 t2 t3 |
	t1 := time addSeconds: 70.	"4:03:57 am"
	self
		assert: t1 hours equals: 4;
		assert: t1 minutes equals: 3;
		assert: t1 seconds equals: 57.

	t2 := t1 addTime: (self timeClass fromSeconds: 60 * 60 * 5).
	self
		assert: t2 hours equals: 9;
		assert: t2 minutes equals: 3;
		assert: t2 seconds equals: 57.

	t3 := t2 subtractTime: (self timeClass fromSeconds: 60 * 60 * 5 + 70).
	self assert: t3 equals: time
]

{ #category : #tests }
TimeTest >> testAsDate [
	self assert: aTime asDate equals: Date current
]

{ #category : #tests }
TimeTest >> testAsDateAndTime [
	self assert: aTime asDateAndTime equals: DateAndTime current midnight + aTime
]

{ #category : #tests }
TimeTest >> testAsDuration [
	self
		assert: aTime asDuration
		equals:
			(Duration
				days: 0
				hours: 12
				minutes: 34
				seconds: 56)
]

{ #category : #tests }
TimeTest >> testAsNanoSeconds [
	self assert: aTime asNanoSeconds equals: 45296000000000
]

{ #category : #tests }
TimeTest >> testAsSeconds [
	self assert: aTime asSeconds equals: 45296
]

{ #category : #tests }
TimeTest >> testAsTime [
	self assert: aTime asTime equals: aTime
]

{ #category : #tests }
TimeTest >> testAsWeek [
	self assert: aTime asWeek equals: (DateAndTime current midnight + aTime) asWeek
]

{ #category : #tests }
TimeTest >> testAsYear [
	self assert: aTime asYear equals: (DateAndTime current midnight + aTime) asYear
]

{ #category : #tests }
TimeTest >> testComparing [
	| t1 t2 t3 |
	t1 := self timeClass fromSeconds: 14567.	"4:02:47 am"
	t2 := self timeClass fromSeconds: 5000.	"1:23:20 am"
	t3 := self timeClass fromSeconds: 80000.	"10:13:20 pm"

	self
		assert: time equals: t1;
		assert: time hash equals: t1 hash;
		assert: time equals: time copy.
	self
		deny: t1 < t2;
		assert: t1 < t3
]

{ #category : #tests }
TimeTest >> testConverting [
	self assert: time asSeconds equals: 14567
]

{ #category : #tests }
TimeTest >> testDuration [
	self assert: aTime duration equals: 0 seconds
]

{ #category : #tests }
TimeTest >> testEqual [
	self assert: aTime equals: (Time readFrom: '12:34:56' readStream).
	self assert: aTime equals: (Time readFrom: '12:34:56.00' readStream).
	self assert: aTime equals: (Time readFrom: '12:34:56.0000' readStream)
]

{ #category : #tests }
TimeTest >> testFromSeconds [
	| t |
	t := self timeClass fromSeconds: 14567.
	self assert: t equals: time
]

{ #category : #tests }
TimeTest >> testGeneralInquiries [
	| date aDateAndTime |

	self should: [ self timeClass timeWords ] raise: MessageNotUnderstood.

	date := '2 June 1973' asDate.
	time := '4:02:47 am' asTime.
	aDateAndTime := self timeClass dateAndTimeFromSeconds: (2285280000 + 14567).
	self
		assert: aDateAndTime equals: {date. time}.

]

{ #category : #tests }
TimeTest >> testHhmm24 [
	self assert: aTime hhmm24 equals: '1234'
]

{ #category : #tests }
TimeTest >> testHour [
	self assert: aTime hour equals: 12.
	self assert: aTime hour12 equals: 12.
	self assert: aTime hour24 equals: 12.
	self assert: aTime hours equals: 12
]

{ #category : #tests }
TimeTest >> testLessThan [
	self assert: aTime < (Time readFrom: '12:34:57' readStream)
]

{ #category : #tests }
TimeTest >> testMeridianAbbreviation [
	self assert: aTime meridianAbbreviation equals: 'PM'
]

{ #category : #tests }
TimeTest >> testMinute [
	self assert: aTime minute equals: 34.
	self assert: aTime minutes equals: 34
]

{ #category : #tests }
TimeTest >> testNanoSecond [
	self assert: aTime nanoSecond equals: 0
	"Right now all times all seconds"
]

{ #category : #tests }
TimeTest >> testNew [
	self assert: self timeClass new asSeconds equals: 0
]

{ #category : #'tests - printing' }
TimeTest >> testPrint24 [
	self assert: aTime print24 equals: '12:34:56'
]

{ #category : #'tests - printing' }
TimeTest >> testPrint24On [
	self assert: (String streamContents: [ :str | aTime print24: true on: str ]) equals: '12:34:56'
]

{ #category : #'tests - printing' }
TimeTest >> testPrint24OnWithPM [
	self assert: (String streamContents: [ :str | aTime print24: false on: str ]) equals: '12:34:56 pm'
]

{ #category : #'tests - printing' }
TimeTest >> testPrint24OnWithoutSeconds [
	self assert: (String streamContents: [ :str | aTime print24: true showSeconds: true on: str ]) equals: '12:34:56'
]

{ #category : #'tests - printing' }
TimeTest >> testPrint24withNanos [
	self assert: '12:34:56.1' asTime print24 equals: '12:34:56'
]

{ #category : #'tests - printing' }
TimeTest >> testPrintMinutes [
	self assert: aTime printMinutes equals: '12:34 pm'
]

{ #category : #'tests - printing' }
TimeTest >> testPrintOn [
	self assert: (String streamContents: [ :str | aTime printOn: str ]) equals: '12:34:56 pm'
]

{ #category : #tests }
TimeTest >> testPrintStringNanos [
	self
		assert:
			(Time
				hour: 15
				minute: 15
				second: 15
				nanoSecond: 150 * 1000000) printString
		equals: '3:15:15.15 pm'
]

{ #category : #'tests - printing' }
TimeTest >> testPrinting [
	self
		assert: time printString equals: '4:02:47 am';
		assert: time intervalString equals: '4 hours 2 minutes 47 seconds';
		assert: time print24 equals: '04:02:47';
		assert: time printMinutes equals: '4:02 am';
		assert: time hhmm24 equals: '0402'
]

{ #category : #'tests - input' }
TimeTest >> testReadFrom [
	| string t |
	string := '4:02:47 am'.
	t := self timeClass readFrom: string readStream.
	self assert: time printString equals: t printString
]

{ #category : #'tests - input' }
TimeTest >> testReadFromWithError [
		
	#('invalid' '0:invalid' '1 invalid' '1 pm is the afternoon' '1250 Fake St, New York, USA 12345' '13000 AM' '25:69:1239' '1,3,6') do: [ :each | 
	self should: [self timeClass readFrom: each readStream] raise: Error.]

	

]

{ #category : #'tests - input' }
TimeTest >> testReadFromWithNanos [
	#('4:02:47.5 am' '4:02:55.521 pm')
		do: [ :each | 
			| t |
			t := self timeClass readFrom: each readStream.
			self assert: t printString equals: each ]
	"there is a bug with 520 instead of 521"
]

{ #category : #tests }
TimeTest >> testSecond [
	self assert: aTime second equals: 56.
	self assert: aTime seconds equals: 56
]

{ #category : #tests }
TimeTest >> testSeconds [
	self assert: (Time readFrom: '20:33:14.321-05:00' readStream) asDuration seconds equals: 14
]

{ #category : #tests }
TimeTest >> testStoreOn [
	self assert: (String streamContents: [ :str | aTime storeOn: str ]) equals: '''12:34:56 pm'' asTime'
]

{ #category : #tests }
TimeTest >> testStoring [
	self
		assert: time storeString equals: '''4:02:47 am'' asTime';
		assert: time equals: '4:02:47 am' asTime
]

{ #category : #tests }
TimeTest >> testSubtractTime [
	self assert: (aTime subtractTime: aTime) equals: (Time readFrom: '00:00:00' readStream)
]

{ #category : #tests }
TimeTest >> testTicks [
	self assert: aTime ticks equals: #(0 45296 0).
	self assert: aTime equals: (Time new ticks: #(0 45296 0))
]

{ #category : #setup }
TimeTest >> timeClass [

	^ Time
]
