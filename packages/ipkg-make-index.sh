#!/usr/bin/env bash
set -e

pkg_dir=$1

if [ -z "$pkg_dir" ] || [ ! -d "$pkg_dir" ]; then
    echo "Usage: ipkg-make-index <package_directory>" >&2
    exit 1
fi

empty=1

for pkg in $(find "$pkg_dir" -name '*.ipk' | sort); do
    empty=
    name="${pkg##*/}"
    name="${name%%_*}"
    [[ "$name" == "kernel" ]] && continue
    [[ "$name" == "libc" ]] && continue
    echo "Generating index for package $pkg" >&2

    file_size=$(stat -L -c%s "$pkg")
    sha256sum=$(sha256sum "$pkg" | cut -d ' ' -f1)

    sed_safe_pkg=$(echo "$pkg" | sed 's/^\.\///; s/\//\\\//g')

    # Распаковываем control напрямую из .ipk (tar.gz)
    tar -xOzf "$pkg" control | \
    sed -e "s|^Description:|Filename: $sed_safe_pkg\nSize: $file_size\nSHA256sum: $sha256sum\nDescription:|"

    echo ""
done

[ -n "$empty" ] && echo
exit 0
