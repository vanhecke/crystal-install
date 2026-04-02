#!/usr/bin/env bash

. ./test/helper.sh

function setUp()
{
	crystal_version="1.19.1"

	# Create a mock versions cache so init() can resolve
	mkdir -p "$crystal_install_cache_dir"
	cat > "$crystal_install_cache_dir/versions.txt" <<-EOF
		1.18.0
		1.18.1
		1.18.2
		1.19.0
		1.19.1
	EOF
}

function test_init()
{
	init

	assertEquals "did not return 0" 0 $?
}

function test_init_resolves_version()
{
	crystal_version="1.19"
	init

	assertEquals "did not resolve partial version" "1.19.1" "$crystal_version"
}

function test_init_with_unknown_version()
{
	crystal_version="9999"

	local output=$(init 2>&1)

	assertTrue "did not print a warning" \
		   '[[ $output == *"Unknown crystal version"* ]]'
}

function test_init_sets_install_dir()
{
	init

	assertEquals "did not correctly default install_dir" \
		     "$crystals_dir/crystal-1.19.1" \
		     "$install_dir"
}

function test_init_preserves_custom_install_dir()
{
	install_dir="/custom/path"
	init

	assertEquals "did not preserve install_dir" "/custom/path" "$install_dir"
}

function test_init_preserves_custom_url()
{
	local url="https://example.com/crystal.tar.gz"
	crystal_url="$url"
	init

	assertEquals "did not preserve crystal_url" "$url" "$crystal_url"
}

function test_init_preserves_custom_sha256()
{
	local sha="abc123"
	crystal_sha256="$sha"
	init

	assertEquals "did not preserve crystal_sha256" "$sha" "$crystal_sha256"
}

function test_init_sets_archive()
{
	init

	assertNotEquals "did not set crystal_archive" "" "$crystal_archive"
	assertTrue "archive does not contain version" \
		   '[[ "$crystal_archive" == *"1.19.1"* ]]'
}

function test_init_sets_url()
{
	init

	assertNotEquals "did not set crystal_url" "" "$crystal_url"
	assertTrue "url does not point to github" \
		   '[[ "$crystal_url" == *"github.com"* ]]'
}

function tearDown()
{
	unset install_dir crystal_version crystal_url crystal_archive crystal_sha256
}

function oneTimeTearDown()
{
	rm -rf "$crystal_install_cache_dir"
}

SHUNIT_PARENT=$0 . $SHUNIT2
