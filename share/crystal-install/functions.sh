#!/usr/bin/env bash

#
# Resolves the Crystal archive filename for the current platform and version.
#
function resolve_crystal_archive()
{
	resolve_crystal_platform || return $?

	crystal_archive="crystal-${crystal_version}-1-${crystal_platform}.tar.gz"
}

#
# Resolves the download URL for the Crystal archive.
#
function resolve_crystal_url()
{
	crystal_url="https://github.com/crystal-lang/crystal/releases/download/${crystal_version}/${crystal_archive}"
}

#
# Ensures the install directory exists.
#
function pre_install()
{
	mkdir -p "$install_dir" || return $?
}

#
# Install Crystal's runtime dependencies.
#
function install_deps()
{
	set_crystal_dependencies

	if (( ${#crystal_dependencies[@]} > 0 )); then
		log "Installing dependencies for crystal $crystal_version ..."
		install_packages "${crystal_dependencies[@]}" || return $?
	fi
}

#
# Download the Crystal archive.
#
function download_crystal()
{
	log "Downloading $crystal_url into $src_dir ..."
	download "$crystal_url" "$src_dir/$crystal_archive" || return $?
}

#
# Verifies the Crystal archive SHA256 checksum.
#
function verify_crystal()
{
	log "Verifying $crystal_archive ..."

	local file="$src_dir/$crystal_archive"

	# Use user-provided checksum, or look up from cache
	if [[ -z "$crystal_sha256" ]]; then
		crystal_sha256="$(lookup_cached_sha256 "$crystal_archive")"
	fi

	if [[ -n "$crystal_sha256" ]]; then
		verify_sha256 "$file" "$crystal_sha256" || return $?
	else
		# No known checksum — compute and cache for future verification
		local computed
		computed="$(compute_sha256 "$file")"

		if [[ -n "$computed" ]]; then
			log "Computed SHA256: $computed"
			cache_sha256 "$crystal_version" "$crystal_archive" "$computed"
		fi
	fi
}

#
# Extract the Crystal archive.
#
function extract_crystal()
{
	log "Extracting $crystal_archive to $src_dir ..."
	extract "$src_dir/$crystal_archive" "$src_dir" || return $?

	# Discover the extracted directory name dynamically
	crystal_build_dir=""
	for dir in "$src_dir"/crystal-"${crystal_version}"*/; do
		if [[ -d "$dir" ]]; then
			crystal_build_dir="${dir%/}"
			break
		fi
	done

	if [[ -z "$crystal_build_dir" ]] || [[ ! -d "$crystal_build_dir" ]]; then
		error "Could not find extracted Crystal directory in $src_dir"
		return 1
	fi

	debug "Extracted to: $crystal_build_dir"
}

#
# Install Crystal by copying the extracted files into the install directory.
#
function install_crystal()
{
	log "Installing crystal $crystal_version into $install_dir ..."
	copy_into "$crystal_build_dir" "$install_dir" || return $?
}

#
# Verify the installed crystal binary works.
#
function post_install()
{
	if [[ -x "$install_dir/bin/crystal" ]]; then
		local installed_version
		installed_version="$("$install_dir/bin/crystal" --version 2>&1 | head -1)"
		log "Installed: $installed_version"
	else
		warn "crystal binary not found at $install_dir/bin/crystal"
	fi
}

#
# Remove downloaded archive and unpacked source.
#
function cleanup_source()
{
	if [[ -f "$src_dir/$crystal_archive" ]]; then
		log "Removing $src_dir/$crystal_archive ..."
		run rm "$src_dir/$crystal_archive" || return $?
	fi

	if [[ -n "$crystal_build_dir" ]] && [[ -d "$crystal_build_dir" ]]; then
		log "Removing $crystal_build_dir ..."
		run rm -rf "$crystal_build_dir" || return $?
	fi
}
