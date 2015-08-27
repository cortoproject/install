#!/bin/sh

VERSION="0.2.0-alpha"

install_cortex_fail() {
    >&2 echo "cortex: installation failed :("
    # rm -rf "$INSTALL_TMPDIR"
    sudo rm -f "/usr/bin/cortex"
    sudo rm -f "/usr/bin/cortex.$VERSION"
    sudo rm -f "/usr/lib/libcortex.so"
    sudo rm -f "/usr/lib/libcortex.so.$VERSION"
    sudo rm -rf "/usr/lib/cortex/$VERSION"
    sudo rm -rf "/usr/include/cortex/$VERSION"
    # sudo rm -rf "$HOME/.cortex"
}

install_cortex () {
    set -e
    set -u

    UNAME=$(uname)
    ARCHITECTURE=$(uname -p)
    PREFIX="/usr"
    FILENAME="cortex"
    TARBALL_URL="https://s3.amazonaws.com/cortexbinaries/$FILENAME.$UNAME.$ARCHITECTURE.tar.gz"
    INSTALL_TMPDIR="$HOME/.cortex/.download"

    echo
    echo "Stand by, this will just take a second..."
    echo

    # Check supported OS
    if [ "$UNAME" != "Linux" -a "$UNAME" != "Darwin" ] ; then
        >&2 echo "cortex: sorry, this OS is not supported yet!"
        exit 1
    fi
    if [ "$UNAME" = "Darwin" ] ; then
        if [ "i386" != "$(uname -p)" -o "1" != "$(sysctl -n hw.cpu64bit_capable 2>/dev/null || echo 0)" ] ; then
          >&2 echo "cortex: only 64-bit Intel processors are supported at this time!"
          exit 1
        fi
    fi

    trap install_cortex_fail EXIT

    # Ask for password upfront
    sudo true

    # Remove existing version
    if [ "`which cortex`" != "" ]  ; then
        OLD_VERSION=`cortex -v`
        echo "cortex: removing your existing cortex distribution ($OLD_VERSION)"
        sudo rm -f "/usr/bin/cortex"
        sudo rm -f "/usr/bin/cortex.$OLD_VERSION"
        sudo rm -f "/usr/lib/libcortex.so"
        sudo rm -f "/usr/lib/libcortex.so.$OLD_VERSION"
        sudo rm -rf "/usr/lib/cortex/$OLD_VERSION"
        sudo rm -rf "/usr/include/cortex/$OLD_VERSION"
    fi

    mkdir -p "$HOME/.cortex"
    sudo mkdir -p "$PREFIX/lib/cortex/$VERSION"

    echo "cortex: downloading distribution"
    rm -rf "$INSTALL_TMPDIR"
    mkdir -p "$INSTALL_TMPDIR"

    sudo curl --progress-bar --fail "$TARBALL_URL" | tar -xzf - -C "$INSTALL_TMPDIR"

    echo "cortex: installing files"
    sudo cp -a "$INSTALL_TMPDIR/." "/usr"
    rm -rf "$INSTALL_TMPDIR"
    sudo mv "/usr/bin/cortex" "/usr/bin/cortex.$VERSION"
    sudo mv "/usr/lib/libcortex.so" "/usr/lib/libcortex.so.$VERSION"
    sudo ln -s "/usr/bin/cortex.$VERSION" "/usr/bin/cortex"
    sudo ln -s "/usr/lib/libcortex.so.$VERSION" "/usr/lib/libcortex.so"
    echo "cortex: done!"
    echo

    echo "Yay! Cortex $VERSION successfully installed!"
    echo
    echo "Hit the ground running with:"
    echo
    echo "   $ cortex create myApp"
    echo "   $ cd myApp"
    echo "   $ cortex run"
    echo

    trap - EXIT
}

install_cortex
