# make check   everything that can be verified without a login session
SCRIPTS := install.sh $(wildcard i3/scripts/* polybar/scripts/*)

.PHONY: check syntax lint themes units packages dry-run

check: syntax lint themes units dry-run
	@echo "all checks passed"

syntax:
	@for f in $(SCRIPTS); do bash -n $$f || exit 1; done; echo "syntax    ok ($(words $(SCRIPTS)) scripts)"

lint:
	@if command -v shellcheck >/dev/null; then shellcheck -S warning $(SCRIPTS) && echo "lint      ok"; \
	else echo "lint      skipped (shellcheck not installed)"; fi

themes:
	@i3/scripts/theme --check && echo "themes    ok ($$(ls themes/palettes | wc -l) palettes)"

units:
	@if command -v systemd-analyze >/dev/null; then \
		for u in systemd/user/*.service systemd/user/*.target; do \
			systemd-analyze --user verify $$PWD/$$u 2>&1 | grep -vE 'man\)|systemd.special|not executable|No such file' | grep . && exit 1; \
		done; echo "units     ok"; \
	else echo "units     skipped"; fi

# needs pacman's sync databases; not part of `check`
packages:
	@grep -hvE '^\s*(#|$$)' packages/*.txt | while read -r p; do pacman -Si $$p >/dev/null 2>&1 || { echo "not in repos: $$p"; exit 1; }; done; echo "packages  ok"

dry-run:
	@./install.sh --dry-run >/dev/null && echo "installer ok (dry run)"
