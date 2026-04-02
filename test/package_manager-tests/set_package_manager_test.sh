#!/usr/bin/env bash

. ./test/helper.sh
. ./share/crystal-install/dependencies.sh

function test_set_package_manager_with_apt()
{
	set_package_manager "apt"

	assertEquals "did not return 0" $? 0
	assertEquals "did not set package_manager" "apt" "$package_manager"
}

function test_set_package_manager_with_dnf()
{
	set_package_manager "dnf"

	assertEquals "did not return 0" $? 0
	assertEquals "did not set package_manager" "dnf" "$package_manager"
}

function test_set_package_manager_with_yum()
{
	set_package_manager "yum"

	assertEquals "did not return 0" $? 0
	assertEquals "did not set package_manager" "yum" "$package_manager"
}

function test_set_package_manager_with_zypper()
{
	set_package_manager "zypper"

	assertEquals "did not return 0" $? 0
	assertEquals "did not set package_manager" "zypper" "$package_manager"
}

function test_set_package_manager_with_pacman()
{
	set_package_manager "pacman"

	assertEquals "did not return 0" $? 0
	assertEquals "did not set package_manager" "pacman" "$package_manager"
}

function test_set_package_manager_with_pkg()
{
	set_package_manager "pkg"

	assertEquals "did not return 0" $? 0
	assertEquals "did not set package_manager" "pkg" "$package_manager"
}

function test_set_package_manager_with_homebrew()
{
	set_package_manager "brew"

	assertEquals "did not return 0" $? 0
	assertEquals "did not set package_manager" "brew" "$package_manager"
}

function test_set_package_manager_with_macports()
{
	set_package_manager "port"

	assertEquals "did not return 0" $? 0
	assertEquals "did not set package_manager" "port" "$package_manager"
}

function test_set_package_manager_with_xbps()
{
	set_package_manager "xbps"

	assertEquals "did not return 0" $? 0
	assertEquals "did not set package_manager" "xbps" "$package_manager"
}

function test_set_package_manager_with_unknown_package_manager()
{
	set_package_manager "foo" 2>/dev/null

	assertEquals "did not return 1" $? 1
}

SHUNIT_PARENT=$0 . $SHUNIT2
