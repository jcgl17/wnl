NAME    := wnl
SPECFILE := wnl.spec

VERSION := $(shell git describe --tags --match "v*" --abbrev=0 | sed 's/^v//')
RELEASE := 1

RPM_DIST := $(shell rpm --eval '%{?dist}')

RPM_NAME := $(shell rpmspec \
			--define 'name $(NAME)' \
			--define "ver $(VERSION)" \
			--define "rel $(RELEASE)" \
			--query $(SPECFILE) \
			--queryformat '%{name}-%{version}-%{release}.%{arch}.rpm' \
			)

RPMBUILD_TOPDIR ?= $(HOME)/rpmbuild
SOURCES         := $(RPMBUILD_TOPDIR)/SOURCES
BUILD_DIR       := $(RPMBUILD_TOPDIR)/BUILD
RPMS_DIR        := $(RPMBUILD_TOPDIR)/RPMS/noarch
RPM_OUT         := $(RPMS_DIR)/$(RPM_NAME)

.PHONY: all prepare rpm clean

all: rpm

prepare: $(SOURCES)/$(NAME)-$(VERSION).tar.gz

$(SOURCES)/$(NAME)-$(VERSION).tar.gz:
	@echo "==> [prepare] creating $@ from git tag v$(VERSION)"
	@mkdir -p $(SOURCES)
	@git archive \
		--format=tar.gz \
		--prefix=$(NAME)-$(VERSION)/ \
		v$(VERSION) \
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
