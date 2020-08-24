BOOTSTRAP_ARCH = 32
BUILD_NUMBER = 1

ifeq ($(BOOTSTRAP_ARCH),32)
	SEEK=24
else
	SEEK=40
endif

bootstrap = ./pharo bootstrapImage.image

PREFIX=Pharo7.0
GIT_COMMIT_HASH=$(shell git show -s --format=%h)
SUFFIX=$(BOOTSTRAP_ARCH)bit-$(GIT_COMMIT_HASH)

VM=./bootstrap-cache/vm/pharo

BOOTSTRAP_ARCHIVE_IMAGE_PATH=bootstrap-cache/$(PREFIX)-bootstrap-$(SUFFIX).image

BOOTSTRAP_IMAGE_NAME=bootstrap

COMPILER_IMAGE_NAME=$(PREFIX)-compiler-$(SUFFIX)
COMPILER_IMAGE_PATH=bootstrap-cache/$(COMPILER_IMAGE_NAME).image

TRAITS_IMAGE_NAME=$(PREFIX)-traits-$(SUFFIX)
TRAITS_IMAGE_PATH=bootstrap-cache/$(TRAITS_IMAGE_NAME).image

CORE_IMAGE_NAME=$(PREFIX)-core-$(SUFFIX)
CORE_IMAGE_PATH=bootstrap-cache/$(CORE_IMAGE_NAME).image

MC_BOOTSTRAP_IMAGE_NAME=$(PREFIX)-monticello_bootstrap-$(SUFFIX)
MC_BOOTSTRAP_IMAGE_PATH=bootstrap-cache/$(MC_BOOTSTRAP_IMAGE_NAME).image

MC_IMAGE_NAME=$(PREFIX)-monticello-$(SUFFIX)
MC_IMAGE_PATH=bootstrap-cache/$(MC_IMAGE_NAME).image

METACELLO_IMAGE_NAME=$(PREFIX)-metacello-$(SUFFIX)
METACELLO_IMAGE_PATH=bootstrap-cache/$(METACELLO_IMAGE_NAME).image

PHARO_IMAGE_NAME=$(PREFIX)-$(SUFFIX)
PHARO_IMAGE_PATH=bootstrap-cache/$(PHARO_IMAGE_NAME).image

$(PHARO_IMAGE_PATH): $(METACELLO_IMAGE_PATH)
	@echo "[Pharo] Reloading rest of packages"
	$(VM) "$(METACELLO_IMAGE_PATH)" save "$(PHARO_IMAGE_NAME)"
	# fix the display size in the image header (position 40 [zero based], 24 for 32-bit image)
	# in older versions we must use octal representation
	printf "\231\002\320\003" > displaySize.bin
	dd if="displaySize.bin" of="$(PHARO_IMAGE_PATH)" bs=1 seek=$(SEEK) count=4 conv=notrunc
	$(VM) "$(PHARO_IMAGE_PATH)" eval --save "Smalltalk vm parameterAt: 45 put: (Smalltalk vm parameterAt: 44) * 4"
	$(VM) "$(PHARO_IMAGE_PATH)" eval --save "Metacello new baseline: 'Tonel';repository: 'github://pharo-vcs/tonel:v1.0.5';onWarning: [ :e | Error signal: e messageText in: e signalerContext ]; load: 'core'"
	$(VM) "$(PHARO_IMAGE_PATH)" eval --save "Metacello new baseline: 'IDE';repository: 'tonel://src';onWarning: [ :e | Error signal: e messageText in: e signalerContext ]; load"
	$(VM) "$(PHARO_IMAGE_PATH)" eval --save "FFIMethodRegistry resetAll. PharoSourcesCondenser condenseNewSources. Smalltalk garbageCollect."
	#$(VM) "$(PHARO_IMAGE_PATH)" clean --release
	#@echo "[Pharo] Configure resulting image"
	#$(VM) "$(PHARO_IMAGE_PATH)" st bootstrap/scripts/04-configure-resulting-image/fixPackageVersions.st --save --quit
	#$(VM) "$(PHARO_IMAGE_PATH)" save "Pharo"
	#zip "bootstrap-cache/$(PHARO_IMAGE_NAME).zip" bootstrap-cache/$(PHARO_IMAGE_NAME).*

