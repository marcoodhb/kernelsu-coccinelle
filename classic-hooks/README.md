# KernelSU Coccinelle (classic hooks)

**Supported Linux kernels: 3.18 to 5.15**

Re-implementation of the original KernelSU “manual hooks” as semantic patches with some additional required backports. These are the most basic and have the best compatibility with OG KernelSU* and its forks.

They are based on https://kernelsu.org/guide/how-to-integrate-for-non-gki.html#manually-modify-the-kernel-source

**Important note**: these hooks need to be applied on a clean kernel source. If you already applied some KernelSU or SUSFS patches they won't work. Furthermore, you can't apply these patches several times on a kernel source. You need to first revert the changes before you can apply them again.

Best practice is to apply these patches in a CI step right before building the kernel and keep your kernel source clean. This way you will never need to revert anything and you can always apply the latest versions of the patches right in CI.

# How to use

1) Install [Coccinelle](https://coccinelle.gitlabpages.inria.fr/website/download.html).
2) Clone the repository:
    ```
    git clone https://github.com/devnoname120/kernelsu-coccinelle
    ```
2) Run the patcher script:
    ```sh
    cd kernelsu-coccinelle/classic-hooks 
    ./apply.sh /path/to/your/kernel/source
    ```

    For example in my case my kernel source location is `~/dev/kernel_xiaomi_sm6150` so I run this: `./apply.sh ~/dev/kernel_xiaomi_sm6150`