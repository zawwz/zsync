
var_exclude = ZPASS_.* XDG_.* REMOTE_.* DISPLAY CONFIGFILE TMPDIR
fct_exclude = _tty_on

zsync: src/*
	lxsh -o zsync -M --exclude-var "$(var_exclude)" --exclude-fct "$(fct_exclude)" src/main.sh

debug: src/*
	lxsh -o zsync src/main.sh

build: zsync

install: build
	mv zsync /usr/local/bin

uninstall:
	rm /usr/local/bin/zpass

clear:
	rm zsync
