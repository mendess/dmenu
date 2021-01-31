#!/bin/bash
# Maintainer: Pedro Mendes <pedro.mendes.26@gmail.com>

pkgname=colour-dmenu
pkgver=$(grep 'VERSION = ' Makefile | cut -d'=' -f2 | xargs)
pkgrel=1
pkgdesc="My patched dmenu that changes colour according to /tmp/wall_colors"
arch=('any')
url="https://github.com/mendess/dmenu"
license=('GPL')
depends=(sh glibc coreutils libx11 libxinerama libxft
    freetype2 fontconfig libfontconfig.so=1-64)
optdepends=()
provides=(dmenu)
conflicts=(dmenu)
source=(./*.* Makefile dmenu_path dmenu_run)
md5sums=($(for _ in $(seq 1 ${#source[@]}); do echo -n 'SKIP ' ; done))

package() {
    make PREFIX=/usr DESTDIR="$pkgdir" install
}

# vim: ts=2 sw=2 et ft=sh:
