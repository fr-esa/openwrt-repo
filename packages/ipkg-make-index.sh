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

    # Экранируем слеши для sed (используем разделитель |)
    sed_safe_pkg=$(echo "$pkg" | sed 's/^\.\///; s/\//\\\//g')

    # Временная директория для распаковки
    tmpdir=$(mktemp -d)
    trap "rm -rf $tmpdir" EXIT

    # Распаковываем ipk (ar архив)
    ar x "$pkg" -C "$tmpdir"

    # Распаковываем control.tar.gz и выводим control с нужными заменами
    tar -xzf "$tmpdir/control.tar.gz" -C "$tmpdir"
    sed -e "s|^Description:|Filename: $sed_safe_pkg\nSize: $file_size\nSHA256sum: $sha256sum\nDescription:|" "$tmpdir/control"

    echo ""
done

[ -n "$empty" ] && echo
exit 0
