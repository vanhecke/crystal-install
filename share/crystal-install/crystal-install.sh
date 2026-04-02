#!/usr/bin/env bash

shopt -s extglob

crystal_install_version="0.1.0"
crystal_install_dir="${BASH_SOURCE[0]%/*}"
crystal_install_cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/crystal-install"

system_dir="/usr/local"

if (( UID == 0 )); then
	src_dir="${CRYSTAL_INSTALL_SRC_DIR:-$system_dir/src}"
	crystals_dir="${CRYSTAL_INSTALL_CRYSTALS_DIR:-/opt/crystals}"
else
	src_dir="${CRYSTAL_INSTALL_SRC_DIR:-$HOME/src}"
	crystals_dir="${CRYSTAL_INSTALL_CRYSTALS_DIR:-$HOME/.crystals}"
fi

source "$crystal_install_dir/logging.sh"
source "$crystal_install_dir/system.sh"
source "$crystal_install_dir/util.sh"
source "$crystal_install_dir/checksums.sh"
source "$crystal_install_dir/versions.sh"
source "$crystal_install_dir/dependencies.sh"
source "$crystal_install_dir/functions.sh"

#
# Prints usage information for crystal-install.
#
function usage()
{
	cat <<USAGE
usage: crystal-install [OPTIONS] [VERSION]

Options:

	    --crystals-dir DIR	Directory that contains other installed Crystals
	-i, --install-dir DIR	Directory to install Crystal into
	    --system		Install into $system_dir
	-s, --src-dir DIR	Directory to download source-code into
	-c, --cleanup		Remove archive and unpacked source after installation
	-u, --url URL		Alternate URL to download the Crystal archive from
	    --sha256 SHA256	SHA256 checksum of the Crystal archive
	--package-manager [apt|dnf|yum|pacman|zypper|brew|pkg|port]
				Use an alternative package manager
	--no-download		Use the previously downloaded Crystal archive
	--no-verify		Do not verify the downloaded Crystal archive
	--no-extract		Do not re-extract the downloaded Crystal archive
	--no-install-deps	Do not install dependencies before installing Crystal
	--no-reinstall  	Skip installation if Crystal is detected in same location
	-U, --update		Force re-download of the version list
	-D, --debug		Enable debug messages
	-V, --version		Prints the version
	-h, --help		Prints this message

Examples:

	$ crystal-install
	$ crystal-install 1.19.1
	$ crystal-install 1.19
	$ crystal-install latest

USAGE
}

#
# Parses command-line options.
#
function parse_options()
{
	local argv=()

	while [[ $# -gt 0 ]]; do
		case "$1" in
			--crystals-dir)
				crystals_dir="$(absolute_path "$2")"
				shift 2
				;;
			-i|--install-dir)
				install_dir="$(absolute_path "$2")"
				shift 2
				;;
			--system)
				install_dir="$system_dir"
				shift 1
				;;
			-s|--src-dir)
				src_dir="$(absolute_path "$2")"
				shift 2
				;;
			-c|--cleanup)
				cleanup=1
				shift
				;;
			-u|--url)
				crystal_url="$2"
				crystal_archive="${crystal_url##*/}"
				shift 2
				;;
			--sha256)
				crystal_sha256="$2"
				shift 2
				;;
			--package-manager)
				set_package_manager "$2"
				shift 2
				;;
			--no-download)
				no_download=1
				shift
				;;
			--no-verify)
				no_verify=1
				shift
				;;
			--no-extract)
				no_download=1
				no_verify=1
				no_extract=1
				shift
				;;
			--no-install-deps)
				no_install_deps=1
				shift
				;;
			--no-reinstall)
				no_reinstall=1
				shift
				;;
			-U|--update)
				force_update=1
				shift
				;;
			-D|--debug)
				enable_debug=1
				shift
				;;
			-V|--version)
				echo "crystal-install: $crystal_install_version"
				exit
				;;
			-h|--help)
				usage
				exit
				;;
			-*)
				echo "crystal-install: unrecognized option $1" >&2
				return 1
				;;
			*)
				argv+=("$1")
				shift
				;;
		esac
	done

	case ${#argv[*]} in
		1)	crystal_version="${argv[0]}" ;;
		0)	return 0 ;;
		*)
			echo "crystal-install: too many arguments: ${argv[*]}" >&2
			usage 1>&2
			return 1
			;;
	esac
}

#
# Lists available Crystal versions.
#
function list_versions()
{
	if [[ $force_update -eq 1 ]] || are_versions_missing || is_versions_stale; then
		log "Downloading latest crystal versions ..."
		fetch_crystal_versions || fail "Failed to download crystal versions!"
	fi

	echo "Available crystal versions:"
	list_stable_versions | sed -e 's/^/  /' || return $?
}

#
# Initializes variables after option parsing.
#
function init()
{
	local resolved
	resolved="$(resolve_version "$crystal_version")"

	if [[ -n "$resolved" ]]; then
		crystal_version="$resolved"
	else
		warn "Unknown crystal version $crystal_version. Proceeding anyways ..."
	fi

	# Resolve archive and URL if not manually set
	if [[ -z "$crystal_url" ]]; then
		resolve_crystal_archive || return $?
		resolve_crystal_url
	fi

	install_dir="${install_dir:-$crystals_dir/crystal-$crystal_version}"
}
