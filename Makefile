# dmenu - dynamic menu
# See LICENSE file for copyright and license details.

# dmenu version
VERSION = 6.3

# paths
ifndef PREFIX
PREFIX = /usr/local
endif
ifndef MANPREFIX
MANPREFIX = $(PREFIX)/share/man
endif

X11INC = /usr/X11R6/include
X11LIB = /usr/X11R6/lib

# Xinerama, comment if you don't want it
XINERAMALIBS  = -lXinerama
XINERAMAFLAGS = -DXINERAMA

# freetype
FREETYPELIBS = -lfontconfig -lXft
FREETYPEINC = /usr/include/freetype2
# OpenBSD (uncomment)
#FREETYPEINC = $(X11INC)/freetype2

NUM_THREADS = $(shell nproc)

# includes and libs
INCS = -I$(X11INC) -I$(FREETYPEINC)
LIBS = -L$(X11LIB) -lX11 $(XINERAMALIBS) $(FREETYPELIBS)

# flags
CPPFLAGS = -D_DEFAULT_SOURCE -D_BSD_SOURCE -D_XOPEN_SOURCE=700 -D_POSIX_C_SOURCE=200809L -DVERSION=\"$(VERSION)\" $(XINERAMAFLAGS)
CFLAGS   = -std=c99 -pedantic -Wall -Ofast $(INCS) $(CPPFLAGS) -DNUM_THREADS=$(NUM_THREADS)
LDFLAGS  = $(LIBS) -pthread

# compiler and linker
CC = cc

SRC = drw.c dmenu.c stest.c util.c
OBJ = $(SRC:.c=.o)

all: options dmenu stest

options:
	@echo dmenu build options:
	@echo "CFLAGS   = $(CFLAGS)"
	@echo "LDFLAGS  = $(LDFLAGS)"
	@echo "CC       = $(CC)"

.c.o:
	$(CC) -c $(CFLAGS) $<

config.h:
	cp config.def.h $@

$(OBJ): arg.h config.h config.mk drw.h

dmenu: dmenu.o drw.o util.o
	$(CC) -o $@ dmenu.o drw.o util.o $(LDFLAGS)

stest: stest.o
	$(CC) -o $@ stest.o $(LDFLAGS)

clean:
	rm -f dmenu stest $(OBJ) dmenu-$(VERSION).tar.gz config.h

dist: clean
	mkdir -p dmenu-$(VERSION)
	cp LICENSE Makefile README arg.h config.def.h config.mk dmenu.1\
		drw.h util.h dmenu_path dmenu_run stest.1 $(SRC)\
		dmenu-$(VERSION)
	tar -cf dmenu-$(VERSION).tar dmenu-$(VERSION)
	gzip dmenu-$(VERSION).tar
	rm -rf dmenu-$(VERSION)

install: all
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	cp -f dmenu dmenu_path dmenu_run stest $(DESTDIR)$(PREFIX)/bin
	chmod 755 $(DESTDIR)$(PREFIX)/bin/dmenu
	chmod 755 $(DESTDIR)$(PREFIX)/bin/dmenu_path
	chmod 755 $(DESTDIR)$(PREFIX)/bin/dmenu_run
	chmod 755 $(DESTDIR)$(PREFIX)/bin/stest
	mkdir -p $(DESTDIR)$(MANPREFIX)/man1
	sed "s/VERSION/$(VERSION)/g" < dmenu.1 > $(DESTDIR)$(MANPREFIX)/man1/dmenu.1
	sed "s/VERSION/$(VERSION)/g" < stest.1 > $(DESTDIR)$(MANPREFIX)/man1/stest.1
	chmod 644 $(DESTDIR)$(MANPREFIX)/man1/dmenu.1
	chmod 644 $(DESTDIR)$(MANPREFIX)/man1/stest.1

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/dmenu\
		$(DESTDIR)$(PREFIX)/bin/dmenu_path\
		$(DESTDIR)$(PREFIX)/bin/dmenu_run\
		$(DESTDIR)$(PREFIX)/bin/stest\
		$(DESTDIR)$(MANPREFIX)/man1/dmenu.1\
		$(DESTDIR)$(MANPREFIX)/man1/stest.1

arch_install:
	pkgver=$(VERSION) makepkg -si --clean
	rm -f colour-dmenu-*-any.pkg.tar.zst

.PHONY: all patches options clean dist install uninstall
