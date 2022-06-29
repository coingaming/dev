#!/bin/sh

# This script installs the Nix package manager on your system by
# downloading a binary distribution and running its installer script
# (which in turn creates and populates /nix).

{ # Prevent execution if this script was only partially downloaded
oops() {
    echo "$0:" "$@" >&2
    exit 1
}

umask 0022

tmpDir="$(mktemp -d -t nix-binary-tarball-unpack.XXXXXXXXXX || \
          oops "Can't create temporary directory for downloading the Nix binary tarball")"
cleanup() {
    rm -rf "$tmpDir"
}
trap cleanup EXIT INT QUIT TERM

require_util() {
    command -v "$1" > /dev/null 2>&1 ||
        oops "you do not have '$1' installed, which I need to $2"
}

case "$(uname -s).$(uname -m)" in
    Linux.x86_64)
        hash=ea7b94637b251cdaadf932cef41c681aa3d2a15928877d8319ae6f35a440977d
        path=bmryqr433a18hirfgp9yzpqyakfrhn6s/nix-2.9.1-x86_64-linux.tar.xz
        system=x86_64-linux
        ;;
    Linux.i?86)
        hash=41e38706a26736aa42acd3dbd57db7e354e722e4bd5f6d9c8069d1c98b6081be
        path=ssgfczjzb0wzbbcpy8zysh8br005xm14/nix-2.9.1-i686-linux.tar.xz
        system=i686-linux
        ;;
    Linux.aarch64)
        hash=d706c6b710548b9c3ed4a409df3a7293da14f726dcc59849abd709e574cabeed
        path=qbwlwywbq0qjzgw5wfqh28zm5dfjdsiw/nix-2.9.1-aarch64-linux.tar.xz
        system=aarch64-linux
        ;;
    Linux.armv6l_linux)
        hash=d8483f0747dce74685fcffa628908a96e6d0f7b1166a97f0eef231f5faa86c22
        path=7qc0k4m7rkdw2hvr3hnakl4vvc1j4bcs/nix-2.9.1-armv6l-linux.tar.xz
        system=armv6l-linux
        ;;
    Linux.armv7l_linux)
        hash=6f7f285d5de8b8d7686b6925869e25c2ff40f16492190c0b773ebd357bd4c956
        path=553g5g2jbs6j1h1jw9khj5rkhwjjwld8/nix-2.9.1-armv7l-linux.tar.xz
        system=armv7l-linux
        ;;
    Darwin.x86_64)
        hash=84a67ab30454064a7bccf70a2adb96134b4b9517076499edfe72c446236b49bd
        path=ikrdcfzi6lpamr9m42g7n6r8a7kb81rv/nix-2.9.1-x86_64-darwin.tar.xz
        system=x86_64-darwin
        ;;
    Darwin.arm64|Darwin.aarch64)
        hash=06e9c9157f4d4b6ae0ffa8d8fd1ef1aceb29ed3b0bf7888f2fd1c1e8a1712a84
        path=gq0f3jf0dg712pw9wc7zql294b30fyk3/nix-2.9.1-aarch64-darwin.tar.xz
        system=aarch64-darwin
        ;;
    *) oops "sorry, there is no binary distribution of Nix for your platform";;
esac

# Use this command-line option to fetch the tarballs using nar-serve or Cachix
if [ "${1:-}" = "--tarball-url-prefix" ]; then
    if [ -z "${2:-}" ]; then
        oops "missing argument for --tarball-url-prefix"
    fi
    url=${2}/${path}
    shift 2
else
    url=https://releases.nixos.org/nix/nix-2.9.1/nix-2.9.1-$system.tar.xz
fi

tarball=$tmpDir/nix-2.9.1-$system.tar.xz

require_util tar "unpack the binary tarball"
if [ "$(uname -s)" != "Darwin" ]; then
    require_util xz "unpack the binary tarball"
fi

if command -v curl > /dev/null 2>&1; then
    fetch() { curl --fail -L "$1" -o "$2"; }
elif command -v wget > /dev/null 2>&1; then
    fetch() { wget "$1" -O "$2"; }
else
    oops "you don't have wget or curl installed, which I need to download the binary tarball"
fi

echo "downloading Nix 2.9.1 binary tarball for $system from '$url' to '$tmpDir'..."
fetch "$url" "$tarball" || oops "failed to download '$url'"

if command -v sha256sum > /dev/null 2>&1; then
    hash2="$(sha256sum -b "$tarball" | cut -c1-64)"
elif command -v shasum > /dev/null 2>&1; then
    hash2="$(shasum -a 256 -b "$tarball" | cut -c1-64)"
elif command -v openssl > /dev/null 2>&1; then
    hash2="$(openssl dgst -r -sha256 "$tarball" | cut -c1-64)"
else
    oops "cannot verify the SHA-256 hash of '$url'; you need one of 'shasum', 'sha256sum', or 'openssl'"
fi

if [ "$hash" != "$hash2" ]; then
    oops "SHA-256 hash mismatch in '$url'; expected $hash, got $hash2"
fi

unpack=$tmpDir/unpack
mkdir -p "$unpack"
tar -xJf "$tarball" -C "$unpack" || oops "failed to unpack '$url'"

script=$(echo "$unpack"/*/install)

[ -e "$script" ] || oops "installation script is missing from the binary tarball!"
export INVOKED_FROM_INSTALL_IN=1
"$script" "$@"

} # End of wrapping
