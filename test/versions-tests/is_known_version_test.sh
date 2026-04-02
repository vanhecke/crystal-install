#!/usr/bin/env bash

. ./test/helper.sh
. ./share/crystal-install/versions.sh

test_dir="$test_fixtures_dir/versions_test"

function oneTimeSetUp()
{
	mkdir -p "$test_dir"

	cat > "$test_dir/versions.txt" <<-EOF
		1.18.0
		1.18.1
		1.18.2
		1.19.0
		1.19.1
	EOF

	crystal_versions_cache="$test_dir/versions.txt"
}

function test_is_known_version()
{
	is_known_version "1.19.1"

	assertEquals "did not find the version" 0 $?
}

function test_is_known_version_with_empty_version()
{
	is_known_version ""

	assertEquals "did not return an error" 1 $?
}

function test_is_known_version_with_invalid_version()
{
	is_known_version "9.9.9"

	assertEquals "did not return an error" 1 $?
}

function oneTimeTearDown()
{
	rm -rf "$test_dir"
}

SHUNIT_PARENT=$0 . $SHUNIT2
