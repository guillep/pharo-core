.PHONY: bootstrap_tools target_vm clean bootstrap

# -----------------------------------------------------
#   Arguments that can be specified for build process
# -----------------------------------------------------
# The output directory for everything to do with this build
BUILD_DIR ?= $(PWD)/build
# The directory bootstrapping tools
BOOTSTRAP_TOOLS_DIR ?= $(BUILD_DIR)/bootstrap-tools
# The target architecture of this build (architecture of virtual machine to download)
TARGET_ARCH ?= 64
# The target VM type of this build
#   Possible VM types are vm, vmT (Threaded heartbeat) and vmI (Timer heartbeat), see https://get.pharo.org for more information
TARGET_VM_TYPE ?= vm
# Any flags you want to pass to the build process
#   Will be used like: ./pharo Pharo.image $BUILD_IMAGE_FLAGS ...
BUILD_IMAGE_FLAGS ?= --no-default-preferences
# TODO not sure what this is for
BUILD_NUMBER ?= 1337
# This is of the form Pharo9.0, and is used to prefix the files built
# TODO can we simplify this?
PHARO_NAME_PREFIX ?= Pharo$(target_version)-PR
PHARO_COMMIT_HASH ?= g$(shell git rev-parse --verify HEAD)
BOOTSTRAP_CACHE_DIR ?= $(BUILD_DIR)/bootstrap-cache
BOOTSTRAP_ST_CACHE_DIR ?= $(BOOTSTRAP_CACHE_DIR)/st-cache

# -----------------------------------------------------
#   Detect and populate variables
# -----------------------------------------------------
target_version = $(shell head -n1 VERSION)

# -----------------------------------------------------
#   Simplifying variables
# -----------------------------------------------------
download = wget --quiet -O $@
# Contents of bootstrapImage.zip that we are interested in
bootstrap_image_components = Pharo.image Pharo.changes Pharo7.0-32bit-343f470.sources
vm_components = pharo pharo-ui pharo-vm
target_vm_components = $(addprefix $(BUILD_DIR)/,$(vm_components))
target_vm_image_exec = $(BUILD_DIR)/pharo --headless $@ $(BUILD_IMAGE_FLAGS)
save_from_dependency_image = $(BUILD_DIR)/pharo --headless $< $(BUILD_IMAGE_FLAGS) save $(basename $@)


# -----------------------------------------------------
#   Various stages of building Pharo
# -----------------------------------------------------

bootstrap: $(BUILD_DIR)/step-11-patch-display-size/bootstrap.image

$(addprefix $(BUILD_DIR)/step-01-raw/,$(bootstrap_image_components)): $(BOOTSTRAP_TOOLS_DIR)/bootstrapImage.zip
	@echo -e '\n    [+] Extracting image used to bootstrap this build\n'
	@mkdir -p $(dir $@)
	unzip -o $< $(notdir $@) -d $(dir $@)
	@touch $@

$(addprefix $(BUILD_DIR)/step-02-prepare-image/,$(bootstrap_image_components)): $(addprefix $(BUILD_DIR)/step-01-raw/,$(bootstrap_image_components)) $(addprefix $(BOOTSTRAP_TOOLS_DIR)/,$(vm_components))
	@echo -e '\n    [+] Copying image components to $(basename $(dir $@)) and then modifying in place\n'
	@mkdir -p $(dir $@)
	cp -r $(filter $(BUILD_DIR)/step-01-raw/%,$^) $(dir $@)
	$(BOOTSTRAP_TOOLS_DIR)/pharo $(dir $@)Pharo.image $(BUILD_IMAGE_FLAGS) ./bootstrap/scripts/prepare_image.st --save --quit

