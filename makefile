ifeq ($(MAKECMDGOALS),)
$(error no target selected. please choose "make install" or "make uninstall" [SYSTEM=1|USER_LOCAL=1|SYSTEM_LOCAL=1])
endif

ifdef SYSTEM
PREFIX := $(DESTDIR)/usr
else ifdef USER_LOCAL
PREFIX := $(DESTDIR)$(HOME)/.local
else
PREFIX := $(DESTDIR)/usr/local
endif

BIN_DIR := $(PREFIX)/bin
MAN_DIR := $(PREFIX)/share/man
COMPLETION_DIR_BASH := $(PREFIX)/share/bash-completion/completions
COMPLETION_DIR_FISH := $(PREFIX)/share/fish/vendor_completions.d
LICENSES_DIR := $(PREFIX)/share/licenses/wnl

.PHONY: install
install:
	install -vDm 0755 wnl wnlctl -t $(BIN_DIR)
	install -vDm 0644 share/completions/bash/* -t $(COMPLETION_DIR_BASH)
	install -vDm 0644 share/completions/fish/* -t $(COMPLETION_DIR_FISH)
	install -dm 0755 $(MAN_DIR)/man1
	gzip --stdout share/man/wnl.1 > $(MAN_DIR)/man1/wnl.1.gz
	ln -sv wnl.1.gz $(MAN_DIR)/man1/wnlctl.1.gz
	install -vDm 0644 LICENSE.md -t $(LICENSES_DIR)

.PHONY: uninstall
uninstall:
	rm -vf $(BIN_DIR)/{wnl,wnlctl}
	rm -vf $(COMPLETION_DIR_BASH)/{wnl,wnlctl}
	rm -vf $(COMPLETION_DIR_FISH)/share/completions/{wnl,wnlctl}.fish
	rm -vf $(MAN_DIR)/man1/{wnl,wnlctl}.1*
	rm -vfr $(LICENSES_DIR)

.PHONY: link
link:
	ln -sf $(CURDIR)/wnl $(BIN_DIR)/wnl
	ln -sf $(CURDIR)/wnlctl $(BIN_DIR)/wnlctl
	ln -sf $(CURDIR)/share/completions/bash/wnl $(COMPLETION_DIR_BASH)/wnl
	ln -sf $(CURDIR)/share/completions/bash/wnlctl $(COMPLETION_DIR_BASH)/wnlctl
	ln -sf $(CURDIR)/share/completions/fish/wnl.fish $(COMPLETION_DIR_FISH)/wnl.fish
	ln -sf $(CURDIR)/share/completions/fish/wnlctl.fish $(COMPLETION_DIR_FISH)/wnlctl.fish
	ln -sf $(CURDIR)/share/man/wnl.1 $(MAN_DIR)/man1/wnl.1
	ln -sf $(CURDIR)/share/man/wnl.1 $(MAN_DIR)/man1/wnlctl.1
	mkdir -pv $(LICENSES_DIR)
	ln -sf $(CURDIR)/LICENSE.md $(LICENSES_DIR)/LICENSE.md

.PHONY: release
release:
	./util/generate_release_notes
	sh -c "git tag $$(./util/generate_release_notes | head -n1) --annotate --sign --file <(./util/generate_release_notes)"
	./util/generate_obs_changes > ~/code/home:jcgl/wnl_dev/wnl.changes
