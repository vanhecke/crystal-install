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

function test_resolve_version_with_latest()
{
	assertEquals "did not resolve 'latest' to newest version" \
		     "1.19.1" \
		     "$(resolve_version "latest")"
}

function test_resolve_version_with_partial()
{
	assertEquals "did not resolve partial version" \
		     "1.18.2" \
		     "$(resolve_version "1.18")"
}

function test_resolve_version_with_exact()
{
	assertEquals "did not return exact version" \
		     "1.19.0" \
		     "$(resolve_version "1.19.0")"
}

function test_resolve_version_with_empty()
{
	assertEquals "did not resolve empty to latest" \
		     "1.19.1" \
		     "$(resolve_version "")"
}

function oneTimeTearDown()
{
	rm -rf "$test_dir"
}

SHUNIT_PARENT=$0 . $SHUNIT2
