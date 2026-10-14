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


sed -i -E 's/^static (ssize_t \(\*write_op\[\]\))/\1/' security/selinux/selinuxfs.c
sed -i -E 's/^static (const struct file_operations sel_handle_status_ops)/\1/' security/selinux/selinuxfs.c
sed -i -E 's/^static (void security_dump_masked_av)/\1/' security/selinux/ss/services.c
sed -i -E 's/^static (void context_struct_compute_av)/\1/' security/selinux/ss/services.c

while IFS='|' read -r pat file; do
  if grep -qF "$pat" "$file"; then
    echo "ERROR: sigue static -> $pat ($file)" >&2
    exit 1
  fi
done <<'LIST'
static ssize_t (*write_op[])|security/selinux/selinuxfs.c
static const struct file_operations sel_handle_status_ops|security/selinux/selinuxfs.c
static void security_dump_masked_av|security/selinux/ss/services.c
static void context_struct_compute_av|security/selinux/ss/services.c
LIST
