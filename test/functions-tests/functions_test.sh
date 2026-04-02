#!/usr/bin/env bash

. ./test/helper.sh

function setUp()
{
	crystal_version="1.19.1"
}

function test_resolve_crystal_archive()
{
	resolve_crystal_archive

	assertEquals "did not return 0" 0 $?
	assertNotEquals "did not set crystal_archive" "" "$crystal_archive"
	assertTrue "archive does not contain version" \
		   '[[ "$crystal_archive" == *"1.19.1"* ]]'
	assertTrue "archive does not end with .tar.gz" \
		   '[[ "$crystal_archive" == *.tar.gz ]]'
}

function test_resolve_crystal_archive_on_current_platform()
{
	resolve_crystal_archive

	case "$os_platform" in
		Darwin)
			assertTrue "darwin archive not darwin-universal" \
				   '[[ "$crystal_archive" == *"darwin-universal"* ]]'
			;;
		Linux)
			assertTrue "linux archive does not contain linux" \
				   '[[ "$crystal_archive" == *"linux-"* ]]'
			;;
	esac
}

function test_resolve_crystal_url()
{
	resolve_crystal_archive
	resolve_crystal_url

	assertNotEquals "did not set crystal_url" "" "$crystal_url"
	assertTrue "url does not point to github releases" \
		   '[[ "$crystal_url" == "https://github.com/crystal-lang/crystal/releases/download/"* ]]'
	assertTrue "url does not contain version" \
		   '[[ "$crystal_url" == *"1.19.1"* ]]'
	assertTrue "url does not end with archive name" \
		   '[[ "$crystal_url" == *"$crystal_archive" ]]'
}

function tearDown()
{
	unset crystal_version crystal_archive crystal_url crystal_platform
}

SHUNIT_PARENT=$0 . $SHUNIT2
