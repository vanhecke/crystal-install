#!/usr/bin/env bash

. ./test/helper.sh
. ./share/crystal-install/system.sh

function test_cpu_count()
{
	local count="$(cpu_count)"

	assertNotEquals "did not return a value" "" "$count"
	assertTrue "did not return a positive number" '(( count > 0 ))'
}

SHUNIT_PARENT=$0 . $SHUNIT2