# This step creates a bunch of hermes files in $(BUILD_DIR)/bootstrap-cache and then does some bootstrapping
$(addprefix $(BUILD_DIR)/step-03-bootstrap/,$(bootstrap_image_components)): $(addprefix $(BUILD_DIR)/step-02-prepare-image/,$(bootstrap_image_components)) $(addprefix $(BOOTSTRAP_TOOLS_DIR)/,$(vm_components))
	@echo -e '\n    [+] Bootstrapping $(basename $(dir $@))\n'
	@mkdir -p $(dir $@)
	cp -r $(filter $(BUILD_DIR)/step-02-prepare-image/%,$^) $(dir $@)
	BOOTSTRAP_CACHE=$(BOOTSTRAP_CACHE_DIR) $(BOOTSTRAP_TOOLS_DIR)/pharo $(dir $@)Pharo.image $(BUILD_IMAGE_FLAGS) ./bootstrap/scripts/bootstrap.st --ARCH=${TARGET_ARCH} --BUILD_NUMBER=${BUILD_NUMBER} --VERSION_INFO="${PHARO_NAME_PREFIX}-${PHARO_COMMIT_HASH}" --save --quit

$(BUILD_DIR)/step-04-bootstrap/bootstrap.image: $(addprefix $(BUILD_DIR)/step-03-bootstrap/,$(bootstrap_image_components)) $(target_vm_components)
	@echo -e '\n    [+] Bootstrapping $(basename $(dir $@))\n'
	@mkdir -p $(dir $@)
	cp $(BUILD_DIR)/bootstrap-cache/bootstrap.image $@
	@# Run it once so the next time it starts the CommandLineHandler
	$(BUILD_DIR)/pharo --headless $@

$(BUILD_DIR)/step-05-bootstrap-kernel/bootstrap.image: $(BUILD_DIR)/step-04-bootstrap/bootstrap.image $(target_vm_components) # TODO add deps on hermes files
	@echo -e '\n    [+] Bootstrapping $(basename $(dir $@))\n'
	@mkdir -p $(dir $@)
	cp -r $(dir $<)bootstrap.image $(dir $@)bootstrap.image
	$(target_vm_image_exec) loadHermes $(BOOTSTRAP_CACHE_DIR)/Hermes-Extensions.hermes --save
	$(target_vm_image_exec) loadHermes $(addprefix $(BOOTSTRAP_CACHE_DIR)/,Math-Operations-Extensions.hermes Debugging-Core.hermes Kernel-Chronology-Extras.hermes Multilingual-Encodings.hermes Multilingual-TextConversion.hermes Multilingual-Languages.hermes ReflectionMirrors-Primitives.hermes) --save --no-fail-on-undeclared

	$(target_vm_image_exec) loadHermes $(BOOTSTRAP_CACHE_DIR)/InitializePackagesCommandLineHandler.hermes --save
	$(target_vm_image_exec) loadHermes $(addprefix $(BOOTSTRAP_CACHE_DIR)/,Collections-Atomic.hermes AST-Core.hermes Collections-Arithmetic.hermes Jobs.hermes System-SourcesCondenser.hermes) --save --no-fail-on-undeclared
	$(target_vm_image_exec) initializePackages --protocols=$(BOOTSTRAP_CACHE_DIR)/protocolsKernel.txt --packages=$(BOOTSTRAP_CACHE_DIR)/packagesKernel.txt --save

$(BUILD_DIR)/step-06-bootstrap-compiler/bootstrap.image: $(BUILD_DIR)/step-05-bootstrap-kernel/bootstrap.image $(target_vm_components) # TODO add deps on hermes files
	@echo -e '\n    [+] Bootstrapping $(basename $(dir $@))\n'
	@mkdir -p $(dir $@)
	cp -r $(dir $<)bootstrap.image $(dir $@)bootstrap.image

	$(target_vm_image_exec) loadHermes $(addprefix $(BOOTSTRAP_CACHE_DIR)/,OpalCompiler-Core.hermes CodeExport.hermes CodeImport.hermes CodeImportCommandLineHandlers.hermes) --save --no-fail-on-undeclared
	$(target_vm_image_exec) eval --save "OpalCompiler register. CompilationContext initialize. OCASTTranslator initialize."
	$(target_vm_image_exec) st ./bootstrap/scripts/01-initialization/01-init.st --no-source --save --quit

	@# Initializing Unicode
	$(target_vm_image_exec) st ./bootstrap/scripts/01-initialization/03-initUnicode.st --no-source --save --quit ./resources/unicode/

	$(target_vm_image_exec) loadHermes $(addprefix $(BOOTSTRAP_CACHE_DIR)/,DeprecatedFileStream.hermes FileSystem-Core.hermes FileSystem-Disk.hermes) --save --no-fail-on-undeclared
	$(target_vm_image_exec) eval --save "PharoBootstrapInitialization initializeFileSystem"
	$(target_vm_image_exec) eval --save "SourceFileArray initialize"

