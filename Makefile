SHELL=/usr/bin/env bash
NAME=crystal-install
VERSION=0.1.0

DIRS=bin share
INSTALL_DIRS=`find $(DIRS) -type d`
INSTALL_FILES=`find $(DIRS) -type f`

PKG_DIR=pkg
PKG_NAME=$(NAME)-$(VERSION)
PKG=$(PKG_DIR)/$(PKG_NAME).tar.gz

PREFIX?=/usr/local
DOC_DIR=share/doc/$(PKG_NAME)

all:

pkg:
	mkdir -p $(PKG_DIR)

build: pkg
	git archive --output=$(PKG) --prefix=$(PKG_NAME)/ HEAD

clean:
	rm -f $(PKG)

check:
	shellcheck --exclude SC2034 \
		   --exclude SC2154 \
		   --exclude SC1090 \
		   --exclude SC1091 \
		   --exclude SC2242 \
		   --exclude SC2089 \
		   --exclude SC2090 \
		   --exclude SC2207 \
		   share/$(NAME)/*.sh bin/*

test:
	./test/runner

install:
	for dir in $(INSTALL_DIRS); do mkdir -p $(DESTDIR)$(PREFIX)/$$dir; done
	for file in $(INSTALL_FILES); do cp $$file $(DESTDIR)$(PREFIX)/$$file; done

uninstall:
	for file in $(INSTALL_FILES); do rm -f $(DESTDIR)$(PREFIX)/$$file; done

.PHONY: build clean check test install uninstall all
