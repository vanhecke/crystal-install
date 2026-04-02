#!/usr/bin/env bash

. ./test/helper.sh

function setUp()
{
	unset crystal_version
	unset src_dir
	unset install_dir
	unset crystal_url
	unset crystal_archive
	unset crystal_sha256
}

function test_parse_options_with_no_arguments()
{
	parse_options

	assertEquals "did not return 0" 0 $?
	assertNull "did not leave \$crystal_version blank" "$crystal_version"
}

function test_parse_options_with_invalid_options()
{
	parse_options "--foo" >/dev/null 2>&1

	assertEquals "did not return 1" 1 $?
}

function test_parse_options_with_one_argument()
{
	local expected="1.19.1"

	parse_options "$expected"

	assertEquals "did not set \$crystal_version" "$expected" "$crystal_version"
}

function test_parse_options_with_too_many_arguments()
{
	parse_options "1.19.1" "extra" >/dev/null 2>&1

	assertEquals "did not return 1" 1 $?
}

function test_parse_options_with_install_dir()
{
	local expected="/usr/local/"

	parse_options "--install-dir" "$expected" "1.19.1"

	assertEquals "did not set \$install_dir" "$expected" "$install_dir"
}

function test_parse_options_with_system()
{
	local expected="/usr/local"

	parse_options "--system"

	assertEquals "did not set \$install_dir to $expected" "$expected" \
		                                              "$install_dir"
}

function test_parse_options_with_crystals_dir()
{
	local expected="/opt/crystals"

	parse_options "--crystals-dir" "$expected"

	assertEquals "did not set \$crystals_dir" "$expected" "$crystals_dir"
}

function test_parse_options_with_src_dir()
{
	local expected="/tmp"

	parse_options "--src-dir" "$expected" "1.19.1"

	assertEquals "did not set \$src_dir" "$expected" "$src_dir"
}

function test_parse_options_with_url()
{
	local archive="crystal-1.19.1-1-darwin-universal.tar.gz"
	local url="https://example.com/downloads/$archive"

	parse_options "--url" "$url" "1.19.1"

	assertEquals "did not set \$crystal_url" "$url" "$crystal_url"
	assertEquals "did not also set \$crystal_archive" "$archive" "$crystal_archive"
}

function test_parse_options_with_sha256()
{
	local sha256="b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9"

	parse_options "--sha256" "$sha256" "1.19.1"

	assertEquals "did not set \$crystal_sha256" "$sha256" "$crystal_sha256"
}

function test_parse_options_with_cleanup()
{
	parse_options "--cleanup" "1.19.1"

	assertEquals "did not set \$cleanup" 1 $cleanup
}

function test_parse_options_with_package_manager()
{
	local new_package_manager="dnf"

	set_package_manager "apt"

	parse_options "--package-manager" "$new_package_manager"

	assertEquals "did not set \$package_manager" "$new_package_manager" "$package_manager"
}

function test_parse_options_with_no_download()
{
	parse_options "--no-download" "1.19.1"

	assertEquals "did not set \$no_download" 1 $no_download
}

function test_parse_options_with_no_verify()
{
	parse_options "--no-verify" "1.19.1"

	assertEquals "did not set \$no_verify" 1 $no_verify
}

function test_parse_options_with_no_extract()
{
	parse_options "--no-extract" "1.19.1"

	assertEquals "did not set \$no_extract" 1 $no_extract
	assertEquals "did not set \$no_verify" 1 $no_verify
	assertEquals "did not set \$no_download" 1 $no_download
}

function test_parse_options_with_no_install_deps()
{
	parse_options "--no-install-deps" "1.19.1"

	assertEquals "did not set \$no_install_deps" 1 $no_install_deps
}

function test_parse_options_with_no_reinstall()
{
	parse_options "--no-reinstall" "1.19.1"

	assertEquals "did not set \$no_reinstall" 1 $no_reinstall
}

function test_parse_options_with_update()
{
	parse_options "--update" "1.19.1" 2>/dev/null

	assertEquals "did not set \$force_update" 1 $force_update
}

SHUNIT_PARENT=$0 . $SHUNIT2
