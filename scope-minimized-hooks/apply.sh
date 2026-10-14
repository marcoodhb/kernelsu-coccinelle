#!/bin/sh

set -eux

target_kernel_dir="${1:-.}"


# We assume the cocci file is in the same directory as the script
sp_file="$(dirname "$(realpath -- "$0")")/kernelsu-scope-minimized.cocci"

# Files declared as patched in the cocci file
files="$(grep -Po 'file in "\K[^"]+' "$sp_file" | sort | uniq)"

cd "$target_kernel_dir"

while IFS= read -r p; do
    spatch --very-quiet --sp-file "$sp_file" --in-place --linux-spacing "$p" || true
done << EOF
$files
EOF

sed -i '/extern int ksu_handle_execveat/i __attribute__((hot))' fs/exec.c 2>/dev/null || true
sed -i '/extern int ksu_handle_post_execveat/i __attribute__((hot))' fs/exec.c 2>/dev/null || true
sed -i '/extern int ksu_handle_faccessat/i __attribute__((hot))' fs/open.c 2>/dev/null || true
sed -i '/extern int ksu_handle_stat/i __attribute__((hot))' fs/stat.c 2>/dev/null || true
