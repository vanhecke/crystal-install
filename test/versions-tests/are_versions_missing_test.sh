#!/usr/bin/env bash

. ./test/helper.sh
. ./share/crystal-install/versions.sh

test_dir="$test_fixtures_dir/versions_test"

function test_are_versions_missing_when_cache_does_not_exist()
{
	crystal_versions_cache="$test_dir/nonexistent.txt"

	are_versions_missing

	assertEquals "did not return 0 (missing)" 0 $?
}

function test_are_versions_missing_when_cache_exists()
{
	mkdir -p "$test_dir"
	echo "1.19.1" > "$test_dir/versions.txt"
	crystal_versions_cache="$test_dir/versions.txt"

	are_versions_missing

	assertEquals "did not return 1 (not missing)" 1 $?
}

function oneTimeTearDown()
{
	rm -rf "$test_dir"
}

SHUNIT_PARENT=$0 . $SHUNIT2
