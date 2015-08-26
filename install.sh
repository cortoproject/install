#!/bin/sh

install_cortex_fail() {
    >&2 echo "Installation failed."
    rm -rf "$INSTALL_TMPDIR"
}

install_cortex () {
    set -e
    set -u

    UNAME=$(uname)
    ARCHITECTURE=$(uname -p)
    VERSION="0.2.0-alpha"
    PREFIX="/usr"
    FILENAME="cortex"
    TARBALL_URL="https://s3.amazonaws.com/cortexbinaries/$UNAME/$ARCHITECTURE/$FILENAME.tar.gz"
    INSTALL_TMPDIR="$HOME/.cortex/.download"

    # Check supported OS
    if [ "$UNAME" != "Linux" -a "$UNAME" != "Darwin" ] ; then
        >&2 echo "Sorry, this OS is not supported yet."
        exit 1
    fi
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

    echo "Downloading Cortex source code from $TARBALL_URL."
    rm -rf "$INSTALL_TMPDIR"
    mkdir -p "$INSTALL_TMPDIR"
    sudo true
    sudo curl --progress-bar --fail "$TARBALL_URL" | tar -xzf - -C "$INSTALL_TMPDIR"

    echo "Removing any previous installation."
    sudo rm -f /usr/bin/cortex
    sudo rm -f "/usr/bin/cortex.$VERSION"
    sudo rm -f "/usr/lib/libcortex.so"
    sudo rm -f "/usr/lib/libcortex.so.$VERSION"
    sudo rm -rf /usr/include/cortex
    sudo rm -rf /usr/include/cortex/0.2.0-alpha/packages/cortex
    sudo rm -rf /usr/lib/cortex/0.2.0-alpha/packages/cortex

    echo "Copying files."
    sudo cp -R "$INSTALL_TMPDIR/" "/usr"
    rm -rf "$INSTALL_TMPDIR"
    sudo mv "/usr/bin/cortex" "/usr/bin/cortex.$VERSION"
    sudo mv "/usr/bin/libcortex.so" "/usr/lib/libcortex.so.$VERSION"
    sudo ln -s "/usr/bin/cortex.$VERSION" "/usr/bin/cortex"
    sudo ln -s "/usr/lib/libcortex.so.$VERSION" "/usr/lib/libcortex.so"

    echo "Cortex successfully installed."

    trap - EXIT
}

install_cortex