#Bootstrap Metacello
$(METACELLO_IMAGE_PATH): $(MC_IMAGE_PATH)
	@echo "[Metacello] Bootstrapping Metacello"
	$(VM) "$(MC_IMAGE_PATH)" save $(METACELLO_IMAGE_NAME)
	cd bootstrap-cache && ./vm/pharo "$(METACELLO_IMAGE_NAME).image" st ../bootstrap/scripts/03-metacello-bootstrap/01-loadMetacello.st --save --quit
	zip "bootstrap-cache/$(METACELLO_IMAGE_NAME).zip" bootstrap-cache/$(METACELLO_IMAGE_NAME).*

#Bootstrap Monticello Part 2: Networking Packages and Remote Repositories
$(MC_IMAGE_PATH): $(MC_BOOTSTRAP_IMAGE_PATH)
	@echo "[Monticello] Loading Networking Packages and Remote Repositories"
	$(VM) "$(MC_BOOTSTRAP_IMAGE_PATH)" save $(MC_IMAGE_NAME)
	cd bootstrap-cache && ./vm/pharo "$(MC_IMAGE_NAME).image" st ../bootstrap/scripts/02-monticello-bootstrap/03-bootstrapMonticelloRemote.st --save --quit
	zip "bootstrap-cache/$(MC_IMAGE_NAME).zip" bootstrap-cache/$(MC_IMAGE_NAME).*

#Bootstrap Monticello Part 1: Core and Local repositories
$(MC_BOOTSTRAP_IMAGE_PATH): $(CORE_IMAGE_PATH) bootstrap-cache/PharoV60.sources
	@echo "[Monticello] Bootstrap Monticello Core and Local repositories"
	$(VM) "$(CORE_IMAGE_PATH)" save $(MC_BOOTSTRAP_IMAGE_NAME)
	$(VM) "$(MC_BOOTSTRAP_IMAGE_PATH)" st bootstrap-cache/st-cache/Monticello.st --save --quit
	$(VM) "$(MC_BOOTSTRAP_IMAGE_PATH)" st bootstrap/scripts/02-monticello-bootstrap/01-fixLocalMonticello.st --save --quit
	cd bootstrap-cache && ./vm/pharo "$(MC_BOOTSTRAP_IMAGE_NAME).image" st ../bootstrap/scripts/02-monticello-bootstrap/02-bootstrapMonticello.st --save --quit
	$(VM) "$(MC_BOOTSTRAP_IMAGE_PATH)" eval --save "TraitsBootstrap fixSourceCodeOfTraits "
	zip "bootstrap-cache/$(MC_BOOTSTRAP_IMAGE_NAME).zip" bootstrap-cache/$(MC_BOOTSTRAP_IMAGE_NAME).*


#Bootstrap Initialization: Class and RPackage initialization
$(CORE_IMAGE_PATH): $(TRAITS_IMAGE_PATH)
	@echo "[Core] Class and RPackage initialization - REMOVE ME"
	$(VM) "$(TRAITS_IMAGE_PATH)" save $(CORE_IMAGE_NAME)
	zip "bootstrap-cache/$(CORE_IMAGE_NAME).zip" "$(CORE_IMAGE_PATH)"

#Traits Initialization
$(TRAITS_IMAGE_PATH): $(COMPILER_IMAGE_PATH)
	@echo "[Core] Trait initialization"
	$(VM) "$(COMPILER_IMAGE_PATH)" save $(TRAITS_IMAGE_NAME)
	$(VM) "$(TRAITS_IMAGE_PATH)" loadHermes bootstrap-cache/TraitsV2.hermes --save
	$(VM) "$(TRAITS_IMAGE_PATH)" loadHermes bootstrap-cache/Kernel-Traits.hermes bootstrap-cache/AST-Core-Traits.hermes bootstrap-cache/Collections-Abstract-Traits.hermes bootstrap-cache/Transcript-Core-Traits.hermes bootstrap-cache/SUnit-Core-Traits.hermes bootstrap-cache/CodeImport-Traits.hermes bootstrap-cache/RPackage-Traits.hermes bootstrap-cache/OpalCompiler-Traits.hermes bootstrap-cache/Slot-Traits.hermes bootstrap-cache/CodeExport-Traits.hermes bootstrap-cache/System-Sources-Traits.hermes bootstrap-cache/System-Support-Traits.hermes bootstrap-cache/TraitsV2-Compatibility.hermes --save
	zip "bootstrap-cache/$(TRAITS_IMAGE_NAME).zip" "$(TRAITS_IMAGE_PATH)"

