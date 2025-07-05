# KernelSU Coccinelle (classic hooks)

**Supported Linux kernels: 3.4 to 6.15 (and above)**

Semantic patches for the scope-minimized manual hooks based on [@backslashxx](https://github.com/backslashxx)'s work. They are designed to minimize the number of common code paths that are hooked in order to reduce their performance impact.

These semantic patches are mostly based on the following:
- https://github.com/backslashxx/KernelSU/issues/5 (v1.3)
- https://github.com/backslashxx/KernelSU/issues/20
- https://github.com/backslashxx/KernelSU/issues/4
- https://github.com/backslashxx/KernelSU/issues/7
- Additional fixes, backports, support for kernel variations, etc.

**Important note**: these hooks need to be applied on a clean kernel source. If you already applied some KernelSU or SUSFS patches they won't work. Furthermore, you can't apply these patches several times on a kernel source. You need to first revert the changes before you can apply them again.

Best practice is to apply these patches in a CI step right before building the kernel and keep your kernel source clean. This way you will never need to revert anything and you can always apply the latest versions of the patches right in CI.

# How to use

1) Install [Coccinelle](https://coccinelle.gitlabpages.inria.fr/website/download.html).
2) Clone the repository:
    ```
    git clone https://github.com/devnoname120/kernelsu-coccinelle
    ```
3) Run the patcher script:
    ```
    cd kernelsu-coccinelle/classic-hooks
    ./apply.sh /path/to/your/kernel/source
    ```

    For example in my case my kernel source location is `~/dev/kernel_xiaomi_sm6150` so I run this: `./apply.sh ~/dev/kernel_xiaomi_sm6150`
