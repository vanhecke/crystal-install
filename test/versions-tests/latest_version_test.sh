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

function test_latest_version_with_prefix()
{
	local expected="1.18.2"

	assertEquals "did not return the last matching version" \
		     "$expected" \
		     "$(latest_version "1.18")"
}

function test_latest_version_with_empty_string()
{
	local expected="1.19.1"

	assertEquals "did not return the last version" \
		     "$expected" \
		     "$(latest_version "")"
}

function test_latest_version_with_unknown_version()
{
	latest_version "9.9"

	assertEquals "did not return an error" 1 $?
}

function oneTimeTearDown()
{
	rm -rf "$test_dir"
}

SHUNIT_PARENT=$0 . $SHUNIT2
