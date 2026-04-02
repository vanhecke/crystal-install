#!/usr/bin/env bash

. ./test/helper.sh
. ./share/crystal-install/system.sh

function test_resolve_crystal_platform()
{
	resolve_crystal_platform

	assertEquals "did not return 0" 0 $?
	assertNotEquals "did not set \$crystal_platform" "" "$crystal_platform"
}

function test_resolve_crystal_platform_on_current_os()
{
	resolve_crystal_platform

	case "$os_platform" in
		Darwin)
			assertEquals "did not resolve to darwin-universal" \
				     "darwin-universal" "$crystal_platform"
			;;
		Linux)
			case "$os_arch" in
				x86_64)
					assertEquals "did not resolve to linux-x86_64" \
						     "linux-x86_64" "$crystal_platform"
					;;
				aarch64|arm64)
					assertEquals "did not resolve to linux-aarch64" \
						     "linux-aarch64" "$crystal_platform"
					;;
			esac
			;;
	esac
}

SHUNIT_PARENT=$0 . $SHUNIT2
