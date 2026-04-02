#!/usr/bin/env bash

. ./test/helper.sh
. ./share/crystal-install/system.sh

function test_downloader()
{
	assertNotEquals "did not detect wget or curl" "" "$downloader"
}

SHUNIT_PARENT=$0 . $SHUNIT2
