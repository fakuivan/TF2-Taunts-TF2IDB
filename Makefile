SPCOMP=$(SM_SCRIPTING_PATH)/spcomp64
INCLUDE_DIRS=-i$(SM_SCRIPTING_PATH)/include -i./scripting/include
AUTOGEN_INCLUDES=scripting/include/autoversioning.inc \
                 scripting/include/updater_helper.inc
LIBS_INCLUDE_FILES=scripting/include/tf2idb.inc \
                   scripting/include/tf2itemsinfo.inc \
                   scripting/include/tf2items.inc \
                   scripting/include/updater.inc
PLUGIN_ITEMS_API=$(shell test '$(PLUGIN_USE_TF2II)' = true && echo tf2ii || echo tf2idb)
PLUGIN_DEFINES=$(shell test '$(PLUGIN_ITEMS_API)' = tf2ii && echo _USE_TF2II_INSTEAD_OF_TF2IDB= || echo)

default: all

env-guard-%:
	@ if [ -z "$${${*}+x}" ]; then \
	    echo "Environment variable $* not set"; \
	    exit 1; \
	fi

smlib: env-guard-SM_SCRIPTING_PATH
	test -x $(SPCOMP)

plugins:
	mkdir -p plugins

PLUGIN_FILES=plugins/tf2_taunts_tf2idb.smx
plugins/%.smx: smlib plugins $(LIBS_INCLUDE_FILES)
	$(SPCOMP) scripting/$*.sp $(INCLUDE_DIRS) $(PLUGIN_DEFINES) -o$@


# Versioning
AUTOVERSIONING_FEATURES=scripting/include/autoversioning.inc
GIT_COMMIT_NUMBER?=$(shell git rev-list --count HEAD)
GIT_TAG?=$(shell git describe --tags HEAD)
GIT_VERSION=$(GIT_TAG).$(GIT_COMMIT_NUMBER)-$(PLUGIN_ITEMS_API)
scripting/include/autoversioning.inc:
	echo \#if defined _autoversioning_included > $@.temp
	echo \ \#endinput >> $@.temp
	echo \#endif >> $@.temp
	echo \#define _autoversioning_included >> $@.temp
	echo \#define AUTOVERSIONING_ENABLED >> $@.temp
	echo \#define AUTOVERSIONING_TAG \"$(GIT_TAG)\" >> $@.temp
	echo \#define AUTOVERSIONING_COMMIT \"$(GIT_COMMIT_NUMBER)\" >> $@.temp
	mv $@.temp $@

print-version:
	@echo $(GIT_VERSION)

# Package
OUTPUT_DIR_ALL=.package
$(OUTPUT_DIR_ALL):
	mkdir -p $@

OUTPUT_DIR=$(OUTPUT_DIR_ALL)/$(GIT_VERSION)
$(OUTPUT_DIR): $(OUTPUT_DIR_ALL) $(PLUGIN_FILES)
	tempdir=$$(mktemp -d); \
	cp -r plugins scripting translations gamedata $$tempdir; \
	mv $$tempdir $@

package: $(OUTPUT_DIR)

print-output-dir:
	@echo $(OUTPUT_DIR)

# Updater
UPDATER_INCLUDES=scripting/include/updater_helper.inc
scripting/include/updater_helper.inc: env-guard-UPDATER_URL
	echo \#if defined _updater_helper_included > $@.temp
	echo \ \#endinput >> $@.temp
	echo \#endif >> $@.temp
	echo \#define _updater_helper_included >> $@.temp
	echo \#define UPDATER_ENABLED
	echo \#define UPDATER_HELPER_URL \""$$UPDATER_URL"\" >> $@.temp
	mv $@.temp $@

$(OUTPUT_DIR)/updater.txt: $(UPDATER_INCLUDES) $(OUTPUT_DIR) \
                           env-guard-UPDATER_NEWS_URL
	test -f scripting/include/updater_helper.inc && \
	    python3 ".buildtools/tony_updater/updater_script_gen.py" \
	        --sm_path "$(OUTPUT_DIR)" \
	        --version "$(GIT_VERSION)" \
	        --notes "Version $(GIT_VERSION) is out!" \
	                "Go to $$UPDATER_NEWS_URL to see the changes" \
	        --output "$@"

scripting/include/tf2idb.inc:
	cp .libs/tf2idb/$@ $@

scripting/include/tf2itemsinfo.inc:
	cp .libs/tf2itemsinfo/$@ $@

scripting/include/tf2items.inc:
	cp .libs/tf2items/pawn/tf2items.inc $@

scripting/include/updater.inc:
	cp .libs/updater/include/updater.inc $@

clean-version:
	rm -rf $(PLUGIN_FILES) \
	       $(AUTOGEN_INCLUDES) \
	       $(OUTPUT_DIR)

clean-notlibs: clean-version
	rm -rf $(OUTPUT_DIR_ALL)

clean: clean-notlibs
	rm -rf $(LIBS_INCLUDE_FILES)


all: $(AUTOVERSIONING_FEATURES) \
     $(UPDATER_INCLUDES) \
     $(PLUGIN_FILES) \
     $(OUTPUT_DIR) \
     $(OUTPUT_DIR)/updater.txt

# We don't want updater stuff on a dev build
dev: $(AUTOVERSIONING_FEATURES) \
     $(PLUGIN_FILES)