Extension { #name : #InstructionStream }

{ #category : #'*OpalCompiler-Tests' }
InstructionStream >> peekInstruction [
	"Return the next bytecode instruction as a message that an InstructionClient would understand.  The pc remains unchanged."

	| currentPc instruction |
	currentPc := self pc.
	instruction := self interpretNextInstruction.
	self pc: currentPc.
	^ instruction
]
