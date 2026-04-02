#!/usr/bin/env bash

unset GREP_OPTIONS GREP_COLOR GREP_COLORS

if   command -v sha256sum > /dev/null; then sha256sum="sha256sum"
elif command -v sha256 > /dev/null;    then sha256sum="sha256 -r"
elif command -v shasum > /dev/null;    then sha256sum="shasum -a 256"
fi

#
# Computes SHA256 of a file.
#
function compute_sha256()
{
	local file="$1"

	if [[ -z "$sha256sum" ]]; then
		error "could not find sha256 checksum utility"
		return 1
	fi

	debug "$sha256sum $file"
	local output
	output="$($sha256sum "$file")"

	echo -n "${output%% *}"
}

#
# Verifies a file's SHA256 against an expected value.
#
function verify_sha256()
{
	local file="$1"
	local expected="$2"

	if [[ -z "$expected" ]]; then
		warn "No SHA256 checksum for ${file##*/}"
		return
	fi

	local actual
	actual="$(compute_sha256 "$file")"

	if [[ "$actual" != "$expected" ]]; then
		error "Invalid SHA256 checksum for ${file##*/}"
		error "  expected: $expected"
		error "  actual:   $actual"
		return 1
	fi
}

#
# Caches a computed SHA256 checksum.
#
function cache_sha256()
{
	local version="$1"
	local archive="$2"
	local hash="$3"
	local cache_file="$crystal_install_cache_dir/checksums.sha256"

	mkdir -p "$crystal_install_cache_dir" || return $?

	# Avoid duplicate entries
	if [[ -f "$cache_file" ]] && grep -q "  $archive$" "$cache_file" 2>/dev/null; then
		return
	fi

	echo "$hash  $archive" >> "$cache_file"
}

#
# Looks up a cached SHA256 checksum.
#
function lookup_cached_sha256()
{
	local archive="$1"
	local cache_file="$crystal_install_cache_dir/checksums.sha256"

	if [[ ! -f "$cache_file" ]]; then
		return 1
	fi

	local output
	output="$(grep "  $archive$" "$cache_file")"

	if [[ -n "$output" ]]; then
		echo -n "${output%% *}"
	else
		return 1
	fi
}
