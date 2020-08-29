Class {
	#name : #PBSignal,
	#superclass : #StringSignal,
	#category : 'Pharo30Bootstrap'
}

{ #category : #'instance creation' }
PBSignal class >> log: msg [
	"Writes msg to stdout too, since this information is useful during the build process, where output is only seen on the command line."
        Transcript show: '    [+] ' , msg; cr.
        ^ super log: msg
]
