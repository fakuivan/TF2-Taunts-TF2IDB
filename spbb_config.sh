#!/usr/bin/env bash

# Project info
PROJECT_SHORTNAME="tf2_taunts_tf2idb"
PROJECT_URL="https://github.com/fakuivan/TF2-Taunts-TF2IDB"
PROJECT_BUILD_OPTIONS=("tf2idb" "tf2ii")
## The selected option (index in  the PROJECT_BUILD_OPTIONS array) can be found on $BUILD_OPTION

project_format_version_string () { 
	local tag="$1"
	local commit="$2"
	echo "$tag.$commit-${PROJECT_BUILD_OPTIONS[$BUILD_OPTION]}" 
}

project_format_release_name () {
	echo "$PROJECT_SHORTNAME-${PROJECT_BUILD_OPTIONS[$BUILD_OPTION]}"
}

## Project root at $PROJECT_ROOT
## Path to the https://github.com/fakuivan/sp_buildtools repo
PROJECT_BUILDTOOLS_PATH="$PROJECT_ROOT/.buildtools"

# Updater info, change these if you want to get updates from another source
UPDATER_REPO="sm_updater_plugins"
UPDATER_USER="fakuivan"
UPDATER_USER_NAME="$UPDATER_USER"
UPDATER_USER_EMAIL="$UPDATER_USER@gmail.com"
UPDATER_MANIFEST_PATH="updater.txt"
UPDATER_DEFAULT_BRANCH="default"

updater_format_branch () {
	local project_branch="$1"
	if [[ "$project_branch" == "master" ]]; then 		echo "master";	return 0; fi
	if [[ "$project_branch" == "updater" ]]; then 		echo "master";	return 0; fi
	if [[ "$project_branch" == "updater_test" ]]; then 	echo "test";	return 0; fi
	if [[ "$project_branch" == "dev" ]]; then 			echo "dev";		return 0; fi
	echo "$UPDATER_DEFAULT_BRANCH"
	return 1;
}

updater_format_notes () {
	local version="$1"
	# This will be split by "\n" and then sent to "updater_script_gen.py"
	# In practice each echo command will be translated into separate "Notes" sections
	echo "Version $version is out!" 
	echo "Go to $PROJECT_URL to see the changes"
}

updater_format_manifest_url () {
	# Because we use a git provider for our updates, we can map project branches
	# to branches on the updates repository. This isn't how spbb is set up to work with
	# the manifest generator (the URL is supposed to be the same for one project), because
	# of this, we'll need to export the custom variable ``PROJECT_BRANCH``, setting it to
	# the appropriate branch name (``export PROJECT_BRANCH="branch-name"``) 
	# before running spbb. If said branch is not a validated by ``updater_format_branch``,
	# then ``UPDATER_DEFAULT_BRANCH`` will be used as the branch for the updater URL.

	local branch="$(updater_format_branch "$PROJECT_BRANCH")"
	# You might want to change this if you use another site to deploy updates
	echo "https://raw.githubusercontent.com/$UPDATER_USER/$UPDATER_REPO/$branch/$(project_format_release_name)/$UPDATER_MANIFEST_PATH"
}

# Package info
PACKAGE_PATH="$PROJECT_ROOT/.package"
## The fury of ``rm -rf`` will fall over this directory, just don't put "/" here
PACKAGE_ROOT_PATH="$PACKAGE_PATH/root"
PACKAGE_COPY_DIRS=(
	"$PROJECT_ROOT/scripting"
	"$PROJECT_ROOT/gamedata"
	"$PROJECT_ROOT/translations")
PACKAGE_SOURCE_FILES="$PACKAGE_ROOT_PATH/scripting"
PACKAGE_INCLUDE_FILES="$PACKAGE_SOURCE_FILES/include"
PACKAGE_BINARY_FILES="$PACKAGE_ROOT_PATH/plugins"
PACKAGE_PROJECT_SPECIFIC_INCLUDES="$PACKAGE_SOURCE_FILES/include/$PROJECT_SHORTNAME"
## Everything in here will be archived
PACKAGE_ARCHIVE_BASE_DIR=$PACKAGE_ROOT_PATH

package_format_archive_path () {
	local tag="$1"
	local commit="$2"
	echo "$PACKAGE_PATH/$PROJECT_SHORTNAME-n$commit-${PROJECT_BUILD_OPTIONS[$BUILD_OPTION]}.zip"
}

# Compilation info
## Complier path at $COMP_ROOT
COMP_PLUGINS=(
	"$PACKAGE_SOURCE_FILES/tf2_taunts_tf2idb.sp")
## Windows Subsystem for Linux support
if [[ -x '/mnt/c/Windows/explorer.exe' ]]; then
	COMP_COMPILER_EXTENSION='.exe'
else
	COMP_COMPILER_EXTENSION=''
fi

COMP_COMPILER_PATH="$COMP_ROOT/spcomp$COMP_COMPILER_EXTENSION"
COMP_COMPILER_INCLUDE_PATH="$COMP_ROOT/include"
COMP_THIRD_PARTY_INCLUDES="$PROJECT_ROOT/.libraries"
COMP_INCLUDE_DIRS=(
	"$COMP_COMPILER_INCLUDE_PATH"
	"$PACKAGE_INCLUDE_FILES"
	"$PACKAGE_PROJECT_SPECIFIC_INCLUDES")

## Custom function that gets called before compilation
comp_func_pre () {
	local third_party_include_files=(
		"$COMP_THIRD_PARTY_INCLUDES/updater/include/updater.inc"
		"$COMP_THIRD_PARTY_INCLUDES/tf2items/pawn/tf2items.inc"
		"$COMP_THIRD_PARTY_INCLUDES/tf2idb/scripting/include/tf2idb.inc"
		"$COMP_THIRD_PARTY_INCLUDES/tf2ii/scripting/include/tf2itemsinfo.inc")
	logger_subtask "1" "Copying project include files to package..."
	logger_subtask "1" "Failed to copy include files" \
		"$(cp "${third_party_include_files[@]}" "$PACKAGE_INCLUDE_FILES" 2>&1 >/dev/null)" $?
	if [[ ! $? -eq 0 ]]; then return 1; fi
	logger_subtask "1" "Done."
}

## Custom function that gets called after compilation was successful
comp_func_post () {
	return 0;
}

comp_format_output_file () {
	local file_to_compile="$1"
	local file_name=$(basename "$file_to_compile")
	echo "$PACKAGE_BINARY_FILES/${file_name%.*}.smx"
}

comp_format_extra_arguments () {
	# The same behavior for ``updater_format_notes`` applies here
	# Each line will be interpreted as a discrete argument
	local file_to_compile="$1"
	local tag="$2"
	local commit="$3"
	if [[ "${PROJECT_BUILD_OPTIONS[$BUILD_OPTION]}" == "tf2ii" ]]; then 
		echo '_USE_TF2II_INSTEAD_OF_TF2IDB=' 
	else 
		echo ''
	fi
}
