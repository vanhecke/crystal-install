#!/usr/bin/env bash

. ./test/helper.sh
. ./share/crystal-install/checksums.sh

test_dir="$test_fixtures_dir/checksums_test"

function oneTimeSetUp()
{
	mkdir -p "$test_dir"
	echo -n "hello" > "$test_dir/test_file.txt"

	# Known SHA256 of "hello" (no newline)
	expected_sha256="2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824"
}

function test_compute_sha256()
{
	local actual
	actual="$(compute_sha256 "$test_dir/test_file.txt")"

	assertEquals "did not compute correct SHA256" \
		     "$expected_sha256" "$actual"
}

function test_verify_sha256_with_correct_hash()
{
	verify_sha256 "$test_dir/test_file.txt" "$expected_sha256"

	assertEquals "did not return 0 for correct hash" 0 $?
}

function test_verify_sha256_with_incorrect_hash()
{
	verify_sha256 "$test_dir/test_file.txt" "0000000000000000" 2>/dev/null

	assertEquals "did not return 1 for incorrect hash" 1 $?
}

function test_verify_sha256_with_empty_hash()
{
	# Empty hash should warn but not fail
	verify_sha256 "$test_dir/test_file.txt" "" 2>/dev/null

	assertEquals "did not return 0 for empty hash" 0 $?
}

function test_cache_and_lookup_sha256()
{
	crystal_install_cache_dir="$test_dir/cache"
	mkdir -p "$crystal_install_cache_dir"

	cache_sha256 "1.19.1" "crystal-1.19.1.tar.gz" "$expected_sha256"

	local result
	result="$(lookup_cached_sha256 "crystal-1.19.1.tar.gz")"

	assertEquals "did not look up cached checksum" \
		     "$expected_sha256" "$result"
}

function test_lookup_cached_sha256_when_not_cached()
{
	crystal_install_cache_dir="$test_dir/empty_cache"

	lookup_cached_sha256 "nonexistent.tar.gz"

	assertEquals "did not return 1 for missing cache" 1 $?
}

function oneTimeTearDown()
{
	rm -rf "$test_dir"
}

SHUNIT_PARENT=$0 . $SHUNIT2
