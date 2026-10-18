#!/bin/sh
# Quarto post-render: keep old Wix file links alive after the DNS switch.
# For each line of legacy_urls.tsv, copy <file in this site> to _files/ugd/<Wix file name>.
# An optional third tab-separated column is a note and is ignored.
# Old links therefore always serve the CURRENT version of the paper.
out="${QUARTO_PROJECT_OUTPUT_DIR:-_site}"
mkdir -p "$out/_files/ugd"
tab="$(printf '\t')"
grep -v '^#' legacy_urls.tsv | grep -v '^[[:space:]]*$' | while IFS="$tab" read -r name src _note; do
  if [ -f "$src" ]; then
    cp "$src" "$out/_files/ugd/$name"
  else
    echo "copy_legacy: missing $src (for $name)" >&2
    exit 1
  fi
done
