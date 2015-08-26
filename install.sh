#!/bin/sh

install_cortex_fail() {
    >&2 echo "Installation failed."
    rm -rf "$INSTALL_TMPDIR"
}

install_cortex () {
    set -e
    set -u

    VERSION="0.2.0"
    PREFIX="/usr"

    # Check supported OS
    UNAME=$(uname)
    if [ "$UNAME" != "Linux" -a "$UNAME" != "Darwin" ] ; then
        >&2 echo "Sorry, this OS is not supported yet."
        exit 1
    fi
    ARCHITECTURE=$(uname -p)
    if [ "$UNAME" = "Darwin" ] ; then
        if [ "i386" != "$(uname -p)" -o "1" != "$(sysctl -n hw.cpu64bit_capable 2>/dev/null || echo 0)" ] ; then
          >&2 echo "Only 64-bit Intel processors are supported at this time."
          exit 1
        fi
    fi

    trap install_cortex_fail EXIT

    echo "Removing your existing Cortex $VERSION installation."
    sudo rm -rf "$PREFIX/lib/cortex/$VERSION"
    rm -rf "$HOME/.cortex/$VERSION"
    sudo mkdir -p "$PREFIX/lib/cortex/$VERSION"
    mkdir -p "$HOME/.cortex"

    FILENAME="cortex.x64-darwin.0.2.0-alpha"
    TARBALL_URL="https://s3.amazonaws.com/cortexbinaries/$UNAME/$ARCHITECTURE/$FILENAME.tar.gz"
    INSTALL_TMPDIR="$HOME/.cortex/.download"
    rm -rf "$INSTALL_TMPDIR"
    mkdir -p "$INSTALL_TMPDIR"
    sudo true
    echo "Downloading Cortex source code from $TARBALL_URL."
    sudo curl --progress-bar --fail "$TARBALL_URL" | tar -xzf - -C "$INSTALL_TMPDIR"
    sudo cp -R "$INSTALL_TMPDIR/" "/usr"
    rm -rf "$INSTALL_TMPDIR"

    trap - EXIT
}

install_cortex
