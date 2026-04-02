#!/usr/bin/env bash

crystal_dependencies=()

#
# Sets Crystal runtime dependencies based on the detected package manager.
#
function set_crystal_dependencies()
{
	case "$package_manager" in
		brew)
			crystal_dependencies=(bdw-gc gmp libevent libyaml openssl@3 pcre2 pkgconf)
			;;
		apt)
			crystal_dependencies=(
				libevent-dev
				libgc-dev
				libgmp-dev
				libpcre2-dev
				libssl-dev
				libyaml-dev
			)
			;;
		dnf|yum)
			crystal_dependencies=(
				gc-devel
				gmp-devel
				libevent-devel
				libyaml-devel
				openssl-devel
				pcre2-devel
			)
			;;
		pacman)
			crystal_dependencies=(
				gc
				gmp
				libevent
				libyaml
				openssl
				pcre2
			)
			;;
		zypper)
			crystal_dependencies=(
				gc-devel
				gmp-devel
				libevent-devel
				libyaml-devel
				libopenssl-devel
				pcre2-devel
			)
			;;
		pkg)
			crystal_dependencies=(
				boehm-gc
				gmp
				libevent
				libyaml
				openssl
				pcre2
			)
			;;
		port)
			crystal_dependencies=(
				boehmgc
				gmp
				libevent
				libyaml
				openssl3
				pcre2
			)
			;;
		xbps)
			crystal_dependencies=(
				gc-devel
				gmp-devel
				libevent-devel
				libyaml-devel
				openssl-devel
				pcre2-devel
			)
			;;
	esac
}

#
# Sets the package manager and installs packages.
#
function set_package_manager()
{
	case "$1" in
		zypper|apt|dnf|yum|pkg|port|brew|pacman|xbps)
			package_manager="$1"
			;;
		*)
			error "Unsupported package manager: $1"
			return 1
			;;
	esac
}

#
# Installs packages using the detected package manager.
#
function install_packages()
{
	case "$package_manager" in
		apt)
			run $sudo apt install -y "$@" || return $?
			;;
		dnf|yum)
			run $sudo "$package_manager" install -y "$@" || return $?
			;;
		port)
			run $sudo port install "$@" || return $?
			;;
		pkg)
			run $sudo pkg install -y "$@" || return $?
			;;
		brew)
			local brew_sudo=""

			if (( UID == 0 )) && [[ -n "$SUDO_USER" ]]; then
				brew_sudo="sudo -u \"$SUDO_USER\""
			fi

			run $brew_sudo brew install "$@" ||
			run $brew_sudo brew upgrade "$@" || return $?
			;;
		pacman)
			local missing_pkgs=($(pacman -T "$@"))

			if (( ${#missing_pkgs[@]} > 0 )); then
				run $sudo pacman -S "${missing_pkgs[@]}" || return $?
			fi
			;;
		zypper)
			run $sudo zypper -n in -l "$@" || return $?
			;;
		xbps)
			run $sudo xbps-install -Sy "$@" || return $?
			;;
		"")
			warn "Could not determine Package Manager. Proceeding anyway."
			;;
	esac
}
