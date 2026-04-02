#!/usr/bin/env bash

. ./test/helper.sh
. ./share/crystal-install/util.sh

function test_absolute_path_with_absolute_path()
{
	local path="/usr/local/bin"

	assertEquals "did not return the absolute path as-is" \
		     "$path" "$(absolute_path "$path")"
}

function test_absolute_path_with_relative_path()
{
	local path="foo/bar"
	local expected="${PWD}/${path}"

	assertEquals "did not prepend PWD" \
		     "$expected" "$(absolute_path "$path")"
}

SHUNIT_PARENT=$0 . $SHUNIT2
