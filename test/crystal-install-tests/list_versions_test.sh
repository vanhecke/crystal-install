#!/usr/bin/env bash

. ./test/helper.sh

function oneTimeSetUp()
{
	# Create a mock versions cache
	mkdir -p "$crystal_install_cache_dir"
	cat > "$crystal_install_cache_dir/versions.txt" <<-EOF
		1.18.0
		1.19.0
		1.19.1
	EOF
}

function test_list_versions()
{
	local output="$(list_versions 2>&1)"

	assertTrue "did not include version numbers" \
		   '[[ "$output" == *"1.19.1"* ]]'
}

function oneTimeTearDown()
{
	rm -rf "$crystal_install_cache_dir"
}

SHUNIT_PARENT=$0 . $SHUNIT2