$(BUILD_DIR)/step-07-bootstrap-core/bootstrap.image: $(BUILD_DIR)/step-06-bootstrap-compiler/bootstrap.image $(target_vm_components) $(BUILD_DIR)/step-07-bootstrap-core/PharoV60.sources # TODO add deps on hermes files
	@echo -e '\n    [+] Bootstrapping $(basename $(dir $@))\n'
	@mkdir -p $(dir $@)
	cp -r $(dir $<)bootstrap.image $(dir $@)bootstrap.image

	$(target_vm_image_exec) loadHermes $(BOOTSTRAP_CACHE_DIR)/TraitsV2.hermes --save
	$(target_vm_image_exec) loadHermes $(addprefix $(BOOTSTRAP_CACHE_DIR)/,Kernel-Traits.hermes AST-Core-Traits.hermes Collections-Abstract-Traits.hermes Transcript-Core-Traits.hermes CodeImport-Traits.hermes CodeExport-Traits.hermes TraitsV2-Compatibility.hermes) --save

$(BUILD_DIR)/step-08-bootstrap-monticello/bootstrap.image: $(BUILD_DIR)/step-07-bootstrap-core/bootstrap.image $(target_vm_components) $(BUILD_DIR)/step-07-bootstrap-core/PharoV60.sources # TODO add deps on hermes files
	@echo -e '\n    [+] Bootstrapping $(basename $(dir $@))\n'
	@mkdir -p $(dir $@)

	$(save_from_dependency_image)
	@# TODO this was originally open old image, save new image. Is copying the same thing?
	@# cp -r $(dir $<)bootstrap.image $(dir $@)bootstrap.image
	cp $(BUILD_DIR)/step-07-bootstrap-core/PharoV60.sources $(dir $@)PharoV60.sources

	$(target_vm_image_exec) st $(BOOTSTRAP_ST_CACHE_DIR)/Monticello.st --save --quit
	$(target_vm_image_exec) st ./bootstrap/scripts/02-monticello-bootstrap/01-fixLocalMonticello.st --save --quit

	$(target_vm_image_exec) st ./bootstrap/scripts/02-monticello-bootstrap/02-bootstrapMonticello.st --BOOTSTRAP_PACKAGE_CACHE_DIR=$(BOOTSTRAP_CACHE_DIR)/pharo-local/package-cache --save --quit

	$(target_vm_image_exec) eval --save "TraitsBootstrap fixSourceCodeOfTraits"

$(BUILD_DIR)/step-09-bootstrap-monticello-networking/bootstrap.image: $(BUILD_DIR)/step-08-bootstrap-monticello/bootstrap.image $(target_vm_components) $(BUILD_DIR)/step-07-bootstrap-core/PharoV60.sources # TODO add deps on hermes files
	@echo -e '\n    [+] Bootstrapping $(basename $(dir $@))\n'
	@mkdir -p $(dir $@)
	$(save_from_dependency_image)
	@# TODO this was originally open old image, save new image. Is copying the same thing?
	@# cp -r $(dir $<)bootstrap.image $(dir $@)bootstrap.image

	cp $(BUILD_DIR)/step-07-bootstrap-core/PharoV60.sources $(dir $@)PharoV60.sources

	$(target_vm_image_exec) st ./bootstrap/scripts/02-monticello-bootstrap/03-bootstrapMonticelloRemote.st --BOOTSTRAP_PACKAGE_CACHE_DIR=$(BOOTSTRAP_CACHE_DIR)/pharo-local/package-cache --save --quit

