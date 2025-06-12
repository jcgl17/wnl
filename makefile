NAME    := wnl
SPECFILE := packaging/rpm/wnl.spec

VERSION ?= $(shell git describe --tags --always --dirty | tr '-' '+' | sed 's/^v//')
RELEASE := 1

RPM_DIST ?= $(shell rpm --eval '%{?dist}')

RPM_NAME ?= $(shell rpmspec \
			--define 'name $(NAME)' \
			--define "ver $(VERSION)" \
			--define "rel $(RELEASE)" \
			--query $(SPECFILE) \
			--queryformat '%{name}-%{version}-%{release}.%{arch}.rpm' \
			)

DEPS := wnl wnlctl share/completions/*

RPMBUILD_TOPDIR ?= $(HOME)/rpmbuild
SOURCES         := $(RPMBUILD_TOPDIR)/SOURCES
BUILD_DIR       := $(RPMBUILD_TOPDIR)/BUILD
RPMS_DIR        := $(RPMBUILD_TOPDIR)/RPMS/noarch
RPM_OUT         = $(RPMS_DIR)/$(RPM_NAME)

.PHONY: all prepare rpm clean install

all: rpm

prepare: $(SOURCES)/$(NAME)-$(VERSION).tar.gz

$(SOURCES)/$(NAME)-$(VERSION).tar.gz: $(DEPS)
	@echo "==> [prepare] creating $@ from git tag v$(VERSION)"
	mkdir -p $(SOURCES)
	git archive \
		--format=tar.gz \
		--prefix=$(NAME)-$(VERSION)/ \
		HEAD \
	> $@

rpm: prepare $(SPECFILE)
	@echo "==> [rpm] building $(RPM_NAME)"
	rpmbuild -ba \
	  --define "ver $(VERSION)" \
	  --define "rel $(RELEASE)" \
	  --define "_topdir $(RPMBUILD_TOPDIR)" \
	  $(SPECFILE)
	@echo "==> [rpm] done: $(RPM_OUT)"

clean:
	rm -vf $(SOURCES)/$(NAME)-$(VERSION).tar.gz
	rm -vrf $(BUILD_DIR)/$(NAME)-*
	rm -vf $(RPM_OUT)

ifdef PACKAGE
BIN_DIR := /usr/bin
COMPLETION_DIR_BASH := /usr/share/bash-completion/completions
else
BIN_DIR := /usr/local/bin
COMPLETION_DIR_BASH := /usr/local/share/bash-completion/completions
endif
COMPLETION_DIR_FISH := /usr/share/fish/vendor_completions.d
MANDIR := /usr/share/man

install:
	install -vDm 0755 wnl wnlctl -t $(DESTDIR)$(BIN_DIR)
	install -vDm 0644 share/completions/*.fish -t $(DESTDIR)$(COMPLETION_DIR_FISH)
	install -vDm 0644 share/completions/wnl.bash $(DESTDIR)$(COMPLETION_DIR_BASH)/wnl
	install -vDm 0644 share/completions/wnlctl.bash $(DESTDIR)$(COMPLETION_DIR_BASH)/wnlctl
	install -dm 0755 $(DESTDIR)$(MANDIR)/man1
	gzip --stdout share/man/wnl.1 > $(DESTDIR)$(MANDIR)/man1/wnl.1.gz
	ln -sv wnl.1.gz $(DESTDIR)$(MANDIR)/man1/wnlctl.1.gz
