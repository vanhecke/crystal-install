#!/usr/bin/env bash

. ./test/helper.sh
. ./share/crystal-install/util.sh

test_dir="$test_fixtures_dir/download_test"
test_url="https://raw.githubusercontent.com/crystal-lang/crystal/master/LICENSE"
test_dest="$test_dir/download.txt"

function test_download()
{
	download "$test_url" "$test_dest" 2>/dev/null

	assertEquals "did not return 0" 0 $?
	assertTrue "did not create the file" '[[ -f "$test_dest" ]]'
}

function test_download_skips_existing()
{
	mkdir -p "$test_dir"
	echo "existing" > "$test_dest"

	download "$test_url" "$test_dest" 2>/dev/null

	local content
	content="$(cat "$test_dest")"

	assertEquals "did not skip the existing file" "existing" "$content"
}

function tearDown()
{
	rm -rf "$test_dir"
}

SHUNIT_PARENT=$0 . $SHUNIT2
