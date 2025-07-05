// Usually in `fs/stat.c`

@vfs_statx@
attribute name __user;
identifier dfd, filename, flags;
statement S1, S2;
@@

+#ifdef CONFIG_KSU
+extern int ksu_handle_stat(int *dfd, const char __user **filename_user, int *flags);
+#endif
vfs_statx(int dfd, const char __user *filename, int flags, ...) {
... when != S1
+#ifdef CONFIG_KSU
+ksu_handle_stat(&dfd, &filename, &flags);
+#endif
S2
...
}

@vfs_fstatat depends on never vfs_statx@
attribute name __user;
identifier dfd, filename, stat, flag;
statement S1, S2;
@@
+#ifdef CONFIG_KSU
+extern int ksu_handle_stat(int *dfd, const char __user **filename_user, int *flags);
+#endif
vfs_fstatat(int dfd, const char __user *filename, struct kstat *stat, int flag) {
... when != S1
+#ifdef CONFIG_KSU
+ksu_handle_stat(&dfd, &filename, &flag);
+#endif
S2
...
}
