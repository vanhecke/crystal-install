#!/usr/bin/env bash

. ./test/helper.sh
. ./share/crystal-install/dependencies.sh

function test_set_crystal_dependencies_with_brew()
{
	package_manager="brew"
	set_crystal_dependencies

	assertTrue "did not set dependencies for brew" \
		   '(( ${#crystal_dependencies[@]} > 0 ))'
}

function test_set_crystal_dependencies_with_apt()
{
	package_manager="apt"
	set_crystal_dependencies

	assertTrue "did not set dependencies for apt" \
		   '(( ${#crystal_dependencies[@]} > 0 ))'
}

function test_set_crystal_dependencies_with_dnf()
{
	package_manager="dnf"
	set_crystal_dependencies

	assertTrue "did not set dependencies for dnf" \
		   '(( ${#crystal_dependencies[@]} > 0 ))'
}

function test_set_crystal_dependencies_with_pacman()
{
	package_manager="pacman"
	set_crystal_dependencies

	assertTrue "did not set dependencies for pacman" \
		   '(( ${#crystal_dependencies[@]} > 0 ))'
}

function test_set_crystal_dependencies_with_zypper()
{
	package_manager="zypper"
	set_crystal_dependencies

	assertTrue "did not set dependencies for zypper" \
		   '(( ${#crystal_dependencies[@]} > 0 ))'
}

function tearDown()
{
	crystal_dependencies=()
}

SHUNIT_PARENT=$0 . $SHUNIT2
