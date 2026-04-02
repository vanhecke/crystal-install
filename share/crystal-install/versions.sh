#!/usr/bin/env bash

crystal_repo_url="https://github.com/crystal-lang/crystal.git"
crystal_releases_api="https://api.github.com/repos/crystal-lang/crystal/releases"
crystal_versions_cache="$crystal_install_cache_dir/versions.txt"
crystal_versions_max_age=86400 # 24 hours in seconds

#
# Fetches Crystal version tags via git ls-remote (no auth required, no rate limits).
#
function fetch_versions_via_git()
{
	local versions
	versions="$(git ls-remote --tags "$crystal_repo_url" 2>/dev/null \
		| grep -o 'refs/tags/[0-9][^{}]*$' \
		| sed 's|refs/tags/||' \
		| sort -t. -k1,1n -k2,2n -k3,3n)"

	if [[ -n "$versions" ]]; then
		echo "$versions"
		return 0
	fi

	return 1
}

#
# Fetches Crystal versions from the GitHub API (needs auth for high rate limits).
#
function fetch_versions_via_api()
{
	local api_url="$crystal_releases_api?per_page=100"
	local auth_header=""

	if [[ -n "$GITHUB_TOKEN" ]]; then
		auth_header="Authorization: token $GITHUB_TOKEN"
	fi

	if [[ -z "$downloader" ]]; then
		return 1
	fi

	local page=1
	local all_versions=""

	while true; do
		local page_url="${api_url}&page=${page}"
		local page_file="$crystal_install_cache_dir/releases_page_${page}.json"

		rm -f "$page_file"

		case "$downloader" in
			curl)
				if [[ -n "$auth_header" ]]; then
					curl -s -f -L -H "$auth_header" -o "$page_file" "$page_url" 2>/dev/null
				else
					curl -s -f -L -o "$page_file" "$page_url" 2>/dev/null
				fi
				;;
			wget)
				if [[ -n "$auth_header" ]]; then
					wget -q --header="$auth_header" -O "$page_file" "$page_url" 2>/dev/null
				else
					wget -q -O "$page_file" "$page_url" 2>/dev/null
				fi
				;;
		esac

		if [[ ! -f "$page_file" ]]; then
			break
		fi

		local page_versions
		if command -v jq > /dev/null 2>&1; then
			page_versions="$(jq -r '.[].tag_name' "$page_file" 2>/dev/null)"
		else
			page_versions="$(grep -o '"tag_name"[[:space:]]*:[[:space:]]*"[^"]*"' "$page_file" | sed 's/"tag_name"[[:space:]]*:[[:space:]]*"//;s/"$//')"
		fi

		rm -f "$page_file"

		if [[ -z "$page_versions" ]]; then
			break
		fi

		if [[ -n "$all_versions" ]]; then
			all_versions="$all_versions"$'\n'"$page_versions"
		else
			all_versions="$page_versions"
		fi

		local count
		count="$(echo "$page_versions" | wc -l | tr -d ' ')"
		if (( count < 100 )); then
			break
		fi

		page=$((page + 1))
	done

	if [[ -n "$all_versions" ]]; then
		echo "$all_versions" | sort -t. -k1,1n -k2,2n -k3,3n
		return 0
	fi

	return 1
}

#
# Downloads available Crystal versions and caches them.
# Uses git ls-remote first (fast, no rate limits), falls back to GitHub API.
#
function fetch_crystal_versions()
{
	mkdir -p "$crystal_install_cache_dir" || return $?

	local versions

	debug "Fetching Crystal versions via git ls-remote ..."
	versions="$(fetch_versions_via_git)"

	if [[ -z "$versions" ]]; then
		debug "git ls-remote failed, trying GitHub API ..."
		versions="$(fetch_versions_via_api)"
	fi

	if [[ -z "$versions" ]]; then
		error "Failed to fetch Crystal versions from GitHub"
		error "Try setting GITHUB_TOKEN for higher API rate limits"
		return 1
	fi

	echo "$versions" > "$crystal_versions_cache"
}

#
# Checks if the versions cache file is missing.
#
function are_versions_missing()
{
	[[ ! -f "$crystal_versions_cache" ]]
}

#
# Checks if the versions cache is older than crystal_versions_max_age.
#
function is_versions_stale()
{
	if [[ ! -f "$crystal_versions_cache" ]]; then
		return 0
	fi

	local now file_age age_seconds

	case "$os_platform" in
		Darwin)
			file_age="$(stat -f %m "$crystal_versions_cache")"
			;;
		*)
			file_age="$(stat -c %Y "$crystal_versions_cache")"
			;;
	esac

	now="$(date +%s)"
	age_seconds=$(( now - file_age ))

	(( age_seconds > crystal_versions_max_age ))
}

#
# Lists all cached stable versions.
#
function list_stable_versions()
{
	if [[ ! -f "$crystal_versions_cache" ]]; then
		return 1
	fi

	cat "$crystal_versions_cache"
}

#
# Checks if a version is known.
#
function is_known_version()
{
	local version="$1"

	if [[ ! -f "$crystal_versions_cache" ]] || [[ -z "$version" ]]; then
		return 1
	fi

	grep -q -x "$version" "$crystal_versions_cache"
}

#
# Finds the latest version matching a prefix (e.g. "1.19" -> "1.19.1").
#
function latest_version()
{
	local key="$1"

	if [[ ! -f "$crystal_versions_cache" ]]; then
		return 1
	fi

	if [[ -z "$key" ]]; then
		tail -n 1 "$crystal_versions_cache"
		return
	fi

	local version match=""

	while IFS="" read -r version; do
		if [[ "$version" == "$key".* || "$version" == "$key" ]]; then
			match="$version"
		fi
	done < "$crystal_versions_cache"

	if [[ -n "$match" ]]; then
		echo -n "$match"
	else
		return 1
	fi
}

#
# Resolves a user-provided version string to a fully qualified version.
# "latest" -> newest version
# "1.19"   -> "1.19.1" (latest patch)
# "1.19.1" -> "1.19.1" (exact match)
#
function resolve_version()
{
	local version="$1"

	case "$version" in
		latest|"")
			latest_version ""
			;;
		*)
			if is_known_version "$version"; then
				echo -n "$version"
			else
				latest_version "$version"
			fi
			;;
	esac
}
