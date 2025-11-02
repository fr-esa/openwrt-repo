#!/usr/bin/env bash
set -e

pkg_dir=$1

if [ -z "$pkg_dir" ] || [ ! -d "$pkg_dir" ]; then
  echo "Usage: ipkg-make-index <package_directory>" >&2
  exit 1
fi

empty=1

for pkg in "$pkg_dir"/*.ipk; do
  [ -e "$pkg" ] || continue
  empty=
  echo "Generating index for package $pkg" >&2
  
  tempdir=$(mktemp -d)
  
  # Распаковываем .ipk
  tar -xzf "$pkg" -C "$tempdir"
  
  if [ ! -f "$tempdir/control.tar.gz" ]; then
    echo "No control.tar.gz found in $pkg" >&2
    rm -rf "$tempdir"
    continue
  fi
  
  file_size=$(stat -L -c%s "$pkg")
  sha256sum=$(sha256sum "$pkg" | cut -d' ' -f1)
  
  # Вот ключевая часть: добавляем Filename, Size, SHA256sum перед Description, с корректными переносами строк
  tar -Oxzf "$tempdir/control.tar.gz" ./control | sed -e "1iFilename: ${pkg##*/}\nSize: $file_size\nSHA256sum: $sha256sum" 
  
  echo
  
  rm -rf "$tempdir"
done

[ -n "$empty" ] && echo >&2 "No packages found in $pkg_dir"

exit 0
