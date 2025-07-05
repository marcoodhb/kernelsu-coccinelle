#!/bin/sh

set -eux

target_kernel_dir="${1:-.}"

# We assume the cocci files are in the same directory as the script
sp_dir="$(dirname "$(realpath -- "$0")")"

cd "$target_kernel_dir"

spatch --sp-file "$sp_dir/input_handle_event.cocci" --in-place --linux-spacing "$target_kernel_dir/drivers/input/input.c"
find "$sp_dir" -iname '*.cocci' | xargs -I{} -P0 spatch --sp-file "{}" --dir "$target_kernel_dir/fs" --in-place --linux-spacing