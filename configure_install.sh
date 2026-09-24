#!/bin/sh
# get.opentraderworld.com/configure_install.sh
#
# Downloads the pinned OpenTraderWorld server installer, checks it is the file we
# published, and runs it. It does nothing else, and it never will: everything
# this fetches is reviewable at the tag below.
set -eu

TAG="v0.0.13"
SHA="f4a0c5419a635aa375e1156a11f3dc58e9fb0ca703d687a3f7674899abb1ae17"
URL="https://raw.githubusercontent.com/G-OTW/OpenTraderWorld/${TAG}/deploy/server-setup.sh"

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT INT TERM
curl -fsSL "$URL" -o "$tmp" || {
  echo "Could not download the installer. Check this machine's internet connection."
  exit 1
}

# sha256sum on Linux, shasum on the odd machine that has only that.
if command -v sha256sum >/dev/null 2>&1; then
  have="$(sha256sum "$tmp" | cut -d' ' -f1)"
else
  have="$(shasum -a 256 "$tmp" | cut -d' ' -f1)"
fi

if [ "$have" != "$SHA" ]; then
  echo "The install file is not the one we published. Nothing on this machine was changed."
  echo "Please report this at https://github.com/G-OTW/OpenTraderWorld/issues"
  exit 1
fi

# The installer is bash, and it reads its questions from /dev/tty, so it works
# under `curl | bash` with stdin already spent.
exec bash "$tmp" "$@"
