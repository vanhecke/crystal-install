#!/usr/bin/env bash

. ./test/helper.sh
. ./share/crystal-install/system.sh

function test_package_manager()
{
	case "$os_platform" in
		Darwin|Linux)
			assertNotEquals "did not set \$package_manager" "" "$package_manager"
			;;
		*)
			# On unknown platforms, package_manager may be empty
			return
			;;
	esac
}

SHUNIT_PARENT=$0 . $SHUNIT2
