#!/usr/bin/env bash

. ./test/helper.sh

function test_crystals_dir()
{
	if (( UID == 0 )); then
		assertEquals "did not correctly default crystals_dir" \
			     "/opt/crystals" \
			     "$crystals_dir"
	else
		assertEquals "did not correctly default crystals_dir" \
			     "$HOME/.crystals" \
			     "$crystals_dir"
	fi
}

function test_src_dir()
{
	if (( UID == 0 )); then
		assertEquals "did not correctly default src_dir" \
			     "/usr/local/src" \
			     "$src_dir"
	else
		assertEquals "did not correctly default src_dir" \
			     "$HOME/src" \
			     "$src_dir"
	fi
}

function test_crystal_install_cache_dir()
{
	assertNotEquals "did not set crystal_install_cache_dir" \
			"" "$crystal_install_cache_dir"
}

SHUNIT_PARENT=$0 . $SHUNIT2
