!ShiftClassBuilder methodsFor: 'migrating' stamp: 'PabloTesone 10/02/2017 16:09'!
compileMethods
	oldClass localMethods do: [ :m | | copy |
		copy := m copy.
		copy methodClass: newClass.
		copy literals withIndexDo: [:l :i |
			(l isKindOf: ClassVariable)
				ifTrue: [ | newLiteral |
					newLiteral := newClass innerBindingOf: l key.
					m literalAt: i put: newLiteral ].
		].
		newClass addSelectorSilently: copy selector withMethod: copy.
	].
	oldClass classSide localMethods do: [ :m | | copy |
		copy := m copy.
		copy methodClass: newClass classSide.
		copy literals withIndexDo: [:l :i |
			(l isKindOf: ClassVariable)
				ifTrue: [ | newLiteral |
					newLiteral := newClass innerBindingOf: l key.
					m literalAt: i put: newLiteral ].
		].
		newClass classSide addSelectorSilently: copy selector withMethod: copy.
	].! !


(MonticelloBootstrap inDirectory: (CommandLineArguments new optionAt: 'BOOTSTRAP_PACKAGE_CACHE_DIR' ifAbsent: [ 'pharo-local/package-cache' ])) bootstrap.
MCCacheRepository reset.
