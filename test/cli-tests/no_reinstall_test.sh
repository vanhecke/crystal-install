#!/usr/bin/env bash

. ./test/helper.sh

test_install_dir="$test_fixtures_dir/no_reinstall_test"

function setUp()
{
	mkdir -p "$test_install_dir/bin"
	touch "$test_install_dir/bin/crystal"
	chmod +x "$test_install_dir/bin/crystal"

	# Create a mock versions cache so crystal-install doesn't try to fetch
	mkdir -p "$crystal_install_cache_dir"
	echo "1.19.1" > "$crystal_install_cache_dir/versions.txt"
}

function test_no_reinstall_when_crystal_executable_exists()
{
	local output="$(crystal-install --install-dir "$test_install_dir" --no-reinstall --no-install-deps 1.19.1 2>&1)"

	assertEquals "did not return 0" 0 $?
	assertTrue "did not print a message to STDOUT" \
		'[[ "$output" == *"already installed"* ]]'
}

function tearDown()
{
	rm -rf "$test_install_dir"
}

function oneTimeTearDown()
{
	rm -rf "$crystal_install_cache_dir"
}

SHUNIT_PARENT=$0 . $SHUNIT2