$(BUILD_DIR)/step-10-bootstrap-metacello/bootstrap.image: $(BUILD_DIR)/step-09-bootstrap-monticello-networking/bootstrap.image $(target_vm_components) $(BUILD_DIR)/step-07-bootstrap-core/PharoV60.sources # TODO add deps on hermes files
	@echo -e '\n    [+] Bootstrapping $(basename $(dir $@))\n'
	@mkdir -p $(dir $@)
	$(save_from_dependency_image)
	@# cp -r $(dir $<)bootstrap.image $(dir $@)bootstrap.image
	@# TODO cp $(BUILD_DIR)/step-07-bootstrap-core/PharoV60.sources $(dir $@)PharoV60.sources

	$(target_vm_image_exec) st ./bootstrap/scripts/03-metacello-bootstrap/01-loadMetacello.st --save --quit
	$(target_vm_image_exec) eval --save "Metacello new baseline: 'Tonel';repository: 'github://pharo-vcs/tonel:v1.0.16';onWarning: [ :e | Error signal: e messageText in: e signalerContext ]; load: 'core'"


$(BUILD_DIR)/step-11-patch-display-size/bootstrap.image: $(BUILD_DIR)/step-10-bootstrap-metacello/bootstrap.image $(target_vm_components) # TODO add deps on hermes files
	@echo -e '\n    [+] Bootstrapping $(basename $(dir $@))\n'
	@mkdir -p $(dir $@)
	cp -r $(dir $<)bootstrap.image $(dir $@)bootstrap.image

	@# Fix the display size in the image header (position 40 [zero based], 24 for 32-bit image) in older versions we must use octal representation
	printf "\231\002\320\003" > $(BUILD_DIR)/step-12-patch-display-size/displaySize.bin

	@# If TARGET_ARCH is 32, the offset is 24; if TARGET_ARCH is 64, the offset is 40;
	dd if=$(BUILD_DIR)/step-12-patch-display-size/displaySize.bin of=$@ bs=1 seek=$(subst 64,40,$(subst 32,24,$(TARGET_ARCH))) count=4 conv=notrunc

# -----------------------------------------------------
#   Download the target VM (for use with built image)
# -----------------------------------------------------
target_vm: $(target_vm_components)

$(target_vm_components):
	@echo -e '\n    [+] Downloading the $(TARGET_ARCH)-bit Smalltalk virtual machine for use with built image\n'
	@mkdir -p $(dir $@)
	@rm -rf $@
	@# If TARGET_ARCH is 32, the subst will remove 32 to return /
	wget --quiet -O- https://get.pharo.org/$(subst 32,,$(TARGET_ARCH)/)$(TARGET_VM_TYPE)70 | (cd $(BUILD_DIR); bash > /dev/null 2>&1)
	@touch $@

# -----------------------------------------------------
#   Download bootstrapping tools
# -----------------------------------------------------
# We don't need $(BOOTSTRAP_TOOLS_DIR)/pharo-ui for the build since we're not using the UI for building
bootstrap_tools: $(addprefix $(BUILD_DIR)/bootstrap-tools/,bootstrapImage.zip PharoV60sources icon-packs/idea11.zip) $(addprefix $(BOOTSTRAP_TOOLS_DIR)/,pharo pharo-vm)

$(addprefix $(BOOTSTRAP_TOOLS_DIR)/,$(vm_components)):
	@echo -e '\n    [+] Downloading the 64-bit Smalltalk virtual machine to be used for bootstrapping\n'
	@mkdir -p $(dir $@)
	@rm -rf $@
	wget --quiet -O- https://get.pharo.org/vm70 | (cd $(BOOTSTRAP_TOOLS_DIR); bash > /dev/null 2>&1)
	@touch $@

$(BOOTSTRAP_TOOLS_DIR)/bootstrapImage.zip:
	@echo -e '\n    [+] Downloading image used to bootstrap this build\n'
	@mkdir -p $(dir $@)
	$(download) https://github.com/carolahp/PharoBootstrap/releases/download/v1.7.0/bootstrapImage.zip
	@touch $@

$(BUILD_DIR)/step-07-bootstrap-core/PharoV60.sources:
	@echo -e '\n    [+] Downloading old sources file for source condensation step\n'
	@mkdir -p $(dir $@)
	$(download) http://files.pharo.org/sources/PharoV60.sources
	@touch $@

$(BOOTSTRAP_TOOLS_DIR)/icon-packs/idea11.zip:
	@echo -e '\n    [+] Downloading icons for Pharo\n'
	@mkdir -p $(dir $@)
	$(download) https://github.com/pharo-project/pharo-icon-packs/archive/v1.0.0-idea11.zip
	@touch $@

clean:
	rm -rf $(BUILD_DIR)
