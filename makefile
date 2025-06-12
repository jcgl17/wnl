ifeq ($(MAKECMDGOALS),)
$(error no target selected. please choose "make install" or "make uninstall" [SYSTEM=1|USER_LOCAL=1|SYSTEM_LOCAL=1])
endif

ifdef SYSTEM
PREFIX := /usr
else ifdef USER_LOCAL
PREFIX := $(HOME)/.local
else
PREFIX := /usr/local
endif

BIN_DIR := $(PREFIX)/bin
MAN_DIR := $(PREFIX)/share/man
COMPLETION_DIR_BASH := $(PREFIX)/share/bash-completion/completions
COMPLETION_DIR_FISH := $(PREFIX)/share/fish/vendor_completions.d
LICENSES_DIR := $(PREFIX)/share/licenses/wnl

install:
	install -vDm 0755 wnl wnlctl -t $(DESTDIR)$(BIN_DIR)
	install -vDm 0644 share/completions/*.fish -t $(DESTDIR)$(COMPLETION_DIR_FISH)
	install -vDm 0644 share/completions/wnl.bash $(DESTDIR)$(COMPLETION_DIR_BASH)/wnl
	install -vDm 0644 share/completions/wnlctl.bash $(DESTDIR)$(COMPLETION_DIR_BASH)/wnlctl
	install -dm 0755 $(DESTDIR)$(MAN_DIR)/man1
	gzip --stdout share/man/wnl.1 > $(DESTDIR)$(MAN_DIR)/man1/wnl.1.gz
	ln -sv wnl.1.gz $(DESTDIR)$(MAN_DIR)/man1/wnlctl.1.gz
	install -vDm 0644 LICENSE.md -t $(DESTDIR)$(LICENSES_DIR)

uninstall:
	rm -vf $(BIN_DIR)/{wnl,wnlctl}
	rm -vf $(COMPLETION_DIR_FISH)/share/completions/{wnl,wnlctl}.fish
	rm -vf $(COMPLETION_DIR_BASH)/{wnl,wnlctl}
	rm -vf $(MAN_DIR)/man1/{wnl,wnlctl}.1.gz
	rm -vfr $(LICENSES_DIR)