# Installing compiler through Hermes 
$(COMPILER_IMAGE_PATH): bootstrap-cache/bootstrap.image bootstrap-cache/vm
	@echo "Prepare Bootstrap files"
	cp "bootstrap-cache/bootstrap.image" "$(COMPILER_IMAGE_PATH)"
	$(VM) "$(COMPILER_IMAGE_PATH)" # I have to run once the image so the next time it starts the CommandLineHandler.
	$(VM) "$(COMPILER_IMAGE_PATH)" loadHermes bootstrap-cache/Hermes-Extensions.hermes --save
	$(VM) "$(COMPILER_IMAGE_PATH)" loadHermes bootstrap-cache/Multilingual-Encodings.hermes bootstrap-cache/Multilingual-TextConversion.hermes bootstrap-cache/Multilingual-Languages.hermes --save --no-fail-on-undeclared
	$(VM) "$(COMPILER_IMAGE_PATH)" loadHermes bootstrap-cache/InitializePackagesCommandLineHandler.hermes --save
	@echo "[Compiler] Installing compiler through Hermes"
	$(VM) "$(COMPILER_IMAGE_PATH)" loadHermes bootstrap-cache/Collections-Atomic.hermes bootstrap-cache/Collections-Arithmetic.hermes bootstrap-cache/AST-Core.hermes bootstrap-cache/Jobs.hermes --save --no-fail-on-undeclared
	$(VM) "$(COMPILER_IMAGE_PATH)" initializePackages --protocols=bootstrap-cache/protocolsKernel.txt --packages=bootstrap-cache/packagesKernel.txt --save
	$(VM) "$(COMPILER_IMAGE_PATH)" loadHermes bootstrap-cache/OpalCompiler-Core.hermes bootstrap-cache/CodeExport.hermes bootstrap-cache/CodeImport.hermes bootstrap-cache/CodeImportCommandLineHandlers.hermes --save --no-fail-on-undeclared
	$(VM) "$(COMPILER_IMAGE_PATH)" eval --save "CompilationContext initialize. OCASTTranslator initialize." 
	$(VM) "$(COMPILER_IMAGE_PATH)" st ./bootstrap/scripts/01-initialization/01-init.st --no-source --save --quit
	$(VM) "$(COMPILER_IMAGE_PATH)" st bootstrap/scripts/01-initialization/03-initUnicode.st --no-source --save --quit "resources/unicode/"
	$(VM) "$(COMPILER_IMAGE_PATH)" st bootstrap-cache/st-cache/DeprecatedFileStream.st bootstrap-cache/st-cache/FileSystem.st --no-source --quit --save
	$(VM) "$(COMPILER_IMAGE_PATH)" eval --save "SourceFileArray initialize"
	zip "bootstrap-cache/$(COMPILER_IMAGE_NAME).zip" "$(COMPILER_IMAGE_PATH)"

bootstrap-cache/PharoV60.sources:
	cd bootstrap-cache && wget http://files.pharo.org/sources/PharoV60.sources

bootstrap-cache/vm: bootstrap/scripts/download_vm.sh
	cd bootstrap-cache && rm -rf vm && ../bootstrap/scripts/download_vm.sh

bootstrap-cache/bootstrap.image: bootstrapImage.image bootstrap-cache/hermes
	$(bootstrap) ./bootstrap/scripts/bootstrap.st --ARCH=$(BOOTSTRAP_ARCH) --BUILD_NUMBER=$(BUILD_NUMBER) --quit
	cp "bootstrap-cache/bootstrap.image" "$(BOOTSTRAP_ARCHIVE_IMAGE_PATH)"
	zip "$(BOOTSTRAP_ARCHIVE_IMAGE_NAME).zip" "$(BOOTSTRAP_ARCHIVE_IMAGE_PATH)"

bootstrap-cache/hermes: bootstrapImage.image
	mkdir -p bootstrap-cache
	$(bootstrap) ./bootstrap/scripts/generateKernelHermesFiles.st --quit
	$(bootstrap) ./bootstrap/scripts/generateSUnitHermesFiles.st --quit
	$(bootstrap) ./bootstrap/scripts/generateTraitsHermesFiles.st --quit
	touch bootstrap-cache/hermes


bootstrapImage.image:	Pharo.image pharo-vm
	./pharo Pharo.image save bootstrapImage
	$(bootstrap) ./bootstrap/scripts/prepare_image.st --save --quit

Pharo.image:
	wget https://github.com/guillep/PharoBootstrap/releases/download/v1.4.1/bootstrapImage.zip
	unzip bootstrapImage.zip

pharo-vm:
	wget -O - get.pharo.org/vm61 | bash
	
clean:
	rm -rf bootstrap-cache pharo pharo-ui pharo-vm Pharo.* bootstrapImage.* pharo-local