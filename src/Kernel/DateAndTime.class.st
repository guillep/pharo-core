"
I am DateAndTime.
I represent a point in time or timestamp as defined by ISO 8601. 
I am a Magnitude. 
I have nanosecond precision.
I am TimeZone aware. 
I have zero duration.

  DateAndTime now.
  DateAndTime now asUTC rounded.
  DateAndTime fromString: '1969-07-20T20:17:40.123+02:00'.
  DateAndTime fromString: '1969-07-20T20:17:40Z'.

My implementation uses three SmallIntegers and a Duration:
  julianDayNumber - julian day number (starting at midnight UTC rather than noon GMT).
  seconds - number of seconds since midnight UTC. Always positive, between 0 and 86399.
  nanos	 - the number of nanoseconds since the second. Always positive, between 0 and 999999999.
  offset	- duration from UTC.

The offset is used to print the date and time in a local time zone, but the date and time are handled in UTC internally.
The nanosecond attribute is often zero but it defined for full ISO compliance and is suitable for timestamping.

"
Class {
	#name : #DateAndTime,
	#superclass : #Magnitude,
	#instVars : [
		'seconds',
		'offset',
		'julianDayNumber',
		'nanos'
	],
	#classVars : [
		'ClockProvider',
		'LocalTimeZoneCache'
	],
	#pools : [
		'ChronologyConstants'
	],
	#category : #'Kernel-Chronology'
}

