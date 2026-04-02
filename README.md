# crystal-install

Installs [Crystal] language binaries from [GitHub releases][releases].

## Features

* Supports downloading the latest versions from [Crystal's GitHub releases][releases].
* Supports installing into `/opt/crystals/` for root and `~/.crystals/` for users
  by default.
* Supports installing into arbitrary directories.
* Supports downloading from arbitrary URLs.
* Supports downloading archives using `wget` or `curl`.
* Supports verifying downloaded archives via SHA256 checksums.
* Supports installing runtime dependencies from the package manager
  ([apt], [dnf], [yum], [pacman], [zypper], [xbps], [brew], [macports], and
  [pkg]).
* Supports partial version matching (e.g. `1.19` resolves to `1.19.1`).
* Fetches available versions via `git ls-remote` (no API rate limits).
* Supports many different OSes:
  * Linux
    * [Ubuntu] / [Debian]
    * [Fedora]
    * [OpenSUSE]
    * [Arch Linux]
    * [Void Linux]
  * [macOS]
* Has tests.

## Anti-Features

* Does not require upgrading every time a new Crystal version comes out.
* Does not require recipes for each individual Crystal version.

## Requirements

* [bash] >= 3.x
* [git]
* [wget] or [curl]
* `sha256sum` or `shasum`
* `tar`

## Synopsis

List available Crystal versions:

```shell
$ crystal-install
```

Install the latest version of Crystal:

```shell
$ crystal-install latest
```

Install a stable version of Crystal:

```shell
$ crystal-install 1.19
```

Install a specific version of Crystal:

```shell
$ crystal-install 1.19.1
```

Install Crystal into a specific directory:

```shell
$ crystal-install --install-dir /path/to/dir 1.19.1
```

Install Crystal into `/usr/local`:

```shell
$ sudo crystal-install --system 1.19.1
```

Install Crystal without installing dependencies first:

```shell
$ crystal-install --no-install-deps 1.19.1
```

Skip reinstallation if version is already installed:

```shell
$ crystal-install --no-reinstall 1.19.1
```

Force update the cached version list:

```shell
$ crystal-install --update
```

Uninstall a Crystal version:

```shell
$ rm -rf ~/.crystals/crystal-1.19.1
```

### Integration

Using crystal-install with [chcrystal]:

```shell
$ crystal-install 1.19.1
$ chcrystal 1.19.1
$ crystal --version
```

## Install

```shell
wget https://github.com/vanhecke/crystal-install/archive/v0.1.0/crystal-install-0.1.0.tar.gz
tar -xzvf crystal-install-0.1.0.tar.gz
cd crystal-install-0.1.0/
sudo make install
```

### From Source

```shell
git clone https://github.com/vanhecke/crystal-install.git
cd crystal-install/
sudo make install
```

## Uninstall

```shell
sudo make uninstall
```

## Credits

crystal-install is inspired by and structurally based on [ruby-install] by
[postmodern]. The architecture, test patterns, and CI approach are directly
adapted from his work.

* [postmodern](https://github.com/postmodern) for creating [ruby-install] and
  [chruby], which served as the blueprint for this project.

[Crystal]: https://crystal-lang.org/
[releases]: https://github.com/crystal-lang/crystal/releases

[Ubuntu]: https://ubuntu.com/
[Debian]: https://www.debian.org/
[Fedora]: https://fedoraproject.org/
[OpenSUSE]: https://www.opensuse.org/
[Arch Linux]: https://archlinux.org/
[Void Linux]: https://voidlinux.org/
[macOS]: https://www.apple.com/macos/

[apt]: https://wiki.debian.org/Apt
[dnf]: https://fedoraproject.org/wiki/Features/DNF
[yum]: http://yum.baseurl.org/
[pacman]: https://wiki.archlinux.org/index.php/Pacman
[zypper]: https://en.opensuse.org/Portal:Zypper
[xbps]: https://docs.voidlinux.org/xbps/index.html
[pkg]: https://wiki.freebsd.org/pkgng
[macports]: https://www.macports.org/
[brew]: https://brew.sh

[bash]: https://www.gnu.org/software/bash/
[git]: https://git-scm.com/
[wget]: https://www.gnu.org/software/wget/
[curl]: https://curl.se/

[chcrystal]: https://github.com/vanhecke/chcrystal#readme
[ruby-install]: https://github.com/postmodern/ruby-install#readme
[chruby]: https://github.com/postmodern/chruby#readme
[postmodern]: https://github.com/postmodern