{ #category : #private }
DateAndTime class >> basicYear: year month: month day: day hour: hour minute: minute second: second nanoSecond: nanoCount offset: utcOffset [
	"Return a DateAndTime with the values in the given TimeZone (UTCOffset)"

	| p q r s julianDayNumber localSeconds utcSeconds|

	p := (month - 14) quo: 12.
	q := year + 4800 + p.
	r := month - 2 - (12 * p).
	s := (year + 4900 + p) quo: 100.

	julianDayNumber :=
		((1461 * q) quo: 4) +
			((367 * r) quo: 12) -
			((3 * s) quo: 4) +
			(day - 32075).
			
	localSeconds :=  hour * 60 + minute * 60 + second.
	utcSeconds := localSeconds - utcOffset asSeconds.
	
	^self basicNew
		setJdn: julianDayNumber
		seconds: utcSeconds
		nano: nanoCount
		offset: utcOffset;
		yourself
]

{ #category : #'clock provider' }
DateAndTime class >> clock [ 
	 "the provider of real time seconds/milliseconds."

	^ ClockProvider 
]

{ #category : #'system queries' }
DateAndTime class >> clockPrecision [
	"One nanosecond precision"

	^ Duration seconds: 0 nanoSeconds: 1

]

{ #category : #'instance creation queries' }
DateAndTime class >> current [

	^ self now

]

{ #category : #'instance creation queries' }
DateAndTime class >> epoch [
  "Answer a DateAndTime representing the epoch: 1 January 1901"

  ^ (self julianDayNumber: SqueakEpoch) offset: 0.
  
]

{ #category : #'instance creation' }
DateAndTime class >> fromInternalTime: anInteger [
	"Answer an instance of the receiver with the time represented by anInteger. Pharo internal time is an integer representing time in the local timezone with an epoch of 1 Jan. 1901"

	^(self fromSeconds: anInteger offset: 0) translateTo: self localOffset.
]

{ #category : #input }
DateAndTime class >> fromString: aString [ 
	^ self readFrom: aString readStream
]

{ #category : #'instance creation' }
DateAndTime class >> fromUnixTime: anInteger [
	^ self fromSeconds: anInteger + 2177452800 "unix epoch constant"
]

{ #category : #'initialize-release' }
DateAndTime class >> initialize [
	ClockProvider := Time
]

{ #category : #'instance creation' }
DateAndTime class >> julianDayNumber: aJulianDayNumber [

	^ self basicNew
		ticks: aJulianDayNumber days ticks offset: Duration new;
		yourself
]

{ #category : #'instance creation' }
DateAndTime class >> julianDayNumber: aJulianDayNumber offset: aTimeZoneOffset [
	"Return a DateAndTime at midnight local time at the given julian day"
	| ticks |
	"create a ticks representation in UTC, take the given julian day in local time"
	ticks := aJulianDayNumber days ticks.
	ticks at: 2 put: aTimeZoneOffset asSeconds negated.

	^ self basicNew
		ticks: ticks offset: aTimeZoneOffset;
		yourself
]

{ #category : #'system queries' }
DateAndTime class >> localOffset [
	"Answer the duration we are offset from UTC"

	^ self localTimeZone offset

]

{ #category : #'time zones' }
DateAndTime class >> localTimeZone [
	"Answer the local time zone"

	^ LocalTimeZoneCache ifNil: [ LocalTimeZoneCache := TimeZone default ]


]

{ #category : #'time zones' }
DateAndTime class >> localTimeZone: aTimeZone [
	"Set the local time zone"

	"
	DateAndTime localTimeZone: (TimeZone offset:  0 hours name: 'Universal Time' abbreviation: 'UTC').
	DateAndTime localTimeZone: (TimeZone offset: -8 hours name: 'Pacific Standard Time' abbreviation: 'PST').
	"

	LocalTimeZoneCache := aTimeZone



]

{ #category : #'instance creation' }
DateAndTime class >> midnight [

	^ self now midnight

]

{ #category : #primitives }
DateAndTime class >> millisecondClockValue [

	^ self clock millisecondClockValue
]

{ #category : #'instance creation' }
DateAndTime class >> new [
	"Answer a DateAndTime representing the epoch: 1 January 1901"

	^ self epoch offset: self localOffset 
	
]

{ #category : #'instance creation' }
DateAndTime class >> now [ 
	"Answer the current date and time expressed in local time.
	[ 10000 timesRepeat: [ self now. ] ] timeToRun / 10000.0 . "

	| nanoTicks |
	nanoTicks := self clock microsecondClockValue * 1000.
	^ self basicNew
		setJdn: SqueakEpoch 
		seconds: 0
		nano: nanoTicks
		offset: self localOffset
]

{ #category : #'instance creation queries' }
DateAndTime class >> unixEpoch [
	"Answer a DateAndTime representing the Unix epoch (1 January 1970, midnight UTC)"
	^ self basicNew
		ticks: #(2440588 0 0) offset: Duration zero;
		yourself.
]

{ #category : #'clock provider' }
DateAndTime class >> year: aYearInteger month: aMonthNumber [
    "Return a date starting the first day of the month"

    ^ self
        year: aYearInteger
        month: aMonthNumber
        day: 1
        hour: 0
        minute: 0
]

{ #category : #arithmetic }
DateAndTime >> + operand [
	"operand conforms to protocol Duration"

	| durationTicks |
	durationTicks := operand asDuration ticks.
	^ self class basicNew
		setJdn: julianDayNumber + durationTicks first
			seconds: seconds + durationTicks second
			nano: nanos + durationTicks third
			offset: self offset;
		yourself
]

{ #category : #arithmetic }
DateAndTime >> - operand [
	"operand conforms to protocol DateAndTime or protocol Duration"

	^ (operand respondsTo: #asDateAndTime)
		ifTrue: [ 
			| other |
			other := operand asDateAndTime.
			Duration
				seconds: (SecondsInDay * (julianDayNumber - other julianDayNumberUTC))
							+ (seconds - other secondsSinceMidnightUTC)
				nanoSeconds: nanos - other nanoSecond ]
		ifFalse: [ self + operand negated ]
]

{ #category : #arithmetic }
DateAndTime >> < comparand [
	"comparand conforms to protocol DateAndTime,
	or can be converted into something that conforms."

	| other |
	other := comparand asDateAndTime.
	^ julianDayNumber = other julianDayNumberUTC
		ifTrue: [ 
			seconds = other secondsSinceMidnightUTC
				ifTrue: [ nanos < other nanoSecond ]
				ifFalse: [ seconds < other secondsSinceMidnightUTC ] ]
		ifFalse: [ julianDayNumber < other julianDayNumberUTC ]
]

{ #category : #comparing }
DateAndTime >> = other [ 
	self == other ifTrue: [ ^ true ].
	(self species = other species) ifFalse: [ ^ false ].
	^ self hasEqualTicks: other
]

{ #category : #converting }
DateAndTime >> asDate [
    "Convert the receiver in a date object."
    "(DateAndTime fromString: ' 2019-08-17T13:33:00+02:00') asDate printString >>> (Date newDay: 17 month: 8 year: 2019) printString"
    ^ Date starting: self
]

{ #category : #converting }
DateAndTime >> asDateAndTime [

	^ self

]

{ #category : #converting }
DateAndTime >> asDuration [
	"Answer the duration since midnight."

	^ Duration seconds: self secondsSinceMidnightLocalTime nanoSeconds: nanos

]

{ #category : #converting }
DateAndTime >> asTime [

	^ Time seconds: self secondsSinceMidnightLocalTime nanoSeconds: nanos
]

{ #category : #converting }
DateAndTime >> asTimeUTC [

	^ Time seconds: self secondsSinceMidnightUTC nanoSeconds: nanos
]

{ #category : #converting }
DateAndTime >> asUTC [

	^ offset isZero
		ifTrue: [ self ]
		ifFalse: [ self offset: 0 ]

]

{ #category : #converting }
DateAndTime >> asUnixTime [
	"answer number of seconds since unix epoch (midnight Jan 1, 1970, UTC)"
	^((self offset: Duration zero) - self class unixEpoch) asSeconds
]

{ #category : #accessing }
DateAndTime >> dayMonthYearDo: aBlock [
	"Return the value of executing block with the Gregorian Calender day, month and year as arguments,
	as computed from my Julian Day Number, julianDayNumber.
	See http://en.wikipedia.org/wiki/Julian_date#Gregorian_calendar_from_Julian_day_number
    
    A short Description for the Constants used below:
    - 400 years span 146097 days in gregorian calendar.
    - 100 years span 36524 days, except every 400 years.
    - 4 years span 1461 days, except every 100 years.
    - 1 year spans 365 days, except every four years
    "

	| l n i j monthDay month fullYear |
	l := self julianDayNumber + 68569.
	n := 4 * l // 146097.
	l := l - (146097 * n + 3 // 4).
	i := 4000 * (l + 1) // 1461001.
	l := l - (1461 * i // 4) + 31.
	j := 80 * l // 2447.
	monthDay := l - (2447 * j // 80).
	l := j // 11.
	month := j + 2 - (12 * l).
	fullYear := 100 * (n - 49) + i + l.

	^ aBlock
		value: monthDay
		value: month
		value: fullYear.
]

{ #category : #private }
DateAndTime >> hasEqualTicks: aDateAndTime [
	
	^ (self julianDayNumberUTC = aDateAndTime julianDayNumberUTC)
		and: [ (seconds = aDateAndTime secondsSinceMidnightUTC)
			and: [ nanos = aDateAndTime nanoSecond ] ]


]

{ #category : #comparing }
DateAndTime >> hash [
	^ (julianDayNumber hashMultiply bitXor: seconds) bitXor: nanos
]

{ #category : #accessing }
DateAndTime >> julianDayNumber [
	
	^ julianDayNumber + self julianDayOffset
]

{ #category : #accessing }
DateAndTime >> julianDayNumberUTC [
	
	^ julianDayNumber
]

{ #category : #accessing }
DateAndTime >> julianDayOffset [
	"Return the offset in julian days possibly introduced by the timezone offset"
	
	^ ((seconds + self offset asSeconds) / SecondsInDay) floor
]

{ #category : #accessing }
DateAndTime >> localSeconds [
	" Return the seconds since the epoch in local time."
	^ seconds + self offset asSeconds
]

{ #category : #accessing }
DateAndTime >> midnight [
	"Answer a DateAndTime starting at midnight (towards the end of the day) local time"

	self dayMonthYearDo: [ :day :month :year | 
			^ self class
				basicYear: year
				month: month
				day: day
				hour: 0
				minute: 0
				second: 0
				nanoSecond: 0
				offset: offset ]
]

{ #category : #accessing }
DateAndTime >> minute [
	"Answer a number that represents the number of complete minutes in the receiver' time part, 
	after the number of complete hours has been removed."
	"(DateAndTime fromString: ' 2004-02-29T13:33:00+02:00') minute >>> 33"
		
 	^ self localSeconds // SecondsInMinute \\ 60
]

{ #category : #accessing }
DateAndTime >> nanoSecond [

	^ nanos

]

{ #category : #initialization }
DateAndTime >> normalizeSecondsAndNanos [
	(NanosInSecond <= nanos or: [ nanos < 0 ])
		ifTrue: [
			seconds := seconds + (nanos // NanosInSecond).
			nanos := nanos \\ NanosInSecond].
	(SecondsInDay <= seconds or: [ seconds < 0 ])
		ifTrue: [
			julianDayNumber := julianDayNumber + (seconds // SecondsInDay).
			seconds := seconds \\ SecondsInDay].

]

{ #category : #accessing }
DateAndTime >> offset [

	^ offset

]

{ #category : #accessing }
DateAndTime >> offset: anOffset [
	"Answer a <DateAndTime> equivalent to the receiver but with its local time 
	being offset from UTC by offset.
	Unlike #translateTo: this will NOT change the absolute in UTC "

	^ self class basicNew 
		ticks: self ticks offset: anOffset asDuration;
		yourself
		
]

{ #category : #printing }
DateAndTime >> printOn: aStream [
	"Print as per ISO 8601 sections 5.3.3 and 5.4.1.
	Prints either:
		'YYYY-MM-DDThh:mm:ss.s+ZZ:zz:z' (for positive years) or '-YYYY-MM-DDThh:mm:ss.s+ZZ:zz:z' (for negative years)"

	^self printOn: aStream withLeadingSpace: false

]

{ #category : #printing }
DateAndTime >> printOn: aStream withLeadingSpace: printLeadingSpaceToo [
	
	BasicDatePrinter default printDateAndTime: self withLeadingSpace: printLeadingSpaceToo on: aStream
]

{ #category : #accessing }
DateAndTime >> second [
	"Answer a number that represents the number of complete seconds in the receiver's time part, 
	after the number of complete minutes has been removed."
   "(DateAndTime fromString: ' 2004-02-29T13:33:12+02:00') second >>> 12" 

 	^ self localSeconds \\ 60
]

{ #category : #private }
DateAndTime >> setJdn: julDays seconds: secs nano: nanoSecs offset: anOffset [
	julianDayNumber := julDays.
	seconds := secs.
	nanos := nanoSecs.
	offset := anOffset.
	self normalizeSecondsAndNanos
]

{ #category : #private }
DateAndTime >> ticks [
	"Private - answer an array with our instance variables. Assumed to be UTC "

	^ Array with: julianDayNumber with: seconds with: nanos.
]

{ #category : #private }
DateAndTime >> ticks: ticks offset: utcOffset [
	"ticks is {julianDayNumber. secondCount. nanoSeconds}"

	self setJdn: (ticks at: 1) seconds: (ticks at: 2) nano: (ticks at: 3) offset: utcOffset
]
